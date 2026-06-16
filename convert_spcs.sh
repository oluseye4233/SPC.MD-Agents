#!/usr/bin/env bash
# convert_spcs.sh — Junglenomics SPC → Claude Skill converter
# Reads each SPC file from ./spcs/, extracts text, pipes through Claude,
# and writes a SKILL.md into ./skills/user/[card-name]/

set -euo pipefail

# ── Environment-specific binaries ────────────────────────────────────────────
CLAUDE="${CLAUDE_BIN:-}"
if [[ -z "${CLAUDE}" ]]; then
  # Auto-detect: try PATH first, then known Windows install location
  if command -v claude &>/dev/null; then
    CLAUDE="$(command -v claude)"
  elif [[ -f "/c/Users/seyek/AppData/Roaming/Claude/claude-code/2.1.121/claude.exe" ]]; then
    CLAUDE="/c/Users/seyek/AppData/Roaming/Claude/claude-code/2.1.121/claude.exe"
  else
    echo "ERROR: claude binary not found. Set CLAUDE_BIN=/path/to/claude.exe" >&2
    exit 1
  fi
fi

PYTHON="${PYTHON_BIN:-}"
if [[ -z "${PYTHON}" ]]; then
  for candidate in python3 python py "/c/Python314/python"; do
    if command -v "${candidate}" &>/dev/null; then
      # Verify it's a real Python (not the Windows stub)
      if "${candidate}" -c "import sys; assert sys.version_info >= (3,8)" &>/dev/null 2>&1; then
        PYTHON="${candidate}"
        break
      fi
    fi
  done
  if [[ -z "${PYTHON}" ]] && [[ -f "/c/Python314/python" ]]; then
    PYTHON="/c/Python314/python"
  fi
fi

# ── Paths ─────────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPCS_DIR="${SCRIPT_DIR}/spcs"
SKILLS_DIR="${SCRIPT_DIR}/skills/user"
PROMPT_FILE="${SCRIPT_DIR}/prompts/spc_conversion_prompt.md"
LOG_DIR="${SCRIPT_DIR}/logs"
LOG_FILE="${LOG_DIR}/conversion_log.txt"

# Effort level for claude (low/medium/high/xhigh/max) — override with --retry for max
CLAUDE_EFFORT="${CLAUDE_EFFORT:-high}"

# ── Counters ──────────────────────────────────────────────────────────────────
TOTAL=0
SUCCEEDED=0
FAILED=0
declare -a FAILED_FILES=()

# ── Colours ───────────────────────────────────────────────────────────────────
RED=""; GREEN=""; YELLOW=""; CYAN=""; RESET=""
if [[ -t 1 ]]; then
  RED="\033[0;31m"; GREEN="\033[0;32m"
  YELLOW="\033[0;33m"; CYAN="\033[0;36m"; RESET="\033[0m"
fi

