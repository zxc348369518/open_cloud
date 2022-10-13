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
#azure创建vm
create_vm_azure(){
    
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
        offer=`echo $json | jq -r '.opencloud['${b}'].WindowsServer'`
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
    read -e -p "请选择你的服务器位置（编号）:" b
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
    
    if [[ $var != "Updating" ]];
    then
        clear
        echo $json
        echo "虚拟网络创建失败"
        exit 1
    fi
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
    
    if [[ $var != "Succeeded" ]];
    then
        clear
        echo $json
        echo "资源组创建失败"
        exit 1
    fi
}

#azure准备创建vm
create_azure_vm(){
    location_azure
    disk_azure
    vmSize_azure
    
    echo  "正在创建资源组，请稍后！"
    create_resource_azure
    
    mkdir ${file_path}/az/${api_name}/resource/${remark}
    echo "${resource_name}" > ${file_path}/az/${api_name}/resource/${remark}/resource_name
    echo "${location}" > ${file_path}/az/${api_name}/resource/${remark}/location

    
    echo "正在创建虚拟网络，请稍后！"
    create_Network_azure
    
    echo "正在创建虚拟网络-子网，请稍后！"
    create_Network_submets_azure
    
    echo "${subnet_id}" > ${file_path}/az/${api_name}/resource/${remark}/subnet_id
    
    echo "正在创建公网ip，请稍后！"
    create_public_ip_azure
    
    echo "${public_ip}" > ${file_path}/az/${api_name}/resource/${remark}/public_ip
    
    echo "正在创建网络接口，请稍后！"
    create_nic_azure
    
    echo "${vnet_id}" > ${file_path}/az/${api_name}/resource/${remark}/vnet_id
    
    echo "正在创建VM，请稍后！"
    create_vm_azure
    
    echo "正在获取网络参数，请稍后！"
    get_ip_azure
    
    clear
    echo "开机完成！"
    echo "IP：${ip}"
    echo "DDNS：${fqdn}"
    echo "用户名：${resource_name}"
    echo "密码：${resource_name}-"
    azure_loop_script
}

#抓取IP azure
get_ip_azure(){
    json=`curl -s -H "Content-Type: application/json" \
    -H "Authorization: Bearer $az_token" \
    -X GET\
    https://management.azure.com/subscriptions/${az_subid}/resourceGroups/${resource_name}/providers/Microsoft.Network/publicIPAddresses/${resource_name}?api-version=2022-01-01`
    ip=`echo $json | jq -r '.properties.ipAddress'`
}

#azure校验信息
create_azure(){
    clear
    check_api_azure
    read -p "你需要创建vm的api名称:" api_name
    read -p "你需要给这个资源组一个备注:" remark
    
    if [ -d "${file_path}/az/${api_name}/resource/${remark}" ]; then
        echo "这个备注你已经拥有了，需要使用脚本的删除资源组重新尝试"
        exit
    fi
    
    appid=`cat ${file_path}/az/${api_name}/appId`
    pasd=`cat ${file_path}/az/${api_name}/password`
    tenant=`cat ${file_path}/az/${api_name}/tenant`
    
    resource_name=`tr -dc "A-Z-0-9-a-z" < /dev/urandom | head -c 12`
    
    

    clear
    
    echo  "正在获取token，请稍后！"
    azure_token
    
    echo "正在获取subid，请稍后！"
    subid_user_azure
    
    var2=`echo $json | jq -r '.value[0].state'`
    if [[ ${var2} != "Enabled" ]];then
            echo -e  "账号状态存在异常，无法创建"  
            echo "账号状态：${var2}"
            exit
    fi
    create_azure_vm
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
        echo "获取token失败，请把以上信息发送给TG：@LeiGe_233"
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
        echo "获取subid失败，请把以上信息发送给TG：@LeiGe_233"
        exit 1
    fi
}

