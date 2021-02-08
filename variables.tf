variable "aks_node_resource_group" {
  description = "resource group created by AKS"
  type        = string
}

variable "aks_principal_id" {
  description = "principal id used to create AKS cluster"
  type        = string
}

variable "additional_scopes" {
  description = "aad pod identity scopes residing outside of AKS MC_resource_group (resource group id or identity id would be a common input)"
  type        = map(string)
  default     = {}
}

variable "helm_chart_version" {
  description = "Azure AD pod identity helm chart version"
  type        = string
  default     = "3.0.1"
}

variable "identities" {
  description = "Azure identites to be configured"
  type        = map(object({
                  namespace   = string 
                  name        = string
                  client_id   = string
                  resource_id = string
                }))
  default     = null
}

variable "additional_yaml_config" {
  default = ""
}
