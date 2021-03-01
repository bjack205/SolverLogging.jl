const DEFAULT_LEVEL = 1
const DEFAULT_WIDTH = 10

struct EntrySpec
    fmt::String   # C-style format string
    uid::UInt16   # unique ID, corresponds to the order the entry was added
    lvl::UInt8    # verbosity level. 0 always prints.  Higher number -> lower priority
    width::UInt8  # column width in characters
end
EntrySpec(fmt::String, eid, lvl=DEFAULT_LEVEL, width=DEFAULT_WIDTH) = EntrySpec(fmt, UInt16(eid), UInt8(lvl), UInt8(width))

Base.@kwdef mutable struct LoggerOpts
    curlevel::UInt8 = DEFAULT_LEVEL
end

struct Logger
    fmt::Dict{String,EntrySpec}
    fmtfun::Dict{String,Function}
    idx::Vector{Int16}
    data::Vector{String}
    defaults::Dict{DataType,String}
    opts::LoggerOpts
end
function Logger(; opts...)
    fmt = Dict{String,EntrySpec}()
    fmtfun = Dict{String,Function}()
    idx = UInt16[]
    data = String[]
    defaults = _default_formats()
    Logger(fmt, fmtfun, idx, data, defaults, LoggerOpts(; opts...))
end

function _log!(log::Logger, name::String, val)
    if haskey(log.fmt, name)
        espec = log.fmt[name]
        if espec.lvl <= log.opts.curlevel
            idx = log.idx[espec.uid]
            fun = log.fmtfun[espec.fmt]
            log.data[idx] = rpad(log.fmtfun[espec.fmt](val), espec.width)
            if length(log.data[idx]) > espec.width
                @warn "Entry for $name ($(log.data[idx])) is longer than field width ($(espec.width)). Alignment may be affected. Try increasing the field width."
            end
        end
        return nothing
    end
end

function setlevel!(log::Logger, lvl)
    prevlvl = log.opts.curlevel
    log.opts.curlevel = lvl

    # Reset all levels that are no longer active
    for (k,v) in pairs(log.fmt)
        idx = log.idx[v.uid]
        if v.lvl > lvl
            log.data[idx] = ""
        end
    end
    return prevlvl
end

function printheader(log::Logger)
    header = formheader(log)
    printstyled(header, bold=true, color=:blue)
    println()
    printstyled(repeat("—",length(header)), bold=true, color=:blue)
end

function formheader(log::Logger)
    names = fill("", length(log.idx))
    for (k,v) in pairs(log.fmt)
        idx = log.idx[v.uid]
        if v.lvl <= log.opts.curlevel
            names[idx] = rpad(k, v.width)
        end
    end
    header = ""
    for name in names
        header *= name
    end
    return header 
end

function printrow(log::Logger)
    row = formrow(log)
    println(row)
end

function formrow(log::Logger)
    row = "" 
    for v in log.data
        row *= v
    end
    return row 
end

@inline getidx(log::Logger, name::String) = log.idx[log.fmt[name].uid]