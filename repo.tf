
# resource "nexus_repository_docker_hosted" "docker-hosted" {
#   name   = "docker-hosted"
#   online = true

#   component {
#     proprietary_components = false
#   }

#   docker {
#     force_basic_auth = false
#     http_port        = 8082
#     https_port       = 0
#     v1_enabled       = true
#   }

#   storage {
#     blob_store_name                = nexus_blobstore_file.docker-hosted.name
#     strict_content_type_validation = true
#     write_policy                   = "ALLOW"
#   }
# }

# resource "nexus_repository_docker_proxy" "docker-proxy-harbor" {
#   name   = "docker-proxy-harbor"
#   online = true

#   docker {
#     force_basic_auth = false
#     http_port        = 0
#     https_port       = 0
#     v1_enabled       = true
#   }

#   docker_proxy {
#     index_type = "REGISTRY"
#   }

#   http_client {
#     auto_block = true
#     blocked    = false

#     connection {
#       enable_circular_redirects = false
#       enable_cookies            = false
#       retries                   = 0
#       timeout                   = 0
#       use_trust_store           = false
#     }
#   }

#   negative_cache {
#     enabled = true
#     ttl     = 1440
#   }

#   proxy {
#     content_max_age  = 1440
#     metadata_max_age = 1440
#     remote_url       = "https://harbor.local.com"
#   }

#   storage {
#     blob_store_name                = nexus_blobstore_file.docker-proxy.name
#     strict_content_type_validation = true
#   }
# }


# resource "nexus_repository_docker_proxy" "dockerhub" {
#   name   = "dockerhub"
#   online = true

#   docker {
#     force_basic_auth = false
#     http_port        = 0
#     https_port       = 0
#     v1_enabled       = true
#   }

#   docker_proxy {
#     index_type = "HUB"
#   }

#   http_client {
#     auto_block = true
#     blocked    = false

#     connection {
#       enable_circular_redirects = false
#       enable_cookies            = false
#       retries                   = 0
#       timeout                   = 0
#       use_trust_store           = false
#     }
#   }

#   negative_cache {
#     enabled = true
#     ttl     = 1440
#   }

#   proxy {
#     content_max_age  = 1440
#     metadata_max_age = 1440
#     remote_url       = "https://registry-1.docker.io"
#   }

#   storage {
#     blob_store_name                = nexus_blobstore_file.docker-proxy.name
#     strict_content_type_validation = true
#   }
# }


# resource "nexus_repository_docker_group" "docker-group" {

#   name   = "docker-group"
#   online = true

#   docker {
#     force_basic_auth = false
#     http_port        = 8083
#     https_port       = 0
#     v1_enabled       = true
#   }

#   group {
#     member_names = [
#       "${nexus_repository_docker_proxy.docker-proxy-harbor.name}",
#       "${nexus_repository_docker_hosted.docker-hosted.name}",
#       "${nexus_repository_docker_proxy.dockerhub.name}",
#     ]
#   }

#   storage {
#     blob_store_name                = nexus_blobstore_file.docker-group.name
#     strict_content_type_validation = true
#   }
#   depends_on = [
#     nexus_repository_docker_hosted.docker-hosted,
#     nexus_repository_docker_proxy.dockerhub
#   ]
# }



resource "nexus_repository_apt_proxy" "apt" {
  for_each = merge(var.mirror_url.data.debian,var.mirror_url.data.ubuntu)
  distribution = "*"
  flat         = false
  name         = each.key
  online       = true

  http_client {
    auto_block = true
    blocked    = false

    connection {
      enable_circular_redirects = false
      enable_cookies            = false
      retries                   = 0
      timeout                   = 0
      use_trust_store           = false
    }
  }

  negative_cache {
    enabled = true
    ttl     = 1440
  }

  proxy {
    content_max_age  = 1440
    metadata_max_age = 1440
    remote_url       = each.value
  }

  storage {
    blob_store_name                = contains(var.blobstore_file,"apt")? "apt":"data"
    strict_content_type_validation = true
  }
  depends_on =[
    nexus_blobstore_file.blob
  ]
}



resource "nexus_repository_npm_hosted" "local" {
  name   = "npm-local"
  online = true

  component {
    proprietary_components = false
  }
  // try(var.blobstore_file.npm_local,nexus_blobstore_file.blob["data"].name)
  storage {
    blob_store_name                = contains(var.blobstore_file,"npm-local")? "npm-local":"data"
    strict_content_type_validation = true
    write_policy                   = "ALLOW"
  }
  depends_on =[
    nexus_blobstore_file.blob
  ]
}




