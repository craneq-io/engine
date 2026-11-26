import CraneQ.US.IRC.Section1001

namespace CraneQ.US.IRC.PropertyBasis

private def revision := "54739fc202d8c5f8fb1ad5659bb578067a6c188c"

private def statute (sectionNumber subdivision : String) : SourceRef :=
  ⟨revision, "manifests/usc/26/" ++ sectionNumber ++ "/2024.json",
    "USCODE-2024-title26-subtitleA-chap1-subchapO-partII-sec" ++ sectionNumber,
    "26 USC " ++ sectionNumber ++ subdivision ++ ", 2024 edition"⟩

def scope2024 : RuleScope := {
  jurisdiction := .usFederal
  period := .calendarYear 2024
  primarySource := statute "1011" "(a)"
  supportingSources := [Section1001.scope2024.primarySource, statute "1012" "(a)", statute "1015" "(a)", statute "1016" "(a)(1)",
    ⟨revision, "registry/us-federal.json", "https://www.govinfo.gov/content/pkg/CFR-2024-title26-vol13/pdf/CFR-2024-title26-vol13-sec1-1012-1.pdf",
      "26 CFR 1.1012-1(a), 2024 annual edition"⟩]
}

/-- Each supported constructor asserts its legal prerequisites for one entire asset.
Amounts are USD cents. An explicit zero establishes no adjustment. -/
inductive BasisFacts where
  /-- Ordinary cash purchase. The only later adjustments are established capital
  additions under §1016(a)(1), net of its exclusions. No lot allocation is required. -/
  | ordinaryPurchase (cost capitalAdditions : Option Nat)
  /-- Outright gift after 1920. Carryover basis includes pre-gift adjustments.
  No applicable gift-tax increase, later adjustment or special transfer rule. -/
  | outrightGift (carryoverBasis giftDateFMV : Option Nat)
  | unclassified
  | specialTreatment
  deriving Repr, DecidableEq

structure AdjustedBasis where
  gainCents : Nat
  lossCents : Nat
  deriving Repr, DecidableEq

def adjusted2024 (ctx : Context) (facts : BasisFacts) : Outcome AdjustedBasis :=
  scope2024.evaluate ctx fun _ =>
    match facts with
    | .ordinaryPurchase (some cost) (some additions) =>
      .determined ⟨cost + additions, cost + additions⟩
    | .ordinaryPurchase none _ => .unresolved "purchase cost"
    | .ordinaryPurchase _ none => .unresolved "capital additions"
    | .outrightGift (some basis) (some fmv) => .determined ⟨basis, min basis fmv⟩
    | .outrightGift none _ => .unresolved "carryover basis"
    | .outrightGift _ none => .unresolved "gift-date fair market value"
    | .unclassified => .unresolved "basis treatment"
    | .specialTreatment => .outsideScope "special basis or adjustment rule"

/-- Realized result before recognition, character and deduction limits. For a gift
with two bases, the interval between them yields neither gain nor loss. -/
def realized2024 (ctx : Context) (proceeds : Option Nat) (facts : BasisFacts) : Outcome Int :=
  match adjusted2024 ctx facts with
  | .unresolved why => .unresolved why
  | .outsideScope why => .outsideScope why
  | .determined basis =>
    if basis.gainCents == basis.lossCents then
      Section1001.realized2024 ctx proceeds (.common basis.gainCents)
    else
      match proceeds with
      | none => .unresolved "amount realized"
      | some p =>
        if p > basis.gainCents then .determined (Int.ofNat p - Int.ofNat basis.gainCents)
        else if p < basis.lossCents then .determined (Int.ofNat p - Int.ofNat basis.lossCents)
        else .determined 0

end CraneQ.US.IRC.PropertyBasis
