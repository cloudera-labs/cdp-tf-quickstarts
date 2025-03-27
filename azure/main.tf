# Copyright 2025 Cloudera, Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

terraform {
  required_version = ">= 1.5.7"
  required_providers {
    cdp = {
      source  = "cloudera/cdp"
      version = ">= 0.6.1"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.46.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.5"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.1"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.2.1"
    }
  }
}

provider "azurerm" {
  subscription_id = var.azure_subscription_id
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

}

provider "azuread" {
}

module "cdp_azure_prereqs" {
  source = "git::https://github.com/cloudera-labs/terraform-cdp-modules.git//modules/terraform-cdp-azure-pre-reqs?ref=v0.10.1"

  env_prefix   = var.env_prefix
  azure_region = var.azure_region

  deployment_template           = var.deployment_template
  ingress_extra_cidrs_and_ports = local.ingress_extra_cidrs_and_ports

  # Inputs for BYO-VNet
  create_vnet                = var.create_vnet
  cdp_resourcegroup_name     = var.cdp_resourcegroup_name
  cdp_vnet_name              = var.cdp_vnet_name
  cdp_subnet_names           = var.cdp_subnet_names
  cdp_gw_subnet_names        = var.cdp_gw_subnet_names
  cdp_delegated_subnet_names = var.cdp_delegated_subnet_names

  # Tags to apply resources (omitted by default)
  env_tags = var.env_tags

}

module "cdp_deploy" {
  source = "git::https://github.com/cloudera-labs/terraform-cdp-modules.git//modules/terraform-cdp-deploy?ref=v0.10.1"

  env_prefix          = var.env_prefix
  infra_type          = "azure"
  region              = var.azure_region
  public_key_text     = local.public_key_text
  deployment_template = var.deployment_template
  datalake_scale      = var.datalake_scale
  datalake_version    = var.datalake_version
  enable_raz          = var.enable_raz
  datalake_recipes    = var.datalake_recipes
  freeipa_recipes     = var.freeipa_recipes
  multiaz             = var.multiaz
  cdp_groups          = local.cdp_groups

  environment_async_creation = var.environment_async_creation
  datalake_async_creation    = var.datalake_async_creation

  # From pre-reqs module output
  azure_subscription_id = var.azure_subscription_id == null ? module.cdp_azure_prereqs.azure_subscription_id : var.azure_subscription_id
  azure_tenant_id       = module.cdp_azure_prereqs.azure_tenant_id

  azure_resource_group_name      = module.cdp_azure_prereqs.azure_resource_group_name
  azure_vnet_name                = module.cdp_azure_prereqs.azure_vnet_name
  azure_cdp_subnet_names         = module.cdp_azure_prereqs.azure_cdp_subnet_names
  azure_cdp_gateway_subnet_names = module.cdp_azure_prereqs.azure_cdp_gateway_subnet_names

  azure_environment_flexible_server_delegated_subnet_names = module.cdp_azure_prereqs.azure_cdp_flexible_server_delegated_subnet_names
  azure_database_private_dns_zone_id                       = module.cdp_azure_prereqs.azure_database_private_dns_zone_id

  azure_security_group_default_uri = module.cdp_azure_prereqs.azure_security_group_default_uri
  azure_security_group_knox_uri    = module.cdp_azure_prereqs.azure_security_group_knox_uri

  data_storage_location   = module.cdp_azure_prereqs.azure_data_storage_location
  log_storage_location    = module.cdp_azure_prereqs.azure_log_storage_location
  backup_storage_location = module.cdp_azure_prereqs.azure_backup_storage_location

  azure_xaccount_app_uuid  = module.cdp_azure_prereqs.azure_xaccount_app_uuid
  azure_xaccount_app_pword = module.cdp_azure_prereqs.azure_xaccount_app_pword

  azure_idbroker_identity_id      = module.cdp_azure_prereqs.azure_idbroker_identity_id
  azure_datalakeadmin_identity_id = module.cdp_azure_prereqs.azure_datalakeadmin_identity_id
  azure_ranger_audit_identity_id  = module.cdp_azure_prereqs.azure_ranger_audit_identity_id
  azure_log_identity_id           = module.cdp_azure_prereqs.azure_log_identity_id
  azure_raz_identity_id           = module.cdp_azure_prereqs.azure_raz_identity_id

  # Tags to apply resources (omitted by default)
  env_tags = var.env_tags

  depends_on = [
    module.cdp_azure_prereqs
  ]
}

# ------- Create SSH Keypair if input public_key_text variable is not specified
locals {
  # flag to determine if keypair should be created
  create_keypair = var.public_key_text == null ? true : false

  # key pair value
  public_key_text = (
    local.create_keypair == false ?
    var.public_key_text :
    tls_private_key.cdp_private_key[0].public_key_openssh
  )
}

# Create and save a RSA key
resource "tls_private_key" "cdp_private_key" {
  count     = local.create_keypair ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save the private key to ./<env_prefix>-ssh-key.pem
resource "local_sensitive_file" "pem_file" {
  count = local.create_keypair ? 1 : 0

  filename             = "${var.env_prefix}-ssh-key.pem"
  file_permission      = "600"
  directory_permission = "700"
  content              = tls_private_key.cdp_private_key[0].private_key_pem
}

# ------- Lookup public ip for ingress settings if ingress_extra_cidrs_and_ports variable is not specified
locals {
  # flag to determine if public ip of host should be used for ingress
  lookup_ip = var.ingress_extra_cidrs_and_ports == null ? true : false

  # ingress value
  ingress_extra_cidrs_and_ports = (
    local.lookup_ip == false ?
    var.ingress_extra_cidrs_and_ports :
    { cidrs = ["${chomp(data.http.my_ip[0].response_body)}/32"],
      ports = [443, 22]
    }
  )
}

# Perform lookup of public IP of executing host
data "http" "my_ip" {
  count = local.lookup_ip ? 1 : 0

  url = "https://ipv4.icanhazip.com"
}

# ------- Create default admin and user CDP group if input cdp_group variable is not specified
locals {
  # flag to determine if keypair should be created
  cdp_groups = var.cdp_groups != null ? var.cdp_groups : toset([
    {
      name                   = "${var.env_prefix}-az-cdp-admin-group"
      create_group           = true
      add_id_broker_mappings = true
    },
    {
      name                   = "${var.env_prefix}-az-cdp-user-group"
      create_group           = true
      add_id_broker_mappings = true
    }
  ])
}