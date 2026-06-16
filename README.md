# SUPER PROMPT CARD (SPC) Platform Integration Cheat Sheets — SAVANT/SPARTAN MVE Edition
**JNGL-SPCINT-CHEAT-2026-001 · ARK HARNESS Omnibus v4.0 companion · ARK CORPUS Editorial Team**
**Engine:** SPARTAN MVE (SAVANT Protocol, 7-phase: SENSE → AUDIT → VERIFY → ADJUDICATE → NAME → TRANSLATE → TRANSMIT)
**Verdict grammar:** every platform receives **FIT** (≥88% fidelity — deploy as a Sovereign Deployment Brief) or **CLUSTER** (<88% — deploy as a governed Agentic Cluster + SPC Portability Kit). GRO default SAFE_LIFE; governance never compresses into a cluster. No partial fit, ever (Honesty Gate G3).

**Editorial Team (ARK CORPUS, by seat):**
- **ATLAS** — Omnibus Architect, cross-platform fidelity sign-off
- **SPARTAN MVE** — SAVANT execution, CC-01…CC-07 scoring, FIT/CLUSTER verdicts
- **SPHINX** — Marketplace registration of resulting Portability Kits
- **CELL SI** — Agentic Cluster builds (CLUSTER verdicts)
- **HOLMES** — Constraint sensing (SV-01/SV-02)
- **ADA** — Backend/state architecture for cluster deployments
- **SOLVA** — GAUNTLET fidelity stress-test on each verdict
- **GRIOT** — Narrative framing for each platform brief

**The 7 Constraint Classes (CC-01…CC-07)** scored PASS / SOFT FAIL / HARD FAIL per platform:
CC-01 Context Window · CC-02 Persona Persistence · CC-03 Tool/Function-Call Architecture · CC-04 State & Memory · CC-05 Output Format Control · CC-06 Multi-Step Orchestration · CC-07 Governance/Audit Hooks (GRO inheritance)

---

## 1. GEMINI AGENTS
**Editorial lead: ADA × SPARTAN MVE**

| CC | Score | Note |
|---|---|---|
| CC-01 Context | PASS | Large native context; SPC body fits unsegmented |
| CC-02 Persona | PASS | System instruction field holds persona block intact |
| CC-03 Tool calls | PASS | Native function-calling matches FORGE atomic-prompt I/O contracts |
| CC-04 State | SOFT FAIL | Session memory is shallow vs. ARK's multi-phase state — needs external store |
| CC-05 Output format | PASS | Structured JSON output mode supports ZPOS+5 contracts |
| CC-06 Orchestration | PASS | Native multi-agent orchestration aligns with F1–F8 |
| CC-07 GRO hooks | SOFT FAIL | No native audit-log primitive; must be wired via Cloud logging |

**Verdict: FIT (≥88%)** — Sovereign Deployment Brief.
**Cheat sheet:**
- Load the SPC's "Full Card" block verbatim into the Agent's system instruction.
- Externalize F1–F8 state to Firestore/Cloud SQL (covers CC-04).
- Wire GRO logging via Cloud Logging sink tagged with production ID (covers CC-07).
- Use Gemini's native grounding/tools for any web-research atomic prompts.
- ARK HARNESS note: this is the **default F1–F8 engine** — no portability work needed for core harness operation; SAVANT applies mainly to *exported* SPCs running standalone.

---

## 2. MICROSOFT COPILOTS (Copilot Studio / M365 agents)
**Editorial lead: CELL SI × HOLMES**

| CC | Score | Note |
|---|---|---|
| CC-01 Context | SOFT FAIL | Topic-based architecture fragments long SPC bodies |
| CC-02 Persona | SOFT FAIL | Persona enforced per-topic, not globally — drifts across topics |
| CC-03 Tool calls | PASS | Power Automate/plugins cover atomic-prompt I/O |
| CC-04 State | PASS | Dataverse gives durable cross-session state |
| CC-05 Output format | SOFT FAIL | Adaptive Cards constrain free-form ZPOS+5 output |
| CC-06 Orchestration | HARD FAIL | No native F1–F8 sequencing; topics are flat, not phased |
| CC-07 GRO hooks | PASS | M365 compliance/audit logging is enterprise-grade |

