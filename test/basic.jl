using SolverLogging
using Test
using Crayons
using SolverLogging: EntrySpec
# using BenchmarkTools # using Formatting
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
SolverLogging.setentry(lg, "alpha", Float64)
@test length(lg.data) == 1
@test lg.fmt["alpha"] == EntrySpec(Float64, def[AbstractFloat],1, 1, SolverLogging.DEFAULT_WIDTH)
@test lg.idx[1] == 1
@test SolverLogging.getidx(lg, "alpha") == 1
lg.data[1] = "alpha"

# Add an integer entry
SolverLogging.setentry(lg, "iter", Int, fmt="%10d")
@test lg.fmt["iter"] == EntrySpec(Int,"%10d",2,1,11)
@test length(lg.data) == 2
@test SolverLogging.getidx(lg, "iter") == 2
lg.data[2] = "iter"

# Insert twice
SolverLogging.setentry(lg, "iter", Int, fmt="%3d", index=2)
@test length(lg.data) == 2
@test lg.data[2] == "iter"
@test length(keys(lg.fmt)) == 2
@test lg.data == ["alpha","iter"]
@test SolverLogging.getidx(lg, "iter") == 2

# New string field
SolverLogging.setentry(lg, "info", String, index=1)
@test lg.fmt["info"] == EntrySpec(String,"%s",3)
@test SolverLogging.getidx(lg, "info") == 1
@test SolverLogging.getidx(lg, "alpha") == 2
@test SolverLogging.getidx(lg, "iter") == 3
lg.data[1] = "info"
@test lg.data == ["info", "alpha","iter"]

# Move an existing field (1 to 3)
SolverLogging.setentry(lg, "info", String, index=-1)
@test lg.fmt["info"] == EntrySpec(String,"%s",3)
@test lg.data == ["alpha","iter","info"]
@test lg.idx == [1,2,3]

# Change the width (not specifying type)
@test lg.fmt["alpha"].width == SolverLogging.DEFAULT_WIDTH 
SolverLogging.setentry(lg, "alpha", width=12)
@test lg.fmt["alpha"].width == 12

# Change the ccrayon and test
SolverLogging.setentry(lg, "alpha", ccrayon=ConditionalCrayon(1, 10))
entry = lg.fmt["alpha"]
@test entry.ccrayon(5) == Crayon(reset=true)
@test entry.ccrayon(0) == crayon"green"
@test entry.ccrayon(11) == crayon"red"

# Make sure it doesn't erase the previous crayon if another field is modified
SolverLogging.setentry(lg, "alpha", width=9)
entry = lg.fmt["alpha"]
@test entry.ccrayon(5) == Crayon(reset=true)
@test entry.ccrayon(0) == crayon"green"
@test entry.ccrayon(11) == crayon"red"

# Try adding new field without the type
@test_throws AssertionError SolverLogging.setentry(lg, "ϕ")

# Add to 2nd to last field
SolverLogging.setentry(lg, "ϕ", Int32, index=-2)
@test lg.fmt["ϕ"] == EntrySpec(Int32,def[Integer],4,1, 10) 
lg.data[3] = "phi"
@test lg.data == ["alpha","iter","phi","info"]
@test lg.idx == [1,2,4,3]

# move and use new format (3 to 2)
SolverLogging.setentry(lg, "ϕ", Int32, index=-3, fmt="%5d")
@test lg.fmt["ϕ"] == EntrySpec(Int32,"%5d", 4, 1, 10)
@test lg.data == ["alpha","phi","iter","info"]
@test lg.idx == [1,3,4,2]

# Change level
SolverLogging.setentry(lg, "ϕ", Int32, lvl=2)
@test lg.fmt["ϕ"] == EntrySpec(Int32,"%5d", 4, 2, 10)

# Change Width 
SolverLogging.setentry(lg, "ϕ", Int32, width=12) 
@test lg.fmt["ϕ"] == EntrySpec(Int32,"%5d", 4, 2, 12)

# @test (@allocated SolverLogging.setentry(lg, "ϕ", Int32, index=-3, fmt="%5d")) == 0

## Log values
SolverLogging._log!(lg, "iter", 1)
@test lg.data[3] == "  1        "
@test parse(Int,lg.data[3]) == 1
SolverLogging._log!(lg, "iter", 200)
@test parse(Int,lg.data[3]) == 200 

SolverLogging._log!(lg, "info", "hi there")
@test lg.data[4] == rpad("hi there", 10)

SolverLogging.setentry(lg, "alpha", Float64, width=6)
@test_logs (:warn,) SolverLogging._log!(lg, "alpha", 1e-3)
@test lg.data[1] == "1.00e-03"

SolverLogging.setentry(lg, "alpha", Float64, width=10)
SolverLogging._log!(lg, "alpha", 1e-3)
@test lg.data[1] == "1.00e-03  "
@test lg.crayons[1] == crayon"green"

# Move alpha and make sure the crayon moves too
SolverLogging.setentry(lg, "alpha", index=2)
@test lg.data[2] == "1.00e-03  "
@test lg.crayons[2] == crayon"green"

SolverLogging.setentry(lg, "alpha", index=1)

## Test printing and verbosity
SolverLogging.setlevel!(lg, 1)
@test lg.data[2] == ""
SolverLogging._log!(lg, "ϕ", 3)
@test lg.data[2] == ""
@test !occursin("ϕ", SolverLogging.formheader(lg))
@test length(SolverLogging.formrow(lg)) == 31
SolverLogging.printheader(lg)
for i = 1:10
    SolverLogging._log!(lg, "alpha", 2i-5)
    SolverLogging.printrow(lg)
end

@test SolverLogging.setlevel!(lg, 2) == 1
SolverLogging._log!(lg, "ϕ", 3)
@test lg.data[2] == rpad("    3", 12)
@test occursin("ϕ", SolverLogging.formheader(lg))
@test length(SolverLogging.formrow(lg)) == 43 

begin
    SolverLogging.printheader(lg)
    for i = 1:3
        SolverLogging._log!(lg, "iter", i)
        SolverLogging.printrow(lg)
    end
end

# Print a lower verbosity level and make sure there
# aren't any extra entries
@test SolverLogging.setlevel!(lg, 1) == 2
begin
    SolverLogging.printheader(lg)
    for i = 1:3
        SolverLogging._log!(lg, "alpha", 10(i-1)-5)
        SolverLogging._log!(lg, "iter", i)
        SolverLogging.printrow(lg)
    end
end
SolverLogging._log!(lg, "ϕ", 21.2)
header = SolverLogging.formheader(lg)
@test !occursin("ϕ", header)
row = SolverLogging.formrow(lg)
@test !occursin("21.5", row)
