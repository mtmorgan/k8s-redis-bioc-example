library(RedisParam)

p <- RedisParam(workers = 5, jobname = "demo", is.worker = FALSE)

fun <- function(i) {
    Sys.sleep(1)
    Sys.info()[["nodename"]]
}

system.time({                     # 13 seconds / 5 workers = 3 seconds
    res <- bplapply(1:13, fun, BPPARAM = p)
})

table(unlist(res))                # each worker slept 2 or 3 times