# ── Helpers ───────────────────────────────────────────────────────────────────
log() { local level="$1"; shift; echo "$(date '+%Y-%m-%d %H:%M:%S') [${level}] $*" >> "${LOG_FILE}"; }
info()    { echo -e "${CYAN}[INFO]${RESET}  $*";  log "INFO"    "$*"; }
success() { echo -e "${GREEN}[OK]${RESET}    $*";  log "SUCCESS" "$*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; log "WARN"    "$*"; }
err()     { echo -e "${RED}[ERROR]${RESET} $*" >&2; log "ERROR"  "$*"; }

# ── Derive card name from filename ────────────────────────────────────────────
derive_card_name() {
  local filename="$1"
  local base
  base="$(basename "${filename}")"
  # Strip all extensions (handles .md.pdf, .docx, .PDF etc.)
  base="${base%%.*}"

  # Strip known suffixes — longest first to avoid partial stripping
  base="$(echo "${base}" | sed \
    -e 's/_ULTRA_SI_V3_0_HIVE_INTEGRATED//gI' \
    -e 's/_ULTRA_SI_SPC//gI' \
    -e 's/_ULTRA_SI//gI' \
    -e 's/_JST_VMST_INDEX_SPC//gI' \
    -e 's/_JST_VMST_INDEX//gI' \
    -e 's/_APP_MANAGEMENT_SPC//gI' \
    -e 's/_SI_ULTRA_SPC//gI' \
    -e 's/_SI_SPC//gI' \
    -e 's/_2_0_ULTRA_SI//gI' \
    -e 's/_2\.0_ULTRA_SI//gI' \
    -e 's/_SPC_v[0-9_]*//gI' \
    -e 's/_Super_Prompt_Card_v[0-9_]*//gI' \
    -e 's/_SPC//gI' \
    -e 's/_v[0-9][_0-9]*//gI' \
    -e 's/ SPC//gI' \
    -e 's/ SI$//gI' \
    -e 's/_MAXIMUS//gI' \
  )"

  # Normalise: lowercase, spaces/underscores → hyphens, strip non-alnum, collapse hyphens
  base="$(echo "${base}" \
    | tr '[:upper:]' '[:lower:]' \
    | sed 's/[[:space:]_]/-/g' \
    | sed 's/[^a-z0-9-]//g' \
    | sed 's/-\{2,\}/-/g' \
    | sed 's/^-//; s/-$//')"

  echo "${base}"
}

# ── Extract text from file ────────────────────────────────────────────────────
extract_content() {
  local filepath="$1"
  local ext="${filepath##*.}"
  ext="$(echo "${ext}" | tr '[:upper:]' '[:lower:]')"

  case "${ext}" in
    md|txt)
      cat "${filepath}"
      ;;
    pdf)
      if command -v pdftotext &>/dev/null; then
        pdftotext "${filepath}" - 2>/dev/null
      elif [[ -n "${PYTHON}" ]]; then
        "${PYTHON}" - "${filepath}" <<'PYEOF'
import sys
from pdfminer.high_level import extract_text
text = extract_text(sys.argv[1])
sys.stdout.buffer.write(text.encode('utf-8', errors='replace'))
PYEOF
      else
        err "No PDF extractor available (need pdftotext or pdfminer.six)"
        return 1
      fi
      ;;
    docx)
      if [[ -n "${PYTHON}" ]]; then
        # Try python-docx first (most reliable), then docx2txt package
        if "${PYTHON}" -c "import docx" &>/dev/null 2>&1; then
          PYTHONIOENCODING=utf-8 "${PYTHON}" - "${filepath}" <<'PYEOF'
import sys, docx
doc = docx.Document(sys.argv[1])
parts = []
for para in doc.paragraphs:
    parts.append(para.text)
# Also extract text from tables
for table in doc.tables:
    for row in table.rows:
        for cell in row.cells:
            parts.append(cell.text)
text = '\n'.join(parts)
sys.stdout.buffer.write(text.encode('utf-8', errors='replace'))
PYEOF
        elif "${PYTHON}" -c "import docx2txt" &>/dev/null 2>&1; then
          PYTHONIOENCODING=utf-8 "${PYTHON}" -c "
import docx2txt, sys
text = docx2txt.process(sys.argv[1])
sys.stdout.buffer.write(text.encode('utf-8', errors='replace'))
" "${filepath}"
        else
          err "No DOCX python library found (install python-docx or docx2txt)"
          return 1
        fi
      elif command -v pandoc &>/dev/null; then
        pandoc --to plain "${filepath}"
      else
        err "No DOCX extractor found (install python-docx, docx2txt, or pandoc)"
        return 1
      fi
      ;;
    *)
      err "Unsupported extension '.${ext}': ${filepath}"
      return 1
      ;;
  esac
}

# ── Preflight ─────────────────────────────────────────────────────────────────
preflight_check() {
  local ok=true

  if [[ ! -d "${SPCS_DIR}" ]]; then
    err "SPCs directory not found: ${SPCS_DIR}"; ok=false
  fi
  if [[ ! -f "${PROMPT_FILE}" ]]; then
    err "Conversion prompt not found: ${PROMPT_FILE}"; ok=false
  fi
  if [[ ! -x "${CLAUDE}" ]] && ! command -v "${CLAUDE}" &>/dev/null; then
    err "Claude binary not found or not executable: ${CLAUDE}"; ok=false
  fi

  info "Claude  : ${CLAUDE}"
  info "Python  : ${PYTHON:-none}"
  info "Effort  : ${CLAUDE_EFFORT}"

  [[ "${ok}" == true ]]
}

