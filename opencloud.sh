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
#初始化
initialization(){
    mkdir -p /root/opencloud
    mkdir -p /root/opencloud/do
    mkdir -p /root/opencloud/linode
    mkdir -p /root/opencloud/az
    mkdir -p /root/opencloud/aws
    mkdir -p /root/opencloud/vu
    
    if [ ! -f "/usr/local/bin/aws" ]; then
        echo "需要初始化，2秒后进行！"
        sleep 2s
        install_aws_EC2_cli
        rm -rf /root/aws
        rm -rf awscliv2.zip
    fi
    
    if [ -d "${file_path}/az/${api_name}/resource/${remark}" ]; then
        cp -r /root/opencloud/az/ge/. /root/opencloud/az
        rm -rf /root/opencloud/az/ge
    fi
    
    start_menu
}

#启动菜单
start_menu() {
  clear
  echo && echo -e "云服务开机脚本${Red_font_prefix} 开源免费 无加密代码${Font_color_suffix} ${Green_font_prefix}from @openccloud${Font_color_suffix}
项目地址：${Red_font_prefix}https://github.com/LG-leige/open_cloud${Font_color_suffix}
 ${Green_font_prefix}1.${Font_color_suffix} Digitalocean 
 ${Green_font_prefix}2.${Font_color_suffix} Linode
 ${Green_font_prefix}3.${Font_color_suffix} vultr（未开发，没有API）
 ${Green_font_prefix}4.${Font_color_suffix} Azure
 ${Green_font_prefix}5.${Font_color_suffix} AWS EC2
————————————————————————————————————————————————————————————————
 ${Green_font_prefix}99.${Font_color_suffix} 退出脚本" &&

read -p " 请输入数字 :" num
  case "$num" in
    1)
    bash <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/digitalocean/opencloud-digitalocean.sh)
    ;;
    2)
    bash <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/linode/opencloud-linode.sh)
    ;;
    3)
    clear
    echo "目前该项目尚未开发，作者没有API" #vultr_menu
    ;;
    4)
    bash <(curl -Ls https://raw.githubusercontent.com/LG-leige/open_cloud/main/Azure/opencloud-Azure.sh)
    ;;
    5)
    echo "目前该项目正在开发，请耐心等待" #aws_EC2_menu
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