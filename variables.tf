variable "nexus" {
  type    = any
  default = {}

}


variable "oci_registry" {
  type    = any
  default = {}

}

variable "cleanup_policy" {
  type    = any
  default = {}

}

variable "s3" {
  type    = any
  default = {}
}

variable "mirror_url"{
  type  = any
  default = {}
}

variable "blobstore_file" {
  type = any
  default = []
}