terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform"
    storage_account_name = "stterraformbackendbsprod"
    container_name       = "functionapps"
    key                  = "hello.tfstate"
  }
}
