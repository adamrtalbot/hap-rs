# DeepTrio separate TP rows

This minimized fixture comes from HG003 DeepTrio and GIAB GRCh38 v4.2.1 at
`chr11:65167297-65167304`, shifted into a 251 bp public GRCh38 reference
slice (`chr11:65167201-65167451`) so the two source positions are 97 and 104.
The VCFs are the common input shape after the variantbenchmarking pipeline
splits multi-allelic calls with `bcftools norm -m-any` and normalizes them.
The reference slice is from UCSC's hg38 sequence API.

Pinned hap.py 0.3.15 and hap-rs produce identical internal prepared VCFs:
truth has `G>GT 0/1` at 97, then `G>GT 1/0` and `G>T 0/1` at 104;
query has `G>T 1/0` and `G>GT,GT 2/1` at 104. The latter aggregate is
a homozygous insertion, but legacy comparison leaves its TP row separate
from the heterozygous truth TP at 104. Both rows have `BK=gm`; the SNP
is a paired TP/TP row. INDEL counts remain truth TP=2 and query TP=1.

Before the fix, hap-rs emits one `G>GT` TP/TP row at 104. The ordinary
verification comparison checks the whole annotated VCF and summary.

The same fix was checked against five other issue loci using 251 bp public
GRCh38 slices and the public GIAB/DeepTrio records within 35 bp of each site.
Each input was split with `bcftools norm -m-any` and normalized against its
slice before both pinned hap.py 0.3.15 and hap-rs were run. Ordered
`GT:BD:BK:BI:BVT:BLT` rows and all decision-count columns agreed:

| Source locus | Annotated rows | INDEL PASS truth TP / query TP |
| --- | ---: | ---: |
| chr2:207102126 | 5 | 2 / 2 |
| chr9:99416267 | 5 | 2 / 2 |
| chr11:65167304 | 4 | 2 / 1 |
| chr12:20448752 | 7 | 2 / 2 |
| chr17:72600444 | 5 | 3 / 1 |
| chr22:31587482 | 4 | 2 / 1 |
