6 May, 2019

# Work in progress: current state

## Create Docker image

From the root directory of this repository, start, e.g., minikube

    minikube start

or other k8s host.

Build an _R_ worker docker file -- this is from
`rocker/rstudio:3.6.0`, R, RStudio server, and [RedisParam][]. If one
were implementing a particularly workflow, likely it would be built
from a more complete image like [Bioconductor/AnVIL_Docker][]
customized with required packages.

    eval \$(minikube docker-env)
    docker build -t bioc-redis R/

If this were the google cloud, then the `bioc-redis` image would need to
be on Dockerhub or similar.

[RedisParam]: https://github.com/mtmorgan/RedisParam
[Bioconductor/AnVIL_Docker]: https://github.com/Bioconductor/AnVIL_Docker

## Create kubernetes components

In kubernetes, create a redis service and running redis application

    kubectl create -f redis/redis-service.yaml
    kubectl create -f redis/redis-pod.yaml

Create an RStudio service to expose RStudio, and an R / RStudio instance

    kubectl create -f redis/rstudio-service.yaml
    kubectl create -f redis/manager-pod.yaml

Add five 'workers' based on this image

    kubectl create -f R/worker-jobs.yaml

## Log in to R

Connect to R at the command line with

    kubectl exec -it manager -- /bin/bash

or via your browser at the ip address returned by

    minicube ip

and the second port (30001 in this example) associated with the
rstudio-service

    kubectl get services rstudio-service
    ## NAME              TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
    ## rstudio-service   NodePort   10.106.213.234   <none>        8787:30001/TCP   5h44m

# Use

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

    p <- RedisParam(
        workers = 5, jobname = "demo", is.worker = FALSE,
        manager.hostname = hostname, manager.port = port
    )
    register(bpstart(p))

Use `bplapply()` for parallel evaluation

    system.time(res <- bplapply(1:13, fun))
    table(unlist(res))

## Clean up

Quit and exit the R manager (or simply leave your RStudio session in
the browser)

    > q()     # R
    # exit    # manager

Clean up kubernetes

    $ kubectl delete -f R/worker-jobs.yaml
    $ kubectl delete -f R/manager-pod.yaml
    $ kubectl delete -f R/rstudio-server.yaml
    $ kubectl delete -f redis/redis-pod.yaml
    $ kubectl delete -f redis/redis-service.yaml

# TODO

A little further work will remove the need to create the
`RedisParam()` in the R session.

The create / delete steps can be coordinated by a [helm] chart, so
that a one-liner will give a URL to a running RStudio backed by
arbitary number of workers.

[helm]: https://helm.sh/
