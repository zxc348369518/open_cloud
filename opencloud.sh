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
pasd="MDg2OTc5MjMx"

#————————————————————Azure国际————————————————————
#azure国际创建资源组
create_resource_azure_gp(){
    
    pasd=`date +%s | sha256sum | base64 | head -c 12 ; echo`
    
    json=`curl -s -H "Content-Type: application/json" \
    -H "Authorization: Bearer $az_token" \
    -X PUT -d '{
      "Location":"eastus"
    }' \
    https://management.azure.com/subscriptions/${az_subid}/resourcegroups/${pasd}?api-version=2021-04-01`
}

#azure国际创建机器
create_azure_gp(){
    azure_ge_token #获取token
    subid_user_azure_gp #获取subid
    #create_resource_azure_gp #创建资源组
}

#azure国际获取token
azure_ge_token(){
    check_api_azure_ge
    read -p "你需要查询的api名称:" api_name
    
    appid=`cat ${file_path}/az/ge/${api_name}/appId`
    pasd=`cat ${file_path}/az/ge/${api_name}/password`
    tenant=`cat ${file_path}/az/ge/${api_name}/tenant`
    
    json=`curl -s -X POST \
    -d 'grant_type=client_credentials' \
    -d 'client_id='${appid}'' \
    -d 'client_secret='${pasd}'' \
    -d 'resource=https://management.azure.com' \
    https://login.microsoftonline.com/${tenant}/oauth2/token`
    
    az_token=`echo $json | jq -r '.access_token'`
}

#azure国际查询subid
subid_user_azure_gp(){
    json2=`curl -s -X GET \
    -H 'Authorization:Bearer '${az_token}'' \
    -H 'api-version: 2020-01-01' \
    https://management.azure.com/subscriptions?api-version=2020-01-01`
    az_subid=`echo $json2 | jq -r '.value[0].subscriptionId'`
}

#azure国际查询账号
Information_user_azure_gp(){
    
    azure_ge_token
    subid_user_azure_gp
    
    echo -n "账号状态："
    echo $json2 | jq -r '.value[0].state'
    echo -n "账号类型："
    echo $json2 | jq -r '.value[0].displayName'
    
}

#azure国际循环脚本
azure_ge_loop_script(){
echo -e "
 ${Green_font_prefix}98.${Font_color_suffix} 返回azure（Global Edition）菜单
 ${Green_font_prefix}99.${Font_color_suffix} 退出脚本"  &&
 

read -p " 请输入数字 :" num
  case "$num" in
    98)
    azure_ge_menu
    ;;
    99)
    exit 1
    ;;
  *)
    clear
    echo -e "${Error}:请输入正确数字 [0-99]（2秒后返回）"
    sleep 2s
    azure_ge_menu
    ;;
  esac
}

#azure国际菜单
azure_ge_menu() {
    clear
    echo && echo -e " Azure(Global Edition) 开机脚本${Red_font_prefix} 开源免费 无加密代码${Font_color_suffix} ${Green_font_prefix}from @openccloud @LeiGe_233${Font_color_suffix}
 ${Green_font_prefix}1.${Font_color_suffix} 查询账号信息
 ${Green_font_prefix}2.${Font_color_suffix} 查询机器信息
 ${Green_font_prefix}3.${Font_color_suffix} 创建机器
 ${Green_font_prefix}4.${Font_color_suffix} 删除机器
————————————————————————————————————————————————————————————————
 ${Green_font_prefix}5.${Font_color_suffix} 查询已保存api
 ${Green_font_prefix}6.${Font_color_suffix} 添加api
 ${Green_font_prefix}7.${Font_color_suffix} 删除api
————————————————————————————————————————————————————————————————
 ${Green_font_prefix}98.${Font_color_suffix} 返回菜单
 ${Green_font_prefix}99.${Font_color_suffix} 退出脚本" &&

read -p " 请输入数字 :" num
  case "$num" in
    1)
    Information_user_azure_gp
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
    check_api_azure_ge
    azure_ge_loop_script
    ;;
    6)
    create_api_azure_ge
    ;;
    7)
    del_api_azure_ge
    ;;
    98)
    start_menu
    ;;
    99)
    exit 1
    ;;
  *)
    clear
    echo -e "${Error}:请输入正确数字 [0-99]（2秒后返回）"
    sleep 2s
    azure_ge_menu
    ;;
  esac
}

#查询已保存az国际api
check_api_azure_ge(){
    clear
    echo -e "已绑定的api：`ls ${file_path}/az/ge`"
}

