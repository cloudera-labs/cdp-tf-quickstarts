
# Cloudera on cloud Quickstart Using Terraform

This repository provides Terraform resources to quickly deploy **Cloudera on Cloud** and associated pre-requisite **Cloud Service Provider (CSP)** resources. It uses the [CDP Terraform Modules](https://github.com/cloudera-labs/terraform-cdp-modules) to do this.

A summary requirements, configuration and execution steps to use this repository is given below.

## ⚠️ Prerequisites

To use the module provided here, you will need:

* An AWS, Azure, or GCP Cloud account;
* A Cloudera on cloud account (you can sign up for a [60-day free pilot](https://www.cloudera.com/campaign/try-cdp-public-cloud.html) );
* A recent version of Terraform software (version 0.13 or higher).

## 🔧 Configure Local Prerequisites

* Terraform can be installed by following the instructions at https://developer.hashicorp.com/terraform/downloads.

* If you have not yet configured your `~/.cdp/credentials` file, follow the steps for [Generating an API access key](https://docs.cloudera.com/cdp-public-cloud/cloud/cli/topics/mc-cli-generating-an-api-access-key.html).

* To create resources in the Cloud Provider, access credentials or service account are needed for authentication.
  * For **AWS** access keys are required to be able to create the Cloud resources via the Terraform aws provider. See the [AWS documentation for Managing access keys](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html).
  * For **Azure**, authentication with the Azure subscription is required. There are a number of ways to do this outlined in the [Azure Terraform Provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure).
  * For **GCP**, authentication with the GCP API is required. There are a number of ways to do this outlined in the [Google Terraform Provider documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#authentication).

> [!NOTE]
> See the [Additional Authentication & Configuration Notes](#additional-authentication--configuration-notes) section for further details on authentication with the Cloud Providers.

## 📖 Quickstart Guide

> [!IMPORTANT]
> Make sure your Cloudera and you Cloud provider credentials are properly configured  before proceeding

### 1. Clone the Repository

```bash
git clone https://github.com/cloudera-labs/cdp-tf-quickstarts.git
cd cdp-tf-quickstarts
```

### 2. Configure Variables

Change to required cloud provider directory and create a `terraform.tfvars` file with variable configuration for your deployment.

Reference the `terraform.tfvars.template` in each cloud provider directory and the sample contents with indicators of values to change shown below.

> [!IMPORTANT]
> Ensure the value of the `env_prefix` variable is 12 characters or less in length and consist only of lowercase letters, numbers, and hyphens.

```bash
# Change into cloud provider directory, e.g. for aws
cd aws

cp terraform.tfvars.template terraform.tfvars

vi terraform.tfvars
```

<details>
    <summary><strong> Expand for AWS configuration file</strong></summary>

  ```yaml
  # ------- Global settings -------
  env_prefix = "<ENTER_VALUE>" # Required name prefix for cloud and CDP resources, e.g. cldr1

  # ------- Cloud Settings -------
  aws_region = "<ENTER_VALUE>" # Change this to specify Cloud Provider region, e.g. eu-west-1

  # ------- CDP Environment Deployment -------
  deployment_template = "<ENTER_VALUE>"  # Specify the deployment pattern below. Options are public, semi-private or private
  ```

</details>
<br>
<details>
    <summary><strong> Expand for Azure configuration file</strong></summary>

  ```yaml
  # ------- Global settings -------
  env_prefix = "<ENTER_VALUE>" # Required name prefix for cloud and CDP resources, e.g. cldr1

  # ------- Cloud Settings -------
  azure_region = "<ENTER_VALUE>" # Change this to specify Cloud Provider region, e.g. eastus

  # ------- CDP Environment Deployment -------
  deployment_template = "<ENTER_VALUE>"  # Specify the deployment pattern below. Options are public, semi-private or private
  ```

</details>
<br>
<details>
    <summary><strong> Expand for GCP configuration file</strong></summary>

  ```yaml
  # ------- Global settings -------
  env_prefix = "<ENTER_VALUE>" # Required name prefix for cloud and CDP resources, e.g. cldr1

  # ------- Cloud Settings -------
  gcp_project = "<ENTER_VALUE>" # Change this to specify the GCP Project ID

  gcp_region = "<ENTER_VALUE>" # Change this to specify Cloud Provider region, e.g. europe-west2

  # ------- CDP Environment Deployment -------
  deployment_template = "<ENTER_VALUE>"  # Specify the deployment pattern below. Options are public, semi-private or private
  ```

</details>

### 3. Deploy Infrastructure

```bash
terraform init
terraform apply
```

> ⏱️ **Note:** The deployment can take up to **60 minutes**.

### 4. Monitor Progress

You can follow the deployment process on the Cloudera on cloud Management Console from your browser at [cdp.cloudera.com](https://cdp.cloudera.com).

After it completes, you can add [Data Hubs and Data Services](https://docs.cloudera.com/cdp-public-cloud/cloud/overview/topics/cdp-services.html) to your newly deployed environment from the Management Console UI or using the CLI.

### Clean Up Resources

If you no longer need the infrastructure and Cloudera on cloud environment that's provisioned by Terraform, run the following command to remove the deployment infrastructure and terminate all resources.

```bash
terraform destroy
```

> ⏱️ **Note:** Cleanup of the deployment will take about 20 minutes.

## Additional Authentication & Configuration Notes

### SSH keys

By default the Terraform quickstarts will create a new SSH keypair that will be associated with all nodes provisioned by Cloudera on cloud. The private key will be stored in the `<env_prefix>-ssh-key.pem` file of the Terraform cloud provider project directory.

To use an existing SSH key, set the keypair name (for AWS) or public key text (for Azure and GCP) variable in the `terraform.tvars` file.

### Access to UI and API endpoints

The optional variable `ingress_extra_cidrs_and_ports` in the `terraform.tvars` file defines the list of client IP allowed to access - via ssh and https - the UI and API endpoints of your deployment.

When commented, this variable defaults to current public IP of the terraform client. In case this IP is a leased one - hence that might change overtime - you can uncomment this variable and set additional CIDRs or IP ranges via the `ingress_extra_cidrs_and_ports` variable.

### Notes on AWS authentication

* Details of the different methods to authenticate with AWS are available in the [aws Terraform provider docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration).

* The most common ways to specify AWS access and secret keys are:
  * via environment variables (i.e. setting the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`) or;
  * via shared configuration/credential files (e.g. the `$HOME/.aws/credentials` file). The `AWS_PROFILE` environment variable can be set to specify a named AWS profile.

* Note that the AWS region to use should always be specifed as a Terraform input variable (with the `aws_region` variable). This region variable is also used an input to the CDP deploy module used to identify the Cloud Provider region.

### Notes on Azure authentication

* Where you have more than one Azure Subscription the id to use can be passed via the the `ARM_SUBSCRIPTION_ID` environment variable.

* When using a Service Principal (SP) to authenticate with Azure, it is not possible to authenticate with azuread Terraform Provider (the provider used to create the Azure Cross Account AD Application) with the command az login --service-principal. We found the the best way to authenticate using an SP is by setting environment variables. Details of required environment variables are in the [azuread docs](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/guides/service_principal_client_secret#environment-variables) and [azurerm docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret#configuring-the-service-principal-in-terraform) and summarized below.

  ```bash
  export ARM_CLIENT_ID="<sp_client_id>"
  export ARM_CLIENT_SECRET="<sp_client_secret>"
  export ARM_TENANT_ID="<sp_tenant_id>"
  export ARM_SUBSCRIPTION_ID="<sp_subscription_id>" 
  ```

* The Azure API permissions listed are required by the provisioning account to create the Azure pre-requisite resources. Note that all permissions are of type Application (rather than Delegated).

| API Permission    | Purpose |
| ------------------| ------- |
| Microsoft Graph - Application.Read.All   | Read all applications |
| Microsoft Graph - Application.ReadWrite.All   | Read and write all applications |
| Microsoft Graph - Application.ReadWrite.OwnedBy | Manage apps that this app creates or owns |
| Microsoft Graph - Directory.ReadWrite.All | Read and write directory data |
| Microsoft Graph - User.Read.All | Read all users' full profiles |

### Notes on GCP authentication

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

* The Google project Id can be specified via the `gcp_project` input variable, the `GOOGLE_PROJECT` environment variable or the default project set via the Cloud SDK. This is described in the [Google Provider Default Values Configuration](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#provider-default-values-configuration) documentation.

### Add variables from Terraform module in the Quickstart module

By default, only common and required variables from the [terraform-cdp-modules](https://github.com/cloudera-labs/terraform-cdp-modules) are exposed in these quickstarts.

To expose an additional variable from any of the modules the process below can be followed. We use the [`freeipa_instance_type`](https://github.com/cloudera-labs/terraform-cdp-modules/tree/main/modules/terraform-cdp-deploy#input_freeipa_instance_type) variable from the terraform-cdp-deploy as an example to illustrate the steps.

1. Update the `variables.tf` file in the cloud specific root module with the variable declaration. Note that we give a default value of `null` to make this variable optional.

    ```hcl
    variable "freeipa_instance_type" {
      type = string

      description = "Instance Type to use for creating FreeIPA instances"

      default = null
    }
    ```

1. Update `main.tf` to pass the variable to the relevant module.

    ```hcl
    module "cdp_deploy" {
    source = "git::https://github.com/cloudera-labs/terraform-cdp-modules.git//modules/terraform-cdp-deploy?ref=v0.10.2"

    env_prefix          = var.
    ... <other input variables>

    # New variable
    freeipa_instance_type = var.freeipa_instance_type
    ```

1. To define a value for the variable, update `terraform.tfvars` and set as required.

    ```terraform-vars
    freeipa_instance_type = "m5.large"
    ```
