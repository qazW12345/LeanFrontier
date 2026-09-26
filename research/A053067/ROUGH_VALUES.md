# Many rough A053067 values in every large decimal width

This note gives an unconditional global-distribution theorem that is stronger
than the earlier Euclid construction.

It shows that every sufficiently large fixed decimal-width band contains
**exponentially many** A053067 terms with no small prime factor.

## 1. A universal avoiding progression inside one fixed width

Fix a decimal width \(D\), put

\[
q=10^D,
\]

and let \(z\ge5\) be an integer. Define

\[
M_z=\operatorname{lcm}(1,2,\ldots,z).
\]

Consider any genuine \(D\)-digit fixed-width A053067 index \(n\) satisfying

\[
\boxed{n\equiv1\pmod{M_z}.}
\]

We claim that

\[
\boxed{\gcd\!\left(A(n),\prod_{p\le z}p\right)=1.}
\]

### Odd primes \(p\le z\)

Let \(p\le z\) be an odd prime with \(p\ne5\), and put

\[
r_p=\operatorname{ord}_p(q).
\]

Because

\[
r_p\mid p-1\le z,
\]

both \(p\) and \(r_p\) divide \(M_z\). Therefore

\[
n\equiv1\pmod p,
\qquad
n\equiv1\pmod{r_p}.
\]

Hence

\[
q^n\equiv q\pmod p.
\]

Also

\[
L_n=\frac{n(n-1)}2+1\equiv1\pmod p,
\qquad
U_n=\frac{n(n+1)}2\equiv1\pmod p.
\]

If \(q\not\equiv1\pmod p\), the division-free closed form gives

\[
(q-1)^2 A(n)
\equiv
q\big((q-1)+1\big)-\big((q-1)+q\big)
=
(q-1)^2
\pmod p.
\]

Since \(q-1\) is invertible,

\[
\boxed{A(n)\equiv1\pmod p.}
\]

If \(q\equiv1\pmod p\), the ordinary-sum formula gives

\[
A(n)
\equiv
\frac{n(n^2+1)}2
\equiv1
\pmod p.
\]

Thus every odd prime \(p\le z\), \(p\ne5\), is avoided.

### The primes 2 and 5

For \(z\ge5\),

\[
20\mid M_z.
\]

Hence

\[
n\equiv1\pmod{20}.
\]

Writing \(n=20m+1\),

\[
U_n
=
\frac{n(n+1)}2
=
(20m+1)(10m+1)
\equiv1\pmod{10}.
\]

The decimal concatenation ends in the final integer \(U_n\), so

\[
A(n)\equiv1\pmod{10}.
\]

Therefore neither 2 nor 5 divides \(A(n)\).

This proves the avoiding-progression theorem.

## 2. Size of the genuine fixed-width interval

Let

\[
I_D=
\{n:
10^{D-1}\le L_n,\ U_n<10^D\}.
\]

This is an interval of consecutive indices.

Its endpoints satisfy

\[
\min I_D
=
(\sqrt{2/10}+o(1))\,10^{D/2},
\]

and

\[
\max I_D
=
(\sqrt2+o(1))\,10^{D/2}.
\]

Consequently

\[
\boxed{
|I_D|
=
\left(\sqrt2-\sqrt{\frac15}+o(1)\right)10^{D/2}.
}
\]

In particular,

\[
\log |I_D|
=
\frac{\log10}{2}D+O(1).
\]

## 3. Size of the avoiding modulus

The classical Chebyshev function satisfies

\[
\log\operatorname{lcm}(1,2,\ldots,z)
=
\psi(z).
\]

By the prime number theorem,

\[
\psi(z)\sim z.
\]

Thus

\[
\boxed{
\log M_z=(1+o(1))z.
}
\]

## 4. Exponentially many rough values

Fix any real

\[
0<c<\frac{\log10}{2}.
\]

Let

\[
z_D=\lfloor cD\rfloor.
\]

Then

\[
\log M_{z_D}
=
(c+o(1))D,
\]

whereas

\[
\log|I_D|
=
\frac{\log10}{2}D+O(1).
\]

Therefore

\[
\frac{|I_D|}{M_{z_D}}
=
\exp\!\left(
\left(\frac{\log10}{2}-c+o(1)\right)D
\right).
\]

Every interval of length \(M_{z_D}\) contains exactly one integer congruent
to \(1\bmod M_{z_D}\). Hence

\[
\boxed{
\#\{n\in I_D:n\equiv1\pmod{M_{z_D}}\}
=
\exp\!\left(
\left(\frac{\log10}{2}-c+o(1)\right)D
\right).
}
\]

For every such index,

\[
P^-(A(n))>z_D,
\]

where \(P^-(N)\) is the least prime factor of \(N>1\).

Thus:

\[
\boxed{
P^-(A(n))>cD
}
\]

for exponentially many A053067 terms in every sufficiently large decimal
width \(D\), for every fixed

\[
c<\frac{\log10}{2}=1.151292546\ldots.
\]

## 5. Equivalent scale in terms of term size

For a \(D\)-digit-width term,

\[
\log\log A(n)
=
\frac{\log10}{2}D+O(\log D)
\]

uniformly at the natural index scale \(n\asymp10^{D/2}\).

Hence the construction gives, for every fixed \(\eta>0\), exponentially many
terms per width with

\[
\boxed{
P^-(A(n))
>
(1-\eta)\log\log A(n)
}
\]

after adjusting constants through the displayed asymptotic.

So the sequence contains a very large family of values that are rough at the
natural \(\log\log\)-scale.

## 6. Why this matters

This theorem is stronger than merely constructing one term escaping a
prescribed finite prime set.

For every sufficiently large width, there are exponentially many indices in
one explicit arithmetic progression for which **all primes up to a linear
function of the width are absent**.

It is therefore an unconditional global-distribution statement inside each
width band, not just a local-density calculation.

It still falls far short of primality: a term may be a product of several
enormous primes.  But it demonstrates that the sequence systematically
produces large populations of locally admissible, increasingly rough values.

Combined with the full factorization-scale local singular theorem on prime
widths, this further isolates the remaining difficulty as the genuine
prime-values/parity problem rather than a shortage of locally admissible
indices.
