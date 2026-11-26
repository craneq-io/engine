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
- [Pinned source manifest](https://github.com/craneq-io/tax-sources/blob/29c82c2a6699dc098388d4b09aff661f254caaa5/manifests/usc/26/7703/2024.json)
- GPO granule `USCODE-2024-title26-subtitleF-chap79-sec7703`, HTML SHA-256 `e88d61d4c0c8709e650c77ae37a3a9b123b828a85d9407e0dbc58f31df811938`.

The initial translation is a review candidate. The first native build request stopped before compilation because the runner lacked Lake. Both the Lean check and independent tax-domain review are pending.

## Build and check

Use the approved container build route with Lean and Lake built from the pinned Lean 4 source revision. The package has no external Lean dependencies. [Lean v4.35.0 source pin](https://github.com/leanprover/lean4/tree/eb6cafb7290e8bd5f2937522d8d804f58f02bafc)

```sh
lake build
```

The default targets cover both the library and its examples. Each example states an expected result as a Lean equality, so a change that breaks one fails the build. Passing the examples establishes behavior of the encoded rule; legal interpretation and effective-date coverage require domain review.

Maintainers can bootstrap the verifier and run the examples in one native Darwin
arm64 queue job with `sh toolchain/native-check.sh`. The build needs the Apple
compiler, SDK, make, Perl, Git, curl, tar and patch from the approved builder
image. It downloads and verifies the five source archives in
[`toolchain/sources.lock`](toolchain/sources.lock), then builds CMake, pkgconf,
OpenSSL, libuv and Lean under a job-local temporary directory. An explicit patch
disables the upstream optional CaDiCaL and leantar downloads. The examples use
neither tool. The script runs the stage 1 Lake against a clean copy of the
committed engine and prints the job ID and source revisions after success.
This bootstrap still awaits its first successful native queue receipt.

## Federal calendar-year 2024 exercises

`CraneQ.Framework` gives each rule a jurisdiction, a supported taxable period
and citations into an immutable source manifest. A result can be determined,
unresolved because a fact is missing, or outside the modeled scope. The covered
period is an implementation decision separate from the edition of the Code.

| Entry point | Caller establishes | Result |
| --- | --- | --- |
| `Section7703.evaluate2024` | Part V of subchapter B of chapter 1 applies or another provision refers to § 7703(a), the death timeline and facts of one spousal relationship | Assessment time and marital finding |
| `Section63.basic2024` | Ordinary nonitemizer case and the § 63(c)(2) category | Basic standard deduction in whole dollars |
| `Section63.standard2024` | The same evidence plus the independently determined additional amount under § 63(c)(3) and (f) | Basic plus additional under § 63(c)(1) |

For a fictional eligible joint return in calendar 2024, the basic amount is
2 × $14,600 = $29,200. An independently established additional $1,550 yields
$30,750. An unknown additional amount leaves the sum unresolved. Separate
review establishes a joint return, qualifying surviving spouse or head of
household. A marital finding alone cannot supply that classification.

The deduction exercise excludes itemizers, § 63(c)(5) dependent limitations,
§ 63(c)(6) zero-deduction cases and special disaster-loss increases. It covers
only calendar 2024. Fiscal years beginning in 2024 also fall outside this pilot.
The residual category covers otherwise eligible unmarried individuals and married
individuals filing separately who fall outside the other named categories.
A later period needs its own source selection. The tests
are synthetic, and native compilation and tax-domain approval remain pending.
[2024 Code and IRS adjustment evidence](https://github.com/craneq-io/tax-sources/blob/e0173c093f195165411a37897aeb8abf79b11f6f/evidence/26-usc-63/sources.json)

### Gain or loss on one brokerage disposition

`Section1001.realized2024` computes signed realized gain or loss in USD cents
under § 1001(a). The caller establishes a calendar-2024 disposition, its amount
realized under § 1001(b), and a § 1011 adjusted basis that applies to both gain
and loss. For a synthetic sale with $99.99 realized and a $100.00 adjusted
basis, the result is −1 cent. A blank basis in a brokerage record leaves the
result unresolved. A documented zero basis is a valid input.

Lot identification, basis adjustments and valuation happen upstream. Different
gain and loss bases fall outside this exercise. Recognition under § 1001(c),
loss deductibility, holding period, return reporting and form preparation require
separate rules and evidence. [2024 U.S. Code, § 1001](https://www.govinfo.gov/content/pkg/USCODE-2024-title26/html/USCODE-2024-title26-subtitleA-chap1-subchapO-partI-sec1001.htm)

### Property basis and the 2024 disposition worksheet

[PropertyBasis](CraneQ/US/IRC/PropertyBasis.lean) computes gain and loss bases in cents for a single ordinary cash purchase with established capital additions, or an outright post-1920 gift meeting the documented assumptions. For a gift with $100 carryover basis and $80 gift-date fair market value, proceeds of $110 yield $10 realized gain, $90 yields zero, and $70 yields $10 realized loss. Depreciation, gift tax adjustments, lot identification, charitable bargain sales and other special treatments require separate rules. Use the special-treatment or unclassified input until the prerequisites are established.

[Form8949](CraneQ/US/Forms/Form8949.lean) computes column (h) from the established whole-dollar entries in (d), (e) and (g). This function accepts rows with numeric proceeds and basis. Rows with a prescribed blank basis or an EXPIRED entry require separate reporting treatment. The caller determines reported basis and signed adjustments under the instructions. This worksheet uses its own reporting units and does not implicitly convert the engine's cents to dollars. Both modules cite the [pinned federal sources](https://github.com/craneq-io/tax-sources/tree/54739fc202d8c5f8fb1ad5659bb578067a6c188c).
