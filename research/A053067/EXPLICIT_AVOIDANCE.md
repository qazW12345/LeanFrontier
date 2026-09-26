# Explicit Euclid subsequence for A053067

There is a much simpler explicit construction behind the infinite-prime-divisor
theorem.

Define

\[
\boxed{
n_k=10^k+1,
\qquad
d_k=2k.
}
\]

For every \(k\ge1\), the entire A053067 block at \(n_k\) consists of exactly
\(2k\)-digit integers.

For \(k\ge2\), the term is also automatically coprime to 10.

This gives an explicit subsequence that escapes every prescribed finite set
of prime divisors.

## 1. Exact decimal width

Put

\[
N=10^k,
\qquad
n=N+1.
\]

The lower endpoint is

\[
L_n
=
\frac{n(n-1)}2+1
=
\frac{N(N+1)}2+1.
\]

Since \(N^2=10^{2k}\),

\[
L_n
>
\frac{N^2}{2}
=
5\cdot10^{2k-1}
>
10^{2k-1}.
\]

The upper endpoint is

\[
U_n
=
\frac{n(n+1)}2
=
\frac{(N+1)(N+2)}2
=
\frac{N^2+3N+2}{2}.
\]

For \(k\ge1\), \(N\ge10\), so

\[
3N+2<N^2.
\]

Hence

\[
U_n<N^2=10^{2k}.
\]

Therefore

\[
\boxed{
10^{2k-1}\le L_n\le U_n<10^{2k}.
}
\]

Every integer in the block has exactly \(2k\) decimal digits, so its decimal
concatenation is precisely the fixed-width recurrence

\[
A(n_k)=F(10^{2k},L_{n_k},n_k).
\]

No asymptotic width argument is needed.

## 2. Exact elementary admissibility

For \(k\ge2\),

\[
10^k\equiv40\pmod{60},
\]

so

\[
\boxed{n_k\equiv41\pmod{60}.}
\]

The residue 41 is one of the 12 exact elementary candidate classes.

Equivalently, the final block value is

\[
U_{n_k}
=
5\cdot10^{2k-1}
+
15\cdot10^{k-1}
+
1.
\]

For \(k\ge2\), both nonconstant terms are divisible by 10, hence

\[
\boxed{U_{n_k}\equiv1\pmod{10}.}
\]

Thus \(A(n_k)\) is odd and not divisible by 5.

## 3. Residue 5 modulo every synchronized odd prime

Let \(p\ne2,5\) be prime and assume

\[
\operatorname{ord}_p(10)\mid k.
\]

Then

\[
10^k\equiv1\pmod p.
\]

Hence

\[
n_k=10^k+1\equiv2\pmod p
\]

and

\[
q=10^{2k}\equiv1\pmod p.
\]

For a fixed-width block with \(q\equiv1\), the exact sum congruence is

\[
A(n)
\equiv
\frac{n(n^2+1)}2
\pmod p.
\]

Therefore

\[
A(n_k)
\equiv
\frac{2(4+1)}2
\equiv5
\pmod p.
\]

Thus

\[
\boxed{
A(10^k+1)\equiv5\pmod p
\qquad
\text{whenever }
p\nmid10,\ 
\operatorname{ord}_p(10)\mid k.
}
\]

In particular every such prime \(p\ne5\) is excluded as a divisor.

## 4. Explicit finite-prime avoidance

Let \(S\) be any finite set of primes.

For the primes \(p\in S\setminus\{2,5\}\), define

\[
D_S
=
\operatorname{lcm}_{p\in S\setminus\{2,5\}}
\operatorname{ord}_p(10),
\]

with empty lcm equal to 1.

Choose any multiple

\[
k\equiv0\pmod{D_S},
\qquad
k\ge2.
\]

Then for every \(p\in S\setminus\{2,5\}\),

\[
A(10^k+1)\equiv5\not\equiv0\pmod p.
\]

The final-digit calculation gives

\[
A(10^k+1)\equiv1\pmod{10},
\]

