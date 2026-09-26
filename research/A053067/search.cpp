#include <gmpxx.h>

#include <algorithm>
#include <atomic>
#include <chrono>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <mutex>
#include <numeric>
#include <optional>
#include <sstream>
#include <stdexcept>
#include <string>
#include <thread>
#include <vector>

using u64 = std::uint64_t;
using u128 = unsigned __int128;

static u64 mul_mod(u64 a, u64 b, u64 m) {
  return (u128)a * b % m;
}

static u64 add_mod(u64 a, u64 b, u64 m) {
  return (u64)(((u128)a + b) % m);
}

struct Transform {
  u64 A = 1;
  u64 B = 0;
  u64 C = 0;
  u64 K = 0;
};

// Composition for state (x,m):
//   x' = A*x + B*m + C (mod modulus)
//   m' = m + K.
static Transform compose(
    const Transform& after,
    const Transform& before,
    u64 modulus) {
  Transform r;
  r.A = mul_mod(after.A, before.A, modulus);
  r.B = add_mod(mul_mod(after.A, before.B, modulus), after.B, modulus);

  u64 c = mul_mod(after.A, before.C, modulus);
  c = add_mod(c, mul_mod(after.B, before.K % modulus, modulus), modulus);
  r.C = add_mod(c, after.C, modulus);
  r.K = before.K + after.K;
  return r;
}

static Transform transition_pow(u64 q, u64 count, u64 modulus) {
  Transform result;  // identity
  Transform base{q % modulus, 1 % modulus, 0, 1};

  while (count != 0) {
    if (count & 1) {
      result = compose(base, result, modulus);
    }
    count >>= 1;
    if (count) {
      base = compose(base, base, modulus);
    }
  }
  return result;
}

static unsigned digits10(u64 x) {
  unsigned d = 1;
  while (x >= 10) {
    x /= 10;
    ++d;
  }
  return d;
}

static u64 pow10_u64(unsigned d) {
  u64 x = 1;
  while (d--) {
    if (x > UINT64_MAX / 10) {
      throw std::runtime_error("10^d overflow");
    }
    x *= 10;
  }
  return x;
}

static std::pair<u64, u64> block_bounds(u64 n) {
  u128 lo = (u128)n * (n - 1) / 2 + 1;
  u128 hi = (u128)n * (n + 1) / 2;
  if (hi > UINT64_MAX) {
    throw std::runtime_error("n too large for 64-bit block endpoints");
  }
  return {(u64)lo, (u64)hi};
}

// Compute A053067(n) modulo modulus without constructing A053067(n).
static u64 concat_mod(u64 n, u64 modulus) {
  auto [lo, hi] = block_bounds(n);
  u64 x = 0;
  u64 cur = lo;

  while (cur <= hi) {
    unsigned d = digits10(cur);
    u64 p10 = pow10_u64(d);
    u64 end = std::min(hi, p10 - 1);
    u64 count = end - cur + 1;

    Transform t = transition_pow(p10 % modulus, count, modulus);

    u64 y = mul_mod(t.A, x, modulus);
    y = add_mod(y, mul_mod(t.B, cur % modulus, modulus), modulus);
    y = add_mod(y, t.C, modulus);
    x = y;

    cur = end + 1;
  }
  return x;
}

// For n>2, a prime term must not be divisible by 2, 3 or 5.
// A(n) mod 3 is the sum of the n integers in the block mod 3, so n=0 mod 3
// is excluded. The last decimal digit is T_n mod 10 and must be 1,3,7,9.
static bool elementary_candidate(u64 n) {
  if (n <= 2) {
    return true;
  }
  if (n % 3 == 0) {
    return false;
  }

  auto [lo, hi] = block_bounds(n);
  (void)lo;
  u64 last = hi % 10;
  return last == 1 || last == 3 || last == 7 || last == 9;
}

