# HG003 DeepTrio repeat deletion first

This 61-base GRCh38 window preserves the issue #69 deletion-first shape at
chr2:1255863, remapped to position 32. The following deletion is retained:
hap-rs previously shifted the insertion from the source multiallelic call
onto that record. Pinned hap.py 0.3.15 prepares one `AA>A,long` hetalt row
at position 32. A distant truth SNP keeps the contig in the HAPPY comparison;
the target rows remain outside the confident region and are annotated `UNK`.
