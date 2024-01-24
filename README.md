# CDP quickstart using the Terraform Module for CDP Prerequisites

This repository contains Terraform resource files to quickly deploy Cloudera Data Platform (CDP) Public Cloud and associated pre-requisite Cloud Service Provider (CSP) resources. It uses the [CDP Terraform Modules](https://github.com/cloudera-labs/terraform-cdp-modules) to do this.

A summary requirements, configuration and execution steps to use this repository is given below.

## Prerequisites

To use the module provided here, you will need the following prerequisites:

* An AWS, Azure or GCP Cloud account;
* A CDP Public Cloud account (you can sign up for a  [60-day free pilot](https://www.cloudera.com/campaign/try-cdp-public-cloud.html) );
* A recent version of Terraform software (version 0.13 or higher).

## Deployment steps

### Configure local prerequisites

* To create resources in the Cloud Provider, access credentials or service account are needed for authentication.
  * For **AWS** access keys are required to be able to create the Cloud resources via the Terraform aws provider. See the [AWS documentation for Managing access keys for IAM users](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html).
  * For **Azure**, authentication with the Azure subscription is required. There are a number of ways to do this outlined in the [Azure Terraform Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure).
  * For **GCP**, authentication with the GCP API is required. There are a number of ways to do this outlined in the [Google Terraform Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#authentication).

* If you have not yet configured your `~/.cdp/credentials file`, follow the steps for [Generating an API access key](https://docs.cloudera.com/cdp-public-cloud/cloud/cli/topics/mc-cli-generating-an-api-access-key.html).

* Terraform can be installed by following the instructions at https://developer.hashicorp.com/terraform/downloads

#### Notes on AWS authentication

* Details of the different methods to authenticate with AWS are available in the [aws Terraform provider docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration).

* The most common ways to specify AWS access and secret keys are:
  * via environment variables (i.e. setting the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`) or;
  * via shared configuration/credential files (e.g. the `$HOME/.aws/credentials` file). The `AWS_PROFILE` environment variable can be set to specify a named AWS profile. 

* Note that the AWS region to use should always be specifed as a Terraform input variable (with the `aws_region` variable). This region variable is also used an input to the CDP deploy module used to identify the Cloud Provider region.

#### Notes on Azure authentication

* Where you have more than one Azure Subscription the id to use can be passed via the the `ARM_SUBSCRIPTION_ID` environment variable.

* When using a Service Principal (SP) to authenticate with Azure, it is not possible to authenticate with azuread Terraform Provider (the provider used to create the Azure Cross Account AD Application) with the command az login --service-principal. We found the the best way to authenticate using an SP is by setting environment variables. Details of required environment variables are in the [azuread docs](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/guides/service_principal_client_secret#environment-variables) and [azurerm docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret#configuring-the-service-principal-in-terraform) and summarized below.
```bash
export ARM_CLIENT_ID="<sp_client_id>"
export ARM_CLIENT_SECRET="<sp_client_secret>"
export ARM_TENANT_ID="<sp_tenant_id>"
export ARM_SUBSCRIPTION_ID="<sp_subscription_id>" 
```

* The Azure API permissions listed are required by the provisioning account to create the Azure pre-requisite resources.

| API Permission    | Purpose |
| ------------------| ------- |
| Microsoft Graph - Application.ReadWrite.All   | Read and write all applications |
| Microsoft Graph - Application.ReadWrite.OwnedBy | Manage apps that this app creates or owns |
| Microsoft Graph - AppRoleAssignment.ReadWrite.All | Manage app permission grants and app role assignments |
| Microsoft Graph - Directory.ReadWrite.All | Read and write directory data |
| Microsoft Graph - User.Read | Sign in and read user profile |

#### Notes on GCP authentication

* The [Getting Started Docs for Google Terraform Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started#adding-credentials) gives details on the two recommended ways to authenticate with the GCP API.
  1. The Google Cloud SDK (`gcloud`) can be installed and a User Application Default Credentials ("ADCs") can be created by running the command `gcloud auth application-default login`
  1. A Google Cloud Service Account key file can be generated and downloaded. The `GOOGLE_APPLICATION_CREDENTIALS` environment variable can then be set to the location of the file.

  ```bash
  export GOOGLE_APPLICATION_CREDENTIALS=<location_of_gcp_sa_json_file>
  ```

* The Google Cloud IAM roles listed below are required by the provisioning account to create the GCP pre-requisite resources.

| IAM Role                  | 
| ------------------------- | 
| Compute Network Admin     | 
| Compute Security Admin    | 
| Role Administrator        | 
| Security Admin            | 
| Service Account Admin     | 
| Service Account Key Admin | 
| Storage Admin             | 
| Viewer                    | 

### Input file configuration

The `terraform.tfvars.template` file in the required cloud provider directory contains the user-facing configuration. Edit this file to match your particular deployment.

Sample contents with indicators of values to change are shown below.

#### Sample Configuration file for AWS

```yaml
# ------- Global settings -------
env_prefix = "<ENTER_VALUE>" # Required name prefix for cloud and CDP resources, e.g. cldr1

# ------- Cloud Settings -------
aws_region = "<ENTER_VALUE>" # Change this to specify Cloud Provider region, e.g. eu-west-1

# ------- CDP Environment Deployment -------
deployment_template = "<ENTER_VALUE>"  # Specify the deployment pattern below. Options are public, semi-private or private

```

#### Sample Configuration file for Azure

```yaml
# ------- Global settings -------
env_prefix = "<ENTER_VALUE>" # Required name prefix for cloud and CDP resources, e.g. cldr1

# ------- Cloud Settings -------
azure_region = "<ENTER_VALUE>" # Change this to specify Cloud Provider region, e.g. eastus

# ------- CDP Environment Deployment -------
deployment_template = "<ENTER_VALUE>"  # Specify the deployment pattern below. Options are public, semi-private or private
```

#### Sample Configuration file for GCP

```yaml
# ------- Global settings -------
env_prefix = "<ENTER_VALUE>" # Required name prefix for cloud and CDP resources, e.g. cldr1

# ------- Cloud Settings -------
gcp_project = "<ENTER_VALUE>" # Change this to specify the GCP Project ID

gcp_region = "<ENTER_VALUE>" # Change this to specify Cloud Provider region, e.g. europe-west2

# ------- CDP Environment Deployment -------
deployment_template = "<ENTER_VALUE>"  # Specify the deployment pattern below. Options are public, semi-private or private
```

#### SSH keys

By default the Terraform quickstarts will create a new SSH keypair that will be associated with all nodes provisioned by CDP. The private key will be stored in the `<env_prefix>-ssh-key.pem` file of the Terraform cloud provider project directory.

To use an existing SSH key, set the keypair name (for AWS) or public key text (for Azure and GCP) variable in the `terraform.tvars` file.

#### Access to UI and API endpoints

By default inbound access to the UI and API endpoints of your deployment will be allowed from the public IP of executing host. 

To add additional CIDRs or IP ranges, set the optional `ingress_extra_cidrs_and_ports` variable in the `terraform.tvars` file.

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
