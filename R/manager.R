library(RedisParam)

host = Sys.getenv("REDIS_SERVICE_HOST")
port = as.integer(Sys.getenv("REDIS_SERVICE_PORT"))

p <- RedisParam(
    workers = 5, jobname = "demo", is.worker = FALSE,
    manager.hostname = host, manager.port = port
)

fun <- function(i) {
    Sys.sleep(1)
    Sys.info()[["nodename"]]
}

bpstart(p)
system.time({
    res <- bplapply(1:5, fun, BPPARAM = p)
})
bpstop(p)
