# Mixed-boundary sieve: decimal widths 1..5000

GitHub Actions run 36259329121 scanned the unique A053067 block crossing each
power-of-ten boundary 10^d for d=1..5000.

Configuration:

- triggering commit: `2c360d2680ba79462c439041c24053674135302f`
- prime bound: `100000`
- boundary widths scanned: `5000`
- boundaries surviving the exact 2/3/5 filter: `1020`
- explicit small-prime factors found: `826`
- sieve survivors: `194`
- survivor fraction among admissible boundaries: `194/1020 ~= 0.1902`

For comparison, the Mertens product over primes 7 <= p <= 100000 is about
0.1828, so the observed mixed-boundary survival rate is close to ordinary
random-integer sieving after conditioning away 2,3,5.

Most frequent first factors in the run:

- 7: 177
- 11: 74
- 13: 59
- 17: 48
- 19: 35
- 23: 23
- 29: 18
- 31: 18
- 53: 14
- 59: 13

Actions artifact:

- artifact id: `10911778787`
- artifact ZIP SHA-256:
  `90bb37066dcb7b40db694945dcb18dddeaa20eebc8e2e0a4096165ce982921c9`
