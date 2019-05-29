# README

## INSTALL helm chart

Clone and install the helm chart to get going with the Bioc RedisParam on K8s.

### Quickstart

	git clone https://github.com/nturaga/k8s-redis-bioc-chart.git

	helm install k8s-redis-bioc-chart

### Requirements

1. Kubernetes cluster is running, i.e (either minikube on your local
   machine or a cluster in the cloud)
   
   This should work
   
		kubectl cluster-info 
	
		minikube start ## if you want to start a cluster


1. Have helm installed!! 

		brew install helm 
