resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = var.resource_group_name

  dns_prefix = "${var.aks_name}-dns"

  private_cluster_enabled = true

  default_node_pool {
    name = "systempool"

    vm_size        = "Standard_D2s_v3"
    node_count     = 1
    os_sku         = "Ubuntu"
    vnet_subnet_id = azurerm_subnet.aks.id

    only_critical_addons_enabled = true
  }

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  identity {
    type = "UserAssigned"

    identity_ids = [
      azurerm_user_assigned_identity.aks.id
    ]
  }

  node_provisioning_profile {
    mode = "Manual"
  }

  role_based_access_control_enabled = true

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = true
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"

    load_balancer_sku = "standard"

    service_cidr   = "172.16.0.0/16"
    dns_service_ip = "172.16.0.10"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name = "userpool"

  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id

  vm_size = "Standard_D2s_v3"

  vnet_subnet_id = azurerm_subnet.aks.id

  mode = "User"

  auto_scaling_enabled = true

  min_count = 1
  max_count = 5
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope = azurerm_container_registry.acr.id

  role_definition_name = "AcrPull"

  principal_id = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}



