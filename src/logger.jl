const DEFAULT_LEVEL = 1
const DEFAULT_WIDTH = 10

struct EntrySpec
    type::DataType  
    fmt::String     # C-style format string
    uid::UInt16     # unique ID, corresponds to the order the entry was added
    lvl::UInt8      # verbosity level. 0 always prints.  Higher number -> lower priority
    width::UInt8    # column width in characters
    ccrayon::ConditionalCrayon
end
EntrySpec(T::DataType, fmt::String, eid, lvl=DEFAULT_LEVEL, width=DEFAULT_WIDTH; 
    ccrayon=ConditionalCrayon()) = EntrySpec(T, fmt, UInt16(eid), UInt8(lvl), UInt8(width), ccrayon)

Base.@kwdef mutable struct LoggerOpts
    curlevel::UInt8 = DEFAULT_LEVEL
    freq::UInt16 = 10                 # how often header prints
    _count::UInt16 = 0                # internal counter
    headerstyle::Crayon = crayon"bold blue"
    linechar::Char = '—'
    enable::Bool = true
end

"""
    SolverLogger.Logger

A logger designed to print tabulated data that can be updated at any point. 
It supports varying verbosity levels, each including all of the information 
from previous levels. 

# Constructor

    SolverLogger.Logger(; opts...)

Where `opts` are one of the following keyword arguments:

* `curlevel` Current verbosity level of the solver. A non-negative integer.
* `freq` A non-negative integer specifying how often the header row should be printed.
* `headerstyle` A `Crayon` specifying the style of the header.
* `linechar` A `Char` that is used for the deliminating row underneath the header. Set to `\0` to not print a row below the header.
* `enable` Enabled/disabled state of the logger at construction.

# Typical Usage
The fields to be printed are specified before use via [`setentry`](@ref). Here the
user can specify properties of the field such as the width of the column, format 
specifications (such as number of decimal places, numeric format, alignment, etc.),
column index, and even conditional formatting via a [`ConditionalCrayon`](@ref).
Each field is assigned a fixed verbosity level, and is only printed if the current
verbosity level of the logger, set via [`setlevel!`](@ref) is greater than or equal 
to the level of the field.

Once all the fields for the logger have been specified, typical usage is via the 
[`@log`](@ref) macro:

    @log logger "iter" 1
    @log logger "cost" cost * 10  # supports expressions
    @log logger "alpha" alpha
    @log logger alpha             # shortcut for the previous 

All calls to `@log` overwrite any previous data. Data is only stored in the logger 
if the field is active at the current verbosity.

To print the log, the easiest is via the [`printlog`](@ref) function, which will 
automatically print the header rows for you, at the frequency specified by 
`logger.opts.freq`. The period can be reset (printing a header at the next call to 
`printlog`) via [`resetcount!`](@ref). For more control, the header and rows can 
be printed directly via [`printheader`](@ref) and [`printrow`](@ref).

The logger can be completely reset via [`resetlogger!`](@ref).

# Enabling / Disabling
The logger can be enable/disabled via `SolverLogging.enable` and `SolverLogging.disable`.
This overwrites the verbosity level.

# Default logger
Most methods that take a `SolverLogging.Logger` as the first argument (including `@log`)
support omitting the logger, in which case the default logger stored in the `SolverLogging`
module is used.
"""
struct Logger
    fmt::Dict{String,EntrySpec}  # Collection of entry specifications. UID for each entry is automatically assigned
    fmtfun::Dict{String,Function}
    idx::Vector{Int16}  # determines column order. idx[id] gives the column for entry with id.
    data::Vector{String}
    crayons::Vector{Crayon}
    defaults::Dict{DataType,String}
    opts::LoggerOpts
end
function Logger(; opts...)
    fmt = Dict{String,EntrySpec}()
    fmtfun = Dict{String,Function}()
    idx = UInt16[]
    data = String[]
    crayons = Crayon[]
    defaults = _default_formats()
    Logger(fmt, fmtfun, idx, data, crayons, defaults, LoggerOpts(; opts...))
end

