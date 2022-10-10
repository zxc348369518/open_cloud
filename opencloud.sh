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
create_vm_azure_gp(){
    
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
image_azure_gp(){
    echo -e " ${Green_font_prefix}1.${Font_color_suffix} Debian_9
 ${Green_font_prefix}2.${Font_color_suffix} Debian_10_gen2
 ${Green_font_prefix}3.${Font_color_suffix} Debian_11_gen2
 ${Green_font_prefix}4.${Font_color_suffix} Ubuntu 16.04_gen2
 ${Green_font_prefix}5.${Font_color_suffix} Ubuntu_18_04_gen2
 ${Green_font_prefix}6.${Font_color_suffix} Ubuntu_20_04_gen2
 ${Green_font_prefix}7.${Font_color_suffix} Centos 7.9_gen2
 ${Green_font_prefix}8.${Font_color_suffix} Centos 8.5_gen2
 ${Green_font_prefix}9.${Font_color_suffix} Windows Datacenter 2022
 ${Green_font_prefix}10.${Font_color_suffix} Windows Datacenter 2019
 ${Green_font_prefix}11.${Font_color_suffix} Windows Datacenter 2016
 ${Green_font_prefix}12.${Font_color_suffix} Windows Datacenter 2012
 ${Green_font_prefix}13.${Font_color_suffix} Windows 10 21H2_gen2
 ${Green_font_prefix}13.${Font_color_suffix} Windows 11 21H2"
    read -e -p "请选择你的VM系统:" sku
    if [[ ${sku} == "1" ]]; then
        sku="9"
        publisher="credativ"
        version="latest"
        offer="Debian"
        create_azure_gp_vm
    elif [[ ${sku} == "2" ]]; then
        sku="10-gen2"
        publisher="Debian"
        version="latest"
        offer="debian-10"
        create_azure_gp_vm
    elif [[ ${sku} == "3" ]]; then
        sku="11-gen2"
        publisher="Debian"
        version="latest"
        offer="debian-11"
        create_azure_gp_vm
    elif [[ ${sku} == "4" ]]; then
        sku="16_04-lts-gen2"
        publisher="Canonical"
        version="latest"
        offer="UbuntuServer"
        create_azure_gp_vm
    elif [[ ${sku} == "5" ]]; then
        sku="18_04-lts-gen2"
        publisher="Canonical"
        version="latest"
        offer="UbuntuServer"
    elif [[ ${sku} == "6" ]]; then
        sku="20_04-lts-gen2"
        publisher="Canonical"
        version="latest"
        offer="0001-com-ubuntu-server-focal"
        create_azure_gp_vm
    elif [[ ${sku} == "7" ]]; then
        sku="7_9-gen2"
        publisher="OpenLogic"
        version="latest"
        offer="CentOS"
        create_azure_gp_vm
    elif [[ ${sku} == "8" ]]; then
        sku="8_5-gen2"
        publisher="OpenLogic"
        version="latest"
        offer="CentOS"
        create_azure_gp_vm
    elif [[ ${sku} == "9" ]]; then
        sku="2022-Datacenter-smalldisk"
        publisher="MicrosoftWindowsServer"
        version="latest"
        offer="WindowsServer"
        create_azure_gp_vm
    elif [[ ${sku} == "10" ]]; then
        sku="2019-Datacenter-smalldisk"
        publisher="MicrosoftWindowsServer"
        version="latest"
        offer="WindowsServer"
        create_azure_gp_vm
    elif [[ ${sku} == "11" ]]; then
        sku="2016-Datacenter-smalldisk"
        publisher="MicrosoftWindowsServer"
        version="latest"
        offer="WindowsServer"
        create_azure_gp_vm
    elif [[ ${sku} == "13" ]]; then
        sku="2012-Datacenter-smalldisk"
        publisher="MicrosoftWindowsServer"
        version="latest"
        offer="WindowsServer"
        create_azure_gp_vm
    elif [[ ${sku} == "13" ]]; then
        sku="win10-21h2-pro-zh-cn-g2"
        publisher="MicrosoftWindowsDesktop"
        version="latest"
        offer="Windows-10"
    elif [[ ${sku} == "14" ]]; then
        sku="win11-21h2-pro-zh-cn"
        publisher="MicrosoftWindowsDesktop"
        version="latest"
        offer="Windows-11"
        create_azure_gp_vm
    else
        echo "输入错误"
        azure_ge_loop_script
    fi
}

#VM实例大小
mSize_azure_gp(){
    echo -e " ${Green_font_prefix}1.${Font_color_suffix}  b系列
 ${Green_font_prefix}2.${Font_color_suffix}  f系列
 ${Green_font_prefix}3.${Font_color_suffix}  d系列"
    read -e -p "请选择你的VM大小系列:" vmSize
    if [[ ${vmSize} == "1" ]]; then
        b_vmSize_azure_gp
    elif [[ ${vmSize} == "2" ]]; then
        f_vmSize_azure_gp
    elif [[ ${vmSize} == "3" ]]; then
        d_vmSize_azure_gp
    else
        echo "输入错误"
        azure_ge_loop_script
    fi
}

#f系列VM实例大小
f_vmSize_azure_gp(){
    echo -e " ${Green_font_prefix}1.${Font_color_suffix}  Standard_F1s（1C2G）
 ${Green_font_prefix}2.${Font_color_suffix}  Standard_F2s_v2（2C4G）
 ${Green_font_prefix}3.${Font_color_suffix}  Standard_F4s_v2（4C8G）
 ${Green_font_prefix}4.${Font_color_suffix}  Standard_F8s_v2（8C16G）"
    read -e -p "请选择你的VM大小系列:" vmSize
    if [[ ${vmSize} == "1" ]]; then
        vmSize="Standard_F1s"
        image_azure_gp
    elif [[ ${vmSize} == "2" ]]; then
        vmSize="Standard_F2s_v2"
        image_azure_gp
    elif [[ ${vmSize} == "3" ]]; then
        vmSize="Standard_F4s_v2"
        image_azure_gp
    elif [[ ${vmSize} == "4" ]]; then
        vmSize="Standard_F8s_v2"
        image_azure_gp

    else
        echo "输入错误"
        azure_ge_loop_script
    fi
}

#d系列VM实例大小
d_vmSize_azure_gp(){
    echo -e " ${Green_font_prefix}1.${Font_color_suffix}  Standard_DS1_v2（1C3.5G）
 ${Green_font_prefix}2.${Font_color_suffix}  Standard_DS2_v2（2C7G）
 ${Green_font_prefix}3.${Font_color_suffix}  Standard_DS3_v2（1C14G）"
    read -e -p "请选择你的VM大小系列:" vmSize
    if [[ ${vmSize} == "1" ]]; then
        vmSize="Standard_DS1_v2"
        image_azure_gp
    elif [[ ${vmSize} == "2" ]]; then
        vmSize="Standard_B1s"
        image_azure_gp
    elif [[ ${vmSize} == "3" ]]; then
        vmSize="Standard_DS3_v2"
        image_azure_gp
    else
        echo "输入错误"
        azure_ge_loop_script
    fi
}

#b系列VM实例大小
b_vmSize_azure_gp(){
    echo -e " ${Green_font_prefix}1.${Font_color_suffix}  Standard_B1ls（1C0.5G）
 ${Green_font_prefix}2.${Font_color_suffix}  Standard_B1s（1C1G）
 ${Green_font_prefix}3.${Font_color_suffix}  Standard_B1ms（1C2G）
 ${Green_font_prefix}4.${Font_color_suffix}  Standard_B2s（2C4G）
 ${Green_font_prefix}5.${Font_color_suffix}  Standard_B2ms（2C8G）
 ${Green_font_prefix}6.${Font_color_suffix}  Standard_B4ms（4C16G）"
    read -e -p "请选择你的VM大小系列:" vmSize
    if [[ ${vmSize} == "1" ]]; then
        vmSize="Standard_B1ls"
        image_azure_gp
    elif [[ ${vmSize} == "2" ]]; then
        vmSize="Standard_B1s"
        image_azure_gp
    elif [[ ${vmSize} == "3" ]]; then
        vmSize="Standard_B1ms"
        image_azure_gp
    elif [[ ${vmSize} == "4" ]]; then
        vmSize="Standard_B2s"
        image_azure_gp
    elif [[ ${vmSize} == "5" ]]; then
        vmSize="Standard_B2ms"
        image_azure_gp
    elif [[ ${vmSize} == "6" ]]; then
        vmSize=""
    else
        echo "输入错误"
        azure_ge_loop_script
    fi
}

#VM硬盘
disk_azure_gp(){
    read -e -p "硬盘大小位多少GB(默认: 64GB)：" disk
    [[ -z ${disk} ]] && disk="64"
    mSize_azure_gp
}

#azure国际创建网络接口
create_nic_azure_gp(){
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
create_public_ip_azure_gp(){
    

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
create_Network_submets_azure_gp(){
    
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
create_Network_azure_gp(){
    
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
create_resource_azure_gp(){
    
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

#azure国际创建vm
create_azure_gp_vm(){
    echo  "正在创建资源组，请稍后！"
    create_resource_azure_gp
    
    mkdir ${file_path}/az/ge/${api_name}/resource/${remark}
    echo "${resource_name}" > ${file_path}/az/ge/${api_name}/resource/${remark}/resource_name
    echo "${location}" > ${file_path}/az/ge/${api_name}/resource/${remark}/location

    
    echo "正在创建虚拟网络，请稍后！"
    create_Network_azure_gp
    
    echo "正在创建虚拟网络-子网，请稍后！"
    create_Network_submets_azure_gp
    
    echo "${subnet_id}" > ${file_path}/az/ge/${api_name}/resource/${remark}/subnet_id
    
    echo "正在创建公网ip，请稍后！"
    create_public_ip_azure_gp
    
    echo "${public_ip}" > ${file_path}/az/ge/${api_name}/resource/${remark}/public_ip
    
    echo "正在创建网络接口，请稍后！"
    create_nic_azure_gp
    
    echo "${vnet_id}" > ${file_path}/az/ge/${api_name}/resource/${remark}/vnet_id
    
    echo "正在创建VM，请稍后！"
    create_vm_azure_gp
    
    echo "正在获取网络参数，请稍后！"
    get_ip_azure_gp
    
    clear
    echo "开机完成！"
    echo "IP：${ip}"
    echo "DDNS：${fqdn}"
    echo "用户名：${resource_name}"
    echo "密码：${resource_name}-"
    azure_ge_loop_script
}

#抓取IP azure国际
get_ip_azure_gp(){
    json=`curl -s -H "Content-Type: application/json" \
    -H "Authorization: Bearer $az_token" \
    -X GET\
    https://management.azure.com/subscriptions/${az_subid}/resourceGroups/${resource_name}/providers/Microsoft.Network/publicIPAddresses/${resource_name}?api-version=2022-01-01`
    ip=`echo $json | jq -r '.properties.ipAddress'`
}

#azure国际校验信息
create_azure_gp(){
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
    subid_user_azure_gp
    
    var2=`echo $json | jq -r '.value[0].state'`
    if [[ ${var2} != "Enabled" ]];then
            echo -e  "账号状态存在异常，无法创建"  
            echo "账号状态：${var2}"
            exit
    fi
    location_azure_gp
}

#azure国际选择位置
location_azure_gp(){
    echo -e " ${Green_font_prefix}1.${Font_color_suffix}  (US) West US 3【美国西部 3】
 ${Green_font_prefix}2.${Font_color_suffix}  (Europe) UK South【英国南部】
 ${Green_font_prefix}3.${Font_color_suffix}  (US) South Central US【美国中南部】
 ${Green_font_prefix}4.${Font_color_suffix}  (Europe) West Europe【西欧】
 ${Green_font_prefix}5.${Font_color_suffix}  (Asia Pacific) Central India【印度中部】
 ${Green_font_prefix}6.${Font_color_suffix}  (Asia Pacific) Japan East【日本东部】
 ${Green_font_prefix}7.${Font_color_suffix}  (Asia Pacific) Korea Central【韩国中部】
 ${Green_font_prefix}8.${Font_color_suffix}  (Europe) France Central【法国中部】
 ${Green_font_prefix}9.${Font_color_suffix}  (Europe) Norway East【挪威东部】
 ${Green_font_prefix}10.${Font_color_suffix}  (South America) Brazil South【巴西南部】
 ${Green_font_prefix}11.${Font_color_suffix}  (Asia Pacific) East Asia【香港】"
    read -e -p "请选择你的服务器位置:" location
    if [[ ${location} == "1" ]]; then
        location="westus3"
        disk_azure_gp
    elif [[ ${location} == "2" ]]; then
        location="uksouth"
        disk_azure_gp
    elif [[ ${location} == "3" ]]; then
        location="westeurope"
        disk_azure_gp
    elif [[ ${location} == "4" ]]; then
        location="centralindia"
        disk_azure_gp
    elif [[ ${location} == "5" ]]; then
        location="japaneast"
        disk_azure_gp
    elif [[ ${location} == "6" ]]; then
        location="koreacentral"
        disk_azure_gp
    elif [[ ${location} == "7" ]]; then
        location="koreacentral"
        disk_azure_gp
    elif [[ ${location} == "8" ]]; then
        location="francecentral"
        disk_azure_gp
    elif [[ ${location} == "9" ]]; then
        location="norwayeast"
        disk_azure_gp
    elif [[ ${location} == "10" ]]; then
        location="brazilsouth"
        disk_azure_gp
    elif [[ ${location} == "11" ]]; then
        location="eastasia"
        disk_azure_gp
    else
        echo "输入错误"
        azure_ge_loop_script
    fi
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
subid_user_azure_gp(){
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
Information_user_azure_gp(){
    
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
        subid_user_azure_gp
        
        var1=`echo $json | jq -r '.value[0].displayName'`
        var2=`echo $json | jq -r '.value[0].state'`
        
        if [[ ${var2} == "Enabled" ]];then
            echo -e  "API名称：${var0}————账号类型：${var1}————账号状态：Enabled" 
        else
            echo -e  "API名称：${var0}————账号类型：${var1}————————账号状态：${var2}" 
        fi
        
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
    subid_user_azure_gp

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
    Information_user_azure_gp
    ;;
    2)
    change_ip_azure_ge
    ;;
    3)
    create_azure_gp
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
    subid_user_azure_gp

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
    Information_user_azure_gp
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
    
    i=-1
    while ((i < ("${total}" - "1" )))
    do
        ((i++))
        echo
        echo -n "机器ID："
        echo $json | jq '.droplets['${i}'].id'
        echo -n "机器名字："
        echo $json | jq '.droplets['${i}'].name'
        echo -n "机器IP："
        echo -n $json | jq '.droplets['${i}'].networks.v4[0].ip_address'
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
        
        if [[ ${var3} == "active" ]];then
            echo -e  "API名称：${var0}————电子邮箱：${var2}————账号配额：${var1}————账号余额：${var4}————账号状态：${var3}" 
        else
            echo -e  "API名称：${var0}————电子邮箱：${var2}————账号状态：Disabled" 
        fi
        
    done
    do_loop_script
}

#do服务器位置
region_do(){
    echo -e " ${Green_font_prefix}1.${Font_color_suffix}  纽约3
 ${Green_font_prefix}2.${Font_color_suffix}  纽约1 
 ${Green_font_prefix}3.${Font_color_suffix}  新加坡1
 ${Green_font_prefix}4.${Font_color_suffix}  阿姆斯特丹3
 ${Green_font_prefix}5.${Font_color_suffix}  法兰克福1
 ${Green_font_prefix}6.${Font_color_suffix}  加拿大1
 ${Green_font_prefix}7.${Font_color_suffix}  印度
 ${Green_font_prefix}8.${Font_color_suffix}  加利福尼亚3
 ${Green_font_prefix}9.${Font_color_suffix}  悉尼"
    read -e -p "请选择你的服务器位置:" region
    if [[ ${region} == "1" ]]; then
        region="nyc3"
    elif [[ ${region} == "2" ]]; then
        region="nyc1"
    elif [[ ${region} == "3" ]]; then
        region="sgp1"
    elif [[ ${region} == "4" ]]; then
        region="ams3"
    elif [[ ${region} == "5" ]]; then
        region="fra1"
    elif [[ ${region} == "6" ]]; then
        region="tor1"
    elif [[ ${region} == "7" ]]; then
        region="blr1"
    elif [[ ${region} == "8" ]]; then
        region="sfo3"
    elif [[ ${region} == "9" ]]; then
        region="syd1"
    else
        echo "输入错误"
        do_loop_script
    fi
}

#do服务器大小
size_do(){
    echo -e " ${Green_font_prefix}1.${Font_color_suffix}  s-1vcpu-512mb-10gb
 ${Green_font_prefix}2.${Font_color_suffix}  s-1vcpu-1gb 
 ${Green_font_prefix}3.${Font_color_suffix}  s-1vcpu-1gb-amd
 ${Green_font_prefix}4.${Font_color_suffix}  s-1vcpu-1gb-intel
 ${Green_font_prefix}5.${Font_color_suffix}  s-1vcpu-2gb
 ${Green_font_prefix}6.${Font_color_suffix}  s-1vcpu-2gb-amd
 ${Green_font_prefix}7.${Font_color_suffix}  s-1vcpu-2gb-intel
 ${Green_font_prefix}8.${Font_color_suffix}  s-2vcpu-2gb
 ${Green_font_prefix}9.${Font_color_suffix}  s-2vcpu-2gb-amd
 ${Green_font_prefix}10.${Font_color_suffix}  s-2vcpu-2gb-intel
 ${Green_font_prefix}11.${Font_color_suffix}  s-2vcpu-4gb
 ${Green_font_prefix}12.${Font_color_suffix}  s-2vcpu-4gb-amd
 ${Green_font_prefix}13.${Font_color_suffix}  s-2vcpu-4gb-intel"
    read -p " 请输入机器规格:" size
    if [[ ${size} == "1" ]]; then
        size="s-1vcpu-512mb-10gb"
    elif [[ ${size} == "2" ]]; then
        size="s-1vcpu-1gb"
    elif [[ ${size} == "3" ]]; then
        size="s-1vcpu-1gb-amd"
    elif [[ ${size} == "4" ]]; then
        size="s-1vcpu-1gb-intel"
    elif [[ ${size} == "5" ]]; then
        size="s-1vcpu-2gb"
    elif [[ ${size} == "6" ]]; then
        size="s-1vcpu-2gb-amd"
    elif [[ ${size} == "7" ]]; then
        size="s-1vcpu-2gb-intel"
    elif [[ ${size} == "8" ]]; then
        size="s-2vcpu-2gb"
    elif [[ ${size} == "9" ]]; then
        size="s-2vcpu-2gb-amd"
    elif [[ ${size} == "10" ]]; then
        size="s-2vcpu-2gb-intel"
    elif [[ ${size} == "11" ]]; then
        size="s-2vcpu-4gb"
    elif [[ ${size} == "12" ]]; then
        size="s-2vcpu-4gb-amd"
    elif [[ ${size} == "13" ]]; then    
        size="s-2vcpu-4gb-intel"
    else
        echo "输入错误"
        do_loop_script
    fi
}

#do服务器镜像
image_do(){
    echo -e " ${Green_font_prefix}1.${Font_color_suffix}  centos-7-x64
 ${Green_font_prefix}2.${Font_color_suffix}  centos-stream-8-x64
 ${Green_font_prefix}3.${Font_color_suffix}  debian-11-x64
 ${Green_font_prefix}4.${Font_color_suffix}  debian-10-x64
 ${Green_font_prefix}5.${Font_color_suffix}  ubuntu-22-04-x64
 ${Green_font_prefix}6.${Font_color_suffix}  ubuntu-20-04-x64
 ${Green_font_prefix}7.${Font_color_suffix}  ubuntu-18-04-x64
 ${Green_font_prefix}8.${Font_color_suffix}  centos-stream-9-x64"
    read -p " 请输入机器系统:" image
    if [[ ${image} == "1" ]]; then
        image="centos-7-x64"
    elif [[ ${image} == "2" ]]; then
        image="centos-stream-8-x64"
    elif [[ ${image} == "3" ]]; then
        image="debian-11-x64"
    elif [[ ${image} == "4" ]]; then
        image="debian-10-x64"
    elif [[ ${image} == "5" ]]; then
        image="ubuntu-22-04-x64"
    elif [[ ${image} == "6" ]]; then
        image="ubuntu-20-04-x64"
    elif [[ ${image} == "7" ]]; then
        image="ubuntu-18-04-x64"
    elif [[ ${image} == "8" ]]; then
        image="centos-stream-9-x64"
    else
        echo "输入错误"
        do_loop_script
    fi
}

#创建机器
create_do() {

    read -p " 请输入机器名字:" name
    
    region_do
    size_do

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
                "ipv6":true,
                "user_data":"bash <(curl -Ls https://github.com/LG-leige/open_cloud/raw/main/passwd.sh)"
                
            }' \
            "https://api.digitalocean.com/v2/droplets"`
            var1=`echo $json | jq -r '.droplet.id'`
            echo ""
            if [[ $var1 == null ]];
            then
                echo $json
                echo "创建失败，请把以上的错误代码发送给 @LeiGe_233 可帮您更新提示"
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
            curl -s -X DELETE \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
            "https://api.digitalocean.com/v2/droplets/${id}"
            echo "ID为 ${id} 删除成功！"
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
    ls ${file_path}/do
    echo "已绑定的api："$array
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
    echo -e " ${Green_font_prefix}1.${Font_color_suffix}  ap-west（in）
 ${Green_font_prefix}2.${Font_color_suffix}  ca-central（ca）
 ${Green_font_prefix}3.${Font_color_suffix}  ap-southeast（au）
 ${Green_font_prefix}4.${Font_color_suffix}  us-central（us）
 ${Green_font_prefix}5.${Font_color_suffix}  us-west（us）
 ${Green_font_prefix}6.${Font_color_suffix}  us-southeast（us）
 ${Green_font_prefix}7.${Font_color_suffix}  us-east（us）
 ${Green_font_prefix}8.${Font_color_suffix}  eu-west（uk）
 ${Green_font_prefix}9.${Font_color_suffix}  ap-south（sg）
 ${Green_font_prefix}10.${Font_color_suffix}  eu-central（de）
 ${Green_font_prefix}11.${Font_color_suffix}  ap-northeast（JP）"
    read -e -p "请选择你的服务器位置:" region
    if [[ ${region} == "1" ]]; then
        region="ap-west"
    elif [[ ${region} == "2" ]]; then
        region="ca-central"
    elif [[ ${region} == "3" ]]; then
        region="ap-southeast"
    elif [[ ${region} == "4" ]]; then
        region="us-central"
    elif [[ ${region} == "5" ]]; then
        region="us-west"
    elif [[ ${region} == "6" ]]; then
        region="us-southeast"
    elif [[ ${region} == "7" ]]; then
        region="us-east"
    elif [[ ${region} == "8" ]]; then
        region="eu-west"
    elif [[ ${region} == "9" ]]; then
        region="ap-south"
    elif [[ ${region} == "10" ]]; then
        region="eu-central"
    elif [[ ${region} == "11" ]]; then
        region="ap-northeast"
    else
        echo "输入错误"
        linode_loop_script
    fi
}

#linode服务器镜像
image_linode(){
    echo -e " ${Green_font_prefix}1.${Font_color_suffix}  linode/centos7
 ${Green_font_prefix}2.${Font_color_suffix}  linode/centos-stream8
 ${Green_font_prefix}3.${Font_color_suffix}  linode/centos-stream9
 ${Green_font_prefix}4.${Font_color_suffix}  linode/debian10
 ${Green_font_prefix}5.${Font_color_suffix}  linode/debian11
 ${Green_font_prefix}6.${Font_color_suffix}  linode/debian9
 ${Green_font_prefix}7.${Font_color_suffix}  linode/ubuntu16.04lts
 ${Green_font_prefix}8.${Font_color_suffix}  linode/ubuntu18.04
 ${Green_font_prefix}9.${Font_color_suffix}  linode/ubuntu20.04
 ${Green_font_prefix}10.${Font_color_suffix}  linode/ubuntu22.04
 ${Green_font_prefix}11.${Font_color_suffix}  linode/centos8
 ${Green_font_prefix}12.${Font_color_suffix}  linode/ubuntu21.04
 ${Green_font_prefix}13.${Font_color_suffix}  linode/ubuntu21.10"
    read -e -p "请选择你的服务器位置:" image
    if [[ ${image} == "1" ]]; then
        image="linode/centos7"
    elif [[ ${image} == "2" ]]; then
        image="linode/centos-stream8"
    elif [[ ${image} == "3" ]]; then
        image="linode/centos-stream9"
    elif [[ ${image} == "4" ]]; then
        image="linode/debian10"
    elif [[ ${image} == "5" ]]; then
        image="linode/debian11"
    elif [[ ${image} == "6" ]]; then
        image="linode/debian9"
    elif [[ ${image} == "7" ]]; then
        image="linode/ubuntu16.04lts"
    elif [[ ${image} == "8" ]]; then
        image="linode/ubuntu18.04"
    elif [[ ${image} == "9" ]]; then
        image="linode/ubuntu20.04"
    elif [[ ${image} == "10" ]]; then
        image="linode/ubuntu22.04"
    elif [[ ${image} == "11" ]]; then
        image="linode/centos8"
    elif [[ ${image} == "12" ]]; then
        image="linode/ubuntu21.04"
     elif [[ ${image} == "13" ]]; then   
        image="linode/ubuntu21.10"
    else
        echo "输入错误"
        linode_loop_script
    fi
}

#linode服务器大小
size_linode(){
    echo -e " ${Green_font_prefix}1.${Font_color_suffix} 1H1G
 ${Green_font_prefix}2.${Font_color_suffix}  1H2G
 ${Green_font_prefix}3.${Font_color_suffix}  2H4G
 ${Green_font_prefix}4.${Font_color_suffix}  4H8G
 ${Green_font_prefix}5.${Font_color_suffix}  6H16G"
    read -p " 请输入机器规格:" size
    if [[ ${size} == "1" ]]; then
        size="g6-nanode-1"
    elif [[ ${size} == "2" ]]; then
        size="g6-standard-1"
    elif [[ ${size} == "3" ]]; then
        size="g6-standard-2"
    elif [[ ${size} == "4" ]]; then
        size="g6-standard-4"
    elif [[ ${size} == "5" ]]; then    
        size="g6-standard-6"
    else
        echo "输入错误"
        linode_loop_script
    fi
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
 ${Green_font_prefix}x.${Font_color_suffix} Azure (Global Edition)
————————————————————————————————————————————————————————————————
 ${Green_font_prefix}x.${Font_color_suffix} aws（未开发）
 ${Green_font_prefix}x.${Font_color_suffix} vultr（未开发，没有API）
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
