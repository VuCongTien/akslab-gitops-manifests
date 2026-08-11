resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = var.resource_group_name

  dns_prefix = "${var.aks_name}-dns"

  private_cluster_enabled = true

  default_node_pool {
    name = "systempool"

    vm_size    = "Standard_B2s"
    node_count = 1

    vnet_subnet_id = azurerm_subnet.aks.id

    only_critical_addons_enabled = true
  }

  identity {
    type = "SystemAssigned"
  }

  node_provisioning_profile {
    os_sku = "Ubuntu"
  }
  
}
