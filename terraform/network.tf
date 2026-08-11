resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name

  address_space = var.vnet_address_space
}


resource "azurerm_subnet" "aks" {
  name                 = "subnet-aks"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "appgw" {
  name                 = "subnet-appgw"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "pe" {
  name                 = "subnet-pe"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_subnet" "db" {
  name                 = "subnet-db"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.4.0/24"]
}

resource "azurerm_network_security_group" "aks" {
  name                = "aks-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_group" "appgw" {
  name                = "appgw-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_group" "pe" {
  name                = "pe-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_group" "db" {
  name                = "db-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet_network_security_group_association" "aks" {
  subnet_id                 = azurerm_subnet.aks.id
  network_security_group_id = azurerm_network_security_group.aks.id
}

resource "azurerm_subnet_network_security_group_association" "appgw" {
  subnet_id                 = azurerm_subnet.appgw.id
  network_security_group_id = azurerm_network_security_group.appgw.id
}

resource "azurerm_subnet_network_security_group_association" "pe" {
  subnet_id                 = azurerm_subnet.pe.id
  network_security_group_id = azurerm_network_security_group.pe.id
}

resource "azurerm_subnet_network_security_group_association" "db" {
  subnet_id                 = azurerm_subnet.db.id
  network_security_group_id = azurerm_network_security_group.db.id
}

resource "azurerm_network_security_rule" "appgw_allow_http" {
  name      = "allow_http"
  priority  = 100
  direction = "Inbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_port_range      = "*"
  destination_port_range = "80"

  source_address_prefix      = "Internet"
  destination_address_prefix = "*"

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.appgw.name
}

resource "azurerm_network_security_rule" "appgw_allow_https" {
  name      = "allow_https"
  priority  = 110
  direction = "Inbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_port_range      = "*"
  destination_port_range = "443"

  source_address_prefix      = "Internet"
  destination_address_prefix = "*"

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.appgw.name
}

resource "azurerm_network_security_rule" "appgw_gateway_manager" {
  name      = "allow_gateway_manager"
  priority  = 120
  direction = "Inbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_port_range      = "*"
  destination_port_range = "65200-65535"

  source_address_prefix      = "GatewayManager"
  destination_address_prefix = "*"

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.appgw.name
}

resource "azurerm_network_security_rule" "pe_allow_from_aks" {
  name      = "Allow-From-AKS"
  priority  = 100
  direction = "Inbound"
  access    = "Allow"
  protocol  = "*"

  source_port_range      = "*"
  destination_port_range = "*"

  source_address_prefix      = "10.0.1.0/24"
  destination_address_prefix = "10.0.3.0/24"

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.pe.name
}

resource "azurerm_network_security_rule" "pe_deny_other_vnet" {
  name      = "Deny-Other-VNet"
  priority  = 4096
  direction = "Inbound"
  access    = "Deny"
  protocol  = "*"

  source_port_range      = "*"
  destination_port_range = "*"

  source_address_prefix      = "VirtualNetwork"
  destination_address_prefix = "10.0.3.0/24"

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.pe.name
}

resource "azurerm_network_security_rule" "db_allow_from_aks" {
  name      = "Allow-From-AKS"
  priority  = 100
  direction = "Inbound"
  access    = "Allow"
  protocol  = "*"

  source_port_range      = "*"
  destination_port_range = "*"

  source_address_prefix      = "10.0.1.0/24"
  destination_address_prefix = "10.0.4.0/24"

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.db.name
}

resource "azurerm_network_security_rule" "db_deny_other_vnet" {
  name      = "Deny-Other-VNet"
  priority  = 4096
  direction = "Inbound"
  access    = "Deny"
  protocol  = "*"

  source_port_range      = "*"
  destination_port_range = "*"

  source_address_prefix      = "VirtualNetwork"
  destination_address_prefix = "10.0.4.0/24"

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.db.name
}