static std::vector<unsigned> primes_up_to(unsigned limit) {
  std::vector<bool> is(limit + 1, true);
  is[0] = false;
  if (limit >= 1) {
    is[1] = false;
  }

  for (unsigned p = 2; (u64)p * p <= limit; ++p) {
    if (!is[p]) {
      continue;
    }
    for (u64 k = (u64)p * p; k <= limit; k += p) {
      is[(size_t)k] = false;
    }
  }

  std::vector<unsigned> ps;
  for (unsigned p = 2; p <= limit; ++p) {
    if (is[p]) {
      ps.push_back(p);
    }
  }
  return ps;
}

struct Batch {
  u64 product = 1;
  std::vector<unsigned> primes;
};

// Packing primes into products makes one concat_mod computation test several
// primes at once. Keeping the product below 2^63 lets mul_mod use u128 safely.
static std::vector<Batch> make_batches(const std::vector<unsigned>& ps) {
  constexpr u64 LIMIT = (u64(1) << 63) - 1;
  std::vector<Batch> out;
  Batch batch;

  for (unsigned p : ps) {
    if (p <= 5) {
      continue;
    }

    if (batch.product > LIMIT / p) {
      out.push_back(std::move(batch));
      batch = Batch{};
    }

    batch.product *= p;
    batch.primes.push_back(p);
  }

  if (!batch.primes.empty()) {
    out.push_back(std::move(batch));
  }
  return out;
}

static std::optional<unsigned> small_factor(
    u64 n,
    const std::vector<Batch>& batches) {
  for (const auto& batch : batches) {
    u64 remainder = concat_mod(n, batch.product);
    u64 g = std::gcd(remainder, batch.product);

    if (g > 1) {
      for (unsigned p : batch.primes) {
        if (remainder % p == 0) {
          return p;
        }
      }
    }
  }
  return std::nullopt;
}

static std::string build_decimal(u64 n) {
  auto [lo, hi] = block_bounds(n);

  std::string s;
  s.reserve((size_t)n * digits10(hi));

  for (u64 x = lo; x <= hi; ++x) {
    s += std::to_string(x);
  }
  return s;
}

struct Config {
  u64 start = 3;
  u64 end = 1000;
  unsigned sieve_bound = 200000;
  int prp_reps = 25;
  u64 shard_index = 0;
  u64 shard_count = 1;
  unsigned threads = 0;
  std::string output;
};

static Config parse_args(int argc, char** argv) {
  Config cfg;

  for (int i = 1; i < argc; ++i) {
    std::string arg = argv[i];

    auto need = [&](auto& dst) {
      if (++i >= argc) {
        throw std::runtime_error("missing value after " + arg);
      }
      std::stringstream ss(argv[i]);
      ss >> dst;
      if (!ss || !ss.eof()) {
        throw std::runtime_error("bad value for " + arg);
      }
    };

    if (arg == "--start") {
      need(cfg.start);
    } else if (arg == "--end") {
      need(cfg.end);
    } else if (arg == "--sieve-bound") {
      need(cfg.sieve_bound);
    } else if (arg == "--prp-reps") {
      need(cfg.prp_reps);
    } else if (arg == "--shard-index") {
      need(cfg.shard_index);
    } else if (arg == "--shard-count") {
      need(cfg.shard_count);
    } else if (arg == "--threads") {
      need(cfg.threads);
    } else if (arg == "--output") {
      if (++i >= argc) {
        throw std::runtime_error("missing value after --output");
      }
      cfg.output = argv[i];
    } else if (arg == "--help") {
      std::cout
          << "A053067 search\n"
          << "  --start N --end N --sieve-bound P --prp-reps R\n"
          << "  --shard-index I --shard-count C --threads T --output FILE\n";
      std::exit(0);
    } else {
      throw std::runtime_error("unknown argument: " + arg);
    }
  }

  if (cfg.start > cfg.end) {
    throw std::runtime_error("start > end");
  }
  if (cfg.shard_count == 0 || cfg.shard_index >= cfg.shard_count) {
    throw std::runtime_error("invalid shard");
  }
  return cfg;
}

struct Result {
  u64 n = 0;
  std::string status;
  std::string witness;
  std::size_t digits = 0;
};

