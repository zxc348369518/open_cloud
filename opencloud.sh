#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"
file_path="/root/opencloud"
Version="22.10.2-3"

#提取do机器信息
Information_vps_do() {
    check_api_do
    read -p "你需要查询的api名称:" api_name
    DIGITALOCEAN_TOKEN=`cat ${file_path}/do/${api_name}`
    
    json=`curl -s -X GET \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
    "https://api.digitalocean.com/v2/droplets"`
    total=`echo $json | jq -r '.meta.total'`
    
    i=-1
    while ((i < ("${total}" - "1" )))
    do
        ((i++))
        echo "机器ID："
        echo $json | jq '.droplets['${i}'].id'
        echo "机器名字："
        echo $json | jq '.droplets['${i}'].name'
        echo "机器IP："
        echo $json | jq '.droplets['${i}'].networks.v4[0].ip_address'
        echo $json | jq '.droplets['${i}'].networks.v4[1].ip_address'
        echo -e "\n"
    done
}

#提取do用户信息
Information_user_do() {
    check_api_do
    read -p "你需要查询的api名称:" api_name
    DIGITALOCEAN_TOKEN=`cat ${file_path}/do/${api_name}`
    json=`curl -s -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" "https://api.digitalocean.com/v2/account"`
    json2=`curl -s -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" "https://api.digitalocean.com/v2/customers/my/balance"`
    if [[ $json =~ "Unable to authenticate you" ]];
    then
        echo "获取失败：无法对您进行身份验证"
    else
        var1=`echo $json | jq -r '.account.droplet_limit'`
        var2=`echo $json | jq -r '.account.email'`
        var3=`echo $json | jq -r '.account.status'`
        var4=`echo $json2 | jq -r '.month_to_date_balance'`
        echo -e  "电子邮箱：${var2}\n账号配额：${var1}\n账号状态：${var3}\n账号余额：${var4}" 
    fi
}

