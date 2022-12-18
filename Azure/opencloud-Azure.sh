#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"
file_path="/root/.opencloud/Azure"

#azure创建vm
create_vm_azure(){
    json=`curl -s -H "Content-Type: application/json" \
    -H "Authorization: Bearer $az_token" \
    -X PUT -d '{
                "location": "'${location}'",
                "name": "'${resource_name}'",
                "properties": {
                    "hardwareProfile": {
                        "vmSize": "'${vmSize}'"
                    },
                    "storageProfile": {
                        "imageReference": {
                            "sku": "'${sku}'",
                            "publisher": "'${publisher}'",
                            "version": "'${version}'",
                            "offer": "'${offer}'"
                            
                        },
                        "osDisk": {
                            "caching": "ReadWrite",
                            "managedDisk": {
                                "storageAccountType": "Premium_LRS"
                            },
                            "name": "'${resource_name}'",
                            "diskSizeGB": "'${disk}'",
                            "createOption": "FromImage"
                        }
                    },
                    "osProfile": {
                        "adminUsername": "'${resource_name}'",
                        "computerName": "'${resource_name}'",
                        "adminPassword": "'${resource_name}'-"
                    },
                    "networkProfile": {
                        "networkInterfaces": [
                            {
                                "id": "'${vnet_id}'",
                                "properties": {
                                    "primary": "True"
                                }
                            }
                        ]
                    },
                    "userData": "IyEvYmluL2Jhc2gKICAgICAgICAgICAgICAgIApzdWRvIHNlcnZpY2UgaXB0YWJsZXMgc3RvcCAyPiAvZGV2L251bGwgOyBjaGtjb25maWcgaXB0YWJsZXMgb2ZmIDI+IC9kZXYvbnVsbCA7CnN1ZG8gc2VkIC1pLmJhayAnL15TRUxJTlVYPS9jU0VMSU5VWD1kaXNhYmxlZCcgL2V0Yy9zeXNjb25maWcvc2VsaW51eDsKc3VkbyBzZWQgLWkuYmFrICcvXlNFTElOVVg9L2NTRUxJTlVYPWRpc2FibGVkJyAvZXRjL3NlbGludXgvY29uZmlnOwpzdWRvIHNldGVuZm9yY2UgMDsKZWNobyByb290Ok9wZW5jbG91ZEBMZWlnZSB8c3VkbyBjaHBhc3N3ZCByb290OwpzdWRvIHNlZCAtaSAncy9eI1w/UGVybWl0Um9vdExvZ2luLiovUGVybWl0Um9vdExvZ2luIHllcy9nJyAvZXRjL3NzaC9zc2hkX2NvbmZpZzsKc3VkbyBzZWQgLWkgJ3MvXiNcP1Bhc3N3b3JkQXV0aGVudGljYXRpb24uKi9QYXNzd29yZEF1dGhlbnRpY2F0aW9uIHllcy9nJyAvZXRjL3NzaC9zc2hkX2NvbmZpZzsKc3VkbyBzZXJ2aWNlIHNzaGQgcmVzdGFydDs="
                }
 } '\
    https://management.azure.com/subscriptions/${az_subid}/resourceGroups/${resource_name}/providers/Microsoft.Compute/virtualMachines/${resource_name}?api-version=2021-03-01`
    rm -rf ${file_path}/userdata
    
    var=`echo $json | jq -r '.type'`
}

#vm镜像
image_azure(){
    json=`cat <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/Azure/image)`
    o=`echo $json| jq ".opencloud | length"`
    
    i=-1
    while ((i < ("${o}" - "1" )))
    do
        ((i++))
        echo -n -e "  ${Green_font_prefix}${i}.${Font_color_suffix}  "
        echo $json | jq -r '.opencloud['${i}'].name'
    done
    read -e -p "请选择你的服务器系统（编号）:" b
        sku=`echo $json | jq -r '.opencloud['${b}'].sku'`
        publisher=`echo $json | jq -r '.opencloud['${b}'].publisher'`
        version=`echo $json | jq -r '.opencloud['${b}'].version'`
        offer=`echo $json | jq -r '.opencloud['${b}'].offer'`
}

