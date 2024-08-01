#!/bin/bash

# Copyright 2024 Cloudera, Inc. All Rights Reserved.
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

export TF_VAR_aws_region="${1:-""}"
export TF_VAR_env_prefix="${2:-""}"
export ACCOUNT_ID="${3:-""}"
export CDP_REGION="${4:-"us-west-1"}"
export TF_VAR_deployment_template="${5:-"semi-private"}"
export TF_VAR_ingress_extra_cidrs_and_ports="${6:-"{ cidrs = [\"0.0.0.0/0\"], ports = [443, 22] }"}"
export TF_VAR_env_tags='{"deploy_tool": "express-tf", "env_prefix": "'"$2"'"}'
export TF_VAR_create_vpc_endpoints="false"
export TF_VAR_environment_async_creation="true"
export TF_VAR_datalake_async_creation="true"

# Save TF variables to file
output_file="variables.sh"

cat <<EOF > $output_file
export TF_VAR_aws_region="${TF_VAR_aws_region}"
export TF_VAR_env_prefix="${TF_VAR_env_prefix}"
export ACCOUNT_ID="${ACCOUNT_ID}"
export TF_VAR_deployment_template="${TF_VAR_deployment_template}"
export TF_VAR_env_tags="${TF_VAR_env_tags}"
export TF_VAR_create_vpc_endpoints="${TF_VAR_create_vpc_endpoints}"
export TF_VAR_environment_async_creation="${TF_VAR_environment_async_creation}"
export TF_VAR_datalake_async_creation="${TF_VAR_datalake_async_creation}"
export TF_VAR_ingress_extra_cidrs_and_ports="${TF_VAR_ingress_extra_cidrs_and_ports}"
EOF

# Make the file executable
chmod +x $output_file

# Install Terraform
curl -fsSL https://releases.hashicorp.com/terraform/1.7.1/terraform_1.7.1_linux_amd64.zip -o terraform.zip
unzip -o terraform.zip -d ${HOME}
rm terraform.zip

# Checkout CDP Quickstart Repository
git clone --branch v0.7.2 https://github.com/cloudera-labs/cdp-tf-quickstarts.git
cd cdp-tf-quickstarts/aws

# Install CDP CLI and Log In
pip install cdpcli

config_file="${HOME}/.cdp/config"
region_config="cdp_region = ${CDP_REGION}"
echo "$region_config" >> "$config_file"

cdp login --account-id "${ACCOUNT_ID}" --use-device-code

# Apply Terraform Quickstart Module
${HOME}/terraform init

${HOME}/terraform apply -auto-approve