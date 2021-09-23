#!/bin/bash

# 
# Commands taken from https://docs.flagger.app/ and
# https://docs.flagger.app/tutorials/istio-progressive-delivery
#

# Install Flagger's Canary CRD
kubectl apply -f https://raw.githubusercontent.com/fluxcd/flagger/main/artifacts/flagger/crd.yaml

# Deploy Flagger for Istio
helm upgrade -i flagger flagger/flagger \
--namespace=istio-system \
--set crd.create=false \
--set meshProvider=istio \
--set metricsServer=http://prometheus:9090

# Flagger comes with a Grafana dashboard made for monitoring the canary analysis. Deploy Grafana
# in the istio-system namespace. Nothe that the prometheus url below, 
# http://prometheus.istio-system:9090 is the url to specify when the grafana data source url is
# specified in the grafana dashboard.
helm upgrade -i flagger-grafana flagger/grafana \
--namespace=istio-system \
--set url=http://prometheus.istio-system:9090 \
--set user=admin \
--set password=change-me

# Use port forwarding to access grafana.
kubectl -n istio-system port-forward svc/flagger-grafana 3000:80

# Install prometheus
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.11/samples/addons/prometheus.yaml

# Create a test namespace with Istio sidecar injection enabled
kubectl create ns test
kubectl label namespace test istio-injection=enabled

# Create a deployment and a horizontal pod autoscaler. This is the app that will be used
# to illustrate flagger deployment.
kubectl apply -k https://github.com/fluxcd/flagger//kustomize/podinfo?ref=main

# Deploy a load testing service to generate traffic during the canary analysis
kubectl apply -k https://github.com/fluxcd/flagger//kustomize/tester?ref=main

# Deploy the flagger 'canary' sustom resource.
kubectl apply -f ./flagger-canary-custom-resource.yaml

# Trigger a canary deployment by updating the container image
kubectl -n test set image deployment/podinfo podinfod=stefanprodan/podinfo:3.1.1

# Check what happens
kubectl -n test describe canary/podinfo

# You can monitor all canaries with
watch kubectl get canaries --all-namespaces
