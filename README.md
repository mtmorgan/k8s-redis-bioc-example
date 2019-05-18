18 May, 2019

# Work in progress: current state

Recent updates

- Use dockerhub images; separate 'manager' and 'worker'.
- Document use on gcloud
- Re-organized files for easier build & deploy

## Start minikube or gcloud

For minikube

    minikube start

for gcloud, see [below][].

[below]: #google-cloud-work-in-progress

## Create application in kubernetes

In kubernetes, create a redis service and running redis application,
an _RStudio_ service, an _RStudio_ 'manager', and five _R_ worker
'jobs'.

    kubectl apply -f k8s/

The two services, redis and manager pods, and worker pods should all
be visible and healthy with

    kubectl get all

## Log in to R

Via your browser on the port 300001 at the ip address returned by

    minicube ip

or on gcloud the "EXTERNAL-IP" address of any host

    kubectl get nodes --output wide

e.g.,

    http://192.168.99.101:30001

this will provide access to RStudio, with user `rstudio` and password
`bioc`. Alternatively, connect to R at the command line with

    kubectl exec -it manager -- /bin/bash

## Use

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

Stop minikube

    minikube stop

or `gcloud`

    gcloud container clusters delete [CLUSTER_NAME]

# Google cloud [WORK IN PROGRESS]

One uses Google kubernetes service rather than minikube. Make sure
that minikube is not running

    minikube stop

## Enable kubernetes service

Make sure the Kubernetes Engine API is enables by visiting
`https://console.cloud.google.com`.

Make sure the appropriate project is selected (dropdown in the blue
menu bar).

Choose `APIs & Services` the hamburger (top left) dropdown, and `+
ENABLE APIS & SERVICES` (center top).

## Configure gcloud

At the command line, make sure the correct account is activated and
the correct project associated with the account

    gcloud auth list
    gclod config list

Use `gcloud config help` / `gcloud config set help` and eventually
`gcloud config set core/project VALUE` to udpate the project and
perhaps other information, e.g., `compute/zone` and `compute/region`.

## Start and authenticate the gcloud kubernetes engine

A guide to [exposing applications][1] guide is available; we'll most
closely follow the section [Creating a Service of type NodePort][2].

Create a cluster (replace `[CLUSTER_NAME]` with an appropriate
identifier)

    gcloud container clusters create [CLUSTER_NAME]

Authenticate with the cluster

    gcloud container clusters get-credentials [CLUSTER_NAME]

Create a whole in the firewall that surrounds our cloud (30001 is from
k8s/rstudio-service.yaml)

    gcloud compute firewall-rules create test-node-port --allow tcp:30001

At this stage, we can use `kubectl apply ...` etc., as above.

[1]: https://cloud.google.com/kubernetes-engine/docs/how-to/exposing-apps
[2]: https://cloud.google.com/kubernetes-engine/docs/how-to/exposing-apps#creating_a_service_of_type_nodeport

# Docker images

Docker images for the manager and worker are available at dockerhub as
[mtmorgan/bioc-redis-manager][] and
[mtmorgan/bioc-redis-worker][]. They were built as

    docker build -t bioc-redis-worker -f docker/Dockerfile.worker docker
    docker build -t bioc-redis-manager -f docker/Dockerfile.manager docker

[mtmorgan/bioc-redis-manager]: https://cloud.docker.com/u/mtmorgan/repository/docker/mtmorgan/bioc-redis-manager
[mtmorgan/bioc-redis-worker]: https//cloud.docker.com/u/mtmorgan/repository/docker/mtmorgan/bioc-redis-worker

The _R_ manager docker file -- is from `rocker/rstudio:3.6.0`
providing _R_ _RStudio_ server, and additional infrastructure to
support [RedisParam][].  The _R_ worker docker file -- is from
`rocker/r-base:latest` providing _R_, and additional infrastructure to
support [RedisParam][].

If one were implementing a particularly workflow, likely the worker
(and perhaps manager) images would be built from a more complete image
like [Bioconductor/AnVIL_Docker][] customized with required packages.

[RedisParam]: https://github.com/mtmorgan/RedisParam
[Bioconductor/AnVIL_Docker]: https://github.com/Bioconductor/AnVIL_Docker

For use of local images, one needs to build these in the minikube environment

    eval $(minikube docker-env)
    docker build ...

# TODO

A little further work will remove the need to create the
`RedisParam()` in the R session.

The create / delete steps can be coordinated by a [helm] chart, so
that a one-liner will give a URL to a running RStudio backed by
arbitary number of workers.

[helm]: https://helm.sh/
