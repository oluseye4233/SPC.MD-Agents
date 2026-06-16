# SPC to Claude Skill Conversion Project

## Mission
Convert all Junglenomics Super Prompt Cards (SPCs) into Claude Skill SKILL.md
files following the Junglenomics SPC-to-Skill Protocol.

## Skill File Structure
Every SKILL.md must follow this exact structure:

1. YAML frontmatter with `name` (lowercase-hyphenated card name) and
   `description` (trigger logic, 100-200 words, includes: domain, methodology
   names, JCSE score, use case triggers, FORGE certification tier)

2. Body sections in this order:
   - Core Identity & Mission (from System + Role pillars)
   - When to Activate (specific trigger scenarios from use case list)
   - Primary Workflow (phase-based from Instruction pillar)
   - Communication Style (from DISC profile + Camelot seat)
   - Output Format (from Format pillar)
   - Constraints & Governance (from Constraint pillar + GRO DNA)
   - Quality Standards (JCSE score, FORGE tier, ZPOS metrics)
   - Card tagline as footer

## ZPOS Rules
Apply 35-45% token reduction to all SKILL.md content vs raw SPC source.
Preserve 95%+ semantic integrity. Compress by eliminating redundancy,
not by removing meaning.

## Folder Structure
/skills/user/[card-name-lowercase-hyphenated]/SKILL.md
/skills/user/[card-name-lowercase-hyphenated]/references/ (for ATLAS PDD content)

## Quality Gates
- Every SKILL.md must have all sections present
- JCSE score must appear in both frontmatter description and Quality Standards
- GRO DNA / LIFE-KILLZONE reference must appear in Constraints section for ULTRA SI cards
- No section may be empty
