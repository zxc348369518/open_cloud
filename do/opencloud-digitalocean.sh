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

#do测活
Information_user_do() {
    clear
    echo "`date` 正在进行Digitalocean测活api操作"
    echo
    cd ${file_path}/do/account
    o=`ls -l|grep -c "^d"`
    a=(`ls ${file_path}/do/account`)
    i=-1
    echo "已保存的api"
    while ((i < ("${o}" - "1" )))
    do
        ((i++))
        echo -n -e "  ${Green_font_prefix}${i}.${Font_color_suffix}  "
        echo ${a[i]}
    done
    
    read -e -p "是否需要测活那个API？(编号)：" num
    
    clear
    echo "`date` 正在进行Digitalocean测活api操作"
    echo
    
    DIGITALOCEAN_TOKEN=`cat ${file_path}/do/${a[num]}/token`

        json=`curl -s -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" "https://api.digitalocean.com/v2/account"`
        json2=`curl -s -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" "https://api.digitalocean.com/v2/customers/my/balance"`
        var1=`echo $json | jq -r '.account.droplet_limit'`
        var2=`echo $json | jq -r '.account.email'`
        var3=`echo $json | jq -r '.account.status'`
        var4=`echo $json2 | jq -r '.month_to_date_balance'`
        
        echo -e  "账号信息如下：
API名称：${var0}
电子邮箱：${var2}
账号配额：${var1}
账号余额：${var4}
账号状态：${var3}" 

    do_loop_script
}

#do服务器位置
region_do(){
    json=`cat <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/do/data/region)`
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
    json=`cat <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/do/data/size)`
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
    
    clear
    echo "`date` 正在进行Digitalocean创建vm操作"
    echo
    
    json=`cat <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/do/data/size-${size})`
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
    json=`cat <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/do/data/image)`
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
    echo "`date` 正在进行Digitalocean创建vm操作"
    echo
    read -p " 请输入机器名字:" name
    clear
    echo "`date` 正在进行Digitalocean创建vm操作"
    echo
    region_do
    clear
    echo "`date` 正在进行Digitalocean创建vm操作"
    echo
    size_do
    clear
    echo "`date` 正在进行Digitalocean创建vm操作"
    echo
    image_do
    clear
    echo "`date` 正在进行Digitalocean创建vm操作"
    echo
    cd ${file_path}/do/account
    o=`ls -l|grep -c "^d"`
    a=(`ls ${file_path}/do/account`)
    i=-1
    echo "已保存的api"
    while ((i < ("${o}" - "1" )))
    do
        ((i++))
        echo -n -e "  ${Green_font_prefix}${i}.${Font_color_suffix}  "
        echo ${a[i]}
    done

    read -e -p "是否需要使用那个API？(编号)：" num
    
    clear
    echo -e "`date` 正在进行Digitalocean创建vm操作
    
使用账号：${a[num]}
机器备注：${name}
服务器位置：${region}
服务器规格：${size}
机器系统: ${image}"
        read -e -p "请确认开机信息？(默认: N 取消):" state
        [[ -z ${state} ]] && state="n"
        if [[ ${state} == [Yy] ]]; then
        clear
echo "`date` 正在进行Digitalocean创建vm操作"
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
        mkdir ${file_path}/do/account/${a[num]}/${name}
        echo ${var1} > ${file_path}/do/account/${a[num]}/${name}/id
        echo ${ipv4} > ${file_path}/do/account/${a[num]}/${name}/ip
        clear
        echo -e "vm创建成功！
使用账号：${a[num]}
机器备注：${name}
服务器位置：${region}
服务器规格：${size}
机器系统: ${image}

IP地址为：${ipv4}
用户名：root
密码：Opencloud@Leige
密码为固定密码，请立即修改！"
    fi
    do_loop_script
}

