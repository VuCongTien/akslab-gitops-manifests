resource "azurerm_user_assigned_identity" "aks" {
  name                = "id-aks"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_user_assigned_identity" "backend" {
  name                = "id-backend"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_role_assignment" "backend_keyvault" {
  scope = azurerm_key_vault.kv.id

  role_definition_name = "Key Vault Secrets Officer"

  principal_id = azurerm_user_assigned_identity.backend.principal_id
}

resource "azurerm_federated_identity_credential" "backend_workload_identity" {
  name                      = "backend-workload-identity"
  user_assigned_identity_id = azurerm_user_assigned_identity.backend.id
  audience                  = ["api://AzureADTokenExchange"]
  issuer                    = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  subject                   = "system:serviceaccount:backend-ns:be-sa"
}

