# A053067 research workspace

This branch is a research workspace for [OEIS A053067](https://oeis.org/A053067), not an ordinary
LeanFrontier submission.

For n >= 1, let

- L_n = n(n-1)/2 + 1,
- U_n = n(n+1)/2,

and let A(n) be the base-10 concatenation of the n consecutive integers
L_n, L_n+1, ..., U_n.

The OEIS question (still open on the entry last modified 2026-08-28) is:

> The second term is a prime. When is the next prime, if there is another?

Thus A(1)=1, A(2)=23, A(3)=456, A(4)=78910, ...

## Exact cheap congruence sieve

For n > 2, a prime A(n) must survive divisibility by 2, 3 and 5.

The last decimal digit of A(n) is the last digit of U_n. Requiring it to be one of
1, 3, 7, 9 gives

    n mod 20 in {1, 2, 6, 13, 17, 18}.

Modulo 3, decimal concatenation is congruent to the sum of the concatenated integers:

    A(n) == sum_{m=L_n}^{U_n} m
         == n(L_n + U_n)/2
         == n(n^2 + 1)/2             (mod 3).

Since n^2+1 is nonzero modulo 3, this excludes exactly n == 0 (mod 3).
Combining both conditions leaves the 12 residue classes

    n mod 60 in {1, 2, 13, 17, 22, 26, 37, 38, 41, 46, 53, 58}.

So 80% of indices are eliminated before any large integer is constructed.

## Search implementation

`search.cpp` computes A(n) modulo many small primes without constructing A(n).

Within a run of d-digit integers, appending the next integer m transforms the state (x,m) by

    x' = 10^d x + m
    m' = m + 1.

The program exponentiates this affine transform, so an entire same-width part of the block is
processed in O(log n) modular multiplications. Small primes are packed into 63-bit products;
one modular evaluation plus a gcd therefore tests several primes at once.

Only indices surviving the small-prime sieve are materialized as a GMP integer and sent to
`mpz_probab_prime_p`. A GMP result of 0 is definitive compositeness for search purposes.
A probable-prime result is only a candidate: it must subsequently receive a rigorous primality
certificate before any mathematical claim is made.

## Checked-in search results

Two bounded scans are currently checked in:

- `results/pilot-3-1000.csv`: 198 admissible indices, 161 with an explicit
  small-prime divisor, 37 reported composite by GMP, and no probable prime.
- `results/scan-1001-3000.csv`: 400 admissible indices, 340 with an explicit
  small-prime divisor, 60 reported composite by GMP, and no probable prime.

Combined, every index 3 <= n <= 3000 is covered by the exact 2/3/5 filter or one
of those two result files. Among the 598 indices that survive the exact filter,
501 have an explicit prime divisor recorded and independently checkable by
modular evaluation; the remaining 97 were reported composite by GMP. No
probable-prime term was found.

This is computational exclusion evidence, not yet a formal theorem about the
entire interval: rows marked `composite_prp` intentionally do not pretend to
contain a standalone compositeness certificate.

## Reproduction

On Debian/Ubuntu with a C++20 compiler and GMP development files:

    g++ -O3 -std=c++20 research/A053067/search.cpp -lgmpxx -lgmp -o a053067-search
    python3 research/A053067/verify.py
    ./a053067-search --start 3 --end 1000 --sieve-bound 200000 \
      --prp-reps 25 --output results.csv
    python3 research/A053067/analyze.py results.csv --start 3 --end 1000

The search supports `--shard-index I --shard-count C` for partitioning a range across machines.

## GitHub Actions compute

`.github/workflows/research-a053067.yml` targets a Linux x64 self-hosted runner.
It runs only on the dedicated `research/a053067` branch, has read-only repository
permissions, and accepts only numeric parameters from `run-request.env`; it never
sources repository text as shell code. Push-triggering is restricted to the research
request/search/verification files, so pull-request code cannot execute on the research
machine.

The workflow compiles the searcher, verifies checked-in evidence, runs the requested
shard, validates exact shard coverage and explicit factors with `analyze.py`, records
tool/source hashes, and uploads the result as an immutable Actions artifact.

A second workflow, `.github/workflows/research-a053067-hosted.yml`, provides bounded
bootstrap scans on `ubuntu-latest` from `run-hosted.env`. It exists so development and
small searches can continue even when no matching self-hosted runner is online. Deep
searches should use the self-hosted workflow.

Do not merge the research directory or either research workflow upstream as an ordinary
LeanFrontier theorem submission.

## Research plan

1. Push the computational exclusion bound substantially past 1000.
2. Record explicit small factors whenever possible.
3. For GMP-composite survivors, run a second factor/certificate pass rather than treating the
   probable-prime engine as formal evidence.
4. If a probable prime appears, independently reproduce it, generate a rigorous primality
   certificate, and then prove that certificate.
5. Only after a genuine mathematical result exists, translate the relevant statement and
   certificates into normal LeanFrontier source under `LeanFrontier/` and validate it against
   the submission contract.
