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
  profile = var.aws_profile
  region  = var.aws_region
}

module "cdp_aws_prereqs" {
  source = "../../terraform-cdp-modules/modules/terraform-cdp-aws-pre-reqs"
  # source = "git::https://github.com/cloudera-labs/terraform-cdp-modules.git//modules/terraform-cdp-aws-pre-reqs"

  env_prefix = var.env_prefix
  aws_region = var.aws_region

  deployment_template = var.deployment_template
  cdp_profile         = var.cdp_profile

  ingress_extra_cidrs_and_ports = var.ingress_extra_cidrs_and_ports
}

module "cdp_deploy" {
  source = "../../terraform-cdp-modules/modules/terraform-cdp-deploy"
  # source = "git::https://github.com/jimright/terraform-cdp-modules.git//modules/terraform-cdp-deploy?ref=feature/azure_pre_reqs_and_cdp_modules"
  # source = "git::https://github.com/cloudera-labs/terraform-cdp-modules.git//modules/terraform-cdp-deploy?ref="

  env_prefix          = var.env_prefix
  infra_type          = "aws"
  region              = var.aws_region
  keypair_name        = var.aws_key_pair
  deployment_template = var.deployment_template

  # From pre-reqs module output
  aws_vpc_id = module.cdp_aws_prereqs.aws_vpc_id
  aws_public_subnet_ids = module.cdp_aws_prereqs.aws_public_subnet_ids
  aws_private_subnet_ids = module.cdp_aws_prereqs.aws_private_subnet_ids

  aws_security_group_default_id = module.cdp_aws_prereqs.aws_security_group_default_id
  aws_security_group_knox_id    = module.cdp_aws_prereqs.aws_security_group_knox_id

  data_storage_location   = module.cdp_aws_prereqs.aws_data_storage_location
  log_storage_location    = module.cdp_aws_prereqs.aws_log_storage_location
  backup_storage_location = module.cdp_aws_prereqs.aws_backup_storage_location

  aws_xaccount_role_arn  = module.cdp_aws_prereqs.aws_xaccount_role_arn
  aws_datalake_admin_role_arn  = module.cdp_aws_prereqs.aws_datalake_admin_role_arn
  aws_ranger_audit_role_arn      = module.cdp_aws_prereqs.aws_ranger_audit_role_arn

  aws_log_instance_profile_arn  = module.cdp_aws_prereqs.aws_log_instance_profile_arn
  aws_idbroker_instance_profile_arn = module.cdp_aws_prereqs.aws_idbroker_instance_profile_arn

  depends_on = [
    module.cdp_aws_prereqs
  ]
}