# ── Process one SPC file ──────────────────────────────────────────────────────
process_file() {
  local filepath="$1"
  local filename
  filename="$(basename "${filepath}")"

  TOTAL=$(( TOTAL + 1 ))
  info "Processing [${TOTAL}]: ${filename}"

  local card_name
  card_name="$(derive_card_name "${filename}")"

  if [[ -z "${card_name}" ]]; then
    err "  Could not derive card name from: ${filename}"
    FAILED=$(( FAILED + 1 )); FAILED_FILES+=("${filename}"); return
  fi
  info "  Card → ${card_name}"

  local skill_dir="${SKILLS_DIR}/${card_name}"
  local refs_dir="${skill_dir}/references"
  mkdir -p "${skill_dir}" "${refs_dir}"
  local skill_file="${skill_dir}/SKILL.md"

  # Extract text
  local content
  if ! content="$(extract_content "${filepath}" 2>/tmp/_spc_extract_err)"; then
    err "  Extraction failed: $(cat /tmp/_spc_extract_err 2>/dev/null)"
    FAILED=$(( FAILED + 1 )); FAILED_FILES+=("${filename}"); return
  fi

  # Guard against empty extraction
  local char_count="${#content}"
  if [[ "${char_count}" -lt 100 ]]; then
    err "  Extracted content too short (${char_count} chars). Skipping."
    FAILED=$(( FAILED + 1 )); FAILED_FILES+=("${filename}"); return
  fi
  info "  Extracted ${char_count} chars"

  # Build full prompt
  local conversion_prompt
  conversion_prompt="$(cat "${PROMPT_FILE}")"
  local full_prompt
  full_prompt="$(printf '%s\n\n---\n\n## SPC SOURCE\n\nFilename: %s\nDerived card name: %s\n\n%s' \
    "${conversion_prompt}" "${filename}" "${card_name}" "${content}")"

  # Call Claude — use --output-format text for direct SKILL.md output
  local skill_content
  local claude_exit=0
  skill_content="$(echo "${full_prompt}" \
    | "${CLAUDE}" \
        --print \
        --output-format text \
        --effort "${CLAUDE_EFFORT}" \
        --dangerously-skip-permissions \
        2>/tmp/_spc_claude_err)" || claude_exit=$?

  if [[ ${claude_exit} -ne 0 ]]; then
    err "  Claude failed (exit ${claude_exit}): $(cat /tmp/_spc_claude_err 2>/dev/null | head -3)"
    FAILED=$(( FAILED + 1 )); FAILED_FILES+=("${filename}")
    log "RETRY" "${filename}"
    return
  fi

  if [[ -z "${skill_content}" ]]; then
    err "  Claude returned empty output."
    FAILED=$(( FAILED + 1 )); FAILED_FILES+=("${filename}")
    log "RETRY" "${filename}"
    return
  fi

  # Write SKILL.md
  printf '%s\n' "${skill_content}" > "${skill_file}"

  # Inject Reference Files section for cards that have pre-built execution contracts
  local refs_file="${refs_dir}/execution-contracts.md"
  if [[ -f "${refs_file}" ]]; then
    if ! grep -qi "Reference Files" "${skill_file}"; then
      printf '\n\n## Reference Files\n\n- [references/execution-contracts.md](references/execution-contracts.md) — Full ATLAS PromptWare execution contracts (%s prompts)\n' \
        "$(grep -cE '[A-Z]{2,8}-[0-9]{3}' "${refs_file}" 2>/dev/null || echo "see file")" \
        >> "${skill_file}"
      info "  Injected Reference Files section (execution-contracts.md found)"
    fi
  fi

  # Quick section gate
  local missing=()
  for section in "Core Identity" "When to Activate" "Primary Workflow" \
                 "Communication Style" "Output Format" "Constraints" "Quality Standards"; do
    grep -qi "${section}" "${skill_file}" || missing+=("${section}")
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    warn "  Written but missing: ${missing[*]}"
    log "WARN" "${filename} → missing sections: ${missing[*]}"
  else
    success "  → ${skill_file}"
  fi

  SUCCEEDED=$(( SUCCEEDED + 1 ))
  log "SUCCESS" "${filename} → ${skill_file}"
}

