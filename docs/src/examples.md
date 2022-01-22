# [Examples](@id examples_section)

```@meta
CurrentModule = SolverLogging
```

## Setting up a Logger
The [Quickstart](@ref) used the default logger provided by this package. It's 
usually a better idea to have your own local logger you can use, to avoid 
possible conflicts. 

!!! tip
    You can extract the default logger by accessing it directly at `SolverLogger.DEFAULT_LOGGER`

```@example quickstart; continue=true
using SolverLogging
logger = SolverLogging.Logger()
setentry(logger, "iter", Int, width=5)
setentry(logger, "cost")
setentry(logger, "dJ", level=2)
setentry(logger, "info", String, width=25)
```
We can change a few things about the behavior of our logger by accessing the 
logger options. Here we change the header print frequency to print every 5 
iterations instead of the default 10, eliminate the line under the header, and
set the header to print in bold yellow:

```@example quickstart; continue=false
using Crayons
logger.opts.freq = 5
logger.opts.linechar = '\0'
logger.opts.headerstyle = crayon"bold yellow";
```

If we set the verbosity to 1 and print, we'll see that it doesn't print the `dJ`
field:

```
setlevel!(logger, 1)
Jprev = 100
for iter = 1:3
    global Jprev
    J = 100/iter
    @log logger iter
    @log logger "cost" J
    @log logger "dJ" Jprev - J  # note this is disregarded
    Jprev = J
    if iter == 5
        @log logger "info" "Last Iteration"
    end
    printlog(logger)
end
```
If we change the verbosity to 2, we now see `dJ` printed out:
```
setlevel!(logger, 2)  # note the change to 2
Jprev = 100
for iter = 1:5
    global Jprev
    J = 100/iter
    @log logger iter
    @log logger "cost" J
    @log logger "dJ" Jprev - J
    Jprev = J
    if iter == 5
        @log logger "info" "Last Iteration"
    end
    printlog(logger)
end
```
Note how the new output doesn't start with a header, since it's continuing the 
count from before. We can change this by resetting the count with [`resetcount!`](@ref):
```
setlevel!(logger, 1)               # note the change back to 1
SolverLogging.resetcount!(logger)  # this resets the print count
Jprev = 100
for iter = 1:5
    global Jprev
    J = 100/iter
    @log logger iter
    @log logger "cost" J
    @log logger "dJ" Jprev - J
    Jprev = J
    if iter == 5
        @log logger "info" "Last Iteration"
    end
    printlog(logger)
end
```
So that, as you can see, we now get a nice output with the header at the top. By 
changing the verbosity level back to 1, you see that it got rid of the `dJ` column 
again.

## Conditional Formatting
In this example we cover how to use the conditional formatting. Lets say we have a
field `tol` that we want below `1e-6`. We also have another field `control` that 
we want to be "good" if it's absolute value is less than 1, and "bad" if it's 
greater than 10.

We create 2 [`ConditionalCrayon`](@ref) types to encode this behavior. Our first one
can be covered using the constructor that takes a `lo` and `hi` value:
```
using SolverLogging
ccrayon_tol = ConditionalCrayon(1e-6,Inf, reverse=false)
nothing # hide
```
Which by default will consider any values less than `lo` good and any values greater
than `hi` bad. We can reverse this with the optional `reverse` keyword.

For our control formatting, let's say we want it to print orange if it's absolute 
value is in between 1 and 10 and cyan if it's less than 1:

```
using Crayons
goodctrl = x->abs(x) < 1 
badctrl = x->abs(x) > 10
lowcolor = crayon"blue"
defcolor = crayon"208"  # the ANSI color for a dark orange. 
ccrayon_control = ConditionalCrayon(badctrl, goodctrl, 
    defaultcolor=defcolor, goodcolor=crayon"cyan")
nothing # hide
```

!!! tip
    Use `Crayons.test_256_colors()` to generate a sample of all the ANSI color codes.

We can now specify these when we set up our fields:
```
logger = SolverLogging.Logger()
setentry(logger, "iter", Int, width=5)
setentry(logger, "tol", Float64, ccrayon=ccrayon_tol)
setentry(logger, "ctrl", Float64, fmt="%.1f", ccrayon=ccrayon_control)
```
We should see the desired behavior when we print out some test values:
```
for iter = 1:10
    tol = exp10(-iter)
    ctrl = 0.1*(iter-1)*iter^2
    @log logger iter
    @log logger tol
    @log logger ctrl
    printlog(logger)
end
``` 


## Saving to a File
Instead of writing to `stdout`, we can write a to a file. This interface is exactly
the same, but we pass a filename or an `IOStream` to the logger when we create it:
```
using SolverLogging
filename = "log.out"
logger = SolverLogging.Logger(filename)
```
Note that this will automatically open the file with read privileges, overwritting 
any contents in the file. The stream is flushed after every write so it should 
populate the contents of the file in real time.