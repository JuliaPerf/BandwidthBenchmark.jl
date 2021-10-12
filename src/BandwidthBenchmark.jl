module BandwidthBenchmark

# stdlibs
using Base.Threads: @threads, nthreads
using Printf
using Statistics

# packages
using DataFrames
using PrettyTables

# includes
include("allocate.jl")
include("affinity.jl")
include("benchmarks.jl")
include("bwbench.jl")
include("bwscaling.jl")
export bwbench, bwscaling

end
