#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"
file_path="/root/.opencloud/linode"
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
  echo -e "Linode 云服务开机脚本${Red_font_prefix} 开源免费 无加密代码${Font_color_suffix} ${Green_font_prefix}from @openccloud${Font_color_suffix}
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
    Information_user_linode
    ;;
    2)
    create_linode
    ;;
    3)
    del_linode
    ;;
    4)
    clear
    echo "`date` 正在进行Linode查询已保存的api"
    echo
    check_api_linode
    linode_loop_script
    ;;
    5)
    create_api_linode
    ;;
    6)
    del_api_linode
    ;;
    0)
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

#linode一键测活
Information_user_linode() {
    
    cd ${file_path}
    o=`ls ${file_path}|wc -l`
    i=-1
    while ((i < ("${o}" - "1" )))
    do
        ((i++))
        array=(*)
        var0=`echo ${array[${i}]}`
        TOKEN=`cat ${file_path}/${var0}`
        
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

#查询已保存linode api
check_api_linode(){
    echo "已绑定的api："
    ls ${file_path}/account
}

#创建linode机器
create_linode() {
    clear
    echo "`date` 正在进行Linode创建vm操作"
    echo
    read -p " 请输入机器名字:" name
    
    clear
    echo "`date` 正在进行Linode创建vm操作"
    echo
    region_linode
    
    clear
    echo "`date` 正在进行Linode创建vm操作"
    echo
    image_linode
    
    clear
    echo "`date` 正在进行Linode创建vm操作"
    echo
    size_linode
    
    clear
    echo "`date` 正在进行Linode创建vm操作"
    echo
    cd ${file_path}/account
    o=`ls -l|grep -c "^d"`
    a=(`ls ${file_path}/account`)
    i=-1
    echo "已保存的api"
    while ((i < ("${o}" - "1" )))
    do
        ((i++))
        echo -n -e "  ${Green_font_prefix}${i}.${Font_color_suffix}  "
        echo ${a[i]}
    done

    read -e -p "是否需要使用那个API？(编号)：" num
    
    api_name=${a[num]}
    
    TOKEN=`cat ${file_path}/account/${api_name}/token`
    
    clear
    echo "`date` 正在进行Linode创建vm操作
    
使用账号：${api_name}
机器备注：${name}
服务器位置：${region}
服务器规格：${size}
机器系统: ${image}"
        read -e -p "请确认开机信息？(默认: N 取消):" state
        [[ -z ${state} ]] && state="n"
        if [[ ${state} == [Yy] ]]; then
        clear
    
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
    https://api.linode.com/v4/c/instances`
    
    ipv4=`echo ${json} | jq -r '.ipv4'`
    ipv6=`echo ${json} | jq -r '.ipv6'`
    id=`echo ${json} | jq -r '.id'`
    fi
    clear

    if [[ $ipv4 =~ "null" ]];
    then
        echo $json
        echo "创建失败，请把以上的错误代码发送给 @LeiGe_233 可帮您更新提示"
    else
        mkdir ${file_path}/account/${api_name}/vm
        mkdir ${file_path}/account/${api_name}}/vm/${name}
        echo ${id} > ${file_path}/account/${api_name}//vm/${name}/id
        echo ${ipv4} > ${file_path}/dlinodeo/account/${api_name}/vm/${name}/ipv4
        echo ${ipv6} > ${file_path}/dlinodeo/account/${api_name}/vm/${name}/ipv6
        
        echo -e "`date` Linode创建vm完成！
    
使用账号：${api_name}
机器备注：${name}
服务器位置：${region}
服务器规格：${size}
机器系统: ${image}

IP地址为：${ipv4}
用户名：root
密码：Opencloud@Leige
密码为固定密码，请立即修改！"
    fi
    linode_loop_script
}

