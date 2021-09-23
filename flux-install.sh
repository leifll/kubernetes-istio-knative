#!/bin/bash

# 
# Commands taken from https://searchitoperations.techtarget.com/tutorial/Try-out-this-GitOps-tutorial-with-Flux-and-Kubernetes
#

# Pass github credentials to flux as env vars.
#export GITHUB_TOKEN=<your-token>
#export GITHUB_USER=<your-username>

# Installs flux to the cluster and creates a github repo that flux will monitor. Note
# that the repository created here contains only the flux system.
flux bootstrap github \
 --owner=$GITHUB_USER \
 --repository=gitops-Kubernetes-demo \
 --branch=main \
 --path=./clusters/demo-cluster \
 --personal \
 --private=false

# Commands to check what has been installed
kubectl get all -n flux-system
kubectl api-resources | grep flux
kubectl api-versions | grep flux
kubectl get gitrepositories.source.toolkit.fluxcd.io -n flux-system
flux get sources git

# Clone the recently created github repo
git clone https://github.com/leifll/gitops-Kubernetes-demo.git

# Create a yaml file describing a flux GitRepository source, which will sync the cluster
# with the content of the specified git repo.
flux create source git podinfo \
 --url=https://github.com/dexterposh/podinfo \
 --branch=master \
 --interval=30s \
 --export > ./gitops-Kubernetes-demo/clusters/demo-cluster/podinfo-source.yaml

# List the newly created yaml file
cat gitops-Kubernetes-demo/clusters/demo-cluster/podinfo-source.yaml 

# Commit the newly created yaml file to the github repo monitored by flux.
cd gitops-Kubernetes-demo/
git add .
git commit -m "added podinfo app"
git push origin main

# Check that flux has updated the cluster according to the newly committed
# yaml file. A new GitRepository source has been created, monitoring the 
# repo specified in the newly committed yaml file.
kubectl get gitrepositories.source.toolkit.fluxcd.io -n flux-system
flux get sources git

# The GitRepository source will only track the repository and pull changes, not apply 
# the changes. To do that we must create a Kustomization resource. 
flux create kustomization podinfo \
 --source=podinfo \
 --path="./kustomize" \
 --prune=true \
 --validation=client \
 --interval=5m \
 --export > ./gitops-Kubernetes-demo/clusters/demo-cluster/podinfo-kustomization.yaml

# Commit the newly created file podinfo-kustomization.yaml
cd gitops-Kubernetes-demo/
git add .
git commit -m "added kustomization for the podinfo app"
git push origin main

# Check the status of the source and Kustomization resources. The output of the first two 
# commands will show that a new revision of the git repo has been applied.
kubectl get gitrepositories.source.toolkit.fluxcd.io -n flux-system
flux get sources git
kubectl get kustomization.kustomize.toolkit.fluxcd.io -n flux-system
flux get kustomizations

# Check that the specified app is deployed.
kubectl get pod
kubectl get service
ubectl get deployment
kubectl get deployments.apps
kubectl get hpa

# Some important points to remember:
#  * Changes made to the YAML manifests in the application repository will be synchronized 
#    and applied to the cluster. You can suspend the reconciliation by running 
#    flux suspend kustomization <name> and resume it with flux resume kustomization <name>.
#  * Any manual changes made to the application deployment, like useing kubectl edit to modify
#    the sample application deployments, would be reverted.
#  * Removing the Kustomization manifest file from the cluster repository will remove the
#    corresponding Kubernetes resources deployed too.
