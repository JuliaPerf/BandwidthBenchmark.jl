using ThreadPinning
using BandwidthBenchmark
using UnicodePlots

# Compact Pinning
pinthreads(:compact)
println("Check compact pinning: ", getcpuids(), "\n")

# bwbench(; verbose=true);
println("bwbench():")
bwbench(; verbose=true, write_allocate=true);

println("bwscaling():")
data = bwscaling()
p = lineplot(data[:,1], data[:,2], title = "Bandwidth Scaling, Compact Pinning", xlabel = "# cores", ylabel = "MB/s", border = :ascii, canvas = AsciiCanvas)
println(p)

println("flopsscaling():")
data = BandwidthBenchmark.flopscaling()
p = lineplot(data[:,1], data[:,2], title = "Flops Scaling, Compact Pinning", xlabel = "# cores", ylabel = "MFlops/s", border = :ascii, canvas = AsciiCanvas)
println(p)

# Scatter Pinning
pinthreads(:scatter)
println("Check scatter pinning: ", getcpuids(), "\n")

# bwbench(; verbose=true);
println("bwbench():")
bwbench(; verbose=true, write_allocate=true);

println("bwscaling():")
data = bwscaling()
p = lineplot(data[:,1], data[:,2], title = "Bandwidth Scaling, Scattered Pinning", xlabel = "# cores", ylabel = "MB/s", border = :ascii, canvas = AsciiCanvas)
println(p)

println("flopsscaling():")
data = BandwidthBenchmark.flopscaling()
p = lineplot(data[:,1], data[:,2], title = "Flops Scaling, Scattered Pinning", xlabel = "# cores", ylabel = "MFlops/s", border = :ascii, canvas = AsciiCanvas)
println(p)

