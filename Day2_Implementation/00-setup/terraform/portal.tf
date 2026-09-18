resource "konnect_portal" "dev_portal" {
  name                      = "${var.demo_prefix}-FinTech-Portal"
  description               = "Developer Portal for the BootCamp Case"
  auto_approve_applications = true
  auto_approve_developers   = true
}

output "portal_id" {
  value = konnect_portal.dev_portal.id
}