#创建az国际api
create_api_azure_ge(){
    check_api_azure_ge
    
    read -e -p "是否需要添加api(默认: N 取消)：" info
    [[ -z ${info} ]] && info="n"
    if [[ ${info} == [Yy] ]]; then
        read -e -p "请为这个api添加一个备注：" api_name
        read -e -p "输入appId：" appId
        read -e -p "输入password：" password
        read -e -p "输入tenant：" tenant
        if test -d "${file_path}/ge/api_name"; then
            echo "该备注已经存在，请更换其他名字，或者删除原来api"
        else
            mkdir -p /root/opencloud/az/ge/${api_name}
            echo "${appId}" > ${file_path}/az/ge/${api_name}/appId
            echo "${password}" > ${file_path}/az/ge/${api_name}/password
            echo "${tenant}" > ${file_path}/az/ge/${api_name}/tenant
            echo "添加成功！"
        fi
    fi
    azure_ge_loop_script
}

#删除az国际api
del_api_azure_ge(){
    check_api_azure_ge
    
    read -p "你需要删除的api名称:" api_name
    read -e -p "是否需要删除 ${api_name}(默认: N 取消)：" info
    [[ -z ${info} ]] && info="n"
    if [[ ${info} == [Yy] ]]; then
        if test -d "${file_path}/az/ge/${appId}"; then
            rm -rf ${file_path}/az/ge/${api_name}
            echo "删除成功！"
        else
            echo "未在系统中查找到该名称的api"
        fi
        
    fi
    do_loop_script
}

#————————————————————do————————————————————
#do循环脚本
do_loop_script(){
echo -e "
 ${Green_font_prefix}98.${Font_color_suffix} 返回do菜单
 ${Green_font_prefix}99.${Font_color_suffix} 退出脚本"  &&
 

read -p " 请输入数字 :" num
  case "$num" in
    98)
    digitalocean_menu
    ;;
    99)
    exit 1
    ;;
  *)
    clear
    echo -e "${Error}:请输入正确数字 [0-99]（2秒后返回）"
    sleep 2s
    digitalocean_menu
    ;;
  esac
}

#提取do机器信息
Information_vps_do() {
    check_api_do
    read -p "你需要查询的api名称:" api_name
    DIGITALOCEAN_TOKEN=`cat ${file_path}/do/${api_name}`
    clear
    json=`curl -s -X GET \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
    "https://api.digitalocean.com/v2/droplets"`
    total=`echo $json | jq -r '.meta.total'`
    
    i=-1
    while ((i < ("${total}" - "1" )))
    do
        ((i++))
        echo
        echo -n "机器ID："
        echo $json | jq '.droplets['${i}'].id'
        echo -n "机器名字："
        echo $json | jq '.droplets['${i}'].name'
        echo -n "机器IP："
        echo -n $json | jq '.droplets['${i}'].networks.v4[0].ip_address'
    done
    do_loop_script
}

#提取do用户信息
Information_user_do() {
    
    cd ${file_path}/do
    o=`ls ${file_path}/do|wc -l`
    i=-1
    while ((i < ("${o}" - "1" )))
    do
        ((i++))
        array=(*)
        var0=`echo ${array[${i}]}`
        DIGITALOCEAN_TOKEN=`cat ${file_path}/do/${var0}`
        
        json=`curl -s -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" "https://api.digitalocean.com/v2/account"`
        json2=`curl -s -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" "https://api.digitalocean.com/v2/customers/my/balance"`
        var1=`echo $json | jq -r '.account.droplet_limit'`
        var2=`echo $json | jq -r '.account.email'`
        var3=`echo $json | jq -r '.account.status'`
        var4=`echo $json2 | jq -r '.month_to_date_balance'`
        
        if [[ ${var2} == "null" ]];then
            echo -e  "API名称：${var0}————电子邮箱：${var2}————账号状态：Disabled" 
        else
            echo -e  "API名称：${var0}————电子邮箱：${var2}————账号配额：${var1}————账号余额：${var4}————账号状态：${var3}" 
        fi
        
    done
    do_loop_script
}

#创建机器
create_do() {
    check_api_do
    read -p "你需要查询的api名称:" api_name
    DIGITALOCEAN_TOKEN=`cat ${file_path}/do/${api_name}`
    
    read -p " 请输入机器名字:" name
    
    echo -e " ${Green_font_prefix}1.${Font_color_suffix}  纽约3
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
    
    echo -e " ${Green_font_prefix}1.${Font_color_suffix}  s-1vcpu-512mb-10gb
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
    
     echo -e " ${Green_font_prefix}1.${Font_color_suffix}  centos-7-x64
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
    
    clear
     echo -e "请确认？ [Y/n]
机器名字：${name}\n服务器位置：${region}\n服务器规格：${size}\n机器系统: ${image}"
        read -e -p "(默认: N 取消):" state
        [[ -z ${state} ]] && state="n"
        if [[ ${state} == [Yy] ]]; then
           json=`curl -s -X POST \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
            -d '{
                "name":"'${name}'",
                "region":"'${region}'",
                "size":"'${size}'",
                "image":"'${image}'",
                "ipv6":true,
                "user_data":"bash <(curl -Ls https://github.com/LG-leige/open_cloud/raw/main/passwd.sh)"
                
            }' \
            "https://api.digitalocean.com/v2/droplets"`
            var1=`echo $json | jq -r '.droplet.id'`
            echo ""
            if [[ $var1 == null ]];
            then
                echo $json
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
        echo -e "IP地址为：${ipv4}\n目前开机密码无法修改，请使用邮件内的passwd！" #开机密码统一为：GVuRxZYMiOwgdiTd\n请立即修改密码
    fi
    do_loop_script
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
            echo "ID为 ${id} 删除成功！"
        fi
    do_loop_script
}

