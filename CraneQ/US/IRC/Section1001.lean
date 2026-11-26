import CraneQ.Framework

namespace CraneQ.US.IRC.Section1001

def scope2024 : RuleScope := {
  jurisdiction := .usFederal
  period := .calendarYear 2024
  primarySource := ⟨"ecfc574b898700fba6a2f70d0261c83072e27dbd", "manifests/usc/26/1001/2024.json",
    "USCODE-2024-title26-subtitleA-chap1-subchapO-partI-sec1001", "26 USC 1001(a), 2024 edition"⟩
}

/-- The caller determines the § 1011 basis for gain and for loss. This exercise
covers dispositions where the same adjusted basis applies in both directions. -/
inductive BasisEvidence where
  | common (cents : Nat)
  | differentGainAndLossBases
  | unresolved
  deriving Repr, DecidableEq

/-- Signed realized gain or loss, in USD cents, for one established disposition.
The amount realized under § 1001(b) is an independently established input. -/
def realized2024 (ctx : Context) (amountRealizedCents : Option Nat)
    (basis : BasisEvidence) : Outcome Int :=
  scope2024.evaluate ctx fun _ =>
    match basis, amountRealizedCents with
    | .differentGainAndLossBases, _ => .outsideScope "different gain and loss bases"
    | .unresolved, none => .unresolved "adjusted basis and amount realized"
    | .unresolved, some _ => .unresolved "adjusted basis"
    | .common _, none => .unresolved "amount realized"
    | .common cost, some proceeds => .determined (Int.ofNat proceeds - Int.ofNat cost)

end CraneQ.US.IRC.Section1001
