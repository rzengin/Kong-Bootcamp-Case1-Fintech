variable "konnect_token" {
  type      = string
  sensitive = true
}
variable "konnect_server_url" {
  type    = string
  default = "https://us.api.konghq.com"
}
variable "demo_prefix" {
  type    = string
  default = "RZE"
}

variable "portal_id" {
  type = string
}
variable "cp_core_id" {
  type = string
}
variable "cp_credit_cards_id" {
  type = string
}
variable "cp_loans_id" {
  type = string
}

variable "svc_accounts_id" {
  type = string
}
variable "svc_credit_accounts_id" {
  type = string
}
variable "svc_loans_id" {
  type = string
}
