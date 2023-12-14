# Copyright 2023 Cloudera, Inc. All Rights Reserved.
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

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

}

provider "azuread" {
}

module "cdp_azure_prereqs" {
  source = "git::https://github.com/cloudera-labs/terraform-cdp-modules.git//modules/terraform-cdp-azure-pre-reqs?ref=v0.5.0"

  env_prefix   = var.env_prefix
  azure_region = var.azure_region

  deployment_template           = var.deployment_template
  ingress_extra_cidrs_and_ports = var.ingress_extra_cidrs_and_ports

  # Inputs for BYO-VNet
  create_vnet            = var.create_vnet
  cdp_resourcegroup_name = var.cdp_resourcegroup_name
  cdp_vnet_name          = var.cdp_vnet_name
  cdp_subnet_names       = var.cdp_subnet_names
  cdp_gw_subnet_names    = var.cdp_gw_subnet_names

}

module "cdp_deploy" {
  source = "git::https://github.com/cloudera-labs/terraform-cdp-modules.git//modules/terraform-cdp-deploy?ref=v0.5.0"

  env_prefix          = var.env_prefix
  infra_type          = "azure"
  region              = var.azure_region
  public_key_text     = var.public_key_text
  deployment_template = var.deployment_template

  # From pre-reqs module output
  azure_subscription_id = module.cdp_azure_prereqs.azure_subscription_id
  azure_tenant_id       = module.cdp_azure_prereqs.azure_tenant_id

  azure_resource_group_name      = module.cdp_azure_prereqs.azure_resource_group_name
  azure_vnet_name                = module.cdp_azure_prereqs.azure_vnet_name
  azure_cdp_subnet_names         = module.cdp_azure_prereqs.azure_cdp_subnet_names
  azure_cdp_gateway_subnet_names = module.cdp_azure_prereqs.azure_cdp_gateway_subnet_names

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

  depends_on = [
    module.cdp_azure_prereqs
  ]
}
