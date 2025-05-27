<!-- BEGIN_TF_DOCS -->
# Terraform root module for Cloudera on Azure Deployment

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | 2.46.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0 |
| <a name="requirement_cdp"></a> [cdp](#requirement\_cdp) | >= 0.6.1 |
| <a name="requirement_http"></a> [http](#requirement\_http) | ~> 3.2.1 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.5.1 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_http"></a> [http](#provider\_http) | ~> 3.2.1 |
| <a name="provider_local"></a> [local](#provider\_local) | ~> 2.5.1 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | ~> 4.0.5 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cdp_azure_prereqs"></a> [cdp\_azure\_prereqs](#module\_cdp\_azure\_prereqs) | git::https://github.com/cloudera-labs/terraform-cdp-modules.git//modules/terraform-cdp-azure-pre-reqs | v0.11.0 |
| <a name="module_cdp_deploy"></a> [cdp\_deploy](#module\_cdp\_deploy) | git::https://github.com/cloudera-labs/terraform-cdp-modules.git//modules/terraform-cdp-deploy | v0.11.0 |

## Resources

| Name | Type |
|------|------|
| [local_sensitive_file.pem_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file) | resource |
| [tls_private_key.cdp_private_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [http_http.my_ip](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_region"></a> [azure\_region](#input\_azure\_region) | Region which Cloud resources will be created | `string` | n/a | yes |
| <a name="input_deployment_template"></a> [deployment\_template](#input\_deployment\_template) | Deployment Pattern to use for Cloud resources and CDP | `string` | n/a | yes |
| <a name="input_env_prefix"></a> [env\_prefix](#input\_env\_prefix) | Shorthand name for the environment. Used in resource descriptions | `string` | n/a | yes |
| <a name="input_azure_subscription_id"></a> [azure\_subscription\_id](#input\_azure\_subscription\_id) | The subscription where the environment should be deployed to | `string` | `null` | no |
| <a name="input_cdp_delegated_subnet_names"></a> [cdp\_delegated\_subnet\_names](#input\_cdp\_delegated\_subnet\_names) | List of subnet names delegated for Flexible Servers. Required if create\_vnet is false. | `list(any)` | `null` | no |
| <a name="input_cdp_groups"></a> [cdp\_groups](#input\_cdp\_groups) | List of CDP Groups to be added to the IDBroker mappings of the environment. If create\_group is set to true then the group will be created. | <pre>set(object({<br/>    name                          = string<br/>    create_group                  = bool<br/>    sync_membership_on_user_login = optional(bool)<br/>    add_id_broker_mappings        = bool<br/>    })<br/>  )</pre> | `null` | no |
| <a name="input_cdp_gw_subnet_names"></a> [cdp\_gw\_subnet\_names](#input\_cdp\_gw\_subnet\_names) | List of subnet names for CDP Gateway. Required if create\_vnet is false. | `list(any)` | `null` | no |
| <a name="input_cdp_resourcegroup_name"></a> [cdp\_resourcegroup\_name](#input\_cdp\_resourcegroup\_name) | Pre-existing Resource Group for CDP environment. Required if create\_vnet is false. | `string` | `null` | no |
| <a name="input_cdp_subnet_names"></a> [cdp\_subnet\_names](#input\_cdp\_subnet\_names) | List of subnet names for CDP Resources. Required if create\_vnet is false. | `list(any)` | `null` | no |
| <a name="input_cdp_vnet_name"></a> [cdp\_vnet\_name](#input\_cdp\_vnet\_name) | Pre-existing VNet Name for CDP environment. Required if create\_vnet is false. | `string` | `null` | no |
| <a name="input_compute_cluster_configuration"></a> [compute\_cluster\_configuration](#input\_compute\_cluster\_configuration) | Kubernetes configuration for the externalized compute cluster | <pre>object({<br/>    kube_api_authorized_ip_ranges = optional(set(string))<br/>    outbound_type                 = optional(string)<br/>    private_cluster               = optional(bool)<br/>    worker_node_subnets           = optional(set(string))<br/>  })</pre> | `null` | no |
| <a name="input_compute_cluster_enabled"></a> [compute\_cluster\_enabled](#input\_compute\_cluster\_enabled) | Enable externalized compute cluster for the environment | `bool` | `false` | no |
| <a name="input_create_vnet"></a> [create\_vnet](#input\_create\_vnet) | Flag to specify if the VNet should be created | `bool` | `true` | no |
| <a name="input_datalake_async_creation"></a> [datalake\_async\_creation](#input\_datalake\_async\_creation) | Flag to specify if Terraform should wait for CDP datalake resource creation/deletion | `bool` | `false` | no |
| <a name="input_datalake_image"></a> [datalake\_image](#input\_datalake\_image) | The image to use for the datalake. Can only be used when 'datalake\_version' is null. | <pre>object({<br/>    id           = optional(string)<br/>    catalog_name = optional(string)<br/>    os           = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_datalake_recipes"></a> [datalake\_recipes](#input\_datalake\_recipes) | Additional recipes that will be attached on the datalake instances | <pre>set(<br/>    object({<br/>      instance_group_name = string,<br/>      recipe_names        = set(string)<br/>    })<br/>  )</pre> | `null` | no |
| <a name="input_datalake_scale"></a> [datalake\_scale](#input\_datalake\_scale) | The scale of the datalake. Valid values are LIGHT\_DUTY, ENTERPRISE. | `string` | `null` | no |
| <a name="input_datalake_version"></a> [datalake\_version](#input\_datalake\_version) | The Datalake Runtime version. Valid values are latest or a semantic version, e.g. 7.2.17 | `string` | `"latest"` | no |
| <a name="input_enable_raz"></a> [enable\_raz](#input\_enable\_raz) | Flag to enable Ranger Authorization Service (RAZ) | `bool` | `true` | no |
| <a name="input_env_tags"></a> [env\_tags](#input\_env\_tags) | Tags applied to pvovisioned resources | `map(any)` | `null` | no |
| <a name="input_environment_async_creation"></a> [environment\_async\_creation](#input\_environment\_async\_creation) | Flag to specify if Terraform should wait for CDP environment resource creation/deletion | `bool` | `false` | no |
| <a name="input_freeipa_recipes"></a> [freeipa\_recipes](#input\_freeipa\_recipes) | The recipes for the FreeIPA cluster | `set(string)` | `null` | no |
| <a name="input_ingress_extra_cidrs_and_ports"></a> [ingress\_extra\_cidrs\_and\_ports](#input\_ingress\_extra\_cidrs\_and\_ports) | List of extra CIDR blocks and ports to include in Security Group Ingress rules | <pre>object({<br/>    cidrs = list(string)<br/>    ports = list(number)<br/>  })</pre> | `null` | no |
| <a name="input_multiaz"></a> [multiaz](#input\_multiaz) | Flag to specify that the FreeIPA and DataLake instances will be deployed across multi-availability zones. | `bool` | `false` | no |
| <a name="input_public_key_text"></a> [public\_key\_text](#input\_public\_key\_text) | SSH Public key string for the nodes of the CDP environment | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azure_vnet_name"></a> [azure\_vnet\_name](#output\_azure\_vnet\_name) | Azure Virtual Network Name |
| <a name="output_cdp_environment_crn"></a> [cdp\_environment\_crn](#output\_cdp\_environment\_crn) | CDP Environment CRN |
| <a name="output_cdp_environment_name"></a> [cdp\_environment\_name](#output\_cdp\_environment\_name) | CDP Environment Name |
<!-- END_TF_DOCS -->