# ── Retry mode ────────────────────────────────────────────────────────────────
retry_mode() {
  CLAUDE_EFFORT="max"
  info "Retry mode — effort: max"

  if [[ ! -f "${LOG_FILE}" ]]; then
    err "No log file at ${LOG_FILE}. Nothing to retry."; exit 1
  fi

  local -a retry_files=()
  while IFS= read -r fname; do
    [[ -f "${SPCS_DIR}/${fname}" ]] && retry_files+=("${SPCS_DIR}/${fname}")
  done < <(grep '\[RETRY\]' "${LOG_FILE}" | awk '{print $NF}' | sort -u)

  if [[ ${#retry_files[@]} -eq 0 ]]; then
    info "No failed files in log."; exit 0
  fi

  info "Retrying ${#retry_files[@]} file(s) with effort=max..."
  mkdir -p "${SKILLS_DIR}"
  for f in "${retry_files[@]}"; do process_file "${f}"; echo ""; done

  echo -e "${CYAN}══ Retry Summary ══${RESET}"
  echo -e "  Retried   : ${TOTAL}  Succeeded : ${SUCCEEDED}  Failed : ${FAILED}"
  [[ ${FAILED} -eq 0 ]]
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
  mkdir -p "${LOG_DIR}"
  : > "${LOG_FILE}"

  echo ""
  echo -e "${CYAN}══════════════════════════════════════════════════${RESET}"
  echo -e "${CYAN}  Junglenomics SPC → Claude Skill Converter       ${RESET}"
  echo -e "${CYAN}══════════════════════════════════════════════════${RESET}"
  echo ""

  log "INFO" "Conversion run started — effort=${CLAUDE_EFFORT}"
  preflight_check || { err "Preflight failed."; exit 1; }

  mkdir -p "${SKILLS_DIR}"

  local -a spc_files=()
  while IFS= read -r -d '' f; do
    spc_files+=("$f")
  done < <(find "${SPCS_DIR}" -maxdepth 1 \
    \( -iname "*.md" -o -iname "*.txt" -o -iname "*.pdf" -o -iname "*.docx" \) \
    -print0 | sort -z)

  if [[ ${#spc_files[@]} -eq 0 ]]; then
    warn "No SPC files in ${SPCS_DIR}"; exit 0
  fi

  info "Found ${#spc_files[@]} SPC file(s)"
  echo ""

  for filepath in "${spc_files[@]}"; do
    process_file "${filepath}"
    echo ""
  done

  # Summary
  echo -e "${CYAN}══════════════════════════════════════════════════${RESET}"
  echo -e "${CYAN}  Summary${RESET}"
  echo -e "${CYAN}══════════════════════════════════════════════════${RESET}"
  echo -e "  Total     : ${TOTAL}"
  echo -e "  ${GREEN}Succeeded${RESET} : ${SUCCEEDED}"
  echo -e "  ${RED}Failed${RESET}    : ${FAILED}"
  echo ""
  log "INFO" "Run complete — total=${TOTAL} succeeded=${SUCCEEDED} failed=${FAILED}"

  if [[ ${FAILED} -gt 0 ]]; then
    echo -e "${RED}Failed (retry with: ./convert_spcs.sh --retry):${RESET}"
    for f in "${FAILED_FILES[@]}"; do
      echo -e "  ${RED}✗${RESET} ${f}"
      # Ensure RETRY tag in log for retry mode
      grep -q "\[RETRY\] ${f}$" "${LOG_FILE}" 2>/dev/null || \
        echo "$(date '+%Y-%m-%d %H:%M:%S') [RETRY] ${f}" >> "${LOG_FILE}"
    done
    echo ""
    exit 2
  fi

  echo -e "${GREEN}All conversions succeeded.${RESET}"
  echo -e "Skills: ${SKILLS_DIR}"
  echo -e "Log:    ${LOG_FILE}"
  echo ""
}

# ── Entry ─────────────────────────────────────────────────────────────────────
case "${1:-}" in
  --retry|-r) retry_mode ;;
  --help|-h)
    echo "Usage: $(basename "$0") [--retry]"
    echo "  (no args)  Convert all files in ./spcs/"
    echo "  --retry    Re-process failed files with effort=max"
    ;;
  "") main ;;
  *) err "Unknown: $1"; exit 1 ;;
esac
