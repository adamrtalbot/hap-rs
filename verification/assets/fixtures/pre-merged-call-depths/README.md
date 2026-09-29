# Merged colocated calls keep the highest QUAL and depths

This fixture preserves the preprocessing cause seen on the HG003 PEPPER
long-read callset at `chr1:11720593`. Two het insertions in a poly-A run,
`C>CAA` (QUAL 8.9, DP 19, AD 12,0) and `C>CAAA` (QUAL 50.5, DP 25, AD 15,4),
merge into one `C>CAA,CAAA` het-alt record. Legacy keeps the highest QUAL, DP
and reference depth across the two calls and takes GQ, PL and VAF from the
first, giving QUAL 50.5, DP 25 and AD 15,0,4.

The reference is GRCh38 `chr1:11720571-11720620`, remapped to `chrA`.

At `chrA` the second call has the higher QUAL, DP and reference depth, so
`chrB` adds a synthetic pair where they split. `A>AC` has QUAL 60, DP 10 and
AD 3,5; `AC>A` has QUAL 20, DP 30 and AD 8,2. Legacy writes QUAL 60, DP 30 and
AD 8,5,2, taking each value's maximum rather than all of one call's values.
