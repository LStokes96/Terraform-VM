provider "azurerm" {
  features{}
}
resource "azurerm_resource_group" "ModuleRG" {
  name = "Module-RG"
  location = "uk south"
}
module "azurerm_linux_virtual_machine" {
  source = "./VM"
  location = azurerm_resource_group.ModuleRG.location
  Resource_group_name = azurerm_resource_group.ModuleRG.name
}