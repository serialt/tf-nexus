# resource "nexus_cleanup_policy" "cleanup_policy" {
#   for_each = var.cleanup_policy
#   name     = each.value.name
#   format   = each.value.format

#   notes = contains(keys(each.value), "notes") ? each.value.notes : ""
#   criteria {
#     last_blob_updated_days = contains(keys(each.value.criteria), "last_blob_updated_days") ? each.value.criteria.last_blob_updated_days : 0
#     last_downloaded_days   = contains(keys(each.value.criteria), "last_downloaded_days") ? each.value.criteria.last_downloaded_days : 0
#     regex                  = contains(keys(each.value.criteria), "regex") ? each.value.criteria.regex : ""
#   }
# }

