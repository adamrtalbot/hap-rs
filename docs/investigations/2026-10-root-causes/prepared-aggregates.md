## Confirmed failure

A prepared `GT=1/2` insertion/deletion aggregate is split again during comparison when it lacks an overlapping query deletion. Original hap.py preserves the aggregate. This changes INDEL QUERY.TOTAL/UNK from1 to2.

This is a measured, source-grounded counterexample in the #69/#83 repeat-row family, using #69's exact committed chr10:44341562 GRCh38 window. It proves the existing #69 correction is conditional on neighbor shape; it **does not yet establish that the exact S7K7S public-data case #83 has identical prepared inputs**, because NIST retrieval timed out. Do not close #83/#84 solely on this fixture.

## Pinned versions and source inputs

- Native commit `58da3234f06cef7fd2ef6faefe10aeb0c569c043`.
- Original source `Illumina/hap.py@84011695b2ff2406c16a335106db6831fb67fdfe`.
- Unmodified reference container on linux/amd64: `community.wave.seqera.io/library/happy-0.3.15@sha256:1a9cbcff999927913de87c3f7533c18622d08362e2f2accff336a49aa18d8c7b`.
- Exact source shape/reference from [committed #69 chr10 test](https://github.com/adamrtalbot/hap-rs/blob/58da3234f06cef7fd2ef6faefe10aeb0c569c043/rust/src/engines/variant_pipeline.rs#L1395), locus remapped to32. One distant truth SNP retains comparison contig; target locus is outside confidence regions. No target truth call or adjacent deletion is added.

## Self-contained reproduction

```sh
mkdir -p aggregate-repro
cd aggregate-repro
python3 - <<'PY'
from pathlib import Path
s='TCGATTACTGTTTCTTAAACTGAACTAATAGGGTGTGTGTGTGTGTGTGTGTGTGTGTGTG'
Path('ref.fa').write_text('>chr10\n'+s+'\n')
Path('ref.fa.fai').write_text(f'chr10\t{len(s)}\t7\t{len(s)}\t{len(s)+1}\n')
h='##fileformat=VCFv4.2\n##contig=<ID=chr10,length=61>\n##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">\n#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\t'
Path('query.vcf').write_text(h+'QUERY\nchr10\t32\t.\tGG\tGGTGTG,T\t30\tPASS\t.\tGT\t1/2\n')
Path('truth.vcf').write_text(h+'TRUTH\nchr10\t4\t.\tA\tC\t60\tPASS\t.\tGT\t0/1\n')
Path('conf.bed').write_text('chr10\t0\t10\n')
PY
hap pre --leftshift --decompose --no-fixchr -r ref.fa query.vcf native-pre.vcf.gz
hap germline truth.vcf query.vcf -r ref.fa -f conf.bed --no-fixchr --threads 1 -o native
docker run --rm --platform linux/amd64 \
 --mount "type=bind,src=$PWD,dst=/work" \
 community.wave.seqera.io/library/happy-0.3.15@sha256:1a9cbcff999927913de87c3f7533c18622d08362e2f2accff336a49aa18d8c7b \
 sh -c 'pre.py -r /work/ref.fa --leftshift --decompose --no-fixchr /work/query.vcf /work/reference-pre.vcf.gz; hap.py /work/truth.vcf /work/query.vcf -r /work/ref.fa -f /work/conf.bed --no-fixchr --threads 1 -o /work/reference; bcftools query -f "%CHROM\t%POS\t%REF\t%ALT[\t%GT:%BD:%BK:%BI:%BVT:%BLT]\n" /work/reference.vcf.gz; bcftools query -f "%CHROM\t%POS\t%REF\t%ALT[\t%GT:%BD:%BK:%BI:%BVT:%BLT]\n" /work/native.vcf.gz'
```

Prepared query records are the same:

```
chr10 32 G  T         GT1/0
chr10 32 GG G,GGTGTG  GT1/2
```

Final reference query rows (truth column omitted; identical distant truth row omitted):

```
chr10 32 G  T         1/0:UNK:lm:tv:SNP:het
chr10 32 GG G,GGTGTG  1/2:UNK:lm:d1_5,i1_5:INDEL:hetalt
```

Final native query rows:

```
chr10 30 AG A      0/1:UNK:lm:d1_5:INDEL:het
chr10 32 G  T      1/0:UNK:lm:tv:SNP:het
chr10 33 G  GTGTG  0/1:UNK:lm:i1_5:INDEL:het
```

Reference INDEL QUERY.TOTAL and QUERY.UNK are1 (ALL/PASS); native both2. Same scientific selection, different count/record grain, unlike a BK-only discrepancy.

## Confirmed responsible decision

Native [split_query_primitives_with_neighbors](https://github.com/adamrtalbot/hap-rs/blob/58da3234f06cef7fd2ef6faefe10aeb0c569c043/rust/src/application/compare/rows.rs#L705) resplits unless [persisted_query_representation_is_final](https://github.com/adamrtalbot/hap-rs/blob/58da3234f06cef7fd2ef6faefe10aeb0c569c043/rust/src/application/compare/rows.rs#L903) succeeds. That helper trusts `GT=2/1` unconditionally, but only trusts `GT=1/2` if there is an overlapping deletion and a recognized ALT shape. The prepared aggregate here legitimately carries1/2 and lacks that neighbor, so the helper returnsfalse and changes an already prepared record's grain.

The [closed #69 comparison regression](https://github.com/adamrtalbot/hap-rs/blob/58da3234f06cef7fd2ef6faefe10aeb0c569c043/rust/src/application/compare/test_suite.rs#L3146) always injects an anchor+1 deletion. It therefore exercises the true branch and misses this counterexample. Original [VariantInput](https://github.com/Illumina/hap.py/blob/84011695b2ff2406c16a335106db6831fb67fdfe/src/c%2B%2B/lib/variant/VariantInput.cpp#L164) has explicit primitive-split -> normalization -> aggregation -> uniqueness -> padding stages; the original comparison receives their final record structure. Its actually observed output, above, preserves this1/2 aggregate without requiring the neighbor.

## Fix direction and acceptance

Preserve actual stage/provenance state across the prepare/compare boundary, or faithfully implement the original comparison transformation contract. Genotype orientation is biological data and does not reliably identify whether aggregation has already run. Do not add another GT/ALT/neighbor exception, swap1/2 to2/1 to activate this branch, rewrite final rows, or indiscriminately suppress all valid legacy comparison transformations.

- Retain the failing native-vs-original PREPY and HAPPY fixture, separately demonstrating same prepared records and different final records before the fix.
- Match complete final records, genotype orientation and ALL/PASS QUERY.TOTAL/UNK afterward.
- Keep #69's neighboring-deletion case and raw subset/primitive-split cases that genuinely split in original hap.py. Record explicit contrasting trigger evidence.
- Retrieve and compare exact S7K7S #83 / DRAGEN #84 prepared VCFs before assigning this cause to them. If they are the same class, add their original public-data confirmation and per-locus count accounting; otherwise retain independent issues.
