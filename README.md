## Terraform 配置 Nexus

### 1、环境变量配置
```shell
export NEXUS_PASSWORD=sugar
export NEXUS_USERNAME=admin
export NEXUS_URL=http://nexus.local.com
export NEXUS_INSECURE_SKIP_VERIFY=true
```

### 2、nginx配置文件模板
```nginx
upstream nexus-local {
    server localhost:8081;
}
server {
    listen 80;
    server_name  nexus.local.com ;
    charset utf-8;
    client_max_body_size       100m;
    client_body_buffer_size    12800k;
    location / {
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-Proto $scheme;    
        proxy_pass http://nexus-local;
    }
    access_log /var/log/nginx/nexus.log;
    error_log /var/log/nginx/nexus-error.log;
}

server {
    listen 443 ssl;
    server_name  nexus.local.com ;
    charset utf-8;
    client_max_body_size       100m;
    client_body_buffer_size    12800k;
    location / {
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-Proto $scheme; 
        proxy_pass http://nexus-local;
    }
    ssl_certificate /etc/nginx/cert_files/local.com.crt;
    ssl_certificate_key /etc/nginx/cert_files/local.com.key;
    access_log /var/log/nginx/nexus.log;
    error_log /var/log/nginx/nexus-error.log;
}

server {
    listen 80;
    server_name  mirrors.local.com ;
    client_max_body_size       1024m;
    client_body_buffer_size    128k;
    charset utf-8;
    location / {
        proxy_pass http://nexus.local.com/repository/;
        proxy_set_header Host nexus.local.com;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    access_log /var/log/nginx/mirrors.log;
    error_log /var/log/nginx/mirrors-error.log;
}
```


### 3、换源配置
```shell

### npm
# 配置 npm默认源
npm config set registry http://mirrors.local.com/repository/npm

# 或者直接使用npm命令
npm install -y --registry=http://nexus.local.com/repository/npm/

### pypi
vim .pip/pip.conf
[global]
index-url = http://nexus.local.com/repository/pypi/simple
trusted-host = nexus.local.com
timeout = 120


# 不配置pip.conf直接使用
pip3 install redis   -i http://mirrors.local.com/pypi/simple --truste
d-host mirrors.local.com


# maven
# settings.xml
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                      https://maven.apache.org/xsd/settings-1.0.0.xsd">
    <localRepository>/usr/share/maven/ref/repository</localRepository>
    <mirrors>
        <mirror>
            <id>nexus</id>
            <name>nexus</name>
            <url>http://nexus.local.com/repository/maven/</url>
            <mirrorOf>*</mirrorOf>
        </mirror>
    </mirrors>
</settings>


### apt
sed -i 's+\w*.debian.org+nexus.local.com/repository+g' /etc/apt/sources.list


### alpine
sed -i 's+https://dl-cdn.alpinelinux.org+http://nexus.local.com/repository+g' /etc/apk/repositories
```



