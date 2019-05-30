# README

## INSTALL helm chart

Clone and install the helm chart to get going with the Bioc RedisParam on K8s.

### Quickstart

Clone the repo

	git clone https://github.com/mtmorgan/k8s-redis-bioc-example.git

Install the helm chart

	helm install k8s-redis-bioc-example/helm-chart/
	
Get list of running helm charts

	helm list <release name>

Get status of the installed chart

	helm status <release name>

### Requirements

1. Kubernetes cluster is running, i.e (either minikube on your local
   machine or a cluster in the cloud)
   
   This should work
   
		kubectl cluster-info 
	
		minikube start ## if you want to start a cluster

1. Have helm installed!! 

		brew install helm 

### Debug or dry run

Very useful options to check how the templates are forming,

`--dry-run` doesn't actually install the chart and run it.

	helm install --dry-run k8s-redis-bioc-example/helm-chart/

`--debug` prints out the templates with the values.yaml embedded in them

	helm install --dry-run --debug k8s-redis-bioc-example/helm-chart/

### User Settings

The defined user settings in the values.yaml file of the helm chart,
can be changed in two ways,

1. In the values.yaml file directly, where you can modify the Rstudio
   login password ``rstudioPassword`` and the number of workers you
   want to deploy `workerPoolSize`

		# user settings
		userSettings:
        # User setting: change the rstudio password on the manager
	       rstudioPassword: bioc
	    # User setting: change the number of workers in your cluster
	       workerPoolSize: 5
		   
1. The other way is while deploying the helm chart,

		helm install k8s-redis-bioc-example/helm-chart/ \
			--set userSettings.rstudioPassword=biocuser,userSettings.workerPoolSize=10 
