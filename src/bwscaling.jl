"""
Uses `bwbench()` to measure the memory bandwidth for an increasing number of threads (`1:max_nthreads`).
"""
function bwscaling(; max_nthreads=Threads.nthreads(), kwargs...)
    if max_nthreads > Threads.nthreads()
        throw(ArgumentError("max_nthreads must be ≤ Threads.nthreads()."))
    end
    results = zeros(max_nthreads, NBENCH)
    for n in 1:max_nthreads
        df = bwbench(; nthreads=n, kwargs...)
        results[n, :] .= df.var"Rate (MB/s)"
        println("$n Thread(s), Bandwidths (MB/s): ", join([round(bw, digits=2) for bw in @view results[n, :]], ", "))
        flush(stdout)
    end
    # print results
    println("\n\nScaling results:")
    data = hcat(1:max_nthreads, results)
    pretty_table(data; header=(vcat(["# Threads"], [b.label for b in BENCHMARKS]), vcat([""],["MB/s" for i in 1:NBENCH])))
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
