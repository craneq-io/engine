namespace CraneQ

inductive Jurisdiction where
  | usFederal
  | other (identifier : String)
  deriving Repr, DecidableEq

inductive TaxPeriod where
  | calendarYear (year : Nat)
  | otherPeriod
  deriving Repr, DecidableEq

structure Context where
  jurisdiction : Option Jurisdiction
  period : Option TaxPeriod
  deriving Repr, DecidableEq

/-- Source revision and path in craneq-io/tax-sources, plus the specific artifact and citation. -/
structure SourceRef where
  revision : String
  manifest : String
  artifact : String
  citation : String
  deriving Repr, DecidableEq

structure RuleScope where
  jurisdiction : Jurisdiction
  period : TaxPeriod
  primarySource : SourceRef
  supportingSources : List SourceRef := []
  deriving Repr, DecidableEq

inductive Outcome (α : Type) where
  | determined (value : α)
  | unresolved (missing : String)
  | outsideScope (boundary : String)
  deriving Repr, DecidableEq

/-- A known mismatch takes precedence over missing evidence. Each implementation chooses
its coverage window separately from the edition or retrieval date of its sources. -/
def RuleScope.evaluate (scope : RuleScope) (ctx : Context) (run : Unit → Outcome α) : Outcome α :=
  match ctx.jurisdiction, ctx.period with
  | some j, p =>
    if j != scope.jurisdiction then .outsideScope "jurisdiction"
    else match p with
      | none => .unresolved "taxable period"
      | some t => if t == scope.period then run () else .outsideScope "taxable period"
  | none, some t =>
    if t != scope.period then .outsideScope "taxable period" else .unresolved "jurisdiction"
  | none, none => .unresolved "jurisdiction and taxable period"

end CraneQ
