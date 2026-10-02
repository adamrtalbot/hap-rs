## Agent skills

### Issue tracker

Issues are tracked in the `adamrtalbot/hap.py` GitHub repository. See `docs/agents/issue-tracker.md`.

### Triage labels

The repository uses the five default triage labels. See `docs/agents/triage-labels.md`.

### Domain docs

This is a single-context repository. See `docs/agents/domain.md`.

### Root-cause investigation

For compatibility defects, find and fix the earliest causal divergence from the
original hap.py processing path. Trace the pinned upstream implementation and
its dependencies, and validate behavior in the unmodified reference environment;
source interpretation alone does not establish observed legacy behavior.

- Ground investigations in the exact reported truth/query inputs, reference,
  confidence regions, invocation, and versions. Preserve neighboring records,
  duplicate multiplicity, allele order, genotype orientation, and phase.
- Compare prepared inputs, comparison decisions, and emitted records separately
  before assigning a defect to preprocessing, comparison, or reporting.
- Correct the responsible algorithm, stage order, or state representation. Do
  not add locus, caller, allele-length, genotype-spelling, or output-rewriting
  rules solely to make an observed example pass. Any required legacy rule must
  have evidence of its actual trigger and contrasting cases.
- Retain a minimized fixture with the same causal divergence, demonstrate its
  failure before the fix and agreement afterward, and confirm the original
  public-data case. Do not weaken the equivalence contract to obtain a pass.
- Record immutable source references, reproduction commands, and evidence.
  Distinguish measured causes from source-based hypotheses; if legacy execution
  or original data is unavailable, state the gap rather than claiming closure.
