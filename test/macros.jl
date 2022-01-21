using SolverLogging
using Test

## API
"""
@log "α" 2.2

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

a = 1+2
nm = "iter"
@log "iter" 2a
@log "cost" 10
@log "ΔJ" 1e-3
printheader()
SolverLogging.formrow(lg)
printrow()
@test lg.opts._count == 1
printrow()
@test lg.opts._count == 2

iter = 2
@log iter
lg.data
printlog()

SolverLogging.resetcount!()
for iter = 1:12
    @log iter
    printlog()
end
@test SolverLogging.isenabled()

println("\nNothing should print after this:")
SolverLogging.disable()
SolverLogging.resetcount!()
for iter = 1:12
    @log iter
    printlog()
end

# cc = ConditionalCrayon(crayon"red", crayon"green", crayon"blue", 0, 10)
# println(cc(0))
# typeof(cc(5))