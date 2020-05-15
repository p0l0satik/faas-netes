#!/bin/bash


kind create cluster --name dev-openfaas

kubectl rollout status deploy coredns --watch -n kube-system

# INSTALLING HELM
kubectl -n kube-system create sa tiller \
  && kubectl create clusterrolebinding tiller \
  --clusterrole cluster-admin \
  --serviceaccount=kube-system:tiller

helm init --skip-refresh --upgrade --service-account tiller

# SETUP REQUIRED NAMESPACES
kubectl apply -f https://raw.githubusercontent.com/openfaas/faas-netes/master/namespaces.yml

# CONFIGURE BASIC AUTH
export PASSWORD="tester"
kubectl -n openfaas create secret generic basic-auth \
--from-literal=basic-auth-user=admin \
--from-literal=basic-auth-password="$PASSWORD"

# INSTALL OPENFAAS VIA HELM
helm repo add openfaas https://openfaas.github.io/faas-netes/
helm repo update

kubectl rollout status deploy tiller-deploy --watch -n kube-system


helm upgrade openfaas --install openfaas/openfaas \
    --namespace openfaas  \
    --set basic_auth=true \
    --set functionNamespace=openfaas-fn
kubectl rollout status deploy gateway --watch -n openfaas

echo ""
echo "OpenFaaS started!"
printf '%-15s:\t %s\n' "Username" "admin"
printf '%-15s:\t %s\n' "Password" "tester"
printf '%-15s:\t %s\n' "CLI run" "faas-cli login --username admin --password tester --gateway http://localhost:31112"
echo ""

## In a new terminal
kubectl -n openfaas port-forward deploy/gateway 31112:8080