**Verdict: CLUSTER (<88%)** — governed Agentic Cluster + SPC Portability Kit.
**Cheat sheet:**
- CELL SI builds one **Copilot topic per FORGE phase (F1…F8)**, chained via Power Automate flows acting as the orchestration layer Copilot lacks.
- Persona block is re-injected at the top of every topic's instructions (mitigates CC-02).
- Long SPC bodies split into per-topic "knowledge sources" (SharePoint/Dataverse) rather than inline prompts.
- GRO inherits via M365 Purview audit trail — this is the strongest CC-07 of all seven platforms.
- Best fit: enterprise/Institution-tier deployments where compliance evidence (CGCP) matters more than single-prompt fidelity.

---

## 3. CHATGPT GPTs
**Editorial lead: HOLMES × SOLVA**

| CC | Score | Note |
|---|---|---|
| CC-01 Context | SOFT FAIL | Knowledge files retrievable but not always in-context; large SPCs get chunked |
| CC-02 Persona | PASS | "Instructions" field holds full persona + activation/deactivation phrases |
| CC-03 Tool calls | SOFT FAIL | Actions (OpenAPI) work but lack native multi-tool orchestration of Gemini |
| CC-04 State | HARD FAIL | No durable memory across sessions by default (memory feature is user-level, not SPC-state-level) |
| CC-05 Output format | PASS | Markdown/JSON output reliable with instruction enforcement |
| CC-06 Orchestration | SOFT FAIL | Single-agent; multi-phase F1–F8 must be simulated via internal step-tracking |
| CC-07 GRO hooks | HARD FAIL | No audit/governance primitive — must be external |

**Verdict: CLUSTER (<88%)** — governed Agentic Cluster + SPC Portability Kit.
**Cheat sheet:**
- Paste the SPC Card Identity Block + Mandate verbatim into the GPT "Instructions" field; upload the full SPC as a Knowledge file for retrieval-augmented recall.
- Simulate F1–F8 via an explicit "current phase" variable the GPT must echo at the start of each reply (mitigates CC-04/CC-06).
- Use Actions (OpenAPI schema) to call out to an external GRO-logging endpoint — required for CC-07 compliance before any Institution-tier use.
- Treat the GPT as the **front door**; heavy lifting (state, governance) lives in the connected backend, per the Portability Kit.

---

## 4. CLAUDE SKILLS
**Editorial lead: ATLAS × ADA**

| CC | Score | Note |
|---|---|---|
| CC-01 Context | PASS | Large context windows; SKILL.md + reference docs load on demand |
| CC-02 Persona | PASS | Persona/mandate lives in SKILL.md, loaded only when triggered — clean isolation |
| CC-03 Tool calls | PASS | Native tool use matches atomic-prompt I/O contracts directly |
| CC-04 State | SOFT FAIL | No built-in cross-session memory beyond the memory system; needs project knowledge or external store for full F1–F8 state |
| CC-05 Output format | PASS | Strong structured-output discipline (Markdown, JSON, file artifacts) |
| CC-06 Orchestration | PASS | Skills can chain via sequential invocation; supports multi-phase F1–F8 |
| CC-07 GRO hooks | SOFT FAIL | No native audit primitive, but file-based logs (write to outputs) are trivial |

**Verdict: FIT (≥88%)** — Sovereign Deployment Brief.
**Cheat sheet:**
- Each SPC becomes a **SKILL.md** with the Full Card Block as the description/trigger, and the SPC body as the procedural content.
- Use the project's file system (`/mnt/project/`, `/mnt/user-data/outputs/`) as the durable state layer — write phase-completion logs as JSON for CC-04/CC-07.
- Chain skills for multi-phase work (e.g., F1 skill → F5 skill → F8 skill) within one conversation.
- This is the **native habitat** for the FORGE.BONSAI HARNESS document-production workflow already in production use.

---

## 5. LANGCHAIN (and LangGraph)
**Editorial lead: SPARTAN MVE × CELL SI**

