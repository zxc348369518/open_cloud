#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"
file_path="/root/.opencloud/aws/Lightsail"

#删除实例
del_Lightsail_aws(){
    clear
    echo "`date` 正在进行AWS Lightsail 删除vm"
    echo
    region_Lightsail_aws
    
    clear
    echo "`date` 正在进行AWS Lightsail 删除vm"
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
    read -e -p "是否需要使用那个API？(编号)：" num
    
    api_name=${a[num]}
    
    key_id=`cat ${file_path}/account/${api_name}/key_id`
    access_key=`cat ${file_path}/account/${api_name}/access_key`
    
    export AWS_ACCESS_KEY_ID=${key_id}
    export AWS_SECRET_ACCESS_KEY=${access_key}
    export AWS_DEFAULT_REGION=${region}
    export AWS_DEFAULT_OUTPUT=json

    clear
    echo "`date` 正在进行AWS Lightsail 删除vm"
    echo
    
    cd ${file_path}/account/${api_name}/vm/${region}/vm_info
    o=`ls -l|grep -c "^d"`
    a=(`ls ${file_path}/account/${api_name}/vm/${region}/vm_info`)
    i=-1
    echo "已保存的api"
    while ((i < ("${o}" - "1" )))
    do
        ((i++))
        echo -n -e "  ${Green_font_prefix}${i}.${Font_color_suffix}  "
        echo ${a[i]}
    done
    echo
    read -e -p "是否需要修改那台机器？(编号)：" num
    
    
    vm_name=${a[num]}
    

    json=`aws lightsail delete-instance \
    --instance-name ${vm_name}`
    status=`echo $json | jq -r '.operations[0].operationType'`
    sleep 20s
    if [[ $status == "DeleteInstance" ]]; then
        rm -rf ${file_path}/account/${api_name}/vm/${region}/vm_info/${vm_name}/
        clear
        echo "`date` 正在进行AWS Lightsail 删除vm"
        echo
        echo "删除成功"
    else
        echo $status
        echo ""
        echo "终止失败，建议翻译上面一段话"
        exit
    fi
}

#更换IP
change_ip_aws_Lightsail(){
    
    clear
    echo "`date` 正在进行AWS Lightsail 更换IP"
    echo
    region_Lightsail_aws
    
    clear
    echo "`date` 正在进行AWS Lightsail 更换IP"
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
    read -e -p "是否需要使用那个API？(编号)：" num
    
    api_name=${a[num]}
    
    key_id=`cat ${file_path}/account/${api_name}/key_id`
    access_key=`cat ${file_path}/account/${api_name}/access_key`
    
    export AWS_ACCESS_KEY_ID=${key_id}
    export AWS_SECRET_ACCESS_KEY=${access_key}
    export AWS_DEFAULT_REGION=${region}
    export AWS_DEFAULT_OUTPUT=json

    clear
    echo "`date` 正在进行AWS Lightsail 更换IP"
    echo
    
    cd ${file_path}/account/${api_name}/vm/${region}/vm_info
    o=`ls -l|grep -c "^d"`
    a=(`ls ${file_path}/account/${api_name}/vm/${region}/vm_info`)
    i=-1
    echo "已保存的api"
    while ((i < ("${o}" - "1" )))
    do
        ((i++))
        echo -n -e "  ${Green_font_prefix}${i}.${Font_color_suffix}  "
        echo ${a[i]}
    done
    echo
    read -e -p "是否需要修改那台机器？(编号)：" num
    
    
    vm_name=${a[num]}
    
    
    clear
    echo "`date` 正在进行AWS Lightsail 更换IP"
    echo
    json=`aws Lightsail stop-instances \
    --instance-name ${vm_name}`
    status=`echo $json | jq -r '.operations[0].operationType'`
    if [[ $status == "StopInstance" ]]; then
        sleep 30s
    else
        echo $status
        echo ""
        echo "更换失败，建议翻译上面一段话"
        exit
    fi
    
    clear
    echo "`date` 正在进行AWS Lightsail 更换IP"
    echo
    json=`aws lightsail start-instance \
    --instance-name ${vm_name}`
    
    sleep 15s

    json=`aws lightsail get-instance \
    --instance-name ${vm_name}`
    ipv4=`echo ${json} | jq -r '.instance.publicIpAddress'`
    ipv6=`echo ${json} | jq -r '.instance.ipv6Addresses[0]'`
    echo "`date` 正在进行AWS Lightsail VM信息"
    echo
    echo "旧IP：`${file_path}/account/${api_name}/vm/${region}/vm_info/${remark}/ipv4`
新IP：${ipv4}"
    rm -rf ${file_path}/account/${api_name}/vm/${region}/${remark}/vm_info/ipv4
    echo "${ipv4}" >  ${file_path}/account/${api_name}/vm/${region}/vm_info/${remark}/ipv4
}

