
struct Logger
    fmt::Dict{String,Tuple{String,UInt16}}
    fmtfun::Dict{String,Function}
    idx::Vector{UInt16}
    data::Vector{String}
    defaults::Dict{DataType,String}
end
function Logger()
    fmt = Dict{String,Tuple{String,UInt32}}()
    fmtfun = Dict{String,Function}()
    idx = UInt16[]
    data = String[]
    defaults = _default_formats()
    Logger(fmt, fmtfun, idx, data, defaults)
end

function _log(log::Logger, name::String, val)
    if haskey(log.fmt, name)
        fmt,fid = log.fmt[name]
        idx = log.idx[fid]
        fun = log.fmtfun[fmt]
        log.data[idx] = log.fmtfun[fmt](val)
    end
end

function newfield(log::Logger, name::String, ::Type{T}; 
        fmt::String=default_format(log, T), index::Integer=-1) where T

    # Check if index is valid
    index == 0 && error("Index can't be zero. Must be positive or negative")
    if length(log.data) == 0 && abs(index) == 1 
        index = 1
    elseif index < 0 
        if index >= -length(log.data)
            index = length(log.data) + index + 2
        else
            error("Invalid index. Negative indices must be greater than $(-length(log.data))")
        end
    elseif index > length(log.data)
        error("Invalid index. Must be less than $(length(log.data))")
    end

    # Check if the field already exists
    if haskey(log.fmt, name)
        index -= 1
        fmt0,fid = log.fmt[name]
        oldindex = log.idx[fid]

        # Shift data 
        if oldindex != index
            shiftswap!(log.data, index, oldindex)
            shiftidx!(log.idx,  fid, index) 
        end

        if fmt != fmt0
            log.fmt[name] = (fmt,fid)
        end
    else
        # Insert new field
        fid = length(log.idx) + 1
        insert!(log.data, index, "")
        push!(log.idx, fid)
        shiftidx!(log.idx, fid, index)

        # Set field format and index
        log.fmt[name] = (fmt, fid)
        if !haskey(log.fmtfun, fmt)
            log.fmtfun[fmt] = generate_formatter(fmt)
        end
    end
    return 
end

@inline getidx(log::Logger, name::String) = log.idx[log.fmt[name][2]]

function shiftswap!(a, inew, iold)
    if inew != iold
        v = a[iold]
        deleteat!(a, iold)
        insert!(a, inew, v)
    end
    return a
end

"""
Set idx[fid] = inew. After update, 
"""
function shiftidx!(idx, fid, inew) 
    iold = idx[fid]
    ilo = min(iold,inew)
    ihi = max(iold,inew)
    s = -sign(inew - iold)
    for j = 1:length(idx)
        if ilo <= idx[j] <= ihi
            idx[j] += s
        end
    end
    idx[fid] = inew
    return idx
end


function default_format(log::Logger, ::Type{T}) where T
    _getformat(log.defaults, T)
end

function set_default_format(log::Logger, ::Type{T}, fmt::String) where T
    log.defaults[T] = fmt
end

function _default_formats()
    Dict(
        AbstractFloat => "%3.2e",
        AbstractString => "%s",
        Integer => "%4d"
    )
end

function _getformat(fmt::Dict, ::Type{T}) where T
    if haskey(fmt, T) 
        return fmt[T]
    else
        return _newdefault(fmt, T)
    end
end

function _newdefault(fmt::Dict, ::Type{T}) where T
    Tsuper = Any 
    for (k,v) in pairs(fmt)
        if (T <: k) && (k <: Tsuper)
            Tsuper = k
        end
    end
    fmt[T] = fmt[Tsuper]
end