#创建机器
create_do() {
    check_api_do
    read -p "你需要查询的api名称:" api_name
    DIGITALOCEAN_TOKEN=`cat ${file_path}/do/${api_name}`
    
    read -p " 请输入机器名字:" name
    
    echo && echo -e " ${Green_font_prefix}1.${Font_color_suffix}  纽约3
 ${Green_font_prefix}2.${Font_color_suffix}  纽约1 
 ${Green_font_prefix}3.${Font_color_suffix}  加利福尼亚1（未开放）
 ${Green_font_prefix}4.${Font_color_suffix}  纽约2（未开放）
 ${Green_font_prefix}5.${Font_color_suffix}  阿姆斯特丹2（未开放）
 ${Green_font_prefix}6.${Font_color_suffix}  新加坡1
 ${Green_font_prefix}7.${Font_color_suffix}  阿姆斯特丹3
 ${Green_font_prefix}8.${Font_color_suffix}  法兰克福1
 ${Green_font_prefix}9.${Font_color_suffix}  加拿大1
 ${Green_font_prefix}10.${Font_color_suffix}  加利福尼亚2（未开放）
 ${Green_font_prefix}11.${Font_color_suffix}  印度
 ${Green_font_prefix}12.${Font_color_suffix}  加利福尼亚3
 ${Green_font_prefix}13.${Font_color_suffix}  悉尼"
    read -e -p "请选择你的服务器位置:" region
    if [[ ${region} == "1" ]]; then
        region="nyc3"
    elif [[ ${region} == "2" ]]; then
        region="nyc1"
    elif [[ ${region} == "3" ]]; then
        region="sfo1"
    elif [[ ${region} == "4" ]]; then
        region="nyc2"
    elif [[ ${region} == "5" ]]; then
        region="ams2"
    elif [[ ${region} == "6" ]]; then
        region="sgp1"
    elif [[ ${region} == "7" ]]; then
        region="ams3"
    elif [[ ${region} == "8" ]]; then
        region="fra1"
    elif [[ ${region} == "9" ]]; then
        region="tor1"
    elif [[ ${region} == "10" ]]; then
        region="sfo2"
    elif [[ ${region} == "11" ]]; then
        region="blr1"
    elif [[ ${region} == "12" ]]; then
        region="sfo3"
    else
        region="syd1"
    fi
    
    echo && echo -e " ${Green_font_prefix}1.${Font_color_suffix}  s-1vcpu-512mb-10gb
 ${Green_font_prefix}2.${Font_color_suffix}  s-1vcpu-1gb 
 ${Green_font_prefix}3.${Font_color_suffix}  s-1vcpu-1gb-amd
 ${Green_font_prefix}4.${Font_color_suffix}  s-1vcpu-1gb-intel
 ${Green_font_prefix}5.${Font_color_suffix}  s-1vcpu-2gb
 ${Green_font_prefix}6.${Font_color_suffix}  s-1vcpu-2gb-amd
 ${Green_font_prefix}7.${Font_color_suffix}  s-1vcpu-2gb-intel
 ${Green_font_prefix}8.${Font_color_suffix}  s-2vcpu-2gb
 ${Green_font_prefix}9.${Font_color_suffix}  s-2vcpu-2gb-amd
 ${Green_font_prefix}10.${Font_color_suffix}  s-2vcpu-2gb-intel
 ${Green_font_prefix}11.${Font_color_suffix}  s-2vcpu-4gb
 ${Green_font_prefix}12.${Font_color_suffix}  s-2vcpu-4gb-amd
 ${Green_font_prefix}13.${Font_color_suffix}  s-2vcpu-4gb-intel"
    read -p " 请输入机器规格:" size
    if [[ ${size} == "1" ]]; then
        size="s-1vcpu-512mb-10gb"
    elif [[ ${size} == "2" ]]; then
        size="s-1vcpu-1gb"
    elif [[ ${size} == "3" ]]; then
        size="s-1vcpu-1gb-amd"
    elif [[ ${size} == "4" ]]; then
        size="s-1vcpu-1gb-intel"
    elif [[ ${size} == "5" ]]; then
        size="s-1vcpu-2gb"
    elif [[ ${size} == "6" ]]; then
        size="s-1vcpu-2gb-amd"
    elif [[ ${size} == "7" ]]; then
        size="s-1vcpu-2gb-intel"
    elif [[ ${size} == "8" ]]; then
        size="s-2vcpu-2gb"
    elif [[ ${size} == "9" ]]; then
        size="s-2vcpu-2gb-amd"
    elif [[ ${size} == "10" ]]; then
        size="s-2vcpu-2gb-intel"
    elif [[ ${size} == "11" ]]; then
        size="s-2vcpu-4gb"
    elif [[ ${size} == "12" ]]; then
        size="s-2vcpu-4gb-amd"
    else
        size="s-2vcpu-4gb-intel"
    fi
    
    data="#!/bin/bash && echo root:GVuRxZYMiOwgdiTd |sudo chpasswd root \ sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config; && sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config; && sudo service sshd restart"

    echo && echo -e " ${Green_font_prefix}1.${Font_color_suffix}  centos-7-x64
 ${Green_font_prefix}2.${Font_color_suffix}  centos-stream-8-x64
 ${Green_font_prefix}3.${Font_color_suffix}  debian-11-x64
 ${Green_font_prefix}4.${Font_color_suffix}  debian-10-x64
 ${Green_font_prefix}5.${Font_color_suffix}  ubuntu-22-04-x64
 ${Green_font_prefix}6.${Font_color_suffix}  ubuntu-20-04-x64
 ${Green_font_prefix}7.${Font_color_suffix}  ubuntu-18-04-x64
 ${Green_font_prefix}8.${Font_color_suffix}  centos-stream-9-x64"
    read -p " 请输入机器系统:" image
    if [[ ${image} == "1" ]]; then
        image="centos-7-x64"
    elif [[ ${image} == "2" ]]; then
        image="centos-stream-8-x64"
    elif [[ ${image} == "3" ]]; then
        image="debian-11-x64"
    elif [[ ${image} == "4" ]]; then
        image="debian-10-x64"
    elif [[ ${image} == "5" ]]; then
        image="ubuntu-22-04-x64"
    elif [[ ${image} == "6" ]]; then
        image="ubuntu-20-04-x64"
    elif [[ ${image} == "7" ]]; then
        image="ubuntu-18-04-x64"
    else
        image="centos-stream-9-x64"
    fi

     echo -e "请确认？ [Y/n]
机器名字：${name}\n服务器位置：${region}\n服务器规格：${size}\n机器系统: ${image}"
        read -e -p "(默认: N 取消):" state
        [[ -z ${state} ]] && state="n"
        if [[ ${state} == [Yy] ]]; then
           json=`curl -s -X POST \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
            -d '{"name":"'${name}'","region":"'${region}'","size":"'${size}'","image":"'${image}'","ipv6":true,"user_data":"bash <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/passwd.sh)"}' \
            "https://api.digitalocean.com/v2/droplets"`
            echo $json
            if [[ $json =~ "created_at" ]];
            then
                echo "创建失败，请把以上的错误代码发送给 @LeiGe_233 可帮您更新提示"
            else
                echo "创建中，请稍等！"
                cheek_ip_do
            fi
        fi

}

