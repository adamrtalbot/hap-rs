# HG003 DeepTrio chr10 compound block

This 151-base GRCh38 chr10 slice and four prepared calls reproduce issue #65.
Position 70 maps to chr10:130333869. The truth has a heterozygous insertion
and deletion. The query has a complex `G>TCACA` allele followed by the same
deletion. The query order matches the pipeline's prepared VCF. Pinned hap.py
0.3.15 preprocesses the query into `G>T` and
`GCACACA>G,GCACACACACA` with GT `2/1`.

The legacy comparison emits two truth FN rows, a query SNP FP row, and a query
INDEL FP row. Its INDEL ALL and PASS counts are TP 0, FN 2, FP 1. Before the
fix, hap-rs reversed the aggregate ALT order and GT, promoted the deletion to
TP, and emitted an extra UNK insertion row. The focused regression asserts
these three counts and the prepared allele order. The remaining BK and FP.al
differences are outside issue #65; the BK omission belongs to #70. This fixture
stays out of the strict artifact parity samplesheet until those values match.
