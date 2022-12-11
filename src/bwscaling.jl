"""
Uses `bwbench()` to measure the memory bandwidth for an increasing number of threads (`1:max_nthreads`).
The kernel to be used (default: SDAXPY) can be specified via the `kernel` keyword argument.
"""
function bwscaling(; max_nthreads=Threads.nthreads(), kernel=:sdaxpy, kwargs...)
    bidx = benchmarkindex(kernel)
    if max_nthreads > Threads.nthreads()
        throw(ArgumentError("max_nthreads must be ≤ Threads.nthreads()."))
    elseif isnothing(bidx)
        throw(ArgumentError("Unknown kernel. Supported arguments are $(join(lowercase.(getproperty.(BENCHMARKS, :label)), ", "))"))
    end
    blabel = uppercase(string(kernel))
    results = zeros(max_nthreads)
    for n in 1:max_nthreads
        df = bwbench(; nthreads=n, kwargs...)
        results[n] = df.var"Rate (MB/s)"[bidx]
        println("$n Thread(s): $(blabel) Bandwidth (MB/s) is ", round(results[n], digits=2))
        flush(stdout)
    end

    # print results
    println("\n\nScaling results:")
    data = hcat(1:max_nthreads, results)
    pretty_table(data; header=["# Threads", "$(blabel) Bandwidth (MB/s)"])
    return data
end

function flopsscaling(; max_nthreads=Threads.nthreads())
    triad_results = zeros(max_nthreads)
    for n in 1:max_nthreads
        # bench
        N = 120_000_000
        alignment = 64
        a = allocate(Float64, N, alignment)
        b = allocate(Float64, N, alignment)
        c = allocate(Float64, N, alignment)
        scalar = 3.0

        Nperthread = floor(Int, N / n)
        rest = rem(N, n)
        thread_indices = collect(Iterators.partition(1:N, Nperthread))

        times = zeros(10)
        for k in 1:10
            times[k] = @elapsed triad_kernel(a, b, c, scalar; nthreads=n, thread_indices=thread_indices)
        end

        mintime = minimum(times)
        flops = 2 * N
        flop_rate = 1.0e-06 * flops / mintime
        # bench end

        triad_results[n] = flop_rate
        println("$n Thread(s): Triad Performance (MFlop/s) is ", round(triad_results[n], digits=2))
        flush(stdout)
    end

    # print results
    println("\n\nScaling results:")
    data = hcat(1:max_nthreads, triad_results)
    pretty_table(data; header=["# Threads", "Triad Performance (MFlop/s)"])
    return data
end
