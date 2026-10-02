# Prepared insertion/deletion aggregate

Issue #91's exact 61-base GRCh38 chr10:44341562 window, remapped to position
32. A distant truth SNP retains the comparison contig; confidence excludes
the aggregate. No neighboring deletion is injected.

PREPY verifies the same two prepared records in both implementations:
`G>T 1/0` and `GG>G,GGTGTG 1/2`, both at position 32. HAPPY verifies that
comparison retains this aggregate and counts one INDEL QUERY.TOTAL/UNK in
both ALL and PASS. The issue contains pinned original/native reproduction
and before/after execution evidence.

Contrasts remain in the ordinary matrix: `deeptrio_repeat_rows` and
`deeptrio_repeat_delete_first` cover #69; `multiallelic_aggregate_split`,
`no_decompose_multiallelic_split` and `decompose_multiallelic_split` preserve
valid preparation-time splits. HAPPY's chr21 subset/primitive cases retain
classification-time partial matching.
