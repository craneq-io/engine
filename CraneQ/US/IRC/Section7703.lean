/-!
# 26 U.S.C. § 7703(a), 2024 edition

Determination time and qualifying legal separation for a single, reviewed
spousal relationship. Callers establish that the referring provision uses
subsection (a). See the package README for the source and coverage boundary.
-/

namespace CraneQ.US.IRC.Section7703

/-- A reviewer classifies the death relative to the individual's taxable year. -/
inductive DeathEvidence where
  | noSpouseDeathDuringYear
  | spouseDiedDuringYear
  | unresolved
  deriving Repr, DecidableEq

inductive AssessmentTime where
  | yearClose
  | timeOfSpouseDeath
  deriving Repr, DecidableEq

/-- Facts at the selected time, before applying the federal separation rule.
A qualifying decree means legal separation under a decree of divorce or
separate maintenance. Physical separation alone does not establish this fact. -/
inductive Relationship where
  | unmarried
  | marriedWithoutQualifyingDecree
  | legallySeparatedUnderQualifyingDecree
  | unresolved
  deriving Repr, DecidableEq

inductive Finding where
  | married
  | treatedAsUnmarried
  | unresolved
  deriving Repr, DecidableEq

structure Assessment where
  time : Option AssessmentTime
  finding : Finding
  deriving Repr, DecidableEq

/-- § 7703(a)(1) selects the time. Missing evidence remains explicit. -/
def assessmentTime : DeathEvidence → Option AssessmentTime
  | .noSpouseDeathDuringYear => some .yearClose
  | .spouseDiedDuringYear => some .timeOfSpouseDeath
  | .unresolved => none

/-- § 7703(a)(2) applies the decree exception to the selected facts. -/
def assess (death : DeathEvidence) (factsAt : AssessmentTime → Relationship) : Assessment :=
  match assessmentTime death with
  | none => ⟨none, .unresolved⟩
  | some t =>
    let finding : Finding := match factsAt t with
      | .marriedWithoutQualifyingDecree => .married
      | .unmarried | .legallySeparatedUnderQualifyingDecree => .treatedAsUnmarried
      | .unresolved => .unresolved
    ⟨some t, finding⟩

end CraneQ.US.IRC.Section7703
