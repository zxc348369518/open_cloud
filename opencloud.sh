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
#————————————————————Azure（Global Edition）————————————————————
#azure国际创建vm
create_vm_azure_ge(){
    
    json=`curl -s -H "Content-Type: application/json" \
    -H "Authorization: Bearer $az_token" \
    -X PUT -d '{
                "location": "'${location}'",
                "name": "'${resource_name}'",
                "properties": {
                    "hardwareProfile": {
                        "vmSize": "Standard_B1s"
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
                    }
                }
 } '\
    https://management.azure.com/subscriptions/${az_subid}/resourceGroups/${resource_name}/providers/Microsoft.Compute/virtualMachines/${resource_name}?api-version=2021-03-01`
    
    var=`echo $json | jq -r '.type'`
    
    if [[ $var == "Microsoft.Compute/virtualMachines" ]];
    then
        sleep 30s
    else
        clear
        echo $json
        echo "VM创建失败"
        exit 1
    fi
}

#vm镜像
image_azure_ge(){
    json=`cat <(curl -Ls https://github.com/LG-leige/open_cloud/raw/main/Azure/GE/image)`
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
        offer=`echo $json | jq -r '.opencloud['${b}'].WindowsServer'`
}

#VM实例大小
vmSize_azure_ge(){
    json=`cat <(curl -Ls https://github.com/LG-leige/open_cloud/raw/main/Azure/GE/vmSize)`
    o=`echo $json| jq ".opencloud | length"`
    
    i=-1
    while ((i < ("${o}" - "1" )))
    do
        ((i++))
        echo -n -e "  ${Green_font_prefix}${i}.${Font_color_suffix}  "
        echo $json | jq -r '.opencloud['${i}'].name'
    done
    read -e -p "请选择你的服务器位置（编号）:" b
        vmSize=`echo $json | jq -r '.opencloud['${b}'].id'`
}

#VM硬盘
disk_azure_ge(){
    read -e -p "硬盘大小位多少GB(默认: 64GB)：" disk
    [[ -z ${disk} ]] && disk="64"
}

#azure国际创建网络接口
create_nic_azure_ge(){
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
    
    if [[ $var == "Microsoft.Network/networkInterfaces" ]];
    then
        vnet_id=`echo $json | jq -r '.id'`
    else
        clear
        echo $json
        echo "网络接口创建失败"
        exit 1
    fi
}

#azure国际创建公网ip
create_public_ip_azure_ge(){
    

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
    
    if [[ $var == "Microsoft.Network/publicIPAddresses" ]];
    then
        public_ip=`echo $json | jq -r '.id'`
    else
        clear
        echo $json
        echo "公网ip创建失败"
        exit 1
    fi
}

#azure国际创建虚拟网络子网
create_Network_submets_azure_ge(){
    
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
    
    if [[ $var == "Updating" ]];
    then
        subnet_id=`echo $json | jq -r '.id'`
    else
        clear
        echo $json
        echo "虚拟网络-子网创建失败"
        exit 1
    fi
}

#azure国际创建虚拟网络
create_Network_azure_ge(){
    
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
    
    if [[ $var != "Updating" ]];
    then
        clear
        echo $json
        echo "虚拟网络创建失败"
        exit 1
    fi
}

#azure国际创建资源组
create_resource_azure_ge(){
    
    json=`curl -s -H "Content-Type: application/json" \
    -H "Authorization: Bearer $az_token" \
    -X PUT -d '{
      "Location":"'${location}'",
    }' \
    https://management.azure.com/subscriptions/${az_subid}/resourcegroups/${resource_name}?api-version=2021-04-01`
    
    var=`echo $json | jq -r '.properties.provisioningState'`
    
    if [[ $var != "Succeeded" ]];
    then
        clear
        echo $json
        echo "资源组创建失败"
        exit 1
    fi
}

