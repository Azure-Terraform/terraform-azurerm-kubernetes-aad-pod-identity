# terraform-azurerm-kubernetes-aad-pod-identity

## Introduction

AAD Pod Identity enables Kubernetes applications to access cloud resources securely with Azure Active Directory.
This module will install/configure the helm chart in AKS.
<br />

<!--- BEGIN_TF_DOCS --->
## Providers

| Name | Version |
|------|---------|
| azurerm | n/a |
| helm | >= 1.2.4 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| additional\_scopes | aad pod identity scopes residing outside of AKS MC\_resource\_group (resource group id or identity id would be a common input) | `list(string)` | `[]` | no |
| aks\_node\_resource\_group | resource group created by AKS | `string` | n/a | yes |
| aks\_principal\_id | principal id used to create AKS cluster | `string` | n/a | yes |
| helm\_chart\_version | Azure AD pod identity helm chart version | `string` | `"2.0.0"` | no |

## Outputs

No output.
<!--- END_TF_DOCS --->
