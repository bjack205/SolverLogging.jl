using SolverLogging
using Test
# using BenchmarkTools
# using Formatting

## API
# @field "α" Float64 fmt="%0.2f" index=1
# @log "α" 2.2
# @printlog

# SolverLogging.enable()
# SolverLogging.disable()

## Formatting defaults
lg = SolverLogging.Logger()
def = SolverLogging._default_formats() 
@test !haskey(def, Float64)

# Add a new entry
@test SolverLogging.default_format(lg, Float64) == def[AbstractFloat]
@test haskey(lg.defaults, Float64)

# Set default
@test !haskey(lg.defaults, Int)
SolverLogging.set_default_format(lg, Int, "%3d")
@test haskey(lg.defaults, Int)
@test SolverLogging.default_format(lg, Int) !== 
    SolverLogging.default_format(lg, Int32)
@test haskey(lg.defaults, Int32)

# Insert fields
@test length(lg.data) == 0
SolverLogging.newfield(lg, "alpha", Float64)
@test length(lg.data) == 1
@test lg.fmt["alpha"] == ("%3.2e",1)
@test lg.idx[1] == 1
@test SolverLogging.getidx(lg, "alpha") == 1
lg.data[1] = "alpha"

SolverLogging.newfield(lg, "iter", Int, fmt="%3d")
@test lg.fmt["iter"] == ("%3d",2)
@test length(lg.data) == 2
@test SolverLogging.getidx(lg, "iter") == 2
lg.data[2] = "iter"

# Insert twice
SolverLogging.newfield(lg, "iter", Int, fmt="%3d")
@test length(lg.data) == 2
@test lg.data[2] == "iter"
@test length(keys(lg.fmt)) == 2
@test lg.data == ["alpha","iter"]
@test SolverLogging.getidx(lg, "iter") == 2

# New string field
SolverLogging.newfield(lg, "info", String, index=1)
@test lg.fmt["info"] == ("%s",3)
@test SolverLogging.getidx(lg, "info") == 1
@test SolverLogging.getidx(lg, "alpha") == 2
@test SolverLogging.getidx(lg, "iter") == 3
lg.data[1] = "info"
@test lg.data == ["info", "alpha","iter"]

# Move an existing field (1 to 3)
SolverLogging.newfield(lg, "info", String, index=-1)
@test lg.fmt["info"] == ("%s",3)
@test lg.data == ["alpha","iter","info"]
@test lg.idx == [1,2,3]

# Add to 2nd to last field
SolverLogging.newfield(lg, "ϕ", Int32, index=-2)
@test lg.fmt["ϕ"] == (def[Integer],4)
lg.data[3] = "phi"
@test lg.data == ["alpha","iter","phi","info"]
@test lg.idx == [1,2,4,3]

# move and use new format (3 to 2)
SolverLogging.newfield(lg, "ϕ", Int32, index=-3, fmt="%5d")
@test lg.fmt["ϕ"] == ("%5d", 4)
@test lg.data == ["alpha","phi","iter","info"]
@test lg.idx == [1,3,4,2]

@test (@allocated SolverLogging.newfield(lg, "ϕ", Int32, index=-3, fmt="%5d")) == 0
@test (@allocated SolverLogging.newfield(lg, "ϕ", Int32, index=-3, fmt="%7d")) == 0

## Log values
SolverLogging._log(lg, "iter", 1)
@test lg.data[3] == "  1"
@test parse(Int,lg.data[3]) == 1
SolverLogging._log(lg, "iter", 200)
@test parse(Int,lg.data[3]) == 200 

SolverLogging._log(lg, "info", "hi there")
@test lg.data[4] == "hi there"