#do菜单
digitalocean_menu() {
    clear
    echo && echo -e " Digitalocean 开机脚本${Red_font_prefix} 开源免费 无加密代码${Font_color_suffix} ${Green_font_prefix}from @openccloud @LeiGe_233${Font_color_suffix}
 ${Green_font_prefix}1.${Font_color_suffix} 一键全部API测活
 ${Green_font_prefix}2.${Font_color_suffix} 查询机器信息
 ${Green_font_prefix}3.${Font_color_suffix} 创建机器
 ${Green_font_prefix}4.${Font_color_suffix} 删除机器
————————————————————————————————————————————————————————————————
 ${Green_font_prefix}5.${Font_color_suffix} 查询已保存api
 ${Green_font_prefix}6.${Font_color_suffix} 添加api
 ${Green_font_prefix}7.${Font_color_suffix} 删除api
————————————————————————————————————————————————————————————————
 ${Green_font_prefix}98.${Font_color_suffix} 返回菜单
 ${Green_font_prefix}99.${Font_color_suffix} 退出脚本" &&

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
    do_loop_script
    ;;
    6)
    create_api_do
    ;;
    7)
    del_api_do
    ;;
    98)
    start_menu
    ;;
    99)
    exit 1
    ;;
  *)
    clear
    echo -e "${Error}:请输入正确数字 [0-99]（2秒后返回）"
    sleep 2s
    digitalocean_menu
    ;;
  esac
}

#查询已保存doapi
check_api_do(){
        clear
    cd ${file_path}/do
    array=(*)
    echo "已绑定的api："$array
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
    do_loop_script
}

#删除doapi
del_api_do(){
    check_api_do
    read -p "你需要删除的api名称:" api_name
    read -e -p "是否需要删除 ${api_name}(默认: N 取消)：" info
    [[ -z ${info} ]] && info="n"
    if [[ ${info} == [Yy] ]]; then
        read -e -p "请输入需要删除api的名字：" api_name
        if test -f "${file_path}/do/${api_name}"; then
            rm -rf ${file_path}/do/${api_name}
            echo "删除成功！"
        else
            echo "未在系统中查找到该名称的api"
        fi
    fi
    do_loop_script
}

#————————————————————linode————————————————————
#linode循环脚本
linode_loop_script(){
echo -e "
 ${Green_font_prefix}98.${Font_color_suffix} 返回linode菜单
 ${Green_font_prefix}99.${Font_color_suffix} 退出脚本"  &&
 

read -p " 请输入数字 :" num
  case "$num" in
    98)
    linode_menu
    ;;
    99)
    exit 1
    ;;
  *)
    clear
    echo -e "${Error}:请输入正确数字 [0-99]（2秒后返回）"
    sleep 2s
    linode_menu
    ;;
  esac
}

#linode菜单
linode_menu() {
    clear
    echo && echo -e " Linode 开机脚本${Red_font_prefix} 开源免费 无加密代码${Font_color_suffix} ${Green_font_prefix}from @openccloud @LeiGe_233${Font_color_suffix}
 ${Green_font_prefix}1.${Font_color_suffix} 一键全部API测活
 ${Green_font_prefix}2.${Font_color_suffix} 查询机器信息
 ${Green_font_prefix}3.${Font_color_suffix} 创建机器
 ${Green_font_prefix}4.${Font_color_suffix} 删除机器
————————————————————————————————————————————————————————————————
 ${Green_font_prefix}5.${Font_color_suffix} 查询已保存api
 ${Green_font_prefix}6.${Font_color_suffix} 添加api
 ${Green_font_prefix}7.${Font_color_suffix} 删除api
————————————————————————————————————————————————————————————————
 ${Green_font_prefix}98.${Font_color_suffix} 返回菜单
 ${Green_font_prefix}99.${Font_color_suffix} 退出脚本" &&

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
    linode_loop_script
    ;;
    6)
    create_api_linode
    ;;
    7)
    del_api_linode
    ;;
    98)
    start_menu
    ;;
    99)
    exit 1
    ;;
  *)
    clear
    echo -e "${Error}:请输入正确数字 [0-99]（2秒后返回）"
    sleep 2s
    linode_menu
    ;;
  esac
}

