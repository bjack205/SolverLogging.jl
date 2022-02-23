const DEFAULT_LEVEL = 1
const DEFAULT_WIDTH = 10

struct EntrySpec
    type::DataType  
    fmt::String     # C-style format string
    uid::UInt16     # unique ID, corresponds to the order the entry was added
    level::UInt8      # verbosity level. 0 always prints.  Higher number -> lower priority
    width::UInt8    # column width in characters
    ccrayon::ConditionalCrayon
end
EntrySpec(T::DataType, fmt::String, eid, level=DEFAULT_LEVEL, width=DEFAULT_WIDTH; 
    ccrayon=ConditionalCrayon()) = EntrySpec(T, fmt, UInt16(eid), UInt8(level), UInt8(width), ccrayon)

Base.@kwdef mutable struct LoggerOpts
    curlevel::UInt8 = DEFAULT_LEVEL
    freq::UInt16 = 10                 # how often header prints
    _count::UInt16 = 0                # internal counter
    headerstyle::Crayon = crayon"bold blue"
    linechar::Char = '—'
    enable::Bool = true
    autosize::Bool = true             # automatically expand columns
end

"""
    SolverLogger.Logger

A logger designed to print tabulated data that can be updated at any point. 
It supports varying verbosity levels, each including all of the information 
from previous levels. 

# Constructor

    SolverLogger.Logger(io=stdout; opts...)
    SolverLogger.Logger(filename; opts...)

The constructor can take either an `IO` object or a filename, in which case it will 
be opened with write permissions, replacing any existing contents.

The keyword arguments `opts` are one of the following:

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

"""
struct Logger
    io::IO
    fmt::Dict{String,EntrySpec}  # Collection of entry specifications. UID for each entry is automatically assigned
    fmtfun::Dict{String,Function}
    idx::Vector{Int16}  # determines column order. idx[id] gives the column for entry with id.
    data::Vector{String}
    crayons::Vector{Crayon}
    defaults::Dict{DataType,String}
    opts::LoggerOpts
end
function Logger(io::IO=Base.stdout; opts...)
    fmt = Dict{String,EntrySpec}()
    fmtfun = Dict{String,Function}()
    idx = UInt16[]
    data = String[]
    crayons = Crayon[]
    defaults = _default_formats()
    Logger(io, fmt, fmtfun, idx, data, crayons, defaults, LoggerOpts(; opts...))
end
Logger(filename::AbstractString; kwargs...) = Logger(open(filename, "w"); kwargs...)

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

function clear!(log::Logger)
    level = getlevel(log)
    for (k,v) in pairs(log.fmt)
        idx = log.idx[v.uid]
        if v.level > level
            log.data[idx] = ""
        else
            log.data[idx] = " "^v.width 
        end
    end
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
function _log!(log::Logger, name::String, val, op::Symbol=:replace)
    if haskey(log.fmt, name)
        espec = log.fmt[name]
        if espec.level <= log.opts.curlevel
            idx = log.idx[espec.uid]
            fun = log.fmtfun[espec.fmt]
            crayon = espec.ccrayon(val)
            if op == :replace
                log.data[idx] = rpad(log.fmtfun[espec.fmt](val), espec.width)
            elseif op == :append
                if espec.type <: AbstractString
                    data0 = rstrip(log.data[idx])
                    newdata = log.fmtfun[espec.fmt](string(val))
                    if all(isspace, data0)
                        data = newdata
                    elseif data0[end] == '.'
                        data = data0 * " " * newdata
                    else
                        data = data0 * ". " * newdata
                    end
                    log.data[idx] = rpad( data, espec.width)
                else
                    @warn "Cannot append to a non-string entry."
                end
            elseif op == :add
                if espec.type <: Number
                    data0 = parse(espec.type, rstrip(log.data[idx]))
                    log.data[idx] = rpad(log.fmtfun[espec.fmt](val + data0), espec.width)
                else
                    @warn "Cannot add to a non-numeric field. Use :append for strings."
                end
            end
            log.crayons[idx] = crayon
            @debug "Logging $name with value $val at index $idx"
            if length(log.data[idx]) > espec.width
                if log.opts.autosize
                    newwidth = round(Int, length(log.data[idx])*1.5)
                    setentry(log, name, width = newwidth)
                    log.opts._count = 0
                    log.data[idx] = rpad(log.data[idx], newwidth)
                else
                    @warn "Entry for $name ($(log.data[idx])) is longer than field width ($(espec.width)). Alignment may be affected. Try increasing the field width."
                end
            end
        else
            @debug "Not logging $name, level not high enough"
        end
        return nothing
    else
        @debug "Rejecting log for $name with value $val"
    end
end

"""
    getlevel(logger)

Gets the current verbosity level for the logger.
"""
getlevel(logger::Logger) = logger.opts.curlevel


"""
    setlevel!(logger, level)

Set the verbosity level for the logger. High levels prints more information.
Returns the previous verbosity level.
"""
function setlevel!(log::Logger, level)
    prevlvl = log.opts.curlevel
    log.opts.curlevel = level

    # Reset all levels that are no longer active
    for (k,v) in pairs(log.fmt)
        idx = log.idx[v.uid]
        if v.level > level
            log.data[idx] = ""
        else
            log.data[idx] = rpad(log.data[idx], v.width)
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
    _printheader(log.io, log)
    return nothing 
end
function _printheader(io::IOStream, log::Logger)
    header = formheader(log)
    println(io, header)
    if log.opts.linechar != '\0'
        println(io, repeat(log.opts.linechar, length(header)))
    end
end
function _printheader(io::IO, log::Logger)
    header = formheader(log)
    println(log.opts.headerstyle(header))
    if log.opts.linechar != '\0'
        println(log.opts.headerstyle(repeat(log.opts.linechar, length(header))))
    end
end

"""
    formheader(logger)

Outputs the header as a string
"""
function formheader(log::Logger)
    names = fill("", length(log.idx))
    for (k,v) in pairs(log.fmt)
        idx = log.idx[v.uid]
        if v.level <= log.opts.curlevel
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
    _printrow(log.io, log)
    log.opts._count += 1
    return nothing
end
function _printrow(io::IOStream, log::Logger)
    for v in log.data
        print(io,v)
    end
    println(io)
    flush(io)
end
function _printrow(io::IO, log::Logger)
    for (c,v) in zip(log.crayons, log.data)
        print(c,v)
    end
    println()
    flush(stdout)
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

The period of the header can be reset using [`resetcount!`](@ref).
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

_getdata(log::Logger, name::String) = log.data[getidx(log, name)]