# Deployments

This directory tree holds the resources for creating Kubernetes clusters via various tools, targeting various platforms.  Each tool/platform combination should provide a `scripts` directory that will roughly follow the [scripts to rule them all](https://github.com/azavea/operations/blob/main/doc/arch/adr-0000-scripts-to-rule-them-all.md) organization.

In all cases, the intent is to determine how to set up a cluster that follows the [standard architecture](../docs/1-General/Azavea-standard Kubernetes architecture.md).  In short, provide some base capacity for system services, and then use an autoscaler to furnish additional capacity for application loads.

## AWS

### Terraform

From `aws/terraform` run `./scripts/cibuild` followed by `./scripts/cipublish`.  Use `./scripts/edit-tfvars` either from inside the docker-compose environment, or from the host environment (some environment variables may need to be set for the latter).

### eksctl

### Rancher

## Google Cloud

> Our understanding of the tool portfolio for this provider is unknown.  Completing the picture will be a research task.

### Terraform

## Azure

> We have had some experience with this provider, but distilling that experience into a consumable module will require additional effort.

### Terraform