#azure国际准备创建vm
create_azure_ge_vm(){
    
    location_azure_ge
    disk_azure_ge
    vmSize_azure_ge
    
    echo  "正在创建资源组，请稍后！"
    create_resource_azure_ge
    
    mkdir ${file_path}/az/ge/${api_name}/resource/${remark}
    echo "${resource_name}" > ${file_path}/az/ge/${api_name}/resource/${remark}/resource_name
    echo "${location}" > ${file_path}/az/ge/${api_name}/resource/${remark}/location

    
    echo "正在创建虚拟网络，请稍后！"
    create_Network_azure_ge
    
    echo "正在创建虚拟网络-子网，请稍后！"
    create_Network_submets_azure_ge
    
    echo "${subnet_id}" > ${file_path}/az/ge/${api_name}/resource/${remark}/subnet_id
    
    echo "正在创建公网ip，请稍后！"
    create_public_ip_azure_ge
    
    echo "${public_ip}" > ${file_path}/az/ge/${api_name}/resource/${remark}/public_ip
    
    echo "正在创建网络接口，请稍后！"
    create_nic_azure_ge
    
    echo "${vnet_id}" > ${file_path}/az/ge/${api_name}/resource/${remark}/vnet_id
    
    echo "正在创建VM，请稍后！"
    create_vm_azure_ge
    
    echo "正在获取网络参数，请稍后！"
    get_ip_azure_ge
    
    clear
    echo "开机完成！"
    echo "IP：${ip}"
    echo "DDNS：${fqdn}"
    echo "用户名：${resource_name}"
    echo "密码：${resource_name}-"
    azure_ge_loop_script
}

#抓取IP azure国际
get_ip_azure_ge(){
    json=`curl -s -H "Content-Type: application/json" \
    -H "Authorization: Bearer $az_token" \
    -X GET\
    https://management.azure.com/subscriptions/${az_subid}/resourceGroups/${resource_name}/providers/Microsoft.Network/publicIPAddresses/${resource_name}?api-version=2022-01-01`
    ip=`echo $json | jq -r '.properties.ipAddress'`
}

#azure国际校验信息
create_azure_ge(){
    clear
    check_api_azure_ge
    read -p "你需要创建vm的api名称:" api_name
    read -p "你需要给这个资源组一个备注:" remark
    
    if [ -d "${file_path}/az/ge/${api_name}/resource/${remark}" ]; then
        echo "这个备注你已经拥有了，需要使用脚本的删除资源组重新尝试"
        exit
    fi
    
    appid=`cat ${file_path}/az/ge/${api_name}/appId`
    pasd=`cat ${file_path}/az/ge/${api_name}/password`
    tenant=`cat ${file_path}/az/ge/${api_name}/tenant`
    
    resource_name=`tr -dc "A-Z-0-9-a-z" < /dev/urandom | head -c 12`
    
    

    clear
    
    echo  "正在获取token，请稍后！"
    azure_ge_token
    
    echo "正在获取subid，请稍后！"
    subid_user_azure_ge
    
    var2=`echo $json | jq -r '.value[0].state'`
    if [[ ${var2} != "Enabled" ]];then
            echo -e  "账号状态存在异常，无法创建"  
            echo "账号状态：${var2}"
            exit
    fi
    create_azure_ge_vm
}

