push!(LOAD_PATH, joinpath(@__DIR__, "../.."))

using BandwidthBenchmark
using UnicodePlots

Threads.@threads :static for i in 1:Threads.nthreads()
    println("Thread $i running on core $(BandwidthBenchmark.ThreadPinning.getcpuid())")
end
println()

title = length(ARGS) > 0 ? join(ARGS, " ") : nothing

data = BandwidthBenchmark.flopscaling()
p = lineplot(data[:,1], data[:,2], title = title, xlabel = "# cores", ylabel = "MFlops/s", border = :ascii, canvas = AsciiCanvas)
print(stdout, p)
