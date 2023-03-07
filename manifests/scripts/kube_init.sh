export USE_GKE_GCLOUD_AUTH_PLUGIN=True
gcloud container clusters get-credentials $1 --zone $2 --project $3
kubectl apply -f ../prod/namespace/namespace.yaml
kubectl apply -f ../prod/configMap/configMap.yaml
