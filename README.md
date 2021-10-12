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

# `bwbench`

```
[pthread wrapper] 
[pthread wrapper] MAIN -> 0
[pthread wrapper] PIN_MASK: 0->1  1->2  2->3  3->4  4->5  5->6  6->7  
[pthread wrapper] SKIP MASK: 0xFFFFFFFFFFFFF801
	threadid 140662158194432 -> SKIP 
	threadid 140661888833280 -> core 1 - OK
	threadid 140661880440576 -> core 2 - OK
	threadid 140661871404800 -> core 3 - OK
	threadid 140661789554432 -> core 4 - OK
	threadid 140661772773120 -> core 5 - OK
	threadid 140661760186112 -> core 6 - OK
	threadid 140661735016192 -> core 7 - OK
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

# `bwscaling`

Possible Output:

```
Scaling results:
┌───────────┬─────────────────────────┐
│ # Threads │ SDaxpy Bandwidth (MB/s) │
├───────────┼─────────────────────────┤
│       1.0 │                 12984.4 │
│       2.0 │                 24013.0 │
│       3.0 │                 31780.1 │
│       4.0 │                 36674.6 │
│       5.0 │                 38757.0 │
│       6.0 │                 39721.9 │
│       7.0 │                 40127.3 │
│       8.0 │                 40238.4 │
│       9.0 │                 40084.9 │
│      10.0 │                 40545.9 │
└───────────┴─────────────────────────┘
```

## References

* [TheBandwidthBenchmark](https://github.com/RRZE-HPC/TheBandwidthBenchmark) by RRZE-HPC Erlangen
* Sister package [STREAMBenchmark.jl](https://github.com/JuliaPerf/STREAMBenchmark.jl)
