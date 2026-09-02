# Equal-cost affine gaps open before they extend

This fixture preserves two forms of the same alignment tie from the HG003
PEPPER long-read callset. At `chr1:78142355`, `TGTGTGTG>GT` can split its six
deleted bases as 1+5 or 5+1; legacy emits 5+1. At `chr1:20712846`, the
`AGATA` complex allele can split 142 inserted bases at many repeat boundaries;
legacy emits 123 bases before the matched `AGATA` and 19 after it.

The allele sequences are unchanged and use short flanking reference on two
synthetic contigs. They cover deletion and insertion paths through the same
affine-gap tie rule.