#VM实例大小
vmSize_azure(){
    json=`cat <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/Azure/vmSize)`
    o=`echo $json| jq ".opencloud | length"`
    
    i=-1
    while ((i < ("${o}" - "1" )))
    do
        ((i++))
        echo -n -e "  ${Green_font_prefix}${i}.${Font_color_suffix}  "
        echo $json | jq -r '.opencloud['${i}'].name'
    done
    read -e -p "请选择你的服务器实例大小（编号）:" b
        vmSize=`echo $json | jq -r '.opencloud['${b}'].id'`
}

#VM硬盘
disk_azure(){
    read -e -p "硬盘大小位多少GB(默认: 64GB)：" disk
    [[ -z ${disk} ]] && disk="64"
}

#azure创建网络接口
create_nic_azure(){
    json=`curl -s -H "Content-Type: application/json" \
    -H "Authorization: Bearer $az_token" \
    -X PUT -d '{
        "properties": {
            "enableAcceleratedNetworking":"False",
            "ipConfigurations": [
            {
                "name": "ipconfig1",
                "properties": {
                    "publicIPAddress": {
                        "id": "'${public_ip}'"
                    },
                    "subnet": {
                        "id": "'${subnet_id}'"
                    }
                }
            }
        ]
    },
        "location":"'${location}'"
}' \
    https://management.azure.com/subscriptions/${az_subid}/resourceGroups/${resource_name}/providers/Microsoft.Network/networkInterfaces/${resource_name}?api-version=2022-01-01`
    
    var=`echo $json | jq -r '.type'`
    
    
}

#azure创建公网ip
create_public_ip_azure(){
    

    declare -l ddns="${resource_name}"

    json=`curl -s -H "Content-Type: application/json" \
    -H "Authorization: Bearer $az_token" \
    -X PUT -d '{
      "location":"'${location}'",
      "properties":{
          "publicIPAllocationMethod":"Dynamic",
          "idleTimeoutInMinutes":"4",
          "publicIPAddressVersion":"IPv4",
          "dnsSettings":{
              "domainNameLabel":"a'${ddns}'"
          }
      },
      "sku":{
          "name":"Basic",
          "tier":"Regional"
      }
    }' \
    https://management.azure.com/subscriptions/${az_subid}/resourceGroups/${resource_name}/providers/Microsoft.Network/publicIPAddresses/${resource_name}?api-version=2020-11-01`
    
    var=`echo $json | jq -r '.type'`
    fqdn=`echo $json | jq -r '.properties.dnsSettings.fqdn'`
}

#azure创建虚拟网络子网
create_Network_submets_azure(){
    
    json=`curl -s -H "Content-Type: application/json" \
    -H "Authorization: Bearer $az_token" \
    -X PUT -d '{
      "location":"'${location}'",
      "properties":{
              "addressPrefix":"10.0.0.0/24"
          }
    }' \
    https://management.azure.com/subscriptions/${az_subid}/resourceGroups/${resource_name}/providers/Microsoft.Network/virtualNetworks/${resource_name}/subnets/${resource_name}_subnet?api-version=2020-11-01`
    
    var=`echo $json | jq -r '.properties.provisioningState'`
}

#azure创建虚拟网络
create_Network_azure(){
    
    json=`curl -s -H "Content-Type: application/json" \
    -H "Authorization: Bearer $az_token" \
    -X PUT -d '{
      "location":"'${location}'",
      "properties":{
          "addressSpace":{
              "addressPrefixes":["10.0.0.0/16"]
          }
      }
    }' \
    https://management.azure.com/subscriptions/${az_subid}/resourceGroups/${resource_name}/providers/Microsoft.Network/virtualNetworks/${resource_name}?api-version=2020-11-01`
    
    var=`echo $json | jq -r '.properties.provisioningState'`
}

#azure创建资源组
create_resource_azure(){
    
    json=`curl -s -H "Content-Type: application/json" \
    -H "Authorization: Bearer $az_token" \
    -X PUT -d '{
      "Location":"'${location}'",
    }' \
    https://management.azure.com/subscriptions/${az_subid}/resourcegroups/${resource_name}?api-version=2021-04-01`
    
    var=`echo $json | jq -r '.properties.provisioningState'`
}

