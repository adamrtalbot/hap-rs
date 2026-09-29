# HG003 PEPPER local block kind

From issue #70, HG003 PEPPER HiFi at GRCh38 `chr1:93846926-93847028`.
The input VCF records are the reported run's prepared truth and query records,
reduced to GT and shifted by 93,846,799 bases onto a 401-base reference slice.
The confident BED preserves the boundary at original position 93,846,936.
Pinned hap.py 0.3.15 and hap-rs produce identical prepared compare inputs:
14 truth and 16 query records. The difference is in the block verdict:
pinned xcmp emits `ctype=hap:mismatch`, while hap-rs previously suppressed it.

The pinned annotated VCF has 20 rows: the shared insertion at local position
127 is `TP:gm` on both sides; all 19 remaining rows carry `BK=lm`. This
includes `chr1:173 G>GC` as `UNK:lm:i1_5:INDEL:homalt` on both sides and
`chr1:211 G>T` as `UNK:lm:tv:SNP:het` on both sides. The parity case compares
the complete observed set, including all row identities and annotations.
