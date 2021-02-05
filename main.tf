locals {
  identities = {
    for identity in var.identities:
      identity.name => {
        Namespace     = identity.namespace
        type          = "0"
        resourceID    = identity.resource_id
        clientID      = identity.client_id
        binding = {
          name     = "${identity.name}-binding"
          selector = identity.name
        }
      }
  }
}

data "azurerm_resource_group" "node_rg" {
  name = var.aks_node_resource_group
}

resource "azurerm_role_assignment" "k8s_virtual_machine_contributor" {
  scope                = data.azurerm_resource_group.node_rg.id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = var.aks_principal_id
}

resource "azurerm_role_assignment" "k8s_managed_identity_operator" {
  scope                = data.azurerm_resource_group.node_rg.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = var.aks_principal_id
}

resource "azurerm_role_assignment" "additional_managed_identity_operator" {
#  count                = length(var.additional_scopes)
#  scope                = var.additional_scopes[count.index]
  for_each             = var.additional_scopes
  scope                = each.value
  role_definition_name = "Managed Identity Operator"
  principal_id         = var.aks_principal_id
}

resource "helm_release" "aad_pod_identity" {
  depends_on = [azurerm_role_assignment.k8s_virtual_machine_contributor, azurerm_role_assignment.k8s_managed_identity_operator,azurerm_role_assignment.additional_managed_identity_operator]
  name       = "aad-pod-identity"
  namespace  = "kube-system"
  repository = "aad-pod-identity"
  chart      = "aad-pod-identity"
  version    = var.helm_chart_version

  values = [
    templatefile("${path.module}/config/aad-pod-identity.yaml.tmpl", {
        #identities = chomp(replace(indent(2, yamlencode(local.identities)), "/\"|{|}/", ""))
        identities = indent(2, yamlencode(local.identities))
    }),
    var.additional_yaml_config
  ]
}
