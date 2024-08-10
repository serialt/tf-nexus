terraform {

  required_providers {
    nexus = {
      source = "serialt/nexus"
      #   version = "2.2.3"
    }
  }

}

# set env 
# NEXUS_USERNAME
# NEXUS_PASSWORD
provider "nexus" {
  insecure = var.nexus.insecure
  url      = var.nexus.url
  username = var.nexus.username
  password = var.nexus.password

}