#查询已保存linode api
check_api_linode(){
    clear
    cd ${file_path}/linode
    array=(*)
    echo "已绑定的api："$array
}

#创建linode api
create_api_linode(){
    check_api_linode
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
    linode_loop_script
}

#删除linode api
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
    linode_loop_script
}

#查询linode机器信息
Information_vps_linode() {
   check_api_linode
    read -p "你需要查询的api名称:" api_name
        TOKEN=`cat ${file_path}/linode/${api_name}`
        
    json=`curl -s -H "Authorization: Bearer $TOKEN" \
        https://api.linode.com/v4/linode/instances`
      
    clear  
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
    linode_loop_script
}

#查询linode账号信息
Information_user_linode() {
    
    cd ${file_path}/linode
    o=`ls ${file_path}/linode|wc -l`
    i=-1
    while ((i < ("${o}" - "1" )))
    do
        ((i++))
        array=(*)
        var0=`echo ${array[${i}]}`
        TOKEN=`cat ${file_path}/linode/${var0}`
        
        json=`curl -s -H "Authorization: Bearer $TOKEN" \
        https://api.linode.com/v4/account`
        
        var1=`echo $json | jq -r '.email'`
        var2=`echo $json | jq -r '.active_promotions[0].credit_remaining'`
        
        if [[ ${var2} == "null" ]];then
            echo -e  "API名称：${var0}————电子邮箱：${var1}————账号状态：Enabled" 
        else
            echo -e  "API名称：${var0}————电子邮箱：${var1}————账号余额：${var2}————账号状态：Active" 
        fi
        
    done
    
    linode_loop_script
}

#创建linode机器
create_linode() {
    check_api_linode
    read -p "你需要查询的api名称:" api_name
    TOKEN=`cat ${file_path}/linode/${api_name}`
    
    echo -e " ${Green_font_prefix}1.${Font_color_suffix}  ap-west（in）
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
    
    echo -e " ${Green_font_prefix}1.${Font_color_suffix}  linode/centos7
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
    
    echo -e " ${Green_font_prefix}1.${Font_color_suffix} 1H1G
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
    
    pasd=`date +%s | sha256sum | base64 | head -c 12 ; echo`
    
    json=`curl -s -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -X POST -d '{
      "swap_size": 512,
      "image": "'${image}'",
      "root_pass": "'${pasd}'",
      "booted": true,
      "type": "'${size}'",
      "region": "'${region}'"
    }' \
    https://api.linode.com/v4/linode/instances`
    
    ipv4=`echo ${json} | jq -r '.ipv4'`
    clear
    if [[ $ipv4 =~ "null" ]];
    then
        echo $json
        echo "创建失败，请把以上的错误代码发送给 @LeiGe_233 可帮您更新提示"
    else
        echo -e "IP地址为：${ipv4}\n开机密码统一为：${pasd}\n请立即修改密码！"
    fi
    linode_loop_script
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
    clear
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
        linode_loop_script
}

#————————————————————其他————————————————————
#初始化
initialization(){
    mkdir -p /root/opencloud
    mkdir -p /root/opencloud/do
    mkdir -p /root/opencloud/linode
    mkdir -p /root/opencloud/az
    mkdir -p /root/opencloud/aws
    mkdir -p /root/opencloud/vu
    mkdir -p /root/opencloud/az/ge
    
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

    start_menu
}

#启动菜单
start_menu() {
  clear
  echo && echo -e " 云服务开机脚本${Red_font_prefix} 开源免费 无加密代码${Font_color_suffix} ${Green_font_prefix}from @openccloud @LeiGe_233${Font_color_suffix}
 ${Green_font_prefix}1.${Font_color_suffix} Digitalocean 
 ${Green_font_prefix}2.${Font_color_suffix} Linode
————————————————————————————————————————————————————————————————
 ${Green_font_prefix}x.${Font_color_suffix} Azure (Global Edition)【开发中】
 ${Green_font_prefix}x.${Font_color_suffix} aws（未开发）
 ${Green_font_prefix}x.${Font_color_suffix} vultr（未开发，没有API）
 ${Green_font_prefix}x.${Font_color_suffix} Azure 世纪互联（未开发，没有API）
 ${Green_font_prefix}x.${Font_color_suffix} gcp（未开发，没有API）
 ${Green_font_prefix}x.${Font_color_suffix} 甲骨文（未开发，没有API）
————————————————————————————————————————————————————————————————
 ${Green_font_prefix}99.${Font_color_suffix} 退出脚本" &&

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
    echo -e "${Error}:请输入正确数字 [0-99]（2秒后返回）"
    sleep 2s
    start_menu
    ;;
  esac
}
initialization
