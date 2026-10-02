# Long ALT block-kind counterexample

Valid synthetic inputs, executed against unmodified pinned hap.py and native58da323. This is not a recovered GRAF locus. ALT lengths511/512 preserve lm in both implementations; lengths513 and785/789 lose lm only in native despite identical ctype=hap:mismatch. Full expected records include comparison state and genotypes.

Run from this directory: `./reproduce.sh /absolute/path/to/hap`. Requires Docker, Python3, linux/amd64 reference image and the native binary from58da323. Source fix targets are two length-based suppressors in rows.rs1014–1029 and matching.rs1082–1096; see linked issue for evidence and acceptance criteria. In managed environments, follow required Docker proxy/CA/socket access instructions. SHA manifest hashes inputs and observed records; output files in run/ are new diagnostic evidence.
