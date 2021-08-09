##*Subject -  Create AKS Cluster


#Add Azure Provider
provider "azurerm" {
    
    client_id       =   var.client_id
    client_secret   =   var.client_secret
    subscription_id =   var.subscription_id
    tenant_id       =   var.tenant_id

    features {}
}


#Create Resource Group
resource "azurerm_resource_group" "aks_rg" {
    name = var.resource_group_name
    location = var.location
}

## Create ACR & AKS association
resource "azurerm_role_assignment" "role_acrpull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
  skip_service_principal_aad_check  = true
}

## Create ACR
resource "azurerm_container_registry" "acr" {
  name                     = var.acr_name
  resource_group_name      = azurerm_resource_group.aks_rg.name
  location                 = azurerm_resource_group.aks_rg.location
  sku                      = "standard"
  admin_enabled            = false

}


#Create AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
    name = var.cluster_name
    location = azurerm_resource_group.aks_rg.location
    resource_group_name = azurerm_resource_group.aks_rg.name
    dns_prefix = var.cluster_name

    default_node_pool {
        name = "system"
        vm_size = "Standard_DS2_v2"
        type  = "VirtualMachineScaleSets"
        node_count = var.system_node_count
		availability_zones   = [1, 2, 3]
		enable_auto_scaling  = false
    }
      
    identity {
        type = "SystemAssigned"
    }

    network_profile {
        load_balancer_sku = "Standard"
		    network_plugin = "kubenet"
    }
}

