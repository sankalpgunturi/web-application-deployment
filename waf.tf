module "cloud_armor" {
  source = "GoogleCloudPlatform/cloud-armor/google"
  project_id     = var.project_id
  name           = "web-application-security-policy"
  description    = "Basic Cloud Armor security policy for DoS protection"
  default_rule_action = "deny"

  security_rules = {
    "deny_all" = {
      action    = "deny(403)"
      priority  = 1
      description = "Deny all requests for DoS protection"
      src_ip_ranges = ["0.0.0.0/0"]  # Dummy IP range
    }
  }
}