variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = "e3186bd8-afa3-4945-b6d1-3c426a33d328"
}

variable "vnet_name" {
  description = "Name Vnet"
  type        = string
  default     = "labaks-vnet"
}

variable "location" {
  description = "Location Azure"
  type        = string
  default     = "southeastasia"
}

variable "resource_group_name" {
  description = "Name Resource Group"
  type        = string
  default     = "rg-aks-lab-tienvc"
}

variable "vnet_address_space" {
  description = "Address space for Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "key_vault_name" {
  description = "Azure Key Vault name"
  type        = string
  default     = "tienvc123-kv"
}

variable "acr_name" {
  description = "Azure ACR name"
  type        = string
  default     = "tienvc123acr"
}


variable "aks_name" {
  description = "Azure AKS name"
  type        = string
  default     = "tienvc123aks"
}

variable "postgresql_name" {
  description = "Azure PostgreSQL name"
  type        = string
  default     = "tienvc123postgresql"
}

variable "postgresql_admin_username" {
  description = "Azure PostgreSQL admin username"
  type        = string
  default     = "admin"
}

variable "postgresql_admin_password" {
  description = "Azure PostgreSQL admin password"
  type        = string
  default     = "Password123!"
}

variable "database_name" {
  description = "Azure database name"
  type        = string
  default     = "backend"
}

