# HG003 DeepTrio repeat rows

This 61-base GRCh38 window preserves the issue #69 insertion-first shape at
chr1:182360353. The source call carries an insertion on one allele and a
substitution plus deletion on the other. Its reported locus is remapped to
position 32. A second fixture covers the deletion-first shape; focused Rust
tests pin the prepared rows at all four original loci.

Pinned hap.py 0.3.15 prepares one hetalt indel row at this position. The
ordinary HAPPY parity case compares the final annotated VCF and reports with
the same legacy environment. A distant truth SNP keeps the contig in the
comparison without introducing a second call at the affected position.
