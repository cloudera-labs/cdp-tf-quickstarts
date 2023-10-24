# CDP quickstart using the Terraform Module for CDP Prerequisites

This repository contains Terraform resource files to quickly deploy Cloudera Data Platform (CDP) Public Cloud and associated pre-requisite Cloud Service Provider (CSP) resources. It uses the CDP Terraform Modules to do this.

A summary requirements, configuration and execution steps to use this repository is given below.

## Prerequisites

To use the module provided here, you will need the following prerequisites:

* An AWS or Azure Cloud account;
* A CDP Public Cloud account (you can sign up for a  [60-day free pilot](https://www.cloudera.com/campaign/try-cdp-public-cloud.html) );
* A recent version of Terraform software (version 0.13 or higher).

## Deployment steps

### Configure local prerequisites

* To create resources in the Cloud Provider, access credentials or service account are needed for authentication.
  * For **AWS** access keys are required to be able to create the Cloud resources via the Terraform aws provider. See the [AWS documentation for Managing access keys for IAM users](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html).
  * For **Azure**, authentication with the Azure subscription is required. There are a number of ways to do this outlined in the [Azure Terraform Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure).

* If you have not yet configured your `~/.cdp/credentials file`, follow the steps for [Generating an API access key](https://docs.cloudera.com/cdp-public-cloud/cloud/cli/topics/mc-cli-generating-an-api-access-key.html).

* Terraform can be installed by following the instructions at https://developer.hashicorp.com/terraform/downloads

#### Notes on Azure authentication

* Where you have more than one Azure Subscription the id to use can be passed via the the `ARM_SUBSCRIPTION_ID` environment variable.

* When using a Service Principal (SP) to authenticate with Azure, it is not possible to authenticate with azuread Terraform Provider (the provider used to create the Azure Cross Account AD Application) with the command az login --service-principal. We found the the best way to authenticate using an SP is by setting environment variables. Details of required environment variables are in the [azuread docs](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/guides/service_principal_client_secret#environment-variables) and [azurerm docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret#configuring-the-service-principal-in-terraform) and summarized below.
```bash
export ARM_CLIENT_ID="<sp_client_id>"
export ARM_CLIENT_SECRET="<sp_client_secret>"
export ARM_TENANT_ID="<sp_tenant_id>"
export ARM_SUBSCRIPTION_ID="<sp_subscription_id>" 
```

### Input file configuration

The `terraform.tfvars.template` file in the required cloud provider directory contains the user-facing configuration. Edit this file to match your particular deployment.

Sample contents with indicators of values to change are shown below.

#### Sample Configuration file for AWS

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

#### Sample Configuration file for Azure

```yaml
# ------- Global settings -------
env_prefix = "<ENTER_VALUE>" # Required name prefix for cloud and CDP resources, e.g. cldr1

# ------- Cloud Settings -------
azure_region = "<ENTER_VALUE>" # Change this to specify Cloud Provider region, e.g. westeurpoe

public_key_text = "<ENTER_VALUE>" # Change this with the SSH public key text, e.g. ssh-rsa AAA....

# ------- CDP Environment Deployment -------
deployment_template = "<ENTER_VALUE>"  # Specify the deployment pattern below. Options are public, semi-private or private

# ------- Network Settings -------
# **NOTE: If required change the values below any additional CIDRs to add the the AWS Security Groups**
ingress_extra_cidrs_and_ports = {
 cidrs = ["<ENTER_IP_VALUE>/32", "<ENTER_IP_VALUE>/32"],
 ports = [443, 22]
}
```

### Create infrastructure

1. Clone this repository using the following commands:

```bash
# Git clone
git clone https://github.com/cloudera-labs/cdp-tf-quickstarts.git 
# Change to directory with the cloned repo
cd cdp-tf-quickstarts
```

2. In the cloned repo, change to required cloud provider directory and create a `terraform.tfvars` file with variable definitions to run the module. Reference the `terraform.tfvars.template` in each cloud provider directory and the example contents discussed in the section above.

```bash
# Change into cloud provider directory, e.g. for aws
cd aws

#Copy terraform.tfvars.template into terraform.tfvars
cp terraform.tfvars.template terraform.tfvars

# Edit the terraform.tfvars file as needed, e.g. using vi
vi terraform.tfvars
```

3. To create Cloud resources and CDP environment, in the cloud provider directory, run the Terraform commands to initialize and apply the changes:

```bash
terraform init
terraform apply
```

Once the creation of the CDP environment and data lake starts, you can follow the deployment process on the CDP Management Console from your browser in ( [https://cdp.cloudera.com/](https://cdp.cloudera.com/) ). After it completes, you can add CDP  [Data Hubs and Data Services](https://docs.cloudera.com/cdp-public-cloud/cloud/overview/topics/cdp-services.html) to your newly deployed environment from the Management Console UI or using the CLI.

### Clean up the CDP environment and infrastructure

If you no longer need the infrastructure and CDP environment that’s provisioned by Terraform, run the following command to remove the deployment infrastructure and terminate all resources.

```bash
terraform destroy
```
