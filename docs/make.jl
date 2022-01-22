using Documenter
using SolverLogging

makedocs(
    sitename = "SolverLogging.jl",
    format = Documenter.HTML(
        prettyurls = !("local" in ARGS),
        ansicolor=true
    ),
    pages = [
        "Introduction" => "index.md",
        "API" => "api.md",
        "Examples" => "examples.md"
    ]
)

deploydocs(
    repo = "github.com/bjack205/SolverLogging.jl.git",
    devbranch = "master"
)