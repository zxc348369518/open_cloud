#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"
Version="3.0"
file_path="/root/.opencloud/do"
bash_name="Digitalocean"

#初始化
initialization(){
    mkdir -p ${file_path}
    mkdir -p ${file_path}/account
    mkdir -p ${file_path}/account/default（勿删）

    if [ ! -f "${file_path}/userdata" ]; then
        echo "#!/bin/bash
                
sudo service iptables stop 2> /dev/null ; chkconfig iptables off 2> /dev/null ;
sudo sed -i.bak '/^SELINUX=/cSELINUX=disabled' /etc/sysconfig/selinux;
sudo sed -i.bak '/^SELINUX=/cSELINUX=disabled' /etc/selinux/config;
sudo setenforce 0;
echo root:Opencloud@Leige |sudo chpasswd root;
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config;
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config;
sudo service sshd restart;" > ${file_path}/userdata
    fi
    menu
}

#菜单
menu() {
  clear
  echo -e "${bash_name} 云服务开机脚本${Red_font_prefix} 开源免费 无加密代码${Font_color_suffix} ${Green_font_prefix}from @openccloud${Font_color_suffix}
项目地址：${Red_font_prefix}https://github.com/LG-leige/open_cloud${Font_color_suffix}
 ${Green_font_prefix}1.${Font_color_suffix} API测活
 ${Green_font_prefix}2.${Font_color_suffix} 创建机器
 ${Green_font_prefix}3.${Font_color_suffix} 删除机器
————————————————————————————————————————————————————————————————
 ${Green_font_prefix}4.${Font_color_suffix} 添加api
 ${Green_font_prefix}5.${Font_color_suffix} 删除api
————————————————————————————————————————————————————————————————
 当前版本：${Version}" &&

read -p " 请输入数字 :" num
  case "$num" in
    1)
    check_account
    ;;
    2)
    create
    ;;
    3)
    delete_vm
    ;;
    4)
    create_api
    ;;
    5)
    delete_api
    ;;
  *)
    clear
    echo -e "${Error}:请输入正确数字 [0-99]（2秒后返回）"
    sleep 2s
    menu
    ;;
  esac
}

#标题
title(){
    echo "`date` 正在进行 ${bash_name} ${title_content}"
    echo
}

#查询已保存api
check_api(){
    echo "已保存的api有："
    if ls -d "${file_path}/account/"*/ &> /dev/null; then
    ls "${file_path}/account/"
    else
        :
    fi
}

#检查vm备注是否存在
check_vm_name(){
    if test -d "${file_path}/account/${api_name}/${vm_name}"; then
        echo "检测到该备注存在，请重新添加（2秒后返回）"
        sleep 2s
        create_vm
    else
        :
    fi
}

#选择API
select_api(){
    echo "已保存的api有："
    
    num_files=$(ls "${file_path}/account" | wc -l)

    for ((i=1; i<=num_files; i++)); do
      file=$(ls "${file_path}/account" | sort | sed -n "${i}p")
      echo "$i. $file"
    done

    echo "请选择操作的API（输入编号）："
    read file_num

    api_name=$(ls "${file_path}/account" | sort | sed -n "${file_num}p")
}

#添加api
create_api(){
    
    clear
    title_content="创建API操作"
    title
    
    check_api
    
    echo
    read -e -p "请新的api添加一个备注：" api_name
    
    if test -d "${file_path}/account/${api_name}"; then
        echo "检测到该备注存在，请重新添加（2秒后返回）"
        sleep 2s
        create_api
    else
        :
    fi

    read -e -p "输入api：" api_key
    
    mkdir ${file_path}/account/${api_name}
	echo "${api_key}" > ${file_path}/account/${api_name}/token
	echo "添加成功！"
	loop_script
}

#删除API
delete_api(){
    clear
    title_content="删除API操作"
    title
    select_api
    
    clear
    title_content="删除VM操作"
    title
    echo
    read -p "是否需要帮你删除备注为 ${api_name} 的API [y/n] " confirm

    if [[ $confirm =~ ^[Yy]$ ]]; then
        rm -rf ${file_path}/account/${api_name}
        echo
        echo "备注为 ${api_name} 的API，删除成功！"
    else
        echo
        echo "用户已取消"
    fi
    loop_script
}

