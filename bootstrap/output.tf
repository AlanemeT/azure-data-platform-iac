output "storage_account_name" {
  description = "Terraform backend storage account"
  value       = azurerm_storage_account.tfstate.name
}

output "resource_group_name" {
  description = "Terraform backend resource group"
  value       = azurerm_resource_group.tfstate.name
}

output "container_name" {
  description = "Terraform state container"
  value       = azurerm_storage_container.tfstate.name
}