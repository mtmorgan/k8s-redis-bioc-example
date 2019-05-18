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

    eval $ (minikube docker-env)
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

Via your browser at the ip address returned by

    minicube ip

and port 30001, e.g.,

    http://192.168.99.101:30001

this will provide access to RStudio, with user `rstudio` and password
`bioc`. Alternatively, connect to R at the command line with

    kubectl exec -it manager -- /bin/bash

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

# Google cloud [WORK IN PROGRESS]

There are two changes for use in the cloud. The docker image needs to
be publicly available. One uses Google kubernetes service rather than
minikube.

Make sure that minikube is not running

    minikube stop

## Docker image

The docker image needs to be publicly available -- replace

    image: bioc-redis

with

    image: mtmorgan/bioc-redis-test

in the files `k8s/manager-pod.yaml` and `k8s/worker-jobs.yaml`

Remove the line

    imagePullPolicy: Never
    
from both of these files.

## Kubernetes service

### Enable

Make sure the Kubernetes Engine API is enables by visiting
`https://console.cloud.google.com`.

Make sure the appropriate project is selected (dropdown in the blue
menu bar).

Choose `APIs & Services` the hamburger (top left) dropdown, and `+
ENABLE APIS & SERVICES` (center top).

### gcloud configuration

At the command line, make sure the correct account is activated and the correct project associated with the account

    gcloud auth list
    gclod config list
    
Use `gcloud config help` / `gcloud config set help` and eventually
`gcloud config set core/project VALUE` to udpate the project and
perhaps other information, e.g., `compute/zone` and `compute/region`.
    
### Start and authenticate the gcloud kubernetes engine

A guide to [exposing applications][1] guide is available; we'll most closely follow the section [Creating a Service of type NodePort][2].

Create a cluster (replace `[CLUSTER_NAME]` with an appropriate identifier)

    gcloud container clusters create [CLUSTER_NAME]
    
Authenticate with the cluster

    gcloud container clusters get-credentials [CLUSTER_NAME]
    
Create a whole in the firewall that surrounds our cloud (30001 is from
k8s/rstudio-service.yaml)

    gcloud compute firewall-rules create test-node-port --allow tcp:30001

[1]: https://cloud.google.com/kubernetes-engine/docs/how-to/exposing-apps
[2]: https://cloud.google.com/kubernetes-engine/docs/how-to/exposing-apps#creating_a_service_of_type_nodeport

### Start our application

Deploy our application to our cloud

    kubectl apply -f k8s/
    
Confirm that the deployment was successful (may take a minute or so...)

    kubectl get all
    
Find the external port of our service by looking for (any) IP address in the `EXTERNAL-IP` column of the output from

    kubectl get nodes --output wide

and connect to RStudio via the browser, e.g.,

    http://35.245.195.245:30001/
    
### Clean up

Delete the deployment

    kubectl delete -f k8s/
    
shut down the gcloud

    gcloud container clusters delete [CLUSTER_NAME]

# TODO

A little further work will remove the need to create the
`RedisParam()` in the R session.

The create / delete steps can be coordinated by a [helm] chart, so
that a one-liner will give a URL to a running RStudio backed by
arbitary number of workers.

[helm]: https://helm.sh/
