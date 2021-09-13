#!/bin/bash

# See:
# - https://istio.io/latest/docs/setup/getting-started/
# - https://www.oreilly.com/library/view/istio-up-and/9781492043775/ch04.html

# First, start a kubernetes cluster, for example the kind cluster described in 'kind'startup'.

# Note that istio resources are installed as kubernetes CRDs, and can thus be managed 
# with kubectl. The recommended approach is to use kubectl instead of istioctl whenever possible.

# Install istio on the kubernetes kluster.
# istioctl install --set profile=demo -y

# To see what's happening, try instead:
istioctl install --set profile=demo --verify

# To install with helm (considered alpha at 210913 according to https://istio.io/latest/docs/setup/install/helm/):
# kubectl create namespace istio-system
# helm install istio-base /usr/local/istio/manifests/charts/base -n istio-system
# helm install istiod /usr/local/istio/manifests/charts/istio-control/istio-discovery -n istio-system
# helm install istio-ingress /usr/local/istio/manifests/charts/gateways/istio-ingress -n istio-system
# helm install istio-egress /usr/local/istio/manifests/charts/gateways/istio-egress -n istio-system

# Add a namespace label to instruct Istio to automatically inject Envoy sidecar proxies 
# when you deploy your application later:
kubectl label namespace default istio-injection=enabled

# Deploy the bookinfo sample application.
kubectl apply -f /usr/local/istio/samples/bookinfo/platform/kube/bookinfo.yaml

# See following steps at https://istio.io/latest/docs/setup/getting-started/
# Everything on that page, including the Kiali dashboard, works. (210913)
# Use the method under 'Other environments' to get the ingress host, that is the command
# export INGRESS_HOST=$(kubectl get po -l istio=ingressgateway -n istio-system -o jsonpath='{.items[0].status.hostIP}') 