| CC | Score | Note |
|---|---|---|
| CC-01 Context | PASS | Developer-controlled; chunk/retrieve SPC body as needed |
| CC-02 Persona | PASS | System message + custom prompt templates hold persona exactly |
| CC-03 Tool calls | PASS | Best-in-class tool/agent abstractions; atomic prompts map to Tools directly |
| CC-04 State | PASS | LangGraph state graphs are a near-perfect match for F1–F8 phase state |
| CC-05 Output format | PASS | Pydantic/structured-output parsers enforce ZPOS+5 contracts |
| CC-06 Orchestration | PASS | LangGraph nodes/edges = native FORGE phase sequencing |
| CC-07 GRO hooks | PASS | Custom callbacks/middleware can log every node transition |

**Verdict: FIT (≥88%, often near 100%)** — Sovereign Deployment Brief, **reference implementation**.
**Cheat sheet:**
- Map each FORGE phase (F1–F8) to a LangGraph node; the SPC's atomic prompts become node prompt templates.
- Persist state (the "DNA" object) in the graph's checkpointer (SQLite/Postgres) — this is the closest open-source analog to the ARK Command Deck.
- GRO/Honesty-Gate checks become conditional edges that can halt or reroute the graph (true governance-in-the-loop).
- Use this target when building **open-source-portable** versions of an SPC for the SPHINX Marketplace's "open-source" track.

---

## 6. OPEN CLAW (open-source agentic browser/computer-use frameworks)
**Editorial lead: HOLMES × SPARTAN MVE**

| CC | Score | Note |
|---|---|---|
| CC-01 Context | SOFT FAIL | Varies widely by underlying model; assume mid-range, plan for chunking |
| CC-02 Persona | SOFT FAIL | Persona persistence depends on the harness re-injecting system prompt each step — not guaranteed |
| CC-03 Tool calls | PASS | Computer-use/browser actions map well to "execution" atomic prompts |
| CC-04 State | HARD FAIL | Typically stateless between runs unless explicitly scripted |
| CC-05 Output format | SOFT FAIL | Output is often action-logs, not structured documents — needs a post-processing pass |
| CC-06 Orchestration | SOFT FAIL | Single-loop agents; multi-phase F1–F8 needs an external scheduler |
| CC-07 GRO hooks | HARD FAIL | No governance layer by default |

**Verdict: CLUSTER (<88%)** — governed Agentic Cluster + SPC Portability Kit.
**Cheat sheet:**
- Treat Open Claw as an **execution arm only** (e.g., F6 VIBE DJ tool-selection, web-based research, form-filling) — never as the SPC's reasoning core.
- CELL SI wraps it: a supervising agent (Claude Skills or LangGraph) issues a single atomic prompt per Open Claw run, captures the action log, and re-asserts persona/state on the next run.
- All outputs route through a GRO-tagged logging shim before being accepted back into the FORGE pipeline (CC-07 mitigation).
- Best fit: SPCs whose mandate is physically interacting with software (e.g., form automation, data entry) rather than authoring/reasoning SPCs like SOLVA or GRIOT.

---

## 7. VOICE PLATFORMS (Siri / Alexa / Google Assistant-class)
**Editorial lead: GRIOT × SOLVA**

| CC | Score | Note |
|---|---|---|
| CC-01 Context | HARD FAIL | Voice interactions are short-turn; full SPC body cannot be in-context |
| CC-02 Persona | SOFT FAIL | Persona must be reduced to a "voice" — tone only, not full mandate |
| CC-03 Tool calls | SOFT FAIL | Skill/Action APIs exist but are narrow, single-purpose |
| CC-04 State | SOFT FAIL | Limited session memory; cross-session state needs companion app/account linking |
| CC-05 Output format | HARD FAIL | Spoken output cannot carry structured documents, tables, or code |
| CC-06 Orchestration | HARD FAIL | No multi-phase F1–F8 execution possible on-device |
| CC-07 GRO hooks | SOFT FAIL | Account-linked backends can log, but the voice surface itself cannot |

