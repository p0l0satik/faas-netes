make build
kind load docker-image --name dev-openfaas openfaas/faas-netes:latest

helm upgrade openfaas --recreate-pods openfaas/openfaas \
    --namespace openfaas  \
    --set basic_auth=true \
    --set openfaasImagePullPolicy=IfNotPresent \
    --set faasnetes.imagePullPolicy=IfNotPresent \
    --set gateway.imagePullPolicy=IfNotPresent \
    --set gateway.image=openfaas/gateway:latest-dev \
    --set faasnetes.image=openfaas/faas-netes:latest \
    --set functionNamespace=openfaas-fn




