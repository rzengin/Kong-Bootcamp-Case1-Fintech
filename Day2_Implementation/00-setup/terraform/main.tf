locals {
  control_planes = {
    credit_cards     = "Credit Cards"
    loans            = "Loans"
    personal_banking = "Personal Banking"
    core             = "Core Banking"
  }
}

resource "konnect_gateway_control_plane" "cp" {
  for_each     = local.control_planes
  name         = "${var.demo_prefix}-${each.value}"
  description  = "Control Plane for ${each.value} Business Unit"
  cluster_type = "CLUSTER_TYPE_HYBRID"
  auth_type    = "pinned_client_certs"
}

resource "konnect_gateway_data_plane_client_certificate" "cert" {
  for_each         = local.control_planes
  control_plane_id = konnect_gateway_control_plane.cp[each.key].id
  cert             = file("../certs/${each.key}/tls.crt")
}

output "control_plane_ids" {
  value = { for k, cp in konnect_gateway_control_plane.cp : k => cp.id }
}

output "control_plane_endpoints" {
  value = { for k, cp in konnect_gateway_control_plane.cp : k => cp.config.control_plane_endpoint }
}

output "telemetry_endpoints" {
  value = { for k, cp in konnect_gateway_control_plane.cp : k => cp.config.telemetry_endpoint }
}
