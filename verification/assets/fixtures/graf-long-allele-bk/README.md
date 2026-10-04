# GRAF long multiallelic insertion block kind

Real HG003 GRAF records from [issue #81](https://github.com/adamrtalbot/hap-rs/issues/81).
The source query is `4HL0B_HG003.vcf.gz`, **422381613 bytes**, SHA256
`ed5f7702ea16c1e8b63dd1eed697fa87fce6419bd4d5abc912ab3fdf611d8e0f`.
Its size and checksum were verified before extraction on 2026-10-04 from
`/Users/adam.talbot/nist-vcfs/4HL0B_HG003.vcf.gz`. No replacement query was used.
The published source is
[NIST submission 4HL0B](https://data.nist.gov/od/ds/ark:/88434/mds2-2336/submission_vcfs/4HL0B/4HL0B_HG003.vcf.gz).

## Extraction

Each directory contains all truth and query records anchored in the inclusive
GRCh38 input interval below, with the complete comparison block and the nearest
record on either side. Coordinates are shifted onto the corresponding reference
slice; subtract the listed offset from original VCF positions and BED endpoints.
The chromosome remains `chr6`.

| Directory | Original input interval | Reference slice | Offset | Fixture target | Truth/query records |
| --- | --- | --- | --- | --- | --- |
| `31329617` | 31329565–31331287 | 31329365–31331487 | 31329364 | 253 | 97 / 96 |
| `32675681` | 32675579–32675910 | 32673503–32676482 | 32673502 | 2179 | 11 / 11 |

REF and ALT strings are copied verbatim, without shortening, synthesis, or
reordering. ID, QUAL, FILTER and GT are retained too. INFO and other FORMAT
fields are removed. All retained source genotypes are unphased; the truth's
PS values are missing. Record order and duplicate multiplicity are preserved.
The complete source confidence intervals intersecting the retained records are
shifted without clipping: 31329860–31331287 for the first case, and
32673703–32675606 plus 32675757–32676282 for the second (original BED endpoints).
Reference slices extend beyond those intervals, preserving their boundaries.
The first case also retains every source call through its following confident
interval, preserving that interval's SNP and INDEL quantification context.
`regions.bed` selects the entire slice for the preprocessing lane.

Truth comes from GIAB
[`HG003_GRCh38_1_22_v4.2.1_benchmark.vcf.gz`](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/release/AshkenazimTrio/HG003_NA24149_father/NISTv4.2.1/GRCh38/HG003_GRCh38_1_22_v4.2.1_benchmark.vcf.gz)
(147212428 bytes, SHA256
`a4f8fefa826f8d2c9457eacf6f4b2f6bfa29daef429d570ce04254c5e7b1121e`).
Confidence regions come from
[`HG003_GRCh38_1_22_v4.2.1_benchmark_noinconsistent.bed`](https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/release/AshkenazimTrio/HG003_NA24149_father/NISTv4.2.1/GRCh38/HG003_GRCh38_1_22_v4.2.1_benchmark_noinconsistent.bed)
(13219856 bytes, SHA256
`652afd3046705af3200f9c87c255fef11bb212dd76c75a19999c9b2df8a3180c`).
Reference bases were extracted with `samtools faidx` from the local iGenomes
NCBI GRCh38 `genome.fa`; every retained REF was checked against that sequence.

The query's literal source GT is `1/2` at both loci. The first source record's
ALT order is **789, 785** bases; preprocessing orders it **785, 789** with GT
`2/1`. The second source record has two different 969-base ALTs. Their SHA256
values below hash the literal ASCII allele strings, without a trailing newline,
in source order:

```text
31329617 ALT1 789 b57cf11c4bed516448401acf4b8844f735093787e20e52b15f30278bc35c3867
31329617 ALT2 785 938781a745a21a292ebef3ddb94669b21ddd64bcb4e8a1e54683609375301c1c
32675681 ALT1 969 652feeda6ccce391875e01eae5c4f5f0e0f6354d98fb59b6ef3dbc95dde9b19c
32675681 ALT2 969 032a26d35e8a69e65868c58ee3f860299e432fc9f94763c43499e340c5ec1850
```

## Evidence and acceptance

The unmodified reference is
`community.wave.seqera.io/library/happy-0.3.15@sha256:1a9cbcff999927913de87c3f7533c18622d08362e2f2accff336a49aa18d8c7b`,
run on `linux/amd64`. Initial 20,001-base scouting windows established identical
prepared truth and query rows within both target blocks on native base
`64a545061e474445643a9f8e40d20c97c9562afa`:

| Original block | Prepared truth/query rows | Annotated block rows | Query `BD:BK:BI:BVT:BLT` at target |
| --- | --- | --- | --- |
| chr6:31329617–31329832 | 18 / 18 | 19 | `UNK:lm:i16_plus:INDEL:hetalt` |
| chr6:32675643–32675807 | 9 / 9 | 10 | `UNK:lm:i16_plus:INDEL:hetalt` |

Both engines emit `ctype=hap:mismatch` and the expected query annotations in
diagnostic runs. The final fixtures retain those blocks and their boundary
neighbors. The germline cases use the standard annotated-VCF invocation from
the existing real-data BK cases, so the unchanged comparator checks complete
ordered records, including GT, BD, BK, BI, BVT and BLT. Optional diagnostic
`--preserve-info` exposes additional neighboring `kind/type` differences beyond
the reported annotation contract; production changes to those fields are outside
this issue. Two preprocessing cases also compare the complete prepared query
VCFs and indexes.

[PR #97](https://github.com/adamrtalbot/hap-rs/pull/97) already removed the two
annotation suppressors in `bk_for_row` and `correct_long_aggregate_block_kind`.
Their pre-fix conditions (multiallelic ALT lengths above 512 and prepared GT
`2/1`, with `UNK:lm` for the final-row rewrite) apply to these real records.
The evidence places the reported loss at BK classification and its subsequent
row correction, rather than preprocessing. Original
[XCmpQuantify.cpp, lines 188–204](https://github.com/Illumina/hap.py/blob/84011695b2ff2406c16a335106db6831fb67fdfe/src/c%2B%2B/lib/quantify/XCmpQuantify.cpp#L188-L204)
derives BK from the comparison state without an allele-length override.
No further production change is required on this base. The existing 512-base,
haplotype-match and enumeration-failure controls remain in the gate.

Fixture VCF SHA256 values:

```text
31329617/query.vcf 7d8df43ce2ba89de7a3b4e24111e3958978c690391e51c6f65bc176c95f18d04
31329617/truth.vcf e6144d2db31034f71e89e93a7d59548488e2f64e563b85b6735c89d8ea5c448a
32675681/query.vcf 8e6b223ffa897bcfd57ede4d927921420a29c4226b15b3d2aec3812c62353de3
32675681/truth.vcf ac38ace1a84698812bd6dd7484585be26a4e81f3d3b1b455a4eb8ea5d6b89477
```