#azure国际选择位置
location_azure_ge(){
    json=`cat <(curl -Ls https://github.com/LG-leige/open_cloud/raw/main/Azure/GE/location)`
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

#azure国际获取token
azure_ge_token(){
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
        echo "获取token失败，请把以上信息发送给TG：@LeiGe_233"
        exit 1
    fi
}

#azure国际查询subid
subid_user_azure_ge(){
    json=`curl -s -X GET \
    -H 'Authorization:Bearer '${az_token}'' \
    -H 'api-version: 2020-01-01' \
    https://management.azure.com/subscriptions?api-version=2020-01-01`
    az_subid=`echo $json | jq -r '.value[0].subscriptionId'`
    
    if [[ $az_subid == null ]];
    then
        clear
        echo $json
        echo "获取subid失败，请把以上信息发送给TG：@LeiGe_233"
        exit 1
    fi
}

#azure国际测活
Information_user_azure_ge(){
    
    cd ${file_path}/az/ge
    o=`ls ${file_path}/az/ge|wc -l`
    i=-1
    while ((i < ("${o}" - "1" )))
    do
        ((i++))
        array=(*)
        var0=`echo ${array[${i}]}`
        
        appid=`cat ${file_path}/az/ge/${var0}/appId`
        pasd=`cat ${file_path}/az/ge/${var0}/password`
        tenant=`cat ${file_path}/az/ge/${var0}/tenant`
        
        azure_ge_token
        subid_user_azure_ge
        
        var1=`echo $json | jq -r '.value[0].displayName'`
        var2=`echo $json | jq -r '.value[0].state'`
        
        echo -e  "API名称：${var0}————账号类型：${var1}————————账号状态：${var2}" 
        
    done
    
    azure_ge_loop_script
    
}

#azure国际循环脚本
azure_ge_loop_script(){
echo -e "
 ${Green_font_prefix}98.${Font_color_suffix} 返回azure（Global Edition）菜单
 ${Green_font_prefix}99.${Font_color_suffix} 退出脚本"  &&
 

read -p " 请输入数字 :" num
  case "$num" in
    98)
    azure_ge_menu
    ;;
    99)
    exit 1
    ;;
  *)
    clear
    echo -e "${Error}:请输入正确数字 [0-99]（2秒后返回）"
    sleep 2s
    azure_ge_menu
    ;;
  esac
}

#azure国际资源组备注
check_api_remark_azure_ge(){
    echo "当前api已绑定备注的有："
    ls ${file_path}/az/ge/${api_name}/resource
}

#azure国际删除机器
del_azure_ge(){
    
    check_api_azure_ge
    read -p "你需要删除的api名称:" api_name
    check_api_remark_azure_ge
    read -p "你需要删除的备注:" remark
    
    appid=`cat ${file_path}/az/ge/${api_name}/appId`
    pasd=`cat ${file_path}/az/ge/${api_name}/password`
    tenant=`cat ${file_path}/az/ge/${api_name}/tenant`
    resource_name=`cat ${file_path}/az/ge/${api_name}/resource/${remark}/resource_name`
    
    azure_ge_token
    subid_user_azure_ge

    curl -s -H "Content-Type: application/json" \
    -H "Authorization: Bearer $az_token" \
    -X DELETE \
    https://management.azure.com/subscriptions/${az_subid}/resourcegroups/${resource_name}?api-version=2021-04-01
    
    echo "删除完成！"
    rm -rf ${file_path}/az/ge/${api_name}/resource/${remark}
    azure_ge_loop_script
}

#azure国际菜单
azure_ge_menu() {
    clear
    echo && echo -e " Azure(Global Edition) 开机脚本${Red_font_prefix} 开源免费 无加密代码${Font_color_suffix} ${Green_font_prefix}from @openccloud @LeiGe_233${Font_color_suffix}
 ${Green_font_prefix}1.${Font_color_suffix} 一键测活
 ${Green_font_prefix}2.${Font_color_suffix} 更换VM IP
 ${Green_font_prefix}3.${Font_color_suffix} 创建资源组(VM)
 ${Green_font_prefix}4.${Font_color_suffix} 删除资源组
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
    Information_user_azure_ge
    ;;
    2)
    change_ip_azure_ge
    ;;
    3)
    create_azure_ge
    ;;
    4)
    del_azure_ge
    ;;
    5)
    check_api_azure_ge
    azure_ge_loop_script
    ;;
    6)
    create_api_azure_ge
    ;;
    7)
    del_api_azure_ge
    ;;
    98)
    start_menu
    ;;
    99)
    exit 1
    ;;
  *)
    clear
    echo -e "${Error}:请输入正确数字 [0-99]（2秒后返回）"
    sleep 2s
    azure_ge_menu
    ;;
  esac
}

#查询已保存az国际api
check_api_azure_ge(){
    clear
    echo "已绑定的api："
    ls ${file_path}/az/ge
}