#已保存实例的备注
check_remark_aws_Lightsail(){
    echo "该API下保存的实例备注："
    ls ${file_path}/account/${api_name}/vm/${region}/vm_info
}

#AWS创建Lightsail
create_Lightsail_AWS(){
    clear
    echo "`date` 正在进行AWS Lightsail 创建vm"
    echo
    region_Lightsail_aws
    
    clear
    echo "`date` 正在进行AWS Lightsail 创建vm"
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
    read -e -p "是否需要使用那个API？(编号)：" num
    
    api_name=${a[num]}
    
    key_id=`cat ${file_path}/account/${api_name}/key_id`
    access_key=`cat ${file_path}/account/${api_name}/access_key`
    
    export AWS_ACCESS_KEY_ID=${key_id}
    export AWS_SECRET_ACCESS_KEY=${access_key}
    export AWS_DEFAULT_REGION=${region}
    export AWS_DEFAULT_OUTPUT=json
    
    clear
    echo "`date` 正在进行AWS Lightsail 创建vm"
    echo
    size_Lightsail_aws
    
    clear
    echo "`date` 正在进行AWS Lightsail 创建vm"
    echo
    image_aws_Lightsail
    
    clear
    echo "`date` 正在进行AWS Lightsail 创建vm"
    echo
    check_remark_aws_Lightsail
    
    clear
    echo "`date` 正在进行AWS Lightsail 创建vm"
    echo
    read -e -p "请给这台服务器一个备注（尽量不要重复，数据会替换的）:" remark
    
    clear
    echo "`date` 正在进行AWS Lightsail 创建vm"
    echo
    read -e -p "需要给这台服务器设置多少硬盘呢（填写数字，默认8G）:" vda
    [[ -z ${vda} ]] && vda="8"
    
    clear
    echo "`date` 正在进行AWS Lightsail 创建vm"
    echo
    read -e -p "你创建的系统是否为windows:（默认 N）" win
    [[ -z ${win} ]] && win="n"
    
    clear
    echo "`date` 正在进行AWS Lightsail 创建vm
        
使用账号：${api_name}
机器备注：${remark}
服务器位置：${region}
服务器规格：${size}
机器系统: ${image}
机器硬盘：${vda} GB"
        read -e -p "请确认开机信息？(默认: N 取消):" state
        [[ -z ${state} ]] && state="n"
        if [[ ${state} == [Yy] ]]; then

    clear
    echo "`date` 正在进行AWS Lightsail 创建vm"
    echo
    json=`aws lightsail create-instances \
--instance-names ${remark} \
--availability-zone ${region}-a \
--blueprint-id ${image} \
--bundle-id ${size} \
--user-data """#!/bin/sh
sudo service iptables stop 2> /dev/null ; chkconfig iptables off 2> /dev/null ;
sudo sed -i.bak '/^SELINUX=/cSELINUX=disabled' /etc/sysconfig/selinux;
sudo sed -i.bak '/^SELINUX=/cSELINUX=disabled' /etc/selinux/config;
sudo setenforce 0;
echo root:Opencloud@Leige |sudo chpasswd root;
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config;
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config;
sudo service sshd restart;
"""`

    InstanceId=`echo $json | jq -r '.operations[0].id'`
    
    if [[ $InstanceId != null ]]; then
        mkdir ${file_path}/account/${api_name}/vm
        mkdir ${file_path}/account/${api_name}/vm/${region}
        mkdir ${file_path}/account/${api_name}/vm/${region}/${remark}
        mkdir ${file_path}/account/${api_name}/vm/${region}/${remark}/vm_info
        echo "${InstanceId}" > ${file_path}/account/${api_name}/vm/${region}/vm_info/${remark}/InstanceId
    else
        echo $json
        echo ""
        echo "创建失败，建议翻译上面一段话"
        exit
    fi

    clear
    echo "`date` 正在进行AWS Lightsail vm信息"
    echo
    json=`aws lightsail get-instance --instance-name ${remark}`
    ipv4=`echo ${json} | jq -r '.instance.publicIpAddress'`
    ipv6=`echo ${json} | jq -r '.instance.ipv6Addresses[0]'`
    json=`aws lightsail open-instance-public-ports \
    --instance-name ${remark} \
    --port-info fromPort=0,protocol=-1,toPort=65535`

    echo "${ipv4}" > ${file_path}/account/${api_name}/vm/${region}/vm_info/${remark}/ipv4
    echo "${ipv6}" > ${file_path}/account/${api_name}/vm/${region}/vm_info/${remark}/ipv6

    clear
    echo "`date` 正在进行AWS Lightsail vm信息"
    echo
    if [[ $win == "y" ]]; then
        echo -e "实例ID：${InstanceId}
IP地址1：${ipv4}
IP地址2：${ipv6}

用户名：root
密码：Opencloud@Leige
密码为固定密码，请立即修改！"
fi
fi
}

