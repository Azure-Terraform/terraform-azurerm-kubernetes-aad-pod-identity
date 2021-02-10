terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.32.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "=2.3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "=1.13.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "=2.0.2"
    }
  }
   required_version = "=0.13.5"
}

provider "azurerm" {
  features {}
}

provider "kubernetes" {
  host                   = module.kubernetes.host
  client_certificate     = base64decode(module.kubernetes.client_certificate)
  client_key             = base64decode(module.kubernetes.client_key)
  cluster_ca_certificate = base64decode(module.kubernetes.cluster_ca_certificate)
  load_config_file       = false
}

provider "helm" {
  kubernetes {
    host                   = module.kubernetes.host
    client_certificate     = base64decode(module.kubernetes.client_certificate)
    client_key             = base64decode(module.kubernetes.client_key)
    cluster_ca_certificate = base64decode(module.kubernetes.cluster_ca_certificate)
  }
}

data "http" "my_ip" {
  url = "http://ipv4.icanhazip.com"
}

resource "random_string" "random" {
  length  = 12
  upper   = false
  number  = false
  special = false
}

data "azurerm_subscription" "current" {
}

module "subscription" {
  source = "github.com/Azure-Terraform/terraform-azurerm-subscription-data.git?ref=v1.0.0"
  subscription_id = data.azurerm_subscription.current.subscription_id
}

module "naming" {
  source = "github.com/Azure-Terraform/example-naming-template.git?ref=v1.0.0"
}

module "metadata" {
  source = "github.com/Azure-Terraform/terraform-azurerm-metadata.git?ref=v1.1.0"

  naming_rules = module.naming.yaml

  market              = "us"
  project             = "https://github.com/Azure-Terraform/terraform-azurerm-kubernetes-aad-pod-identity/tree/master/example"
  location            = "eastus2"
  environment         = "sandbox"
  product_name        = random_string.random.result
  business_unit       = "infra"
  product_group       = "contoso"
  subscription_id     = module.subscription.output.subscription_id
  subscription_type   = "dev"
  resource_group_type = "app"
}

module "resource_group" {
  source = "github.com/Azure-Terraform/terraform-azurerm-resource-group.git?ref=v1.0.0"

  location = module.metadata.location
  names    = module.metadata.names
  tags     = module.metadata.tags
}

module "virtual_network" {
  source = "github.com/Azure-Terraform/terraform-azurerm-virtual-network.git?ref=v2.3.1"

  naming_rules = module.naming.yaml

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  names               = module.metadata.names
  tags                = module.metadata.tags

  address_space = ["10.1.0.0/22"]

  subnets = {
    "iaas-public"  = { cidrs                   = ["10.1.1.0/24"]
                       service_endpoints       = ["Microsoft.Storage"]
                       allow_lb_inbound        = true    # Allow traffic from Azure Load Balancer to pods
                       allow_internet_outbound = true }  # Allow traffic to Internet for image download
  }
}

module "storage_account" {
  source = "github.com/Azure-Terraform/terraform-azurerm-storage-account.git?ref=v0.3.0"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  names               = module.metadata.names
  tags                = module.metadata.tags

  account_kind     = "StorageV2"
  replication_type = "LRS"

  access_list = {
    "my_ip"      = chomp(data.http.my_ip.body)
  }

  service_endpoints = {
    "iaas-public" = module.virtual_network.subnet["iaas-public"].id
  }
}

resource "azurerm_storage_container" "content" {
  name                  = "content"
  storage_account_name  = module.storage_account.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "custom" {
  name                   = "custom.html"
  storage_account_name   = module.storage_account.name
  storage_container_name = azurerm_storage_container.content.name
  type                   = "Block"
  source_content         = <<-EOT
<!DOCTYPE html>
<html>
<body>
<h1>Custom HTML</h1>
<p>This file was copied from an Azure Blob.</p>
</body>
</html>
EOT
}

module "kubernetes" {
  source = "github.com/Azure-Terraform/terraform-azurerm-kubernetes.git?ref=v1.6.1"

  kubernetes_version = "1.18.10"

  location                 = module.metadata.location
  names                    = module.metadata.names
  tags                     = module.metadata.tags
  resource_group_name      = module.resource_group.name

  use_service_principal = false

  default_node_pool_name                = "default"
  default_node_pool_vm_size             = "Standard_B2s"
  default_node_pool_enable_auto_scaling = true
  default_node_pool_node_min_count      = 1
  default_node_pool_node_max_count      = 3
  default_node_pool_availability_zones  = [1,2,3]
  default_node_pool_subnet              = "public"

  network_plugin             = "azure"
  aks_managed_vnet           = false
  configure_subnet_nsg_rules = true

  node_pool_subnets = {
    public = {
      id                  = module.virtual_network.subnet["iaas-public"].id
      resource_group_name = module.virtual_network.vnet.resource_group_name
      security_group_name = module.virtual_network.subnet_nsg_names["iaas-public"]
    }
  }
}

module "aad_pod_identity" {
  source = "../"

  depends_on = [ module.kubernetes, azurerm_user_assigned_identity.nginx ]

  helm_chart_version = "3.0.1"

  aks_node_resource_group = module.kubernetes.node_resource_group
  additional_scopes       = {parent_rg = module.resource_group.id}

  aks_principal_id = module.kubernetes.principal_id

  identities = {
    nginx = {
      name        = azurerm_user_assigned_identity.nginx.name
      namespace   = "default"
      client_id   = azurerm_user_assigned_identity.nginx.client_id
      resource_id = azurerm_user_assigned_identity.nginx.id
    }
  }
       
}

resource "azurerm_user_assigned_identity" "nginx" {
  name                = "${module.metadata.names.product_group}-${module.metadata.names.subscription_type}-nginx"
  resource_group_name = module.resource_group.name
  location            = module.metadata.location
  tags                = module.metadata.tags
}

resource "azurerm_role_assignment" "blob_reader" {
  depends_on = [ azurerm_user_assigned_identity.nginx ]

  scope                = azurerm_storage_container.content.resource_manager_id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_user_assigned_identity.nginx.principal_id
}

resource "helm_release" "nginx_blob_test" {
  depends_on = [ module.aad_pod_identity, azurerm_role_assignment.blob_reader ]

  name       = "nginx-blob-test"
  chart      = "./helm_chart"
  timeout    = 90

  set {
    name  = "identity"
    value = azurerm_user_assigned_identity.nginx.name
  }

  set {
    name  = "url"
    value = azurerm_storage_blob.custom.url
  }
}

data "kubernetes_service" "nginx" {
  depends_on = [helm_release.nginx_blob_test] 
  metadata {
    name = "nginx"
  }
}

resource "azurerm_network_security_rule" "ingress_public_allow_nginx" {
  name                        = "AllowNginx"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "Internet"
  destination_address_prefix  = data.kubernetes_service.nginx.load_balancer_ingress.0.ip
  resource_group_name         = module.resource_group.name
  network_security_group_name = module.virtual_network.subnet_nsg_names["iaas-public"]
}

output "nginx_url" {
  value = "http://${data.kubernetes_service.nginx.load_balancer_ingress.0.ip}"
}

output "aks_login" {
  value = "az aks get-credentials --name ${module.kubernetes.name} --resource-group ${module.resource_group.name}"
}
