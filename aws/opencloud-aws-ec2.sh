#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"
file_path="/root/.opencloud/aws/ec2"

#获取win密码
get_win_passwd(){
    clear
    echo "`date` 正在进行AWS EC2 获取WIN密码"
    echo
    region_ec2_aws
    
    clear
    echo "`date` 正在进行AWS EC2 获取WIN密码"
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
    echo "`date` 正在进行AWS EC2 获取WIN密码"
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
    read -e -p "是否需要获取那台机器？(编号)：" num
    
    vm_name=${a[num]}
    
    ids=`cat ${file_path}/account/${api_name}/vm/${region}/vm_info/${vm_name}/InstanceId`
    
    sleep 10s
    
    `json=ws ec2 get-password-data --instance-id ${ids} --priv-launch-key ${file_path}/account/${api_name}/opencloud.pem`
    data=`echo $json | jq -r '.PasswordData'`
    clear
    echo -e "`date` 正在进行AWS EC2 获取WIN密码
用户名：Administrator
密码：${data}"
}

#删除实例
del_ec2_aws(){
    clear
    echo "`date` 正在进行AWS EC2 删除vm"
    echo
    region_ec2_aws
    
    clear
    echo "`date` 正在进行AWS EC2 删除vm"
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
    echo "`date` 正在进行AWS EC2 删除vm"
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
    
    
    ids=`cat ${file_path}/account/${api_name}/vm/${region}/vm_info/${vm_name}/InstanceId`
    
    json=`aws ec2 terminate-instances \
    --instance-ids ${ids}`
    status=`echo $json | jq -r '.TerminatingInstances[0].CurrentState.Code'`
    sleep 20s
    if [[ $status == "32" ]]; then
        rm -rf ${file_path}/account/${api_name}/vm/${region}/vm_info/${vm_name}/
        clear
        echo "`date` 正在进行AWS EC2 删除vm"
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
change_ip_aws_ec2(){
    
    clear
    echo "`date` 正在进行AWS EC2 更换IP"
    echo
    region_ec2_aws
    
    clear
    echo "`date` 正在进行AWS EC2 更换IP"
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
    echo "`date` 正在进行AWS EC2 更换IP"
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
    
    ids=`cat ${file_path}/account/${api_name}/vm/${region}/vm_info/${vm_name}/InstanceId`
    
    clear
    echo "`date` 正在进行AWS EC2 更换IP"
    echo
    json=`aws ec2 stop-instances \
    --instance-ids ${ids}`
    status=`echo $json | jq -r '.StoppingInstances[0].CurrentState.Code'`
    if [[ $status == "64" ]]; then
        sleep 30s
    else
        echo $status
        echo ""
        echo "更换失败，建议翻译上面一段话"
        exit
    fi
    
    clear
    echo "`date` 正在进行AWS EC2 更换IP"
    echo
    json=`aws ec2 start-instances \
        --instance-ids ${ids}`
    status=`echo $json | jq -r '.StoppingInstances[0].CurrentState.Code'`
    
    sleep 15s

    json=`aws ec2 describe-instances \
    --instance-ids ${ids} \
    --region ${region} `
    ip=`echo $json | jq -r '.Reservations[0].Instances[0].PublicIpAddress'`
    echo "`date` 正在进行AWS EC2 VM信息"
    echo
    echo "旧IP：`${file_path}/account/${api_name}/vm/${region}/vm_info/${remark}/ip`
新IP：${ip}"
    rm -rf ${file_path}/account/${api_name}/vm/${region}/${remark}/vm_info/ip
    echo "${ip}" >  ${file_path}/account/${api_name}/vm/${region}/vm_info/${remark}/ip
}

#已保存实例的备注
check_remark_aws_EC2(){
    echo "该API下保存的实例备注："
    ls ${file_path}/account/${api_name}/vm/${region}/vm_info
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
    --block-device-mappings "[{\"DeviceName\":\"/dev/sda1\",\"Ebs\":{\"VolumeSize\":${vda},\"DeleteOnTermination\":true}}]"`
    
    InstanceId=`echo $json | jq -r '.Instances[0].InstanceId'`
    
    if [[ $InstanceId != null ]]; then
        mkdir ${file_path}/account/${api_name}/vm
        mkdir ${file_path}/account/${api_name}/vm/${region}
        mkdir ${file_path}/account/${api_name}/vm/${region}/vm_info
        mkdir ${file_path}/account/${api_name}/vm/${region}/vm_info/${remark}
        echo "${InstanceId}" > ${file_path}/account/${api_name}/vm/${region}/vm_info/${remark}/InstanceId
    else
        echo $json
        echo ""
        echo "创建失败，建议翻译上面一段话"
    fi
}

#创建vm机器
create_vm_aws_EC2(){
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
echo root:Opencloud@Leige |sudo chpasswd root;
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config;
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config;
sudo service sshd restart;
""" \
    --security-group-ids ${sgid} \
    --subnet-id ${SubnetId} \
    --region ${region} \
    --block-device-mappings "[{\"DeviceName\":\"/dev/sda1\",\"Ebs\":{\"VolumeSize\":${vda},\"DeleteOnTermination\":true}}]"`
    
    InstanceId=`echo $json | jq -r '.Instances[0].InstanceId'`
    
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
    fi
}

#AWS创建ec2
create_ec2_AWS(){
    clear
    echo "`date` 正在进行AWS EC2 创建vm"
    echo
    region_ec2_aws
    
    clear
    echo "`date` 正在进行AWS EC2 创建vm"
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
    echo "`date` 正在进行AWS EC2 创建vm"
    echo
    size_ec2_aws
    
    clear
    echo "`date` 正在进行AWS EC2 创建vm"
    echo
    image_aws_ec2
    
    clear
    echo "`date` 正在进行AWS EC2 创建vm"
    echo
    check_remark_aws_EC2
    
    clear
    echo "`date` 正在进行AWS EC2 创建vm"
    echo
    read -e -p "请给这台服务器一个备注（尽量不要重复，数据会替换的）:" remark
    
    clear
    echo "`date` 正在进行AWS EC2 创建vm"
    echo
    read -e -p "需要给这台服务器设置多少硬盘呢（填写数字，默认8G）:" vda
    [[ -z ${vda} ]] && vda="8"
    
    clear
    echo "`date` 正在进行AWS EC2 创建vm"
    echo
    read -e -p "你创建的系统是否为windows:（默认 N）" win
    [[ -z ${win} ]] && win="n"
    
    clear
    echo "`date` 正在进行AWS EC2 创建vm
        
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
    echo "`date` 正在进行AWS EC2 创建vm"
    echo
    if test -f "${file_path}/account/${api_name}/vm/${region}/vpcid"; then
        vpcid=`cat ${file_path}/account/${api_name}/vm/${region}/vpcid`
        
        # 写到这里
    else
        json=`aws  ec2 describe-vpcs`
        vpcid=`echo $json | jq -r '.Vpcs[0].VpcId'`
        if [[ $svpcidgid != null ]]; then
            echo "${vpcid}" > ${file_path}/account/${api_name}/vm/${region}/vpcid
        else
            clear
            echo $json
            echo ""
            echo "创建失败，建议翻译上面一段话"
        fi   
    fi
    
    
     clear
    echo "`date` 正在进行AWS EC2 创建vm"
    echo
    if test -f "${file_path}/${api_name}/vm/${region}/security_group"; then
       ${sgid}=`cat ${file_path}/account/${api_name}/vm/${region}/security_group`
    else
        json=`aws ec2 create-security-group \
        --region ${region} \
        --group-name opencloud_${region} \
        --description "aws_EC2_securiy_group_${region}" \
        --vpc-id ${vpcid}`
        sgid=`echo $json | jq -r '.GroupId'`
        clear
        echo "`date` 正在进行AWS EC2 创建vm"
        echo
        if [[ $sgid != null ]]; then
            echo "${sgid}" > ${file_path}/account/${api_name}/vm/${region}/security_group
                json=`aws ec2 authorize-security-group-ingress \
                --group-id ${sgid} \
                --protocol -1 \
                --cidr 0.0.0.0/0 \
                --region ${region}`
                info=`echo $json | jq -r '.Return'`
                clear
                echo "`date` 正在进行AWS EC2 创建vm"
                echo
                if [[ $info == "true" ]]; then
                    echo "！"
                else
                    echo $info
                    echo ""
                    echo "创建失败，建议翻译上面一段话"
                fi
        else
            clear
            echo $json
            echo ""
            echo "创建失败，建议翻译上面一段话"
        fi
    fi

    clear
    echo "`date` 正在进行AWS EC2 创建vm"
    echo
    if test -f "${file_path}/account/${api_name}/vm/${region}/SubnetId"; then
        vpcid=`cat ${file_path}/account/${api_name}/vm/${region}/SubnetId`
    else
        json=`aws ec2 describe-subnets --region ${region}`
        SubnetId=`echo $json | jq -r '.Subnets[0].SubnetId'`
        if [[ SubnetId != null ]]; then
            echo "${vpcid}" > ${file_path}/account/${api_name}/vm/${region}/SubnetId
        else
            clear
            echo $json
            echo ""
            echo "创建失败，建议翻译上面一段话"
        fi   
    fi
    
    clear
    echo "`date` 正在进行AWS EC2 创建vm"
    echo
    if [[ $win == "y" ]]; then
        ssh_key
        create_win_aws_EC2
    else
        create_vm_aws_EC2
    fi
    
    clear
    echo "`date` 正在进行AWS EC2 创建vm"
    echo
    sleep 10s
    ids=`cat ${file_path}/${api_name}/vm/${region}/${remark}/InstanceId`
    json=`aws ec2 describe-instances \
    --instance-ids ${ids} \
    --region ${region} `
    ip=`echo $json | jq -r '.Reservations[0].Instances[0].PublicIpAddress'`
    echo "${ip}" >  ${file_path}/account/${api_name}//vm/${region}/vm_info/${remark}/ip
    
    
    clear
    echo "`date` 正在进行AWS EC2 vm信息"
    echo
    if [[ $win == "y" ]]; then
        echo -e "实例ID：${InstanceId}
IP地址：${ip}
登录密码需要再次运行脚本，选择win登录获取模块即可"
    else
        echo -e "实例ID：${InstanceId}
IP地址：${ip}
用户名：root
密码：Opencloud@Leige
密码为固定密码，请立即修改！"
    fi
fi
}

#aws选择区域
region_ec2_aws(){
    json=`cat <(curl -Ls https://raw.githubusercontent.com/zxc348369518/open_cloud/main/aws/EC2/region/region)`
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
    echo "`date` 正在进行AWS EC2 创建vm"
    echo
    json=`cat <(curl -Ls https://raw.githubusercontent.com/zxc348369518/open_cloud/main/aws/EC2/region/${id}) `
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
size_ec2_aws(){
    json=`cat <(curl -Ls https://raw.githubusercontent.com/zxc348369518/open_cloud/main/aws/EC2/size/size)`
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
    echo "`date` 正在进行AWS EC2 创建vm"
    echo
    json=`cat <(curl -Ls https://raw.githubusercontent.com/zxc348369518/open_cloud/main/aws/EC2/size/${id})`
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
image_aws_ec2(){
    json=`cat <(curl -Ls https://raw.githubusercontent.com/zxc348369518/open_cloud/main/aws/EC2/image/image)`
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
    echo "`date` 正在进行AWS EC2 创建vm"
    echo
    json=`cat <(curl -Ls https://raw.githubusercontent.com/zxc348369518/open_cloud/main/aws/EC2/image/${region}/${image})`
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
Information_user_aws_EC2(){
    clear
    echo "`date` 正在进行AWS EC2 API测活"
    echo
    read -e -p "当前配置检测的地区是：us-west-2，需要切换地区？(默认: N 取消):" info
    [[ -z ${info} ]] && info="n"
    if [[ ${info} == [Yy] ]]; then
        region_ec2_aws
    else
        region="us-west-2"
    fi
    
    clear
    echo "`date` 正在进行AWS EC2 API测活"
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
    echo "`date` 正在进行AWS EC2 API测活"
    echo

    json=`aws service-quotas get-service-quota \
--service-code ec2 \
--quota-code L-1216C47A`

        echo -e  "账号信息如下：
API名称：${var0}
CPU额度：`echo $json | jq -r '.Quota.Value'`" 

    aws_EC2_loop_script
}

#aws循环脚本
aws_EC2_loop_script(){
echo -e "
 ${Green_font_prefix}98.${Font_color_suffix} 返回AWS EC2菜单
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

#登录秘钥
ssh_key(){
    
    if [[ ! -f "${file_path}/${api_name}/account/opencloud.pem" ]]; then
        json=`aws ec2 create-key-pair --key-name opencloud --query 'opencloud' --output text > ${file_path}/account/${api_name}/opencloud.pem`
    else
        keydata=`cat ${file_path}/${api_name}/account/opencloud.pem`
    fi
}

#aws菜单
aws_EC2_menu() {
  clear
  echo -e "AWS EC2 云服务开机脚本${Red_font_prefix} 开源免费 无加密代码${Font_color_suffix} ${Green_font_prefix}from @openccloud${Font_color_suffix}
项目地址：${Red_font_prefix}https://github.com/LG-leige/open_cloud${Font_color_suffix}
 ${Green_font_prefix}1.${Font_color_suffix} API测活
 ${Green_font_prefix}2.${Font_color_suffix} 更换IP
 ${Green_font_prefix}3.${Font_color_suffix} 创建机器
 ${Green_font_prefix}4.${Font_color_suffix} 删除机器
 ${Green_font_prefix}5.${Font_color_suffix} 获取windows登录密码
————————————————————————————————————————————————————————————————
 ${Green_font_prefix}6.${Font_color_suffix} 查询已保存api
 ${Green_font_prefix}7.${Font_color_suffix} 添加api
 ${Green_font_prefix}8.${Font_color_suffix} 删除api
————————————————————————————————————————————————————————————————
 ${Green_font_prefix}0.${Font_color_suffix} 退出脚本" &&

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
    clear
    echo "`date` 正在进AWS EC2查询已保存的api"
    echo
    check_api_aws_EC2
    aws_EC2_loop_script
    ;;
    7)
    create_api_aws_EC2
    ;;
    8)
    del_api_aws_EC2
    ;;
    0)
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
    echo "已绑定的api："
    ls ${file_path}/account
}

#创建aws api
create_api_aws_EC2(){
    clear
    echo "`date` 正在进行AWS EC2创建api操作"
    echo
    check_api_aws_EC2
    
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
    
    aws_EC2_loop_script
}

#删除aws api
del_api_aws_EC2(){

    clear
    echo "`date` 正在进行AWS EC2删除api操作"
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
    aws_EC2_loop_script
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
        install_aws_EC2_cli
        rm -rf /root/aws
        rm -rf awscliv2.zip
        
        echo "[default]
region = us-west-2
output = json
aws_EC2_access_key_id = test
aws_EC2_secret_access_key = test" > /root/.aws/config
    fi
    
    aws_EC2_menu
}

#安装aws cli
install_aws_EC2_cli(){
    curl -s "https://raw.githubusercontent.com/zxc348369518/open_cloud/main/aws/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    ./aws/install -i /usr/local/aws-cli -b /usr/local/bin
}
initialization