#获取doip
cheek_ip_do(){
    
    var1=`echo $json | jq -r '.droplet.id'`
    json=`curl -s -X GET \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
    "https://api.digitalocean.com/v2/droplets/${var1}"`
    ipv4=`echo $json | jq -r '.droplet.networks.v4[0].ip_address'`
    
    if [[ $ipv4 =~ "null" ]];
    then
        cheek_ip_do
    else
        echo -e "IP地址为：${ipv4}\n开机密码统一为：GVuRxZYMiOwgdiTd\n请立即修改密码！"
    fi
}

#删除机器
del_do() {
    check_api_do
    read -p "你需要删除哪个api下的机器（输入API名字）:" api_name
    DIGITALOCEAN_TOKEN=`cat ${file_path}/do/${api_name}`
    
    json=`curl -s -X GET \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
    "https://api.digitalocean.com/v2/droplets"`
    total=`echo $json | jq -r '.meta.total'`
    
    i=-1
    while ((i < ("${total}" - "1" )))
    do
        ((i++))
        echo "机器ID："
        echo $json | jq '.droplets['${i}'].id'
        echo "机器名字："
        echo $json | jq '.droplets['${i}'].name'
        echo "机器IP："
        echo $json | jq '.droplets['${i}'].networks.v4[0].ip_address'
        echo $json | jq '.droplets['${i}'].networks.v4[1].ip_address'
        echo -e "\n"
    done
    
    read -e -p "请输入需要删除机器的id号：" id
    read -e -p "是否需要删除id为 ${id} (默认: N 取消)：" info
        [[ -z ${info} ]] && info="n"
        if [[ ${info} == [Yy] ]]; then
            curl -s -X DELETE \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
            "https://api.digitalocean.com/v2/droplets/${id}"
        fi
}

