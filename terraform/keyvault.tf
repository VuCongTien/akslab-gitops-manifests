data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                = var.key_vault_name
  location            = var.location
  resource_group_name = var.resource_group_name

  tenant_id = data.azurerm_client_config.current.tenant_id
  sku_name  = "standard"

  rbac_authorization_enabled = true

  public_network_access_enabled = false

  soft_delete_retention_days = 7
  purge_protection_enabled   = true
}

resource "azurerm_private_endpoint" "kv" {
  name                = "pe-keyvault"
  location            = var.location
  resource_group_name = var.resource_group_name

  subnet_id = azurerm_subnet.pe.id

  private_service_connection {
    name                           = "psc-keyvault"
    private_connection_resource_id = azurerm_key_vault.kv.id

    subresource_names    = ["vault"]
    is_manual_connection = false
  }

  private_dns_zone_group {
    name = "kv-private-dns-zone-group"

    private_dns_zone_ids = [
      azurerm_private_dns_zone.kv.id
    ]
  }
}

resource "azurerm_private_dns_zone" "kv" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "kv" {
  name = "kv-vnet-link"

  private_dns_zone_id = azurerm_private_dns_zone.kv.id
  virtual_network_id  = azurerm_virtual_network.main.id

  registration_enabled = false
}
