# Truth half-call beside a confidence boundary

This minimized fixture is the chr6:31140629-31140630 block from a local
HG003 v4.2.1 DeepVariant comparison that independently reproduces the
chr6:31140630 truth half-call decision reported in issue #71. The same
confidence-boundary mechanism at chr6:32423359 is pinned by the focused
Rust test. Coordinates are
shifted by 31,140,599 bases onto a 100-base slice of the GRCh38 reference.
The deletion at original chr6:31140629 starts before the raw confident interval
but its REF span reaches inside it. A selected `*` allele on the next record
becomes the truth `C>.` half-call. The adjacent matched SNP is retained so
the ROC report covers both SNP and INDEL classes.

Pinned hap.py 0.3.15 and hap-rs both emit four annotated rows. The half-call
at fixture chr6:31 has `Regions=CONF,TS_contained`, truth
`0/.:N:.:.:UNK:halfcall:.`, and query
`./.:.:.:.:NOCALL:nocall:0`. Two other rows are `TP:gm` deletions; the
fourth is a `TP:gm` SNP.
The summary has `INDEL,ALL` and `INDEL,PASS` rows with truth total/TP = 2/2,
query total = 2, and FN/FP/UNK = 0/0/0. The SNP rows have truth total/TP =
1/1, query total = 1, and FN/FP/UNK = 0/0/0. The ordinary HAPPY comparison
checks the annotated VCF, summary, and ROC report against the pinned
implementation.
