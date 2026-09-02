# A gap that ties with a leading mismatch right-aligns

This fixture preserves the preprocessing cause seen on the HG003 PEPPER
long-read callset at `chr1:88047087`. A complex allele
`AAAGAAAAGAAAG>GGAAAAGAAAA` sits inside a `GAAAA` repeat, on the opposite
haplotype from a long spanning deletion that pins the left-shift floor.

Decomposing the complex allele has two alignments of identical score under the
legacy klib affine parameters (match `+1`, mismatch `-4`, gap open `6`, gap
extend `1`): nine matches, two mismatches and one two-base deletion, with the
deletion falling either before or after the leading mismatch. Legacy resolves
the tie by right-aligning the gap, so it emits the `A>G` substitution first and
leaves the deletion one base further right.

Because the neighbouring deletion holds the left-shift floor at the end of the
block, neither engine can slide the emitted deletion, which makes the tie
directly observable in the output rather than being washed out by
normalization.

The fixture reduces the real locus onto a 100 bp synthetic contig copied
verbatim from GRCh38 `chr1:88047027-88047126`. Legacy and hap-rs both emit
`AGAAAAGAAAAAAGAAAAGAAAG>A 0/1`, `A>G 1/0`, `AAA>A 1/0`, `G>A 1/0`.

The same change also resolved `chr1:16192620`, `chr1:26488524` and
`chr1:224016256` on the same callset, which each left the record diff once the
tie-break was corrected.
