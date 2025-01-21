# Configurar el probedor de azure
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.0"
    }
  }
  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
  use_msi = true
  subscription_id = var.subscription_id
}

# Referenciar un grupo de recursos existente
data "azurerm_resource_group" "rg" {
  name = "AvataresResourcesGroup"
}

# Referenciar un registro de contenedores existente
data "azurerm_container_registry" "acr" {
  name                = "avatarescr"
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Crear un plan de App Service
resource "azurerm_service_plan" "asp" {
  name                = "AvataresAppServicePlan"
  location            = "westus"
  resource_group_name = data.azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B2"
}

# Crear una App Service para el backend
resource "azurerm_linux_web_app" "backend" {
  name                = "avatares-backend-service"
  location            = "westus"
  resource_group_name = data.azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.asp.id

  app_settings = {
    "WEBSITES_PORT" = "5000"
    "FLASK_APP"     = "app.py"
    "FLASK_ENV"     = "production"
    "DOCKER_REGISTRY_SERVER_URL"     = "https://${data.azurerm_container_registry.acr.login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME" = data.azurerm_container_registry.acr.admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD" = data.azurerm_container_registry.acr.admin_password
  }

  site_config {
    app_command_line = "flask run --host=0.0.0.0 --port=5000"
    application_stack {
    docker_image = "${data.azurerm_container_registry.acr.login_server}/backend-avatares"
    docker_image_tag = "latest"
    }
  }
}

# Crear una App Service para el frontend
resource "azurerm_linux_web_app" "frontend" {
  name                = "avatares-frontend-service"
  location            = "westus"
  resource_group_name = data.azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.asp.id

  app_settings = {
    "WEBSITES_PORT"    = "5173"
    "VITE_HOST"        = "0.0.0.0"
    "VITE_PORT"        = "5173"
    "VITE_BACKEND_URL" = "http://${azurerm_linux_web_app.backend.default_hostname}"
    "DOCKER_REGISTRY_SERVER_URL"     = "https://${data.azurerm_container_registry.acr.login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME" = data.azurerm_container_registry.acr.admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD" = data.azurerm_container_registry.acr.admin_password
  }

  site_config {
    app_command_line = "npm run dev -- --host"
    application_stack {
      docker_image = "${data.azurerm_container_registry.acr.login_server}/frontend-avatares"
      docker_image_tag = "latest"
    }
  }
}
