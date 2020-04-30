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
SolverLogging.add_col!(logger.leveldata[InnerLoop], :first, 10, 0)

# Add another field
with_logger(logger) do
    @logmsg InnerLoop :iter value=2 width=4
    @logmsg InnerLoop :cost value=0.9 width=10
    @logmsg InnerLoop :first value=2 width=10 loc=1
end
print_header(logger, InnerLoop)
print_level(InnerLoop, logger)
