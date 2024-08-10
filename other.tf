resource "nexus_security_realms" "realms" {
  active = [
    "NexusAuthenticatingRealm",
    "DockerToken",
  ]
}


# resource "alicloud_alidns_record" "nexus" {
#   for_each = toset(var.nexus_domain.record)

#   domain_name = var.nexus_domain.domain
#   rr          = each.key
#   type        = "A"
#   value       = var.nexus_domain.value
#   remark      = "Record Created by Terraform for  nexus"
#   status      = "ENABLE"
# }