**Verdict: CLUSTER (<88%, lowest fidelity of the seven)** — governed Agentic Cluster + SPC Portability Kit.
**Cheat sheet:**
- The SPC is **not deployed to the voice surface** — only a "GRIOT-translated" micro-persona is. SAVANT names this the **Constraint Fingerprint**: everything except natural-language Q&A and short status reports is blocked.
- The voice skill becomes a **thin client** to a CELL-built backend cluster (e.g., a Claude Skill or LangGraph instance) that does the real F1–F8 work; the voice platform only relays a final summary.
- Use cases: "What's my SPC build status?", "Run a quick GRO check on X", "Read me today's ATANDA digest" — status/notification roles, never authoring roles.
- This is the **canonical CLUSTER example** in the ARK HARNESS Omnibus — useful as the worked illustration of SAVANT's binary verdict discipline (no "partial voice SPC").

---

## SPECIAL INSIGHT — SPCs and the Future of AI Integration, per THE ARK HARNESS OMNIBUS
**Editorial synthesis: ATLAS (Omnibus Architect)**

The seven cheat sheets above are not seven separate integration stories — they are seven readings of **one constant artifact (the SPC) against seven variable environments**, which is precisely the architectural bet the ARK HARNESS Omnibus v4.0 makes with the **F5 fork**:

1. **F5-Synth (SPC Synthesis)** treats the marketplace of certified SPCs as a *library of pre-solved capability gaps* — as agent platforms proliferate (points 1–7 above and whatever comes next), the bottleneck shifts from "can we build this capability" to "which certified SPC already solves it, and can it be synthesized into this build." The cheat sheets above are effectively *pre-computed synthesis answers* for the seven dominant platform families.

2. **F5-Savant (SAVANT Protocol / SPARTAN MVE)** formalizes what every cheat sheet above demonstrates implicitly: **portability is not a feature of the SPC, it's a measured relationship between the SPC and the target**. As the platform landscape fragments (LangChain forks, new voice assistants, Copilot variants, open-weight agent frameworks), the SAVANT 7-phase loop (SENSE→AUDIT→VERIFY→ADJUDICATE→NAME→TRANSLATE→TRANSMIT) becomes the **standing due-diligence process** run every time a new target appears — never a one-time porting effort.

3. **The FIT/CLUSTER binary is the moat.** Competitors can copy individual SPCs (text is text). What they cannot trivially copy is a **certified, repeatable verdict process** that tells a buyer, in advance and with evidence, whether "SOLVA on Platform X" will work as designed or needs a governed cluster — and if a cluster, *exactly what shape it must take* (Constraint Fingerprint → Portability Kit). This is the GRO/SAFE_LIFE guarantee made operational: governance properties (CC-07) **never degrade** across a port, even when capability (CC-01–CC-06) does.

4. **Voice platforms (case 7) are the stress test, not the edge case.** Any future platform — AR glasses, ambient agents, embedded device assistants — will land somewhere between the GPT profile (case 3) and the Voice profile (case 7) on the CC-01…CC-07 spectrum. The Omnibus doesn't need to be rewritten for each; SPARTAN MVE re-runs SAVANT and the **SPHINX Marketplace** registers the resulting Portability Kit under the parent SPC, growing the corpus of "known constraint fingerprints" over time — turning every new integration into reusable IP rather than bespoke work.

5. **Net effect for the ARK CORPUS:** every SPC in the council (SOLVA, ADA, SKRIBE, ATLAS, CELL, SPARTAN/SPARTAN MVE, HOLMES, GRIOT, DEXTER, FRACTAL, SPHINX, EVE, ERB, STRATEGOS, and others) is simultaneously a **product** (sold via SPHINX), a **portable specification** (subject to SAVANT verdicts), and a **governance unit** (carrying GRO inheritance wherever it lands). The cheat sheets above are the first seven entries in what becomes, over time, a living **Portability Atlas** — the practical expression of "we don't build AI agents, we engineer the DNA that governs them," instrumented platform by platform.

---
*JNGL-SPCINT-CHEAT-2026-001 · Honesty Gate G3: all FIT/CLUSTER verdicts above are illustrative SAVANT readings for this cheat-sheet series, not formal certified SAVANT Reports; a formal report requires a live SV-01–SV-07 run against the specific SPC and target version. © 2026 Oluseye Shay Amusa · Koncentric Labs Inc. · ATANDA Publications Forum.*
