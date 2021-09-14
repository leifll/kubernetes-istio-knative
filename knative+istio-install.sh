#!/bin/bash

# Taken from https://knative.dev/docs/admin/install/serving/install-serving-with-yaml/
# and https://knative.dev/docs/admin/install/eventing/install-eventing-with-yaml/

# Install knative serving.
kubectl apply -f https://github.com/knative/serving/releases/download/v0.25.0/serving-crds.yaml
kubectl apply -f https://github.com/knative/serving/releases/download/v0.25.0/serving-core.yaml

# Install Istio
istioctl install -f istio-for-knative.yaml

# List istio pods and services
kubectl get pods -n istio-system
kubectl get services -n istio-system

# Enable sidecar container on knative-serving system namespace.
kubectl label namespace knative-serving istio-injection=enabled

# Allow plain text communication to the knative-serving namespace.
kubectl apply -f plaintext-communication-to-knative.yaml

# Note that the last part of the instructions, Configuring DNS, is not performed here.
# See https://knative.dev/docs/admin/install/installing-istio/#configuring-dns
# When configuring the DNS, the ip address of the ingress can be found with the command
# kubectl get po -l istio=ingressgateway -n istio-system -o jsonpath='{.items[0].status.hostIP}'
# If the DNS isn't configured, curl commands must have a host header. 

# Install the Knative Istio controller 
kubectl apply -f https://github.com/knative/net-istio/releases/download/v0.25.0/net-istio.yaml

# Fetch the External IP address
kubectl get po -l istio=ingressgateway -n istio-system -o jsonpath='{.items[0].status.hostIP}'

# Verify the installation
kubectl get pods -n knative-serving

# Make knative use the sslip.io DNS. Not sure if this works, if not, always specify a host header
# when making http requests to the cluster.
kubectl apply -f https://github.com/knative/serving/releases/download/v0.25.0/serving-default-domain.yaml

# Install Knative eventing
kubectl apply -f https://github.com/knative/eventing/releases/download/v0.25.0/eventing-crds.yaml
kubectl apply -f https://github.com/knative/eventing/releases/download/v0.25.0/eventing-core.yaml

# Verify the installation

# See https://knative.dev/docs/admin/install/eventing/install-eventing-with-yaml/
# for instructions on how to install a messaging layer or broking layer.
