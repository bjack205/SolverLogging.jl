
function setentry(log::Logger, name::String, ::Type{T}=Float64; 
        fmt::String=default_format(log, name, T), 
        index::Integer=default_index(log, name), 
        lvl=default_level(log, name),
        width::Integer=default_width(log, name, fmt)
    ) where T
    @assert width > 0 "Field width must be positive"

    # Check if index is valid
    newentry = !haskey(log.fmt, name)
    index == 0 && error("Index can't be zero. Must be positive or negative")
    if length(log.data) == 0 && abs(index) == 1 
        index = 1
    elseif index < 0 
        if index >= -length(log.data)
            index = length(log.data) + index + 1 + newentry  # add one to the end
        else
            error("Invalid index. Negative indices must be greater than $(-length(log.data))")
        end
    elseif index > length(log.data)
        error("Invalid index. Must be less than $(length(log.data))")
    end

    # Check if the field already exists
    if haskey(log.fmt, name)
        espec = log.fmt[name]
        fid = espec.uid
        oldindex = log.idx[fid]

        # Shift data 
        if oldindex != index
            shiftswap!(log.data, index, oldindex)
            shiftidx!(log.idx,  fid, index) 
        end

        if fmt != espec.fmt || lvl != espec.lvl || width != espec.width || T != espec.type
            log.fmt[name] = EntrySpec(T, fmt, fid, lvl, width)
        end
    else
        # Insert new field
        fid = length(log.idx) + 1
        insert!(log.data, index, "")
        push!(log.idx, fid)
        shiftidx!(log.idx, fid, index)

        # Set field format and index
        log.fmt[name] = EntrySpec(T, fmt, fid, lvl, width)
    end

    # Add formatter if it doesn't exist
    if !haskey(log.fmtfun, fmt)
        log.fmtfun[fmt] = generate_formatter(fmt)
    end
    return 
end

function default_index(log::Logger, name::String)
    if haskey(log.fmt, name)
        uid = log.fmt[name].uid
        return log.idx[uid]::Int16
    end
    Int16(-1)
end

function default_level(log::Logger, name::String)
    if haskey(log.fmt, name)
        return log.fmt[name].lvl::UInt8
    end
    UInt8(DEFAULT_LEVEL)
end

function default_width(log::Logger, name::String, fmt::String)::UInt8
    if haskey(log.fmt, name)
        width = log.fmt[name].width::UInt8
    else
        width = getwidth(fmt)
        if width <= 0
            width = DEFAULT_WIDTH
        else
            width += 1
        end
    end
    return UInt8(max(length(name) + 1, width))
end

# Default Formatting
function default_format(log::Logger, name::String, ::Type{T}) where T
    if haskey(log.fmt, name)
        return log.fmt[name].fmt
    end
    _getformat(log.defaults, T)
end
default_format(log::Logger, ::Type{T}) where T = _getformat(log.defaults, T)

function set_default_format(log::Logger, ::Type{T}, fmt::String) where T
    log.defaults[T] = fmt
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