"""
Use `bwbench()` to measure the memory bandwidth for an increasing number of threads (`1:max_nthreads`).
"""
function bwscaling(; max_nthreads = Threads.nthreads(), kwargs...)
    max_nthreads ≤ Threads.nthreads() || throw(ArgumentError("max_nthreads must be ≤ Threads.nthreads()."))
    sdaxpy_results = zeros(max_nthreads)
    for n in 1:max_nthreads
        df = bwbench(; nthreads=n, kwargs...)
        sdaxpy_results[n] = last(df.var"Rate (MB/s)")
        println("$n Thread(s): SDaxpy Bandwidth (MB/s) is ", round(sdaxpy_results[n], digits=2))
        flush(stdout)
    end

    # print results
    println("\n\nScaling results:")
    pretty_table(hcat(1:max_nthreads, sdaxpy_results); header=["# Threads", "SDaxpy Bandwidth (MB/s)"])    
    return nothing
end