static Result evaluate(
    u64 n,
    const Config& cfg,
    const std::vector<Batch>& batches) {
  Result result;
  result.n = n;

  if (auto factor = small_factor(n, batches)) {
    result.status = "small_factor";
    result.witness = std::to_string(*factor);
    return result;
  }

  std::string decimal = build_decimal(n);
  result.digits = decimal.size();

  mpz_class value;
  if (mpz_set_str(value.get_mpz_t(), decimal.c_str(), 10) != 0) {
    throw std::runtime_error("mpz_set_str failed");
  }

  int primality = mpz_probab_prime_p(value.get_mpz_t(), cfg.prp_reps);
  if (primality == 0) {
    result.status = "composite_prp";
  } else {
    result.status = "probable_prime";
    result.witness = std::to_string(primality);
  }
  return result;
}

int main(int argc, char** argv) {
  try {
    Config cfg = parse_args(argc, argv);
    if (cfg.threads == 0) {
      cfg.threads = std::max(1u, std::thread::hardware_concurrency());
    }

    auto primes = primes_up_to(cfg.sieve_bound);
    auto batches = make_batches(primes);

    std::vector<u64> candidates;
    for (u64 n = cfg.start; n <= cfg.end; ++n) {
      if ((n - cfg.start) % cfg.shard_count != cfg.shard_index) {
        continue;
      }
      if (elementary_candidate(n)) {
        candidates.push_back(n);
      }
    }

    std::vector<Result> results(candidates.size());
    std::atomic<std::size_t> next{0};
    std::atomic<bool> failed{false};
    std::string failure;
    std::mutex failure_mutex;

    auto started = std::chrono::steady_clock::now();

    auto worker = [&]() {
      while (!failed.load(std::memory_order_relaxed)) {
        std::size_t i = next.fetch_add(1);
        if (i >= candidates.size()) {
          return;
        }

        try {
          results[i] = evaluate(candidates[i], cfg, batches);
        } catch (const std::exception& e) {
          failed.store(true);
          std::lock_guard<std::mutex> lock(failure_mutex);
          if (failure.empty()) {
            failure = e.what();
          }
          return;
        }
      }
    };

    unsigned worker_count = std::min<unsigned>(
        cfg.threads,
        std::max<std::size_t>(1, candidates.size()));

    std::vector<std::thread> workers;
    workers.reserve(worker_count);
    for (unsigned i = 0; i < worker_count; ++i) {
      workers.emplace_back(worker);
    }
    for (auto& thread : workers) {
      thread.join();
    }

    if (failed) {
      throw std::runtime_error(failure);
    }

    std::ostream* output = &std::cout;
    std::ofstream file;
    if (!cfg.output.empty()) {
      file.open(cfg.output);
      if (!file) {
        throw std::runtime_error("cannot open output");
      }
      output = &file;
    }

    auto& os = *output;
    os << "n,status,witness,digits\n";

    u64 factored = 0;
    u64 prp_composite = 0;
    u64 probable_prime = 0;

    for (const auto& result : results) {
      if (result.status == "small_factor") {
        ++factored;
      } else if (result.status == "composite_prp") {
        ++prp_composite;
      } else if (result.status == "probable_prime") {
        ++probable_prime;
        std::cerr
            << "PRP CANDIDATE n=" << result.n
            << " digits=" << result.digits << "\n";
      }

      os
          << result.n << ","
          << result.status << ","
          << result.witness << ",";
      if (result.digits) {
        os << result.digits;
      }
      os << "\n";
    }

    double seconds = std::chrono::duration<double>(
        std::chrono::steady_clock::now() - started).count();

    std::cerr
        << "A053067 summary"
        << " range=" << cfg.start << ".." << cfg.end
        << " shard=" << cfg.shard_index << "/" << cfg.shard_count
        << " threads=" << worker_count
        << " elementary=" << candidates.size()
        << " small_factor=" << factored
        << " composite_prp=" << prp_composite
        << " probable_prime=" << probable_prime
        << " seconds=" << seconds
        << "\n";

    // A distinct code lets automation surface a candidate loudly while still
    // distinguishing it from an execution failure.
    return probable_prime ? 10 : 0;
  } catch (const std::exception& e) {
    std::cerr << "error: " << e.what() << "\n";
    return 2;
  }
}