#创建az国际api
create_api_azure_ge(){
    check_api_azure_ge

        read -e -p "请为这个api添加一个备注：" api_name
        read -e -p "输入appId：" appId
        read -e -p "输入password：" password
        read -e -p "输入tenant：" tenant
        if test -d "${file_path}/ge/${api_name}"; then
            echo "该备注已经存在，请更换其他名字，或者删除原来api"
        else
            mkdir -p /root/opencloud/az/ge/${api_name}
            echo "${appId}" > ${file_path}/az/ge/${api_name}/appId
            echo "${password}" > ${file_path}/az/ge/${api_name}/password
            echo "${tenant}" > ${file_path}/az/ge/${api_name}/tenant
            mkdir -p ${file_path}/az/ge/${api_name}/resource
            echo "添加成功！"
        fi
    azure_ge_loop_script
}

#删除az国际api
del_api_azure_ge(){
    check_api_azure_ge
    
    read -p "你需要删除的api名称:" api_name
    read -e -p "是否需要删除 ${api_name}(默认: N 取消)：" info
    [[ -z ${info} ]] && info="n"
    if [[ ${info} == [Yy] ]]; then
        if test -d "${file_path}/az/ge/${appId}"; then
            rm -rf ${file_path}/az/ge/${api_name}
            echo "删除成功！"
        else
            echo "未在系统中查找到该名称的api"
        fi
        
    fi
    do_loop_script
}

#az国际 vm换IP
change_ip_azure_ge(){
    
    check_api_azure_ge
    read -p "你需要使用的api名称:" api_name
    check_api_remark_azure_ge
    read -p "你需要更换资源组的备注:" remark
    
    appid=`cat ${file_path}/az/ge/${api_name}/appId`
    pasd=`cat ${file_path}/az/ge/${api_name}/password`
    tenant=`cat ${file_path}/az/ge/${api_name}/tenant`
    resource_name=`cat ${file_path}/az/ge/${api_name}/resource/${remark}/resource_name`
    public_ip=`cat ${file_path}/az/ge/${api_name}/resource/${remark}/public_ip`
    subnet_id=`cat ${file_path}/az/ge/${api_name}/resource/${remark}/subnet_id`
    location=`cat ${file_path}/az/ge/${api_name}/resource/${remark}/location`

    azure_ge_token
    subid_user_azure_ge

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
    
}

#————————————————————vultr————————————————————
#vultr菜单
vultr_ge_menu() {
    clear
    echo && echo -e " vultr 开机脚本${Red_font_prefix} 开源免费 无加密代码${Font_color_suffix} ${Green_font_prefix}from @openccloud @LeiGe_233${Font_color_suffix}
 ${Green_font_prefix}1.${Font_color_suffix} 查询账号信息
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
    Information_user_azure_ge
    ;;
    2)
    Information_vps_linode
    ;;
    3)
    create_linode
    ;;
    4)
    del_linode
    ;;
    5)
    check_api_vultr
    vultr_loop_script
    ;;
    6)
    create_api_vultr
    ;;
    7)
    del_api_vultr
    ;;
    98)
    start_menu
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

#vultr循环脚本
vultr_loop_script(){
echo -e "
 ${Green_font_prefix}98.${Font_color_suffix} 返回Vultr菜单
 ${Green_font_prefix}99.${Font_color_suffix} 退出脚本"  &&
 

read -p " 请输入数字 :" num
  case "$num" in
    98)
    vultr_ge_menu
    ;;
    99)
    exit 1
    ;;
  *)
    clear
    echo -e "${Error}:请输入正确数字 [0-99]（2秒后返回）"
    sleep 2s
    vultr_ge_menu
    ;;
  esac
}

#查询已保存vultr
check_api_vultr(){
    clear
    cd ${file_path}/vu
    array=(*)
    echo "已绑定的api："$array
}

#创建vultr api
create_api_vultr(){
    check_api_vultr
    
    read -e -p "是否需要添加api(默认: N 取消)：" info
    [[ -z ${info} ]] && info="n"
    if [[ ${info} == [Yy] ]]; then
        read -e -p "请为这个api添加一个备注：" api_name
        read -e -p "输入api：" VULTR_API_KEY
        if test -f "${file_path}/vu/${api_name}"; then
            echo "该备注已经存在，请更换其他名字，或者删除原来api"
        else
            echo "${VULTR_API_KEY}" > ${file_path}/vu/${api_name}
            echo "添加成功！"
        fi
    fi
    vultr_loop_script
}

