library(RedisParam)
hostname = Sys.getenv("REDIS_SERVICE_HOST")
port = as.integer(Sys.getenv("REDIS_SERVICE_PORT"))
Sys.unsetenv("REDIS_PORT")

p <- RedisParam(
    jobname = "demo", is.worker = TRUE,
    manager.hostname = hostname, manager.port = port
)

bpstart(p)

