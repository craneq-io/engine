import CraneQ.Framework

namespace CraneQ.US.IRC.Section63

private def evidence (artifact citation : String) : SourceRef :=
  ⟨"e0173c093f195165411a37897aeb8abf79b11f6f", "evidence/26-usc-63/sources.json", artifact, citation⟩

def scope2024 : RuleScope := {
  jurisdiction := .usFederal
  period := .calendarYear 2024
  primarySource := evidence "usc-2024.htm" "26 USC 63(c)(1)–(7), 2024 edition"
  supportingSources := [evidence "rp-23-34.pdf" "Rev. Proc. 2023-34, section 3.15"]
}

/-- Classification established under § 63(c)(2), including the § 2 definitions. -/
inductive BasicCategory where
  | jointReturn
  | qualifyingSurvivingSpouse
  | headOfHousehold
  | other
  deriving Repr, DecidableEq

/-- Caller has reviewed the nonitemizer election, eligibility, dependent limitation
and special provisions. Only ordinary, unrestricted cases are covered. -/
inductive DeductionCase where
  | ordinary
  | specialTreatment
  deriving Repr, DecidableEq

private def basicAmount : BasicCategory → Nat
  | .jointReturn | .qualifyingSurvivingSpouse => 2 * 14600
  | .headOfHousehold => 21900
  | .other => 14600

/-- Basic standard deduction in whole dollars for the supported population. -/
def basic2024 (ctx : Context) (eligibility : Option DeductionCase)
    (category : Option BasicCategory) : Outcome Nat :=
  scope2024.evaluate ctx fun _ =>
    match eligibility, category with
    | none, _ => .unresolved "ordinary deduction eligibility"
    | some .specialTreatment, _ => .outsideScope "election, limitation, or special treatment"
    | some .ordinary, none => .unresolved "deduction category"
    | some .ordinary, some c => .determined (basicAmount c)

/-- § 63(c)(1) composition only. The caller establishes the entire § 63(c)(3)
additional amount independently, including an explicit zero where appropriate. -/
def standard2024 (ctx : Context) (eligibility : Option DeductionCase)
    (category : Option BasicCategory) (additional : Option Nat) : Outcome Nat :=
  match basic2024 ctx eligibility category with
  | .outsideScope why => .outsideScope why
  | .unresolved why => .unresolved why
  | .determined basic =>
    match additional with
    | none => .unresolved "additional deduction amount"
    | some amount => .determined (basic + amount)

end CraneQ.US.IRC.Section63
