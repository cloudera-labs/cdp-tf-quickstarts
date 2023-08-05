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

# ------- Global settings -------
variable "aws_profile" {
  type        = string
  description = "Profile for AWS cloud credentials"

  # Profile is default unless explicitly specified
  default = "default"
}

variable "aws_region" {
  type        = string
  description = "Region which Cloud resources will be created"
}

variable "env_prefix" {
  type        = string
  description = "Shorthand name for the environment. Used in resource descriptions"
}

variable "aws_key_pair" {
  type = string

  description = "Name of the Public SSH key for the CDP environment"

}

# ------- CDP Environment Deployment -------
variable "deployment_template" {
  type = string

  description = "Deployment Pattern to use for Cloud resources and CDP"
}

# ------- Network Resources -------
variable "ingress_extra_cidrs_and_ports" {
  type = object({
    cidrs = list(string)
    ports = list(number)
  })
  description = "List of extra CIDR blocks and ports to include in Security Group Ingress rules"
}

# ------- Optional inputs for BYO-VPC -------
variable "create_vpc" {
  type = bool

  description = "Flag to specify if the VPC should be created"

  default = true
}

variable "cdp_vpc_id" {
  type        = string
  description = "VPC ID for CDP environment. Required if create_vpc is false."

  default = null
}

variable "cdp_public_subnet_ids" {
  type        = list(any)
  description = "List of public subnet ids. Required if create_vpc is false."

  default = null
}

variable "cdp_private_subnet_ids" {
  type        = list(any)
  description = "List of private subnet ids. Required if create_vpc is false."

  default = null
}

# ------- Optional inputs for Control Plane Connectivity in fully private environment -------
variable "private_network_extensions" {
  type = bool

  description = "Enable creation of resources for connectivity to CDP Control Plane (public subnet and NAT Gateway) for Private Deployment. Only relevant for private deployment template"

  default = true
}