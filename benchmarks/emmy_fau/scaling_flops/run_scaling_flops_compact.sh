# compact pinning, i.e. fill sockets one after another.
JULIA_EXCLUSIVE=1 julia --project -t20 --math-mode=fast scaling_flops.jl Compact Pinning
# likwid-pin -s 0xffffffffffe00001 -c E:N:20 julia --project -t20 --math-mode=fast scaling_flops.jl Compact Pinning