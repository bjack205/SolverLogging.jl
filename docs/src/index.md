# SolverLogging.jl

## Overview
This package provides a logger that is designed for use in iterative solvers.
The logger presents data in a tabulated format, with each line representing 
the data from an iteration of the solver. The key features of this package are:

* The ability to handle different verbosity levels. Assumes each verbosity level 
  contains all information from previous levels. Allows the user to scale the 
  information based on current needs.

* Precise control over output formatting. The location, column width, and entry
  formatting for each field can be controlled.

* Color printing to the terminal thanks to [Crayons.jl](https://github.com/KristofferC/Crayons.jl)

* Conditional formatting that allows values to be automatically formatted 
  based on a the current value.

## Quickstart
To use the logger provided by the package, start by specifying the fields
you want to log:

```@example quickstart; continue=true
using SolverLogging
lg = SolverLogging.Logger()
SolverLogging.resetlogger!(lg)  # good idea to always reset the global logger
setentry(lg, "iter", Int, width=5)
setentry(lg, "cost")
setentry(lg, "info", String, width=25) 
setentry(lg, "α", fmt="%6.4f")  # sets the numeric formatting
setentry(lg, "ΔJ", index=-2)    # sets it to penultimate column
setentry(lg, "tol", level=2)    # sets it to verbosity level 2  (prints less often)
```
After specifying the data we want to log, we log the data using the [`@log`](@ref)
macro:
```@example quickstart; continue=true
@log lg "iter" 1
@log lg "cost" 10.2
```
Note this macro allows expressions:
```@example quickstart; continue=true
dJ = 1e-3
str = "Some Error Code: "
@log lg "ΔJ" dJ
@log lg "info" str * string(10)
```
As a convenient shortcut, we if the local variable name matches the name of the field
we can just pass the local variable and the name will be automatically extracted:
```@example quickstart; continue=true
iter = 2
@log lg iter 
```
To print the output use [`printlog`](@ref),
which will automatically handle printing the header lines. Here we call it in a loop,
updating the iteration field each time:
```@example quickstart; continue=false
for iter = 1:15
    @log lg iter
    printlog(lg)
end
```


## API
See the [API](@ref api_section) page for details on how to use the logger in your application.

## Examples
See the [Examples](@ref) page for a few example to help you get started.