#创建vm返回
return_vm(){
    curl -s -H "Content-Type: application/json" \
    -H "Authorization: Bearer $az_token" \
    -X DELETE \
    https://management.azure.com/subscriptions/${az_subid}/resourcegroups/${resource_name}?api-version=2021-04-01
}

#azure准备创建vm
create_azure_vm(){
    clear
    echo "`date` 正在进行Azure创建VM"
    echo
    location_azure
    
    clear
    echo "`date` 正在进行Azure创建VM"
    echo
    disk_azure
    
    clear
    echo "`date` 正在进行Azure创建VM"
    echo
    vmSize_azure
    
    clear
    echo "`date` 正在进行Azure创建VM"
    echo
    image_azure
    
    clear
    echo "`date` 正在进行Azure创建VM"
    echo
    read -e -p "请给这台服务器一个备注（尽量不要重复，数据会替换的）:" remark
    
    clear
    echo "`date` 正在进行Azure创建VM"
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
    
    appid=`cat ${file_path}/account/${api_name}/appId`
    pasd=`cat ${file_path}/account/${api_name}/password`
    tenant=`cat ${file_path}/account/${api_name}/tenant`
    resource_name=`tr -dc "A-Z-0-9-a-z" < /dev/urandom | head -c 12`
    
    azure_token
    subid_user_azure

    clear
    echo "`date` 正在进行Azure创建VM"
    echo
    echo  "正在创建资源组，请稍后！"
    create_resource_azure
    
    if [[ $var != "Succeeded" ]];
    then
        echo $json
        echo "资源组创建失败"
        exit 1
    else
        mkdir ${file_path}/account/${api_name}/vm
        mkdir ${file_path}/account/${api_name}/vm/${remark}
        echo "${resource_name}" > ${file_path}/account/${api_name}/vm/${remark}/resource_name
        echo "${location}" > ${file_path}/account/${api_name}/vm/${remark}/location
    fi
    
    clear
    echo "`date` 正在进行Azure创建VM"
    echo
    echo "正在创建虚拟网络，请稍后！"
    create_Network_azure
    
    if [[ $var != "Updating" ]];
    then
        echo $json
        echo "虚拟网络创建失败，正在退回，退回需要5分钟时间！"
        return_vm
        rm -rf ${file_path}/account/${api_name}/vm/${remark}
        exit 1
    fi
    
    clear
    echo "`date` 正在进行Azure创建VM"
    echo
    echo "正在创建虚拟网络-子网，请稍后！"
    create_Network_submets_azure
    
    if [[ $var == "Updating" ]];
    then
        subnet_id=`echo $json | jq -r '.id'`
        echo "${subnet_id}" > ${file_path}/account/${api_name}/vm/${remark}/subnet_id
    else
        echo $json
        echo "虚拟网络-子网创建失败，正在退回，退回需要5分钟时间！"
        return_vm
        rm -rf ${file_path}/account/${api_name}/vm/${remark}
        exit 1
    fi
    
    clear
    echo "`date` 正在进行Azure创建VM"
    echo
    echo "正在创建公网ip，请稍后！"
    create_public_ip_azure
    
    if [[ $var == "Microsoft.Network/publicIPAddresses" ]];
    then
        public_ip=`echo $json | jq -r '.id'`
        echo "${public_ip}" > ${file_path}/account/${api_name}/vm/${remark}/public_ip
    else
        echo $json
        echo "公网ip创建失败，正在退回，退回需要5分钟时间！"
        return_vm
        rm -rf ${file_path}/account/${api_name}/vm/${remark}
        exit 1
    fi
    
    clear
    echo "`date` 正在进行Azure创建VM"
    echo
    echo "正在创建网络接口，请稍后！"
    create_nic_azure
    if [[ $var == "Microsoft.Network/networkInterfaces" ]];
    then
        vnet_id=`echo $json | jq -r '.id'`
        echo "${vnet_id}" > ${file_path}/account/${api_name}/vm/${remark}/vnet_id
    else
        echo $json
        echo "网络接口创建失败，正在退回，退回需要5分钟时间！"
        return_vm
        rm -rf ${file_path}/account/${api_name}/vm/${remark}
        exit 1
    fi

    clear
    echo "`date` 正在进行Azure创建VM"
    echo
    echo "正在创建VM，请稍后！"
    create_vm_azure
    if [[ $var == "Microsoft.Compute/virtualMachines" ]];
    then
        sleep 30s
    else
        echo $json
        echo "VM创建失败，正在退回，退回需要5分钟时间！"
        return_vm
        rm -rf ${file_path}/account/${api_name}/vm/${remark}
        exit 1
    fi
    
    echo "正在获取网络参数，请稍后！"
    get_ip_azure
    ip=`echo $json | jq -r '.properties.ipAddress'`
    
    
    clear
    echo "`date` 正在进行Azure VM信息"
    echo
    echo "IP：${ip}"
    echo "DDNS：${fqdn}"
    echo "用户名：root"
    echo "密码：Opencloud@Leige"
    echo "密码为固定密码，请立即修改！"
    echo "${ddns}" > ${file_path}/account/${api_name}/vm/${remark}/ddns
    echo "${ip}" > ${file_path}/account/${api_name}/vm/${remark}/ipv4
    azure_loop_script
}

