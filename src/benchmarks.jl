# -------- Types --------
@enum Bench begin
    INIT
    COPY
    UPDATE
    TRIAD
    DAXPY
    STRIAD
    SDAXPY
end
Base.to_index(b::Bench) = Int(b)+1

struct Benchmark
    label::String
    words::Int
    flops::Int
end

const BENCHMARKS = [
    Benchmark("Init:       ", 1, 0),
    Benchmark("Copy:       ", 2, 0),
    Benchmark("Update:     ", 2, 1),
    Benchmark("Triad:      ", 3, 2),
    Benchmark("Daxpy:      ", 3, 2),
    Benchmark("STriad:     ", 4, 2),
    Benchmark("SDaxpy:     ", 4, 2)
]
const NBENCH = length(BENCHMARKS)

# -------- Kernel (all threads) --------
function init_kernel(a, scalar)
    @threads :static for i in eachindex(a)
        @inbounds a[i] = scalar
    end
    return nothing
end

function copy_kernel(a, b)
    @threads :static for i in eachindex(a)
        @inbounds a[i] = b[i]
    end
    return nothing
end

function update_kernel(a, scalar)
    @threads :static for i in eachindex(a)
        @inbounds a[i] = a[i] * scalar
    end
    return nothing
end

function triad_kernel(a, b, c, scalar)
    @threads :static for i in eachindex(a)
        @inbounds a[i] = b[i] + scalar * c[i]
    end
    return nothing
end

function daxpy_kernel(a, b, scalar)
    @threads :static for i in eachindex(a)
        @inbounds a[i] = a[i] + scalar * b[i]
    end
    return nothing
end

function striad_kernel(a, b, c, d)
    @threads :static for i in eachindex(a)
        a[i] = b[i] + d[i] * c[i]
    end
    return nothing
end

function sdaxpy_kernel(a, b, c)
    @threads :static for i in eachindex(a)
        @inbounds a[i] = a[i] + b[i] * c[i]
    end
    return nothing
end


# -------- Kernel (pool of threads) --------
function init_kernel_pool(a, scalar)
    @threads :static for i in eachindex(a)
        @inbounds a[i] = scalar
    end
    return nothing
end

function copy_kernel_pool(a, b)
    @threads :static for i in eachindex(a)
        @inbounds a[i] = b[i]
    end
    return nothing
end

function update_kernel_pool(a, scalar)
    @threads :static for i in eachindex(a)
        @inbounds a[i] = a[i] * scalar
    end
    return nothing
end

function triad_kernel_pool(a, b, c, scalar)
    @threads :static for i in eachindex(a)
        @inbounds a[i] = b[i] + scalar * c[i]
    end
    return nothing
end

function daxpy_kernel_pool(a, b, scalar)
    @threads :static for i in eachindex(a)
        @inbounds a[i] = a[i] + scalar * b[i]
    end
    return nothing
end

function striad_kernel_pool(a, b, c, d)
    @threads :static for i in eachindex(a)
        @inbounds a[i] = b[i] + d[i] * c[i]
    end
    return nothing
end

function sdaxpy_kernel_pool(a, b, c)
    @threads :static for i in eachindex(a)
        @inbounds a[i] = a[i] + b[i] * c[i]
    end
    return nothing
end


# -------- Kernel (no threads) --------
function init_kernel_nothreads(a, scalar)
    for i in eachindex(a)
        @inbounds a[i] = scalar
    end
    return nothing
end

function copy_kernel_nothreads(a, b)
    for i in eachindex(a)
        @inbounds a[i] = b[i]
    end
    return nothing
end

function update_kernel_nothreads(a, scalar)
    for i in eachindex(a)
        @inbounds a[i] = a[i] * scalar
    end
    return nothing
end

function triad_kernel_nothreads(a, b, c, scalar)
    for i in eachindex(a)
        @inbounds a[i] = b[i] + scalar * c[i]
    end
    return nothing
end

function daxpy_kernel_nothreads(a, b, scalar)
    for i in eachindex(a)
        @inbounds a[i] = a[i] + scalar * b[i]
    end
    return nothing
end

function striad_kernel_nothreads(a, b, c, d)
    for i in eachindex(a)
        @inbounds a[i] = b[i] + d[i] * c[i]
    end
    return nothing
end

function sdaxpy_kernel_nothreads(a, b, c)
    for i in eachindex(a)
        @inbounds a[i] = a[i] + b[i] * c[i]
    end
    return nothing
end