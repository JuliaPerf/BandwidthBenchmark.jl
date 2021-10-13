push!(LOAD_PATH, joinpath(@__DIR__, "../.."))

using BandwidthBenchmark
using UnicodePlots

Threads.@threads :static for i in 1:Threads.nthreads()
    println("Thread $i running on core $(BandwidthBenchmark.get_core_id())")
end
println()

data = BandwidthBenchmark.flopscaling()
p = lineplot(data[:,1], data[:,2], title = "Compact Pinning", xlabel = "# cores", ylabel = "MFlops/s", border = :ascii, canvas = AsciiCanvas)
print(stdout, p)