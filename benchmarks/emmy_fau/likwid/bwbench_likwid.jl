# make BandwidthBenchmark loadable
push!(LOAD_PATH, joinpath(@__DIR__, "../.."))

using BandwidthBenchmark
using LIKWID

bwbench(; verbose=true)