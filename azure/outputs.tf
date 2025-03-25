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

output "cdp_environment_name" {
  value = module.cdp_deploy.cdp_environment_name

  description = "CDP Environment Name"

}

output "cdp_environment_crn" {
  value = module.cdp_deploy.cdp_environment_crn

  description = "CDP Environment CRN"

}

output "azure_vnet_name" {
  value = module.cdp_azure_prereqs.azure_vnet_name

  description = "Azure Virtual Network Name"
}
