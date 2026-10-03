# Long-allele block kind

The mismatch inputs reproduce [issue #92](https://github.com/adamrtalbot/hap.py/issues/92)
exactly: reference `ACGT` repeated 30 times, truth `G>T 0/1` at chr1:43,
query `G>G+A*784,G+C*788 1/2`, and confidence BED `chr1 0 5`.
Preprocessing retains the query as one aggregate with GT `2/1`.
`control512.vcf` uses the issue's `G+A*511,G+C*511` alleles instead.
These are synthetic inputs, not recovered GRAF records.

The match control reuses the same long alleles as two phased truth calls,
`1|0` and `0|1`. The hapfail control uses the mismatch inputs unchanged with
`--xcmp-enumeration-threshold 1` to exceed the diploid enumeration budget.

Measured query annotations from the unmodified linux/amd64 reference image
`community.wave.seqera.io/library/happy-0.3.15@sha256:1a9cbcff999927913de87c3f7533c18622d08362e2f2accff336a49aa18d8c7b`:

| Case | ctype | GT:BD:BK:BI:BVT:BLT |
| --- | --- | --- |
| 785/789 mismatch | hap:mismatch | 2/1:UNK:lm:i16_plus:INDEL:hetalt |
| 512/512 mismatch | hap:mismatch | 2/1:UNK:lm:i16_plus:INDEL:hetalt |
| 785/789 match | hap:match | 2/1:UNK:.:i16_plus:INDEL:hetalt |
| 785/789 hapfail | hapfail:mismatch | 2/1:UNK:.:i16_plus:INDEL:hetalt |

On native commit `5e9fd0cd42861e3fb808fdb0b20d6d4836e4d752`, the long mismatch
query alone loses `BK=lm`; the other annotated VCF rows agree. The mismatch
truth row is `0/1:UNK:lm:tv:SNP:het`; hapfail leaves its BK as dot too.

Original [XCmpQuantify.cpp, lines 188–204](https://github.com/Illumina/hap.py/blob/84011695b2ff2406c16a335106db6831fb67fdfe/src/c%2B%2B/lib/quantify/XCmpQuantify.cpp#L188-L204)
assigns BK from `TP`, `gtmismatch`, `almismatch` or `hap:mismatch`, then dot.
Allele size and GT orientation do not override that precedence.

The HAPPY samplesheet invokes both implementations with `--output-vtc
--preserve-info` so the ordinary comparator checks complete ordered VCF rows,
including genotype, BD, BK, BI, BVT, BLT and ctype.

Input SHA256 values matching the issue's recorded manifest:

```text
query.vcf       a847bcaa1780a331f639945e0347523879a2942da9cf167c413701593393c40f
control512.vcf  f06f64fe1da3ba0024fe530b8bf770a55fd634471f7869c11cfefc236da8ca89
truth.vcf       20802a8592d23dbbecff88667bc27223226288a8a120c864943bf2113be094d3
ref.fa          a48e6b8d6030d49aae45c0cba55205f1ad24a9b7817ca7bf9c65d74dc9c6673a
ref.fa.fai      88325419128d4165ec370afcbec915d1253b518d77cfef6594f522e70a3060e6
conf.bed        7c0b71d52436cfeb4bad2ee5baa96636a33ea1e135781a93bb3356f794080a72
```
