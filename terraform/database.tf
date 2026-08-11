resource "azurerm_postgresql_flexible_server" "db" {
  name                = var.postgresql_name
  resource_group_name = var.resource_group_name
  location            = var.location

  version = "16"
  
  administrator_login    = var.postgresql_admin_username
  administrator_password = var.postgresql_admin_password

  sku_name = "Standard_B1ms"

  storage_mb = 32768

  public_network_access_enabled = false
}


resource "azurerm_postgresql_flexible_server_database" "backend" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.db.id

  charset   = "UTF8"
  collation = "en_US.utf8"
}

resource "azurerm_private_dns_zone" "postgres" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
}


resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name = "postgres-dns-vnet-link"

  private_dns_zone_id = azurerm_private_dns_zone.postgres.id
  virtual_network_id  = azurerm_virtual_network.main.id

  registration_enabled = false
}

resource "azurerm_private_endpoint" "postgres" {
  name                = "pe-postgresql"
  location            = var.location
  resource_group_name = var.resource_group_name

  subnet_id = azurerm_subnet.pe.id

  private_service_connection {
    name = "psc-postgresql"

    private_connection_resource_id = azurerm_postgresql_flexible_server.db.id

    subresource_names = [
      "postgresqlServer"
    ]

    is_manual_connection = false
  }

  private_dns_zone_group {
    name = "postgres-private-dns-zone-group"

    private_dns_zone_ids = [
      azurerm_private_dns_zone.postgres.id
    ]
  }
}