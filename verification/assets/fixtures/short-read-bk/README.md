# Short-read BK=lm over-application

From [issue #80](https://github.com/adamrtalbot/hap-rs/issues/80). Two prepared
blocks where pinned hap.py 0.3.15 reports `ctype=hap:match` and `BK=.`, while
hap-rs stamped `BK=lm` on every outside-CONF row.

The graph signatures of the two sides overlap. The extra `lm` came from
`correct_reaching_insertion_aggregate_block_kind`: any block that touches CONF
and has a 16–64 bp insertion reaching a `GT=2/1` aggregate rewrote `:UNK:.` to
`:UNK:lm`. These blocks do that and are still `hap:match`, so quantify leaves
`BK=.`. The rewrite now runs only when the block is `hap:mismatch`.

## DeepVariant (`deepvariant/`)

Query source: NIST `BSODP_HG003.vcf.gz`, 132437569 bytes, SHA256
`76e1e001abadd7d8e5e987ecefbe12d5fa01c367a4d0fa4e4ede27814af1b48e`
(DeepVariant 1.1.0). Original GRCh38 locus `chr7:32358881` `T>TTG` `1/1`,
plus the multiallelic insertion at `chr7:32358897`.

Truth alleles are the split records from the pipeline-preprocessed GIAB
HG003 v4.2.1 truth
(`HG003_GRCh38_1_22_v4.2.1_benchmark` after split/dedup/norm/filter-missing;
143054789 bytes, SHA256
`fef6522019a435e212fdc3b227bd64ad8660e33dcba52e2a56f7038b3a527320`).
That preprocess rewrote QUAL to 50. REF/ALT/GT are the prepared records.

Coordinates are shifted by 32358700 onto a 380 bp UCSC hg38 slice
(0-based `chr7:32358700-32359080`, uppercased). `conf.bed` keeps the
original confident interval through 1-based 32358830 (`chr7 0 130`).

| Original | Fixture | Side | REF>ALT | Lengths | GT | SHA256 of `REF>ALT` |
| --- | --- | --- | --- | --- | --- | --- |
| chr7:32358881 | 181 | query | T>TTG | 1/3 | 1/1 | `6c31d438a99a38ba2affe07a96e5e2f13919110e0d12b10b201b68286b93b635` |
| chr7:32358881 | 181 | truth | T>TTGTGTGTGTGTGTGTGTCTGTG | 1/23 | 1/0 | `e2700fd4347b577cd4668fe846548a0de89384206d34a4fb8bd06e8451c85f55` |
| chr7:32358881 | 181 | truth | T>TTGTGTGTGTGTGTGTGTCTGTGTG | 1/25 | 0/1 | `b9b2a77fa827086da4c957f0c136df586a9932292301c94ecaf6db53b45c6966` |
| chr7:32358897 | 197 | query | C>CTGT…,CTGT… | 1/21,23 | 1/2 | `c8ba9575627835948be3449e0cd064e5c636f3aafaf7375befae908e394d54da` |
| chr7:32358897 | 197 | truth | C>G | 1/1 | 1/1 | `1aba6c0677ce7de1a1c255bf8dfa0cd0e8158e676b32eaa9898eaaa06134ab10` |

Pinned `hap.py` 0.3.15 (`community.wave.seqera.io/library/happy-0.3.15:7c701db9f05e454a`)
on these inputs: `BS=110;HapMatch;ctype=hap:match`. Outside-CONF rows are
`UNK:.`. The in-CONF `C>T` is `TP:gm`.

## Sentieon (`sentieon/`)

Query source: NIST `KXBR8_HG003.vcf.gz`, 328676968 bytes, SHA256
`b3f5bf69b673fb040c6fa50dd858222000d40875737f3046d7bb86255e52fb0f`
(Sentieon DNAscope). Original GRCh38 locus `chr13:85334339` `C>T` `1/1`,
with the repeat insertions at 85334375 and 85334376. Truth carries the
85334348 insertion pair from the same preprocessed GIAB file.

Shifted by 85334220 onto a 300 bp UCSC hg38 slice
(0-based `chr13:85334220-85334520`, uppercased). `conf.bed` keeps coverage
through 1-based 85334325 (`chr13 0 105`).

| Original | Fixture | Side | REF>ALT | Lengths | GT | SHA256 of `REF>ALT` |
| --- | --- | --- | --- | --- | --- | --- |
| chr13:85334339 | 119 | both | C>T | 1/1 | 1/1 | `dcc438a96a21f5e5160298604960856ca2037d180e3bb47b7c648375a4589b1e` |
| chr13:85334348 | 128 | truth | T>TCTTC… (25) | 1/25 | 1/0 | `9831f9eea80a407cc1408ff805267f7ed7e0986d2678efa76c836333ea5f7e86` |
| chr13:85334348 | 128 | truth | T>TCTTC… (29) | 1/29 | 0/1 | `06ef1f85f6b537892f371f3e5be0407f6f7513aba0901add439ad445f78525f7` |
| chr13:85334375 | 155 | query | T>TCC | 1/3 | 1/1 | `321178cfb74807bb7855c6b72d85590a5b5e5f3a524420e4dca0a6766ef05647` |
| chr13:85334376 | 156 | query | T>TTCCT…,TTCCT… | 1/23,27 | 1/2 | `f1c323da1e028108ec22da1c0912ebab19066ae71a994ddf215746c1a3f93ecd` |
| chr13:85334376 | 156 | truth | T>C | 1/1 | 1/1 | `09e8239cfcd226bb3b5a123c0a783926806450c11849218ad943af396af01085` |

Same pinned hap.py: `BS=75;HapMatch;ctype=hap:match`, and the outside-CONF
rows including `C>T` stay `UNK:.`.

Both HAPPY rows compare the ordered annotated VCF with `-V`. Issue #70
DeepTrio/PEPPER `BK=lm` fixtures and the GRAF long-allele fixtures are
unchanged.
