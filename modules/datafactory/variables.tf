variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "environment" {
  type = string
}

variable "unique_suffix" {
  type = string
}

variable "datalake_id" {
  type = string
}

variable "keyvault_id" {
  type = string
}

variable "tags" {
  type = map(string)
}