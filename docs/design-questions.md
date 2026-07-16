# Design questions

The single journal of design discrepancies and their fates (English only). Only the agent writes here, always inside the PR that causes the change. Resolved questions are never deleted — the status line is the history. Transport to the designer = `/design-fixes export`.

Status legend: ⏳ open (asked) · ✅ resolved (answer → PR) · ✅ as-designed · 🚫 wontfix.

---

**Q1 — Menu Item Hover state: is unchanged text intentional?**
Evidence: the nav "Our Cars" pill has 4 property variants — `False`/Normal: nav-text-gradient [Role: nav-text, Component: MenuItem], no underline. `True`/Hover: **same** nav-text-gradient [Role: nav-text, Component: MenuItem] as Normal, but an underline (nav-underline-gradient) is added. `Variant3`/Press: solid text-white/80 [Role: nav-text, Component: MenuItem] + underline. `Variant4`/Active: solid white [Role: nav-text, Component: MenuItem] + underline.
Figma links: https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-78 (False) · https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-82 (True/Hover) · https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-86 (Variant3/Press)
Question: Hover keeps the exact same dim gradient text as Normal (only the underline is added), while Press and Active progressively brighten the text. Is that intentional (underline alone signals Hover), or should Hover's text also brighten partway between Normal and Press?
Status: ⏳ open (asked 2026-07-12)

**Q2 — BOOK IT link-button, Press state: arrow icon doesn't match its own text gradient**
Evidence: the "BOOK IT →" link-button has 3 states. Normal (node 2:74): text = button-gradient [Role: link-text, Component: BOOK-IT-button] `#FFB800→#E97000`; arrow icon = same button-gradient [Role: link-icon, Component: BOOK-IT-button]. Hover (node 2:75): text = gradient-hover [Role: link-text, Component: BOOK-IT-button] `#FFC533→#ED8D33`; arrow icon = same gradient-hover [Role: link-icon, Component: BOOK-IT-button] — consistent. **Press (node 2:76): text = gradient-press [Role: link-text, Component: BOOK-IT-button] `#E5A500→#D16500`; but the arrow icon on that SAME instance = button-gradient [Role: link-icon, Component: BOOK-IT-button] `#FFB800→#E97000` — the Normal-state colors, not Press.**
Figma links: https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-74 (Normal) · https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-75 (Hover) · https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-76 (Press)
Question: is the Press-state arrow icon's use of the Normal gradient an authoring slip (should it use gradient-press like the text does, matching the Hover state's own icon/text consistency), or is a two-tone Press state (Press-colored text + Normal-colored icon) intentional?
Status: ⏳ open (asked 2026-07-12)

**Q3 — Filled/CTA button drop-shadow: orange-tinted vs neutral black**
Evidence: existing baseline token `--shadow-button` = `0px 4px 8px rgba(0,0,0,0.15)` `[Role: button-drop-shadow, Component: Button (filled variant)]`, from the Components-file CTA Button/Send, constant across all 3 of its own states [nodes 2:53, 2:55, 2:57]. FF-8's filled "BOOK NOW" instance shows the identical offset/blur/alpha but an orange-tinted color, `0px 4px 8px rgba(233,140,0,0.15)` `[Role: button-drop-shadow, Component: Button (filled variant)]` — confirmed on both its desktop [Verify-node: 1:598] and mobile [Verify-node: 1:1034] placements; `get_variable_defs` on both exact nodes returned only `Button/Gradient` (no bound shadow style/variable), ruling out a flattening artifact.
Figma links: https://www.figma.com/design/JFKSRWAuZTSR4nUMNKe0Gn/Components?node-id=2-53 (neutral source) · https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=1-598 (orange-tinted, FF-8)
Question: is the orange-tinted shadow the deliberate treatment for this hero/marketing filled CTA (a distinct size/context preset from the compact header Send button), or an authoring slip that should match the Send button's neutral shadow?
Status: ⏳ open (asked 2026-07-13)

**Q4 — outline variant's hug→fill breakpoint threshold**
Evidence: only two known widths exist for FF-8's outline "View All Cars" button — 138px hug-content at 1440 (node 1:772) and 328px fill-container at 360 (node 1:1249); no tablet frame was surfaced in the Website file.
Figma links: https://www.figma.com/design/FlWYwSHj7vtd487hdXZi6t/Website?node-id=1-772 (desktop, hug-content) · node 1:1249 (mobile, fill-container — same file)
Question: at what viewport does the outline button switch from hug-content to fill-container? Recommend the project's standard small-breakpoint boundary (~640px) as the literal default pending confirmation.
Status: ⏳ open (asked 2026-07-13)
