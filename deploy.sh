#!/usr/bin/env bash

set -e

[[ "$TRACE" ]] && set -x

function ensure_namespace() {
    echo "$KUBE_NAMESPACE"
    kubectl get namespace "$KUBE_NAMESPACE" || kubectl create namespace "$KUBE_NAMESPACE"
    exit 0
}

function create_secret() {
  echo "Create secret..."
  if [[ "$CI_PROJECT_VISIBILITY" == "public" ]]; then
    return
  fi
  
   kubectl create secret docker-registry "gitlab-auth" \
    --docker-server="$CI_REGISTRY" \
    --docker-username=${KUBE_PULL_USER:-maven} \
    --docker-password=${KUBE_PULL_PASS:} \
    --docker-email="$GITLAB_USER_EMAIL" \
    -o yaml --dry-run | kubectl replace --force -f -    
    
}

function persist_environment_url() {
  echo $CI_ENVIRONMENT_URL > environment_url.txt
}

function write_environment_values_file() {
  echo "deploymentApiVersion: apps/v1" > environment_values.txt

  if [[ "$CI_PROJECT_VISIBILITY" != "public" ]]; then
    echo "image: { secrets: [ { name: gitlab-auth} ] }" >> environment_values.txt
  else
    echo "image: { secrets: null }" >> environment_values.txt
  fi
  
}

function check_kube_domain() {
  if [[ -z "$KUBE_INGRESS_BASE_DOMAIN" ]]; then
    echo "KUBE_INGRESS_BASE_DOMAIN variables must be set"
    false
  else
    true
  fi
}
function deploy() {
  local file=${1-deployment.yml}
  cat $file | envsubst | kubectl apply -f -
}

function undeploy() {
  local file=${1-deployment.yml}
  cat $file | envsubst | kubectl delete -f -
}

#
## End Helper functions

option=$1
case $option in

  check_kube_domain) check_kube_domain ;;
  ensure_namespace) ensure_namespace ;;
  create_secret) create_secret ;;
  persist_environment_url) persist_environment_url ;;
  deploy) deploy "${@:2}" ;;
  undeploy) undeploy "${@:2}" ;;
  *) exit 1 ;;
esac

