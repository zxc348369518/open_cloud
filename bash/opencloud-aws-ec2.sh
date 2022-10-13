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
#登录秘钥
ssh_key(){
    
    if [[ ! -f "${file_path}/aws/${api_name}/${region}/opencloud.pem" ]]; then
        json=`aws ec2 create-key-pair --key-name opencloud --query 'operncloud' --output text > ${file_path}/aws/${api_name}/${region}/opencloud.pem`
    else
        keydata=`cat ${file_path}/aws/${api_name}/${region}/opencloud.pem`
    fi
}

#获取win密码
get_win_passwd(){
    aws_EC2_select_api
    check_remark_aws_EC2
    read -e -p "请输入要操作的实例备注:" remark
    ids=`cat ${file_path}/aws/${api_name}/${region}/remark/${remark}/InstanceId`
    clear
    echo "`date` 正在进行获取windows登录密码" && echo
    sleep 10s
    
    json=`aws ec2 get-password-data \
    --instance-id ${ids}`
    
    data=`echo $json | jq -r '.PasswordData'`
    
    aws ec2 get-password-data --instance-id ${ids} --priv-launch-key ${file_path}/aws/${api_name}/${region}/opencloud.pem
    
    echo -e "用户名：Administrator\n密码：`echo $json | jq -r '.PasswordData'`"
}

#删除实例
del_ec2_aws(){
    aws_EC2_select_api
    check_remark_aws_EC2
    read -e -p "请输入要操作的实例备注:" remark
    ids=`cat ${file_path}/aws/${api_name}/${region}/remark/${remark}/InstanceId`
    clear
    echo "`date` 正在进行删除AWS EC2 操作" && echo
    echo -n "正在终止实例中，请稍后（大约10秒）！"
    json=`aws ec2 terminate-instances \
    --instance-ids ${ids}`
    status=`echo $json | jq -r '.TerminatingInstances[0].CurrentState.Code'`
    sleep 20s
    if [[ $status == "32" ]]; then
        echo "——————成功！！！"
        rm -rf ${file_path}/aws/${api_name}/${region}/remark/${remark}
    else
        echo $status
        exit
    fi
}

#已保存实例的备注
check_remark_aws_EC2(){
    clear
    echo "该API下保存的实例备注："
    ls ${file_path}/aws/${api_name}/${region}/remark
}

#更换IP
change_ip_aws_ec2(){
    aws_EC2_select_api
    check_remark_aws_EC2
    read -e -p "请输入要操作的实例备注:" remark
    ids=`cat ${file_path}/aws/${api_name}/${region}/remark/${remark}/InstanceId`
    clear
    echo "`date` 正在进行更换AWS EC2 IP操作" && echo
    echo -n "正在停止实例中，请稍后（大约30秒）！"
    json=`aws ec2 stop-instances \
    --instance-ids ${ids}`
    status=`echo $json | jq -r '.StoppingInstances[0].CurrentState.Code'`
    if [[ $status == "64" ]]; then
        sleep 30s
        echo "——————成功！！！"
    else
        echo $status
        exit
    fi
    
    echo -n "正在启动实例中，请稍后（大约15秒）！"
    json=`aws ec2 start-instances \
        --instance-ids ${ids}`
    status=`echo $json | jq -r '.StoppingInstances[0].CurrentState.Code'`
    sleep 15s
    echo "——————成功！！！"

    echo -n "正在获取IP中，请稍后！（大约5秒）"
    get_ip_aws_EC2
    
    echo "——————成功！"
    echo "新IP：${ip}"
}

