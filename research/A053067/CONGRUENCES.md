# Congruence lemmas for A053067

Let

- (L_n=n(n-1)/2+1),
- (U_n=n(n+1)/2),

and let (A(n)) be the decimal concatenation of the (n) consecutive
integers (L_n,L_n+1,ldots,U_n).

This note records exact congruences useful both for the search and for a later
Lean formalization. They apply when every integer in the block has the same
decimal width (d). Put (q=10^d). Then

[
A(n)=sum_{j=0}^{n-1}(L_n+j)q^{,n-1-j}.
]

Boundary-crossing blocks, where the interval contains a power of ten, are
handled by the general modular evaluator in `search.cpp`.

## The (10^d-1) lemma

Let (p) be an odd prime with (pmid 10^d-1). Then (qequiv1pmod p), so

[
egin{aligned}
A(n)
&equiv sum_{j=0}^{n-1}(L_n+j) pmod p\\
&= rac{n(L_n+U_n)}2\\
&= rac{n(n^2+1)}2 pmod p.
end{aligned}
]

Therefore

[
pmid n(n^2+1)quadLongrightarrowquad pmid A(n).
]

Equivalently, whenever the block is fixed-width, every odd prime divisor of

[
gcd(10^d-1,;n(n^2+1))
]

is a divisor of (A(n)).

Two common subcases are immediate:

- (pmid n);
- (n^2equiv-1pmod p).

Example: for six-digit blocks, (13mid10^6-1), and the square roots of
(-1) modulo 13 are 5 and 8. Hence (13mid A(n)) whenever
(nequiv0,5,8pmod{13}), provided the whole block consists of six-digit
integers.

Likewise (37mid10^6-1), with square roots of (-1) equal to 6 and 31
modulo 37, so the corresponding residue classes are (0,6,31pmod{37}).

## The (10^d+1) lemma

Let (p) be an odd prime with (pmid10^d+1). Then (qequiv-1pmod p).

If (n=2k) is even, consecutive terms pair as

[
-(L_n+2r)+(L_n+2r+1)=1,
]

so

[
A(n)equiv k=rac n2pmod p.
]

Thus

[
pmid nquadLongrightarrowquad pmid A(n)
]

for even (n).

If (n=2k+1) is odd, the alternating sum is

[
L_n-(L_n+1)+cdots-(L_n+2k-1)+(L_n+2k)
=rac{n^2+1}{2},
]

hence

[
A(n)equivrac{n^2+1}{2}pmod p.
]

Thus

[
pmid n^2+1quadLongrightarrowquad pmid A(n)
]

for odd (n).

For example, these (q=-1) cases explain additional factors by 11, 17,
101, and other divisors of (10^d+1) that are not captured by the
(10^d-1) lemma.

## Search consequence

These identities give a certificate-producing prefilter requiring only gcds
with (10^dpm1), rather than evaluation of the full concatenation modulo a
large list of primes. They do not by themselves cover every admissible (n),
but they explain a substantial fraction of the repeated small factors seen in
the checked-in scans.

They also suggest a broader route: for primes where (10^d) has small
multiplicative order modulo (p), (A(n)mod p) is periodic in (n), with a
period dividing a small multiple of (p,mathrm{ord}_p(10^d)). A finite
covering of the admissible residue classes by such congruences would prove
compositeness without constructing the decimal integers. Whether such a
covering exists is a research question; no such claim is made here.