so neither 2 nor 5 divides the term.

Hence

\[
\boxed{
\gcd\left(
A(10^k+1),
\prod_{p\in S}p
\right)=1.
}
\]

Every sufficiently large multiple of \(D_S\) works, so there are infinitely
many such explicit indices.

This proves finite-prime avoidance without any approximation or
large-width existence argument.

## 5. Universal modulus form

Let \(m\ge1\), and let \(m_*\) be its factor coprime to 10.

Choose \(k\ge2\) such that

\[
10^k\equiv1\pmod{m_*}.
\]

Then

\[
A(10^k+1)\equiv5\pmod{m_*}.
\]

Since \(\gcd(5,m_*)=1\), this part is coprime to \(m_*\).

By taking \(k\) larger than the exponents of the 2- and 5-parts of \(m\), the
final-value formula gives

\[
A(10^k+1)\equiv1
\]

modulo those prime-power parts.

Therefore

\[
\boxed{
\forall m\ge1,\ 
\text{infinitely many }k
\text{ satisfy }
\gcd(A(10^k+1),m)=1.
}
\]

This is slightly weaker than the earlier residue-one statement
\(A(n)\equiv1\pmod m\), but it is completely explicit and is more than enough
for all Euclid-type consequences.

## 6. Consequences

The explicit subsequence immediately reproves:

- infinitely many distinct primes divide A053067 terms;
- A053067 contains an infinite pairwise-coprime subsequence;
- for every \(y\), some terms have least prime factor \(>y\);
- prime divisors of unbounded multiplicative order occur;
- no finite prime covering can prove eventual compositeness.

The recursive pairwise-coprime construction may now be carried out using only

\[
n_k=10^k+1.
\]

At each stage choose the next \(k\) divisible by the decimal orders of all
prime divisors seen previously.

## 7. Completely explicit rough terms

The residue-5 congruence gives a particularly clean contrapositive.

Let \(k\ge2\) and let \(p\mid A(10^k+1)\) be prime.  The final digit excludes
\(p=2,5\).

If

\[
\operatorname{ord}_p(10)\mid k,
\]

then Section 3 would give

\[
A(10^k+1)\equiv5\pmod p,
\]

contradicting \(p\mid A(10^k+1)\).

Therefore every prime divisor satisfies

\[
\boxed{
\operatorname{ord}_p(10)\nmid k.
}
\]

Now define

\[
K_R=\operatorname{lcm}(1,2,\ldots,R)
\]

for \(R\ge2\), and take

\[
n_R=10^{K_R}+1.
\]

Every integer \(1\le j\le R\) divides \(K_R\). Hence if a prime
\(p\mid A(n_R)\) had

\[
\operatorname{ord}_p(10)\le R,
\]

then its order would divide \(K_R\), contradiction.

Thus

\[
\boxed{
p\mid A(n_R)
\quad\Longrightarrow\quad
\operatorname{ord}_p(10)>R.
}
\]

Since

\[
\operatorname{ord}_p(10)\le p-1,
\]

we also get

\[
\boxed{
p>R+1.
}
\]

Consequently

\[
\boxed{
P^-\!\left(A(10^{K_R}+1)\right)>R+1,
}
\]

where \(P^-\) denotes the least prime factor.

This is an explicit, nonrecursive sequence of A053067 terms whose least prime
factor and the decimal multiplicative order of every prime factor both tend
to infinity.

It is stronger constructively than the earlier abstract primorial-avoidance
corollary.

## 8. Formalization advantage



This construction is substantially easier to formalize than the earlier
"choose n near \(10^{d/2}\)" argument.

The required ingredients are only:

1. elementary power inequalities proving the \(2k\)-digit width;
2. the fixed-width decimal bridge;
3. the already formalized ZMod fixed-concatenation lemmas;
4. Fermat/multiplicative-order synchronization;
5. the final-digit calculation for 2 and 5.

The branch should use this explicit construction as the primary Lean route to
the infinite-prime-divisor theorem.
