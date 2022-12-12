module BandwidthBenchmark

# stdlibs
using Base.Threads: @threads, nthreads
using Printf
using Statistics

# packages
using DataFrames
using PrettyTables
using Requires
using ThreadPinning

# LIKWID dummies
LIKWID_register(tag) = nothing
LIKWID_start(tag, nthreads) = nothing
LIKWID_stop(tag, nthreads) = nothing
LIKWID_init() = nothing
LIKWID_close() = nothing

# includes
include("allocate.jl")
include("affinity.jl")
include("benchmarks.jl")
include("bwbench.jl")
include("bwscaling.jl")
export bwbench, bwscaling, bwscaling_memory_domains, flopsscaling

function __init__()
    @require LIKWID="bf22376a-e803-4184-b2ed-56326e3bff83" begin
        LIKWID_register(tag) = LIKWID.Marker.registerregion(tag)
        LIKWID_start(tag, nthreads) = begin
            @threads :static for i in 1:nthreads
                LIKWID.Marker.startregion(tag)
            end
        end
        LIKWID_stop(tag, nthreads) = begin
            @threads :static for i in 1:nthreads
                LIKWID.Marker.stopregion(tag)
            end
        end
        LIKWID_init() = begin
            println("BandwidthBenchmark.jl: LIKWID Marker API is enabled!")
            LIKWID.Marker.init()
        end
        LIKWID_close() = LIKWID.Marker.close()
    end
end

end