#删除机器
del_do() {
    clear
    echo "`date` 正在进行Digitalocean删除vm操作"
    echo
    cd ${file_path}/do/account
    o=`ls -l|grep -c "^d"`
    a=(`ls ${file_path}/do/account`)
    i=-1
    echo "已保存的api"
    while ((i < ("${o}" - "1" )))
    do
        ((i++))
        echo -n -e "  ${Green_font_prefix}${i}.${Font_color_suffix}  "
        echo ${a[i]}
    done
    
    read -e -p "是否需要删除那个API？(编号)：" num
    
    DIGITALOCEAN_TOKEN=`cat ${file_path}/do/${a[num]}/token`
    
    clear
    echo "`date` 正在进行Digitalocean删除vm操作"
    echo
    
    cd ${file_path}/do/account/${a[num]}/vm
    o=`ls -l|grep -c "^d"`
    a=(`ls ${file_path}/do/account/${a[num]}/vm`)
    i=-1
    echo "${a[num]}名下已创建的机器"
    while ((i < ("${o}" - "1" )))
    do
        ((i++))
        echo -n -e "  ${Green_font_prefix}${i}.${Font_color_suffix}  "
        echo ${a[i]}
    done
    
    read -e -p "是否需要删除那台备注的机器(编号)：" num
    
    qq=`pwd`
    ip=`cat ${qq}/${a[num]}/ip`
    id=`cat ${qq}/${a[num]}/id`
    
    clear
    echo "`date` 正在进行Digitalocean删除vm操作"
    echo
    
    echo "查询到机器ID为：${id}，IP为：${ip}"
    
    read -e -p "是否需要删除这台机器(默认: N 取消)：" info
    [[ -z ${info} ]] && info="n"
    if [[ ${info} == [Yy] ]]; then
        clear
        echo "`date` 正在进行Digitalocean删除vm操作，删除ID为：${id}，IP为：${ip}的VM"
        echo
        sleep 2s
        curl -s -X DELETE \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
        "https://api.digitalocean.com/v2/droplets/${id}"
        rm -rf ${qq}
        echo && echo "删除成功"
    fi
    do_loop_script
}

#do菜单
digitalocean_menu() {
  clear
  echo -e "Digitalocean 云服务开机脚本${Red_font_prefix} 开源免费 无加密代码${Font_color_suffix} ${Green_font_prefix}from @openccloud${Font_color_suffix}
项目地址：${Red_font_prefix}https://github.com/LG-leige/open_cloud${Font_color_suffix}
 ${Green_font_prefix}1.${Font_color_suffix} API测活
 ${Green_font_prefix}2.${Font_color_suffix} 创建机器
 ${Green_font_prefix}3.${Font_color_suffix} 删除机器
————————————————————————————————————————————————————————————————
 ${Green_font_prefix}4.${Font_color_suffix} 查询已保存api
 ${Green_font_prefix}5.${Font_color_suffix} 添加api
 ${Green_font_prefix}6.${Font_color_suffix} 删除api
————————————————————————————————————————————————————————————————
 ${Green_font_prefix}0.${Font_color_suffix} 退出脚本" &&

read -p " 请输入数字 :" num
  case "$num" in
    1)
    Information_user_do
    ;;
    2)
    create_do
    ;;
    3)
    del_do
    ;;
    4)
    clear
    echo "`date` 正在进行Digitalocean查询已保存的api"
    echo
    check_api_do
    do_loop_script
    ;;
    5)
    create_api_do
    ;;
    6)
    del_api_do
    ;;
    0)
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
    echo "已保存的api有："
    ls ${file_path}/do/account
}

#创建doapi
create_api_do(){
    clear
    echo "`date` 正在进行Digitalocean创建api操作"
    echo
    check_api_do
    
    echo
    read -e -p "请新的api添加一个备注：" api_name
    read -e -p "输入api：" api_key
	
	if [ ! -d "${file_path}/do/account/${api_name}" ]; then
			mkdir ${file_path}/do/account/${api_name}
			echo "${api_key}" > ${file_path}/do/account/${api_name}/token
			echo "添加成功！"
		else
			echo "该备注已经存在，请更换其他名字，或者删除原来api"
		fi
    
    do_loop_script
}

#初始化
initialization(){
    mkdir -p ${file_path}/do
    mkdir -p ${file_path}/do/account
    mkdir -p ${file_path}/do/account/default（勿删）
    digitalocean_menu
}

#删除doapi
del_api_do(){
    clear
    echo "`date`正在进行Digitalocean删除api操作"
    echo
    cd ${file_path}/do/account
    o=`ls -l|grep -c "^d"`
    a=(`ls ${file_path}/do/account`)
    i=-1
    echo "已保存的api"
    while ((i < ("${o}" - "1" )))
    do
        ((i++))
        echo -n -e "  ${Green_font_prefix}${i}.${Font_color_suffix}  "
        echo ${a[i]}
    done
    
    echo
    
    read -e -p "是否需要删除那个API？(编号)：" num
    
    read -e -p "是否需要删除备注为 ${a[num]} 的API(默认: N 取消)：" info
    [[ -z ${info} ]] && info="n"
    if [[ ${info} == [Yy] ]]; then
		if [ ! -d "${file_path}/do/account/${api_name}" ]; then
			echo "未在系统中查找到该名称的api"
		else
			rm -rf ${file_path}/do/account/${a[num]}
            echo "删除成功！"
		fi
	
    fi
    do_loop_script
}
initialization