module SolverLogging
using Printf
using Formatting

include("utils.jl")
include("logger.jl")
include("setentry.jl")

macro log(log::Logger, name::String, expr)
    quote
        espec = log.fmt[name]
        if log.opts.curlevel <= espec.lvl
            _log!(log, name, $(esc(expr)))
        end
    end
end


end # module
