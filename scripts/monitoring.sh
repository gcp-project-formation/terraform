export USE_GKE_GCLOUD_AUTH_PLUGIN=True
gcloud container clusters get-credentials $1 --zone $2 --project $3
helm repo add grafana https://grafana.github.io/helm-charts && helm repo update
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install promo  prometheus-community/prometheus
helm install grafana grafana/grafana --set service.type=LoadBalancer,adminPassword=admin
 