#抓取IP azure
get_ip_azure(){
    json=`curl -s -H "Content-Type: application/json" \
    -H "Authorization: Bearer $az_token" \
    -X GET\
    https://management.azure.com/subscriptions/${az_subid}/resourceGroups/${resource_name}/providers/Microsoft.Network/publicIPAddresses/${resource_name}?api-version=2022-01-01`
}

#azure选择位置
location_azure(){
    json=`cat <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/Azure/location)`
    o=`echo $json| jq ".opencloud | length"`
    
    i=-1
    while ((i < ("${o}" - "1" )))
    do
        ((i++))
        echo -n -e "  ${Green_font_prefix}${i}.${Font_color_suffix}  "
        echo $json | jq -r '.opencloud['${i}'].name'
    done
    read -e -p "请选择你的服务器位置（编号）:" b
        location=`echo $json | jq -r '.opencloud['${b}'].id'`
}

#azure删除机器
del_azure(){
    
    clear
    echo "`date` 正在进行Azure删除vm"
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
    
    clear
    echo "`date` 正在进行Azure删除vm"
    echo
    cd ${file_path}/account/${api_name}/vm
    o=`ls -l|grep -c "^d"`
    a=(`ls ${file_path}/account/${api_name}/vm`)
    i=-1
    echo "已保存的api"
    while ((i < ("${o}" - "1" )))
    do
        ((i++))
        echo -n -e "  ${Green_font_prefix}${i}.${Font_color_suffix}  "
        echo ${a[i]}
    done
    echo
    read -e -p "是否需要删除那台机器？(编号)：" num
    
    
    remark=${a[num]}
    
    appid=`cat ${file_path}/account/${api_name}/appId`
    pasd=`cat ${file_path}/account/${api_name}/password`
    tenant=`cat ${file_path}/account/${api_name}/tenant`
    resource_name=`cat ${file_path}/account/${api_name}/vm/${remark}/resource_name`
    
    azure_token
    subid_user_azure

    curl -s -H "Content-Type: application/json" \
    -H "Authorization: Bearer $az_token" \
    -X DELETE \
    https://management.azure.com/subscriptions/${az_subid}/resourcegroups/${resource_name}?api-version=2021-04-01
    
    echo "删除完成！"
    rm -rf ${file_path}/account/${api_name}/vm/${remark}
    azure_loop_script
}

