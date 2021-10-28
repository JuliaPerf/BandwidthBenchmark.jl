# scatter threads between sockets, i.e. fill both sockets simultaneously
likwid-pin -s 0xffffffffffe00001 -c S:scatter julia --project -t20 --math-mode=fast scaling_flops.jl Scattered Pinning