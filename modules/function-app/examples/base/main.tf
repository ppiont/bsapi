terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.107.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.2"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.2"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4.2"
    }
  }
}

module "function-app" {
  source              = "/tmp/function-app.tgz"
  function_app_name   = "test-${random_integer.randint.result}"
  resource_group_name = "test-${random_integer.randint.result}"
  location            = "westeurope"
  package_source_dir  = "${path.module}/../../../../code/function_app"
  package_output_path = "${path.module}/../../../../dist/functionapp.zip"
  environment         = "test"

  tags = {
    environment = "test"
  }

}

provider "azurerm" {
  features {}
}

resource "random_integer" "randint" {
  min = 100000
  max = 999999
}
