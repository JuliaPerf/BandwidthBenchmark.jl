using BandwidthBenchmark
using BandwidthBenchmark.DataFrames
using Test

Threads.nthreads() ≥ 2 ||
    error("Can't run tests with single Julia thread! Forgot to set `JULIA_NUM_THREADS`?")

result = bwbench(; N=1000, niter=10, verbose=false, nthreads=2, alignment=64,
    write_allocate=false);
@test result isa DataFrame
@test names(result) == ["Function", "Rate (MB/s)", "Rate (MFlop/s)", "Avg time",
    "Min time", "Max time"]
