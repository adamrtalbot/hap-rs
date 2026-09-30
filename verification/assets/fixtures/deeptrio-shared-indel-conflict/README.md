# HG003 DeepTrio shared insertion conflict

The 500-base GRCh38 slice is chr1:218925456-218925955, remapped to chr1:1-500. The reference sequence comes from the UCSC hg38 sequence API. `truth.vcf` is the GIAB HG003 v4.2.1 `C>CA,CCA 1/2` call at chr1:218925705 split with `bcftools norm -m-any`; `query.vcf` is the DeepTrio 1.1.0 `C>CCA,GCA 1/2` call at that position. The focused call retains the original alleles and genotypes but omits unrelated INFO fields.

Both pinned hap.py 0.3.15 and hap-rs prepare these inputs into the same two truth and two query records. In particular, the query becomes `C>G 1/0` plus `C>CCA,CCA 2/1`. The discrepancy is therefore in comparison. Pinned hap.py emits four annotated rows at remapped position 250:

| ALT | Truth `GT:BD:BK:BI:BVT:BLT` | Query `GT:BD:BK:BI:BVT:BLT` |
| --- | --- | --- |
| CA | `1/0:FN:lm:i1_5:INDEL:het` | `./.:.:.:.:NOCALL:nocall` |
| CCA | `0/1:FN:lm:i1_5:INDEL:het` | `./.:.:.:.:NOCALL:nocall` |
| G | `./.:.:.:.:NOCALL:nocall` | `1/0:FP:lm:tv:SNP:het` |
| CCA | `./.:.:.:.:NOCALL:nocall` | `1/1:FP:lm:i1_5:INDEL:homalt` |

Before the fix, hap-rs paired the `C>CCA` truth and query calls into one `FN:am / FP:am` row and emitted only three rows. The separate layout matters even though the headline FN and FP totals are unchanged.
