# Half-call promoted by a matched haplotype block

This minimized fixture comes from the prepared HG003 PEPPER HiFi truth and
query in the issue #71 discovery run. It retains chr6:32702379-32702398,
shifted by 32,702,349 bases onto a 60-base GRCh38 reference slice. GT,
QUAL, FILTER, REF, and ALT are from the prepared VCFs; unused sample fields
were removed. The original confident BED covers this entire slice.

The six truth and five query records include a matched covering deletion,
a colocated `G>T` SNP, the truth `G>.` half-call, and the nearby compound
insertion/SNP spellings that make the block haplotype-match. Removing the
variants after original position 32702396 makes both implementations
classify that block as a mismatch, so those spellings are necessary to the
observed `TP` promotion.

Pinned hap.py 0.3.15 emits truth `0/.:TP:gm:.:UNK:halfcall:12.7` and query
`./.:.:.:.:NOCALL:nocall:0` at fixture chr6:31 `G>.`; the colocated `G>T`
row remains `TP:gm` for both samples. Summary `ALL` and `PASS` rows have
truth total/TP 2/2 and query total 3 for INDEL, truth total/TP 3/3 and
query total 2 for SNP, with FN/FP/UNK all zero. The HAPPY parity case
compares every observed file with the pinned implementation.