resource "nexus_repository_npm_proxy" "proxy" {
  for_each = var.mirror_url.data.npm
  name                 = "npm-${each.key}"
  online               = true
  remove_non_cataloged = false
  remove_quarantined   = false

  http_client {
    auto_block = true
    blocked    = false

    connection {
      enable_circular_redirects = false
      enable_cookies            = false
      retries                   = 0
      timeout                   = 0
      use_trust_store           = false
    }
  }

  negative_cache {
    enabled = true
    ttl     = 1440
  }

  proxy {
    content_max_age  = 1440
    metadata_max_age = 1440
    remote_url       = each.value
  }

  storage {
    blob_store_name                = contains(var.blobstore_file,"npm-proxy")? "npm-proxy":"data"
    strict_content_type_validation = true
  }
  depends_on =[
    nexus_blobstore_file.blob
  ]
}


resource "nexus_repository_npm_group" "npm_group" {
  name   = "npm"
  online = true

  group {
    member_names = concat(
      [for i in  nexus_repository_npm_proxy.proxy: i.name],
      [nexus_repository_npm_hosted.local.name],
      )
  }

  storage { 
    blob_store_name                = contains(var.blobstore_file,"npm-group")? "npm-group":"data"
    strict_content_type_validation = true
  }
  depends_on =[
    nexus_blobstore_file.blob,
    nexus_repository_npm_hosted.local,
    nexus_repository_npm_proxy.proxy,
  ]
}




resource "nexus_repository_go_proxy" "proxy" {
  for_each = var.mirror_url.data.go
  name   = "go-${each.key}"
  online = true

  storage {
    blob_store_name                = contains(var.blobstore_file,"go-proxy")? "go-proxy":"data"
    strict_content_type_validation = true
  }

  proxy {
    remote_url       = each.value
    content_max_age  = 1440
    metadata_max_age = 1440
  }

  negative_cache {
    enabled = true
    ttl     = 1440
  }

  http_client {
    auto_block = true
    blocked    = false

    connection {
      enable_circular_redirects = false
      enable_cookies            = false
      retries                   = 0
      timeout                   = 0
      use_trust_store           = false
    }
  }
  depends_on =[
    nexus_blobstore_file.blob
  ]
}


resource "nexus_repository_go_group" "group" {
  name   = "go"
  online = true

  group {
    member_names = concat(
     [for i in  nexus_repository_go_proxy.proxy: i.name],
    )
  }

  storage {
    blob_store_name                = contains(var.blobstore_file,"go-group")? "go-group":"data"
    strict_content_type_validation = true
  }
  depends_on =[
    nexus_blobstore_file.blob,
  ]
}




resource "nexus_repository_pypi_hosted" "local" {
  name   = "pypi-local"
  online = true

  storage {
    blob_store_name                = contains(var.blobstore_file,"pypi-local")? "pypi-local":"data"
    strict_content_type_validation = true
    write_policy                   = "ALLOW"
  }
  depends_on =[
    nexus_blobstore_file.blob
  ]
}



resource "nexus_repository_pypi_proxy" "proxy" {
  for_each = var.mirror_url.data.pypi
  name   = "pypi-${each.key}"
  online = true

  http_client {
    auto_block = true
    blocked    = false

    connection {
      enable_circular_redirects = false
      enable_cookies            = false
      retries                   = 0
      timeout                   = 0
      use_trust_store           = false
    }
  }

  negative_cache {
    enabled = true
    ttl     = 1440
  }

  proxy {
    content_max_age  = 1440
    metadata_max_age = 1440
    remote_url       = each.value
  }

  storage {
    blob_store_name                = contains(var.blobstore_file,"pypi-proxy")? "pypi-proxy":"data"
    strict_content_type_validation = true
  }
  depends_on =[
    nexus_blobstore_file.blob
  ]
}


resource "nexus_repository_pypi_group" "group" {
  name   = "pypi-group"
  online = true

  group {
    member_names = concat(
     [for i in  nexus_repository_pypi_proxy.proxy: i.name],
     [nexus_repository_pypi_hosted.local.name],
    )
  }

  storage {
    blob_store_name                = contains(var.blobstore_file,"pypi-group")? "pypi-group":"data"
    strict_content_type_validation = true
  }
  depends_on =[
    nexus_blobstore_file.blob
  ]
}








