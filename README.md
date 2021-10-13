# BandwidthBenchmark.jl

*Measuring memory bandwidth using streaming kernels*

[TheBandwidthBenchmark](https://github.com/RRZE-HPC/TheBandwidthBenchmark) as a Julia package.

Citing from the [original source](https://github.com/RRZE-HPC/TheBandwidthBenchmark):

> It contains the following streaming kernels with corresponding data access pattern (Notation: S - store, L - load, WA - write allocate). All variables are vectors, s is a scalar:
>
>    * init (S1, WA): Initilize an array: `a = s`. Store only.
>    * sum (L1): Vector reduction: `s += a`. Load only.
>    * copy (L1, S1, WA): Classic memcopy: `a = b`.
>    * update (L1, S1): Update vector: `a = a * scalar`. Also load + store but **without write allocate**.
>    * triad (L2, S1, WA): Stream triad: `a = b + c * scalar`.
>    * daxpy (L2, S1): Daxpy (**without write allocate**): `a = a + b * scalar`.
>    * striad (L3, S1, WA): Schoenauer triad: `a = b + c * d`.
>    * sdaxpy (L3, S1): Schoenauer triad **without write allocate**: `a = a + b * c`.

Note, that we do not (yet) include the sum reduction in this Julia package.

## Examples

Benchmark examples, conducted on the [Emmy cluster at NHR@FAU](https://hpc.fau.de/systems-services/systems-documentation-instructions/clusters/emmy-cluster/), can be found in the [benchmark folder](https://github.com/carstenbauer/BandwidthBenchmark.jl/tree/main/benchmark).

## `bwbench`

**Keyword arguments:**

* `N` (default: `120_000_000`): length of vectors
* `nthreads` (default: `Threads.nthreads()`): number of Julia threads to use
* `niter` (default: `10`): # of times we repeat the measurement
* `alignment` (default: `64`): array alignment
* `verbose` (default: `false`): print result table + thread information etc.
* `write_allocate` (default: `false`): include write allocate compensation factors

It is highly recommend(!) to pin the Julia threads to specific cores (according to the architecture at hand). The simplest way is probably to set `JULIA_EXCLUSIVE=1`, which will pin Julia threads to the first `N` cores of the system. For more specific pinning, [LIKIWD.jl](https://github.com/JuliaPerf/LIKWID.jl) or other tools like `numactl` may be useful.

```julia
julia> using BandwidthBenchmark

julia> bwbench(; verbose=true);
Threading enabled, using 8 (of 8) Julia threads
Total allocated datasize: 3840.0 MB
	Thread 6 running on core 5.
	Thread 5 running on core 4.
	Thread 2 running on core 1.
	Thread 3 running on core 2.
	Thread 7 running on core 6.
	Thread 8 running on core 7.
	Thread 1 running on core 0.
	Thread 4 running on core 3.
┌──────────┬─────────────┬────────────────┬───────────┬───────────┬───────────┐
│ Function │ Rate (MB/s) │ Rate (MFlop/s) │  Avg time │  Min time │  Max time │
│   String │     Float64 │        Float64 │   Float64 │   Float64 │   Float64 │
├──────────┼─────────────┼────────────────┼───────────┼───────────┼───────────┤
│     Init │     18972.0 │            0.0 │ 0.0508247 │ 0.0506008 │ 0.0510763 │
│     Copy │     27137.6 │            0.0 │ 0.0710205 │ 0.0707507 │ 0.0715388 │
│   Update │     37939.9 │        2371.24 │ 0.0509081 │ 0.0506063 │ 0.0512734 │
│    Triad │     30753.6 │         2562.8 │ 0.0943514 │ 0.0936477 │  0.094945 │
│    Daxpy │     40548.7 │        3379.05 │  0.071467 │ 0.0710258 │ 0.0719743 │
│   STriad │     33344.3 │        2084.02 │  0.115823 │  0.115162 │   0.11737 │
│   SDaxpy │     41370.0 │        2585.62 │ 0.0935033 │ 0.0928209 │ 0.0941559 │
└──────────┴─────────────┴────────────────┴───────────┴───────────┴───────────┘
```

### LIKWID & Write Allocate

When LIKWID.jl is loaded, `bwbench` will automatically try to use LIKWIDs Marker API! Running e.g.

```
JULIA_EXCLUSIVE=1 likwid-perfctr -c 0-7 -g MEM_DP -m julia --project=. --math-mode=fast -t8 bwbench_likwid.jl
```

one gets detailed information from hardware-performance counters: [example output](https://github.com/carstenbauer/BandwidthBenchmark.jl/blob/main/benchmark/likwid/run_bwbench_likwid.out). Among other things, we can use these values to check / prove that write allocates have happened. Inspecting the memory bandwith associated with read and write in the STRIAD region, extracted here for convenience,

```
Memory read bandwidth [MBytes/s]  | 31721.7327
Memory write bandwidth [MBytes/s] |  8014.1479
```

we see that `31721.7327 / 8014.1479 ≈ 4` times more reads have happened than writes. Naively, one would expect 3 loads and 1 store, i.e. a factor of 3 instead of 4 for the Schönauer Triad `a[i] = b[i] + c[i] * d[i]`. The additional load is due to the write allocate (`a` must be loaded before it can be written to).

If we know that write allocates happen (as is usually the case), we can pass `write_allocate=true` to `bwbench` to account for the extra loads. In this case, we obtain the following table
```julia
┌──────────┬─────────────┬────────────────┬───────────┬───────────┬───────────┐
│ Function │ Rate (MB/s) │ Rate (MFlop/s) │  Avg time │  Min time │  Max time │
│   String │     Float64 │        Float64 │   Float64 │   Float64 │   Float64 │
├──────────┼─────────────┼────────────────┼───────────┼───────────┼───────────┤
│     Init │     38150.7 │            0.0 │ 0.0506281 │ 0.0503267 │ 0.0508563 │
│     Copy │     40560.1 │            0.0 │ 0.0712144 │ 0.0710057 │ 0.0714202 │
│   Update │     37862.3 │        2366.39 │ 0.0512318 │ 0.0507101 │   0.05211 │
│    Triad │     40979.8 │        2561.24 │ 0.0945374 │ 0.0937046 │ 0.0949424 │
│    Daxpy │     40347.0 │        3362.25 │ 0.0719729 │ 0.0713808 │   0.07248 │
│   STriad │     41754.5 │        2087.73 │  0.115761 │  0.114958 │  0.117923 │
│   SDaxpy │     41276.1 │        2579.75 │  0.093708 │ 0.0930321 │ 0.0949028 │
└──────────┴─────────────┴────────────────┴───────────┴───────────┴───────────┘
```

Note that there are no write allocates for `Update`, `Daxpy`, and `SDaxpy`.

## `bwscaling`

Use `bwscaling()` to measure the memory bandwidth for an increasing number of threads (`1:max_nthreads`).

**Keyword arguments:**

* `max_nthreads` (default: `Threads.nthreads()`): upper limit for the number of threads to be used

```
julia> using BandwidthBenchmark

julia> bwscaling();
1 Thread(s): SDaxpy Bandwidth (MB/s) is 13056.6
Threading enabled, using 2 (of 10) Julia threads
2 Thread(s): SDaxpy Bandwidth (MB/s) is 24059.99
Threading enabled, using 3 (of 10) Julia threads
3 Thread(s): SDaxpy Bandwidth (MB/s) is 31227.01
Threading enabled, using 4 (of 10) Julia threads
4 Thread(s): SDaxpy Bandwidth (MB/s) is 35209.16
Threading enabled, using 5 (of 10) Julia threads
5 Thread(s): SDaxpy Bandwidth (MB/s) is 37343.37
Threading enabled, using 6 (of 10) Julia threads
6 Thread(s): SDaxpy Bandwidth (MB/s) is 39221.6
Threading enabled, using 7 (of 10) Julia threads
7 Thread(s): SDaxpy Bandwidth (MB/s) is 39725.92
Threading enabled, using 8 (of 10) Julia threads
8 Thread(s): SDaxpy Bandwidth (MB/s) is 40308.3
Threading enabled, using 9 (of 10) Julia threads
9 Thread(s): SDaxpy Bandwidth (MB/s) is 40321.78
Threading enabled, using 10 (of 10) Julia threads
10 Thread(s): SDaxpy Bandwidth (MB/s) is 40969.97


Scaling results:
┌───────────┬─────────────────────────┐
│ # Threads │ SDaxpy Bandwidth (MB/s) │
├───────────┼─────────────────────────┤
│       1.0 │                 13056.6 │
│       2.0 │                 24060.0 │
│       3.0 │                 31227.0 │
│       4.0 │                 35209.2 │
│       5.0 │                 37343.4 │
│       6.0 │                 39221.6 │
│       7.0 │                 39725.9 │
│       8.0 │                 40308.3 │
│       9.0 │                 40321.8 │
│      10.0 │                 40970.0 │
└───────────┴─────────────────────────┘
```

## `flopsscaling`

Since we also estimate the MFlops/s for our streaming kernels, we can also investigate the scaling of the floating point performance for increasing number of threads (`1:max_nthreads`). The function `flopsscaling` does exactly that based on the Triad kernel.

**Keyword arguments:**

* `max_nthreads` (default: `Threads.nthreads()`): upper limit for the number of threads to be used

### Compact vs Scattered Pinning:

Using `flopsscaling`, we can, for example, benchmark and compare the performance of different thread pinning scenarios:

* Compact Pinning: fill physical cores chronologically, i.e. first socket first, second socket second.
* Scattered Pinning: fill both sockets simultaneously, i.e. alternating between first and second socket

```
                                Compact Pinning              
                  +----------------------------------------+ 
            10000 |                                        | 
                  |                                      ./| 
                  |                                    ./  | 
                  |                                ..-"    | 
                  |                              .*'       | 
                  |                           .-/`         | 
                  |                         _*`            | 
   MFlops/s       |                      .r"               | 
                  |           ..  .__._.-'                 | 
                  |        _-"'"""`  `                     | 
                  |      ./                                | 
                  |     .`                                 | 
                  |    r`                                  | 
                  |   /                                    | 
             1000 |  /                                     | 
                  +----------------------------------------+ 
                   0                                     20  
                                    # cores            
```

```
                                Scattered Pinning              
                  +----------------------------------------+ 
            10000 |                                        | 
                  |                    .  .,  /\..*\. .\..r| 
                  |                   .'**`\..`     \/  "' | 
                  |               ,\ .`     \`             | 
                  |               . \.                     | 
                  |            . ,`  `                     | 
                  |          ./'..                         | 
   MFlops/s       |         ./   `                         | 
                  |        ./                              | 
                  |       .`                               | 
                  |      .`                                | 
                  |     /`                                 | 
                  |    /                                   | 
                  |   /                                    | 
             1000 |  /                                     | 
                  +----------------------------------------+ 
                   0                                     20  
                                    # cores                  
```

## References

* [TheBandwidthBenchmark](https://github.com/RRZE-HPC/TheBandwidthBenchmark) by RRZE-HPC Erlangen
* Sister package [STREAMBenchmark.jl](https://github.com/JuliaPerf/STREAMBenchmark.jl)
* [LIKWID](https://github.com/RRZE-HPC/likwid) and [LIKIWD.jl](https://github.com/JuliaPerf/LIKWID.jl)
