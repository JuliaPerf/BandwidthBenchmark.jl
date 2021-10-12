module BandwidthBenchmark

# stdlibs
using Base.Threads: @threads, nthreads
using Printf
using Statistics

# packages
using ThreadPools
using DataFrames
using PrettyTables

# includes
include("allocate.jl")
include("affinity.jl")
include("benchmarks.jl")
include("bwbench.jl")
export bwbench

end
