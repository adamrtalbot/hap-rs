## Agent skills

### Issue tracker

Issues are tracked in the `adamrtalbot/hap.py` GitHub repository. See `docs/agents/issue-tracker.md`.

### Triage labels

The repository uses the five default triage labels. See `docs/agents/triage-labels.md`.

### Domain docs

This is a single-context repository. See `docs/agents/domain.md`.

### Root-cause investigation

For compatibility bugs, reproduce the reported truth/query block against pinned,
unmodified original hap.py. Trace preprocessing, haplotype graph construction,
path enumeration, diploid pairing and classification to the first causal
divergence. Fix that algorithm or state boundary; do not patch symptoms with
locus, caller, allele-length, genotype-spelling or output-rewriting exceptions.
Preserve phase, neighboring calls and duplicate multiplicity. Keep source
references, reproduction evidence and acceptance criteria in the relevant
GitHub issue, and confirm fixes on the original reported data.
