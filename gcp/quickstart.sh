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

export TF_VAR_gcp_project=${1:-""}
export TF_VAR_gcp_region=${2:-""}
export TF_VAR_env_prefix=${3:-""}
export TF_VAR_public_key_text=${4:-""}
export TF_VAR_deployment_template=${5:-""}
export TF_VAR_ingress_extra_cidrs_and_ports=${6:-""}

# Checkout CDP Quickstart Repository
git clone --branch v0.4.0 https://github.com/cloudera-labs/cdp-tf-quickstarts.git
cd cdp-tf-quickstarts/gcp

# Install CDP CLI and Log In
pip install cdpcli

cdp login

# Apply Terraform Quickstart Module
terraform init

terraform apply