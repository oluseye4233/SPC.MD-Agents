#!/usr/bin/env bash
# validate_skills.sh — Junglenomics SKILL.md quality gate validator
# Checks every SKILL.md under ./skills/user/ against 6 structural rules
# and writes a full report to ./logs/validation_report.txt

set -euo pipefail

# ── Paths ─────────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="${SCRIPT_DIR}/skills/user"
LOG_DIR="${SCRIPT_DIR}/logs"
REPORT_FILE="${LOG_DIR}/validation_report.txt"

# ── Counters ──────────────────────────────────────────────────────────────────
TOTAL=0
PASSED=0
FAILED=0
declare -a FAILED_LIST=()

# ── Colours ───────────────────────────────────────────────────────────────────
RED=""; GREEN=""; YELLOW=""; CYAN=""; BOLD=""; RESET=""
if [[ -t 1 ]]; then
  RED="\033[0;31m"; GREEN="\033[0;32m"; YELLOW="\033[0;33m"
  CYAN="\033[0;36m"; BOLD="\033[1m"; RESET="\033[0m"
fi

# ── Required sections (each entry is a grep pattern) ─────────────────────────
REQUIRED_SECTIONS=(
  "Core Identity"
  "When to Activate"
  "Primary Workflow"
  "Communication Style"
  "Output Format"
  "Constraints"
  "Quality Standards"
)

# ── Report helpers ────────────────────────────────────────────────────────────
rpt()  { echo "$*" >> "${REPORT_FILE}"; }
rpt_pass() { rpt "  [PASS] $*"; }
rpt_fail() { rpt "  [FAIL] $*"; }

# ── Word count (portable: no external wc dependency on content) ───────────────
word_count() {
  # Use awk for portability across macOS / Linux / Git-Bash on Windows
  awk '{w += NF} END {print w+0}' "$1"
}

# ── Count words in a string ───────────────────────────────────────────────────
str_word_count() {
  echo "$1" | awk '{w += NF} END {print w+0}'
}

# ── Extract YAML frontmatter block (between first and second ---) ─────────────
extract_frontmatter() {
  local file="$1"
  awk '
    /^---[[:space:]]*$/ { count++; if (count == 2) exit; next }
    count == 1 { print }
  ' "${file}"
}

# ── Extract value of a YAML key (simple single-line or block scalar) ──────────
# Handles:  key: value on one line
#           key: |                     (literal block — reads until next key)
#           key: >                     (folded block — reads until next key)
yaml_get() {
  local key="$1"
  local file="$2"
  # First try single-line:  key: value
  local val
  val="$(extract_frontmatter "${file}" \
    | grep -E "^${key}:[[:space:]]+" \
    | head -1 \
    | sed -E "s/^${key}:[[:space:]]+//" \
    | sed -E 's/^["'"'"']//; s/["'"'"']$//')"

  if [[ -n "${val}" && "${val}" != "|" && "${val}" != ">" ]]; then
    echo "${val}"
    return
  fi

  # Multi-line block scalar — collect indented lines after  key: |  or  key: >
  extract_frontmatter "${file}" | awk -v key="${key}" '
    BEGIN { found=0 }
    $0 ~ "^"key":[[:space:]]*(\\||>)" { found=1; next }
    found && /^[[:space:]]+/ { gsub(/^[[:space:]]+/, ""); print; next }
    found && /^[^[:space:]]/ { exit }
  '
}

