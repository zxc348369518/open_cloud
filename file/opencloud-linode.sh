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
  echo && echo -e "Linode 云服务开机脚本${Red_font_prefix} 开源免费 无加密代码${Font_color_suffix} ${Green_font_prefix}from @openccloud${Font_color_suffix}
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
    Information_user_linode
    ;;
    2)
    Information_vps_linode
    ;;
    3)
    Check_liveness_linode
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
    bash <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/opencloud.sh)
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
    echo "已绑定的api："
    ls ${file_path}/linode
}

#创建linode api
create_api_linode(){
    check_api_linode
    
    read -e -p "请为这个api添加一个备注：" api_name
    read -e -p "输入api：" api_key
    
    if test -f "${file_path}/linode/api_name"; then
        echo "该备注已经存在，请更换其他名字，或者删除原来api"
    else
        echo "${api_key}" > ${file_path}/linode/${api_name}
        echo "添加成功！"
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
    echo $json
    total=`echo $json | jq -r '.results'`
    echo "查询结果为空代表 账号下没有任何机器 或者 账号已经失效了"
    i=-1
    while ((i < ("${total}" - "1" )))
    do
        ((i++))
        echo -e "机器ID：`echo $json | jq '.data['${i}'].id'`————IP：`$json | jq '.data['${i}'].ipv4'`\n"
    done 
    linode_loop_script
}

#linode检查账号是否存存活
Check_liveness_linode(){
    check_api_linode
    read -p "你需要创建机器的api名称:" api_name
    TOKEN=`cat ${file_path}/linode/${api_name}`
    
    json=`curl -s -H "Authorization: Bearer $TOKEN" \
    https://api.linode.com/v4/account`
    
    var1=`echo $json | jq -r '.email'`
    var2=`echo $json | jq -r '.active_promotions[0].credit_remaining'`
    
    if [[ ${var2} == "null" ]];then
        create_linode
    else
        echo -e  "检测到该API存在问题，无法创建服务器！（2秒后返回）"
        sleep 2s
        linode_menu
    fi
}

#linode一键测活
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
            echo -e  "API名称：${var0}————电子邮箱：${var1}————账号状态：Disabled" 
        else
            echo -e  "API名称：${var0}————电子邮箱：${var1}————账号余额：${var2}————账号状态：Enabled" 
        fi
        
    done
    
    linode_loop_script
}

#linnode服务器位置
region_linode(){
    json=`cat <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/linode/region)`
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

#linode服务器镜像
image_linode(){
    json=`cat <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/linode/image)`
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

#linode服务器大小
size_linode(){
    json=`cat <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/linode/size)`
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

#创建linode机器
create_linode() {
    
    region_linode
    image_linode
    size_linode
    
    json=`curl -s -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -X POST -d '{
      "swap_size": 512,
      "image": "'${image}'",
      "root_pass": "Opencloud@Leige",
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
        echo -e "IP地址为：${ipv4}\n开机密码统一为：Opencloud@Leige\n密码为固定密码，请立即修改！"
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
linode_menu