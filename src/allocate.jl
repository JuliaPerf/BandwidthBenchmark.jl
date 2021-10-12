# posix_memalign taken from
# https://discourse.julialang.org/t/julia-alignas-is-there-a-way-to-specify-the-alignment-of-julia-objects-in-memory/57501/2
function allocate(::Type{T}, n::Integer, alignment::Integer) where {T}
    ispow2(alignment) || throw(ArgumentError("$alignment is not a power of 2"))
    alignment ≥ sizeof(Int) || throw(ArgumentError("$alignment is not a multiple of $(sizeof(T))"))
    isbitstype(T) || throw(ArgumentError("$T is not a bitstype"))
    p = Ref{Ptr{T}}()
    err = ccall(:posix_memalign, Cint, (Ref{Ptr{T}}, Csize_t, Csize_t), p, alignment, n*sizeof(T))
    iszero(err) || throw(OutOfMemoryError())
    return unsafe_wrap(Array, p[], n, own=true)
end