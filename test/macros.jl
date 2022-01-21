using SolverLogging
using Crayons
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
itr = 1
@log "iter" itr 
@log "cost" 10a
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
    local iter = i
    @log lg iter
    @log lg "cost" log(10*i)
    @log lg "tol" exp(-i)
    printlog(lg)
end

## Test output to a file
filename = joinpath(@__DIR__, "log.out")
lg = SolverLogging.Logger(filename)
setentry(lg, "iter", Int)
setentry(lg, "cost", Float64)
setentry(lg, "tol", Float64, level=2)
lg.opts.freq = 5
lg.opts.linechar = 0
iter = 1
for i = 1:10
    iter = i
    @log lg iter
    @log lg "cost" log(10*i)
    @log lg "tol" exp(-i)
    printlog(lg)
end
flush(lg.io)
@test lg.io isa IOStream
lines = readlines(filename)
@test length(lines) == 12
for i in (1,7)
    @test occursin("iter", lines[i])
    @test occursin("cost", lines[i])
    @test !occursin("tol", lines[i])
end
for i = 2:6
    @test occursin("$(i-1)", lines[i])
end
rm(filename)

## Test Condition formatting

ccrayon_tol = ConditionalCrayon(1e-6,Inf, reverse=false)

goodctrl = x->abs(x) < 1 
badctrl = x->abs(x) > 10
defcolor = crayon"208"  # the ANSI color for a dark orange. 
ccrayon_control = ConditionalCrayon(badctrl, goodctrl, defaultcolor=defcolor)

logger = SolverLogging.Logger()
setentry(logger, "iter", Int, width=5)
setentry(logger, "tol", Float64, ccrayon=ccrayon_tol)
setentry(logger, "ctrl", Float64, fmt="%.1f", ccrayon=ccrayon_control)

logger.fmt["iter"].ccrayon(10)
for iter = 1:10
    tol = exp10(-iter)
    ctrl = 0.1*(iter-1)*iter^2
    @log logger iter
    @log logger tol
    @log logger ctrl
    printlog(logger)
end
# cc = ConditionalCrayon(crayon"red", crayon"green", crayon"blue", 0, 10)
# println(cc(0))
# typeof(cc(5))