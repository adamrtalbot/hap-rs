## Confirmed failure

A multiallelic query with prepared GT=2/1 and both ALTs longer than 512 bases loses BK=lm even when native and original hap.py agree on ctype=hap:mismatch, selected genotypes, record keys and scientific decisions. Native returns UNK:.; original returns UNK:lm. At ALT lengths 511 and 512 both return lm; at 513 both ALTs trigger the native suppression.

This is confirmed by executing unmodified pinned hap.py against a valid **synthetic** counterexample. It is grounded in original hap.py execution and source, not a recovered GRAF truth/query locus. The allele lengths 785/789 reproduce the length predicate reported in #81; whether the real GRAF rows exercise this same path still requires their exact query inputs and GTs. Do not close #81 merely on this fixture.

## Versions

- hap-rs 58da3234f06cef7fd2ef6faefe10aeb0c569c043.
- Original source 84011695b2ff2406c16a335106db6831fb67fdfe.
- Unmodified reference environment linux/amd64: community.wave.seqera.io/library/happy-0.3.15@sha256:1a9cbcff999927913de87c3f7533c18622d08362e2f2accff336a49aa18d8c7b.

## Self-contained reproducer

The reference is synthetic ACGT repeated 30 times; truth G>T at 43, query two insertions at 43. Confidence BED excludes the block. Use hap built from the native pin above.

```sh
mkdir long-bk-repro
cd long-bk-repro
python3 - <<'PY'
from pathlib import Path
s='ACGT'*30
Path('ref.fa').write_text('>chr1\n'+s+'\n')
Path('ref.fa.fai').write_text('chr1\t120\t6\t120\t121\n')
h='##fileformat=VCFv4.2\n##contig=<ID=chr1,length=120>\n##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">\n#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\tSAMPLE\n'
Path('truth.vcf').write_text(h+'chr1\t43\t.\tG\tT\t30\tPASS\t.\tGT\t0/1\n')
for n,a,b in [('query',784,788),('control511',510,510),('control512',511,511),('control513',512,512)]:
 Path(n+'.vcf').write_text(h+'chr1\t43\t.\tG\tG'+'A'*a+',G'+'C'*b+'\t30\tPASS\t.\tGT\t1/2\n')
Path('conf.bed').write_text('chr1\t0\t5\n')
PY
for case in query control511 control512 control513; do
 hap germline truth.vcf "$case.vcf" -r ref.fa -f conf.bed -o "native-$case" --threads 1 --no-roc --output-vtc --preserve-info
 docker run --rm --platform linux/amd64 --mount "type=bind,src=$PWD,dst=/work" community.wave.seqera.io/library/happy-0.3.15@sha256:1a9cbcff999927913de87c3f7533c18622d08362e2f2accff336a49aa18d8c7b hap.py /work/truth.vcf "/work/$case.vcf" -r /work/ref.fa -f /work/conf.bed -o "/work/reference-$case" --threads 1 --no-roc --output-vtc --preserve-info
done
```

Measured target rows (ALT sequences specified exactly by generation above):

| Case | Both INFO ctype | Both query GT/BD/BI/BVT/BLT | Original BK | Native BK |
|---|---|---|---|---|
| ALT length 785,789 | hap:mismatch | 2/1:UNK:i16_plus:INDEL:hetalt | lm | . |
| ALT length 511,511 | hap:mismatch | 2/1:UNK:i16_plus:INDEL:hetalt | lm | lm |
| ALT length 512,512 | hap:mismatch | 2/1:UNK:i16_plus:INDEL:hetalt | lm | lm |
| ALT length 513,513 | hap:mismatch | 2/1:UNK:i16_plus:INDEL:hetalt | lm | . |

Both arms also emit the identical truth G>T row 0/1:UNK:lm:tv:SNP:het. In the failing row, INFO kind=missing,type=FP,ctype=hap:mismatch and XCMP=UNK:missing:.:gt_hetalt:hap:mismatch agree between implementations. INDEL QUERY.TOTAL/UNK 1 in both ALL/PASS. This isolates annotation from graph-classification/count differences.

## Confirmed root cause and references

Native [bk_for_row](https://github.com/adamrtalbot/hap-rs/blob/58da3234f06cef7fd2ef6faefe10aeb0c569c043/rust/src/application/compare/rows.rs#L1014-L1029) independently returns dot when GT2/1 and all ALT lengths>512, ignoring hap_mismatch. A second [correct_long_aggregate_block_kind](https://github.com/adamrtalbot/hap-rs/blob/58da3234f06cef7fd2ef6faefe10aeb0c569c043/rust/src/application/compare/matching.rs#L1082-L1096) rewrites emitted UNK:lm back to UNK:. for the same predicate; called after classification at matching772. Both must be addressed; removing only one leaves the other.

Original [XCmpQuantify.cpp174–204](https://github.com/Illumina/hap.py/blob/84011695b2ff2406c16a335106db6831fb67fdfe/src/c%2B%2B/lib/quantify/XCmpQuantify.cpp#L174-L204) changes BD to UNK outside CONF before applying BK precedence: TP→gm; gtmismatch→am; almismatch OR ctype hap:mismatch→lm; otherwise dot. No length/GT spelling exceptions. The counterexample follows this original rule and proves native's suppression changes an otherwise identical classification state.

## Fix direction and acceptance

Make BK derive from the authoritative comparison state with original precedence. Remove the two unjustified size-based corrections after verifying contrasting original outcomes; do not replace 512 with another threshold or a GRAF/caller-specific predicate.

- Add this failing case plus 512-base control as an authoritative parity case against unmodified reference environment; require exact genotype/BD/BK/BI/BVT/BLT and ctype agreement.
- Include long-allele hap:match and hapfail controls so removing a rule cannot incorrectly promote lm where original leaves dot.
- Preserve real-data-derived #70 DeepTrio and PEPPER fixtures (native/reference ordered annotations already measured 4/4 and 20/20 matching). Preserve #58 am precedence and #57 hapfail dot.
- Retrieve real GRAF 4HL0B HG003 query at chr6:31329617/32675681, preserve full 785/789 and 969/969 alleles and BS neighbors, verify exact raw/prepared GT and intermediate ctype. Match real #81 records while retaining short-read #80 contrasts before claiming closure.

Real GRAF input: https://data.nist.gov/od/ds/ark:/88434/mds2-2336/submission_vcfs/4HL0B/4HL0B_HG003.vcf.gz . Metadata https://data.nist.gov/od/id/mds2-2336 records 422381613 bytes, SHA256 ed5f7702ea16c1e8b63dd1eed697fa87fce6419bd4d5abc912ab3fdf611d8e0f. NIST body downloads timed out in this investigation; no real query allele sequence or GT was invented.
