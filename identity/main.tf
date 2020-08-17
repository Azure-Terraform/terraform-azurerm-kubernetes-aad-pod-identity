resource "helm_release" "identity" {
  count      = (var.install_type == "helm" ? 1 : 0)
  name       = (var.helm_name != "" ? var.helm_name : "pod-id-${var.identity_name}")
  chart      = "${path.module}/chart"

  set {
    name  = "azureIdentity.name"
    value = var.identity_name
  }

  set {
    name  = "azureIdentity.resourceID"
    value = var.identity_resource_id
  }

  set {
    name  = "azureIdentity.clientID"
    value = var.identity_client_id
  }

  set {
    name  = "azureIdentityBinding.name"
    value = "${var.identity_name}-binding"
  }

  set {
    name  = "azureIdentityBinding.selector"
    value = var.identity_name
  }

}

resource "github_repository_file" "identity_resource" {
  count      = (var.install_type == "flux_github" ? 1 : 0)
  repository = var.flux_git_repo
  branch     = var.flux_git_branch
  file       = "${var.flux_project_path}/terraform/namespaces/${var.namespace}/identity-${var.identity_name}.yaml"
  content    = templatefile("${path.module}/identity.yaml.tmpl", {
                 name = var.identity_name
                 namespace = var.namespace
                 flux_run_level = var.flux_run_level
                 resource_id = var.identity_resource_id
                 client_id = var.identity_client_id
               })
  commit_message = "terraform - AzureIdentity - ${var.namespace}/${var.identity_name}"
}
