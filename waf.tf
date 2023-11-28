module "cloud_armor" {
  source = "GoogleCloudPlatform/cloud-armor/google"
  project_id     = var.project_id
  name           = "web-application-security-policy"
  description    = "Basic Cloud Armor security policy for DoS protection"
  default_rule_action = "deny"
  layer_7_ddos_defense_enable          = true
  layer_7_ddos_defense_rule_visibility = "STANDARD"
  log_level                            = "VERBOSE"

  # Add security rules as per your requirements
  security_rules = {
    "deny_all" = {
      action    = "deny(403)"
      priority  = 1
      description = "Deny all requests for DoS protection"
      src_ip_ranges = ["0.0.0.0/0"]  # Dummy IP range, since we are using default_action = "deny"
    }
  }
}