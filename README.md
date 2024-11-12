# Hands-on Karmada

Demo repository for Karmada showcase and conference talk.

## Demo Instructions

### 
```bash
# we need some CLI tools
brew install eksctl
kubectl krew install karmada

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
```

### Hello Karmada



## Maintainer

M.-Leander Reimer (@lreimer), <mario-leander.reimer@qaware.de>

## License

This software is provided under the MIT open source license, read the `LICENSE`
file for details.

