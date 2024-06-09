provider "azurerm" {
  features {}
}

resource "random_integer" "randint" {
  min = 10000
  max = 99999
}

data "archive_file" "functionapp" {
  type        = "zip"
  source_dir  = var.package_source_dir
  output_path = var.package_output_path
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${var.resource_group_name}-${var.environment}-${local.location}"
  location = var.location
}

resource "azurerm_application_insights" "this" {
  name                = "appinsights-${var.environment}-${local.location}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  application_type    = "web"
}

resource "azurerm_storage_account" "this" {
  name                     = "st${var.function_app_name}func${local.randint}"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "this" {
  name                  = "functionapps"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "blob"
}

resource "azurerm_storage_blob" "updater" {
  name                   = "${var.function_app_name}.zip"
  storage_account_name   = azurerm_storage_account.this.name
  storage_container_name = azurerm_storage_container.this.name
  type                   = "Block"
  content_md5            = data.archive_file.functionapp.output_md5
  source                 = data.archive_file.functionapp.output_path
}

resource "azurerm_service_plan" "this" {
  name                = "asp-${var.function_app_name}-${var.environment}-${local.location}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  os_type             = "Linux"
  sku_name            = "P0v3"
}

resource "azurerm_linux_function_app" "this" {
  name                       = "func-${var.function_app_name}-${var.environment}-${local.location}-${local.randint}"
  resource_group_name        = azurerm_resource_group.this.name
  location                   = azurerm_resource_group.this.location
  storage_account_name       = azurerm_storage_account.this.name
  storage_account_access_key = azurerm_storage_account.this.primary_access_key
  service_plan_id            = azurerm_service_plan.this.id

  site_config {
    application_stack {
      python_version = "3.11"
    }
    application_insights_connection_string = azurerm_application_insights.this.connection_string
    application_insights_key               = azurerm_application_insights.this.instrumentation_key
  }

  tags = {
    "owner"       = "financial controllers"
    "cost-center" = "12345"
  }
}

resource "azurerm_linux_function_app_slot" "staging" {
  name                       = "staging"
  function_app_id            = azurerm_linux_function_app.this.id
  storage_account_name       = azurerm_storage_account.this.name
  storage_account_access_key = azurerm_storage_account.this.primary_access_key

  site_config {
    application_stack {
      python_version = "3.11"
    }
    application_insights_connection_string = azurerm_application_insights.this.connection_string
    application_insights_key               = azurerm_application_insights.this.instrumentation_key
  }

  app_settings = {
    SCM_DO_BUILD_DURING_DEPLOYMENT = true
    WEBSITE_RUN_FROM_PACKAGE       = "https://${azurerm_storage_account.this.name}.blob.core.windows.net/${azurerm_storage_container.this.name}/${azurerm_storage_blob.updater.name}"
    HASH                           = base64encode(data.archive_file.functionapp.output_md5)
    FUNCTIONS_WORKER_PROCESS_COUNT = 3
  }
}

resource "null_resource" "swap_slots" {
  triggers = {
    HASH = azurerm_linux_function_app_slot.staging.app_settings.HASH
  }
  provisioner "local-exec" {
    command = "sleep 5s && az functionapp deployment slot swap -g ${azurerm_resource_group.this.name} -n ${azurerm_linux_function_app.this.name} --slot ${azurerm_linux_function_app_slot.staging.name} --target-slot production"
  }
  depends_on = [azurerm_linux_function_app.this, azurerm_linux_function_app_slot.staging]
}
