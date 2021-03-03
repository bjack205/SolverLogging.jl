import Pkg; Pkg.activate(joinpath(@__DIR__,".."))
using SolverLogging
using Test

## API
"""
@field "α" Float64 fmt="%0.2f" index=1
@log "α" 2.2
@printlog

SolverLogging.enable()
SolverLogging.disable()
"""

##
SolverLogging.resetlogger!()
setentry("iter", Int64, width=5)
setentry("cost")
setentry("ΔJ")
setentry("α", fmt="%6.4f")
setentry("info", String)
lg = SolverLogging.DEFAULT_LOGGER
lg.fmt["iter"].fmt

a = 1+2
nm = "iter"
@log "iter" 2a
@log "cost" 10
@log "ΔJ" 1e-3
α = 2
@log α
@log "info" "Something" 
lg.data

printheader()
SolverLogging.formrow(lg)
printrow()
@test lg.opts._count == 1
printrow()
@test lg.opts._count == 2

for iter = 3:11
    @log iter
    printlog()
end

##
# struct ConditionalCrayon{T}
#     clo::Crayon
#     cmid::Crayon
#     chi::Crayon
#     lo::T
#     hi::T
# end

# function (c::ConditionalCrayon)(v)
#     if v < c.lo
#         c.clo(string(v))
#     elseif v <= c.hi
#         c.cmid(string(v))
#     else
#         c.chi(string(v))
#     end
# end

# cc = ConditionalCrayon(crayon"red", crayon"green", crayon"blue", 0, 10)
# println(cc(0))
# typeof(cc(5))