byteorder() = ifelse(Base.ENDIAN_BOM == 0x04030201, <, >)

"""
    padtruncto!(x::AbstractVector, n; value)

Pad `x` with `value` or truncate it until its length is exactly `n`.
"""
function padtruncto!(x, n; value = zero(eltype(x)))
    l = length(x)
    if l < n
        append!(x, fill(value, n - l))
    elseif l > n
        resize!(x, n)
    end
    return x
end

function checkmagic(io)
    magic = Base.read(io, 6)
    seek(io, 0)
    return if magic[1:3] == GZ_MAGIC
        :gz
    elseif magic[1:3] == BZ2_MAGIC
        :bz2
    elseif magic == XZ_MAGIC
        :xz
    else
        :none
    end
end

function checkextension(path)
    return if endswith(path, ".gz")
        :gz
    elseif endswith(path, ".bz2")
        :bz2
    elseif endswith(path, ".xz")
        :xz
    else
        :none
    end
end

function compresstream(io, type)
    return if type == :gz
        GzipCompressorStream(io)
    elseif type == :bz2
        Bzip2CompressorStream(io)
    elseif type == :xz
        XzCompressorStream(io)
    elseif type == :none
        io
    else
        throw(IOError("Unrecognized compression type"))
    end
end

function decompresstream(io, type)
    return if type == :gz
        GzipDecompressorStream(io)
    elseif type == :bz2
        Bzip2DecompressorStream(io)
    elseif type == :xz
        XzDecompressorStream(io)
    elseif type == :none
        io
    else
        throw(IOError("Unrecognized decompression type"))
    end
end
