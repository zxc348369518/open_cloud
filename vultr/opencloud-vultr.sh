#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"
file_path="/root/.opencloud/vultr"
#vultr循环脚本
vultr_loop_script(){
echo -e "
 ${Green_font_prefix}98.${Font_color_suffix} 返回vultr菜单
 ${Green_font_prefix}99.${Font_color_suffix} 退出脚本"  &&
 

read -p " 请输入数字 :" num
  case "$num" in
    98)
    vultr_menu
    ;;
    99)
    exit 1
    ;;
  *)
    clear
    echo -e "${Error}:请输入正确数字 [0-99]（2秒后返回）"
    sleep 2s
    vultr_menu
    ;;
  esac
}

#vultr菜单
vultr_menu() {
    clear
  echo -e "vultr 云服务开机脚本${Red_font_prefix} 开源免费 无加密代码${Font_color_suffix} ${Green_font_prefix}from @openccloud${Font_color_suffix}
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
    Information_user_vultr
    ;;
    2)
    create_vultr
    ;;
    3)
    del_vultr
    ;;
    4)
    clear
    echo "`date` 正在进行vultr查询已保存的api"
    echo
    check_api_vultr
    vultr_loop_script
    ;;
    5)
    create_api_vultr
    ;;
    6)
    del_api_vultr
    ;;
    0)
    exit 1
    ;;
  *)
    clear
    echo -e "${Error}:请输入正确数字 [0-99]（2秒后返回）"
    sleep 2s
    vultr_menu
    ;;
  esac
}

#vultr一键测活
Information_user_vultr() {
    
    clear
    echo "`date` 正在进行vultr测活"
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
    
    json=`curl -4 "https://api.vultr.com/v2/account" \
  -X GET \
  -H "Authorization: Bearer ${VULTR_API_KEY}"`
    clear
    echo "`date` 正在进行vultr测活
    
API名称：${api_name}
电子邮箱：`echo $json | jq -r '.email'`
账号余额：`echo $json | jq -r '.active_promotions[0].credit_remaining'`
Ps：账号正常则返回余额，不正常就返回其他"
    
    vultr_loop_script
}

#查询已保存vultr api
check_api_vultr(){
    echo "已绑定的api："
    ls ${file_path}/account
}

#创建vultr机器
create_vultr() {
    clear
    echo "`date` 正在进行vultr创建vm操作"
    echo
    read -p " 请输入机器名字:" name
    
    clear
    echo "`date` 正在进行vultr创建vm操作"
    echo
    region_vultr
    
    clear
    echo "`date` 正在进行vultr创建vm操作"
    echo
    image_vultr
    
    clear
    echo "`date` 正在进行vultr创建vm操作"
    echo
    size_vultr
    
    clear
    echo "`date` 正在进行vultr创建vm操作"
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
    
    VULTR_API_KEY=`cat ${file_path}/account/${api_name}/VULTR_API_KEY`
    
    clear
    echo "`date` 正在进行vultr创建vm操作
    
使用账号：${api_name}
机器备注：${name}
服务器位置：${region}
服务器规格：${size}
机器系统: ${image}"
        read -e -p "请确认开机信息？(默认: N 取消):" state
        [[ -z ${state} ]] && state="n"
        if [[ ${state} == [Yy] ]]; then
        clear
    
    json=`curl -4 "https://api.vultr.com/v2/instances" \
  -X POST \
  -H "Authorization: Bearer ${VULTR_API_KEY}" \
  -H "Content-Type: application/json" \
  --data '{
    "region" : "'${region}'",
    "plan" : "'${size}'",
    "os_id" : '${image}',
    "user_data" : "IyEvYmluL2Jhc2gKICAgICAgICAgICAgICAgIApzdWRvIHNlcnZpY2UgaXB0YWJsZXMgc3RvcCAyPiAvZGV2L251bGwgOyBjaGtjb25maWcgaXB0YWJsZXMgb2ZmIDI+IC9kZXYvbnVsbCA7CnN1ZG8gc2VkIC1pLmJhayAnL15TRUxJTlVYPS9jU0VMSU5VWD1kaXNhYmxlZCcgL2V0Yy9zeXNjb25maWcvc2VsaW51eDsKc3VkbyBzZWQgLWkuYmFrICcvXlNFTElOVVg9L2NTRUxJTlVYPWRpc2FibGVkJyAvZXRjL3NlbGludXgvY29uZmlnOwpzdWRvIHNldGVuZm9yY2UgMDsKZWNobyByb290Ok9wZW5jbG91ZEBMZWlnZSB8c3VkbyBjaHBhc3N3ZCByb290OwpzdWRvIHNlZCAtaSAncy9eI1w/UGVybWl0Um9vdExvZ2luLiovUGVybWl0Um9vdExvZ2luIHllcy9nJyAvZXRjL3NzaC9zc2hkX2NvbmZpZzsKc3VkbyBzZWQgLWkgJ3MvXiNcP1Bhc3N3b3JkQXV0aGVudGljYXRpb24uKi9QYXNzd29yZEF1dGhlbnRpY2F0aW9uIHllcy9nJyAvZXRjL3NzaC9zc2hkX2NvbmZpZzsKc3VkbyBzZXJ2aWNlIHNzaGQgcmVzdGFydDs=",
    "hostname": "'${name}'",
    "enable_ipv6" : true
  }'`
    
    id=`echo ${json} | jq -r '.instance.id'`
    
    fi
    clear

    if [[ $id == null ]];
    then
        echo $json
        echo "创建失败，请把以上的错误代码发送给 @LeiGe_233 可帮您更新提示"
    else
        curl -4 "https://api.vultr.com/v2/instances/${id}" \
        -X GET \
        -H "Authorization: Bearer ${VULTR_API_KEY}"
        ipv4=`echo ${json} | jq -r '.instance.gateway_v4'`
    fi
        mkdir ${file_path}/account/${api_name}/vm
        mkdir ${file_path}/account/${api_name}/vm/${name}
        echo ${id} > ${file_path}/account/${api_name}/vm/${name}/id
        echo ${ipv4} > ${file_path}/dvultro/account/${api_name}/vm/${name}/ipv4
        
        echo -e "`date` vultr创建vm完成！
    
使用账号：${api_name}
机器备注：${name}
服务器位置：${region}
服务器规格：${size}
机器系统: ${image}

IP地址为：${ipv4}
用户名：root
密码：Opencloud@Leige
密码为固定密码，请立即修改！"
    vultr_loop_script
}

