# Terraform/EKS reference implementation

This subtree provides a means to deploy the Azavea standard Kubernetes architecture to the AWS EKS service.

## Deployment instructions

We provide a collection of scripts to aid in the deployment of this system which relies on a Docker container to provide access to a consistent version of Terraform.  Environment variables can be used to configure this Docker environment; see the [docker-compose](docker-compose.yaml) file for details on configurations.  We provide scripts to enter and properly configure this docker-compose shell, and other scripts to accomplish the deployment tasks.  Here are the basic steps:

### Prerequisites

Deploying a base cluster requires only a Docker-enabled Linux machine with `docker-compose` installed.  Applications may add additional prerequisites, such as S3 buckets, or existing Route 53 zones.  Consult the `variables.tf` in each application folder to determine which resources are required ahead of time.

### Building the Docker environment

From the current directory, we build the Docker container by running `./scripts/cibuild`.  This creates a Docker container with a user account that shares the UID and GID of the caller to `cibuild`; it also sets up a Docker account that shares the GID of the host.  These steps are taken to maximize the ease of communication with the host environment, and to allow the container environment to build and upload Docker images to ECR.

> Note that we do not presently have a means to build this container on MacOS, since it is likely that the UID and GID of the caller are likely to conflict with the system group ids within the Linux-based container environment which use different conventions for the assignment of ids.  A future solution to provide all the desired features that is Mac-compatible will be addressed at a later time.

### Enter the Docker environment

The `./scripts/console` command facilitates entry into the Docker environment, which is mediated by the `docker-compose.yaml` configuration.  The console script makes sure that we are targeting the desired deployment environment (i.e., staging, production, QA, test, etc.) in the proper AWS region and that the bucket containing the Terraform settings is declared correctly.

#### Set the deployment environment
The target environment is set by one of the following methods:
1. Set the `ENVIRONMENT` environment variable.  If this is set, it will take priority over other methods.
2. Pass the environment name as an argument by issuing `./scripts/console <environment>`.
3. Use the default value of `staging`.

#### Set the target AWS region
One can deploy to a region other than the one configured in your AWS profile by declaring a value for `AWS_DEFAULT_REGION`.

#### Set the project name
The AWS resources will be named according to the project name, which is controlled through the `PROJECT_NAME` environment variable (with a default value of `azavea`).  The cluster will be named as `${PROJECT_NAME}-<environment>`, and the project name will appear in many of the names of the associated resources.

#### Create a settings bucket and initialize variables
In order to configure the Terraform scripts, it is necessary to set the values of a number of variables for the various components that are to be deployed.  This is done by creating a `terraform.tfvars` file, populating it, and uploading it to a bucket of your choosing in the same region as the cluster.  Use the same `terraform.tfvars` file to configure all of the stages you intend to deploy.  This will lead to some warnings while deploying, but this solution is generally more user-friendly.

The name of the bucket to be used is set by one of the following methods:
1. Set the `S3_SETTINGS_BUCKET` environment variable.  This will override the other mechanisms.
2. Set the `BUCKET_PREFIX` environment variable.  The bucket will be named as `${BUCKET_PREFIX}-<region>`.
3. Use the default bucket name of `azavea-kubernetes-settings-<region>`.

Once the bucket is created (and you can create the bucket from inside the `./scripts/console` environment by calling `aws s3 mb s3://${S3_SETTINGS_BUCKET}`), upload your initial `terraform.tfars` file to your bucket with the prefix `<environment>/terraform.tfvars`.  Once created, you can use `./scripts/edit-tfvars` to adjust it without manually downloading/editing/reuploading.

### Deploy the cluster

From within the `console` environment, we can perform a sequence of `plan` and `apply` operations to construct the various stages you wish to deploy.  From `/usr/local/src/deployment/aws-terraform` (the default initial directory), issue the following commands:
```
./scripts/infra plan <stage>
./scripts/infra apply <stage>
```
The value of `<stage>` will be the relative name of a directory containing the Terraform code to be deployed.  You must begin by deploying the `0-hardware` stage, followed by the `1-services` stage.  That sets up the basic infrastructure required to deploy other application stages—e.g., `application/argo` or `application/daskhub`—which generally do not have an order in which they need to be deployed.

There may be occasional failures in deploying a stage, but these are generally overcome by running another `plan` and `apply` cycle for that stage.

### Manage the cluster

Once the cluster is live, most updates can be done in-place by adjusting some variables and then running a `plan`/`apply` cycle for the affected stage(s).  Some changes, though, require a more comprehensive tear-down.  If the `0-hardware` stage requires the cluster to be recreated, then all of the stages which were applied need to first be destroyed, in roughly the opposite order in which they were created.  Run `./infra destroy <stage>` to delete any applicable stages.

As with most EKS Terraform deployments, these destroy steps are prone to failure, and may require manual intervention.  This is especially true when destroying the `0-hardware` stage.  You may need to manually destroy resources to achieve a complete tear-down of the cluster.  If you have to completely delete a cluster, you may wish to clear the Terraform state by deleting folders from s3 in the `s3://${S3_SETTINGS_BUCKET}/${ENVIRONMENT}/terraform/` prefix.  You may then need to run `./scripts/infra clear <stage>` for the applicable stages to purge any locally-stored state.
