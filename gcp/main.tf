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
  source = "git::https://github.com/cloudera-labs/terraform-cdp-modules.git//modules/terraform-cdp-gcp-pre-reqs?ref=v0.5.2"

  env_prefix = var.env_prefix
  gcp_region = var.gcp_region

  deployment_template = var.deployment_template

  ingress_extra_cidrs_and_ports = local.ingress_extra_cidrs_and_ports

  # Inputs for BYO-VPC
  create_vpc       = var.create_vpc
  cdp_vpc_name     = var.cdp_vpc_name
  cdp_subnet_names = var.cdp_subnet_names

}

module "cdp_deploy" {
  source = "git::https://github.com/cloudera-labs/terraform-cdp-modules.git//modules/terraform-cdp-deploy?ref=v0.5.2"

  env_prefix          = var.env_prefix
  infra_type          = "gcp"
  gcp_project_id      = var.gcp_project
  region              = var.gcp_region
  public_key_text     = local.public_key_text
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

  # Tags to apply resources (omitted by default)
  env_tags = var.env_tags

  depends_on = [
    module.cdp_gcp_prereqs
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