#aws选择区域
region_Lightsail_aws(){
    json=`cat <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/aws/Lightsail/region/region)`
    o=`echo $json| jq ".opencloud | length"`
    
    i=-1
    while ((i < ("${o}" - "1" )))
    do
        ((i++))
        echo -n -e "  ${Green_font_prefix}${i}.${Font_color_suffix}  "
        echo $json | jq -r '.opencloud['${i}'].name'
    done
    read -e -p "请选择你的服务器所在地区（编号）:" region_num
        id=`echo $json | jq -r '.opencloud['${region_num}'].id'`
    
    clear
    echo "`date` 正在进行AWS Lightsail 创建vm"
    echo
    json=`cat <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/aws/Lightsail/region/${id}) `
    o=`echo $json| jq ".opencloud | length"`
    
    i=-1
    while ((i < ("${o}" - "1" )))
    do
        ((i++))
        echo -n -e "  ${Green_font_prefix}${i}.${Font_color_suffix}  `echo $json | jq -r '.opencloud['${i}'].id'` "
        echo $json | jq -r '.opencloud['${i}'].name'
    done
    read -e -p "请选择你的服务器位置（编号）:" b
        region=`echo $json | jq -r '.opencloud['${b}'].id'`
}

#aws选择类型
size_Lightsail_aws(){
    json=`cat <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/aws/Lightsail/size/size)`
    o=`echo $json| jq ".opencloud | length"`
    
    i=-1
    while ((i < ("${o}" - "1" )))
    do
        ((i++))
        echo -n -e "  ${Green_font_prefix}${i}.${Font_color_suffix}  "
        echo $json | jq -r '.opencloud['${i}'].name'
    done
    read -e -p "请选择你的服务器类型（编号）:" b
        size=`echo $json | jq -r '.opencloud['${b}'].id'`
}

#选择系统
image_aws_Lightsail(){
    json=`cat <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/aws/Lightsail/image/image)`
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
    
    clear
    echo "`date` 正在进行AWS Lightsail 创建vm"
    echo
    json=`cat <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/aws/Lightsail/image/${image})`
    o=`echo $json| jq ".opencloud | length"`
    
    i=-1
    while ((i < ("${o}" - "1" )))
    do
        ((i++))
        echo -n -e "  ${Green_font_prefix}${i}.${Font_color_suffix}  "
        echo $json | jq -r '.opencloud['${i}'].name'
    done
    read -e -p "请选择你的服务器类型（编号）:" b
        image=`echo $json | jq -r '.opencloud['${b}'].id'`
}

#aws测活
Information_user_aws_Lightsail(){
    clear
    echo "`date` 正在进行AWS Lightsail API测活"
    echo
    read -e -p "当前配置检测的地区是：us-west-2，需要切换地区？(默认: N 取消):" info
    [[ -z ${info} ]] && info="n"
    if [[ ${info} == [Yy] ]]; then
        region_Lightsail_aws
    else
        region="us-west-2"
    fi
    
    clear
    echo "`date` 正在进行AWS Lightsail API测活"
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
    read -e -p "是否需要测活那个API？(编号)：" num
    
    api_name=${a[num]}
    
    key_id=`cat ${file_path}/account/${api_name}/key_id`
    access_key=`cat ${file_path}/account/${api_name}/access_key`
    
    export AWS_ACCESS_KEY_ID=${key_id}
    export AWS_SECRET_ACCESS_KEY=${access_key}
    export AWS_DEFAULT_REGION=${region}
    export AWS_DEFAULT_OUTPUT=json

    
    clear
    echo "`date` 正在进行AWS Lightsail API测活"
    echo

    json=`aws service-quotas get-service-quota \
--service-code Lightsail \
--quota-code L-1216C47A`

        echo -e  "账号信息如下：
API名称：${var0}
CPU额度：`echo $json | jq -r '.Quota.Value'`" 

    aws_Lightsail_loop_script
}

#aws循环脚本
aws_Lightsail_loop_script(){
echo -e "
 ${Green_font_prefix}98.${Font_color_suffix} 返回AWS Lightsail菜单
 ${Green_font_prefix}99.${Font_color_suffix} 退出脚本"  &&
 

read -p " 请输入数字 :" num
  case "$num" in
    98)
    aws_Lightsail_menu
    ;;
    99)
    exit 1
    ;;
  *)
    clear
    echo -e "${Error}:请输入正确数字 [0-99]（2秒后返回）"
    sleep 2s
    aws_Lightsail_menu
    ;;
  esac
}

