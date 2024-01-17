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

provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}


module "cdp_gcp_prereqs" {
  source = "git::https://github.com/cloudera-labs/terraform-cdp-modules.git//modules/terraform-cdp-gcp-pre-reqs?ref=v0.5.1"

  env_prefix = var.env_prefix
  gcp_region = var.gcp_region

  deployment_template = var.deployment_template

  ingress_extra_cidrs_and_ports = var.ingress_extra_cidrs_and_ports

  # Inputs for BYO-VPC
  create_vpc       = var.create_vpc
  cdp_vpc_name     = var.cdp_vpc_name
  cdp_subnet_names = var.cdp_subnet_names

}

module "cdp_deploy" {
  source = "git::https://github.com/cloudera-labs/terraform-cdp-modules.git//modules/terraform-cdp-deploy?ref=v0.5.1"

  env_prefix          = var.env_prefix
  infra_type          = "gcp"
  gcp_project_id      = var.gcp_project
  region              = var.gcp_region
  public_key_text     = var.public_key_text
  deployment_template = var.deployment_template

  # From pre-reqs module output
  gcp_network_name     = module.cdp_gcp_prereqs.gcp_vpc_name
  gcp_cdp_subnet_names = module.cdp_gcp_prereqs.gcp_cdp_subnet_names

  gcp_firewall_default_id = module.cdp_gcp_prereqs.gcp_firewall_default_name
  gcp_firewall_knox_id    = module.cdp_gcp_prereqs.gcp_firewall_knox_name

  data_storage_location   = module.cdp_gcp_prereqs.gcp_data_storage_location
  log_storage_location    = module.cdp_gcp_prereqs.gcp_log_storage_location
  backup_storage_location = module.cdp_gcp_prereqs.gcp_backup_storage_location

  gcp_xaccount_service_account_private_key = module.cdp_gcp_prereqs.gcp_xaccount_sa_private_key

  gcp_idbroker_service_account_email       = module.cdp_gcp_prereqs.gcp_idbroker_service_account_email
  gcp_datalake_admin_service_account_email = module.cdp_gcp_prereqs.gcp_datalake_admin_service_account_email
  gcp_ranger_audit_service_account_email   = module.cdp_gcp_prereqs.gcp_ranger_audit_service_account_email
  gcp_log_service_account_email            = module.cdp_gcp_prereqs.gcp_log_service_account_email

  depends_on = [
    module.cdp_gcp_prereqs
  ]
}
