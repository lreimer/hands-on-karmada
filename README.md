# Hands-on Karmada

Demo repository for Karmada showcase and conference talk.

## Demo Instructions

```bash
# we need some CLI tools
brew install eksctl
kubectl krew install karmada

# create member-01 cluster on GCP
make create-gke-cluster
make bootstrap-gke-flux2

# create member-02 cluster on AWS
make create-eks-cluster
make bootstrap-eks-flux2
```

### Hello Karmada



## Maintainer

M.-Leander Reimer (@lreimer), <mario-leander.reimer@qaware.de>

## License

This software is provided under the MIT open source license, read the `LICENSE`
file for details.

