output "policies_created" {
  description = "List of network policies created"
  value = concat(
    var.enable_default_deny ? ["default-deny-all"] : [],
    ["allow-dns"],
    var.enable_monitoring_access ? ["allow-prometheus-scraping"] : [],
    var.enable_vault_access ? ["allow-egress-to-vault"] : [],
    [for k, v in var.infrastructure_services : "allow-egress-to-${k}"]
  )
}
