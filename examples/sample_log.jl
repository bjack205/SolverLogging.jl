using SolverLogging
using Logging
using Plots

# Create the logger and specify the logged values
logger = SolverLogger(InnerLoop)

inner_cols = [:iter, :cost, :violation]
inner_widths = [5, 14, 14]
inner_types = [Int, Float64, Float64]
outer_cols = [:iter, :total, :c_max]
outer_widths = [10, 10, 10]
outer_types = [Int, Int, Float64]
add_level!(logger, InnerLoop, inner_cols, inner_widths, inner_types, print_color=:green, indent=4)
add_level!(logger, OuterLoop, outer_cols, outer_widths, outer_types, print_color=:yellow, indent=0)


# Print some inner loop info
with_logger(logger) do
    @logmsg InnerLoop :iter value=1
    @logmsg InnerLoop :cost value=10.2
    @logmsg InnerLoop :violation value=0.2
    @logmsg InnerLoop "first iteration"
end

print_header(logger, InnerLoop)
print_row(logger, InnerLoop)

with_logger(logger) do
    @logmsg InnerLoop :iter value=2
    @logmsg InnerLoop :cost value=9.0
end

print_row(logger, InnerLoop)

# Print an outer loop
with_logger(logger) do
    @logmsg OuterLoop :iter value=0
    @logmsg OuterLoop :total value=1
end
print_level(OuterLoop, logger)

# Print another inner loop, adding a new field
with_logger(logger) do
    @logmsg InnerLoop :iter value=3
    @logmsg InnerLoop :cost value=5.0
    @logmsg InnerLoop :violation value=0.1
    @logmsg InnerLoop "first iteration"
    @logmsg InnerLoop :new value=10
end
print_header(logger, InnerLoop)
print_level(InnerLoop, logger)

# Get the cached data
iters = logger.leveldata[InnerLoop].cache[:iter]
cost = logger.leveldata[InnerLoop].cache[:cost]
viol = logger.leveldata[InnerLoop].cache[:violation]
plot(iters, cost)
scatter(iters, viol)
