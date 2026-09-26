#include <algorithm>
#include <cmath>
#include <cstdint>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

using u64 = std::uint64_t;

static u64 powmod(u64 a, u64 e, u64 m) {
  u64 r = 1 % m;
  while (e) {
    if (e & 1) r = static_cast<u64>((__uint128_t)r * a % m);
    a = static_cast<u64>((__uint128_t)a * a % m);
    e >>= 1;
  }
  return r;
}

static std::vector<int> distinct_factors(int n, const std::vector<int>& spf) {
  std::vector<int> out;
  while (n > 1) {
    int p = spf[n];
    out.push_back(p);
    while (n % p == 0) n /= p;
  }
  return out;
}

static int ord10(int p, const std::vector<int>& spf) {
  int o = p - 1;
  for (int r : distinct_factors(o, spf)) {
    while (o % r == 0 && powmod(10, static_cast<u64>(o / r), p) == 1) {
      o /= r;
    }
  }
  return o;
}

int main(int argc, char** argv) {
  int max_p = 5000000;
  int max_d = 10000;
  std::string output = "prime-width-tail.csv";

  for (int i = 1; i < argc; ++i) {
    std::string a = argv[i];
    auto need_int = [&](int& x) {
      if (++i >= argc) throw std::runtime_error("missing numeric value");
      x = std::stoi(argv[i]);
    };
    if (a == "--max-p") need_int(max_p);
    else if (a == "--max-d") need_int(max_d);
    else if (a == "--output") {
      if (++i >= argc) throw std::runtime_error("missing output path");
      output = argv[i];
    } else {
      throw std::runtime_error("unknown argument: " + a);
    }
  }

  if (max_p < 7 || max_d < 2) throw std::runtime_error("invalid bounds");

  std::vector<int> spf(max_p + 1);
  for (int i = 0; i <= max_p; ++i) spf[i] = i;
  for (int i = 2; 1LL * i * i <= max_p; ++i) {
    if (spf[i] != i) continue;
    for (long long j = 1LL * i * i; j <= max_p; j += i) {
      if (spf[j] == j) spf[j] = i;
    }
  }

  std::vector<long double> mass(max_d + 1, 0.0L);
  std::vector<u64> count(max_d + 1, 0);
  u64 prime_count = 0;

  for (int p = 7; p <= max_p; ++p) {
    if (spf[p] != p || p == 5) continue;
    ++prime_count;
    int ell = ord10(p, spf);
    for (int d : distinct_factors(ell, spf)) {
      if (d > max_d) continue;
      mass[d] += static_cast<long double>(d) /
                 (static_cast<long double>(ell) * std::sqrt((long double)p));
      ++count[d];
    }
  }

  std::ofstream out(output);
  if (!out) throw std::runtime_error("cannot open output");
  out << "prime_width,max_local_prime,bad_tail_proxy,count\n";
  out << std::setprecision(18);
  long double min_mass = 1e100L, max_mass = -1;
  int min_d = -1, max_mass_d = -1;
  u64 widths = 0;

  for (int d = 2; d <= max_d; ++d) {
    if (spf[d] != d) continue;
    ++widths;
    out << d << ',' << max_p << ',' << mass[d] << ',' << count[d] << '\n';
    if (mass[d] < min_mass) { min_mass = mass[d]; min_d = d; }
    if (mass[d] > max_mass) { max_mass = mass[d]; max_mass_d = d; }
  }

  std::cerr << "prime-width-tail max_p=" << max_p
            << " max_d=" << max_d
            << " local_primes=" << prime_count
            << " widths=" << widths
            << " min=" << (double)min_mass << "@D=" << min_d
            << " max=" << (double)max_mass << "@D=" << max_mass_d
            << "\n";
}
