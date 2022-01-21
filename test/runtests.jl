using SolverLogging
using Test

@testset "Basics" begin
    include("basic.jl")
    include("utils.jl")
end

@testset "Macros" begin
    include("macros.jl")
end