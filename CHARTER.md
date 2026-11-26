---
schema: yurei.project-charter/v1
version: 1
purpose:
  statement: Translate United States tax provisions into an open-source Lean engine and maintain those translations as the law changes.
  objectives:
    - Reproduce one tax interpretation from its source.
    - Explain a rule change across effective periods.
    - Keep published coverage current.
  metrics: []
themes:
  - id: cited-rule
    title: Reproduce one tax interpretation from its source
    purpose: Trace a fictional case to a dated source and check the Lean model.
    outcome: A second reviewer reproduces the native check at pinned revisions and records the legal scope.
  - id: historical-replay
    title: Explain a rule change across effective periods
    purpose: Reproduce both results across a real amendment.
    outcome: Replaying the pre-amendment release returns the recorded earlier result.
  - id: continuing-updates
    title: Keep published coverage current
    purpose: Process a new delivery and identify the affected released rules.
    outcome: A retried delivery produces one review proposal and the preceding release remains reproducible.
priorities:
  - Reproduce a cited federal individual income tax rule.
  - Replay an enacted amendment across two applicable periods.
  - Deliver reviewed updates with reproducible coverage.
constraints:
  - Pin the source edition, artifact digest, engine revision and Lean toolchain.
  - Document supported callers, effective periods, exclusions and unresolved facts.
  - Use fictional examples and protect private information.
  - Record native compiler results and independent domain review separately.
departments:
  engineering: {enabled: true, mandate: Deliver the scoped Lean rule and its executable examples.}
  quality: {enabled: true, mandate: Record independent reproduction and domain review.}
  release: {enabled: true, mandate: Record immutable revisions and reviewed coverage.}
---
# CraneQ open-core charter

A contributor should be able to follow a result from a fictional example to the Lean rule, its assumptions, and the dated statutory source. When an amendment changes that result, both the earlier and later result should remain reproducible.

The engine README describes supported exercises and their boundaries. The source repository records the editions and checksums behind those exercises. [Engine coverage](README.md) · [Source evidence](https://github.com/craneq-io/tax-sources)
