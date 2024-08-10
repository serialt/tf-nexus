nexus = {
  insecure = true
  url      = "http://nexus.ct.local.com"
  username = "admin"
  password = "sugar"
}



cleanup_policy = {
  docker-proxy = {
    name   = "apk_expire"
    format = "raw"
    criteria = {
      last_blob_updated_days = 365
      last_downloaded_days   = 0
      regex                  = ""
    }
  }
  apk_package_expire = {
    name   = "apk_package_expire"
    format = "raw"
    criteria = {
      last_downloaded_days = 80
    }
  }

}

s3 = {
  bucket = "local-nexus"
  region = "cn-east-1"
  prefix = "nexus-data"

  accessKeyId     = "LEEGB4localxxxxxxx"
  secretAccessKey = "xxxxxxxx"
  endpoint        = "https://xxxxxxxx.local"

}
blobstore_file = [
  "data",
  "docker-hosted",
  "docker-proxy",
  "docker-group",
  "apt",
  "npm-local",
  "npm-proxy",
  "npm-group",
  "pypi-local",
  "pypi-proxy",
  "pypi-group",
  "go-proxy",
  "go-group", 
  "maven-local",
  "maven-proxy",
  "maven-group",
]


mirror_url = {
  default = "https://mirrors.ustc.edu.cn"
  data = {
    debian = {
      debian = "https://mirrors.ustc.edu.cn/debian/"
      debian-security = "https://mirrors.ustc.edu.cn/debian-security/"
    }
    ubuntu = {
      ubuntu = "https://mirrors.ustc.edu.cn/ubuntu/"
    }
    go = {
      goproxy = "https://goproxy.cn"
    }
    npm = {
      official = "https://registry.npmjs.org/"
      huaweicloud = "https://repo.huaweicloud.com/repository/npm/"
      aliyun = "https://registry.npmmirror.com"
      tencent = "http://mirrors.cloud.tencent.com/npm/"
    }
    pypi = {
      aliyun = "https://mirrors.aliyun.com/pypi"
      tuna = "https://pypi.tuna.tsinghua.edu.cn"
      huaweicloud ="https://mirrors.huaweicloud.com/repository/pypi"
      nju = "https://mirror.nju.edu.cn/pypi/web/"
      sjtu = "https://mirror.sjtu.edu.cn/pypi/web"
    }
    maven = {
      aliyun = "https://maven.aliyun.com/repository/central"
    }

    
  }

}