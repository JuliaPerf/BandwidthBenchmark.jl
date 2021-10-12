# -------- Benchmarks --------
struct Benchmark
    label::String
    words::Int64 # bytes = words * sizeof(Float64) * N
    flops::Int64
    write_alloc_factor::Float64 # bytes = words * write_alloc_factor * sizeof(Float64) * N
end

const BENCHMARKS = [
    Benchmark("Init", 1, 0, 2.0),
    Benchmark("Copy", 2, 0, 3/2),
    Benchmark("Update", 2, 1, 1.0),
    Benchmark("Triad", 3, 2, 4/3),
    Benchmark("Daxpy", 3, 2, 1.0),
    Benchmark("STriad", 4, 2, 5/4),
    Benchmark("SDaxpy", 4, 2, 1.0)
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
        @inbounds a[i] = b[i] + d[i] * c[i]
    end
    return nothing
end

function sdaxpy_kernel(a, b, c)
    @threads :static for i in eachindex(a)
        @inbounds a[i] = a[i] + b[i] * c[i]
    end
    return nothing
end


# -------- Kernel (first `nthreads` threads) --------
function init_kernel_fewer(a, scalar; thread_indices, nthreads)
    @threads :static for tid in 1:nthreads
        @inbounds for i in thread_indices[tid]
            a[i] = scalar
        end
    end
    return nothing
end

function copy_kernel_fewer(a, b; thread_indices, nthreads)
    @threads :static for tid in 1:nthreads
        @inbounds for i in thread_indices[tid]
            a[i] = b[i]
        end
    end
    return nothing
end

function update_kernel_fewer(a, scalar; thread_indices, nthreads)
    @threads :static for tid in 1:nthreads
        @inbounds for i in thread_indices[tid]
            a[i] = a[i] * scalar
        end
    end
    return nothing
end

function triad_kernel_fewer(a, b, c, scalar; thread_indices, nthreads)
    @threads :static for tid in 1:nthreads
        @inbounds for i in thread_indices[tid]
            a[i] = b[i] + scalar * c[i]
        end
    end
    return nothing
end

function daxpy_kernel_fewer(a, b, scalar; thread_indices, nthreads)
    @threads :static for tid in 1:nthreads
        @inbounds for i in thread_indices[tid]
            a[i] = a[i] + scalar * b[i]
        end
    end
    return nothing
end

function striad_kernel_fewer(a, b, c, d; thread_indices, nthreads)
    @threads :static for tid in 1:nthreads
        @inbounds for i in thread_indices[tid]
            a[i] = b[i] + d[i] * c[i]
        end
    end
    return nothing
end

function sdaxpy_kernel_fewer(a, b, c; thread_indices, nthreads)
    @threads :static for tid in 1:nthreads
        @inbounds for i in thread_indices[tid]
            a[i] = a[i] + b[i] * c[i]
        end
    end
    return nothing
end