#do菜单
digitalocean_menu() {
    clear
    echo && echo -e " Digitalocean 开机脚本${Red_font_prefix} [V${Version}] 开源免费${Font_color_suffix} ${Green_font_prefix}from @openccloud @LeiGe_233${Font_color_suffix}
 ${Green_font_prefix}1.${Font_color_suffix} 查询账号信息
 ${Green_font_prefix}2.${Font_color_suffix} 查询机器信息
 ${Green_font_prefix}3.${Font_color_suffix} 创建机器
 ${Green_font_prefix}4.${Font_color_suffix} 删除机器
————————————————————————————————————————————————————————————————
 ${Green_font_prefix}5.${Font_color_suffix} 查询已保存api
 ${Green_font_prefix}6.${Font_color_suffix} 添加api
 ${Green_font_prefix}7.${Font_color_suffix} 删除api
————————————————————————————————————————————————————————————————
 ${Green_font_prefix}99.${Font_color_suffix} 退出" &&

read -p " 请输入数字 :" num
  case "$num" in
    1)
    Information_user_do
    ;;
    2)
    Information_vps_do
    ;;
    3)
    create_do
    ;;
    4)
    del_do
    ;;
    5)
    check_api_do
    ;;
    6)
    create_api_do
    ;;
    7)
    del_api_do
    ;;
    99)
    start_menu
    ;;
  *)
    clear
    echo -e "${Error}:请输入正确数字 [0-99]"
    sleep 5s
    start_menu
    ;;
  esac
}

#查询已保存doapi
check_api_do(){
    echo -e "已绑定的api：`ls ${file_path}/do`"
}

#创建doapi
create_api_do(){
    check_api_do
    read -e -p "是否需要添加api(默认: N 取消)：" info
    [[ -z ${info} ]] && info="n"
    if [[ ${info} == [Yy] ]]; then
        read -e -p "请为这个api添加一个备注：" api_name
        read -e -p "输入api：" api_key
        if test -f "${file_path}/do/api_name"; then
            echo "该备注已经存在，请更换其他名字，或者删除原来api"
        else
            echo "${api_key}" > ${file_path}/do/${api_name}
            echo "添加成功！"
        fi
    fi
}

#删除doapi
del_api_do(){
    check_api_do
    read -p "你需要删除的api名称:" api_name
    read -e -p "是否需要删除 ${api_name}(默认: N 取消)：" info
    [[ -z ${info} ]] && info="n"
    if [[ ${info} == [Yy] ]]; then
        read -e -p "请输入需要删除api的名字：" api_name
        if test -f "${file_path}/do/api_name"; then
            rm -rf ${file_path}/do/${api_name}
            echo "删除成功！"
        else
            echo "未在系统中查找到该名称的api"
        fi
    fi
}

#初始化
initialization(){
    depends=("jq")
    depend=""
    for i in "${!depends[@]}"; do
      now_depend="${depends[$i]}"
      if [ ! -x "$(command -v $now_depend 2>/dev/null)" ]; then
        echo "$now_depend 未安装"
        depend="$now_depend $depend"
      fi
    done
    if [ "$depend" ]; then
      if [ -x "$(command -v apk 2>/dev/null)" ]; then
        echo "apk包管理器,正在尝试安装依赖:$depend"
        apk --no-cache add $depend $proxy >>/dev/null 2>&1
      elif [ -x "$(command -v apt-get 2>/dev/null)" ]; then
        echo "apt-get包管理器,正在尝试安装依赖:$depend"
        apt -y install $depend >>/dev/null 2>&1
      elif [ -x "$(command -v yum 2>/dev/null)" ]; then
        echo "yum包管理器,正在尝试安装依赖:$depend"
        yum -y install $depend >>/dev/null 2>&1
      else
        red "未找到合适的包管理工具,请手动安装:$depend"
        exit 1
      fi
      for i in "${!depends[@]}"; do
        now_depend="${depends[$i]}"
        if [ ! -x "$(command -v $now_depend)" ]; then
          red "$now_depend 未成功安装,请尝试手动安装!"
          exit 1
        fi
      done
    fi

    mkdir -p /root/opencloud
    mkdir -p /root/opencloud/do
    mkdir -p /root/opencloud/linode
    mkdir -p /root/opencloud/az
    mkdir -p /root/opencloud/aws
    mkdir -p /root/opencloud/vu

    start_menu
}

