function read_header!(io::IO, ::Type{T}) where {T<:MRCHeader}
    names = fieldnames(T)
    types = T.types
    offsets = fieldoffsets(T)
    bytes = read!(io, Array{UInt8}(undef, HEADER_LENGTH))
    bytes_ptr = pointer(bytes)
    vals = GC.@preserve bytes [
        convertfield(names[i], types[i], bytes_ptr + offsets[i]) for i in 1:length(offsets)
    ]
    header = T(vals...)
    return header
end

function read_extended_header!(io::IO, ::Type{T}, h::MRCHeader) where {T<:MRCExtendedHeader}
    exthead_length = h.nsymbt
    data = read!(io, Array{UInt8}(undef, exthead_length))
    return T(data)
end

function Base.read(io::IO, ::Type{T}) where {T<:MRCData}
    header = read_header!(io, MRCHeader)
    extendedheader = read_extended_header!(io, MRCExtendedHeader, header)
    d = MRCData(header, extendedheader)
    read!(io, d.data)
    return d
end

function Base.read(fn::AbstractString, ::Type{T}) where {T<:MRCData}
    return smartopen(io -> read(io, T), fn, "r")
end
