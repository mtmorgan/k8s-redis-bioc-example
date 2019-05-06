 5 May, 2019
 
# start

    minikube start
    
# create redis

    kubectl create -f redis/redis-service.yaml
    kubectl create -f redis/redis-pod.yaml
    
# build R worker

    eval \$(minikube docker-env)
    docker build -t r-redis R/
    
# create and delete 5 R workers

create (deploy)

    kubectl create -f R/five-workers.yaml

delete

    kubectl delete -f R/five-workers.yaml
    
# deploy master

demo

    kubectl run manager --rm -it --image r-redis --image-pull-policy=Never -- \
        R -f manager.R
        
interactive -- start bash shell, run R, then interactively enter
commands as in `R/manager.R`.

    kubectl run manager --rm -it --image r-redis --image-pull-policy=Never -- \
        /bin/bash
    R
    
