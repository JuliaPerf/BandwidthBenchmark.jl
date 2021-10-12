using BandwidthBenchmark
using BandwidthBenchmark.PrettyTables

# we take NT as the upper limit for our scaling analysis
NT = Threads.nthreads()
sdaxpy_results = zeros(NT)
for n in 1:NT
    df = bwbench(; nthreads=n, verbose=true)
    sdaxpy_results[n] = last(df.var"Rate (MB/s)")
    flush(stdout) # to be safe
end

# print results
println("\n\nScaling results:")
pretty_table(hcat(1:NT, sdaxpy_results); header=["# Threads", "SDaxpy Bandwidth (MB/s)"])