# Period-corrected prime-location heuristic for A053067

This note translates the measured local singular corrections into a rough
prediction for where the next prime term might occur.

It is **not** a proof and should not be read as a numerical forecast with
tight confidence bounds. Its purpose is strategic: determine whether a
sequential primality search is likely to be computationally sensible.

## Prime mass of one decimal-width band

In a genuine fixed-width band of decimal width \(d\), A053067(\(n\)) has
exactly \(dn\) decimal digits, up to the leading-digit normalization already
contained in the exact integer. Thus

\[
\log A(n)\sim dn\log 10.
\]

Exactly \(1/5\) of indices survive the elementary \(2,3,5\) conditions, and
conditioning a random integer on avoiding \(2,3,5\) multiplies prime density
by

\[
\frac{1}{(1-\frac12)(1-\frac13)(1-\frac15)}
=
\frac{15}{4}.
\]

Including the period-corrected local singular factor \(C_d\), the average
prime hazard per index is therefore

\[
\frac{3C_d}{4d\,n\log10}.
\]

The ratio of the upper and lower index endpoints of a full width band tends to
\(\sqrt{10}\), so

\[
\sum_{\text{one width band}}\frac1n
\sim\frac12\log10.
\]

Hence one full width contributes expected prime mass

\[
\boxed{
\lambda_d\sim\frac{3C_d}{8d}.
}
\]

## Using the measured corrections

As a finite-cutoff proxy for \(C_d\), use the exact corrections
\(C_d(1000)\) from hosted run 36266146082.

The full PRP search has now excluded probable-prime terms through \(n=10000\).
The ten-thousandth index lies inside the \(d=8\) fixed-width band, whose full
range is

\[
4473\le n\le14141.
\]

Only the remaining logarithmic fraction

\[
\frac{\log(14141/10000)}{\log\sqrt{10}}
=
0.3009602445
\]

of that band's prime mass is still unsearched.

Starting immediately after \(n=10000\), accumulate

\[
\Lambda(D)
=
\text{remaining \(d=8\) mass}
+
\sum_{d=9}^{D}\frac{3C_d(1000)}{8d}.
\]

Under a Poisson-style rare-prime model, the probability that at least one
prime has appeared is approximately

\[
1-e^{-\Lambda}.
\]

The measured corrections give the following landmarks.

### Median

The cumulative mass reaches

\[
\log2
\]

inside decimal width

\[
\boxed{d=46}.
\]

The crossing occurs about 70.8% of the way through that width on the
logarithmic \(n\)-scale, corresponding to approximately

\[
\boxed{n\sim10^{23.00}}.
\]

Thus the crude model puts the **median next-prime index around \(10^{23}\)**,
not around \(10^4\) or \(10^6\).

### Expected-count one

The cumulative future expected count reaches 1 inside

\[
\boxed{d=101},
\]

at an index scale of roughly

\[
\boxed{n\sim10^{50.31}}.
\]

### 90% cumulative probability

The cumulative mass reaches

\[
-\log(0.1)=2.302585\ldots
\]

only near

\[
\boxed{d=2756},
\]

at the extraordinary index scale

\[
\boxed{n\sim10^{1378.13}}.
\]

These enormous scales are a direct consequence of the band mass decaying like
\(1/d\).

## Interpretation

This heuristic explains why a sequential computational search can easily find
nothing for a very long time even if infinitely many prime terms exist.

It also changes the optimal computational strategy:

1. modest sequential PRP searches are still useful for certification and for
   catching a lucky early outlier;
2. pushing sequentially by many orders of magnitude in \(n\) is not a
   realistic route to the conjecture;
3. analytic proof construction and local-structure theorems have much higher
   expected value;
4. the computational runner should increasingly be used to test structural
   conjectures, singular factors and selected certificates rather than merely
   incrementing the search bound.

## Caveats

The numbers above use \(C_d(1000)\), not the infinite-prime correction \(C_d\).
The local-product experiments through \(B=5000\) and the fixed-width
convergence theorem indicate that this is a reasonable proxy, but the tail
remains a source of uncertainty.

Independence/Poisson assumptions are also heuristic. A hidden global
correlation could shift these scales dramatically.

The robust conclusion is qualitative: under the currently successful local
model, the next prime is expected to be **extremely far away**, so absence of
a prime in the present computational range is not evidence for eventual
compositeness.
