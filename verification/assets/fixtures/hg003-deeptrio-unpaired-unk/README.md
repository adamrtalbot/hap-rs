# HG003 DeepTrio same-locus UNK rows

This example case uses the three truth and three query records from the
prepared inputs of Seqera run `3M006pyp0msOfq` at GRCh38
`chr12:99121318-99121321`. Coordinates are shifted into a 91-base reference
window beginning at original position 99121280, so original
`chr12:99121321` is fixture `chr12:42`. The sequence, alleles, GT, and QUAL
come from that run; other FORMAT and INFO fields do not affect comparison.
The confident BED does not cover the records.

The pinned hap.py 0.3.15 reference emits five rows. At `chr12:42` it emits
a combined `A>G` SNP row, then a truth-only `A>ATGTGTGTG` `UNK/NOCALL` row,
then a query-only `A>ATGTGTGTG` `NOCALL/UNK` row. The query's two source
records at that anchor produce the homozygous insertion. hap-rs at
`0a8eb5f` incorrectly combines the insertion into one `UNK/UNK` row. This
case checks record identity and `BD:BK:BI:BVT:BLT` through the ordinary
paired-output comparator. The expected ordered rows from pinned hap.py are:

| Position | REF>ALT | Truth `BD:BK:BI:BVT:BLT` | Query `BD:BK:BI:BVT:BLT` |
| --- | --- | --- | --- |
| 39 | `G>GGGGTGTGTGTGTGTGTGT` | `UNK:.:i16_plus:INDEL:het` | `NOCALL:nocall` |
| 39 | `G>GGGGTGTGTGT` | `NOCALL:nocall` | `UNK:.:i6_15:INDEL:het` |
| 42 | `A>G` | `UNK:.:ti:SNP:het` | `UNK:.:ti:SNP:het` |
| 42 | `A>ATGTGTGTG` | `UNK:.:i6_15:INDEL:het` | `NOCALL:nocall` |
| 42 | `A>ATGTGTGTG` | `NOCALL:nocall` | `UNK:.:i6_15:INDEL:homalt` |
