variable "identity_name" {
  description = "name for Azure identity to be used by AAD"
  type        = string
}

variable "namespace" {
  description = "kubernetes namespace in which to create identity"
  type        = string
  default     = "default"
}

variable "create_namespace" {
  description = "Create the namespace for the identity if it doesn't yet exist"
  type        = bool
  default     = true
}

variable "identity_client_id" {
  description = "client id of the managed identity"
  type        = string
}

variable "identity_resource_id" {
  description = "resource id of the managed identity"
  type        = string
}

variable "helm_name" {
  description = "name of helm installation (defaults to pod-id-<identity_name>"
  type        = string
  default     = null
}