#选择系统
image_aws_ec2(){
    clear
    json=`cat <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/aws/EC2/image/image)`
    o=`echo $json| jq ".opencloud | length"`
    
    i=-1
    while ((i < ("${o}" - "1" )))
    do
        ((i++))
        echo -n -e "  ${Green_font_prefix}${i}.${Font_color_suffix}  "
        echo $json | jq -r '.opencloud['${i}'].name'
    done
    read -e -p "请选择你的服务器系统（编号）:" b
    id=`echo $json | jq -r '.opencloud['${b}'].id'`
    
    clear
    json=`cat <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/aws/EC2/image/${region}/${id})`
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

#获取ip
get_ip_aws_EC2(){
    ids=`cat ${file_path}/aws/${api_name}/${region}/remark/${remark}/InstanceId`
    json=`aws ec2 describe-instances \
    --instance-ids ${ids} \
    --region ${region} `
    ip=`echo $json | jq -r '.Reservations[0].Instances[0].PublicIpAddress'`
    
}

#创建机器 win
create_win_aws_EC2(){
    json=`aws ec2 run-instances \
    --image-id ${image} \
    --count 1 \
    --instance-type ${size} \
    --associate-public-ip-address \
    --key-name opencloud \
    --security-group-ids ${sgid} \
    --subnet-id ${SubnetId} \
    --region ${region} \
    --block-device-mappings "[{\"DeviceName\":\"/dev/xvda\",\"Ebs\":{\"VolumeSize\":${vda},\"DeleteOnTermination\":true}}]"`
    
    InstanceId=`echo $json | jq -r '.Instances[0].InstanceId'`
    
    if [[ $InstanceId != null ]]; then
        echo "——————成功！"
        
        echo "${InstanceId}" > ${file_path}/aws/${api_name}/${region}/remark/${remark}/InstanceId
    else
        echo $json
        echo ""
        echo "创建失败，建议翻译上面一段话"
    fi
}

#创建机器
create_vm_aws_EC2(){
    pasd=`date +%s | sha256sum | base64 | head -c 12 ; echo`
    json=`aws ec2 run-instances \
    --image-id ${image} \
    --count 1 \
    --instance-type ${size} \
    --associate-public-ip-address \
    --user-data """#!/bin/sh
sudo service iptables stop 2> /dev/null ; chkconfig iptables off 2> /dev/null ;
sudo sed -i.bak '/^SELINUX=/cSELINUX=disabled' /etc/sysconfig/selinux;
sudo sed -i.bak '/^SELINUX=/cSELINUX=disabled' /etc/selinux/config;
sudo setenforce 0;
echo root:${pasd} |sudo chpasswd root;
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config;
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config;
sudo service sshd restart;
""" \
    --security-group-ids ${sgid} \
    --subnet-id ${SubnetId} \
    --region ${region} \
    --block-device-mappings "[{\"DeviceName\":\"/dev/xvda\",\"Ebs\":{\"VolumeSize\":${vda},\"DeleteOnTermination\":true}}]"`
    
    InstanceId=`echo $json | jq -r '.Instances[0].InstanceId'`
    
    if [[ $InstanceId != null ]]; then
        echo "——————成功！"
        
        echo "${InstanceId}" > ${file_path}/aws/${api_name}/${region}/remark/${remark}/InstanceId
    else
        echo $json
        echo ""
        echo "创建失败，建议翻译上面一段话"
    fi
}

#aws选择类型
size_ec2_aws(){
    clear
    json=`cat <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/aws/EC2/size/size)`
    o=`echo $json| jq ".opencloud | length"`
    
    i=-1
    while ((i < ("${o}" - "1" )))
    do
        ((i++))
        echo -n -e "  ${Green_font_prefix}${i}.${Font_color_suffix}  "
        echo $json | jq -r '.opencloud['${i}'].name'
    done
    read -e -p "请选择你的服务器类型（编号）:" b
        id=`echo $json | jq -r '.opencloud['${b}'].id'`
    
    clear
    json=`cat <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/aws/EC2/size/${id})`
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

#aws 获取子网id
get_SubnetId_aws_EC2(){
    json=`aws ec2 describe-subnets --region ${region}`
    SubnetId=`echo $json | jq -r '.Subnets[0].SubnetId'`
    
    if [[ $SubnetId != null ]]; then
        echo "——————成功！"
        echo "${SubnetId}" > ${file_path}/aws/${api_name}/${region}/SubnetId
    else
        echo $json
        echo ""
        echo "创建失败，建议翻译上面一段话"
    fi
}

#aws 配置安全组
set_ec2_security_group_aws(){
    json=`aws ec2 authorize-security-group-ingress \
    --group-id ${sgid} \
    --protocol -1 \
    --cidr 0.0.0.0/0 \
    --region ${region}`
    info=`echo $json | jq -r '.Return'`
    
    if [[ $info == "true" ]]; then
        echo "——————成功！"
    else
        echo $info
        echo ""
        echo "创建失败，建议翻译上面一段话"
    fi
}

#aws ec2 创建安全组
create_ec2_security_group_aws(){
    json=`aws ec2 create-security-group \
    --region ${region} \
    --group-name opencloud_${region} \
    --description "aws_EC2_securiy_group_${region}" \
    --vpc-id ${vpcid}`
    sgid=`echo $json | jq -r '.GroupId'`
    
    if [[ $sgid != null ]]; then
        echo "——————成功！"
        echo "${sgid}" > ${file_path}/aws/${api_name}/${region}/security_group
    else
        echo $json
        echo ""
        echo "创建失败，建议翻译上面一段话"
    fi
}

#AWS获取VPC ID
get_vpcid_aws_EC2(){
    json=`aws  ec2 describe-vpcs`
    vpcid=`echo $json | jq -r '.Vpcs[0].VpcId'`
}

#aws选择区域
region_ec2_aws(){
    clear
    json=`cat <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/aws/EC2/region/region)`
    o=`echo $json| jq ".opencloud | length"`
    
    i=-1
    while ((i < ("${o}" - "1" )))
    do
        ((i++))
        echo -n -e "  ${Green_font_prefix}${i}.${Font_color_suffix}  "
        echo $json | jq -r '.opencloud['${i}'].name'
    done
    read -e -p "请选择你的服务器所在地区（编号）:" b
        id=`echo $json | jq -r '.opencloud['${b}'].id'`
    
    clear
    json=`cat <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/aws/EC2/region/${id}) `
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

#AWS创建ec2
create_ec2_AWS(){
    aws_EC2_select_api 
    size_ec2_aws
    image_aws_ec2
    
    mkdir -p ${file_path}/aws/${api_name}/${region}
    
    read -e -p "请给这台服务器一个备注（尽量不要重复，数据会替换的）:" remark
    mkdir -p ${file_path}/aws/${api_name}/${region}/remark/${remark}
    
    check_remark_aws_EC2
    
    read -e -p "需要给这台服务器设置多少硬盘呢（数量：GB）:" vda
    
    clear
    echo "`date` 正在进行创建AWS EC2 操作" && echo
    
    if [[ ! -f "${file_path}/aws/${api_name}/${region}/security_group" ]]; then
        echo -n "正在创建安全组，请稍等！"
        get_vpcid_aws_EC2
        create_ec2_security_group_aws
        echo -n "正在配置安全组，请稍等！"
    set_ec2_security_group_aws 
    else
        echo -n "正在获取安全组，请稍等！"
        sgid=`cat ${file_path}/aws/${api_name}/${region}/security_group`
        echo "——————成功！"
    fi

    if [[ ! -f "${file_path}/aws/${api_name}/${region}/SubnetId" ]]; then
        echo -n "正在获取子网ID，请稍等！"
        get_SubnetId_aws_EC2
    else
        echo -n "正在获取安全组，请稍等！"
        SubnetId=`cat ${file_path}/aws/${api_name}/${region}/SubnetId`
        echo "——————成功！"
    fi
    
    echo -n "正在创建EC2，请稍等！"
    if [[ $b != "2" ]]; then
        ssh_key
        create_win_aws_EC2
    else
        create_vm_aws_EC2
    fi
    
    echo -n "正在获取IP和密码，请稍等！"
    sleep 10s
    get_ip_aws_EC2
    
    if [[ $b != "2" ]]; then
        echo -e "开机成功\n实例ID：${InstanceId}\nIP地址：${ip}\n登录密码需要再次运行脚本，选择win登录获取模块即可"
    else
        echo -e "开机成功\n实例ID：${InstanceId}\nIP地址：${ip}\n用户名：root\n密码：${pasd}"
    fi
    
}

#aws选择api
aws_EC2_select_api(){
    check_api_aws_EC2
    read -p "你需要操作的api名称:" api_name
    region_ec2_aws
    
    key_id=`cat ${file_path}/aws/${api_name}/key_id`
    access_key=`cat ${file_path}/aws/${api_name}/access_key`
    
    aws configure set region ${region}
    aws configure set aws_EC2_access_key_id ${key_id}
    aws configure set aws_EC2_secret_access_key ${access_key}
    
}

#aws测活
Information_user_aws_EC2(){
    read -e -p "当前配置检测的地区是：us-west-2，需要切换地区？(默认: N 取消):" info
    [[ -z ${info} ]] && info="n"
    if [[ ${info} == [Yy] ]]; then
        region_ec2_aws
    else
        region="us-west-2"
    fi
    
    cd ${file_path}/aws
    o=`ls ${file_path}/aws|wc -l`
    i=-1
    echo "提示：CPU配额大于0账号为正常"
    echo ""
    while ((i < ("${o}" - "1" )))
    do
        ((i++))
        array=(*)
        var0=`echo ${array[${i}]}`
        
        key_id=`cat ${file_path}/aws/${var0}/key_id`
        access_key=`cat ${file_path}/aws/${var0}/access_key`
        aws configure set region ${region}
        aws configure set aws_EC2_access_key_id ${key_id}
        aws configure set aws_EC2_secret_access_key ${access_key}
        
        json=`aws service-quotas get-service-quota \
        --service-code ec2 \
        --quota-code L-1216C47A`
        
        echo -e  "API名称：${var0}————CPU配额：`echo $json | jq -r '.Quota.Value'`"
    done
    aws_EC2_loop_script
}


#aws循环脚本
aws_EC2_loop_script(){
echo -e "
 ${Green_font_prefix}98.${Font_color_suffix} 返回AWS菜单
 ${Green_font_prefix}99.${Font_color_suffix} 退出脚本"  &&
 

read -p " 请输入数字 :" num
  case "$num" in
    98)
    aws_EC2_menu
    ;;
    99)
    exit 1
    ;;
  *)
    clear
    echo -e "${Error}:请输入正确数字 [0-99]（2秒后返回）"
    sleep 2s
    aws_EC2_menu
    ;;
  esac
}

