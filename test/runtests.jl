using TestItemRunner

Threads.nthreads() ≥ 2 ||
    error("Can't run tests with single Julia thread! Forgot to set `JULIA_NUM_THREADS`?")

@run_package_tests

@testitem "benchmark kernels" begin
    include("benchmarks_tests.jl")
end
@testitem "bwbench" begin
    include("bwbench_tests.jl")
end
@testitem "bwscaling and co" begin
    include("bwscaling_tests.jl")
end
