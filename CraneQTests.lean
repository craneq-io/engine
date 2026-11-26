import CraneQ

namespace CraneQTests
open CraneQ.US.IRC.Section7703

-- A reviewer establishes a marriage at the close. A physical move alone does
-- not supply the legally effective decree represented by the second example.
example : assess .noSpouseDeathDuringYear (fun _ => .marriedWithoutQualifyingDecree) =
    ⟨some .yearClose, .married⟩ := rfl
example : assess .noSpouseDeathDuringYear (fun _ => .legallySeparatedUnderQualifyingDecree) =
    ⟨some .yearClose, .treatedAsUnmarried⟩ := rfl

-- One relationship, spouse died during the year. The year-end snapshot differs.
private def widowed : AssessmentTime → Relationship
  | .timeOfSpouseDeath => .marriedWithoutQualifyingDecree
  | .yearClose => .unmarried

example : assess .spouseDiedDuringYear widowed =
    ⟨some .timeOfSpouseDeath, .married⟩ := rfl
example : assess .spouseDiedDuringYear (fun _ => .legallySeparatedUnderQualifyingDecree) =
    ⟨some .timeOfSpouseDeath, .treatedAsUnmarried⟩ := rfl

-- Death after the close falls in the ordinary year-close branch.
example : assessmentTime .noSpouseDeathDuringYear = some .yearClose := rfl
example : assess .noSpouseDeathDuringYear (fun _ => .unmarried) =
    ⟨some .yearClose, .treatedAsUnmarried⟩ := rfl

-- Timing and evidence can each be missing independently.
example (facts : AssessmentTime → Relationship) :
    assess .unresolved facts = ⟨none, .unresolved⟩ := rfl
example : assess .noSpouseDeathDuringYear (fun _ => .unresolved) =
    ⟨some .yearClose, .unresolved⟩ := rfl

end CraneQTests

namespace CraneQTests.Framework
open CraneQ
open CraneQ.US.IRC

private def federal (year : Nat) : Context := ⟨some .usFederal, some (.calendarYear year)⟩

example : Section7703.evaluate2024 (federal 2024) .spouseDiedDuringYear
    (fun _ => .legallySeparatedUnderQualifyingDecree) =
    .determined ⟨some .timeOfSpouseDeath, .treatedAsUnmarried⟩ := rfl
example : Section7703.evaluate2024 (federal 2024) .unresolved (fun _ => .unmarried) =
    .unresolved "spousal death timeline" := rfl

example : Section63.basic2024 (federal 2024) (some .ordinary) (some .jointReturn) = .determined 29200 := rfl
example : Section63.basic2024 (federal 2024) (some .ordinary) (some .qualifyingSurvivingSpouse) = .determined 29200 := rfl
example : Section63.basic2024 (federal 2024) (some .ordinary) (some .headOfHousehold) = .determined 21900 := rfl
example : Section63.basic2024 (federal 2024) (some .ordinary) (some .other) = .determined 14600 := rfl
example : Section63.standard2024 (federal 2024) (some .ordinary) (some .jointReturn) (some 1550) =
    .determined 30750 := rfl
example : Section63.standard2024 (federal 2024) (some .ordinary) (some .other) (some 0) = .determined 14600 := rfl
example : Section63.standard2024 (federal 2024) (some .ordinary) (some .other) none =
    .unresolved "additional deduction amount" := rfl
example : Section63.basic2024 (federal 2024) none (some .other) =
    .unresolved "ordinary deduction eligibility" := rfl
example : Section63.basic2024 (federal 2024) (some .ordinary) none = .unresolved "deduction category" := rfl
example : Section63.basic2024 (federal 2024) (some .specialTreatment) none =
    .outsideScope "election, limitation, or special treatment" := rfl
example : Section63.basic2024 (federal 2025) none none = .outsideScope "taxable period" := rfl
example : Section63.basic2024 ⟨some (.other "US-CA"), none⟩ none none = .outsideScope "jurisdiction" := rfl
example : Section63.basic2024 ⟨none, some (.calendarYear 2024)⟩ none none = .unresolved "jurisdiction" := rfl
example : Section63.basic2024 ⟨some .usFederal, none⟩ none none = .unresolved "taxable period" := rfl

end CraneQTests.Framework
