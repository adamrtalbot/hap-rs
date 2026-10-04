# DRAGEN multiallelic opposite-slot aggregates

Issue #84's three W607K HG003 loci, remapped onto short GRCh38 windows:

- `chr1:10988055` — two opposite-slot query insertions (`G>GAGGAAGGA` / `G>GAGAGAGGAAGGAAGGAAGGA`) with `AF=0.778` vs `AF=0`; no truth at the anchor.
- `chr10:26322872` — opposite-slot query insertion + deletion (`T>TTG` / `TTGTGTGTG>T`) with matching truth half-calls.
- `chr15:56855084` — two opposite-slot insertions on both query and truth (`G>GACACAC` / `G>GACAGACAGAC`).

Alleles, genotypes and FORMAT values are copied from the discovery workflow's
split/normalize prepared records for NIST W607K (SHA256
`27eb8e8031e71d2c6565ac9d5ebc9f102063de3483357e2009d2209c48831304`). Confidence excludes the chr1 anchor and a window covering the chr10
insertion/deletion span so those blocks stay UNK, and covers chr15 so the
query aggregate can TP against the split truth rows.

## Stage

The first causal divergence is preprocessing location aggregation. hap.py's
prepared query already contains the three hetalt aggregates (`GT=2/1`);
native used to emit six split rows. Final annotation diffs followed from that
prepared-input grain, not from comparison re-pairing.

The blocker was FORMAT field reordering before aggregation: `AF=0` classified
as Integer while `AF=0.778` classified as Float, so the two opposite-slot
records received different FORMAT orders and the aggregator refused to merge
them. Legacy aggregates first and only type-buckets FORMAT in VariantWriter.
Deferring `reorder_format_fields` until after location aggregation restores
the aggregates. `#91`'s prepared-aggregate retention and `#83`'s padding
lookahead remain separate, retained fixtures.

## Expected HAPPY shape

Both engines prepare one query hetalt per locus and keep truth half-calls
split on chr10/chr15. Annotated records and INDEL ALL/PASS QUERY.TOTAL/UNK
match. The full VCF is not committed.
