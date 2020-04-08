export dense,
       dims,
       dim

#
# Tools for working with Dims/Tuples
# TODO: put this in a seperate file
#

# dim and dims are used in the Tensor interface, overload 
# base Dims here
dims(ds::Dims) = ds
dims(::Tuple{}) = ()
dense(ds::Dims) = ds
dense(::Type{DimsT}) where {DimsT<:Dims} = DimsT
dim(ds::Dims) = prod(ds)
dim(ds::Dims,i::Int) = dims(ds)[i]

Base.ndims(::Dims{N}) where {N} = N
Base.ndims(::Type{Dims{N}}) where {N} = N
Base.ndims(::Tuple{}) = 0
Base.ndims(::Type{Tuple{}}) = 0

mindim(inds) = (ndims(inds) == 0 ? 1 : minimum(dims(inds)))
diaglength(inds) = mindim(inds)

"""
strides(ds::Dims)

Get the strides of the dimensions.

This is unexported, call with Tensors.strides.
"""
strides(ds::Dims) = Base.size_to_strides(1, dims(ds)...)

"""
stride(ds::Dims, k::Int)

"""
stride(ds::Dims, k::Int) = strides(ds)[k]

# This is to help with some generic programming in the Tensor
# code (it helps to construct a Tuple(::NTuple{N,Int}) where the 
# only known thing for dispatch is a concrete type such
# as Dims{4})
similar_type(::Type{<:Dims},
             ::Type{Val{N}}) where {N} = Dims{N}

# This is to help with ITensor compatibility
dir(::Int) = 0

# This is to help with ITensor compatibility
dag(i::Int) = i

