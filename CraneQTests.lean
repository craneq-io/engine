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
