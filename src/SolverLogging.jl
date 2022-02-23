module SolverLogging
using Printf
using Formatting
using Crayons
using Logging

include("utils.jl")
include("conditional_crayon.jl")
include("logger.jl")
# include("default_logger.jl")
include("setentry.jl")

# Set entries in default logger
"""
    @log [logger] args...

Logs the data with `logger`, which is the default logger if not provided.
Can be any of the following forms:

    @log "name" 1.0    # literal value
    @log "name" 2a     # an expression
    @log "name" name   # a variable
    @log name          # shortcut for previous

If the specified entry is active at the current verbosity level, 
"""
macro log(args...)
    return log_expr(args...)
end

# Use the symbol as the string name 
# e.g. `@log α`` logs the value of α in the "α" field
function log_expr(logger, ex::Symbol)
    name = string(ex)
    _log_expr(logger, name, ex)
end

# Pass-through to actual function
log_expr(logger, name::String, ex) = _log_expr(logger, name, ex)
log_expr(logger, name::String, ex, op::QuoteNode) = _log_expr(logger, name, ex, op)

function _log_expr(logger, name::String, expr, op::QuoteNode=QuoteNode(:replace))
    quote
        let lg = $(esc(logger))
            # @debug "Calling @log on $name"
            if isenabled(lg)
                # espec = lg.fmt[$name]
                # if lg.opts.curlevel <= espec.level
                _log!(lg, $name, $(esc(expr)), $op)
                # end
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
    setlevel!,
    ConditionalCrayon

end # module
