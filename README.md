# 五合一开机脚本 本地版

> Ps：目前为第一个版本，仅支持do、Linode，请期待后续的更新，目前测试账紧缺，如果你有空闲或者多余的请联系我们，这样可以加快开发的速度

### 主要特性
- opencloud 利用 云服务的api调用 进行创建机器 删除机器等操作
- 脚本会自动保存api到本地，云端不会记录你保存的api
- 所有代码都是开源的无任何加密

### api保存位置
- /root/opencloud/do
- /root/opencloud/linode
- /root/opencloud/vu
- /root/opencloud/aws
- /root/opencloud/az

### 安装代码
- 所有机器创建的密码均为：GVuRxZYMiOwgdiTd   开机完成后请立即修改密码
- 使用前先需要安装 jq工具
- ```bash <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/opencloud.sh)```

> [@openccloud](https://t.me/openccloud "@openccloud")
