module BandwidthBenchmark

# stdlibs
using Base.Threads: @threads, nthreads
using Printf
using Statistics

# packages
using DataFrames
using PrettyTables
using Requires

# LIKWID dummies
LIKWID_register(tag) = nothing
LIKWID_start(tag) = nothing
LIKWID_stop(tag) = nothing
LIKWID_init() = nothing
LIKWID_close() = nothing

# includes
include("allocate.jl")
include("affinity.jl")
include("benchmarks.jl")
include("bwbench.jl")
include("bwscaling.jl")
export bwbench, bwscaling

function __init__()
    @require LIKWID="bf22376a-e803-4184-b2ed-56326e3bff83" begin
        LIKWID_register(tag) = LIKWID.Marker.registerregion(tag)
        LIKWID_start(tag) = LIKWID.Marker.startregion(tag)
        LIKWID_stop(tag) = LIKWID.Marker.stopregion(tag)
        LIKWID_init() = begin
            println("BandwidthBenchmark.jl: LIKWID Marker API is enabled!")
            LIKWID.Marker.init()
        end
        LIKWID_close() = LIKWID.Marker.close()
    end
end

end
