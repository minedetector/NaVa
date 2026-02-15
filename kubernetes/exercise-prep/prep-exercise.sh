#!/bin/bash

# Create Kubernetes namespaces with error handling

for i in {1..38}; do
  namespace="tiim-${i}"

  if kubectl get namespace "$namespace" &>/dev/null; then
    echo "Namespace $namespace already exists, skipping..."
  else
    kubectl create namespace "$namespace"
    echo "Created namespace: $namespace"
  fi

  kubectl apply -f ../homework-manifests/resource-quota.yaml -n "$namespace"
  kubectl apply -f ../homework-manifests/configmap.yaml -n "$namespace"
  kubectl apply -f ../homework-manifests/exercise-1 -n "$namespace"
  kubectl apply -f ../homework-manifests/exercise-2 -n "$namespace"
  kubectl apply -f ../homework-manifests/exercise-3 -n "$namespace"
done