#启动菜单
start_menu() {
  clear
  echo && echo -e " 云服务开机脚本${Red_font_prefix} [V${Version}] 开源免费${Font_color_suffix} ${Green_font_prefix}from @openccloud @LeiGe_233${Font_color_suffix}
 ${Green_font_prefix}1.${Font_color_suffix} Digitalocean 
 ${Green_font_prefix}2.${Font_color_suffix} Linode
————————————————————————————————————————————————————————————————
 ${Green_font_prefix}99.${Font_color_suffix} 退出" &&

read -p " 请输入数字 :" num
  case "$num" in
    1)
    digitalocean_menu
    ;;
    2)
    linode_menu
    ;;
    99)
    exit 1
    ;;
  *)
    clear
    echo -e "${Error}:请输入正确数字 [0-99]"
    sleep 5s
    start_menu
    ;;
  esac
}

#linode菜单
linode_menu() {
    clear
    echo && echo -e " Linode 开机脚本${Red_font_prefix} [V${Version}] 开源免费${Font_color_suffix} ${Green_font_prefix}from @openccloud @LeiGe_233${Font_color_suffix}
 ${Green_font_prefix}1.${Font_color_suffix} 查询账号信息
 ${Green_font_prefix}2.${Font_color_suffix} 查询机器信息
 ${Green_font_prefix}3.${Font_color_suffix} 创建机器
 ${Green_font_prefix}4.${Font_color_suffix} 删除机器
————————————————————————————————————————————————————————————————
 ${Green_font_prefix}5.${Font_color_suffix} 查询已保存api
 ${Green_font_prefix}6.${Font_color_suffix} 添加api
 ${Green_font_prefix}7.${Font_color_suffix} 删除api
————————————————————————————————————————————————————————————————
 ${Green_font_prefix}99.${Font_color_suffix} 退出" &&

read -p " 请输入数字 :" num
  case "$num" in
    1)
    Information_user_linode
    ;;
    2)
    Information_vps_linode
    ;;
    3)
    create_linode
    ;;
    4)
    del_linode
    ;;
    5)
    check_api_linode
    ;;
    6)
    create_api_linode
    ;;
    7)
    del_api_linode
    ;;
    99)
    start_menu
    ;;
  *)
    clear
    echo -e "${Error}:请输入正确数字 [0-99]"
    sleep 5s
    start_menu
    ;;
  esac
}

#查询已保存linodeapi
check_api_linode(){
    echo -e "已绑定的api：`ls ${file_path}/linode`"
}

#创建linodeapi
create_api_linode(){
    check_api_do
    read -e -p "是否需要添加api(默认: N 取消)：" info
    [[ -z ${info} ]] && info="n"
    if [[ ${info} == [Yy] ]]; then
        read -e -p "请为这个api添加一个备注：" api_name
        read -e -p "输入api：" api_key
        if test -f "${file_path}/linode/api_name"; then
            echo "该备注已经存在，请更换其他名字，或者删除原来api"
        else
            echo "${api_key}" > ${file_path}/linode/${api_name}
            echo "添加成功！"
        fi
    fi
}

#删除linodeapi
del_api_linode(){
    check_api_linode
    read -p "你需要删除的api名称:" api_name
    read -e -p "是否需要删除 ${api_name}(默认: N 取消)：" info
    [[ -z ${info} ]] && info="n"
    if [[ ${info} == [Yy] ]]; then
        read -e -p "请输入需要删除api的名字：" api_name
        if test -f "${file_path}/linode/${api_name}"; then
            rm -rf ${file_path}/linode/${api_name}
            echo "删除成功！"
        else
            echo "未在系统中查找到该名称的api"
        fi
    fi
}

#查询linode机器信息
Information_vps_linode() {
   check_api_linode
    read -p "你需要查询的api名称:" api_name
        TOKEN=`cat ${file_path}/linode/${api_name}`
        
    json=`curl -s -H "Authorization: Bearer $TOKEN" \
        https://api.linode.com/v4/linode/instances`
        
    total=`echo $json | jq -r '.results'`
    echo "查询结果为空代表 账号下没有任何机器 或者 账号已经失效了"
    i=-1
    while ((i < ("${total}" - "1" )))
    do
        ((i++))
        echo "机器ID："
        echo $json | jq '.data['${i}'].id'
        echo "机器ipv4："
        echo $json | jq '.data['${i}'].ipv4'
        echo -e "\n"
    done 
}

