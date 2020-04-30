using SolverLogging
using Logging

# Create Empy Levels
logger = SolverLogger(InnerLoop)
add_level!(logger, InnerLoop, print_color=:green, indent=4)
add_level!(logger, OuterLoop, print_color=:yellow)

# Dynamically add to the solver output
with_logger(logger) do
    @logmsg InnerLoop :iter value=1 width=4
    @logmsg InnerLoop :cost value=10.2 width=10
    @logmsg InnerLoop :violation value=0.2 width=12
    @logmsg InnerLoop "first iteration"
end
print_level(InnerLoop, logger)

with_logger(logger) do
    @logmsg InnerLoop :iter value=2 width=4
    @logmsg InnerLoop :violation value=0.1 width=12
end
print_row(logger, InnerLoop)

# Add another field
with_logger(logger) do
    @logmsg InnerLoop :iter value=3 width=4
    @logmsg InnerLoop :violation value=0.1 width=6
    @logmsg InnerLoop :first value=2 width=10 loc=2
end
print_header(logger, InnerLoop)
print_row(logger, InnerLoop)

with_logger(logger) do
    @logmsg OuterLoop :iter value=1 width=4
    @logmsg OuterLoop :total value=4 width=4
    @logmsg OuterLoop "outer loop"
    @logmsg OuterLoop "something happened"
end
print_header(logger, OuterLoop)
print_row(logger, OuterLoop)

@info "Something interesting"
