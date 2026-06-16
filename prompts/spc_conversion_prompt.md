You are converting a Junglenomics Super Prompt Card (SPC) into a Claude
Skill SKILL.md file. The SPC content follows this message.

EXTRACTION RULES — read the SPC and extract:

CARD_NAME: The primary card identifier (e.g. EVE ULTRA SI, STRATEGOS ULTRA SI)
JCSE_SCORE: The JCSE score out of 50
FORGE_TIER: The FORGE certification tier (Standard/Premium/Ultra Premium)
DISC_PROFILE: The DISC personality code (D, I, S, C, DI, DC, etc.)
CAMELOT_SEAT: The Camelot Roundtable seat number and archetype name
DOMAIN: The primary domain of expertise
USE_CASES: List of specific tasks this card performs
SYSTEM_PILLAR: Core identity and operating context
ROLE_PILLAR: Domain authority and expertise definition
INSTRUCTION_PILLAR: Primary workflow and task directives
EXAMPLE_PILLAR: Sample outputs or demonstrations
CONSTRAINT_PILLAR: Limitations, boundaries, ethical guardrails
FORMAT_PILLAR: Output structure specifications
DATA_PILLAR: Contextual information and reference data
GRO_DNA: Any GRO/LIFE ZONE/KILLZONE/ANT KING references
ZPOS_METRICS: Token reduction percentage and semantic preservation percentage
TAGLINE: The card's motto or tagline

CONSTRUCTION RULES:

1. YAML frontmatter name: lowercase hyphenated card name
2. YAML frontmatter description: write trigger logic that includes the domain,
   3-5 specific methodology names from the card, JCSE score, 3-5 specific use
   case triggers as the scenarios a user would describe, and FORGE tier.
   This must be 100-200 words. This is the most important section.
3. Body: follow the section order in CLAUDE.md exactly
4. ZPOS application: reduce total token count by 35-45% vs the raw SPC.
   Cut redundancy, repetition, and verbose preamble. Never cut methodology
   names, JCSE scores, or domain-specific terminology.
5. GRO DNA: if the SPC is ULTRA SI class, the Constraints section must
   reference LIFE ZONE / KILLZONE mode switching and GRO ethical governance
6. Footer: end with the card tagline and "Junglenomics / Idea Factory"

OUTPUT: Return ONLY the raw SKILL.md content. No preamble, no explanation,
no code fences. Start immediately with the three dashes of the YAML frontmatter.
