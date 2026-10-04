# GATK spanning-star opposite-slot deletions

Issue #82. Faithful UYMUW GATK HG003 block from GRCh38
`chr10:99441166-99441168`, remapped onto local positions 67–69 of the
verbatim 121 bp window `chr10:99441100-99441220`.

After external `bcftools norm -m-any`, the query carries opposite-slot
deletions plus spanning-deletion (`*`) companions:

| POS | REF | ALT | GT |
|---:|---|---|---|
| 67 | TG | T | 0/1 |
| 68 | GATTC | * | 1/0 |
| 68 | GATTC | G | 0/1 |
| 69 | ATTC | A | 1/0 |
| 69 | ATTC | * | 0/1 |

Legacy `pre.py --decompose --leftshift` drops the `*` rows (VariantCallsOnly)
and emits three query indels: `TG>T`, `GATTC>G`, `ATTC>A`. Hap-rs previously
classified `ALT=*` as a mixed-edit deletion in the spanning pre-scan, marked
`ATTC>A` as a merge partner, and collapsed the two real deletions into one
`GATTC>G,GA` hetalt — undercounting INDEL QUERY.TOTAL/UNK by one at this
locus (and likewise at the other reported UYMUW blocks).

PREPY/HAPPY both must keep the three indel rows. Confidence covers only an
interior decoy SNP (`chr10:30 C>G`, matched in truth and query as TP) so the
indel block remains UNK, matching the reported annotation class. The decoy
sits well inside `confident.bed` (`chr10 20 40`) to avoid TS_boundary / BK=lm
edge disagreements between engines.