#循环脚本
loop_script(){
    echo
    echo -e "${Green_font_prefix}98.${Font_color_suffix} 返回Digitalocean菜单
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

#测活
check_account(){
    clear
    title_content="检测API操作"
    title
    
    select_api
    
    DIGITALOCEAN_TOKEN=`cat ${file_path}/account/${api_name}/token`
    
    json=`curl -s -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" "https://api.digitalocean.com/v2/account"`
    json2=`curl -s -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" "https://api.digitalocean.com/v2/customers/my/balance"`

    echo
    echo -e  "账号信息如下：
API名称：${api_name}
电子邮箱：`echo $json | jq -r '.account.email'`
账号配额：`echo $json | jq -r '.account.droplet_limit'`
账号余额：`echo $json2 | jq -r '.month_to_date_balance'`
账号状态：`echo $json | jq -r '.account.status'`"

    loop_script
}

#服务器位置
region(){
    json=`cat <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/do/region)`
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

#服务器大小
size(){
    json=`cat <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/do/size)`
    o=`echo $json| jq ".opencloud | length"`
    
    i=-1
    while ((i < ("${o}" - "1" )))
    do
        ((i++))
        echo -n -e "  ${Green_font_prefix}${i}.${Font_color_suffix}  "
        echo $json | jq -r '.opencloud['${i}'].name'
    done
    read -e -p "请选择你的服务器机型（编号）:" b
    size=`echo $json | jq -r '.opencloud['${b}'].id'`

}

#服务器大小
size2(){  
    json=`cat <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/do/size-${size})`
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

#服务器镜像
image(){
    json=`cat <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/do/image)`
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

#vm信息
vm_info(){
    echo -e "使用账号：${api_name}
机器备注：${vm_name}
服务器位置：${region}
服务器规格：${size}
机器系统: ${image}"
}

#提交创建vm
create_vm(){
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
    
    var1=`echo $json | jq -r '.droplet.id'`

    if [[ $var1 == null ]];
    then
        clear
        echo $json
        echo "创建失败"
        loop_script
    else
        mkdir -p ${file_path}/account/${api_name}/vm
        mkdir -p ${file_path}/account/${api_name}/vm/${vm_name}
        echo ${var1} > ${file_path}/account/${api_name}/vm/${vm_name}/id
    fi
}

#创建vm完成返回信息
create_vm_done(){
    echo
    echo -e "使用账号：${api_name}
机器备注：${vm_name}
服务器位置：${region}
服务器规格：${size}
机器系统: ${image}

IP地址为：${ipv4}
用户名：root
密码：Opencloud@Leige
密码为固定密码，请立即修改！"
}

#获取vmip
cheek_ip(){

    json=`curl -s -X GET \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
    "https://api.digitalocean.com/v2/droplets/${var1}"`
    ipv4=`echo $json | jq -r '.droplet.networks.v4[0].ip_address'`
    
    if [[ $ipv4 =~ "null" ]];
    then
        sleep 5s
        cheek_ip
    else
        echo ${ipv4} > ${file_path}/account/${api_name}/vm/${vm_name}/ip
        
        clear
        title_content="创建VM操作"
        title
        create_vm_done
    fi
    do_loop_script
}

#创建vm
create(){
    clear
    title_content="创建VM操作"
    title
    
    select_api
    
    DIGITALOCEAN_TOKEN=`cat ${file_path}/account/${api_name}/token`

    clear
    title_content="创建VM操作"
    title
    read -p " 请输入机器名字:" vm_name
    check_vm_name
    
    clear
    title_content="创建VM操作"
    title
    region
    
    clear
    title_content="创建VM操作"
    title
    image
    
    clear
    title_content="创建VM操作"
    title
    size
    
    clear
    title_content="创建VM操作"
    title
    size2
    
    clear
    title_content="创建VM操作"
    title
    vm_info
    
    echo
    read -e -p "请确认开机信息？(默认: N 取消):" confirm
    
    if [[ $confirm =~ ^[Yy]$ ]]; then
        clear
        title_content="创建VM操作"
        title
        create_vm
        
        clear
        title_content="创建VM操作"
        title
        cheek_ip
    else
        echo
        echo "用户已取消"
        loop_script
    fi
}

#选择vm
select_vm(){

    num_files=$(ls "${file_path}/account/${api_name}/vm" | wc -l)

    for ((i=1; i<=num_files; i++)); do
      file=$(ls "${file_path}/account/${api_name}/vm" | sort | sed -n "${i}p")
      echo "$i. $file"
    done


    echo "请选择操作的API（输入编号）："
    read file_num

    vm_name=$(ls "${file_path}/account/${api_name}/vm" | sort | sed -n "${file_num}p")
}

#删除vm
delete_vm(){
    clear
    title_content="删除VM操作"
    title
    select_api
    
    clear
    title_content="删除VM操作"
    title
    select_vm
    
    clear
    title_content="删除VM操作"
    title
    echo
    read -p "是否需要帮你删除备注为 ${api_name} 的API中的 ${vm_name} [y/n] " confirm
    
    id=`cat ${file_path}/account/${api_name}/vm/${vm_name}/id`

    if [[ $confirm =~ ^[Yy]$ ]]; then
        curl -s -X DELETE \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
        "https://api.digitalocean.com/v2/droplets/${id}"
        rm -rf ${file_path}/account/${api_name}/vm/${vm_name}
        echo
        echo "备注为 ${api_name} 的API，删除成功！"
    else
        echo
        echo "用户已取消"
    fi
    do_loop_script
}

initialization