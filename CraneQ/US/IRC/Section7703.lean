import CraneQ.Framework

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

def scope2024 : RuleScope := {
  jurisdiction := .usFederal
  period := .calendarYear 2024
  primarySource := ⟨"29c82c2a6699dc098388d4b09aff661f254caaa5",
    "manifests/usc/26/7703/2024.json", "USCODE-2024-title26-subtitleF-chap79-sec7703",
    "26 USC 7703(a)(1)–(2), 2024 edition"⟩
}

/-- The caller has established that the referring provision uses subsection (a).
Keep timing and missing evidence distinct from a classification. -/
def evaluate2024 (ctx : Context) (death : DeathEvidence)
    (factsAt : AssessmentTime → Relationship) : Outcome Assessment :=
  scope2024.evaluate ctx fun _ =>
    let result := assess death factsAt
    match result.time, result.finding with
    | none, _ => .unresolved "spousal death timeline"
    | some _, .unresolved => .unresolved "relationship at the selected time"
    | some _, _ => .determined result

end CraneQ.US.IRC.Section7703
