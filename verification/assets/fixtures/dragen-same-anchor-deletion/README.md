# DRAGEN same-anchor deletion blocks opposite-slot aggregation

Issue #84 / PR #102: W607K HG003 chr7:63317239, remapped to chr7:10
on the real GRCh38 slice chr7:63317230-63317270 (1-based, inclusive).
The FASTA is that exact 41-base slice. REF, ALT, QUAL, genotype and FORMAT
values retain the four prepared query.final rows supplied to both engines.
There is no AF field; the two het rows already share GT:AD:DP:GQ:PL:SB.
They are the split of raw DRAGEN GAAAAAAAAAA>G,GAAAAAAAAAAAAAAAAA GT=1/2.

The trigger is an ordinary padded insertion/deletion group with separate
same-anchor homalt calls, including GA>G, which consumes the first deleted
base of the longer deletion (anchor + 1). Legacy REF-span ordering puts the
incompatible homalt calls between G>GAAAAAAA 0/1 and GAAAAAAAAAA>G 1/0,
so tail-only location aggregation leaves the hets split. G>GAAAAAAAA 1/1
(QUAL 10.5) and GA>G 1/1 (QUAL 7.69) must remain separate too. This differs
from the AF=0 FORMAT-order trigger in dragen-multiallelic-rows, which must
still aggregate.

Truth has one SNP at chr7:3 to establish the comparison chromosome, and no
variants at the anchor. Confidence covers only bases before the anchor,
leaving all four query annotations UNK with BK=".": two INDEL het rows
(i6_15 and d6_15), and two homalt rows (i6_15 and d1_5).
The full NIST VCFs are not committed.

## Stage and source

The first divergence is preprocessing location aggregation. Sorting ordinary
padded deletions before insertions makes the long het deletion and het insertion
adjacent in the native buffer. Legacy retains one indel class for their nonzero
internal REF spans and orders by REF length: the homalt calls separate the hets.
Mixed primitives and writer-time FORMAT bucketing retain their existing behavior.

Source references at pinned Illumina/hap.py commit
`84011695b2ff2406c16a335106db6831fb67fdfe`:

- `VariantPrimitiveSplitter.cpp:169-199`: pure calls pass through unsplit.
- `Variant.hh:239-355`: location, internal variant class and REF/ALT span ordering.
- `VariantLocationAggregator.cpp:108-131`: only the buffered tail can aggregate.

Before the fix, the pinned HAPPY comparator reports this case as `ok=false`
with seven differing artifacts, including four legacy query INDEL rows versus
three native rows. Acceptance requires `ok=true` and `differences=[]`, two
split hets and unchanged homalts, alongside the existing `dragen_multiallelic_rows`
case that must continue to aggregate opposite-slot AF=0 calls.
The focused two-case run after the fix reports `ok=true` and `differences=[]`
for both cases, with all four anchor rows and their QUALs unchanged.
