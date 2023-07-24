using BandwidthBenchmark
using BandwidthBenchmark.DataFrames
using BandwidthBenchmark.ThreadPinning
using Test

Threads.nthreads() ≥ 2 ||
    error("Can't run tests with single Julia thread! Forgot to set `JULIA_NUM_THREADS`?")

@testset "bwscaling" begin
    results = bwscaling(; max_nthreads=2, N=1000)
    @test results isa Matrix{Float64}
    @test size(results) == (2, BandwidthBenchmark.NBENCH + 1)
end

@testset "bwscaling_memory_domains" begin
    df = bwscaling_memory_domains(; domains=1:1, max_nthreads=2, N=1000)
    @test df isa DataFrame
    @test names(df) == ["Function", "# Threads per domain", "# Memory domains", "Rate (MB/s)"]
    @test size(df) == (1 * 2 * BandwidthBenchmark.NBENCH, 4)

    if nnuma() > 1 && (Threads.nthreads() >= nnuma() * 2)
        df = bwscaling_memory_domains(; max_nthreads=2, N=1000)
        @test df isa DataFrame
        @test names(df) == ["Function", "# Threads per domain", "# Memory domains", "Rate (MB/s)"]
        @test size(df) == (nnuma() * 2 * BandwidthBenchmark.NBENCH, 4)
    end
end

@testset "flopsscaling" begin
    result = flopsscaling(; max_nthreads=2)
    @test result isa Matrix{Float64}
    @test size(result) == (2, 2)
end
