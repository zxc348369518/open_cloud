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
#do循环脚本
do_loop_script(){
echo -e "
 ${Green_font_prefix}98.${Font_color_suffix} 返回Digitalocean菜单
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

#do机器信息
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
    echo "`date` 正在进行查询 ${api_name} 已创建的机器" && echo
    i=-1
    while ((i < ("${total}" - "1" )))
    do
        ((i++))
        echo  "机器ID：`echo $json | jq '.droplets['${i}'].id'`——————机器名字：`echo $json | jq '.droplets['${i}'].name'`——————机器IP：`echo $json | jq '.droplets['${i}'].networks.v4[0].ip_address'`"
    done
    do_loop_script
}

#do一键测活
Information_user_do() {
    clear
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
        
        echo -e  "API名称：${var0}————电子邮箱：${var2}————账号配额：${var1}————账号余额：${var4}————账号状态：${var3}" 
        
    done
    do_loop_script
}

#do服务器位置
region_do(){
    json=`cat <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/digitalocean/region)`
    o=`echo $json| jq ".opencloud | length"`
    
    i=-1
    while ((i < ("${o}" - "1" )))
    do
        ((i++))
        echo -n -e "  ${Green_font_prefix}${i}.${Font_color_suffix}  "
        echo $json | jq -r '.opencloud['${i}'].name'
    done
    read -e -p "请选择你的服务器位置（编号）:" b
        region=`echo $json | jq -r '.opencloud['${b}'].id'`
}

#do服务器大小
size_do(){
    json=`cat <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/digitalocean/size)`
    o=`echo $json| jq ".opencloud | length"`
    
    i=-1
    while ((i < ("${o}" - "1" )))
    do
        ((i++))
        echo -n -e "  ${Green_font_prefix}${i}.${Font_color_suffix}  "
        echo $json | jq -r '.opencloud['${i}'].name'
    done
    read -e -p "请选择你的服务器大小（编号）:" b
        size=`echo $json | jq -r '.opencloud['${b}'].id'`
}

#do服务器镜像
image_do(){
    json=`cat <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/digitalocean/image)`
    o=`echo $json| jq ".opencloud | length"`
    
    i=-1
    while ((i < ("${o}" - "1" )))
    do
        ((i++))
        echo -n -e "  ${Green_font_prefix}${i}.${Font_color_suffix}  "
        echo $json | jq -r '.opencloud['${i}'].name'
    done
    read -e -p "请选择你的服务器系统（编号）:" b
        image=`echo $json | jq -r '.opencloud['${b}'].id'`
}

#创建机器
create_do() {
    clear
    read -p " 请输入机器名字:" name
    clear
    region_do
    clear
    size_do
    clear
    image_do

    clear
    
    echo -e "请确认？ [Y/n]
机器名字：${name}\n服务器位置：${region}\n服务器规格：${size}\n机器系统: ${image}"
        read -e -p "(默认: N 取消):" state
        [[ -z ${state} ]] && state="n"
        if [[ ${state} == [Yy] ]]; then
        clear
echo "`date` 正在进行创建 vm"
            echo "#!/bin/bash
                
sudo service iptables stop 2> /dev/null ; chkconfig iptables off 2> /dev/null ;
sudo sed -i.bak '/^SELINUX=/cSELINUX=disabled' /etc/sysconfig/selinux;
sudo sed -i.bak '/^SELINUX=/cSELINUX=disabled' /etc/selinux/config;
sudo setenforce 0;
echo root:Opencloud@Leige |sudo chpasswd root;
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config;
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config;
sudo service sshd restart;" > ${file_path}/userdata
            
             json=`curl -s -X POST \
             -H "Content-Type: application/json" \
             -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
             -d '{
                "name":"'${name}'",
                "region":"'${region}'",
                "size":"'${size}'",
                "image":"'${image}'",
                "backups":"false",
                "ipv6":"true",
                "user_data":"'"$(cat ${file_path}/userdata)"'"
             }' \
             https://api.digitalocean.com/v2/droplets`
            rm -rf ${file_path}/userdata
           var1=`echo $json | jq -r '.droplet.id'`
           echo ""
           if [[ $var1 == null ]];
           then
               echo $json
               echo "创建失败"
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
        echo -e "IP地址为：${ipv4}\n用户名：root\n密码：Opencloud@Leige\n密码为固定密码，请立即修改！"
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
    echo "`date` 正在进行查询 ${api_name} 已创建的机器" && echo
    echo API名称：${api_name}
    i=-1
    while ((i < ("${total}" - "1" )))
    do
        ((i++))
        echo "机器ID：`echo  $json | jq '.droplets['${i}'].id'`——————机器名字：`echo  $json | jq '.droplets['${i}'].name'`——————机器IP：`echo  $json | jq '.droplets['${i}'].networks.v4[0].ip_address'`"
        
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
    do_loop_script
}

#do菜单
digitalocean_menu() {
  clear
  echo && echo -e "Digitalocean 云服务开机脚本${Red_font_prefix} 开源免费 无加密代码${Font_color_suffix} ${Green_font_prefix}from @openccloud${Font_color_suffix}
项目地址：${Red_font_prefix}https://github.com/LG-leige/open_cloud${Font_color_suffix}
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
    Check_liveness_do
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
    bash <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/opencloud.sh)
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
    echo "已绑定的api："
    ls ${file_path}/do
}

#do检查账号是否存存活
Check_liveness_do(){
    check_api_do
    read -p "你需要查询的api名称:" api_name
    DIGITALOCEAN_TOKEN=`cat ${file_path}/do/${api_name}`
        
    json=`curl -s -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" "https://api.digitalocean.com/v2/account"`
    var1=`echo $json | jq -r '.account.status'`
    
    if [[ ${var1} == "active" ]];then
        create_do
    else
        echo -e  "检测到该API存在问题，无法创建服务器！（2秒后返回）"
        sleep 2s
        digitalocean_menu
    fi
}

#创建doapi
create_api_do(){
    check_api_do
    
    read -e -p "请为这个api添加一个备注：" api_name
    read -e -p "输入api：" api_key
    if test -f "${file_path}/do/${api_name}"; then
        echo "该备注已经存在，请更换其他名字，或者删除原来api"
    else
        echo "${api_key}" > ${file_path}/do/${api_name}
        echo "添加成功！"
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
digitalocean_menu