#删除vultr api
del_api_vultr(){
    check_api_vultr
    read -p "你需要删除的api名称:" api_name
    read -e -p "是否需要删除 ${api_name}(默认: N 取消)：" info
    [[ -z ${info} ]] && info="n"
    if [[ ${info} == [Yy] ]]; then
        read -e -p "请输入需要删除api的名字：" api_name
        if test -f "${file_path}/vu/${api_name}"; then
            rm -rf ${file_path}/vu/${api_name}
            echo "删除成功！"
        else
            echo "未在系统中查找到该名称的api"
        fi
    fi
    vultr_loop_script
}

#————————————————————Digitalocean————————————————————
#do循环脚本
do_loop_script(){
echo -e "
 ${Green_font_prefix}98.${Font_color_suffix} 返回do菜单
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
    echo API名称：${api_name}
    i=-1
    while ((i < ("${total}" - "1" )))
    do
        ((i++))
        echo -n  "机器ID："
        echo  $json | jq '.droplets['${i}'].id'
        echo -n  "机器名字："
        echo  $json | jq '.droplets['${i}'].name'
        echo -n  "机器IP："
        echo  $json | jq '.droplets['${i}'].networks.v4[0].ip_address'
    done
    do_loop_script
}

#do一键测活
Information_user_do() {
    
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
    json=`cat <(curl -Ls https://github.com/LG-leige/open_cloud/raw/main/digitalocean/region)`
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
    json=`cat <(curl -Ls https://github.com/LG-leige/open_cloud/raw/main/digitalocean/size)`
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
    json=`cat <(curl -Ls https://github.com/LG-leige/open_cloud/raw/main/digitalocean/image)`
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
    read -p " 请输入机器名字:" name
    
    region_do
    size_do
    image_do

    clear
    
     echo -e "请确认？ [Y/n]
机器名字：${name}\n服务器位置：${region}\n服务器规格：${size}\n机器系统: ${image}"
        read -e -p "(默认: N 取消):" state
        [[ -z ${state} ]] && state="n"
        if [[ ${state} == [Yy] ]]; then

             json=`curl -s -X POST \
             -H "Content-Type: application/json" \
             -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
             -d '{
                "name":"'${name}'",
                "region":"'${region}'",
                "size":"'${size}'",
                "image":"'${image}'",
                "backups":"false",
                "ipv6":"true"
             }' \
             https://api.digitalocean.com/v2/droplets`
  
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
        echo -e "IP地址为：${ipv4}\n机器的登录密码需要使用邮件内的passwd！\n如果有大佬知道怎么样可以自定义passwd可以联系我"
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
    echo API名称：${api_name}
    i=-1
    while ((i < ("${total}" - "1" )))
    do
        ((i++))
        echo
        echo -n  "机器ID："
        echo  $json | jq '.droplets['${i}'].id'
        echo -n  "机器名字："
        echo  $json | jq '.droplets['${i}'].name'
        echo -n  "机器IP："
        echo  $json | jq '.droplets['${i}'].networks.v4[0].ip_address'
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
    echo && echo -e " Digitalocean 开机脚本${Red_font_prefix} 开源免费 无加密代码${Font_color_suffix} ${Green_font_prefix}from @openccloud @LeiGe_233${Font_color_suffix}
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
    start_menu
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
    
    read -e -p "是否需要添加api(默认: N 取消)：" info
    [[ -z ${info} ]] && info="n"
    if [[ ${info} == [Yy] ]]; then
        read -e -p "请为这个api添加一个备注：" api_name
        read -e -p "输入api：" api_key
        if test -f "${file_path}/do/${api_name}"; then
            echo "该备注已经存在，请更换其他名字，或者删除原来api"
        else
            echo "${api_key}" > ${file_path}/do/${api_name}
            echo "添加成功！"
        fi
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

#————————————————————Linode————————————————————
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
    echo && echo -e " Linode 开机脚本${Red_font_prefix} 开源免费 无加密代码${Font_color_suffix} ${Green_font_prefix}from @openccloud @LeiGe_233${Font_color_suffix}
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
    start_menu
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
    ls ${file_path}/linode
    echo "已绑定的api："$array
}

