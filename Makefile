# AWS specific variables
AWS_ACCOUNT_ID := $(shell aws sts get-caller-identity --query Account --output text)
AWS_REGION ?= eu-north-1

GITHUB_USER ?= lreimer

# https://app.electricitymaps.com/map?lang=de
# https://cloud.google.com/compute/docs/regions-zones?hl=de#available
GCP_PROJECT ?= cloud-native-experience-lab
GCP_REGION ?= europe-north1
GCP_ZONE ?= europe-north1-b

prepare-gke-cluster:
	@gcloud config set compute/region $(GCP_REGION)
	@gcloud config set compute/zone $(GCP_ZONE)
	@gcloud config set container/use_client_certificate False

create-gke-cluster:
	@gcloud container clusters create gke-member-01 \
		--release-channel=regular \
		--cluster-version=1.30 \
		--region=$(GCP_REGION) \
		--addons HttpLoadBalancing,HorizontalPodAutoscaling \
		--workload-pool=$(GCP_PROJECT).svc.id.goog \
		--num-nodes=1 \
		--min-nodes=1 --max-nodes=5 \
		--enable-autoscaling \
		--autoscaling-profile=optimize-utilization \
		--enable-vertical-pod-autoscaling \
		--machine-type=e2-standard-4 \
		--image-type=UBUNTU_CONTAINERD \
		--logging=SYSTEM \
    	--monitoring=SYSTEM
	@kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$$(gcloud config get-value core/account)
	@kubectl cluster-info

bootstrap-gke-flux2:
	@flux bootstrap github \
		--owner=$(GITHUB_USER) \
		--repository=hands-on-karmada \
		--branch=main \
		--path=./members/gke-member-01 \
		--read-write-key \
		--personal

create-eks-cluster:
	@eksctl create cluster -f eks-member-02.yaml

bootstrap-eks-flux2:
	@flux bootstrap github \
		--owner=$(GITHUB_USER) \
		--repository=hands-on-karmada \
		--branch=main \
		--path=./members/eks-member-02 \
		--read-write-key \
		--personal

delete-clusters: delete-gke-cluster delete-eks-cluster

delete-eks-cluster:
	@eksctl delete cluster --region=eu-north-1 --name=eks-member-02
	@aws cloudformation delete-stack --region eu-central-1 --stack-name eksctl-eks-member-02-cluster
	@aws cloudformation delete-stack --region eu-north-1 --stack-name eksctl-eks-member-02-cluster

delete-gke-cluster:
	@gcloud container clusters delete gke-member-01 --region=$(GCP_REGION) --async --quiet
