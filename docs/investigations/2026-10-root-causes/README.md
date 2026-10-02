# Original hap.py root-cause investigation, 2026-10-02

The review covered the 80 open and closed issues available at the start of the
investigation. Deep source and reference executions focused on the outstanding
eight-caller discrepancies (#80–#88), using the closed #69/#70 fixes as contrasts.
No product algorithm was changed. The issue descriptions below are implementation
handoffs, with exact inputs, immutable references, observations and acceptance
criteria.

## Confirmed causes

| Implementation issue | First responsible decision | Measured consequence | Evidence |
| --- | --- | --- | --- |
| [#90](https://github.com/adamrtalbot/hap-rs/issues/90) | Preprocessing derives a left-shift bound from a raw complex substitution before primitive decomposition. | A biologically equivalent padded insertion produces three prepared rows instead of the reference's two. | [Reproduction and contrasting cases](preprocessing.md), `fixtures/raw-complex-floor/` |
| [#91](https://github.com/adamrtalbot/hap-rs/issues/91) | Comparison infers whether a representation is final from GT orientation and neighboring deletions. | Identical prepared records are re-split; INDEL QUERY.TOTAL/UNK becomes 2 instead of 1. | [Reproduction and stage observations](prepared-aggregates.md), `fixtures/persisted-aggregate-resplit/` |
| [#92](https://github.com/adamrtalbot/hap-rs/issues/92) | Two rules suppress BK=lm for multiallelic GT=2/1 when all ALT lengths exceed 512. | Identical ctype, keys, genotypes and decisions receive different BK. Lengths 511/512 agree; 513 and 785/789 diverge. | [Reproduction and threshold controls](long-allele-annotation.md), `fixtures/long-alt-bk/` |
| [#89](https://github.com/adamrtalbot/hap-rs/issues/89) | The discovery pipeline's CSV converter buffers every record to discover optional columns. | Unmodified converter RSS grows from 23,296 KiB at 10,000 records to 278,272 KiB at 200,000. | [Source, benchmark and streaming direction](report-conversion.md) |

The first two fixtures derive from the exact GRCh38 window already committed for
#69, with documented alterations to expose the faulty state transition. The
long-allele fixture is explicitly synthetic. All three scientific failures were
executed against the unmodified reference environment, and independently replayed
by the parent investigation. They are confirmed compatibility defects. Their
relationship to a specific NIST caller report still needs its exact input trace.

The supported common conclusion is that the port sometimes reconstructs or
overrides stage state using raw spans, genotype spelling, neighbor shape or allele
length. These substitutions are fragile because original hap.py makes those
decisions through an ordered variant-processing stream and explicit comparison
state. They do not establish one universal cause for every outstanding issue.

## Versions and provenance

- Native: `58da3234f06cef7fd2ef6faefe10aeb0c569c043`.
- Original source: `Illumina/hap.py@84011695b2ff2406c16a335106db6831fb67fdfe`.
- Reference environment, linux/amd64:
  `community.wave.seqera.io/library/happy-0.3.15@sha256:1a9cbcff999927913de87c3f7533c18622d08362e2f2accff336a49aa18d8c7b`.
- Discovery pipeline:
  `adamrtalbot/variantbenchmarking@7ebe8f6bd4c170799949dfb38a15949cc1934198`.

The pipeline's checked-in legacy image defaults to
`biocontainers/hap.py:0.3.15--py27hcb73b3d_0`. That tag is not proof it is the same
environment as the governed reference digest. Recover the campaign's effective
images, arguments and configuration when confirming its original discrepancies.

Each compact fixture has a SHA256 manifest for its inputs and observed records.
Stored native outputs describe the failing pin, not an acceptance baseline for a
future fix. The original outputs determine the target behavior. Complete embedded
reproductions in the linked handoffs avoid dependence on temporary paths. The
long-allele directory additionally has a runnable `reproduce.sh`.

## Exact caller attribution and remaining work

| Existing issue | Evidence and limits | Next decisive investigation |
| --- | --- | --- |
| [#80](https://github.com/adamrtalbot/hap-rs/issues/80), excessive BK=lm | Original CONF-before-BK precedence was executed on #70 DeepTrio and PEPPER contrasts, which still agree in all 4 and 20 ordered rows. A native reaching-insertion output correction is a source lead; its invocation on the reported blocks is unconfirmed. | Retrieve BSODP/KXBR8 complete BS blocks. Compare prepared inputs, then type/kind/ctype/HapMatch before and after native row corrections. Retain #70's valid lm, #57's hapfail dot and #58's am precedence. |
| [#81](https://github.com/adamrtalbot/hap-rs/issues/81), long GRAF BK | #92 causally reproduces the length predicate. Actual GRAF GT orientation and full block were unavailable. | Retrieve 4HL0B alleles of length 785/789 and 969/969, exact GT and BS neighbors. Show the same state-driven annotation divergence before assigning #92 to these loci. |
| [#82](https://github.com/adamrtalbot/hap-rs/issues/82), GATK deletion aggregation | Simple deletion and aggregate shapes agree between preprocessors. The reported final spelling alone does not identify a universal aggregation bug. | Retrieve UYMUW raw, external pipeline-prepared and internal prepared streams around chr10:99441167 and other listed loci. Preserve unpadded starts and multiplicity. Explain each contribution to the −11 total/UNK count. |
| [#83](https://github.com/adamrtalbot/hap-rs/issues/83), DeepTrio repeats | #90/#91 expose two distinct defects related to the closed #69 family. The S7K7S input is different from #69's GCS input; its cause is not yet established. | Retrieve exact S7K7S blocks, retaining their original sample label. Compare the first divergent stage against both fixtures. Handle its two BK blocks through #80. |
| [#84](https://github.com/adamrtalbot/hap-rs/issues/84), DRAGEN records | #90/#91 are stage-level leads, without W607K prepared records to establish attribution. | Trace UNK aggregation, UNK pairing and TP pairing separately. Account per locus for +96 INDEL total and +95 UNK. |
| [#85](https://github.com/adamrtalbot/hap-rs/issues/85), ensemble homalt becomes two het rows | Original reader allele deduplication and native duplicate projection differ in implementation; no valid original-input counterexample established the responsible step. | Retrieve XV7ZN chr1:102045486/488 with neighbors; trace raw duplicate alleles through decomposition, deduplication, aggregation and emission. Preserve duplicate record multiplicity. |
| [#86](https://github.com/adamrtalbot/hap-rs/issues/86), ensemble FN/FP becomes TP | The isolated G>T truth versus G>A,T query shape gives identical FN/FP in both engines. The earlier ordered-comparator claim is unproven; see below. | Preserve all three real BS blocks. Establish whether query splitting precedes exact matching, then inspect graph paths and genotype selection. Account for whole-caller +41 TP/−41 FN/+17 FP/+510 UNK. |
| [#87](https://github.com/adamrtalbot/hap-rs/issues/87), complex ensemble records | #91 confirms one comparison-time re-splitting defect; that does not identify either XV7ZN block's cause. | Compare raw, prepared and compared records near chr1:1351130 and 14110038. Treat complex indels and same-anchor SNPs separately until their causal traces agree. Account for −91 INDEL UNK. |
| [#88](https://github.com/adamrtalbot/hap-rs/issues/88), missing CSV reports | #89 confirms converter memory growth. Exit 137 alone does not establish OOM, and checked-in retry/finish settings do not explain reported workflow success. | Recover executor termination reason, limits and resolved error strategy. Reuse published benchmark outputs; verify conversion and required-report failure propagation. |

NIST query body requests repeatedly timed out; they were not permission denials.
The [NIST metadata endpoint](https://data.nist.gov/od/id/mds2-2336) did respond.
[public-input-manifest.json](public-input-manifest.json) retains its advertised
size, URL and SHA256 for each of the eight queries. Those hashes were not
independently verified against downloaded files. Metadata did not advertise
remote `.tbi` files, so do not assume remote range extraction is available.

For public confirmation use GIAB HG003 GRCh38 v4.2.1
[truth](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/release/AshkenazimTrio/HG003_NA24149_father/NISTv4.2.1/GRCh38/HG003_GRCh38_1_22_v4.2.1_benchmark.vcf.gz)
and [confidence BED](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/release/AshkenazimTrio/HG003_NA24149_father/NISTv4.2.1/GRCh38/HG003_GRCh38_1_22_v4.2.1_benchmark_noinconsistent.bed),
with the pipeline's exact GRCh38 iGenomes reference. Preserve external
`split_multiallelic,normalize,deduplicate,filter_contigs` preprocessing, followed
by each tool's actual internal stages. Compare the same externally prepared input
in both arms; a separate PREPY experiment is diagnostic, not a substitute for the
campaign invocation. The existing issues carry the samplesheet and pipeline flags.

Retain entire comparison blocks before minimizing. Check slices reproduce the
whole-genome records, including phase, allele order, GT orientation, confidence
boundaries and duplicate counts. Capture INFO classification fields before
quantification with `--output-vtc --preserve-info`. Prove the first causal
divergence and its contrasting cases before selecting a shared fix. Keep #80–#87
open until their exact reported inputs confirm the cause and the fixed behavior.

## Comparator hypothesis correction

An earlier explanation suggested original hap.py's early genotype-mismatch exit
could miss a later exact pair while native set intersection would find it.
However, original DiploidReference constructs candidates with a shared het class
when `nhets != 0`, and a shared non-het class otherwise. That invariant undermines
the proposed example: a het-versus-hom pair cannot later acquire matching classes.
No valid counterexample to equivalence was obtained. Source differences are not
sufficient evidence to file this as the cause of #86.

See original
[DiploidReference.cpp](https://github.com/Illumina/hap.py/blob/84011695b2ff2406c16a335106db6831fb67fdfe/src/c%2B%2B/lib/diploidgraphs/DiploidReference.cpp#L214),
[DiploidComparisonResult.hh](https://github.com/Illumina/hap.py/blob/84011695b2ff2406c16a335106db6831fb67fdfe/src/c%2B%2B/include/DiploidComparisonResult.hh#L70)
and [DiploidCompare.cpp](https://github.com/Illumina/hap.py/blob/84011695b2ff2406c16a335106db6831fb67fdfe/src/c%2B%2B/lib/diploidgraphs/DiploidCompare.cpp#L204).
The last-path-per-mask versus native set-per-mask difference also requires a
valid witness with multiple sequences for one mask before assigning a cause.

## Lessons from closed issues

The history includes both representation and classification fixes. #61 combined
several primitive-alignment/aggregation mechanisms, rather than proving one
cause. #63 required preserving paired row multiplicity; its graph-adjacency title
was misleading. #59's measured cause was ordering, despite an earlier image-drift
explanation. #69/#70 fixed valid measured cases, but #91 now demonstrates a
neighbor condition their existing regression did not cover. Similar loci or
symptoms alone do not establish that a closed fix regressed.

Architecture #2, release policy #8, public confirmation #14/#41 and standalone
normalization #48 remain separate work streams. A passing local corpus does not
resolve new public-data observations. Root guidance in `AGENTS.md` now requires
tracing original hap.py, correcting the causal algorithm or state boundary, and
retaining a faithful failing case plus original public confirmation.
