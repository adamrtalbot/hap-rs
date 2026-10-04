# pFDA DeepTrio repeat aggregates

This is the original S7K7S input for issue #83, distinct from the GCS query
used by #69. The source sample label `HG002` is retained. The full input was
419874259 bytes with SHA256
`e868ab3c497285cc660683dff8a4515953f1bb5ea772d497d3cac66f3c93852f`.
The source VCF is not included.

The three GRCh38 blocks are remapped to position 501 in real 1001-base
reference windows: chr10 becomes chr1, chr11 becomes chr2, and chr4 becomes
chr3. Sequential contig names keep both engines' contig ordering aligned.
Variant FORMAT fields, genotype orientation, neighboring
calls and the clipped GIAB HG003 v4.2.1 confidence intervals are retained.
Unused INFO and header fields and reference/no-call query records are removed.
Nearby real truth/query SNPs retain the first two comparison contigs.

| Original anchor | Original query complex call | Following query call |
|---|---|---|
| chr10:44341562 | `GG>GGTGTG,T 1/2` | `TG>G 0/1` at 44341564 |
| chr11:73296233 | `AA>AAATATA,T 1/2` | `TA>A 0/1` at 73296235 |
| chr4:152419494 | `AA>AACACACACACA,C 1/2` | `CA>A 0/1` at 152419496 |

The chr4 truth is the real `A>AAAACACAC,AACACACACAC 1/2` call. Inputs reproduce
the discovery workflow's bcftools preprocessing, without a separate PREPY
step: filter canonical contigs, `norm -m-any -c w -f REF`,
`norm --rm-du exact -c w -f REF`, sort, then `norm -c w -f REF`.
Consequently each query complex call enters HAPPY as two biallelic records at
501, and the following deletion is left-aligned to a padded anchor at 502.
Contigs are ordered identically in the minimized inputs and reference; the
original-coordinate confirmation inputs retain the original chromosome names.

Retained prepared files from the repository's HAPPY workflow locate the first
divergence in preprocessing location aggregation, before graph construction,
path enumeration, diploid pairing or classification. Pinned unmodified hap.py
prepares `GG>GGTGTG,G`, `AA>AAATATA,A` and `AA>AACACACACACA,A`, all `2/1`.
Before the fix hap-rs instead prepared separate insertion/deletion rows. Its
lookahead treated the neighboring deletion's VCF padding base at 502 as an
edit consuming 502, although these deletions actually consume 503.

Upstream source at `Illumina/hap.py@84011695`:

- `VariantInput.cpp:169-200` orders primitive splitting, normalization,
  location aggregation, uniqueness and final padding.
- `VariantPrimitiveSplitter.cpp:330-357` and `Variant.hh:239-335` order internal
  edits rather than final padded spellings.
- `VariantLocationAggregator.cpp:108-131` compares the buffered tail's
  normalized position; it has no future-record suppression rule.
- `VariantLeftPadding.cpp:187-200` pads empty-ALT deletions after aggregation.

The correction distinguishes actual reference consumption from padding at the
existing normalization/aggregation boundary. The adjacent-SNP contrast remains
covered by the unchanged PREPY `multiallelic_aggregate_split` case.

Before production edits, the nf-test HAPPY comparator reported `ok: false`
with seven artifact differences for this case. INDEL `QUERY.TOTAL/QUERY.UNK`
was hap.py `6/6` versus hap-rs `9/9`, for both ALL and PASS. Three separate
original-coordinate 2 kb neighborhoods from the full prepared S7K7S input
reproduced `2/2` versus `3/3` per chromosome. The ordinary HAPPY row checks
all annotated records and reports against the pinned unmodified hap.py image.

Once aggregate parity was restored, the unchanged comparator exposed 20 extra
empty INDEL `TS_contained` ROC rows in hap-rs. Only the distant confident SNPs
observe that subset; all these indels are outside confidence. ROC baseline
initialization had propagated a subset observed for one type to every type.
It now tracks observed subsets per type, while retaining empty rows for
explicitly configured stratifications. Upstream `BlockQuantify.cpp:244-261`
observes built-in subsets with the actual type; `RocOutput.cpp:284-318` seeds
configured region names separately. The same group map also determines the
metrics table order and indices; those are not rewritten independently.
