#Terraform Statefile

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tf-vrk-hub-frc"
    storage_account_name = "sttfbackendvrkhubfrc"
    container_name       = "hubtfstatefile"
    key                  = "hub.terraform.tfstate"
  }
}


###################################################
# Terraform resource provisioning
###################################################
locals {

  resource_names = {
    log_rg_name                  = lower(join("-", ["rg", var.log_resource_group, var.applicationname_short, var.environment_short, var.region]))
    log_storage_account_name     = lower(join("", ["st", "log", var.applicationname_short, var.environment_short, var.region, "001"]))
    
    
  }

  tags = {
    Customer           = var.customer
    Category           = var.category
    BusinessUnit       = var.business_unit
    ApplicationName    = var.applicationname
    DataClassification = var.data_classification
    ApproverName       = var.approver_name
    Environment        = var.environment
    OwnerName          = var.owner_name
    Contact            = var.contact
    Region             = var.region
  }
}

###################################################
# Log resource provisioning
###################################################

#This module creates Log Resource Group in Hub Environment. 
#This Resource Group required to deploy Storage account and Log Analytics WorkSpace

module "azurerm_rg_log" {
  source   = "../resources/ResourceGroup_module"
  name     = local.resource_names.log_rg_name
  location = var.location
  tags     = merge({ "ResourceName" = format("%s", local.resource_names.log_rg_name) }, local.tags)
}

#This module creates Storage account in Hub Environment. 
#This storage Account required to save all Logs

module "azurerm_log_storage_account" {
  source              = "../resources/StorageAccount_module"
  sa_name             = local.resource_names.log_storage_account_name
  resource_group_name = module.azurerm_rg_log.resource_group_name
  tags                = merge({ "ResourceName" = format("%s", local.resource_names.log_storage_account_name) }, local.tags)
  depends_on          = [module.azurerm_rg_log]
}