#aws菜单
aws_EC2_menu() {
  clear
  echo && echo -e "AWS EC2 云服务开机脚本${Red_font_prefix} 开源免费 无加密代码${Font_color_suffix} ${Green_font_prefix}from @openccloud${Font_color_suffix}
项目地址：${Red_font_prefix}https://github.com/LG-leige/open_cloud${Font_color_suffix}
 ${Green_font_prefix}1.${Font_color_suffix} 一键全部API测活
 ${Green_font_prefix}2.${Font_color_suffix} 更换IP
 ${Green_font_prefix}3.${Font_color_suffix} 创建机器
 ${Green_font_prefix}4.${Font_color_suffix} 删除机器
 ${Green_font_prefix}5.${Font_color_suffix} 获取windows登录密码
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
    Information_user_aws_EC2
    ;;
    2)
    change_ip_aws_ec2
    ;;
    3)
    create_ec2_AWS
    ;;
    4)
    del_ec2_aws
    ;;
    5)
    get_win_passwd
    ;;
    6)
    check_api_aws_EC2
    aws_EC2_loop_script
    ;;
    7)
    create_api_aws_EC2
    ;;
    8)
    del_api_aws_EC2
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
    aws_EC2_menu
    ;;
  esac
}

#查询已保存aws api
check_api_aws_EC2(){
    clear
    echo "已绑定的api："
    ls ${file_path}/aws
}