#创建linode api
create_api_linode(){
    check_api_linode
    read -e -p "是否需要添加api(默认: N 取消)：" info
    [[ -z ${info} ]] && info="n"
    if [[ ${info} == [Yy] ]]; then
        read -e -p "请为这个api添加一个备注：" api_name
        read -e -p "输入api：" api_key
        if test -f "${file_path}/linode/api_name"; then
            echo "该备注已经存在，请更换其他名字，或者删除原来api"
        else
            echo "${api_key}" > ${file_path}/linode/${api_name}
            echo "添加成功！"
        fi
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
    total=`echo $json | jq -r '.results'`
    echo "查询结果为空代表 账号下没有任何机器 或者 账号已经失效了"
    i=-1
    while ((i < ("${total}" - "1" )))
    do
        ((i++))
        echo "机器ID："
        echo $json | jq '.data['${i}'].id'
        echo "机器ipv4："
        echo $json | jq '.data['${i}'].ipv4'
        echo -e "\n"
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
    json=`cat <(curl -Ls https://github.com/LG-leige/open_cloud/raw/main/linode/region)`
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
    json=`cat <(curl -Ls https://github.com/LG-leige/open_cloud/raw/main/linode/image)`
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
    json=`cat <(curl -Ls https://github.com/LG-leige/open_cloud/raw/main/linode/size)`
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
    
    pasd=`date +%s | sha256sum | base64 | head -c 12 ; echo`
    
    json=`curl -s -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -X POST -d '{
      "swap_size": 512,
      "image": "'${image}'",
      "root_pass": "'${pasd}'",
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
        echo -e "IP地址为：${ipv4}\n开机密码统一为：${pasd}\n请立即修改密码！"
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

#————————————————————其他————————————————————
#初始化
initialization(){
    mkdir -p /root/opencloud
    mkdir -p /root/opencloud/do
    mkdir -p /root/opencloud/linode
    mkdir -p /root/opencloud/az
    mkdir -p /root/opencloud/aws
    mkdir -p /root/opencloud/vu
    mkdir -p /root/opencloud/az/ge
    
    start_menu
}

#启动菜单
start_menu() {
  clear
  echo && echo -e " 云服务开机脚本${Red_font_prefix} 开源免费 无加密代码${Font_color_suffix} ${Green_font_prefix}from @openccloud @LeiGe_233${Font_color_suffix}
 ${Green_font_prefix}1.${Font_color_suffix} Digitalocean 
 ${Green_font_prefix}2.${Font_color_suffix} Linode
 ${Green_font_prefix}3.${Font_color_suffix} Azure (Global Edition)
————————————————————————————————————————————————————————————————
 ${Green_font_prefix}x.${Font_color_suffix} aws（未开发）
 ${Green_font_prefix}x.${Font_color_suffix} vultr（未开发，没有API）
————————————————————————————————————————————————————————————————
 ${Green_font_prefix}x.${Font_color_suffix} Azure 世纪互联（未开发，没有API）
 ${Green_font_prefix}x.${Font_color_suffix} gcp（未开发，没有API）
 ${Green_font_prefix}x.${Font_color_suffix} 甲骨文（未开发，没有API）
————————————————————————————————————————————————————————————————
 ${Green_font_prefix}99.${Font_color_suffix} 退出脚本" &&

read -p " 请输入数字 :" num
  case "$num" in
    1)
    digitalocean_menu
    ;;
    2)
    linode_menu
    ;;
    3)
    azure_ge_menu
    ;;
    99)
    exit 1
    ;;
  *)
    clear
    echo -e "${Error}:请输入正确数字 [0-99]（2秒后返回）"
    sleep 2s
    start_menu
    ;;
  esac
}
initialization
