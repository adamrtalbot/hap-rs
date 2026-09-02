# Mixed indels without an anchor-sharing SNP still left-shift

This fixture preserves the preprocessing cause seen on the HG003 PEPPER
long-read callset at `chr1:248645133`. The complex `CAAA>AC` allele decomposes
into a deletion and a SNP at different anchors. Legacy left-shifts the deletion
through the adjacent A run instead of preserving the source allele's anchor.

The reference is GRCh38 `chr1:248645120-248645145`, remapped to `chrA`.
Legacy and hap-rs both emit `AAC>A` at 12 and `A>C` at 17. The same rule fixes
the mixed insertion at `chr1:20816338`, which shifts 14 bases left.
