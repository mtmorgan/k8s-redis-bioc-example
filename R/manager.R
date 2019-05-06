library(RedisParam)
hostname = Sys.getenv("REDIS_SERVICE_HOST")
port = as.integer(Sys.getenv("REDIS_SERVICE_PORT"))
Sys.unsetenv("REDIS_PORT")

p <- RedisParam(
    workers = 5, jobname = "demo", is.worker = FALSE,
    manager.hostname = hostname, manager.port = port
)

bpstart(p)
while (TRUE) {
    print(system.time({
        res <- bplapply(1:5, function(...) {
            Sys.sleep(1)
            system("hostname", intern=TRUE)
        }, BPPARAM = p)
        print(table(unlist(res)))
    }))
}
bpstop(p)
