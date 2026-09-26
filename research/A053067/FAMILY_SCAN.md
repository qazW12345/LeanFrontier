# Periodic divisor-family survey

This is a computational survey produced from the exact fixed-width congruence
formula in `CONGRUENCES.md`. It is not a proof that uncovered terms are prime,
nor a claim that the listed prime bound is exhaustive.

For each decimal width (d) and each prime (7\le p\le B), the tool
`congruence_families.py` computes the exact period of (A(n)\bmod p) and all
residue classes on which it vanishes. Coverage is then measured only on the
indices in the genuine fixed-width (d)-digit interval that survive the exact
2/3/5 filter.

## Prime bound 200

| d | fixed-width n interval | admissible n | covered by some p <= 200 | coverage |
|---:|---:|---:|---:|---:|
| 3 | 15..44 | 6 | 5 | 83.33% |
| 4 | 46..140 | 19 | 10 | 52.63% |
| 5 | 142..446 | 62 | 39 | 62.90% |
| 6 | 448..1413 | 192 | 135 | 70.31% |
| 7 | 1415..4471 | 612 | 387 | 63.24% |
| 8 | 4473..14141 | 1935 | 1187 | 61.34% |
| 9 | 14143..44720 | 6115 | 3468 | 56.71% |
| 10 | 44722..141420 | 19340 | 10006 | 51.74% |
| 11 | 141422..447213 | 61157 | 31516 | 51.53% |
| 12 | 447215..1414213 | 193401 | 134489 | 69.54% |

The oscillation with (d) is expected: changing (d) changes
(q=10^d\pmod p), and widths for which (10^d\pm1) has useful small prime
factors acquire especially dense families.

## Prime bound 1000, selected widths

A second run with (B=1000) gives:

| d | admissible n | covered | coverage |
|---:|---:|---:|---:|
| 6 | 192 | 150 | 78.12% |
| 8 | 1935 | 1363 | 70.44% |
| 10 | 19340 | 11974 | 61.91% |
| 12 | 193401 | 147100 | 76.06% |

The extra primes improve coverage, but the gain is not fast enough to suggest
that ordinary small primes alone will trivially cover every admissible index.

## Example: six-digit blocks

For (d=6), the strongest small families include:

- (p=13), period 13, zero residues 0, 5, 8 mod 13;
- (p=7), period 7, zero residue 0 mod 7;
- (p=19), period 57, five zero residues;
- (p=11), period 11, zero residue 0 mod 11;
- (p=37), period 37, zero residues 0, 6, 31 mod 37.

These are exact divisor certificates for every fixed-width index in the stated
residue classes, not statistical correlations.

## Reproduction

For one width:

    python3 research/A053067/congruence_families.py \
      --digits 6 --prime-bound 200 \
      --json-out research/A053067/results/families-d6-p200.json

The JSON output contains the exact period and root list for every contributing
prime, plus the uncovered indices in that fixed-width interval.

## Research implication

A useful next question is not merely whether increasing the prime bound covers
more finite indices. It is whether the two-dimensional dependence on decimal
width (d) and index (n) admits a finite congruence covering that repeats for
all sufficiently large widths. The current data do not establish such a
covering. They do show that a substantial part of the observed compositeness
has exact periodic explanations, which is a better substrate for proof search
than raw trial division.
