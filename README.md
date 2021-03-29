# terraform-azurerm-kubernetes-aad-pod-identity

## Introduction

AAD Pod Identity enables Kubernetes applications to access cloud resources securely with Azure Active Directory.
This module will install/configure the helm chart in AKS.
<br />

<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0 |
| helm | >= 2.0.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | n/a |
| helm | >= 2.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_scopes | aad pod identity scopes residing outside of AKS MC\_resource\_group (resource group id or identity id would be a common input) | `map(string)` | `{}` | no |
| additional\_yaml\_config | n/a | `string` | `""` | no |
| aks\_identity | Service principal client\_id or kubelet identity client\_id. See [here](https://github.com/Azure/aad-pod-identity/blob/master/website/content/en/docs/Getting%20started/role-assignment.md) | `string` | n/a | yes |
| aks\_node\_resource\_group | resource group created by AKS | `string` | n/a | yes |
| enable\_kubenet\_plugin | Enable feature when AKS cluster is uses Kubenet for CNI, leave default if use AzureCNI | `bool` | `"false"` | no |
| helm\_chart\_version | Azure AD pod identity helm chart version | `string` | `"3.0.1"` | no |
| identities | Azure identites to be configured | <pre>map(object({<br>                  namespace   = string <br>                  name        = string<br>                  client_id   = string<br>                  resource_id = string<br>                }))</pre> | `null` | no |
| install\_crds | Install CRDs | `bool` | `true` | no |

## Outputs

No output.

<!--- END_TF_DOCS --->
