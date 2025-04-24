terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0.0"
    }
  }
  required_version = ">= 0.14.9"
}

variable "suscription_id" {
  type        = string
  description = "Azure subscription id"
}

variable "sqladmin_username" {
  type        = string
  description = "Administrator username for server"
}

variable "sqladmin_password" {
  type        = string
  description = "Administrator password for server"
}

provider "azurerm" {
  features {}
  subscription_id = var.suscription_id
}

resource "random_integer" "ri" {
  min = 100
  max = 999
}

resource "azurerm_resource_group" "rg" {
  name     = "upt-arg-${random_integer.ri.result}"
  location = "centralus"
}

resource "azurerm_service_plan" "appserviceplan" {
  name                = "upt-asp-${random_integer.ri.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "webapp" {
  name                = "upt-awa-${random_integer.ri.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.appserviceplan.id
  depends_on          = [azurerm_service_plan.appserviceplan]

  site_config {
    minimum_tls_version = "1.2"
    always_on           = true
    application_stack {
      docker_image_name   = "patrickcuadros/shorten:latest"
      docker_registry_url = "https://index.docker.io"
    }
  }
}

resource "azurerm_mssql_server" "sqlsrv" {
  name                         = "upt-dbs-${random_integer.ri.result}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = "centralus"
  version                      = "12.0"
  administrator_login          = var.sqladmin_username
  administrator_login_password = var.sqladmin_password
  public_network_access_enabled = false
  minimum_tls_version          = "1.2"
}

resource "azurerm_mssql_firewall_rule" "sqlaccessrule" {
  name             = "SecureAccess"
  server_id        = azurerm_mssql_server.sqlsrv.id
  start_ip_address = "192.168.1.1"
  end_ip_address   = "192.168.1.255"
}

resource "azurerm_mssql_database" "sqldb" {
  name      = "shorten"
  server_id = azurerm_mssql_server.sqlsrv.id
  sku_name  = "Basic"
}

# Auditoría extendida

resource "azurerm_storage_account" "audit_storage" {
  name                     = "auditstorage${random_integer.ri.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = false
  min_tls_version          = "TLS1_2"
}

resource "azurerm_storage_container" "audit_logs" {
  name                  = "sqlaudit"
  storage_account_name  = azurerm_storage_account.audit_storage.name
  container_access_type = "private"
}

resource "azurerm_mssql_server_extended_auditing_policy" "sql_audit" {
  server_id                  = azurerm_mssql_server.sqlsrv.id
  storage_endpoint           = azurerm_storage_account.audit_storage.primary_blob_endpoint
  storage_account_access_key = azurerm_storage_account.audit_storage.primary_access_key
  retention_in_days          = 90
}
