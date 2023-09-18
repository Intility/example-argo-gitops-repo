#!/bin/bash

BLUE=$(tput setaf 4)
NORMAL=$(tput sgr0)
BRIGHT=$(tput bold)
COLOR=$BLUE
STAR='🌟 '

if ! command -v kind &> /dev/null
then
  echo "kind could not be found. Please install kind and try again."
  exit 1
fi

if ! kind create cluster --name my-cluster --config .local/kind-config.yaml
then
  echo "Failed to create kind cluster. Exiting..."
  exit 1
fi

if [[ $(kubectl config current-context) != "kind-my-cluster" ]]; then
  echo "Current context is not kind-my-cluster. Please switch to the correct context and try again."
  exit 1
fi

printf "\n%s%s%s\n" "$STAR" "$COLOR" "installing nginx ingress controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml || exit 1

printf "\n%s%s%s\n" "$STAR" "$COLOR" "waiting for ingress controller to get ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

printf "\n%s%s%s\n" "$STAR" "$COLOR" "installing argocd..."
kubectl apply -k .local/argo || exit 1

printf "\n%s%s%s\n" "$STAR" "$COLOR" "waiting for argocd to get ready..."
kubectl wait -n argocd \
  --for=condition=ready pod \
  --timeout=90s \
  --selector=app.kubernetes.io/name=argocd-server

argo_password=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
argo_host=$(kubectl -n argocd get ingress argocd-server-ingress -o jsonpath="{.spec.rules[0].host}")
argo_path=$(kubectl get ingress -n argocd argocd-server-ingress -o jsonpath="{.spec.rules[0].http.paths[0].path}")
printf "\nArgoCD now available at http://%s%s" "${argo_host:=localhost}" "$argo_path"
printf "\nusername: %sadmin%s" "${BRIGHT}" "${NORMAL}"
printf "\npassword: %s%s%s\n" "${BRIGHT}" "$argo_password" "${NORMAL}"

echo ""
echo "You can now create a bootstrap app by running 'kubectl apply -f .bootstrap/dev.yaml'"
