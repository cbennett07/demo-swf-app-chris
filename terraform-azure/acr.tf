resource "azurerm_container_registry" "main" {
  # ACR names must be globally unique, alphanumeric only, 5-50 chars
  name                = replace("${var.project_name}acr", "-", "")
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = var.acr_sku
  admin_enabled       = true

  tags = var.tags
}
