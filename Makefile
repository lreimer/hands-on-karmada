# AWS specific variables
AWS_ACCOUNT_ID := $(shell aws sts get-caller-identity --query Account --output text)

AWS_REGION_01 ?= eu-north-1
AWS_REGION_02 ?= eu-central-1

GITHUB_USER ?= lreimer

# https://app.electricitymaps.com/map?lang=de
# https://cloud.google.com/compute/docs/regions-zones?hl=de#available
GCP_PROJECT ?= cloud-native-experience-lab

GCP_REGION_01 ?= europe-north1
GCP_REGION_02 ?= europe-west1
GCP_REGION_03 ?= us-east1

create-gke-member-01:
	@gcloud container clusters create gke-member-01 \
		--release-channel=regular \
		--cluster-version=1.30 \
		--region=$(GCP_REGION_01) \
		--addons HttpLoadBalancing,HorizontalPodAutoscaling \
		--workload-pool=$(GCP_PROJECT).svc.id.goog \
		--num-nodes=1 \
		--min-nodes=1 --max-nodes=5 \
		--enable-autoscaling \
		--autoscaling-profile=optimize-utilization \
		--enable-vertical-pod-autoscaling \
		--machine-type=e2-standard-4 \
		--logging=SYSTEM \
    	--monitoring=SYSTEM
	@kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$$(gcloud config get-value core/account)
	@kubectl cluster-info
	@kubectl config view --raw --minify > .kube/gke-member-01.config

bootstrap-flux2-member-01:
	@flux bootstrap github \
		--owner=$(GITHUB_USER) \
		--repository=hands-on-karmada \
		--branch=main \
		--path=./members/gke-member-01 \
		--read-write-key \
		--personal

create-eks-member-02:
	@eksctl create cluster -f members/eks-member-02.yaml
	@kubectl config view --raw --minify > .kube/eks-member-02.config

bootstrap-flux2-member-02:
	@flux bootstrap github \
		--owner=$(GITHUB_USER) \
		--repository=hands-on-karmada \
		--branch=main \
		--path=./members/eks-member-02 \
		--read-write-key \
		--personal

create-gke-member-03:
	@gcloud container clusters create gke-member-03 \
		--release-channel=regular \
		--cluster-version=1.30 \
		--region=$(GCP_REGION_02) \
		--addons HttpLoadBalancing,HorizontalPodAutoscaling \
		--workload-pool=$(GCP_PROJECT).svc.id.goog \
		--num-nodes=1 \
		--min-nodes=1 --max-nodes=5 \
		--enable-autoscaling \
		--autoscaling-profile=optimize-utilization \
		--enable-vertical-pod-autoscaling \
		--machine-type=e2-standard-4 \
		--logging=SYSTEM \
    	--monitoring=SYSTEM
	@kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$$(gcloud config get-value core/account)
	@kubectl cluster-info
	@kubectl config view --raw --minify > .kube/gke-member-03.config

bootstrap-flux2-member-03:
	@flux bootstrap github \
		--owner=$(GITHUB_USER) \
		--repository=hands-on-karmada \
		--branch=main \
		--path=./members/gke-member-03 \
		--read-write-key \
		--personal

create-eks-member-04:
	@eksctl create cluster -f members/eks-member-04.yaml
	@kubectl config view --raw --minify > .kube/eks-member-04.config

bootstrap-flux2-member-04:
	@flux bootstrap github \
		--owner=$(GITHUB_USER) \
		--repository=hands-on-karmada \
		--branch=main \
		--path=./members/eks-member-04 \
		--read-write-key \
		--personal

create-gke-member-05:
	@gcloud container clusters create gke-member-05 \
		--release-channel=regular \
		--cluster-version=1.30 \
		--region=$(GCP_REGION_03) \
		--addons HttpLoadBalancing,HorizontalPodAutoscaling \
		--workload-pool=$(GCP_PROJECT).svc.id.goog \
		--num-nodes=1 \
		--min-nodes=1 --max-nodes=5 \
		--enable-autoscaling \
		--autoscaling-profile=optimize-utilization \
		--enable-vertical-pod-autoscaling \
		--machine-type=e2-standard-4 \
		--logging=SYSTEM \
    	--monitoring=SYSTEM
	@kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$$(gcloud config get-value core/account)
	@kubectl cluster-info
	@kubectl config view --raw --minify > .kube/gke-member-05.config

bootstrap-flux2-member-05:
	@flux bootstrap github \
		--owner=$(GITHUB_USER) \
		--repository=hands-on-karmada \
		--branch=main \
		--path=./members/gke-member-05 \
		--read-write-key \
		--personal

delete-clusters: delete-gke-clusters delete-eks-clusters

delete-eks-clusters:
	@eksctl delete cluster --region=$(AWS_REGION_01) --name=eks-member-02
	@aws cloudformation delete-stack --region $(AWS_REGION_01) --stack-name eksctl-eks-member-02-cluster
	@eksctl delete cluster --region=$(AWS_REGION_02) --name=eks-member-04
	@aws cloudformation delete-stack --region $(AWS_REGION_02) --stack-name eksctl-eks-member-04-cluster

delete-gke-clusters:
	@gcloud container clusters delete gke-member-01 --region=$(GCP_REGION_01) --async --quiet
	@gcloud container clusters delete gke-member-03 --region=$(GCP_REGION_02) --async --quiet
	@gcloud container clusters delete gke-member-05 --region=$(GCP_REGION_03) --async --quiet
