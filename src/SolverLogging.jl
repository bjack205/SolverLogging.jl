module SolverLogging
using Printf
using Formatting
using Crayons

include("utils.jl")
include("conditional_crayon.jl")
include("logger.jl")
include("default_logger.jl")
include("setentry.jl")

# Set entries in default logger
macro log(args...)
    return log_expr(args...)
end

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
        if isenabled($log)
            espec = $(log.fmt[name])
            if $(log.opts.curlevel) <= espec.lvl
                _log!($log, $name, $(esc(expr)))
            end
        end
    end
end

export 
    setentry,
    Logger,
    @log,
    printheader,
    printrow,
    printlog,
    ConditionalCrayon


end # module
