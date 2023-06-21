# CDP quickstart using the Terraform Module for CDP Prerequisites

This repository contains Terraform resource files to quickly deploy Cloudera Data Platform (CDP) Public Cloud and associated pre-requisite Cloud Service Provider (CSP) resources. It uses the CDP Terraform Modules to do this.

A summary requirements, configuration and execution steps to use this repository is given below.

## Requirements

In addition to Terraform there are a number of additional requirements to discover the cross account Ids and to run the CDP environment deployment. A summary of the install steps for these requirements is given below.

> **_NOTE:_** We recommend these steps be performed within a Python virtual environment.

* Terraform can be installed by following the instructions at https://developer.hashicorp.com/terraform/downloads

* Install jq as per instructions at https://stedolan.github.io/jq/download/. An example for MacOS using homebrew is shown below

```bash
brew install jq
```

* Install the Python dependency packages. This includes:
  * the Ansible core and jmespath Python packages
  * cdpy, a Pythonic wrapper for Cloudera CDP CLI. Note that this in turn installs the CDP CLI.

```bash
pip install ansible-core==2.12.10 jmespath==1.0.1 

pip install git+https://github.com/cloudera-labs/cdpy@main#egg=cdpy
```

* Install the community.general and cloudera.cloud Ansible collections

```bash
ansible-galaxy collection install community.general:==5.5.0

ansible-galaxy collection install git+https://github.com/cloudera-labs/cloudera.cloud.git,devel
```

* Configure cdp with CDP access key ID and private key if not already done.
  * See the [CDP documentation for steps to Generate the API access key](https://docs.cloudera.com/cdp-public-cloud/cloud/cli/topics/mc-cli-generating-an-api-access-key.html) required in the `cdp configure` command above.

```bash
cdp configure
```

* To create resources in the Cloud Provider, access credentials or service account are needed for authentication.
  * For **AWS** access keys are required to be able to create the Cloud resources via the Terraform aws provider. See the [AWS documentation for Managing access keys for IAM users](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html).
  * For **Azure**, authentication with the Azure subscription is required. There are a number of ways to do this outlined in the [Azure Terraform Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure).

## Configuration

The `terraform.tfvars.template` file in the required cloud provider directory contains the user-facing configuration. Edit this file to match your particular deployment.

Sample contents with indicators of values to change are shown below.

### Sample Configuration file for AWS

```yaml
# ------- Global settings -------
env_prefix = "<ENTER_VALUE>" # Required name prefix for cloud and CDP resources, e.g. cldr1

# ------- Cloud Settings -------
aws_region = "<ENTER_VALUE>" # Change this to specify Cloud Provider region, e.g. eu-west-1
aws_key_pair = "<ENTER_VALUE>" # Change this with the name of a pre-existing AWS keypair, e.g. my-keypair

# ------- CDP Environment Deployment -------
deployment_template = "<ENTER_VALUE>"  # Specify the deployment pattern below. Options are public, semi-private or private

# ------- Network Settings -------
# **NOTE: If required change the values below any additional CIDRs to add the the AWS Security Groups**
ingress_extra_cidrs_and_ports = {
 cidrs = ["<ENTER_IP_VALUE>/32", "<ENTER_IP_VALUE>/32"],
 ports = [443, 22]
}
```

### Sample Configuration file for Azure

```yaml
# ------- Global settings -------
env_prefix = "<ENTER_VALUE>" # Required name prefix for cloud and CDP resources, e.g. cldr1

# ------- Cloud Settings -------
azure_region = "<ENTER_VALUE>" # Change this to specify Cloud Provider region, e.g. westeurpoe

public_key_text = "<ENTER_VALUE> # Change this with the SSH public key text, e.g. ssh-rsa AAA....

# ------- CDP Environment Deployment -------
deployment_template = "<ENTER_VALUE>"  # Specify the deployment pattern below. Options are public, semi-private or private

# ------- Network Settings -------
# **NOTE: If required change the values below any additional CIDRs to add the the AWS Security Groups**
ingress_extra_cidrs_and_ports = {
 cidrs = ["<ENTER_IP_VALUE>/32", "<ENTER_IP_VALUE>/32"],
 ports = [443, 22]
}
```

## Execution

1. Clone this repository using the following commands:

```bash
# Git clone
git clone https://github.com/cloudera-labs/cdp-tf-quickstarts.git 
# Change to directory with the cloned repo
cd cdp-tf-quickstarts
```

2. In the cloned repo, change to required cloud provider directory and edit the variables in `terraform.tfvars` file as discussed in the section above.

```bash
# Change into cloud provider directory, e.g. for aws
cd aws

# Edit the terraform.tfvars file as needed.
```

3. To create Cloud resources and CDP environment, in the cloud provider directory, run the Terraform commands to initialize and apply the changes:

```bash
terraform init
terraform apply
```

Once the deployment completes, you can create CDP Data Hubs and Data Services from the CDP Management Console (https://cdp.cloudera.com/).

### Clean up the CDP environment and infrastructure

If you no longer need the infrastructure and CDP environment that’s provisioned by Terraform, run the following command to remove the deployment infrastructure and terminate all resources.

```bash
terraform destroy
```
