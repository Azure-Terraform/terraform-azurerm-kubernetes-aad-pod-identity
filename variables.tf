variable "aks_node_resource_group" {
  description = "resource group created by AKS"
  type        = string
}

variable "aks_identity" {
  description = "Service principal client_id or kubelet identity client_id. See [here](https://github.com/Azure/aad-pod-identity/blob/master/website/content/en/docs/Getting%20started/role-assignment.md)."
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
  default     = "3.0.3"
}

variable "install_crds" {
  description = "Install CRDs"
  type        = bool
  default     = true
}

variable "create_namespace" {
  description = "Create the namespace for the identity if it doesn't yet exist"
  type        = bool
  default     = true
}

variable "identities" {
  description = "Azure identities to be configured"
  type = map(object({
    namespace   = string
    name        = string
    client_id   = string
    resource_id = string
  }))
  default = null
}

variable "enable_kubenet_plugin" {
  description = "Enable feature when AKS cluster uses Kubenet network plugin, leave default if use AzureCNI"
  type        = bool
  default     = false
}

variable "additional_yaml_config" {
  default = ""
}