#创建aws api
create_api_aws_EC2(){
    check_api_aws_EC2
    
    read -e -p "请为这个api添加一个备注：" api_name
    if [ -d "${file_path}/aws/${api_name}" ]; then
        echo "该备注已经存在，请更换其他名字，或者删除原来api"
    else
        mkdir ${file_path}/aws/${api_name}
        read -e -p "输入access_key_id：" key_id
        read -e -p "输入secret_access_key" access_key
        echo "${key_id}" > ${file_path}/aws/${api_name}/key_id
        echo "${access_key}" > ${file_path}/aws/${api_name}/access_key
        echo "添加成功！"
    fi
    
    aws_EC2_loop_script
}

#删除aws api
del_api_aws_EC2(){
    check_api_aws_EC2
    read -p "你需要删除的api名称:" api_name
    read -e -p "是否需要删除 ${api_name}(默认: N 取消)：" info
    [[ -z ${info} ]] && info="n"
    if [[ ${info} == [Yy] ]]; then
        read -e -p "请输入需要删除api的名字：" api_name
        if test -f "${file_path}/aws/${api_name}"; then
            rm -rf ${file_path}/aws/${api_name}
            echo "删除成功！"
        else
            echo "未在系统中查找到该名称的api"
        fi
    fi
    aws_EC2_loop_script
}
aws_EC2_menu