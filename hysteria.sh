#!/bin/bash

# 创建hy文件夹
mkdir hy

# 下载文件并更改权限
if [[ $(uname -m) == "x86_64" ]]; then
	echo "检测到的架构: $(uname -m)"
    wget -O hy/hysteria https://github.com/apernet/hysteria/releases/download/v1.3.5/hysteria-linux-amd64
    chmod 755 hy/hysteria
elif [[ $(uname -m) == "aarch64" ]]; then
	echo "检测到的架构: $(uname -m)"
    wget -O hy/hysteria https://github.com/apernet/hysteria/releases/download/v1.3.5/hysteria-linux-arm64
    chmod 755 hy/hysteria
else
    echo "此脚本不支持当前的CPU架构"
fi
cd hy
openssl ecparam -genkey -name prime256v1 -out ca.key
openssl req -new -x509 -days 36500 -key ca.key -out ca.crt  -subj "/CN=bing.com"
echo "创建自签证书"

touch config.json
config='
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
"cert": "/root/hy/ca.crt",
"key": "/root/hy/ca.key"
}
'
# 将内容写入文件
echo "$config" > config.json
# 输出结果
echo "config.json 服务端配置写入"

ipv4=$(curl -s ipv4.ip.sb)
echo "本机外网IPv4为：$ipv4"

touch ipv4.json
ip='
{
"server": "'$ipv4':9669",
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
'
# 将内容写入文件
echo "$ip" > ipv4.json
# 输出结果
echo "ipv4客户端配置写入"

ipv6=$(curl -s ipv6.ip.sb)
echo "本机外网IPv6为：$ipv6"

touch ipv6.json
ip6='
{
"server": "['$ipv6']:9669",
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
'
# 将内容写入文件
echo "$ip6" > ipv6.json
# 输出结果
echo "ipv6客户端配置写入"

echo "客户端文件在/root/hy/文件夹,运行请用以下代码"
echo "cd hy"
echo "./hysteria -c config.json server"
