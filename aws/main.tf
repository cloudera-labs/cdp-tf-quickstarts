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

provider "aws" {
  region = var.aws_region
}

module "cdp_aws_prereqs" {
  source = "git::https://github.com/cloudera-labs/terraform-cdp-modules.git//modules/terraform-cdp-aws-pre-reqs?ref=v0.5.2"

  env_prefix = var.env_prefix
  aws_region = var.aws_region

  deployment_template           = var.deployment_template
  ingress_extra_cidrs_and_ports = local.ingress_extra_cidrs_and_ports

  # Using CDP TF Provider cred pre-reqs data source for values of xaccount account_id and external_id
  xaccount_account_id  = data.cdp_environments_aws_credential_prerequisites.cdp_prereqs.account_id
  xaccount_external_id = data.cdp_environments_aws_credential_prerequisites.cdp_prereqs.external_id

  # Inputs for BYO-VPC
  create_vpc             = var.create_vpc
  cdp_vpc_id             = var.cdp_vpc_id
  cdp_public_subnet_ids  = var.cdp_public_subnet_ids
  cdp_private_subnet_ids = var.cdp_private_subnet_ids

  # Inputs for Control Plane Connectivity in fully private 
  private_network_extensions = var.private_network_extensions

  # Tags to apply resources (omitted by default)
  env_tags = var.env_tags
}

module "cdp_deploy" {
  source = "git::https://github.com/cloudera-labs/terraform-cdp-modules.git//modules/terraform-cdp-deploy?ref=v0.5.2"

  env_prefix          = var.env_prefix
  infra_type          = "aws"
  region              = var.aws_region
  keypair_name        = local.aws_key_pair
  deployment_template = var.deployment_template

  # From pre-reqs module output
  aws_vpc_id             = module.cdp_aws_prereqs.aws_vpc_id
  aws_public_subnet_ids  = module.cdp_aws_prereqs.aws_public_subnet_ids
  aws_private_subnet_ids = module.cdp_aws_prereqs.aws_private_subnet_ids

  aws_security_group_default_id = module.cdp_aws_prereqs.aws_security_group_default_id
  aws_security_group_knox_id    = module.cdp_aws_prereqs.aws_security_group_knox_id

  data_storage_location   = module.cdp_aws_prereqs.aws_data_storage_location
  log_storage_location    = module.cdp_aws_prereqs.aws_log_storage_location
  backup_storage_location = module.cdp_aws_prereqs.aws_backup_storage_location

  aws_xaccount_role_arn       = module.cdp_aws_prereqs.aws_xaccount_role_arn
  aws_datalake_admin_role_arn = module.cdp_aws_prereqs.aws_datalake_admin_role_arn
  aws_ranger_audit_role_arn   = module.cdp_aws_prereqs.aws_ranger_audit_role_arn

  aws_log_instance_profile_arn      = module.cdp_aws_prereqs.aws_log_instance_profile_arn
  aws_idbroker_instance_profile_arn = module.cdp_aws_prereqs.aws_idbroker_instance_profile_arn

  # Tags to apply resources (omitted by default)
  env_tags = var.env_tags

  depends_on = [
    module.cdp_aws_prereqs
  ]
}

# Use the CDP Terraform Provider to find the xaccount account and external ids
terraform {
  required_providers {
    cdp = {
      source  = "cloudera/cdp"
      version = "0.4.2"
    }
  }
}
data "cdp_environments_aws_credential_prerequisites" "cdp_prereqs" {}


# ------- Create SSH Keypair if input aws_key_pair variable is not specified
locals {
  # flag to determine if keypair should be created
  create_keypair = var.aws_key_pair == null ? true : false

  # key pair value
  aws_key_pair = (
    local.create_keypair == false ?
    var.aws_key_pair :
    aws_key_pair.cdp_keypair[0].key_name
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

# Create an AWS EC2 keypair from the generated public key
resource "aws_key_pair" "cdp_keypair" {
  count = local.create_keypair ? 1 : 0

  key_name   = "${var.env_prefix}-keypair"
  public_key = tls_private_key.cdp_private_key[0].public_key_openssh
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
