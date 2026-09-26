#include <algorithm>
#include <cstdint>
#include <iostream>
#include <numeric>
#include <string>
#include <unordered_map>
#include <vector>

/*
Research-only exhaustive scan for the Markov open-core branch.

For a palindromic inner word p over the Cohn generators
  A = [[1,1],[1,2]], B = [[2,1],[1,1]],
we test the word a p b.  Its m-value is the upper-right matrix entry.

The experiment asks whether the same m-value can occur for two different
unordered endpoint-count pairs (#a,#b).  This is intentionally stronger than
the Frobenius/Markov uniqueness conjecture and is NOT assumed to be true.

The implementation exploits symmetry: since A and B are symmetric,
M(reverse(h)) = M(h)^T.  Thus an even palindrome h reverse(h) is evaluated as
H H^T in O(1) after the half-word matrix H has been built.
*/

using u128 = unsigned __int128;

struct Mat {
  u128 a, b, c, d;
};

static const Mat I{1,0,0,1};
static const Mat A{1,1,1,2};
static const Mat B{2,1,1,1};

static Mat mul(const Mat& x, const Mat& y) {
  return {
    x.a*y.a + x.b*y.c,
    x.a*y.b + x.b*y.d,
    x.c*y.a + x.d*y.c,
    x.c*y.b + x.d*y.d
  };
}

static Mat transpose(const Mat& x) {
  return {x.a, x.c, x.b, x.d};
}

static std::string show(u128 x) {
  if (x == 0) return "0";
  std::string s;
  while (x) {
    s.push_back(char('0' + unsigned(x % 10)));
    x /= 10;
  }
  std::reverse(s.begin(), s.end());
  return s;
}

struct Key {
  u128 m;
  bool operator==(const Key& other) const { return m == other.m; }
};

struct KeyHash {
  std::size_t operator()(const Key& key) const {
    std::uint64_t lo = std::uint64_t(key.m);
    std::uint64_t hi = std::uint64_t(key.m >> 64);
    return std::size_t(lo ^ (hi * 0x9e3779b97f4a7c15ULL));
  }
};

struct Record {
  u128 root;
  std::uint8_t lo, hi;
};

int main(int argc, char** argv) {
  int max_inner = argc > 1 ? std::stoi(argv[1]) : 40;

  std::unordered_map<Key, Record, KeyHash> seen;
  seen.reserve(std::size_t(1) << std::min(24, (max_inner + 1) / 2 + 2));

  std::uint64_t total = 0;
  std::uint64_t cross_endpoint = 0;
  std::uint64_t repeated_root_events = 0;
  std::uint64_t primitive_repeated_root_events = 0;

  for (int n = 0; n <= max_inner; ++n) {
    const int half = (n + 1) / 2;
    const std::uint64_t variants = std::uint64_t(1) << half;

    for (std::uint64_t mask = 0; mask < variants; ++mask) {
      Mat H = I;
      std::vector<Mat> prefix(half + 1);
      prefix[0] = I;
      int half_a = 0, half_b = 0;

      for (int i = 0; i < half; ++i) {
        const bool is_b = (mask >> i) & 1;
        if (is_b) ++half_b; else ++half_a;
        H = mul(H, is_b ? B : A);
        prefix[i + 1] = H;
      }

      Mat P;
      int inner_a = 0, inner_b = 0;

      if (n == 0) {
        P = I;
      } else if ((n & 1) == 0) {
        P = mul(H, transpose(H));
        inner_a = 2 * half_a;
        inner_b = 2 * half_b;
      } else {
        const Mat Hprefix = prefix[half - 1];
        P = mul(H, transpose(Hprefix));
        const bool middle_b = (mask >> (half - 1)) & 1;
        inner_a = 2 * half_a - (middle_b ? 0 : 1);
        inner_b = 2 * half_b - (middle_b ? 1 : 0);
      }

      const Mat X = mul(mul(A, P), B);
      const u128 m = X.b;
      const u128 raw_root = X.d - m;
      const u128 centered_root = std::min(raw_root, m - raw_root);

      const int count_a = inner_a + 1;
      const int count_b = inner_b + 1;
      const std::uint8_t lo = std::uint8_t(std::min(count_a, count_b));
      const std::uint8_t hi = std::uint8_t(std::max(count_a, count_b));

      ++total;
      auto [it, inserted] = seen.emplace(Key{m}, Record{centered_root, lo, hi});
      if (!inserted) {
        if (it->second.lo != lo || it->second.hi != hi) {
          ++cross_endpoint;
          std::cout
            << "COUNTEREXAMPLE m=" << show(m)
            << " old_counts=" << unsigned(it->second.lo) << "," << unsigned(it->second.hi)
            << " new_counts=" << unsigned(lo) << "," << unsigned(hi)
            << "\n";
          return 1;
        }
        if (it->second.root != centered_root) {
          ++repeated_root_events;
          const bool primitive =
            std::gcd(unsigned(lo), unsigned(hi)) == 1;
          if (primitive) {
            ++primitive_repeated_root_events;
            std::cout
              << "PRIMITIVE_ROOT_COLLISION m=" << show(m)
              << " roots=" << show(it->second.root) << "," << show(centered_root)
              << " counts=" << unsigned(lo) << "," << unsigned(hi)
              << "\n";
            return 2;
          }
        }
      }
    }

    std::cerr
      << "inner=" << n
      << " total=" << total
      << " distinct_m=" << seen.size()
      << " cross_endpoint=" << cross_endpoint
      << " repeated_root_events=" << repeated_root_events
      << " primitive_repeated_root_events=" << primitive_repeated_root_events
      << "\n";
  }

  std::cout
    << "DONE max_inner=" << max_inner
    << " total=" << total
    << " distinct_m=" << seen.size()
    << " cross_endpoint=" << cross_endpoint
    << " repeated_root_events=" << repeated_root_events
    << " primitive_repeated_root_events=" << primitive_repeated_root_events
    << "\n";
  return 0;
}