#查询linode账号信息
Information_user_linode() {
    check_api_linode
    read -p "你需要查询的api名称:" api_name
    TOKEN=`cat ${file_path}/linode/${api_name}`
    json=`curl -s -H "Authorization: Bearer $TOKEN" \
    https://api.linode.com/v4/account`

    if [[ $json =~ "Invalid Token" ]];
    then
        echo "获取失败：令牌无效"
    else
        var1=`echo $json | jq -r '.email'`
        var2=`echo $json | jq -r '.active_promotions[0].credit_remaining'`
        echo -e  "电子邮箱：${var1}\n账号余额：${var2}\n有余额的账号才是正常的！" 
    fi
}

#创建linode机器
create_linode() {
    check_api_linode
    read -p "你需要查询的api名称:" api_name
    TOKEN=`cat ${file_path}/linode/${api_name}`
    
    echo && echo -e " ${Green_font_prefix}1.${Font_color_suffix}  ap-west（in）
 ${Green_font_prefix}2.${Font_color_suffix}  ca-central（ca）
 ${Green_font_prefix}3.${Font_color_suffix}  ap-southeast（au）
 ${Green_font_prefix}4.${Font_color_suffix}  us-central（us）
 ${Green_font_prefix}5.${Font_color_suffix}  us-west（us）
 ${Green_font_prefix}6.${Font_color_suffix}  us-southeast（us）
 ${Green_font_prefix}7.${Font_color_suffix}  us-east（us）
 ${Green_font_prefix}8.${Font_color_suffix}  eu-west（uk）
 ${Green_font_prefix}9.${Font_color_suffix}  ap-south（sg）
 ${Green_font_prefix}10.${Font_color_suffix}  eu-central（de）
 ${Green_font_prefix}11.${Font_color_suffix}  ap-northeast（JP）"
    read -e -p "请选择你的服务器位置:" region
    if [[ ${region} == "1" ]]; then
        region="ap-west"
    elif [[ ${region} == "2" ]]; then
        region="ca-central"
    elif [[ ${region} == "3" ]]; then
        region="ap-southeast"
    elif [[ ${region} == "4" ]]; then
        region="us-central"
    elif [[ ${region} == "5" ]]; then
        region="us-west"
    elif [[ ${region} == "6" ]]; then
        region="us-southeast"
    elif [[ ${region} == "7" ]]; then
        region="us-east"
    elif [[ ${region} == "8" ]]; then
        region="eu-west"
    elif [[ ${region} == "9" ]]; then
        region="ap-south"
    elif [[ ${region} == "10" ]]; then
        region="eu-central"
    else
        region="ap-northeast"
    fi
    
    echo && echo -e " ${Green_font_prefix}1.${Font_color_suffix}  linode/centos7
 ${Green_font_prefix}2.${Font_color_suffix}  linode/centos-stream8
 ${Green_font_prefix}3.${Font_color_suffix}  linode/centos-stream9
 ${Green_font_prefix}4.${Font_color_suffix}  linode/debian10
 ${Green_font_prefix}5.${Font_color_suffix}  linode/debian11
 ${Green_font_prefix}6.${Font_color_suffix}  linode/debian9
 ${Green_font_prefix}7.${Font_color_suffix}  linode/ubuntu16.04lts
 ${Green_font_prefix}8.${Font_color_suffix}  linode/ubuntu18.04
 ${Green_font_prefix}9.${Font_color_suffix}  linode/ubuntu20.04
 ${Green_font_prefix}10.${Font_color_suffix}  linode/ubuntu22.04
 ${Green_font_prefix}11.${Font_color_suffix}  linode/centos8
 ${Green_font_prefix}12.${Font_color_suffix}  linode/ubuntu21.04
 ${Green_font_prefix}13.${Font_color_suffix}  linode/ubuntu21.10"
    read -e -p "请选择你的服务器位置:" image
    if [[ ${image} == "1" ]]; then
        image="linode/centos7"
    elif [[ ${image} == "2" ]]; then
        image="linode/centos-stream8"
    elif [[ ${image} == "3" ]]; then
        image="linode/centos-stream9"
    elif [[ ${image} == "4" ]]; then
        image="linode/debian10"
    elif [[ ${image} == "5" ]]; then
        image="linode/debian11"
    elif [[ ${image} == "6" ]]; then
        image="linode/debian9"
    elif [[ ${image} == "7" ]]; then
        image="linode/ubuntu16.04lts"
    elif [[ ${image} == "8" ]]; then
        image="linode/ubuntu18.04"
    elif [[ ${image} == "9" ]]; then
        image="linode/ubuntu20.04"
    elif [[ ${image} == "10" ]]; then
        image="linode/ubuntu22.04"
    elif [[ ${image} == "11" ]]; then
        image="linode/centos8"
    elif [[ ${image} == "12" ]]; then
        image="linode/ubuntu21.04"
    else
        image="linode/ubuntu21.10"
    fi
    
    echo && echo -e " ${Green_font_prefix}1.${Font_color_suffix} 1H1G
 ${Green_font_prefix}2.${Font_color_suffix}  1H2G
 ${Green_font_prefix}3.${Font_color_suffix}  2H4G
 ${Green_font_prefix}4.${Font_color_suffix}  4H8G
 ${Green_font_prefix}5.${Font_color_suffix}  6H16G"
    read -p " 请输入机器规格:" size
    if [[ ${size} == "1" ]]; then
        size="g6-nanode-1"
    elif [[ ${size} == "2" ]]; then
        size="g6-standard-1"
    elif [[ ${size} == "3" ]]; then
        size="g6-standard-2"
    elif [[ ${size} == "4" ]]; then
        size="g6-standard-4"
    else
        size="g6-standard-6"
    fi

    json=`curl -s -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -X POST -d '{
      "swap_size": 512,
      "image": "'${image}'",
      "root_pass": "GVuRxZYMiOwgdiTd",
      "booted": true,
      "type": "'${size}'",
      "region": "'${region}'"
    }' \
    https://api.linode.com/v4/linode/instances`
    
    ipv4=`echo ${json} | jq -r '.ipv4'`
    
    if [[ $ipv4 =~ "null" ]];
    then
        echo "创建失败"
    else
        echo -e "IP地址为：${ipv4}\n开机密码统一为：GVuRxZYMiOwgdiTd\n请立即修改密码！"
    fi
}

#删除linode机器
del_linode() {
    Information_vps_linode
    DIGITALOCEAN_TOKEN=`cat ${file_path}/linode/${api_name}`
    
    json=`curl -s -X GET \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
    "https://api.digitalocean.com/v2/droplets"`
    total=`echo $json | jq -r '.meta.total'`
    
    i=-1
    while ((i < ("${total}" - "1" )))
    do
        ((i++))
        echo "机器ID："
        echo $json | jq '.droplets['${i}'].id'
        echo "机器名字："
        echo $json | jq '.droplets['${i}'].name'
        echo "机器IP："
        echo $json | jq '.droplets['${i}'].networks.v4[0].ip_address'
        echo $json | jq '.droplets['${i}'].networks.v4[1].ip_address'
        echo -e "\n"
    done
    
    read -e -p "请输入需要删除机器的id号：" id
    read -e -p "是否需要删除id为 ${id} (默认: N 取消)：" info
        [[ -z ${info} ]] && info="n"
        if [[ ${info} == [Yy] ]]; then
            curl -s -H "Authorization: Bearer $TOKEN" \
            -X DELETE \
            https://api.linode.com/v4/linode/instances/${id}
            echo "${id} 删除成功"
        fi
}

initialization