#登录秘钥
ssh_key(){
    
    if [[ ! -f "${file_path}/${api_name}/account/opencloud.pem" ]]; then
        json=`aws Lightsail create-key-pair --key-name opencloud --query 'opencloud' --output text > ${file_path}/account/${api_name}/opencloud.pem`
    else
        keydata=`cat ${file_path}/${api_name}/account/opencloud.pem`
    fi
}

#aws菜单
aws_Lightsail_menu() {
  clear
  echo -e "AWS Lightsail 云服务开机脚本${Red_font_prefix} 开源免费 无加密代码${Font_color_suffix} ${Green_font_prefix}from @openccloud${Font_color_suffix}
项目地址：${Red_font_prefix}https://github.com/LG-leige/open_cloud${Font_color_suffix}
 ${Green_font_prefix}1.${Font_color_suffix} API测活
 ${Green_font_prefix}2.${Font_color_suffix} 更换IP
 ${Green_font_prefix}3.${Font_color_suffix} 创建机器
 ${Green_font_prefix}4.${Font_color_suffix} 删除机器
————————————————————————————————————————————————————————————————
 ${Green_font_prefix}5.${Font_color_suffix} 查询已保存api
 ${Green_font_prefix}6.${Font_color_suffix} 添加api
 ${Green_font_prefix}7.${Font_color_suffix} 删除api
————————————————————————————————————————————————————————————————
 ${Green_font_prefix}0.${Font_color_suffix} 退出脚本" &&

read -p " 请输入数字 :" num
  case "$num" in
    1)
    Information_user_aws_Lightsail
    ;;
    2)
    change_ip_aws_Lightsail
    ;;
    3)
    create_Lightsail_AWS
    ;;
    4)
    del_Lightsail_aws
    ;;
    5)
    clear
    echo "`date` 正在进AWS Lightsail查询已保存的api"
    echo
    check_api_aws_Lightsail
    aws_Lightsail_loop_script
    ;;
    6)
    create_api_aws_Lightsail
    ;;
    7)
    del_api_aws_Lightsail
    ;;
    0)
    exit 1
    ;;
  *)
    clear
    echo -e "${Error}:请输入正确数字 [0-99]（2秒后返回）"
    sleep 2s
    aws_Lightsail_menu
    ;;
  esac
}

#查询已保存aws api
check_api_aws_Lightsail(){
    echo "已绑定的api："
    ls ${file_path}/account
}

#创建aws api
create_api_aws_Lightsail(){
    clear
    echo "`date` 正在进行AWS Lightsail创建api操作"
    echo
    check_api_aws_Lightsail
    
    echo
    read -e -p "请新的api添加一个备注：" api_name
    read -e -p "输入access_key_id：" key_id
    read -e -p "输入secret_access_key：" access_key
	
	if [ ! -d "${file_path}/account/${api_name}" ]; then
			mkdir ${file_path}/account/${api_name}
			echo "${key_id}" > ${file_path}/account/${api_name}/key_id
			echo "${access_key}" > ${file_path}/account/${api_name}/access_key
			echo "添加成功！"
		else
			echo "该备注已经存在，请更换其他名字，或者删除原来api"
    fi
    
    aws_Lightsail_loop_script
}

#删除aws api
del_api_aws_Lightsail(){

    clear
    echo "`date` 正在进行AWS Lightsail删除api操作"
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
    
    read -e -p "是否需要删除备注为 ${a[num]} 的API(默认: N 取消)：" info
    [[ -z ${info} ]] && info="n"
    if [[ ${info} == [Yy] ]]; then
		if [ ! -d "${file_path}/account/${api_name}" ]; then
			echo "未在系统中查找到该名称的api"
		else
			rm -rf ${file_path}/account/${api_name}
            echo "删除成功！"
		fi
	
    fi
    aws_Lightsail_loop_script
}

#初始化
initialization(){
    mkdir -p ${file_path}
    mkdir -p ${file_path}/account
    mkdir -p ${file_path}/account/default（勿删）
    
    if [ ! -f "/usr/local/bin/aws" ]; then
        echo "需要初始化，2秒后进行！"
        echo "注意：如果一直卡主无法初始化，请自行安装aws cli就可以了。"
        sleep 2s
        install_aws_Lightsail_cli
        rm -rf /root/aws
        rm -rf awscliv2.zip
        
        echo "[default]
region = us-west-2
output = json
aws_Lightsail_access_key_id = test
aws_Lightsail_secret_access_key = test" > /root/.aws/config
    fi
    
    aws_Lightsail_menu
}

#安装aws cli
install_aws_Lightsail_cli(){
    curl -s "https://raw.githubusercontent.com/LG-leige/open_cloud/main/aws/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    ./aws/install -i /usr/local/aws-cli -b /usr/local/bin
}
initialization