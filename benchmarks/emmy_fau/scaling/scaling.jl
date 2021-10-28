push!(LOAD_PATH, joinpath(@__DIR__, "../.."))

using BandwidthBenchmark
using UnicodePlots

data = bwscaling()
p = lineplot(data[:,1], data[:,2], title = "Bandwidth Scaling", xlabel = "# cores", ylabel = "MB/s", border = :ascii, canvas = AsciiCanvas)
print(stdout, p)