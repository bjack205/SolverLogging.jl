module SolverLogging
using Printf
using Formatting
using Crayons

include("utils.jl")
include("logger.jl")
include("setentry.jl")

# Set entries in default logger
function setentry(name::String, ::Type{T}=Float64; kwargs...) where T
    return setentry(DEFAULT_LOGGER, name, T; kwargs...)
end

macro log(args...)
    return log_expr(args...)
end

# Use default logger
log_expr(name::String, ex) =_log_expr(DEFAULT_LOGGER, name, ex)
log_expr(ex::Symbol) = log_expr(DEFAULT_LOGGER, ex)

# Use the symbol as the string name 
# e.g. `@log α`` logs the value of α in the "α" field
function log_expr(log::Logger, ex::Symbol)
    name = string(ex)
    _log_expr(log, name, ex)
end

# Pass-through to actual function
log_expr(log::Logger, name::String, ex) = _log_expr(log, name, ex)


function _log_expr(log::Logger, name::String, expr)
    quote
        espec = $(log.fmt[name])
        if $(log.opts.curlevel) <= espec.lvl
            _log!($log, $name, $(esc(expr)))
        end
    end
end


export 
    setentry,
    Logger,
    @log,
    printheader,
    printrow,
    printlog


end # module