#azure测活
Information_user_azure(){
    
    cd ${file_path}/az
    o=`ls ${file_path}/az|wc -l`
    i=-1
    while ((i < ("${o}" - "1" )))
    do
        ((i++))
        array=(*)
        var0=`echo ${array[${i}]}`
        
        appid=`cat ${file_path}/az/${var0}/appId`
        pasd=`cat ${file_path}/az/${var0}/password`
        tenant=`cat ${file_path}/az/${var0}/tenant`
        
        azure_token
        subid_user_azure
        
        var1=`echo $json | jq -r '.value[0].displayName'`
        var2=`echo $json | jq -r '.value[0].state'`
        
        echo -e  "API名称：${var0}————账号类型：${var1}————————账号状态：${var2}" 
        
    done
    
    azure_loop_script
    
}

#azure循环脚本
azure_loop_script(){
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

#azure资源组备注
check_api_remark_azure(){
    echo "当前api已绑定备注的有："
    ls ${file_path}/az/${api_name}/resource
}

#azure删除机器
del_azure(){
    
    check_api_azure
    read -p "你需要删除的api名称:" api_name
    check_api_remark_azure
    read -p "你需要删除的备注:" remark
    
    appid=`cat ${file_path}/az/${api_name}/appId`
    pasd=`cat ${file_path}/az/${api_name}/password`
    tenant=`cat ${file_path}/az/${api_name}/tenant`
    resource_name=`cat ${file_path}/az/${api_name}/resource/${remark}/resource_name`
    
    azure_token
    subid_user_azure

    curl -s -H "Content-Type: application/json" \
    -H "Authorization: Bearer $az_token" \
    -X DELETE \
    https://management.azure.com/subscriptions/${az_subid}/resourcegroups/${resource_name}?api-version=2021-04-01
    
    echo "删除完成！"
    rm -rf ${file_path}/az/${api_name}/resource/${remark}
    azure_loop_script
}

#azure菜单
azure_menu() {
    clear
  echo && echo -e "Azure 云服务开机脚本${Red_font_prefix} 开源免费 无加密代码${Font_color_suffix} ${Green_font_prefix}from @openccloud${Font_color_suffix}
项目地址：${Red_font_prefix}https://github.com/LG-leige/open_cloud${Font_color_suffix}
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
    azure_menu
    ;;
  esac
}

#查询已保存azapi
check_api_azure(){
    clear
    echo "已绑定的api："
    ls ${file_path}/az
}

#创建azapi
create_api_azure(){
    check_api_azure

        read -e -p "请为这个api添加一个备注：" api_name
        read -e -p "输入appId：" appId
        read -e -p "输入password：" password
        read -e -p "输入tenant：" tenant
        if test -d "${file_path}/${api_name}"; then
            echo "该备注已经存在，请更换其他名字，或者删除原来api"
        else
            mkdir -p /root/opencloud/az/${api_name}
            echo "${appId}" > ${file_path}/az/${api_name}/appId
            echo "${password}" > ${file_path}/az/${api_name}/password
            echo "${tenant}" > ${file_path}/az/${api_name}/tenant
            mkdir -p ${file_path}/az/${api_name}/resource
            echo "添加成功！"
        fi
    azure_loop_script
}

#删除azapi
del_api_azure(){
    check_api_azure
    
    read -p "你需要删除的api名称:" api_name
    read -e -p "是否需要删除 ${api_name}(默认: N 取消)：" info
    [[ -z ${info} ]] && info="n"
    if [[ ${info} == [Yy] ]]; then
        if test -d "${file_path}/az/${appId}"; then
            rm -rf ${file_path}/az/${api_name}
            echo "删除成功！"
        else
            echo "未在系统中查找到该名称的api"
        fi
        
    fi
    do_loop_script
}

#az vm换IP
change_ip_azure(){
    
    check_api_azure
    read -p "你需要使用的api名称:" api_name
    check_api_remark_azure
    read -p "你需要更换资源组的备注:" remark
    
    appid=`cat ${file_path}/az/${api_name}/appId`
    pasd=`cat ${file_path}/az/${api_name}/password`
    tenant=`cat ${file_path}/az/${api_name}/tenant`
    resource_name=`cat ${file_path}/az/${api_name}/resource/${remark}/resource_name`
    public_ip=`cat ${file_path}/az/${api_name}/resource/${remark}/public_ip`
    subnet_id=`cat ${file_path}/az/${api_name}/resource/${remark}/subnet_id`
    location=`cat ${file_path}/az/${api_name}/resource/${remark}/location`

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
    
}
azure_menu