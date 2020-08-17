variable "install_type" {
  description = "method by which to install identity (helm/flux_github)"
  type        = string

  validation {
    condition     = can(regex("helm|flux_git", var.install_type))
    error_message = "The install_type value must be \"helm\" or \"flux_github\"."
  }
}

variable "identity_name" {
  description = "name for Azure identity to be used by AAD"
  type        = string
}

variable "namespace" {
  description = "kubernetes namespace in which to create identity"
  type        = string
  default     = "default"
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
  default     = ""
}

variable "flux_git_repo" {
  description = "git repository within organization (github.com/<organization>/<repo>)"
  type        = string
  default     = ""
}

variable "flux_git_branch" {
  description = "git branch"
  type        = string
  default     = "master"
}

variable "flux_project_path" {
  description = "flux project path within repository"
  type        = string
  default     = ""
}

variable "flux_run_level" {
  description = "flux run level for kubernetes resource"
  type        = number
  default     = "1"
}
