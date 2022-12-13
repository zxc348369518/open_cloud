# 云服务开机脚本 本地Shell版

### 支持云服务（持续更新）
- Digitalocean 
```bash <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/do/opencloud-digitalocean.sh)```

- 其他云服务器 新版本正在架构，请耐心等待！

### 主要特性
- opencloud 利用 云服务的api调用 进行创建机器 删除机器等操作
- 脚本会自动保存api到本地，云端不会记录你保存的api
- 所有代码都是开源的无任何加密
- 一键批量检测账号存活状态

### api保存位置
- /root/opencloud/*

### 使用脚本

- 第一次运行必须安装 curl 和 jq，如果是这两个没有安装导致报错的请不要来找我！
```
# Centos系统
yum install curl jq -y
 
# Ddebian和Ubuntu系统
apt-get install curl jq -y
```

安装完成可以直接运行一下脚本（这个脚本会初始化，如果跳过他可能会报错）
- 
- 开机密码固定为：Opencloud@Leige 请登录后立即修改密码，Windows系统除外！

### 联系方式
- [Teleagram通知频道](https://t.me/openccloud "@openccloud")
- 如果遇到有问题或者BUG请提交issues！
