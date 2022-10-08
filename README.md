# 云服务开机脚本 本地Shell版

### 支持云服务（持续更新）
- Digitalocean
- Linode
> Ps：目前测试账紧缺，如果你有空闲或者多余的请联系我们，这样可以加快开发的速度！

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

安装完成可以直接运行一下脚本
- ```bash <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/opencloud.sh)```

### 联系方式
- [Teleagram通知频道](https://t.me/openccloud "@openccloud")
- [Teleagram](https://t.me/LeiGe_233 "LeiGe_233")
