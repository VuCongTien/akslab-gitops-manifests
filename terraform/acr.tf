resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku                           = "Premium"
  admin_enabled                 = false
  public_network_access_enabled = false
}

resource "azurerm_private_endpoint" "acr" {
  name                = "pe-acr"
  location            = var.location
  resource_group_name = var.resource_group_name

  subnet_id = azurerm_subnet.pe.id

  private_service_connection {
    name                           = "psc-acr"
    private_connection_resource_id = azurerm_container_registry.acr.id

    subresource_names    = ["registry"]
    is_manual_connection = false
  }

  private_dns_zone_group {
    name = "acr-private-dns-zone-group"

    private_dns_zone_ids = [
      azurerm_private_dns_zone.acr.id
    ]
  }
}

resource "azurerm_private_dns_zone" "acr" {
  name                = "privatelink.azurecr.io"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr" {
  name = "acr-vnet-link"

  private_dns_zone_id = azurerm_private_dns_zone.acr.id
  virtual_network_id  = azurerm_virtual_network.main.id

  registration_enabled = false
}
