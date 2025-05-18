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

# ------- Global settings -------
variable "env_prefix" {
  type        = string
  description = "Shorthand name for the environment. Used in resource descriptions"

  validation {
    condition     = length(var.env_prefix) <= 12
    error_message = "The length of env_prefix must be 12 characters or less."
  }
  validation {
    condition     = (var.env_prefix == null ? true : can(regex("^[a-z0-9-]{1,12}$", var.env_prefix)))
    error_message = "env_prefix can consist only of lowercase letters, numbers, and hyphens (-)."
  }

}

variable "gcp_project" {
  type        = string
  description = "Region which Cloud resources will be created. Can also be set via gcloud project default or environment variable."

  default = null
}

variable "gcp_region" {
  type        = string
  description = "Region which Cloud resources will be created"
}

variable "public_key_text" {
  type = string

  description = "SSH Public key string for the nodes of the CDP environment"

  default = null
}

variable "env_tags" {
  type        = map(any)
  description = "Tags applied to pvovisioned resources"

  default = null
}

# ------- CDP Environment Deployment -------
variable "deployment_template" {
  type = string

  description = "Deployment Pattern to use for Cloud resources and CDP"

  validation {
    condition     = contains(["public", "semi-private", "private"], var.deployment_template)
    error_message = "Valid values for var: deployment_template are (public, semi-private, private)."
  }
}

variable "environment_async_creation" {
  type = bool

  description = "Flag to specify if Terraform should wait for CDP environment resource creation/deletion"

  default = false
}

variable "datalake_async_creation" {
  type = bool

  description = "Flag to specify if Terraform should wait for CDP datalake resource creation/deletion"

  default = false
}

variable "datalake_scale" {
  type = string

  description = "The scale of the datalake. Valid values are LIGHT_DUTY, ENTERPRISE."

  validation {
    condition     = (var.datalake_scale == null ? true : contains(["LIGHT_DUTY", "ENTERPRISE", "MEDIUM_DUTY_HA"], var.datalake_scale))
    error_message = "Valid values for var: datalake_scale are (LIGHT_DUTY, ENTERPRISE, MEDIUM_DUTY_HA)."
  }

  default = null

}

variable "datalake_version" {
  type = string

  description = "The Datalake Runtime version. Valid values are latest or a semantic version, e.g. 7.2.17"

  validation {
    condition = (var.datalake_version == null ? true :
      (var.datalake_version == "latest" ? true :
    length(regexall("\\d+\\.\\d+.\\d+", var.datalake_version)) > 0))
    error_message = "Valid values for var: datalake_version are 'latest' or a semantic versioning conventions."
  }

  default = "latest"
}

variable "freeipa_recipes" {
  type = set(string)

  description = "The recipes for the FreeIPA cluster"

  default = null
}

variable "datalake_recipes" {
  type = set(
    object({
      instance_group_name = string,
      recipe_names        = set(string)
    })
  )

  description = "Additional recipes that will be attached on the datalake instances"

  default = null
}

variable "enable_raz" {
  type = bool

  description = "Flag to enable Ranger Authorization Service (RAZ)"

  default = true
}

variable "cdp_groups" {
  type = set(object({
    name                          = string
    create_group                  = bool
    sync_membership_on_user_login = optional(bool)
    add_id_broker_mappings        = bool
    })
  )

  description = "List of CDP Groups to be added to the IDBroker mappings of the environment. If create_group is set to true then the group will be created."

  validation {
    condition = (var.cdp_groups == null ? true : alltrue([
      for grp in var.cdp_groups :
      length(grp.name) >= 1 && length(grp.name) <= 64
    ]))
    error_message = "The length of all CDP group names must be 64 characters or less."
  }
  validation {
    condition = (var.cdp_groups == null ? true : alltrue([
      for grp in var.cdp_groups :
      can(regex("^[a-zA-Z0-9\\-\\_\\.]{1,90}$", grp.name))
    ]))
    error_message = "CDP group names can consist only of letters, numbers, dots (.), hyphens (-) and underscores (_)."
  }

  default = null
}
# ------- Network Resources -------
variable "ingress_extra_cidrs_and_ports" {
  type = object({
    cidrs = list(string)
    ports = list(number)
  })
  description = "List of extra CIDR blocks and ports to include in Security Group Ingress rules"

  default = null
}

# ------- Optional inputs for BYO-VPC -------
variable "create_vpc" {
  type = bool

  description = "Flag to specify if the VPC should be created"

  default = true
}

variable "cdp_vpc_name" {
  type        = string
  description = "Pre-existing VPC Name for CDP environment. Required if create_vpc is false."

  default = null
}

variable "cdp_subnet_names" {
  type        = list(any)
  description = "List of subnet names for CDP Resources. Required if create_vpc is false."

  default = null
}

variable "datalake_image" {
  type = object({
    id           = optional(string)
    catalog_name = optional(string)
    os           = optional(string)
  })
  description = "The image to use for the datalake. Can only be used when 'datalake_version' is null."
  default     = null
}
