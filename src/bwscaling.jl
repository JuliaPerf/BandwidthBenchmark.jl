"""
Uses `bwbench` to measure the memory bandwidth for an increasing number of threads
(`1:max_nthreads`). Returns a matrix whose rows correspond to the number of threads and
different columns hold the bandwidth results for each kernel.
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
    pretty_table(data; header=(vcat(["# Threads"], [b.label for b in BENCHMARKS]), vcat([""], ["MB/s" for i in 1:NBENCH])))
    return data
end

"""
Similar to `bwscaling` but measures the memory bandwidth scaling within and across
memory domains. Returns a `DataFrame` in which each row contains the kernel name,
the number of threads per memory domain, the number of domains considered, and the
measured memory bandwidth (in MB/s).
"""
function bwscaling_memory_domains(; kwargs...)
    if Threads.nthreads() < ncores()
        throw(ErrorException("Not enough Julia threads for the available number of cores " *
                             "($(ncores())). Please start Julia with at least $(ncores()) threads."))
    elseif length(Set(ncores_per_numa())) > 1 # all memory domains have same number of cores
        throw(ErrorException("Memory domains have different number of cores. " *
                             "This is currently unsupported."))
    end
    # query system information
    numacpuids = cpuids_per_numa()
    filter!.(!ishyperthread, numacpuids) # drop hyperthreads
    NNUMA = nnuma()
    NCORES_PER_NUMA = first(ncores_per_numa())
    # results = zeros(NCORES_PER_NUMA, NNUMA, NBENCH)
    results = DataFrame(;
        Function=String[],
        var"# Threads per domain"=Int64[],
        var"# Memory domains"=Int64[],
        var"Rate (MB/s)"=Float64[]
    )
    for nn in 1:NNUMA # how many domains to use
        for nt in 1:NCORES_PER_NUMA # how many threads/cores to use per domain
            println("nnuma=$nn, nthreads_per_numa=$nt")
            total_nthreads = nn * nt
            # select cpuids
            cpuids = @views reduce(vcat, numacpuids[i][1:nt] for i in 1:nn)
            # pin threads
            pinthreads(cpuids)
            # run benchmark (all kernels)
            df = bwbench(; nthreads=total_nthreads, kwargs...)
            # store and print result
            # results[nt, nn, :] .= df.var"Rate (MB/s)"
            for row in eachrow(df)
                push!(results, [row.Function, nt, nn, row.var"Rate (MB/s)"])
            end
            println("Bandwidths (MB/s): ", join([round(bw, digits=2) for bw in df.var"Rate (MB/s)"], ", "))
            flush(stdout)
        end
    end
    return results
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
