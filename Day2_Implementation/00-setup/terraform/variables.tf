variable "konnect_token" {
  description = "Kong Konnect Personal Access Token"
  type        = string
  sensitive   = true
}

variable "konnect_server_url" {
  description = "Kong Konnect Server URL"
  type        = string
  default     = "https://us.api.konghq.com"
}

variable "demo_prefix" {
  description = "Prefix for the Control Planes"
  type        = string
  default     = "RZE"
}
