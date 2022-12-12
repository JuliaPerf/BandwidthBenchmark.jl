using BandwidthBenchmark
using Test

Threads.nthreads() ≥ 2 ||
    error("Can't run tests with single Julia thread! Forgot to set `JULIA_NUM_THREADS`?")

N = 200
nthreads = 2
thread_indices = [1:100, 101:200]
a = fill(2.0, N)
b = fill(2.0, N)
c = fill(0.5, N)
d = ones(N)
scalar = 3.0

@test isnothing(BandwidthBenchmark.init_kernel(b, scalar; thread_indices, nthreads))
@test isnothing(BandwidthBenchmark.copy_kernel(c, a; thread_indices, nthreads))
@test isnothing(BandwidthBenchmark.update_kernel(a, scalar; thread_indices, nthreads))
@test isnothing(BandwidthBenchmark.triad_kernel(a, b, c, scalar; thread_indices, nthreads))
@test isnothing(BandwidthBenchmark.daxpy_kernel(a, b, scalar; thread_indices, nthreads))
@test isnothing(BandwidthBenchmark.striad_kernel(a, b, c, d; thread_indices, nthreads))
@test isnothing(BandwidthBenchmark.sdaxpy_kernel(a, b, c; thread_indices, nthreads))

@test BandwidthBenchmark.validate(a, b, c, d, N, 1)
