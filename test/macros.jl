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
cost = 12.0
@log cost 
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

println("\nNothing should print between this line...")
SolverLogging.disable()
SolverLogging.resetcount!()
for iter = 1:12
    @log iter
    printlog()
end
println("...and this line")

## Use a local logger
lg = SolverLogging.Logger()
setentry(lg, "iter", Int)
setentry(lg, "cost", Float64)
setentry(lg, "tol", Float64, level=2)
lg.opts.freq = 5
lg.opts.linechar = 0
lg.opts.headerstyle = crayon"yellow"
iter = 1
for i = 1:10
    iter = i
    @log lg iter
    @log lg "cost" log(10*i)
    @log lg "tol" exp(-i)
    printlog(lg)
end

## Test output to a file
# filename = joinpath(@__DIR__, "log.out")
# lg = SolverLogging.Logger(filename)
# setentry(lg, "iter", Int)
# setentry(lg, "cost", Float64)
# setentry(lg, "tol", Float64, level=2)
# lg.opts.freq = 5
# lg.opts.linechar = 0
# iter = 1
# for i = 1:10
#     iter = i
#     @log lg iter
#     @log lg "cost" log(10*i)
#     @log lg "tol" exp(-i)
#     printlog(lg)
# end
# close(lg.io)
# lg.io isa IOStream

# cc = ConditionalCrayon(crayon"red", crayon"green", crayon"blue", 0, 10)
# println(cc(0))
# typeof(cc(5))