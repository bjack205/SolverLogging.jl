const DEFAULT_LOGGER = Logger()

function setentry(name::String, ::Type{T}=Float64; kwargs...) where T
    return setentry(DEFAULT_LOGGER, name, T; kwargs...)
end

log_expr(name::String, ex) =_log_expr(DEFAULT_LOGGER, name, ex)
log_expr(ex::Symbol) = log_expr(DEFAULT_LOGGER, ex)

isenabled() = isenabled(DEFAULT_LOGGER)
enable() = enable(DEFAULT_LOGGER)
disable() = disable(DEFAULT_LOGGER)

resetcount!() = resetcount!(DEFAULT_LOGGER)
resetlogger!() = resetlogger!(DEFAULT_LOGGER)

printheader() = printheader(DEFAULT_LOGGER)
printrow() = printrow(DEFAULT_LOGGER)
printlog() = printlog(DEFAULT_LOGGER)