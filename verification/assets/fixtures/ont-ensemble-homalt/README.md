# ONT ensemble homalt SNP aggregation

Issue #85: ONT NanoCaller/Clair/Medaka ensemble at chr1:102045486 and chr1:102045488
(remapped to chr1:7 and chr1:9 in this fixture).

The query has:
- chr1:5 `GAGAGATATATATAT>G,GATATATATATATAT` GT=1/2 (multiallelic hetalt)
- chr1:7 `G>T` GT=0/1 (explicit het SNP)
- chr1:9 `G>T` GT=0/1 (explicit het SNP)

When the multiallelic at chr1:5 is decomposed, the second allele (GATATATATATATAT)
creates SNPs at positions 7 and 9. These should aggregate with the explicit query
SNPs at the same positions to form homalt (GT=1/1) rows.

## The Bug

Before the fix, the decomposed SNPs had FORMAT=`GT:AD:ADO:DP` while the explicit
SNPs had FORMAT=`GT:AD:ADO:DP:GQ`. The location aggregator's exact FORMAT match
requirement (line 1132 of variant_pipeline.rs) caused it to bail out early,
leaving two separate het rows at each position instead of merging them.

## The Fix

Normalize FORMAT fields before aggregation when records have different FORMAT
strings (line 995). Expand all records to have the union of fields (with missing
values where needed), allowing aggregation of records from different sources.

## Measured Stage

The failure occurs during **preprocessing location aggregation** after multiallelic
decomposition. The prepared VCF should have:
- One row at chr1:7 with GT=1/1 (not two het rows)
- One row at chr1:9 with GT=1/1 (not two het rows)

Truth has one SNP at chr1:1 to establish the comparison chromosome. Confidence
covers only bases 0-4, leaving all query annotations UNK with BK=".": one INDEL
hetalt row (at chr1:5) and two homalt SNP rows (at chr1:7 and chr1:9).

Real XV7ZN query rows:
```
chr1	102045484	.	GAGAGATATATATAT	G,GATATATATATATAT	149.158	PASS	.	GT	1/2
chr1	102045486	.	G	T	17.0188	PASS	votes=2	GT:GQ	0/1:17.02
chr1	102045488	.	G	T	18.1512	PASS	votes=2	GT:GQ	0/1:18.15
```

