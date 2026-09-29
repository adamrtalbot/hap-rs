# HG003 DeepTrio local block kind

From issue #70, HG003 DeepTrio at GRCh38 `chr20:6475096`. The input VCF
records are the reported run's prepared truth and query records, reduced to
GT and shifted by 6,474,899 bases onto a 401-base reference slice. The locus
remains inside the confident BED. Pinned hap.py 0.3.15 and hap-rs produce
identical prepared compare inputs: two truth and two query records. Pinned
xcmp emits `ctype=hap:mismatch` for the block.

The pinned annotated VCF has four rows, all with `BK=lm`:

- `chr20:197 C>CA`: truth `FN:lm:i1_5:INDEL:het`, query `NOCALL`.
- `chr20:197 C>CCAA`: truth `FN:lm:i1_5:INDEL:het`, query `NOCALL`.
- `chr20:197 C>T`: truth `NOCALL`, query `FP:lm:ti:SNP:het`.
- `chr20:197 C>CCAA,CCA`: truth `NOCALL`, query `FP:lm:i1_5:INDEL:hetalt`.

The parity case compares the complete observed set, including these row
identities, annotations, and the resulting FP.al counts.
