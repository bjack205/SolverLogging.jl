module SolverLogging
using Printf
using Formatting
using Crayons

include("utils.jl")
include("logger.jl")
include("setentry.jl")

function setentry(name::String, ::Type{T}=Float64; kwargs...) where T
    return setentry(DEFAULT_LOGGER, name, T; kwargs...)
end

macro log(args...)
    return log_expr(args...)
end

function log_expr(name::String, ex)
    return _log_expr(DEFAULT_LOGGER, name, ex)
end

log_expr(ex::Symbol) = log_expr(DEFAULT_LOGGER, ex)
function log_expr(log::Logger, ex::Symbol)
    name = string(ex)
    _log_expr(log, name, ex)
end

function log_expr(log::Logger, name::String, ex)
    return _log_expr(log, name, ex)
end


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
