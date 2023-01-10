# 云服务开机脚本 本地Shell版 【Beta】

# 使用脚本

- 第一次运行必须安装 curl 和 jq 和 unzip，如果是这两个没有安装导致报错的请不要来找我！

- Centos系统
```
yum install curl jq unzip -y
```
 
- Ddebian和Ubuntu系统  UBUNTU16.04才行
```
apt-get install curl jq unzip -y
```


## AWS
EC2：
```
bash <(curl -Ls https://raw.githubusercontent.com/zxc348369518/open_cloud/main/aws/opencloud-aws-ec2.sh)

     
     
     
- 开机密码固定为：Opencloud@Leige 请登录后立即修改密码，Windows系统除外！

# api保存位置
- /root/opencloud/*

