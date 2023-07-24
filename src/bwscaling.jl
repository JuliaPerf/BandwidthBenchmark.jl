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

**Keyword arguments**
- `domains`: memory domains to consider (logical indices, i.e. starting at 1)
- `max_nthreads`: maximal number of threads per memory domain to consider
"""
function bwscaling_memory_domains(; domains=1:nnuma(),
    max_nthreads=maximum(ncores_per_numa()), kwargs...)
    if !all(i->i>0 && i<=nnuma(), domains)
        throw(ArgumentError("Invalid argument `numas` (out of bounds)."))
    end
    # query system information
    numacpuids = cpuids_per_numa()[domains]
    filter!.(!ishyperthread, numacpuids) # drop hyperthreads
    if !all(x->length(x) >= max_nthreads, numacpuids)
        throw(ArgumentError("Some memory domains don't have enough CPU-cores. Please provide a smaller value for `max_nthreads`."))
    end
    if Threads.nthreads() < length(domains) * max_nthreads
        throw(ErrorException("Not enough Julia threads. Please start Julia with at least " *
                             "$(length(domains) * max_nthreads) threads."))
    end
    results = DataFrame(;
        Function=String[],
        var"# Threads per domain"=Int64[],
        var"# Memory domains"=Int64[],
        var"Rate (MB/s)"=Float64[]
    )
    for nn in 1:length(domains) # how many domains to use
        for nt in 1:max_nthreads # how many threads/cores to use per domain
            println("domain=$(domains[nn]), nthreads_per_numa=$nt")
            total_nthreads = nn * nt
            # select cpuids
            cpuids = @views reduce(vcat, numacpuids[i][1:nt] for i in 1:nn)
            # @show cpuids
            # pin threads
            pinthreads(cpuids)
            # run benchmark (all kernels)
            df = bwbench(; nthreads=total_nthreads, kwargs...)
            # store and print result
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
