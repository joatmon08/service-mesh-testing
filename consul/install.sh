#!/bin/bash


kubectl config use-context gke_rosemary-hashicups_us-central1-c_primary
helm install -f primary.yaml consul hashicorp/consul --version "0.32.1" --wait

kubectl apply -f primary-k8s/proxy-defaults.yaml
kubectl get secret consul-federation -o yaml > secondary-k8s/consul-federation-secret.yaml


kubectl config use-context gke_rosemary-hashicups_us-central1-c_secondary
kubectl apply -f secondary-k8s/consul-federation-secret.yaml
helm install -f secondary.yaml consul hashicorp/consul --version "0.32.1" --wait

kubectl apply -f secondary-k8s/proxy-defaults.yaml


kubectl config use-context gke_rosemary-hashicups_us-central1-c_primary
kubectl apply -f primary-k8s/static-client.yaml
kubectl apply -f primary-k8s/intentions.yaml


kubectl config use-context gke_rosemary-hashicups_us-central1-c_secondary
kubectl apply -f secondary-k8s/static-server.yaml


kubectl config use-context gke_rosemary-hashicups_us-central1-c_primary
kubectl exec deploy/static-client -c static-client -- curl -sS http://localhost:8080