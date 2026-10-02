# Decomposed calls determine insertion shift bounds

This is the derived PREPY regression from [issue #90](https://github.com/adamrtalbot/hap-rs/issues/90).
The reference sequence is the committed #69 GRCh38 chr10:44341562 window,
remapped to position 32. It is not an extraction of the #83/#84 public inputs.

`input.vcf` splits the selected alleles into two source records: `GG>GGTGTG`
and `GG>T`. At native commit `58da3234f06cef7fd2ef6faefe10aeb0c569c043`, the
raw complex REF span floored the insertion at 33 and produced three rows.
The unmodified reference emits two rows at 32: `G>T GT=1/0` and
`GG>G,GGTGTG GT=1/2`.

`reversed.vcf` must retain that exact output. `insertion-only.vcf` emits
`G>GGTGT GT=0/1` at 32. The equivalent `pretrimmed.vcf` emits `G>T GT=1/0`
and `GG>GGTGTG,G GT=2/1` at 32; its ALT order differs because its insertion
enters the primitive stream with a different padded representation.
`single-record.vcf` retains the original #69 multiallelic shape and emits
the same two records as `input.vcf`.

`snp-constraint.vcf` and its reversal replace the complex call with a genuine
`G>T` SNP. The SNP remains at 32 and bounds the padded insertion at 33.
`duplicate-insertion.vcf` retains both insertion calls: the first normalizes
at 32, then its normalized span bounds the second at 33. These contrasts
prevent removing real constraints or collapsing duplicate multiplicity.

All eight observations were replayed with unmodified `pre.py --leftshift
--decompose --no-fixchr` on linux/amd64 using
`community.wave.seqera.io/library/happy-0.3.15@sha256:1a9cbcff999927913de87c3f7533c18622d08362e2f2accff336a49aa18d8c7b`.
The source reference is `Illumina/hap.py@84011695b2ff2406c16a335106db6831fb67fdfe`.
The ordinary PREPY samplesheet runs each case against the reference environment;
the command-level Rust test also checks serial and threaded execution.
