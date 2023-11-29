module "cloud_armor" {
  source = "GoogleCloudPlatform/cloud-armor/google"
  project_id     = var.project_id
  name           = "web-application-security-policy"
  description    = "Cloud Armor security policy with rate limiting"
  layer_7_ddos_defense_enable          = true
  layer_7_ddos_defense_rule_visibility = "STANDARD"
  log_level                            = "VERBOSE"

  # Add security rules as per your requirements
  security_rules = {
    "rate_ban" = {
      action        = "rate_based_ban"
      priority      = 13
      description   = "Rate based ban for addresses as soon as they cross rate limit threshold"
      src_ip_ranges = ["190.217.68.213", "45.116.227.70"]
      rate_limit_options = {
        ban_duration_sec                     = 120
        enforce_on_key                       = "ALL"
        exceed_action                        = "deny(502)"
        rate_limit_http_request_count        = 10
        rate_limit_http_request_interval_sec = 60
      }
    }
  }
}
