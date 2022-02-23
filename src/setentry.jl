
"""
    setentry(logger, name::String, type; kwargs...)

Used to add a new entry/field or modify an existing entry/field in the `logger`.

# Adding a new entry
Specify a unique `name` to add a new entry to the logger. The `type` is used to provide 
reasonable formatting defaults and must be included. The keyword arguments control 
the behavior/formatting of the field:
* `fmt` A C-style format string used to control the format of the field
* `index` Column for the entry in the output. Negative numbers insert from the end.
* `level` Verbosity level for the entry. A higher level will be printed less often.
        Level 0 will always be printed, unless the logger is disabled. Prefer to use 
        a minimum level of 1.
* `width` Width of the column. Data is left-aligned to this width.
* `ccrayon` A [`ConditionalCrayon`](@ref) for conditional formatting.

# Modified an existing entry
This method can also modify an existing entry, if `name` is already a field int the logger.
The `type` can be omitted in this case. Simply specify any of the keyword arguments 
with the new setting.
"""
function setentry(log::Logger, name::String, type::Type{T}=Float64; 
        fmt::String=default_format(log, name, T), 
        index::Integer=default_index(log, name), 
        level=default_level(log, name),
        width::Integer=default_width(log, name, fmt),
        ccrayon=nothing
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
            shiftswap!(log.crayons, index, oldindex)
            shiftidx!(log.idx,  fid, index) 
        end

        if isnothing(ccrayon)
            ccrayon = espec.ccrayon
        end

        if fmt != espec.fmt || level != espec.level || width != espec.width || 
            ccrayon != espec.ccrayon
            log.fmt[name] = EntrySpec(espec.type, fmt, fid, level, width, ccrayon)
        end
    else
        @assert type != Nothing "Must specify type for a new field"

        # Insert new field
        fid = length(log.idx) + 1
        insert!(log.data, index, " "^width)
        insert!(log.crayons, index, Crayon(reset=true))
        push!(log.idx, fid)
        shiftidx!(log.idx, fid, index)

        if isnothing(ccrayon)
            ccrayon = ConditionalCrayon()
        end

        # Set field format and index
        log.fmt[name] = EntrySpec(T, fmt, fid, level, width, ccrayon)
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
        return log.fmt[name].level::UInt8
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

"""
    set_default_format(logger, type, fmt)

Set the default format for entries type type is a sub-type of `type`. For example:

    set_default_format(logger, AbstractFloat, "%0.2d")

Will print all floating point fields with 2 decimal places. The most format for the 
type closest to the default is always chosen, such that if we specified 

    set_default_format(logger, Float64, "%0.1d")

This would override the previous behavior for `Float64`s.

"""
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