#删除vultr机器
del_vultr() {
    
    clear
    echo "`date` 正在进行vultr删除vm操作"
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
    
    VULTR_API_KEY=`cat ${file_path}/${api_name}/VULTR_API_KEY`
    
    clear
    echo "`date` 正在进行vultr删除vm操作"
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
    echo "`date` 正在进行vultr删除vm操作"
    echo
    
    echo "查询到机器ID为：${id}，IP为：${ip}"
    
    read -e -p "是否需要删除这台机器(默认: N 取消)：" info
    [[ -z ${info} ]] && info="n"
    if [[ ${info} == [Yy] ]]; then
        clear
        echo "`date` 正在进行vultr删除vm操作，删除ID为：${id}，IP为：${ip}的VM"
        echo
        sleep 2s
        curl -4 "https://api.vultr.com/v2/instances/${id}" \
        -X DELETE \
        -H "Authorization: Bearer ${VULTR_API_KEY}"
        rm -rf ${file_path}/account/${api_name}/vm/${vm_name}
        echo && echo "删除成功"
    fi
    vultr_loop_script
}

#vultr服务器位置
region_vultr(){
    json=`cat <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/vultr/region/region)`
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
        
    clear
    echo "`date` 正在进行vultr 创建vm"
    echo    
    json=`cat <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/vultr/region/${region})`
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

#vultr服务器镜像
image_vultr(){
    json=`cat <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/vultr/image/image)`
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
}

#vultr服务器大小
size_vultr(){
    json=`cat <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/vultr/size/size)`
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
    
    clear
    echo "`date` 正在进行vultr 创建vm"
    echo
    json=`cat <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/vultr/size/${size})`
    o=`echo $json| jq ".opencloud | length"`
    
    i=-1
    while ((i < ("${o}" - "1" )))
    do
        ((i++))
        echo -n -e "  ${Green_font_prefix}${i}.${Font_color_suffix}  "
        echo $json | jq -r '.opencloud['${i}'].name'
    done
    read -e -p "请选择你的服务器位置（编号）:" b
        size=`echo $json | jq -r '.opencloud['${b}'].id'`
}

#初始化
initialization(){
    mkdir -p ${file_path}
    mkdir -p ${file_path}/account
    mkdir -p ${file_path}/account/default（勿删）
    vultr_menu
}

#创建vultr api
create_api_vultr(){
    clear
    echo "`date` 正在进行vultr创建api操作"
    echo
    check_api_vultr
    
    echo
    read -e -p "请新的api添加一个备注：" api_name
    read -e -p "输入api：" api_key
	
	if [ ! -d "${file_path}/account/${api_name}" ]; then
			mkdir ${file_path}/account/${api_name}
			echo "${api_key}" > ${file_path}/account/${api_name}/VULTR_API_KEY
			echo "添加成功！"
		else
			echo "该备注已经存在，请更换其他名字，或者删除原来api"
    fi
    
    vultr_loop_script
}

#删除vultr api
del_api_vultr(){
    clear
    echo "`date` 正在进行vultr删除api操作"
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
    vultr_loop_script
}
initialization