#删除linode机器
del_linode() {
    
    clear
    echo "`date` 正在进行Linode删除vm操作"
    echo
    cd ${file_path}/account
    o=`ls -l|grep -c "^d"`
    a=(`ls ${file_path}/account`)
    i=-1
    echo "已保存的api"
    while ((i < ("${o}" - "1" )))
    do
        ((i++))
        echo -n -e "  ${Green_font_prefix}${i}.${Font_color_suffix}  "
        echo ${a[i]}
    done
    
    read -e -p "是否需要删除那个API？(编号)：" num
    
    api_name=${a[num]}
    
    token=`cat ${file_path}/${api_name}/token`
    
    clear
    echo "`date` 正在进行Linode删除vm操作"
    echo
    
    cd ${file_path}/account/${api_name}/vm
    o=`ls -l|grep -c "^d"`
    a=(`ls ${file_path}/account/${api_name}/vm`)
    i=-1
    echo "${api_name}名下已创建的机器"
    while ((i < ("${o}" - "1" )))
    do
        ((i++))
        echo -n -e "  ${Green_font_prefix}${i}.${Font_color_suffix}  "
        echo ${a[i]}
    done
    
    read -e -p "是否需要删除那台备注的机器(编号)：" num
    
    vm_name=${a[num]}
    
    ip=`cat ${file_path}/account/${api_name}/vm/${vm_name}/ipv4`
    id=`cat ${file_path}/account/${api_name}/vm/${vm_name}/id`
    
    clear
    echo "`date` 正在进行Linode删除vm操作"
    echo
    
    echo "查询到机器ID为：${id}，IP为：${ip}"
    
    read -e -p "是否需要删除这台机器(默认: N 取消)：" info
    [[ -z ${info} ]] && info="n"
    if [[ ${info} == [Yy] ]]; then
        clear
        echo "`date` 正在进行Linode删除vm操作，删除ID为：${id}，IP为：${ip}的VM"
        echo
        sleep 2s
        curl -s -H "Authorization: Bearer $token" \
            -X DELETE \
            https://api.linode.com/v4/linode/instances/${id}
        rm -rf ${file_path}/account/${api_name}/vm/${vm_name}
        echo && echo "删除成功"
    fi
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
    read -e -p "请选择你的服务器系统类型（编号）:" b
    image=`echo $json | jq -r '.opencloud['${b}'].id'`
    
    clear
    echo "`date` 正在进行Linode创建vm操作"
    echo
    
    json=`cat <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/linode/image-${image})`
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

#初始化
initialization(){
    mkdir -p ${file_path}
    mkdir -p ${file_path}/account
    mkdir -p ${file_path}/account/default（勿删）
    linode_menu
}

#创建linode api
create_api_linode(){
    clear
    echo "`date` 正在进行Linode创建api操作"
    echo
    check_api_linode
    
    echo
    read -e -p "请新的api添加一个备注：" api_name
    read -e -p "输入api：" api_key
	
	if [ ! -d "${file_path}/account/${api_name}" ]; then
			mkdir ${file_path}/account/${api_name}
			echo "${api_key}" > ${file_path}/account/${api_name}/token
			echo "添加成功！"
		else
			echo "该备注已经存在，请更换其他名字，或者删除原来api"
    fi
    
    linode_loop_script
}

#删除linode api
del_api_linode(){
    clear
    echo "`date` 正在进行Linode删除api操作"
    echo
    cd ${file_path}/account
    o=`ls -l|grep -c "^d"`
    a=(`ls ${file_path}/account`)
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
    
    api_name=${a[num]}
    
    read -e -p "是否需要删除备注为 ${api_name} 的API(默认: N 取消)：" info
    [[ -z ${info} ]] && info="n"
    if [[ ${info} == [Yy] ]]; then
		if [ ! -d "${file_path}/account/${api_name}" ]; then
			echo "未在系统中查找到该名称的api"
		else
			rm -rf ${file_path}/account/${api_name}
            echo "删除成功！"
		fi
	
    fi
    linode_loop_script
}
initialization