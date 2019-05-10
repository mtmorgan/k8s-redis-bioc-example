6 May, 2019

# Work in progress: current state

Recent updates

- Re-organized files for easier build & deploy

## Create Docker image

From the root directory of this repository, start, e.g., minikube

    minikube start

or other k8s host.

Build an _R_ worker docker file -- this is from
`rocker/rstudio:3.6.0`, _R_, _RStudio_ server, and [RedisParam][]. If
one were implementing a particularly workflow, likely it would be
built from a more complete image like [Bioconductor/AnVIL_Docker][]
customized with required packages.

    eval \$(minikube docker-env)
    docker build -t bioc-redis docker/

If this were the google cloud, then the `bioc-redis` image would need to
be on Dockerhub or similar.

[RedisParam]: https://github.com/mtmorgan/RedisParam
[Bioconductor/AnVIL_Docker]: https://github.com/Bioconductor/AnVIL_Docker

## Create kubernetes components

In kubernetes, create a redis service and running redis application,
an _RStudio_ service, an _RStudio_ 'manager', and five _R_ worker
'jobs'.

    kubectl apply -f k8s/

The two services, redis and manager pods, and worker pods should all
be visible and healthy with

    kubectl get all

## Log in to R

Connect to R at the command line with

    kubectl exec -it manager -- /bin/bash

or via your browser at the ip address returned by

    minicube ip

and port 30001, e.g.,

    http://192.168.99.101:30001

this will provide access to RStudio, with user `rstudio` and password
`bioc`.

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

    p <- RedisParam(workers = 5, jobname = "demo", is.worker = FALSE)
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

    $ kubectl delete -f k8s/

# TODO

A little further work will remove the need to create the
`RedisParam()` in the R session.

The create / delete steps can be coordinated by a [helm] chart, so
that a one-liner will give a URL to a running RStudio backed by
arbitary number of workers.

[helm]: https://helm.sh/
