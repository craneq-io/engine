import CraneQ.Framework

namespace CraneQ.US.Forms.Form8949

def scope2024 : RuleScope := {
  jurisdiction := .usFederal
  period := .calendarYear 2024
  primarySource := ⟨"54739fc202d8c5f8fb1ad5659bb578067a6c188c", "registry/us-federal.json",
    "https://www.irs.gov/pub/irs-prior/f8949--2024.pdf", "2024 Form 8949, column (h)"⟩
  supportingSources := [⟨"54739fc202d8c5f8fb1ad5659bb578067a6c188c", "registry/us-federal.json",
    "https://www.irs.gov/pub/irs-prior/i8949--2024.pdf", "2024 Instructions for Form 8949, columns (d)–(h)"⟩]
}

/-- One applicable row with established column amounts in a consistent whole-dollar
reporting convention. Supply some 0 for a confirmed blank (g). Classification,
rounding, adjustment codes and eligibility to omit the form are upstream decisions. -/
def columnH2024 (ctx : Context) (proceeds basis : Option Nat) (adjustment : Option Int) : Outcome Int :=
  scope2024.evaluate ctx fun _ =>
    match proceeds, basis, adjustment with
    | some d, some e, some g => .determined (Int.ofNat d - Int.ofNat e + g)
    | none, _, _ => .unresolved "column (d)"
    | _, none, _ => .unresolved "column (e)"
    | _, _, none => .unresolved "column (g)"

end CraneQ.US.Forms.Form8949