#az vm换IP
change_ip_azure(){
    
    clear
    echo "`date` 正在进行Azure更换vm ip"
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
    
    clear
    echo "`date` 正在进行Azure更换vm ip"
    echo
    cd ${file_path}/account/${api_name}/vm
    o=`ls -l|grep -c "^d"`
    a=(`ls ${file_path}/account/${api_name}/vm`)
    i=-1
    echo "已保存的api"
    while ((i < ("${o}" - "1" )))
    do
        ((i++))
        echo -n -e "  ${Green_font_prefix}${i}.${Font_color_suffix}  "
        echo ${a[i]}
    done
    echo
    read -e -p "是否需要删除那台机器？(编号)：" num
    
    
    remark=${a[num]}
    
    appid=`cat ${file_path}/account/${api_name}/appId`
    pasd=`cat ${file_path}/account/${api_name}/password`
    tenant=`cat ${file_path}/account/${api_name}/tenant`
    resource_name=`cat ${file_path}/account/${api_name}/vm/${remark}/resource_name`

    public_ip=`cat ${file_path}/account/${api_name}/vm/${remark}/public_ip`
    subnet_id=`cat ${file_path}/account/${api_name}/vm/${remark}/subnet_id`
    location=`cat ${file_path}/account/${api_name}/vm/${remark}/location`

    azure_token
    subid_user_azure

    json=`curl -s -H "Content-Type: application/json" \
    -H "Authorization: Bearer $az_token" \
    -X PUT -d '{
        "properties": {
            "enableAcceleratedNetworking":"False",
            "ipConfigurations": [
            {
                "name": "ipconfig1",
                "properties": {
                    "subnet": {
                        "id": "'${subnet_id}'"
                    }
                }
            }
        ]
    },
        "location":"'${location}'"
}' \
    https://management.azure.com/subscriptions/${az_subid}/resourceGroups/${resource_name}/providers/Microsoft.Network/networkInterfaces/${resource_name}?api-version=2022-01-01`

   json=`curl -s -H "Content-Type: application/json" \
    -H "Authorization: Bearer $az_token" \
    -X PUT -d '{
        "properties": {
            "enableAcceleratedNetworking":"False",
            "ipConfigurations": [
            {
                "name": "ipconfig1",
                "properties": {
                    "publicIPAddress":{
                        "id": "'${public_ip}'"
                    },
                    "subnet": {
                        "id": "'${subnet_id}'"
                    }
                }
            }
        ]
    },
        "location":"'${location}'"
}' \
    https://management.azure.com/subscriptions/${az_subid}/resourceGroups/${resource_name}/providers/Microsoft.Network/networkInterfaces/${resource_name}?api-version=2022-01-01`
    
    json=`curl -s -H "Content-Type: application/json" \
    -H "Authorization: Bearer $az_token" \
    -X GET\
    https://management.azure.com/subscriptions/${az_subid}/resourceGroups/${resource_name}/providers/Microsoft.Network/publicIPAddresses/${resource_name}?api-version=2022-01-01`
    
    ip=`echo $json | jq -r '.properties.ipAddress'`
    echo "更换IP完成，新IP为：${ip}"
    rm -rf ${file_path}/account/${api_name}/vm/${remark}/ipv4
    echo "${ip}" > ${file_path}/account/${api_name}/vm/${remark}/ipv4
    
}

#azure获取token
azure_token(){
    json=`curl -s -X POST \
    -d 'grant_type=client_credentials' \
    -d 'client_id='${appid}'' \
    -d 'client_secret='${pasd}'' \
    -d 'resource=https://management.azure.com' \
    https://login.microsoftonline.com/${tenant}/oauth2/token`
    
    az_token=`echo $json | jq -r '.access_token'`
    
    if [[ $az_tokenr == null ]];
    then
        clear
        echo $json
        echo "获取token失败"
        exit 1
    fi
}

#azure查询subid
subid_user_azure(){
    json=`curl -s -X GET \
    -H 'Authorization:Bearer '${az_token}'' \
    -H 'api-version: 2020-01-01' \
    https://management.azure.com/subscriptions?api-version=2020-01-01`
    az_subid=`echo $json | jq -r '.value[0].subscriptionId'`
    
    if [[ $az_subid == null ]];
    then
        clear
        echo $json
        echo "获取subid失败"
        exit 1
    fi
}

