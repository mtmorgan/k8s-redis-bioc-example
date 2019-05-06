 5 May, 2019

# Work in progress: current state

From the root directory of this repository, start, e.g., minikube

    minikube start

or other k8s host.

Build an _R_ worker docker file -- this is from `rocker/r-ver:3.6.0`,
with [RedisParam][]. If one were implementing a particularly
workflow, likely it would be built from a more complete image like
[Bioconductor/AnVIL_Docker][] customized with required packages.

    eval \$(minikube docker-env)
    docker build -t r-redis R/

If this were the google cloud, then the `r-redis` image would need to
be on Dockerhub or similar.

[RedisParam]: https://github.com/mtmorgan/RedisParam
[Bioconductor/AnVIL_Docker]: https://github.com/Bioconductor/AnVIL_Docker

In kubernetes, create a redis service and running redis application

    kubectl create -f redis/redis-service.yaml
    kubectl create -f redis/redis-pod.yaml

Add five 'workers' based on this image

    kubectl create -f R/five-workers.yaml

Run another image as an interactive 'manager' node

    kubectl run manager --rm -it --image r-redis --image-pull-policy=Never -- \
        /bin/bash

At the bash prompt, launch R

    # R
    ...
    >

Define a simple function

    fun = function(i) {
        Sys.sleep(1)
        Sys.info()[["nodename"]]
    }

Create a `RedisParam` to connect to the job queue and communicate with
the workers, and use `BiocParallel::register()` to make this the
default back-end

    library(RedisParam)

    hostname = Sys.getenv("REDIS_SERVICE_HOST")
    port = as.integer(Sys.getenv("REDIS_SERVICE_PORT"))
    Sys.unsetenv("REDIS_PORT")

    p <- RedisParam(
        workers = 5, jobname = "demo", is.worker = FALSE,
        manager.hostname = hostname, manager.port = port
    )
    register(bpstart(p))

The need to specify `hostname`, `port`, and `jobname` will be smoothed
out; the need to create, start, and register `p` could be moved to,
e.g., a `.Rprofile` on the Docker image).

Use `bplapply()` for parallel evaluation

    system.time(res <- bplapply(1:13, fun))
    table(unlist(res))

Quit and exit when done, and clean up

    q()       # R
    # exit    # manager
    $ kubectl delete -f R/five-workers.yaml
    $ kubectl delete -f redis/redis-pod.yaml
    $ kubectl delete -f redis/redis-service.yaml
    
# TODO

It should be quite easy to instead connect to an RStudio on the
k8s-deployed Docker image through a web browser.

The create / delete steps can be coordinated by a [helm] chart, so
that a one-liner will give a URL to a running RStudio backed by
arbitary number of workers.

[helm]: https://helm.sh/
