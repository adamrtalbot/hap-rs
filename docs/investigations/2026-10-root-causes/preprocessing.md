## Confirmed failure

`hap pre` applies a raw complex allele's full REF span as a same-position leftshift floor before primitive decomposition. This makes preprocessing depend on equivalent insertion padding and produces a different record count from unmodified original hap.py.

This is a newly measured compatibility failure derived from the committed #69 chr10:44341562 GRCh38 window, remapped to position32. It is related to the repeat/multiallelic family (#83/#84), but **has not been established as the root cause of their exact public-data failures**. The pure allele shapes from #82/#83 alone do not reproduce those issues; preserve their full original contexts when investigating.

## Versions and authoritative reference

- Native `58da3234f06cef7fd2ef6faefe10aeb0c569c043`.
- Original source `Illumina/hap.py@84011695b2ff2406c16a335106db6831fb67fdfe`.
- Unmodified reference environment `community.wave.seqera.io/library/happy-0.3.15@sha256:1a9cbcff999927913de87c3f7533c18622d08362e2f2accff336a49aa18d8c7b` on linux/amd64; no interpreter or source modifications.
- The reference sequence is identical to the chr10 window in [the existing #69 regression test](https://github.com/adamrtalbot/hap-rs/blob/58da3234f06cef7fd2ef6faefe10aeb0c569c043/rust/src/engines/variant_pipeline.rs#L1395). The query below splits its two selected alleles into source records. This is a derived regression, not an extraction from pFDA S7K7S.

## Reproduce

```sh
mkdir -p floor-repro
cd floor-repro
cat > ref.fa <<'FA'
>chr10
TCGATTACTGTTTCTTAAACTGAACTAATAGGGTGTGTGTGTGTGTGTGTGTGTGTGTGTG
FA
python3 - <<'PY'
from pathlib import Path
s=Path('ref.fa').read_text().splitlines()[1]
Path('ref.fa.fai').write_text(f'chr10\t{len(s)}\t7\t{len(s)}\t{len(s)+1}\n')
h='##fileformat=VCFv4.2\n##contig=<ID=chr10,length=61>\n##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">\n#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\tQUERY\n'
a='chr10\t32\t.\tGG\tGGTGTG\t30\tPASS\t.\tGT\t1/0\n'
b='chr10\t32\t.\tGG\tT\t30\tPASS\t.\tGT\t0/1\n'
Path('input.vcf').write_text(h+a+b)
Path('reversed.vcf').write_text(h+b+a)
Path('insertion-only.vcf').write_text(h+a)
Path('pretrimmed.vcf').write_text(h+a.replace('\tGG\tGGTGTG\t','\tG\tGGTGT\t')+b)
PY
hap pre --leftshift --decompose --no-fixchr -r ref.fa input.vcf native.vcf.gz
docker run --rm --platform linux/amd64 \
  --mount "type=bind,src=$PWD,dst=/work" \
  community.wave.seqera.io/library/happy-0.3.15@sha256:1a9cbcff999927913de87c3f7533c18622d08362e2f2accff336a49aa18d8c7b \
  sh -c 'pre.py -r /work/ref.fa --leftshift --decompose --no-fixchr /work/input.vcf /work/reference.vcf.gz; bcftools view -H /work/reference.vcf.gz'
zcat native.vcf.gz | sed '/^#/d'
```

Ignoring the common `AD:ADO:DP` fields, native emits:

```
chr10 32 G  T      GT1/0
chr10 32 GG G      GT1/0
chr10 33 G  GTGTG  GT0/1
```

Reference emits:

```
chr10 32 G  T         GT1/0
chr10 32 GG G,GGTGTG  GT1/2
```

## Causal evidence and contrasting cases

1. Native [preprocess.rs492-498](https://github.com/adamrtalbot/hap-rs/blob/58da3234f06cef7fd2ef6faefe10aeb0c569c043/rust/src/application/preprocess.rs#L492) scans `GG>T` as a substitution and records raw end33.
2. [preprocess.rs1026-1034](https://github.com/adamrtalbot/hap-rs/blob/58da3234f06cef7fd2ef6faefe10aeb0c569c043/rust/src/application/preprocess.rs#L1026) floors the colocated insertion at33, and [normalization.rs20-27](https://github.com/adamrtalbot/hap-rs/blob/58da3234f06cef7fd2ef6faefe10aeb0c569c043/rust/src/application/preprocess/normalization.rs#L20) applies that bound.
3. Original [VariantInput.cpp164-178](https://github.com/Illumina/hap.py/blob/84011695b2ff2406c16a335106db6831fb67fdfe/src/c%2B%2B/lib/variant/VariantInput.cpp#L164) orders primitive decomposition before normalizer and aggregator. Its [normalizer](https://github.com/Illumina/hap.py/blob/84011695b2ff2406c16a335106db6831fb67fdfe/src/c%2B%2B/lib/variant/VariantAlleleNormalizer.cpp#L218) updates bounds on already processed calls, rather than full raw complex source spans.
4. Measured native insertion-only result is pos32 `G>GGTGT`; adding `GG>T` moves insertion to33.
5. Measured native result with reversed source lines remains the same three rows: this is not merely unsorted source input.
6. Measured pretrimmed equivalent insertion `G>GGTGT` alongside the same `GG>T` yields identical native/reference aggregate `GG>GGTGTG,G GT2/1` at32. Thus a smaller serialized REF bypasses the offending bound even though the biological edit is unchanged.

## Fix direction and acceptance

Trace the original allele-split -> primitive-split -> normalization stream, including buffering, priority ordering and per-sample state. Correct the earliest state/stage divergence. Do not special-case `GG`, this locus, source genotype spelling, or the final aggregate output; do not globally remove genuine SNP/deletion constraints to make this fixture pass.

- Retain this failing two-source-record fixture as an authoritative PREPY regression, with the same two-vs-three row failure before the fix and exact original record/GT output after.
- Preserve both contrasting cases: insertion-only and equivalent pretrimmed insertion.
- Validate single-record #69 shapes, true colocated SNP constraints, opposite-slot deletion split fixtures, duplicate multiplicity, and input row-order behavior against unmodified original reference.
- Before claiming #83/#84 are fixed, obtain their exact public query and external pipeline prepared inputs; compare prepared VCFs before comparison decisions and final rendering. Public NIST input retrieval timed out in this investigation, so that linkage remains unverified.