isenabled(log::Logger) = log.opts.enable
enable(log::Logger) = log.opts.enable = true
disable(log::Logger) = log.opts.enable = false 

function _default_formats()
    Dict(
        AbstractFloat => "%.2e",
        AbstractString => "%s",
        Integer => "%d",
        Any => "%s"   # default to string printing
    )
end


"""
    empty!(log::Logger)

Clears out all data from logger and restores it to the default configuration.
Users should prefer to use [`resetlogger!`](@ref) which calls this function.
"""
function Base.empty!(log::Logger)
    empty!(log.fmt)
    empty!(log.fmtfun)
    empty!(log.idx) 
    empty!(log.data) 
    empty!(log.defaults) 
    merge!(log.defaults, _default_formats()) 
    return log
end

"""
    resetcount!(logger)

Resets the row counter such that the subsequent call to [`printlog`](@ref) will 
print a header row, and start the count from that point.
"""
resetcount!(log::Logger) = log.opts._count = 0

"""
    resetlogger!(logger)

Resets the logger to the default configuration. All current data will be lost, including
all fields and default formats.
"""
resetlogger!(log::Logger) = begin empty!(log); resetcount!(log) end

"""
    _log!(logger, name, val)

Internal method for logging a value with the logger. Users should prefer to use the
[`@log`](@ref) macro. If `name` is a registered field, `val` will be stored in the logger.

Internally, this method converts `val` to a string using the format specifications
and calculates the color using the [`ConditionalCrayon`](@ref) for the entry.
"""
function _log!(log::Logger, name::String, val)
    if haskey(log.fmt, name)
        espec = log.fmt[name]
        if espec.lvl <= log.opts.curlevel
            idx = log.idx[espec.uid]
            fun = log.fmtfun[espec.fmt]
            crayon = espec.ccrayon(val)
            log.data[idx] = rpad(log.fmtfun[espec.fmt](val), espec.width)
            log.crayons[idx] = crayon
            if length(log.data[idx]) > espec.width
                @warn "Entry for $name ($(log.data[idx])) is longer than field width ($(espec.width)). Alignment may be affected. Try increasing the field width."
            end
        end
        return nothing
    end
end

"""
    setlevel!(logger, lvl)

Set the verbosity level for the logger. High levels prints more information.
Returns the previous verbosity level.
"""
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

"""
    printheader(logger)

Prints the header row(s) for the logger, including only the entries that are active
at the current verbosity level. The style of the header can be changed via 
`logger.opts.headerstyle`, which is a Crayon that applies to the entire header.
The repeated character under the header can be specified via `logger.opts.linechar`.
This value can be set to the null character `\0` if this line should be excluded.
"""
function printheader(log::Logger)
    isenabled(log) || return 
    header = formheader(log)
    println(log.opts.headerstyle(header))
    if log.opts.linechar != 0
        println(log.opts.headerstyle(repeat(log.opts.linechar, length(header))))
    end
    return nothing 
end

"""
    formheader(logger)

Outputs the header as a string
"""
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

"""
    printrow(logger)

Prints the data currently stored in the logger. Any entries with a 
[`ConditionalCrayon`](@ref) will be printed in the specified color.
Only prints the data for the current verbosity level.
"""
function printrow(log::Logger)
    isenabled(log) || return 
    # row = formrow(log)
    # println(row)
    for (c,v) in zip(log.crayons,log.data)
        print(c,v)
    end
    println()
    log.opts._count += 1
    return nothing
end

"""
    formrow(logger)

Outputs the data for the current verbosity level as a string.
"""
function formrow(log::Logger)
    row = "" 
    for v in log.data
        row *= v
    end
    return row 
end

"""
    printlog(logger)

Prints the data currently in the logger, automatically printing the header 
at the frequency specified by `logger.opts.freq`.

The period of the header can be reset using [`resetcount`](@ref).
"""
function printlog(log::Logger)
    cnt, freq = log.opts._count, log.opts.freq
    if cnt % freq == 0
        printheader(log)
        resetcount!(log)
    end
    printrow(log)
end

# Gets the index of the field `name`
@inline getidx(log::Logger, name::String) = log.idx[log.fmt[name].uid]
