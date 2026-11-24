terraform {
  required_version = ">= 1.12.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }

    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "~> 2.22"
    }

  }

  backend "azurerm" {}
}


provider "azurerm" {
  subscription_id = var.subscription_id

  features {}
}