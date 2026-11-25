# CraneQ Engine

CraneQ translates provisions of the US tax code into Lean definitions with traceable sources and examples. Its first module models a small question: *when do we examine a person's marital status, and what does a qualifying legal-separation decree do to the result?*

## First rule · 26 U.S.C. § 7703(a)

The module covers the general rule in paragraphs (1) and (2) of the **2024 edition**. Its scope is part V of subchapter B of chapter 1 and provisions that refer to subsection (a). A caller first establishes that scope. [GPO section text and historical notes](https://www.govinfo.gov/content/pkg/USCODE-2024-title26/html/USCODE-2024-title26-subtitleF-chap79-sec7703.htm)

| Input | How the model uses it |
| --- | --- |
| Death evidence | Select the individual's taxable-year close by default. If their spouse died during that taxable year, assess at the time of death. A caller must establish the individual's year boundaries and the timing of the event. |
| Relationship at the selected time | Supply an established marriage, an unmarried relationship status, or legal separation under a qualifying divorce or separate-maintenance decree. A qualifying decree produces an unmarried finding. |
| Missing evidence | An unresolved death timeline yields an unresolved time and finding. Unresolved relationship evidence yields an unresolved finding at the selected time. |

For example, suppose a spouse dies in October. A reviewer establishes that the couple was married without a qualifying decree at that time. The rule evaluates the October facts even though the surviving individual is widowed at year-end. The result is scoped to subsection (a).

The pilot handles a single spousal relationship. It assumes someone has already interpreted marriage validity, the legal effect of any decree, and the timing of death under applicable law. Remarriage, competing evidence, subsection (b)'s household tests, filing-status selection, and return eligibility require separate review. Edition year identifies the text used here. Selecting the legally applicable version for any particular taxable year remains an upstream task.

- [Lean implementation](CraneQ/US/IRC/Section7703.lean)
- [Executable boundary examples](CraneQTests.lean)
- GPO granule `USCODE-2024-title26-subtitleF-chap79-sec7703`, HTML SHA-256 `e88d61d4c0c8709e650c77ae37a3a9b123b828a85d9407e0dbc58f31df811938`.

## Build and check

Use the approved container build route with Lean and Lake built from the pinned Lean 4 source revision. The package has no external Lean dependencies. [Lean v4.35.0 source pin](https://github.com/leanprover/lean4/tree/eb6cafb7290e8bd5f2937522d8d804f58f02bafc)

```sh
lake build
```

The default targets cover both the library and its examples. Each example states an expected result as a Lean equality, so a change that breaks one fails the build. Passing the examples establishes behavior of the encoded rule; legal interpretation and effective-date coverage require domain review.
