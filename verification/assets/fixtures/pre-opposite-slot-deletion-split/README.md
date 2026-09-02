# Opposite-slot deletions of different span stay two rows

This fixture preserves the preprocessing cause seen on the HG003 PEPPER
long-read callset at `chr1:78100940`. Two colocated records sit on opposite
haplotypes inside an `AC` microsatellite: a raw `ATACACACAC>A` deletion
(`1/0`) and a complex `TACAC>AT` allele (`0/1`).

Decomposing `TACAC>AT` yields a mixed-edit `ATAC>A` deletion plus a `C>T` SNP,
so the locus ends up with two deletions of different span sharing an anchor,
one of them a mixed-edit primitive. Legacy `pre.py --decompose --leftshift`
keeps those two deletions as **separate rows**, shorter span first, each
retaining its own genotype.

The measured rule is that opposite-haplotype deletions of different span fold
into a het-alt only when the mixed-edit flag is uniform across the pair --
either both primitives are mixed (`chr10:34496891` and `chr4:6943863` on the
HG001 Platinum Genomes callset, where the longer deletion arrives as a
pre-scanned mixed merge partner) or neither is. When exactly one carries the
flag the pair stays split, whichever of the two is longer.

The fixture reduces the real locus onto a 200 bp synthetic contig copied
verbatim from GRCh38 `chr1:78100841-78101040`, so the `AC` repeat context
around the shared anchor is preserved and both engines resolve the deletions
to the same position. Legacy and hap-rs both emit `ATAC>A 1/0`,
`ATACACACAC>A 0/1`, `C>T 1/0`.

The same shape recurs at `chr1:158902685`, `chr1:245924655` and
`chr1:95982449`. PREPY is the highest command seam that observes this cause
directly.
