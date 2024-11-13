# Hands-on Karmada

Demo repository for Karmada showcase and conference talk.

## Demo Instructions

### Infrastructure Provisioning

```bash
# we need some CLI tools
brew install --cask google-cloud-sdk
brew install eksctl

# create member-01 cluster on GCP
make create-gke-member-01
make bootstrap-flux2-member-01

# create member-02 cluster on AWS
make create-eks-member-02
make bootstrap-flux2-member-02

# create member-03 cluster on GCP
make create-gke-member-03
make bootstrap-flux2-member-03

# create member-04 cluster on AWS
make create-eks-member-04
make bootstrap-flux2-member-04

# create member-05 cluster on GCP
make create-gke-member-05
make bootstrap-flux2-member-05

```

### Bootstrapping Karmada Fleet

```bash
# make sure the Karmada kubectl CLI is present
k krew install karmada
k karmada --help

# bootstrap the Karmada control plane
k ctx rancher-desktop
k karmada init --karmada-data=$PWD/.karmada --karmada-pki=$PWD/.karmada/pki --karmada-apiserver-advertise-address=127.0.0.1 --etcd-storage-mode=emptyDir --cert-external-ip=127.0.0.1

# check all components are running and control plane is up
k get all -n karmada-system
k --kubeconfig $PWD/.karmada/karmada-apiserver.config get all 
k --kubeconfig $PWD/.karmada/karmada-apiserver.config get clusters

# join the member clusters
k karmada --kubeconfig $PWD/.karmada/karmada-apiserver.config join gke-member-01 \
    --cluster-kubeconfig=$HOME/.kube/config \
    --cluster-context=gke_cloud-native-experience-lab_europe-north1_gke-member-01 \
    --cluster-provider=gcp --cluster-region=europe-north1

k karmada --kubeconfig $PWD/.karmada/karmada-apiserver.config join eks-member-02 \
    --cluster-kubeconfig=$HOME/.kube/config \
    --cluster-context=mario-leander.reimer@eks-member-02.eu-north-1.eksctl.io \
    --cluster-provider=aws --cluster-region=eu-north-1

k karmada --kubeconfig $PWD/.karmada/karmada-apiserver.config join gke-member-03 \
    --cluster-kubeconfig=$HOME/.kube/config \
    --cluster-context=gke_cloud-native-experience-lab_europe-west1_gke-member-03 \
    --cluster-provider=gcp --cluster-region=europe-west1

k karmada --kubeconfig $PWD/.karmada/karmada-apiserver.config join eks-member-04 \
    --cluster-kubeconfig=$HOME/.kube/config \
    --cluster-context=mario-leander.reimer@eks-member-04.eu-central-1.eksctl.io \
    --cluster-provider=aws --cluster-region=eu-central-1

k --kubeconfig $PWD/.karmada/karmada-apiserver.config get clusters
k --kubeconfig $PWD/.karmada/karmada-apiserver.config get cluster gke-member-01 -o yaml
k --kubeconfig $PWD/.karmada/karmada-apiserver.config get cluster eks-member-02 -o yaml
k --kubeconfig $PWD/.karmada/karmada-apiserver.config get cluster gke-member-03 -o yaml
k --kubeconfig $PWD/.karmada/karmada-apiserver.config get cluster eks-member-04 -o yaml

k karmada --kubeconfig $PWD/.karmada/karmada-apiserver.config join gke-member-05 \
    --cluster-kubeconfig=$HOME/.kube/config \
    --cluster-context=gke_cloud-native-experience-lab_us-east1_gke-member-05 \
    --cluster-provider=gcp --cluster-region=us-east1

k --kubeconfig $PWD/.karmada/karmada-apiserver.config get clusters
k --kubeconfig $PWD/.karmada/karmada-apiserver.config get cluster gke-member-05 -o yaml
```

### Hello Karmada Nginx

```bash
# create deployment in Karmada control plane only
KUBECONFIG=$PWD/.karmada/karmada-apiserver.config k apply -f examples/nginx-deployment.yaml
KUBECONFIG=$PWD/.karmada/karmada-apiserver.config k get all
KUBECONFIG=$PWD/.karmada/karmada-apiserver.config k karmada get deploy

KUBECONFIG=$PWD/.karmada/karmada-apiserver.config k apply -f examples/propagationpolicy-static-weight.yaml
KUBECONFIG=$PWD/.karmada/karmada-apiserver.config k karmada get deploy
KUBECONFIG=$PWD/.kube/gke-member-01.config k get pods
KUBECONFIG=$PWD/.kube/gke-member-03.config k get pods

KUBECONFIG=$PWD/.karmada/karmada-apiserver.config k apply -f examples/nginx-overridepolicy-weight.yaml
KUBECONFIG=$PWD/.karmada/karmada-apiserver.config k karmada get deploy
KUBECONFIG=$PWD/.kube/gke-member-01.config k get pods
KUBECONFIG=$PWD/.kube/gke-member-01.config k describe deploy nginx

# more demos
KUBECONFIG=$PWD/.karmada/karmada-apiserver.config k apply -f examples/propagationpolicy-dynamic-weight.yaml
KUBECONFIG=$PWD/.karmada/karmada-apiserver.config k apply -f examples/propagationpolicy-region-field.yaml
```

### Cluster Failover and Workload Rebalancer

```bash
# make sure to enable the karmada-metrics-adapter
k karmada addons enable karmada-metrics-adapter --karmada-kubeconfig=$PWD/.karmada/karmada-apiserver.config

export KUBECONFIG=$PWD/.karmada/karmada-apiserver.config 

k apply -f examples/nginx-deployment.yaml
k apply -f examples/propagationpolicy-dynamic-weight.yaml
k karmada get deploy

# taint cluster to simulate cluster fail-over
k karmada taint clusters gke-member-03 workload-rebalancer-test:NoExecute
k karmada taint clusters gke-member-03 workload-rebalancer-test:NoExecute-

k apply -f examples/nginx-workload-rebalancer.yaml
k get workloadrebalancers.apps.karmada.io nginx-rebalancer -o yaml
```

### Karmada and Flux

```bash
# first we need to apply the Flux2 CRDs to the Karmada control plane
k apply -k github.com/fluxcd/flux2/manifests/crds\?ref=main --kubeconfig $PWD/.karmada/karmada-apiserver.config

# Helm release propagation
k apply -f examples/helmrelease-podinfo.yaml 
k apply -f examples/helmrelease-propagation.yaml 
k apply -f examples/helmrelease-override.yaml 

KUBECONFIG=$PWD/.kube/gke-member-01.config k get pods
KUBECONFIG=$PWD/.kube/eks-member-02.config k get pods

# Kustomize propagation
k apply -f examples/kustomize-podinfo.yaml 
k apply -f examples/kustomize-propagation.yaml 

KUBECONFIG=$PWD/.kube/gke-member-03.config k get pods
KUBECONFIG=$PWD/.kube/eks-member-04.config k get pods
```

### Federated HPA 


## Maintainer

M.-Leander Reimer (@lreimer), <mario-leander.reimer@qaware.de>

## License

This software is provided under the MIT open source license, read the `LICENSE`
file for details.