# ── Validate one SKILL.md ─────────────────────────────────────────────────────
validate_file() {
  local filepath="$1"
  local relpath="${filepath#${SKILLS_DIR}/}"
  local file_failed=false
  local -a failures=()

  TOTAL=$(( TOTAL + 1 ))

  rpt ""
  rpt "────────────────────────────────────────────"
  rpt "FILE: ${relpath}"
  rpt "────────────────────────────────────────────"

  # ── Check 6: not empty, at least 400 words ──────────────────────────────────
  local wc
  wc="$(word_count "${filepath}")"

  if [[ "${wc}" -eq 0 ]]; then
    failures+=("File is empty (0 words)")
    file_failed=true
    rpt_fail "File is empty"
  elif [[ "${wc}" -lt 400 ]]; then
    failures+=("Too short: ${wc} words (minimum 400)")
    file_failed=true
    rpt_fail "Word count ${wc} < 400 minimum"
  else
    rpt_pass "Word count: ${wc} words"
  fi

  # ── Check 1a: YAML frontmatter present (file starts with ---) ───────────────
  local first_line
  first_line="$(head -1 "${filepath}")"
  if [[ "${first_line}" != "---" ]]; then
    failures+=("YAML frontmatter missing — file must start with ---")
    file_failed=true
    rpt_fail "No YAML frontmatter (first line is not ---)"
    # Cannot do YAML checks without frontmatter — note and return early
    rpt "  [SKIP] Remaining YAML checks skipped (no frontmatter)"
  else
    rpt_pass "YAML frontmatter present"

    # Check closing --- exists
    local fm_close
    fm_close="$(awk '/^---[[:space:]]*$/{count++} count==2{print NR; exit}' "${filepath}")"
    if [[ -z "${fm_close}" ]]; then
      failures+=("YAML frontmatter not closed — missing second ---")
      file_failed=true
      rpt_fail "YAML frontmatter not closed (no second ---)"
    fi

    # ── Check 1b: name field present and non-empty ───────────────────────────
    local name_val
    name_val="$(yaml_get "name" "${filepath}")"
    if [[ -z "${name_val}" ]]; then
      failures+=("YAML 'name' field missing or empty")
      file_failed=true
      rpt_fail "YAML 'name' field missing or empty"
    else
      rpt_pass "YAML name: ${name_val}"
    fi

    # ── Check 1c: description field present and non-empty ───────────────────
    local desc_val
    desc_val="$(yaml_get "description" "${filepath}")"
    if [[ -z "${desc_val}" ]]; then
      failures+=("YAML 'description' field missing or empty")
      file_failed=true
      rpt_fail "YAML 'description' field missing or empty"
    else
      # ── Check 2: description word count 100-250 ───────────────────────────
      local desc_wc
      desc_wc="$(str_word_count "${desc_val}")"
      if [[ "${desc_wc}" -lt 100 ]]; then
        failures+=("description too short: ${desc_wc} words (min 100)")
        file_failed=true
        rpt_fail "description word count ${desc_wc} < 100"
      elif [[ "${desc_wc}" -gt 250 ]]; then
        failures+=("description too long: ${desc_wc} words (max 250)")
        file_failed=true
        rpt_fail "description word count ${desc_wc} > 250"
      else
        rpt_pass "description word count: ${desc_wc} (within 100-250)"
      fi
    fi

    # ── Check 5: ULTRA SI → GRO / LIFE ZONE / KILLZONE ──────────────────────
    if [[ -n "${name_val}" ]] && echo "${name_val}" | grep -qi "ultra.si"; then
      if grep -qiE "(GRO|LIFE ZONE|KILLZONE)" "${filepath}"; then
        rpt_pass "ULTRA SI governance: GRO/LIFE ZONE/KILLZONE reference found"
      else
        failures+=("ULTRA SI card missing GRO / LIFE ZONE / KILLZONE in body")
        file_failed=true
        rpt_fail "ULTRA SI card — no GRO, LIFE ZONE, or KILLZONE reference found"
      fi
    fi
  fi

  # ── Check 3: required sections ───────────────────────────────────────────────
  for section in "${REQUIRED_SECTIONS[@]}"; do
    if grep -qi "${section}" "${filepath}"; then
      rpt_pass "Section present: ${section}"
    else
      failures+=("Missing section: '${section}'")
      file_failed=true
      rpt_fail "Missing section: '${section}'"
    fi
  done

  # ── Check 4: JCSE score pattern XX/50 ────────────────────────────────────────
  if grep -qE "[0-9]{1,2}/50" "${filepath}"; then
    local jcse_match
    jcse_match="$(grep -oE "[0-9]{1,2}/50" "${filepath}" | head -1)"
    rpt_pass "JCSE score found: ${jcse_match}"
  else
    failures+=("No JCSE score pattern (XX/50) found in file")
    file_failed=true
    rpt_fail "No JCSE score pattern (XX/50) found"
  fi

  # ── Result for this file ──────────────────────────────────────────────────────
  if [[ "${file_failed}" == true ]]; then
    FAILED=$(( FAILED + 1 ))
    FAILED_LIST+=("${relpath}")
    rpt ""
    rpt "  RESULT: FAILED (${#failures[@]} check(s) failed)"
    echo -e "  ${RED}FAIL${RESET} ${relpath}"
    for reason in "${failures[@]}"; do
      echo -e "       ${RED}✗${RESET} ${reason}"
    done
  else
    PASSED=$(( PASSED + 1 ))
    rpt ""
    rpt "  RESULT: PASSED — ${wc} words"
    echo -e "  ${GREEN}PASS${RESET} ${relpath} (${wc} words)"
  fi
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
  mkdir -p "${LOG_DIR}"

  local ts
  ts="$(date '+%Y-%m-%d %H:%M:%S')"

  # Initialise report file
  cat > "${REPORT_FILE}" <<EOF
════════════════════════════════════════════════════════════
  Junglenomics SKILL.md Validation Report
  Generated: ${ts}
════════════════════════════════════════════════════════════

Checks applied to every SKILL.md:
  1. YAML frontmatter present with 'name' and 'description' fields
  2. description: 100-250 words
  3. Required sections: Core Identity | When to Activate | Primary Workflow |
     Communication Style | Output Format | Constraints | Quality Standards
  4. JCSE score pattern (XX/50) present in file
  5. ULTRA SI cards: GRO / LIFE ZONE / KILLZONE reference present
  6. File not empty; minimum 400 words

EOF

  echo ""
  echo -e "${CYAN}${BOLD}════════════════════════════════════════════════════${RESET}"
  echo -e "${CYAN}${BOLD}  Junglenomics SKILL.md Validator                   ${RESET}"
  echo -e "${CYAN}${BOLD}════════════════════════════════════════════════════${RESET}"
  echo ""

  # Guard: skills directory must exist
  if [[ ! -d "${SKILLS_DIR}" ]]; then
    echo -e "${RED}ERROR:${RESET} Skills directory not found: ${SKILLS_DIR}"
    echo "Run convert_spcs.sh first to generate SKILL.md files."
    rpt "ERROR: ${SKILLS_DIR} not found — no files to validate."
    exit 1
  fi

  # Collect all SKILL.md files
  local -a skill_files=()
  while IFS= read -r -d '' f; do
    skill_files+=("$f")
  done < <(find "${SKILLS_DIR}" -name "SKILL.md" -print0 | sort -z)

  if [[ ${#skill_files[@]} -eq 0 ]]; then
    echo -e "${YELLOW}No SKILL.md files found under ${SKILLS_DIR}${RESET}"
    rpt "No SKILL.md files found — nothing to validate."
    exit 0
  fi

  echo -e "Found ${#skill_files[@]} SKILL.md file(s) to validate."
  echo ""
  rpt "Files found: ${#skill_files[@]}"

  for filepath in "${skill_files[@]}"; do
    validate_file "${filepath}"
  done

  # ── Summary block ─────────────────────────────────────────────────────────
  local summary
  summary="$(cat <<EOF

════════════════════════════════════════════════════════════
  VALIDATION SUMMARY
════════════════════════════════════════════════════════════
  Total validated : ${TOTAL}
  Passed          : ${PASSED}
  Failed          : ${FAILED}
EOF
)"

  if [[ ${FAILED} -gt 0 ]]; then
    summary+="

  FILES REQUIRING ATTENTION:"
    for f in "${FAILED_LIST[@]}"; do
      summary+="
    ✗ ${f}"
    done
  fi

  summary+="

════════════════════════════════════════════════════════════
  Report saved to: ${REPORT_FILE}
════════════════════════════════════════════════════════════
"

  # Write summary to report
  rpt "${summary}"

  # Print summary to console
  echo ""
  echo -e "${CYAN}${BOLD}════════════════════════════════════════════════════${RESET}"
  echo -e "${CYAN}${BOLD}  Validation Summary${RESET}"
  echo -e "${CYAN}${BOLD}════════════════════════════════════════════════════${RESET}"
  echo -e "  Total validated : ${TOTAL}"
  echo -e "  ${GREEN}Passed${RESET}          : ${PASSED}"
  echo -e "  ${RED}Failed${RESET}          : ${FAILED}"

  if [[ ${FAILED} -gt 0 ]]; then
    echo ""
    echo -e "${RED}  Files requiring attention:${RESET}"
    for f in "${FAILED_LIST[@]}"; do
      echo -e "  ${RED}✗${RESET} ${f}"
    done
    echo ""
    echo -e "  Fix these files and re-run: ${YELLOW}./validate_skills.sh${RESET}"
  else
    echo ""
    echo -e "  ${GREEN}All files passed validation.${RESET}"
  fi

  echo ""
  echo -e "  Full report: ${REPORT_FILE}"
  echo ""

  # Exit code: 0 = all passed, 2 = failures found
  [[ ${FAILED} -eq 0 ]]
}

# ── Entry point ───────────────────────────────────────────────────────────────
case "${1:-}" in
  --help|-h)
    echo "Usage: $(basename "$0") [--help]"
    echo ""
    echo "Validates every SKILL.md under ./skills/user/ against 6 structural rules."
    echo "Writes a full report to ./logs/validation_report.txt"
    echo ""
    echo "Exit codes:"
    echo "  0 — all files passed"
    echo "  1 — script error (missing directory etc.)"
    echo "  2 — one or more files failed validation"
    ;;
  "")
    main
    ;;
  *)
    echo "Unknown argument: $1  (try --help)"
    exit 1
    ;;
esac
