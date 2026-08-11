resource "azurerm_user_assigned_identity" "aks" {
  name                = "id-aks"
  location            = var.location
  resource_group_name = var.resource_group_name
}