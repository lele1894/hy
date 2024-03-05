#!/bin/bash

# 下载文件并更改权限
case $(uname -m) in
    x86_64)
        echo "检测到的架构: $(uname -m)"
        wget -O hysteria https://github.com/apernet/hysteria/releases/download/v1.3.4/hysteria-linux-amd64
        ;;
    aarch64)
        echo "检测到的架构: $(uname -m)"
        wget -O hysteria https://github.com/apernet/hysteria/releases/download/v1.3.4/hysteria-linux-arm64
        ;;
    *)
        echo "此脚本不支持当前的CPU架构"
        exit 1
        ;;
esac
chmod 755 hysteria

cd hy
openssl ecparam -genkey -name prime256v1 -out ca.key
openssl req -new -x509 -days 36500 -key ca.key -out ca.crt  -subj "/CN=bing.com"
echo "创建自签证书"

cat > config.json <<EOF
{
    "listen": ":9669",
    "protocol": "udp",
    "resolve_preference": "46",
    "auth": {
        "mode": "password",
        "config": {
            "password": "28fc7a"
        }
    },
    "alpn": "h3",
    "cert": "/root/ca.crt",
    "key": "/root/ca.key"
}
EOF
echo "config.json 服务端配置写入"

ipv4=$(curl -s ipv4.ip.sb)
echo "本机外网IPv4为：$ipv4"

cat > ipv4.json <<EOF
{
    "server": "${ipv4}:9669",
    "protocol": "udp",
    "up_mbps": 20,
    "down_mbps": 100,
    "alpn": "h3",
    "acl": "acl/routes.acl",
    "mmdb": "acl/Country.mmdb",
    "http": {
        "listen": "127.0.0.1:10809",
        "timeout" : 300,
        "disable_udp": false
    },
    "socks5": {
        "listen": "127.0.0.1:10808",
        "timeout": 300,
        "disable_udp": false
    },
    "auth_str": "28fc7a",
    "server_name": "www.bing.com",
    "insecure": true,
    "retry": 3,
    "retry_interval": 3,
    "fast_open": true,
    "hop_interval": 60
}
EOF
echo "ipv4客户端配置写入"

ipv6=$(curl -s ipv6.ip.sb)
echo "本机外网IPv6为：$ipv6"

cat > ipv6.json <<EOF
{
    "server": "[${ipv6}]:9669",
    "protocol": "udp",
    "up_mbps": 20,
    "down_mbps": 100,
    "alpn": "h3",
    "acl": "acl/routes.acl",
    "mmdb": "acl/Country.mmdb",
    "http": {
        "listen": "127.0.0.1:10809",
        "timeout" : 300,
        "disable_udp": false
    },
    "socks5": {
        "listen": "127.0.0.1:10808",
        "timeout": 300,
        "disable_udp": false
    },
    "auth_str": "28fc7a",
    "server_name": "www.bing.com",
    "insecure": true,
    "retry": 3,
    "retry_interval": 3,
    "fast_open": true,
    "hop_interval": 60
}
EOF
echo "ipv6客户端配置写入"

echo "客户端文件在/root/文件夹,运行请用以下代码"
echo "./hysteria -c config.json server"
