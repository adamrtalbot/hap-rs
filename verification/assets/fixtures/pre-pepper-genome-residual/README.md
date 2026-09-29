# Long-read windows from the genome-wide PEPPER comparison

Four HG003 PEPPER windows, each 61 bp of GRCh38 remapped to its own contig,
plus one HG001 window. Each covers one preprocessing rule found when comparing
legacy and hap-rs on every chromosome, beyond the chr1 set:

- `chrA` (`chr8:52884877-52884937`): an ordinary `AAG>A` deletion stays ahead
  of the insertion recovered from the next record's `AG>GAGA`, giving
  `AAG>A,AGAG` 2/1.
- `chrB` (`chr10:4412620-4412680`): `CATAT>C` and `CATAT>TAC` share a
  position. The first record does not floor the second's deletion, which
  left-shifts to `TAC>T`.
- `chrC` (`chr3:180593780-180593840`): `TTAAA>T` ends on the last base the
  `ATTAAA>T` deletion removes. With no SNP at the follower's position the two
  stay as separate rows.
- `chrD` (`chr11:104119029-104119089`): `ATA>TAT` aligns as an insertion then
  a deletion, the equal-score order legacy picks.
- `chrE` (HG001 `chr19:43502966-43503035`): the counterpart to `chrC`.
  `GATCTGT>G` also ends on the last base `AGATCTGT>G` deletes, but a `G>C` SNP
  sits at its position, so legacy merges the two into `AGATCTGT>A,AG` 1/2.
