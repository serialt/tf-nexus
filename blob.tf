resource "nexus_blobstore_file" "blob" {
  for_each = toset(var.blobstore_file)
  name = each.value
  path = each.value
}