#azure测活
Information_user_azure(){
    
    
    clear
    echo "`date` 正在进行Azure测活"
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
    
    appid=`cat ${file_path}/account/${api_name}/appId`
    pasd=`cat ${file_path}/account/${api_name}/password`
    tenant=`cat ${file_path}/account/${api_name}/tenant`
    
    azure_token
    subid_user_azure

    var1=`echo $json | jq -r '.value[0].displayName'`
    var2=`echo $json | jq -r '.value[0].state'`
    
    clear
    echo -e  "`date` 正在进行Azure测活
API名称：${api_name}
账号类型：${var1}
账号状态：${var2}" 

    azure_loop_script
    
}

#azure循环脚本
azure_loop_script(){
    echo
echo -e "
 ${Green_font_prefix}98.${Font_color_suffix} 返回Azure菜单
 ${Green_font_prefix}99.${Font_color_suffix} 退出脚本"  &&
 

read -p " 请输入数字 :" num
  case "$num" in
    98)
    azure_menu
    ;;
    99)
    exit 1
    ;;
  *)
    clear
    echo -e "${Error}:请输入正确数字 [0-99]（2秒后返回）"
    sleep 2s
    azure_menu
    ;;
  esac
}

#azure菜单
azure_menu() {
    clear
  echo && echo -e "Azure 云服务开机脚本${Red_font_prefix} 开源免费 无加密代码${Font_color_suffix} ${Green_font_prefix}from @openccloud${Font_color_suffix}
项目地址：${Red_font_prefix}https://github.com/LG-leige/open_cloud${Font_color_suffix}
 ${Green_font_prefix}1.${Font_color_suffix} 订阅测活
 ${Green_font_prefix}2.${Font_color_suffix} 更换VM IP
 ${Green_font_prefix}3.${Font_color_suffix} 创建资源组(VM)
 ${Green_font_prefix}4.${Font_color_suffix} 删除资源组
————————————————————————————————————————————————————————————————
 ${Green_font_prefix}5.${Font_color_suffix} 查询已保存api
 ${Green_font_prefix}6.${Font_color_suffix} 添加api
 ${Green_font_prefix}7.${Font_color_suffix} 删除api
————————————————————————————————————————————————————————————————
 ${Green_font_prefix}0.${Font_color_suffix} 退出脚本" &&

read -p " 请输入数字 :" num
  case "$num" in
    1)
    Information_user_azure
    ;;
    2)
    change_ip_azure
    ;;
    3)
    create_azure
    ;;
    4)
    del_azure
    ;;
    5)
    check_api_azure
    azure_loop_script
    ;;
    6)
    create_api_azure
    ;;
    7)
    del_api_azure
    ;;
    0)
    exit 1
    ;;
  *)
    clear
    echo -e "${Error}:请输入正确数字 [0-99]（2秒后返回）"
    sleep 2s
    azure_menu
    ;;
  esac
}

#查询已保存azapi
check_api_azure(){
    clear
    echo "已绑定的api："
    ls ${file_path}/account
}

#创建azapi
create_api_azure(){
    clear
    echo "`date` 正在进行Azure创建api操作"
    echo
    check_api_azure
    
    echho
    read -e -p "请为这个api添加一个备注：" api_name
    read -e -p "输入appId：" appId
    read -e -p "输入password：" password
    read -e -p "输入tenant：" tenant
        
    if [ ! -d "${file_path}/account/${api_name}" ]; then
		mkdir ${file_path}/account/${api_name}
		echo "${appId}" > ${file_path}/account/${api_name}/appId
		echo "${password}" > ${file_path}/account/${api_name}/password
		echo "${tenant}" > ${file_path}/account/${api_name}/tenant
		echo "添加成功！"
	else
		echo "该备注已经存在，请更换其他名字，或者删除原来api"
    fi
    azure_loop_script
}

#删除azapi
del_api_azure(){
    clear
    echo "`date` 正在进行Azure删除api操作"
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
    azure_loop_script
}

#初始化
initialization(){
    mkdir -p ${file_path}
    mkdir -p ${file_path}/account
    mkdir -p ${file_path}/account/default（勿删）
    
    azure_menu
}
initialization