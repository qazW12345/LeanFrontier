# Structural resultant probe: 50001..100000

GitHub Actions run 36260034767 regenerated the fixed-width sieve on
50001..100000 and then applied the small-order resultant probe to every
sieve survivor.

Configuration:

- triggering commit: `90b69c19efc86f6bb3456101d51b59c36e33811e`
- sieve bound: `1000000`
- resultant order bound: `k <= 100`
- admissible indices after the exact 2/3/5 filter: `10000`
- explicit factors <= 10^6: `8104`
- sieve survivors: `1896`
- survivors caught by some resultant order 2..100: `0`
- unresolved after the resultant probe: `1896`

Thus, on this range, every prime factor of every hard survivor has
`ord_p((10^10)^n) > 100`.

The statement is conditional only on the independently verified modular
implementation in `root_order_probe.py`; the workflow never constructs the
full concatenated A053067 integers.

Actions artifact:

- artifact id: `10912550116`
- artifact ZIP SHA-256:
  `e2dedc6c49826a0d08a08c88a5f1224fe4de0f5b32294425caf482c69b8c6a77`
