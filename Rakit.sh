#!/bin/bash
# date: 2024-8-2  version: v1.4.2
# Author: Hope
# Mail: busyops@outlook.com



#############################################################
#################更新日志#####################
# 2023-12-18 修改数组比较方式，删掉grep过滤，添加comm命令进行数组比较差异
# 2023-12-22 完成交互面（除添加IP功能外）
# 2024-1.8 实现Centos 7.x IP功能添加
# 2024-2.1 实现Ubuntu 16-22，Debian 8-10添加ip功能
# 2024-2.2 修改链接状态信息，增加IP归属地查询。
# 2024.7.21 增加nmcli配置功能，适配centos stream 8  9    rocky linux
# 2024.7.21 增加网络测速功能
# 2024.8.2 修改网络测试功能，只下载speedtest-cli脚本



##### 自删配置段  =0: 关闭自删  =1: 退出脚本执行自删
auto_delete=0
auto_Delete_Configuration () {

    if [[ auto_delete -eq 1 ]]; then
        echo -e "\nAuto clear, Bye Bye."
        rm -rf speedtest-cli.py
        rm -f $0
        exit 0

    else
        echo -e "\nBye Bye."
        rm -rf speedtest-cli.py
        exit 0
    fi

}

trap auto_Delete_Configuration SIGINT
#############  1.菜单栏


### 1.1 logo

logo () {

clear
    echo -e "\033[32;1m ____       _  ___ _   \033[0m
\033[32;1m|  _ \ __ _| |/ (_) |_ \033[0m
\033[32;1m| |_) / _\` | ' /| | __|\033[0m
\033[32;1m|  _ < (_| | . \| | |_ \033[0m
\033[32;1m|_| \_\__,_|_|\_\_|\__|\033[0m                        \033[1m--v1.4.2\033[0m\n"
}


start_Out_Info_Title () {
    clear
    echo -e "\033[32;1mRak_Smart Kit\033[0m"
    echo -e "\033[1m                       --v1.4.2\033[0m"
}

start_Out_Info_Title_For_Addip () {

    clear
    echo -e "\033[32;1mRak_Smart Kit\033[0m"
    echo -e "\033[1m                       --v1.4.2\n\033[0m"

    active_Ip=$(ip addr show $up_Card_Name | grep -v "127.0.0.1" | grep "\<inet\>" | wc -l)
    echo -e "当前配置的网卡：$up_Card_Name  生效ip：$active_Ip"
}



### 1.2 系统简略信息  os_Base_Info

os_Base_Info () {
    
    cpu_Name=($(lscpu | awk -F: '/^Model name:/{print $2}' | awk -F@ '{print $1}' | awk -FCPU '{print $2}' | xargs))
    cpu_Count=($(lscpu | awk '/Socket/{print $2}'))
    total_Mem=($(free -h | awk '/^Mem/{print $2,$3}'))
    ip_Count=$(ip a | grep -v "127.0.0.1" | grep "\<inet\>" | wc -l)
    
    system_List=(
    "0"
    "CentOS"
    "CentOS Stream"
    "Debian"
    "Ubuntu"
    "Rocky Linux"
    )

    if [ -f /etc/redhat-release ]; then
        egrep -q 'CentOS Linux release' /etc/redhat-release && system_Type=1 && release=$(awk '{print $4}' /etc/redhat-release) && release_2=$(echo $release | awk -F. '{print $1}')
        egrep -q 'CentOS Stream release' /etc/redhat-release && system_Type=2 && release=$(awk '{print $4}' /etc/redhat-release )
        egrep -q 'Rocky Linux release' /etc/redhat-release && system_Type=5 && release=$(awk '{print $4}' /etc/redhat-release) && release_2=$(echo $release | awk -F. '{print $1}')
        
    elif command -v lsb_release &>/dev/null; then
        system_Type=$(lsb_release -a 2>/dev/null | awk '/^Description/{print $2}')
        if [ $system_Type == 'Debian' ]; then
            system_Type=3 && release=$(lsb_release -a 2>/dev/null | awk '/^Description/{print $4}')
        elif [ $system_Type == 'Ubuntu' ]; then
            system_Type=4 && release=$(lsb_release -a 2>/dev/null | awk '/^Description/{print $3}')
            release_2=$(echo $release | awk -F. '{print $1}')
        fi
    else
        echo "不支持这个操作系统"
        auto_Delete_Configuration
    
    fi

    
    echo -e "\033[1m--------------------------------------------------------------------\033[0m"
    printf "%-2s %-15s |%-10s %s X %s | %2s %-s\n" "OS:" "${system_List[$system_Type]} $release" "CPU型号及颗数:" "${cpu_Name[*]}" "$cpu_Count" "内存:" "$total_Mem"
    printf "%-2s %-2s\n" "IP个数:" "$ip_Count"
    echo -e "\033[1m--------------------------------------------------------------------\033[0m\n"

}

### 1.3 主菜单 start_Out_Option

start_Out_Option () {
    clear
    logo
    os_Base_Info
    option_List=(

        " 1. 查看机器硬件信息           "
        "2. 查看链接状态信息           "
        "3. IP连通性检测               "
        "4. 添加IP地址                 "
        "5. 网络测速                   "
        "6. 硬盘读写测速"
        "7. 添加Rak网络镜像源"
        "8. 修改远程端口"
        "9. 修改系统时区"
        "q. 退出"
    )
    a=5
    for i in {0..4}; do
        if  [ $i -eq 0 ]; then
            echo -e "${option_List[$i]}|        \033[31m\033[9m${option_List[$a]}\033[0m\n"
        else
            echo -e " ${option_List[$i]}|        ${option_List[$a]}\n"
        fi
        let a++
    done

    echo -e "\033[32m-------------------------------------------------------------------\033[0m\n"
    read -t 60 -p '请输入对应的序号: ' want

    [ -z $want ] && want='q'

}


### 1.4 进入循环

###1.4.1 通用进入循环  in_Cycle 
in_Cycle () {

    incycle=1
    again_Test=1
    again_Output=1
    
    while [ $incycle -eq 1 ]; do

        if [ $again_Test -eq 1 ]; then
            clear
            $1
        fi
                
        $2
            
    done
}


### 1.4.2 进入循环 ip连通状态专用 in_Cycle_For_Ipconn

in_Cycle_For_Ipconn () {

    incycle=1
    again_Test=1
    again_Output=1
    more_Information=0
    
    while [ $incycle -eq 1 ]; do

        if [ $again_Test -eq 1 ]; then
            clear
            $1
        fi
                
        $2
            
    done

}


### 1.4.3 进入循环 配置ip专用

in_Cycle_For_Ip () {

    incycle=1
    again_Test=1
    again_Output=1
    ip_Suppot
    while [ $incycle -eq 1 ]; do
        
        $1
        $2

    done

}

### 1.4.4 进入循环 speedtest专用

in_Cycle_For_Speedtest () {

    incycle=1
    
    while [ $incycle -eq 1 ]; do

        clear
        $1
            
    done
}


### 1.4.5 进入循环 拉取镜像源文件专用
in_Cycle_For_Pull_Mirror_File () {

    incycle=1
    
    while [ $incycle -eq 1 ]; do
        
        $1
        
        if [ $Mirror_Ping_Complete -eq 1 ]; then
            $2
        fi

    done
    
}



### 1.5 下一步
### 1.5.1 默认下一步 next_Page
next_Page () {

    if [ $again_Output -eq 1 ]; then
        echo "1: 返回上一级"
        echo "2: 重新测试"
        echo "3: 退出脚本"
    fi

    read -p '请输入序号：' next_Want

    [ -z $next_Want ] && next_Want=8
    [ $next_Want == 'q' ] && next_Want=1

    case $next_Want in

    1)
        incycle=2
        ;;

    2)
        again_Test=1
        again_Output=1
        ;;

    3)
        auto_Delete_Configuration
        ;;

    *)
        echo "输入错误，请重新输入"
        again_Test=2
        again_Output=2
        ;;

    esac

}
### 1.5.2 链接状态下一步 next_Page_For_Ipconn
next_Page_For_Ipconn () {

    if [ $again_Output -eq 1 ]; then
        echo "1: 返回上一级"
        echo "2: 重新测试"
        echo "3: 重新测试并增加显示IP归属地信息"
        echo "4: 退出脚本"
    fi

    read -p '请输入序号：' next_Want

    [ -z $next_Want ] && next_Want=8
    [ $next_Want == 'q' ] && next_Want=1

    case $next_Want in

    1)
        incycle=2
        ;;

    2)
        again_Test=1
        again_Output=1
        ;;
    3)
        again_Test=1
        again_Output=1
        more_Information=1
        ;;
    4)
        auto_Delete_Configuration
        ;;

    *)
        echo "输入错误，请重新输入"
        again_Test=2
        again_Output=2
        ;;

    esac

}

### 1.5.3 添加IP下一步  next_Want_Ip_1

next_Want_Ip_1 () {

echo "1: 返回上一级
2: 重启网卡
3: 退出脚本"

read -t 300 -p '输入符合格式的待添加IP信息或对应选项序号: ' want_Ipaddress

[[ $want_Ipaddress == 'q' ]] && want_Ipaddress='1'
[[ -z $want_Ipaddress ]]  && want_Ipaddress='1'

match_Prefix=2
match_Address=2
again_Output=2

case $want_Ipaddress in

1)
    incycle=2
    netcard_Check_Complete=0
    ;; 

2)
    restart_Network
    again_Output=1
    ;;

3)
    auto_Delete_Configuration
    ;;

invalid)
    echo "输入错误，请重新输入"
    again_Output=2
    ;;

*)
    match_Prefix=1
    again_Output=1
    match_AddPre
    ;;

esac

}


### 1.5.4 拉取镜像下一步 next_Want_Mirror 

next_Want_Mirror () {

sub_Footer_Out
echo "1: 返回上一级"
echo "2: 替换本机镜像源"
echo "3: 退出脚本"

read -p '请输入序号：' next_Want
[ $next_Want == 'q' ] && next_Want=1
[ $next_Want == 'y' ] && next_Want=2
[ $next_Want == 'n' ] && next_Want=1

case $next_Want in

1)
    incycle=2
    ;;

2)
    pull_Mirror_File
    incycle=2
    ;;

3)
    auto_Delete_Configuration
    ;;

*) 
    echo "输入错误，请重新输入"
    ;;

esac
}


### 1.6 页脚 sub_Footer_Out

sub_Footer_Out () {

    echo -e "\n\n\n\n"
    echo -e "\033[32m--------------------------------------------------------\033[0m\n"

}


sub_Footer_Out_For_Ipconn () {

    echo -e "\n\n\n\n"
    echo "Notes:"
    echo " - 各状态按连接数降序显示，至多显示十条。"
    echo " - ip归属地信息受本机网络环境和ipinfo.io查询次数影响。"
    echo -e "\033[32m--------------------------------------------------------\033[0m\n"

}

############# 二、功能实现

### 2.1 硬件信息统计 hardware_Info
hardware_Info () {

    start_Out_Info_Title

    cpu_Name=($(lscpu | awk -F: '/^Model name:/{print $2}' | awk -F@ '{print $1}' | xargs))
    cpu_Count=($(lscpu | awk '/Socket/{print $2}'))
    per_Cpu_Core_Count=($(lscpu | awk '/Core\(s\) per socket/{print $NF}'))
    per_Core_Thread_Count=($(lscpu | awk '/Thread\(s\) per core/{print $NF}'))
    total_Core_Thread_Count=($(lscpu | awk '/^CPU\(s\)/{print $NF}'))

###########   mem info  #########

    total_Mem=($(free -h | awk '/^Mem/{print $2,$3}'))
    total_Swap=($(free -h | awk '/Swap/{print $2,$3}'))


###########  disk info  #########

    disk_Count=$(df -h | grep -c "^/dev/")
    disk_List=($(df -h | awk '/^\/dev\//{print}'))

###########  hardware_outpu ################

    echo -e "\033[32m--- CPU 信息        ------------------------------------\033[0m"
    printf "%-21s %s\n" "CPU型号:" "${cpu_Name[*]}"
    printf "%-21s %s\n" "CPU个数:" "${cpu_Count[*]}"
    printf "%-23s %s\n" "单CPU核心数:" "$per_Cpu_Core_Count"
    printf "%-25s %s\n" "单核心线程数:" "$per_Core_Thread_Count"
    printf "%-23s %s\n" "总线程数:" "$total_Core_Thread_Count"

    echo -e "\033[32m--- 内存信息        ------------------------------------\033[0m"
    printf "%-23s %-s %-8s %-s %-s\n" "内存信息:" "总量:" "${total_Mem[0]}" "已用:" "${total_Mem[1]}"
    printf "%-19s %-s %-8s %-s %-s\n" "Swap:" "总量:" "${total_Swap[0]}" "已用:" "${total_Swap[1]}"

    echo -e "\033[32m--- 分区信息        ------------------------------------\033[0m"
    echo ${disk_List[@]} | xargs -n 6 | awk 'BEGIN{print "分区                总量   已用   挂载点"}{printf "%-19s %-6s %-7s %s\n",$1,$2,$3,$NF}END{printf "\n"}'

    sub_Footer_Out
    
}

### 2.2 链接状态统计 link_State

link_State () {

    start_Out_Info_Title

    echo -e "\033[32m--- 链接状态信息    ------------------------------------\033[0m"
    ss_All_State=$(ss -tan | egrep -v "(^State|^LISTEN|\<80\s+$|::)" | egrep -v "127\.0\.0\.1" | awk -F: '{print $1,$2}' | awk '{print $1,$4,$5,$6}')
    ss_All_Type=($(echo ${ss_All_State[@]} | xargs -n 4 | awk '{state[$1]++} END{for (i in state) print i,state[i]}'))

    for state_type in $(seq 0 2 $((${#ss_All_Type[@]}-1)));do
        echo "${ss_All_Type[$state_type]} ${ss_All_Type[$((state_type+1))]}" | awk '{printf "\033[32;1m%-8s\033[0m------- 处于此状态的链接个数: %s\n",$1,$2}'
        state_Info=($(echo "${ss_All_State[@]}" | xargs -n 4 | awk "/^${ss_All_Type[$state_type]}/{print}" | sort -nk 4 | uniq -c | sort -nr ))
        
        [ "$more_Information" -eq 0 ] && printf "   %-17s |   %-10s  |  %-s\n"  "Local IP:Port" "Client IP"  "Conn Count"
        [ "$more_Information" -eq 1 ] && printf "   %-17s |  %-10s  |  %-10s  |  %-10s  |    %-8s    |   %-s\n" "Local IP:Port" "Client IP" "Conn Count" "CIP Country" "CIP City" "CIP Org"


        for sub_State in $(seq 0 5 $((${#state_Info[@]}-1))); do
            [ "$sub_State" -gt 45 ] && continue
            conn_Count=${state_Info[$sub_State]}
            local_Ip=${state_Info[$((sub_State+2))]}
            conn_Port=${state_Info[$((sub_State+3))]}
            client_Ip=${state_Info[$((sub_State+4))]}

            if [ "$more_Information" -eq 1 ]; then

                client_Ip_Index=$(echo $client_Ip | tr '.' '1')
                [ -n "${client_Ip_Info[$client_Ip_Index]}" ] || client_Ip_Info[$client_Ip_Index]=$(curl -s ipinfo.io/$client_Ip)

                client_Ip_City=$(echo "${client_Ip_Info[$client_Ip_Index]}" | egrep "city" | cut -d'"' -f4)
                client_Ip_Country=$(echo "${client_Ip_Info[$client_Ip_Index]}" | egrep "country" | cut -d'"' -f4)
                client_Ip_Org=$(echo "${client_Ip_Info[$client_Ip_Index]}" | egrep "org" | cut -d'"' -f4)

                [ -z "$client_Ip_City" ] && client_Ip_City="Not found"
                [ -z "$client_Ip_Org" ] && client_Ip_Org="Not found"
                [ -z "$client_Ip_Country" ] && client_Ip_Country="Not found"

                if [ "$conn_Count" -ge 20 ]; then
                    printf " \033[31m%-21s:%-15s %-15s       %-12s %-15s %-s\033[0m\n" "$local_Ip:$conn_Port" "$client_Ip" "$conn_Count" "$client_Ip_Country" "$client_Ip_City" "$client_Ip_Org"
                else
                    printf " %-21s%-15s      %-15s %-12s %-15s %-s\n" "$local_Ip:$conn_Port" "$client_Ip" "$conn_Count" "$client_Ip_Country" "$client_Ip_City" "$client_Ip_Org"
                fi

            else
                if [ "$conn_Count" -ge 20 ]; then
                    printf " \033[31m%-21s %-15s      %-s\033[0m\n" "$local_Ip:$conn_Port" "$client_Ip"  "$conn_Count"
                else
                    printf " %-21s %-15s      %-s\n" "$local_Ip:$conn_Port" "$client_Ip" "$conn_Count"
                fi
            fi
        done
        
        [[ "$state_type" -eq $((${#ss_All_Type[@]}-2)) ]] || echo -e "\n\033[32m--------------------------------------------------------\033[0m"

    done
    
    sub_Footer_Out_For_Ipconn

}


### 2.3 ip连通性检测 ip_Info
ip_Info () {

    start_Out_Info_Title

    echo -e "\033[32m--- IP连通性检测       ------------------------------------\033[0m"

    ip_Count=$(ip a | grep -v "127.0.0.1" | grep "\<inet\>" | wc -l)
    ip_List=($(ip a | awk '/inet /{split($2, ip, "/"); print ip[1]}' | grep -v "127.0.0.1"))

    echo "IP个数:-${ip_Count}" | awk -F- '{printf "%-17s %-5d\n",$1,$2}'

    ip_Google_List_Ok=($(echo -n ${ip_List[*]} | xargs -d' ' -n 1 -P 100  -I {} bash -c "ping -c 2 -I {} 8.8.8.8 &>/dev/null && echo {}"))
    ip_Google_List_Ok_Count=(${#ip_Google_List_Ok[@]})
    ip_Google_List_False=($(comm -3 <(printf "%s\n" "${ip_List[@]}" | sort) <(printf "%s\n" "${ip_Google_List_Ok[@]}" | sort)))
    ip_Google_List_False_Count=(${#ip_Google_List_False[@]})
    echo "测试Ping 8.8.8.8-可通:-${ip_Google_List_Ok_Count[0]}-不通:-${ip_Google_List_False_Count[0]}" | awk -F- '{printf "%-17s %-2s %-10s %-3s %-10s\n",$1,$2,$3,$4,$5}'
    
    ip_TxDns_List_Ok=($(echo -n ${ip_List[*]} | xargs -d' ' -n 1 -P 100  -I {} bash -c "ping -c 2 -I {} 119.29.29.29 &>/dev/null && echo {}"))
    ip_TxDns_List_Ok_Count=(${#ip_TxDns_List_Ok[@]})
    ip_TxDns_List_False=($(comm -3 <(printf "%s\n" "${ip_List[@]}" | sort) <(printf "%s\n" "${ip_TxDns_List_Ok[@]}" | sort)))
    ip_TxDns_List_False_Count=(${#ip_TxDns_List_False[@]})
    echo "测试Ping 腾讯DNS-可通:-${ip_TxDns_List_Ok_Count[0]}-不通:-${ip_TxDns_List_False_Count[0]}" | awk -F- '{printf "%-15s %-2s %-10s %-3s %-10s\n",$1,$2,$3,$4,$5}'
    echo


    if [[ ${ip_Google_List_False_Count} -gt 0 ]]; then
        echo -e "\033[32m--- 到8.8.8.8不通          ------------------------------------\033[0m"
        echo "${ip_Google_List_False[*]}" | xargs -n 5 | awk '{printf "%-20s%-20s%-20s%-20s%-20s\n",$1,$2,$3,$4,$5}'
        echo
    fi

    if [[ ${ip_TxDns_List_False_Count} -gt 0 ]]; then
        echo -e "\033[32m--- 到腾讯DNS不通          ------------------------------------\033[0m"
        echo "${ip_TxDns_List_False[*]}" | xargs -n 5 | awk '{printf "%-20s%-20s%-20s%-20s%-20s\n",$1,$2,$3,$4,$5}'
    fi

    sub_Footer_Out

}

### 2.4添加ip
### 2.4.1 检查网卡 netcard_Check

ip_Suppot () {

     if [[ $system_Type -ge 1 && $system_Type -le 5 ]]; then
        echo
    else
        start_Out_Info_Title
        read  -t 30 -p "不支持这个操作系统, 按任意键返回" not_Suppot
        incycle=2
    fi

}
   

netcard_Check () {


    up_Netcard_Count=$(ip a | egrep "^[[:digit:]]+.*state UP" | wc -l)
    up_Netcard_List=($(ip a | egrep "^[[:digit:]]+:[[:space:]].*state UP" | awk '{split($2, cardname, ":");print cardname[1]}'))
    
    if [[ $netcard_Check_Complete -eq 0 ]]; then
        if [[ $up_Netcard_Count -gt 1 ]]; then
            start_Out_Info_Title
            echo "检测到存在多个状态UP的网卡, 手动选择配置到哪个网卡上:"

            for card_Name in $(seq 0 1 $((${#up_Netcard_List[@]}-1))); do
                echo "$((card_Name+1)): ${up_Netcard_List[$card_Name]}"
            done

            read -p '请选择:' card
            up_Card_Name=${up_Netcard_List[$(($card-1))]}
            netcard_Check_Complete=1
            
        elif [[ $up_Netcard_Count -eq 0 ]]; then
            start_Out_Info_Title
            read -t 30 -p "没有检测到UP的网卡, 请手动排查问题, 按任意键返回" not_Suppot
            break

        else 
            up_Card_Name=$(ip a | egrep "state UP"  | awk -F: '{print $2}' | xargs)
        fi
    fi
}


### 2.4.2 添加ip使用帮助输出
output_Ip_Modify_usage () {
    netcard_Check
    start_Out_Info_Title_For_Addip

    if [ $again_Output -eq 1 ]; then

echo -e "\n\033[32m---  添加IP功能的使用方式  ---------------------------------------------------------------------------------------------\033[0m
【Single IP】 输入IP及其所在子网的掩码 || 示例：192.168.1.1/24 或 192.168.1.1/255.255.255.0

【连续IP】 输入IP-IP及其所在子网的掩码 || 示例：192.168.1.1-20/25 或 192.168.1.1-20/255.255.255.0

【整C IP】 输入整C网络地址及其掩码     || 示例：192.168.1.0/24 或 192.168.1.0/255.255.255.0

上述三种IP类型、掩码格式可混合输入，多个待添加的IP使用空格分割、掩码的取值范围24-30|255.255.255.0-252
\033[32m-------------------------------------------------------------------------------------------------------------------------\033[0m\n"

    fi

}

### 2.4.3 重启网卡
restart_Network () {

    if [[ $system_Type -eq 1  && $release_2 -eq 7 ]]; then
        echo -n "重启网卡中......" && systemctl restart network.service && echo -e "\033[32m[成功]\033[0m" || echo -e "\n\033[31m[失败]\033[0m"

    elif [[ $system_Type -eq 1  && $release_2 -eq 8 ]]; then
        up_Card_Conn=$(nmcli -g GENERAL.CONNECTION device show $up_Card_Name)
        echo -n "重启网卡中......" && nmcli conn reload && nmcli connection up "${up_Card_Conn}"  &>/dev/null && echo -e "\033[32m[成功]\033[0m" || echo -e "\n\033[31m[失败]\033[0m"

    elif [[ $system_Type -eq 2  && ($release -eq 8 || $release -eq 9 || $release -eq 10) ]]; then
        up_Card_Conn=$(nmcli -g GENERAL.CONNECTION device show $up_Card_Name)
        echo -n "重启网卡中......" && nmcli conn reload && nmcli connection up "${up_Card_Conn}" &>/dev/null && echo -e "\033[32m[成功]\033[0m" || echo -e "\n\033[31m[失败]\033[0m"
    
    elif [[ $system_Type -eq 5 ]]; then
        up_Card_Conn=$(nmcli -g GENERAL.CONNECTION device show $up_Card_Name)
        echo -n "重启网卡中......" && nmcli conn reload && nmcli connection up "${up_Card_Conn}" &>/dev/null && echo -e "\033[32m[成功]\033[0m" || echo -e "\n\033[31m[失败]\033[0m"
    
    elif [[ $system_Type -eq 3 ]]; then
        echo -n "重启网卡中......" && ip addr flush dev ${up_Card_Name} && systemctl restart networking.service && echo -e "\033[32m[成功]\033[0m"|| echo -e "\n\033[31m[失败]\033[0m"

    elif [[ $system_Type -eq 4 && $release_2 -eq 16 ]]; then
        echo -n "重启网卡中......" && ip addr flush dev ${up_Card_Name} && systemctl restart networking.service && echo -e "\033[32m[成功]\033[0m"|| echo -e "\n\033[31m[失败]\033[0m"
    
    elif [[ $system_Type -eq 4 && $release_2 -gt 16 ]]; then 
        echo -n "重启网卡中......" && netplan apply && echo -e "\033[32m[成功]\033[0m" || echo -e "\n\033[31m[失败]\033[0m"
    
    else
        echo
    fi

    sleep 5

}


### 2.4.4 判断IP是否符合要求 match_AddPre

match_AddPre () {

want_Ipaddress=($(echo "$want_Ipaddress"))

###### 判断掩码是否合规，合规则继续判断IP ######

[[ $match_Prefix -eq 1 ]] && for i in $(seq 0 1 $((${#want_Ipaddress[@]}-1))); do

    error_Info=''
    match_Address=2
    ip_True=2
    prefix_True=2

    prefix=$(echo "${want_Ipaddress[$i]}" | awk -F/ '{print $2}')
    
    if [[ $prefix =~ ^255\.255\.255\.(0|128|192|224|240|248|252)+$ ]]; then

        prefix_4=$(echo $prefix | awk -F. '{print $4}')
        for cycle in {1..8}; do
            [ $prefix_4 -eq $((256-2**$cycle)) ] && prefix=$((32-$cycle)) && modulu=$((2**$cycle))
        done
        prefix_True=1 && match_Address=1

    elif [[ $prefix -ge 24 && $prefix -le 30 ]] &>/dev/null ; then
        for cycle in {1..8}; do
            [[ $prefix -eq $((32-$cycle)) ]] && modulu=$((2**$cycle))
        done
        
        prefix_True=1 && match_Address=1
    
    else
        prefix_True=2 && error_Info='无法识别掩码信息' && ip_Type='bad'

    fi

######### 掩码合格则继续判断IP ##########

    #### single IP 和 整C ip判断
    [[ $match_Address -eq 1 ]] && address=$(echo "${want_Ipaddress[$i]}" | awk -F/ '{print $1}' )      &&  \
    if [[ $address =~ ^((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-3])$ ]]; then

        host_Address=$(echo "$address" | awk -F. '{print $4}')
        network_Address=$(echo "$address" | awk -F. '{printf "%s.%s.%s.",$1,$2,$3}')

        if [[ $((host_Address%modulu)) -eq 0 ]]; then
            ip_Type='overoall' && ip_True=1 && C="$((256/$modulu))C"
            network="$address"  
            gateway="${network_Address}$((host_Address+modulu-2))"
            broadcast=$(echo $network_Address$((host_Address+modulu-1)))
            ip_Num="$((modulu-3))"

        elif [[ $((host_Address%modulu)) -ge $((modulu-2)) ]]; then
            ip_True=2 && error_Info='ip错误, 此IP是这段的网关位或广播位'
    
        else
            network="${network_Address}$((host_Address/modulu*modulu))"  
            gateway="${network_Address}$((host_Address/modulu*modulu+modulu-2))"
            broadcast="${network_Address}$((host_Address/modulu*modulu+modulu-1))"
            ip_Type='singleIP' && ip_True=1

        fi

    ##### 多IP 判断
    elif [[ $address =~ ^((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-3])-(1?[0-9][0-9]?|2[0-4][0-9]|25[0-3])$ ]]; then
        host_Address_Min=$(echo "$address" | awk -F. '{print $4}' | awk -F- '{print $1}')
        host_Address_Max=$(echo "$address" | awk -F. '{print $4}' | awk -F- '{print $2}')
        
        true_Min=$((host_Address_Min/modulu*modulu+1))
        true_Max=$((true_Min+modulu-4))
         
        network_Address=$(echo "$address" | awk -F. '{printf "%s.%s.%s.",$1,$2,$3}')

        if [[ $host_Address_Min -ge $host_Address_Max ]]; then
            ip_Type='bad' && error_Info='多IP识别错误, 请把最小值写在前面'

        elif [[ $host_Address_Min -ge $true_Min && $host_Address_Max -le $true_Max ]]; then
            ip_Type='multi' && ip_True=1
            network="${network_Address}$((true_Min-1))"  
            gateway="${network_Address}$((true_Max+1))"
            broadcast="${network_Address}$((true_Max+2))"
            ip_Num=$((host_Address_Max-host_Address_Min+1))

        else
            ip_Type='bad' && ip_True=2 && error_Info='你填写的多IP超出了这段的可配置范围'
        fi

    else
        ip_Type='bad' && ip_True=2 && error_Info='无法识别这段IP'

    fi

###### 分类存储
    if [[ $ip_Type == 'singleIP' ]]; then
        singleIP[${#singleIP[@]}]="$address $prefix $network $gateway $broadcast"

    elif [[ $ip_Type == 'overoall' ]]; then
        overoall[${#overoall[@]}]="$address $prefix $C $gateway $broadcast $ip_Num"
    
    elif [[ $ip_Type == 'multi' ]]; then
        multi[${#multi[@]}]="$address $prefix $network $gateway $broadcast $ip_Num"

    else 
        badip[${#badip[@]}]="${want_Ipaddress[$i]} $error_Info"
    
    fi
done


###### 计算各类IP个数

commit_Ip_Sum=$((${#singleIP[@]}+${#overoall[@]}+${#multi[@]}+${#badip[@]}))
commit_Ture_Ip_Sum=$((${#singleIP[@]}+${#overoall[@]}+${#multi[@]}))
single_Ip_Count=${#singleIP[@]}
overoall_Ip_Count=${#overoall[@]}
multi_Ip_Count=${#multi[@]}
badip_Count=${#badip[@]}

###### 分类输出 #####

if [[ $commit_Ip_Sum -gt 0 ]]; then

    clear
    start_Out_Info_Title_For_Addip

    echo -e "你一共输入了${commit_Ip_Sum}个参数 | \033[32m正确识别${commit_Ture_Ip_Sum}个\033[0m |  \033[31m无法识别${badip_Count}个\033[0m"

    echo
    
    serial=1
    
    [[ ${#singleIP[@]} -gt 0 ]] &&  awk 'BEGIN{print "---- Single IP ----"}' && for output_Ip in $(seq 0 1 $((${#singleIP[@]}-1))); do
        echo -n "(${serial})  " && echo "${singleIP[$output_Ip]}" | xargs -n 5 |  \
        awk '{printf "%s/%-5s 网络地址：%-15s 网关：%-15s 广播：%s\n",$1,$2,$3,$4,$5}' && let serial++
    done && echo


    [[ ${#overoall[@]} -gt 0 ]] && awk  'BEGIN{print "---- 站群 IP ----"}' && for output_Ip in $(seq 0 1 $((${#overoall[@]}-1))); do
        echo -n "(${serial})  " && echo "${overoall[$output_Ip]}" | xargs -n 6 |      \
        awk '{printf "%s/%-5s  类型：%-5s 网关：%-15s 广播：%-15s 可用IP数：%s\n",$1,$2,$3,$4,$5,$6;serial++}' && let serial++
    done && echo


    [[ ${#multi[@]} -gt 0 ]] && awk  'BEGIN{print "---- 连续 IP ----"}' && for output_Ip in $(seq 0 1 $((${#multi[@]}-1))); do
        echo -n "(${serial})  " && echo "${multi[$output_Ip]}"  | xargs -n 6 |    \
    awk '{printf "%s/%-5s  网络地址：%-5s 网关：%-15s 广播：%-15s 可用IP数：%s\n",$1,$2,$3,$4,$5,$6;}' && let serial++
    done && echo


    [[ ${#badip[@]} -gt 0 ]] && awk  'BEGIN{print "---- 无法正确识别的IP ----"}' && for output_Ip in $(seq 0 1 $((${#badip[@]}-1))); do
        echo -n "(${serial})  " && echo "${badip[$output_Ip]}" | xargs -n 2 |    \
        awk '{printf "%-15s  错误原因：%-s\n",$1,$2}' && let serial++
    done && echo

fi
echo -e "-------------------------------------------------------------------------------------------------------------------------
1. 返回上一级
2. 仅重新输入无法识别的IP (不用再次输入正确识别的IP)
3. 配置正确识别的IP (Single IP --> 网卡配置文件 | 连续IP、站群IP --> 以range形式配置)
4. 退出脚本"

read -t 240 -p '请输入对应的序号: ' next_Want

[[ -z $next_Want ]] && next_Want=1

######## 识别ip后下一步操作

case $next_Want in

1) 
    unset singleIP
    unset multi
    unset overoall
    unset badip
    incycle=2
    ;;

2)
    unset badip
    incycle=1
    again_Output=1
    ;;

3)
    if [[ $system_Type -eq 1  && $release_2 -eq 7 ]]; then
        Configuration_Ip_Centos

    elif [[ $system_Type -eq 1  && $release_2 -eq 8 ]]; then
        Configuration_Ip_Centos_Sream

    elif [[ $system_Type -eq 2  && ($release -eq 8 || $release -eq 9 || $release -eq 10) ]]; then
        Configuration_Ip_Centos_Sream

    elif [[ $system_Type -eq 3 ]]; then
        Configuration_Ip_Ubuntu_16

    elif [[ $system_Type -eq 4 && $release_2 -eq 16 ]]; then
        Configuration_Ip_Ubuntu_16
    
    elif [[ $system_Type -eq 4 && $release_2 -ge 18 ]]; then 
        Configuration_Ip_Ubuntu_20
    
    elif [[ $system_Type -eq 5 ]]; then 
        Configuration_Ip_Centos_Sream

    else
        echo
    fi
    ;;
4)
    auto_Delete_Configuration
    ;;

*)  

    echo "输入错误，请重新输入"
esac

}

### 2.4.5  Centos 7.x  IP配置段

Configuration_Ip_Centos () {


### 取值段
modify_Time=$(date "+%Y-%m-%d_%H:%M:%S")
network_Card_File="ifcfg-$up_Card_Name"
netcard_Cname=$(ip a | egrep "\<${up_Card_Name}:[[:digit:]]{0,}\>" | awk -F: '{print $NF}' | sort -nk1 | tail -1)
let netcard_Cname++
network_Dir="/etc/sysconfig/network-scripts/"
[[ -d ${network_Dir}bak ]] || mkdir ${network_Dir}bak
egrep "NM_CONTROLLED=" ${network_Dir}${network_Card_File} &>/dev/null && sed -i 's/NM_CONTROLLED=yes/NM_CONTROLLED=no/' ${network_Dir}${network_Card_File} || echo 'NM_CONTROLLED=no' >>  ${network_Dir}${network_Card_File}
egrep "ARPCHECK=" ${network_Dir}${network_Card_File} &>/dev/null && sed -i 's/ARPCHECK=yes/ARPCHECK=no/' ${network_Dir}${network_Card_File} || echo 'ARPCHECK=no' >>  ${network_Dir}${network_Card_File}
### 配置IP段
if [[ ${#singleIP[@]} -gt 0 ]]; then

    cp -a ${network_Dir}${network_Card_File} ${network_Dir}bak/${network_Card_File}.bak.${modify_Time}
    ipaddr_Num=$(egrep -o "IPADDR[[:digit:]]{0,}" ${network_Dir}${network_Card_File} | awk -FR '{print $NF}' | sort -nk 1 | tail -1)
    let ipaddr_Num++

    echo -e "\n# ----- ADD IP Time：$modify_Time -----" >> ${network_Dir}${network_Card_File}
    
    for add_Ip in $(seq 0 1 $((${#singleIP[@]}-1))); do
        ip_1=$(echo ${singleIP[$add_Ip]} | awk '{print $1}')
        prefix_1=$(echo ${singleIP[$add_Ip]} | awk '{print $2}')
        netmask_1=$(echo "255.255.255.$((256-2**(32-$prefix_1)))")
        gateway_1=$(echo ${singleIP[$add_Ip]} | awk '{print $4}')

        echo "IPADDR${ipaddr_Num}=$ip_1" >> ${network_Dir}${network_Card_File}
        echo -e "NETMASK${ipaddr_Num}=$netmask_1\n" >> ${network_Dir}${network_Card_File}
        com_Single_Ip[${#com_Single_Ip[@]}]="$ip_1 $netmask_1 $gateway_1"

        let ipaddr_Num++
    done

fi

if [[ ${#multi[@]} -gt 0 ]]; then

    range_Num=$(ls ${network_Dir}${network_Card_File}-range* 2>/dev/null | egrep -o "range[[:digit:]]{0,}" | awk -Fe '{print $NF}' | sort -nk1 | tail -1)
    let range_Num++

    for add_Ip in $(seq 0 1 $((${#multi[@]}-1))); do

        start_Ip=$(echo ${multi[$add_Ip]} | awk -F- '{print $1}')
        network_Address=$(echo "${multi[$add_Ip]}" | awk -F. '{printf "%s.%s.%s.",$1,$2,$3}')
        host_Address_Max=$(echo "${multi[$add_Ip]}" | awk -F- '{print $2}' | awk '{print $1}')
        prefix_1=$(echo ${multi[$add_Ip]} | awk '{print $2}')
        netmask_1=$(echo "255.255.255.$((256-2**(32-$prefix_1)))")
        gateway_1=$(echo "${multi[$add_Ip]}" | awk '{print $4}')
        step=$(echo ${multi[$add_Ip]} | awk '{print $NF}')
cat >> ${network_Dir}${network_Card_File}-range${range_Num} << EOF
# ----- ADD IP Time：$modify_Time -----
DEVICE=${up_Card_Name}
ONBOOT=yes
IPADDR_START=$start_Ip
IPADDR_END=${network_Address}${host_Address_Max}
NETMASK=$netmask_1
GATEWAY=${gateway_1}
ARPCHECK=no
CLONENUM_START=${netcard_Cname}
EOF
        com_Multi_Ip[${#com_Multi_Ip[@]}]="${start_Ip} ${network_Address}${host_Address_Max} ${netmask_1} ${gateway_1}"
        let range_Num++
        let netcard_Cname+=$step

    done

fi

if [[ ${#overoall[@]} -gt 0 ]]; then

    range_Num=$(ls ${network_Dir}${network_Card_File}-range* 2>/dev/null | egrep -o "range[[:digit:]]{0,}" | awk -Fe '{print $NF}' | sort -nk1 | tail -1)
    let range_Num++
    for add_Ip in $(seq 0 1 $((${#overoall[@]}-1))); do

        first_Ip=$(($(echo ${overoall[$add_Ip]} | awk '{print $1}' | awk -F. '{print $NF}' )+1))
        network_Address=$(echo "${overoall[$add_Ip]}" | awk -F. '{printf "%s.%s.%s.",$1,$2,$3}')
        start_Ip=${network_Address}${first_Ip}
        host_Address_Max=$(($(echo "${overoall[$add_Ip]}" | awk '{print $4}' | awk -F. '{printf "%s",$NF}')-1))
        prefix_1=$(echo ${overoall[$add_Ip]} | awk '{print $2}')
        netmask_1=$(echo "255.255.255.$((256-2**(32-$prefix_1)))")
        gateway_1=$(echo "${overoall[$add_Ip]}" | awk '{print $4}')

        

        step=$(echo ${overoall[$add_Ip]} | awk '{print $NF}')
        
cat >> ${network_Dir}${network_Card_File}-range${range_Num} << EOF
# ----- ADD IP Time：$modify_Time -----
DEVICE=${up_Card_Name}
ONBOOT=yes
IPADDR_START=$start_Ip
IPADDR_END=${network_Address}${host_Address_Max}
NETMASK=$netmask_1
GATEWAY=${gateway_1}
ARPCHECK=no
CLONENUM_START=${netcard_Cname}
EOF
        com_Overoall_Ip[${#com_Overoall_Ip[@]}]="${start_Ip} ${network_Address}${host_Address_Max} ${netmask_1} ${gateway_1}"
        let range_Num++
        let netcard_Cname+=$step

    done

fi

Complete_And_Output

}

### 2.4.6 Centos Stream 8 | 9 | 10 配置段


Configuration_Ip_Centos_Sream () {

### 取值段
#modify_Time=$(date "+%Y-%m-%d_%H:%M:%S")

#if [[ $system_Type -eq 1  && $release_2 -eq 8 ]]; then
#    network_Dir="/etc/sysconfig/network-scripts/"

#elif [[ $system_Type -eq 2  && $release -eq 8 ]]; then
#    network_Dir="/etc/sysconfig/network-scripts/"

#else
#    network_Dir="/etc/sysconfig/network-scripts/"
#fi

#[[ -d ${network_Dir}bak ]] || mkdir ${network_Dir}bak

up_Card_Conn=$(nmcli -g GENERAL.CONNECTION device show $up_Card_Name)
up_Card_Uuid=$(nmcli -g connection.uuid conn show "$up_Card_Conn")

#for file in $(ls ${network_Dir}ifcfg-*); do
#    egrep -q $up_Card_Uuid $file && up_Card_File=$file && network_Card_File=$(basename $file)
#done

#cp -a ${up_Card_File} ${network_Dir}bak/${network_Card_File}.bak.${modify_Time}
#echo -e "\n# ----- ADD IP Time：$modify_Time -----" >> ${up_Card_File}

### 配置IP段
if [[ ${#singleIP[@]} -gt 0 ]]; then

    for add_Ip in $(seq 0 1 $((${#singleIP[@]}-1))); do
        ip_1=$(echo ${singleIP[$add_Ip]} | awk '{print $1}')
        prefix_1=$(echo ${singleIP[$add_Ip]} | awk '{print $2}')
        netmask_1=$(echo "255.255.255.$((256-2**(32-$prefix_1)))")
        gateway_1=$(echo ${singleIP[$add_Ip]} | awk '{print $4}')

        nmcli connection modify "$up_Card_Conn" +ipv4.addresses ${ip_1}/${prefix_1}    
        com_Single_Ip[${#com_Single_Ip[@]}]="$ip_1 $netmask_1 $gateway_1"

    done

fi

if [[ ${#multi[@]} -gt 0 ]]; then

   for add_Ip in $(seq 0 1 $((${#multi[@]}-1))); do

            start_Ip=$(echo ${multi[$add_Ip]} | awk -F- '{print $1}')
            first_Ip=$(echo ${start_Ip} | awk -F. '{print $NF}' )
            network_Address=$(echo "${start_Ip}" | awk -F. '{printf "%s.%s.%s.",$1,$2,$3}')
            host_Address_Max=$(echo "${multi[$add_Ip]}" | awk -F- '{print $2}' | awk '{print $1}')
            prefix_1=$(echo ${multi[$add_Ip]} | awk '{print $2}')
            netmask_1="255.255.255.$((256-2**(32-$prefix_1)))"
            gateway_1=$(echo "${multi[$add_Ip]}" | awk '{print $4}')
        
            for add_Multi in $(seq ${first_Ip} 1 ${host_Address_Max}); do
                nmcli connection modify "$up_Card_Conn" +ipv4.addresses ${network_Address}${add_Multi}/${prefix_1} 
            done
            
            com_Multi_Ip[${#com_Multi_Ip[@]}]="${start_Ip} ${network_Address}${host_Address_Max} ${netmask_1} ${gateway_1}"

        done

fi

if [[ ${#overoall[@]} -gt 0 ]]; then

    for add_Ip in $(seq 0 1 $((${#overoall[@]}-1))); do

            first_Ip=$(($(echo ${overoall[$add_Ip]} | awk '{print $1}' | awk -F. '{print $NF}' )+1))
            network_Address=$(echo "${overoall[$add_Ip]}" | awk -F. '{printf "%s.%s.%s.",$1,$2,$3}')
            start_Ip=${network_Address}${first_Ip}
            host_Address_Max=$(($(echo "${overoall[$add_Ip]}" | awk '{print $4}' | awk -F. '{printf "%s",$NF}')-1))
            prefix_1=$(echo ${overoall[$add_Ip]} | awk '{print $2}')
            netmask_1=$(echo "255.255.255.$((256-2**(32-$prefix_1)))")
            gateway_1=$(echo "${overoall[$add_Ip]}" | awk '{print $4}')

            for add_overoall in $(seq ${first_Ip} 1 ${host_Address_Max}); do
                nmcli connection modify "$up_Card_Conn" +ipv4.addresses ${network_Address}${add_overoall}/${prefix_1}
            done

            com_Overoall_Ip[${#com_Overoall_Ip[@]}]="${start_Ip} ${network_Address}${host_Address_Max} ${netmask_1} ${gateway_1}"

        done

fi

Complete_And_Output


}

### 2.4.7  Ubuntu 16 IP配置段

Configuration_Ip_Ubuntu_16 () {


    ##### 取值段

    modify_Time=$(date "+%Y-%m-%d_%H:%M:%S")
   
    network_Card_File="/etc/network/interfaces"
    netcard_Cname=$(ip a | egrep "\<${up_Card_Name}:[[:digit:]]{0,}\>" | awk -F: '{print $NF}' | sort -nk1 | tail -1)
    [[ -z $netcard_Cname ]] && netcard_Cname=0 || let netcard_Cname++
    network_Dir="/etc/network/"
    [[ -d ${network_Dir}bak ]] || mkdir ${network_Dir}bak
    
    cp -a ${network_Card_File} ${network_Dir}bak/interfaces.bak.${modify_Time}
    echo -e "\n# ----- ADD IP Time: $modify_Time -----" >> ${network_Card_File}

    ####配置IP段
    if [[ ${#singleIP[@]} -gt 0 ]]; then
        
        for add_Ip in $(seq 0 1 $((${#singleIP[@]}-1))); do

            ip_1=$(echo ${singleIP[$add_Ip]} | awk '{print $1}')
            prefix_1=$(echo ${singleIP[$add_Ip]} | awk '{print $2}')
            netmask_1=$(echo "255.255.255.$((256-2**(32-$prefix_1)))")
            gateway_1=$(echo ${singleIP[$add_Ip]} | awk '{print $4}')
            
            cat >> ${network_Card_File} << EOF
auto ${up_Card_Name}:${netcard_Cname}
iface ${up_Card_Name}:${netcard_Cname} inet static
    address $ip_1
    netmask $netmask_1

EOF

            com_Single_Ip[${#com_Single_Ip[@]}]="$ip_1 $netmask_1 $gateway_1"
            let netcard_Cname++
        done

    fi
    
    if [[ ${#multi[@]} -gt 0 ]]; then
   
        for add_Ip in $(seq 0 1 $((${#multi[@]}-1))); do

            start_Ip=$(echo ${multi[$add_Ip]} | awk -F- '{print $1}')
            first_Ip=$(echo ${start_Ip} | awk -F. '{print $NF}' )
            network_Address=$(echo "${start_Ip}" | awk -F. '{printf "%s.%s.%s.",$1,$2,$3}')
            host_Address_Max=$(echo "${multi[$add_Ip]}" | awk -F- '{print $2}' | awk '{print $1}')
            prefix_1=$(echo ${multi[$add_Ip]} | awk '{print $2}')
            netmask_1="255.255.255.$((256-2**(32-$prefix_1)))"
            gateway_1=$(echo "${multi[$add_Ip]}" | awk '{print $4}')
        
            for add_Multi in $(seq ${first_Ip} 1 ${host_Address_Max}); do
                
                cat >> ${network_Card_File} << EOF
auto ${up_Card_Name}:${netcard_Cname}
iface ${up_Card_Name}:${netcard_Cname} inet static
    address ${network_Address}${add_Multi}
    netmask $netmask_1

EOF
            let netcard_Cname++

            done
            
            com_Multi_Ip[${#com_Multi_Ip[@]}]="${start_Ip} ${network_Address}${host_Address_Max} ${netmask_1} ${gateway_1}"

        done

    fi

    if [[ ${#overoall[@]} -gt 0 ]]; then

        for add_Ip in $(seq 0 1 $((${#overoall[@]}-1))); do

            first_Ip=$(($(echo ${overoall[$add_Ip]} | awk '{print $1}' | awk -F. '{print $NF}' )+1))
            network_Address=$(echo "${overoall[$add_Ip]}" | awk -F. '{printf "%s.%s.%s.",$1,$2,$3}')
            start_Ip=${network_Address}${first_Ip}
            host_Address_Max=$(($(echo "${overoall[$add_Ip]}" | awk '{print $4}' | awk -F. '{printf "%s",$NF}')-1))
            prefix_1=$(echo ${overoall[$add_Ip]} | awk '{print $2}')
            netmask_1=$(echo "255.255.255.$((256-2**(32-$prefix_1)))")
            gateway_1=$(echo "${overoall[$add_Ip]}" | awk '{print $4}')

            for add_overoall in $(seq ${first_Ip} 1 ${host_Address_Max}); do
                
                cat >> ${network_Card_File} << EOF
auto ${up_Card_Name}:${netcard_Cname}
iface ${up_Card_Name}:${netcard_Cname} inet static
    address ${network_Address}${add_overoall}
    netmask $netmask_1

EOF
                let netcard_Cname++

            done

            com_Overoall_Ip[${#com_Overoall_Ip[@]}]="${start_Ip} ${network_Address}${host_Address_Max} ${netmask_1} ${gateway_1}"

        done
        
    fi

    Complete_And_Output
     
}

######  Ubuntu  18.04 | 20.04 | 22.04 IP配置段
Configuration_Ip_Ubuntu_20 () {

    modify_Time=$(date "+%Y-%m-%d_%H:%M:%S")
    network_Card_File=$(ls /etc/netplan/*.yaml)
    network_Card_File_Count=$(ls /etc/netplan/*.yaml | wc -l)
    

    if [[ $network_Card_File_Count -gt 1 ]]; then
        echo "检测到存在多个网卡配置文件, 请手动处理" && sleep 3 
        break
    fi

    network_Dir="/etc/netplan/"
    [[ -d ${network_Dir}bak ]] || mkdir ${network_Dir}bak
    file=$(basename /etc/netplan/00-installer-config.yaml)
    
    cp -a ${network_Card_File} ${network_Dir}bak/${file}.bak.${modify_Time}

    if [[ $os_Release =~ 'Ubuntu 18' ]]; then
        modify_Info="# ----- ADD IP Time: $modify_Time  -----"

    else
        modify_Info="# ----- ADD IP Time: $modify_Time ↑↑↑↑↑ -----"

    fi

    sed -i "/^[[:space:]]\+${up_Card_Name}:/G" $network_Card_File
    sed  -i "/^[[:space:]]\+${up_Card_Name}:/a \\$modify_Info"   $network_Card_File

    if [[ ${#singleIP[@]} -gt 0 ]]; then
        
        for add_Ip in $(seq 0 1 $((${#singleIP[@]}-1))); do
 
            ip_1=$(echo ${singleIP[$add_Ip]} | awk '{print $1}')
            prefix_1=$(echo ${singleIP[$add_Ip]} | awk '{print $2}')
            netmask_1=$(echo "255.255.255.$((256-2**(32-$prefix_1)))")
            gateway_1=$(echo ${singleIP[$add_Ip]} | awk '{print $4}')

            ubu_Ip="      addresses: [${ip_1}/${prefix_1}]"
            sed -i "/^[[:space:]]\+${up_Card_Name}:/a \\$ubu_Ip" $network_Card_File

            com_Single_Ip[${#com_Single_Ip[@]}]="$ip_1 $netmask_1 $gateway_1"

        done

    fi
    
    if [[ ${#multi[@]} -gt 0 ]]; then
   
        for add_Ip in $(seq 0 1 $((${#multi[@]}-1))); do

            start_Ip=$(echo ${multi[$add_Ip]} | awk -F- '{print $1}')
            first_Ip=$(echo ${start_Ip} | awk -F. '{print $NF}' )
            network_Address=$(echo "${start_Ip}" | awk -F. '{printf "%s.%s.%s.",$1,$2,$3}')
            host_Address_Max=$(echo "${multi[$add_Ip]}" | awk -F- '{print $2}' | awk '{print $1}')
            prefix_1=$(echo ${multi[$add_Ip]} | awk '{print $2}')
            netmask_1="255.255.255.$((256-2**(32-$prefix_1)))"
            gateway_1=$(echo "${multi[$add_Ip]}" | awk '{print $4}')


            for add_Multi in $(seq ${first_Ip} 1 ${host_Address_Max}); do

                ubu_Ip="      addresses: [${network_Address}${add_Multi}/${prefix_1}]"
                sed -i "/^[[:space:]]\+${up_Card_Name}:/a \\$ubu_Ip" $network_Card_File

            done
          
            
            com_Multi_Ip[${#com_Multi_Ip[@]}]="${start_Ip} ${network_Address}${host_Address_Max} ${netmask_1} ${gateway_1}"

        done

        
    fi

    if [[ ${#overoall[@]} -gt 0 ]]; then

        for add_Ip in $(seq 0 1 $((${#overoall[@]}-1))); do

            first_Ip=$(($(echo ${overoall[$add_Ip]} | awk '{print $1}' | awk -F. '{print $NF}' )+1))
            network_Address=$(echo "${overoall[$add_Ip]}" | awk -F. '{printf "%s.%s.%s.",$1,$2,$3}')
            start_Ip=${network_Address}${first_Ip}
            host_Address_Max=$(($(echo "${overoall[$add_Ip]}" | awk '{print $4}' | awk -F. '{printf "%s",$NF}')-1))
            prefix_1=$(echo ${overoall[$add_Ip]} | awk '{print $2}')
            netmask_1=$(echo "255.255.255.$((256-2**(32-$prefix_1)))")
            gateway_1=$(echo "${overoall[$add_Ip]}" | awk '{print $4}')

            for add_overoall in $(seq ${first_Ip} 1 ${host_Address_Max}); do
                
                ubu_Ip="      addresses: [${network_Address}${add_overoall}/${prefix_1}]"
                sed  -i "/^[[:space:]]\+${up_Card_Name}:/a \\$ubu_Ip" $network_Card_File

            done

            com_Overoall_Ip[${#com_Overoall_Ip[@]}]="${start_Ip} ${network_Address}${host_Address_Max} ${netmask_1} ${gateway_1}"

        done
        
    fi

    Complete_And_Output
    
}




#### 配置完成输出段  Complete_And_Output

Complete_And_Output () {
    
    clear
    start_Out_Info_Title
    echo -e "--------------------------------------------------------------\n
您好，新分配的IP已配置到系统中，测试通信正常，信息如下:
Hello, the newly assigned IP address has been configured in the system, and the test communication is normal. The information is as follows:"
    [[ ${#com_Single_Ip[@]} -gt 0 ]] &&  echo ${com_Single_Ip[@]} | xargs -n 3 | awk '{printf "```\nServer IP: %s\nGateway: %s\nNetmask: %s\n```\n",$1,$3,$2}'
    [[ ${#com_Multi_Ip[@]} -gt 0 ]] && echo ${com_Multi_Ip[@]} | xargs -n 4 | awk '{printf "```\nServer IP: %s - %s\nGateway: %s\nNetmask: %s\n```\n",$1,$2,$4,$3}'
    [[ ${#com_Overoall_Ip[@]} -gt 0 ]] && echo ${com_Overoall_Ip[@]} | xargs -n 4 | awk '{printf "```\nServer IP: %s - %s\nGateway: %s\nNetmask: %s\n```\n",$1,$2,$4,$3}'
    echo -e "\033[32m--------------------------------------------------------------\033[0m"
    echo -e "\033[32m新配置IP需要重启网卡才能生效 | 输入1重启网卡 | 其他任意键返回主菜单。\033[0m" 
    echo -n "请输入："
    read -t 120 next_Want

    case $next_Want in
        1)
        incycle=2
        unset singleIP
        unset multi
        unset overoall
        unset badip
        netcard_Check_Complete=0
        restart_Network
        ;;

        *)
        incycle=2
        unset singleIP
        unset multi
        unset overoall
        unset badip
        netcard_Check_Complete=0
        ;;

    esac

}


### 2.5 网络测试


Americas=(
    "0"
    "硅谷:San Jose         "
    "洛杉矶:Los Angeles     "
    "纽约:New York"
    "亚特兰大:Atlanta       "
    "芝加哥:Chicago         "
    "达拉斯:Dallas          "
)

Asia=(
    "0"
    " 中国大陆:China         "
    " 香港:Hong Kong         "
    " 台湾:Taiwan            "
    "东京:Tokyo"
    "新加坡:Singapore       "
    "卢塞纳:Lucena          "
)

Europe=(
    "0"
    "法兰克福:Frankfurt"
    "伦敦:London"
    "阿姆斯特丹:Amsterdam"
    "马德里:Madrid"
    "曼彻斯特:Manchester"
    "巴黎:Paris"
)

Oceania=(
    "0"
    "悉尼:Sydney"
    "墨尔本:Melbourne"
)

Africa=(
    "0"
    "约翰内斯堡:Johannesburg"
)


speedtest_Check () {

    start_Out_Info_Title
    
    if command -v curl &>/dev/null; then
        printf "检测curl命令是否存在         \033[32m[True]\033[0m\n"
        curl_check=1
        wget_check=0

    else
        printf "检测curl命令是否存在         \033[31m[False]\033[0m\n"
        curl_check=0

        if command -v wget &>/dev/null; then
            printf "检测wget命令是否存在         \033[32m[True]\033[0m\n"
            wget_check=1
        else
            printf "检测wget命令是否存在         \033[31m[False]\033[0m\n"
            wget_check=0
        fi
    fi

    python_exec=$(which python3 2>/dev/null || which python)

    if command -v $python_exec &>/dev/null; then
        printf "检测python命令是否存在       \033[32m[True]\033[0m\n"
        python_check=1
        
    else
        printf "检测python是否存在       \033[31m[False]]\033[0m\n"
        python_check=0
        
    fi


    if [ "$python_check" -eq 1 ] && { [ "$curl_check" -eq 1 ] || [ "$wget_check" -eq 1 ]; }; then
        speedtest_Env=1
    else
        speedtest_Env=0
    fi
    
    if [ $speedtest_Env -eq 1 ]; then
        if command -v curl &>/dev/null; then
            curl -O http://198.200.51.51/speedtest-cli.py
            select_Zone
        else
            wget -O speedtest-cli.py http://198.200.51.51/speedtest-cli.py
            select_Zone
        fi

    else
        read -t 30 -p "测速脚本依赖python命令, curl命令或wget命令任意之一即可，请手动安装未检测到的命令, 按回车继续" incyle
        incycle=2

    fi

}

select_Zone () {

    start_Out_Info_Title

    echo -e "\033[1m请选择测速地区\033[0m\n"
    echo -e "           美洲            |            亚洲              |         欧洲\n"
    for i in {1..6}; do
        printf "%-1s. %-25s | %-1s. %-25s  | %-1s. %-25s\n\n"  "$i" "${Americas[$i]}" "$((i+6))" "${Asia[$i]}"  "$((i+12))" "${Europe[$i]}" | tr ':' '-'
    done
    echo "--------------------------------------------------------------------------------------"
    echo -e "         大洋洲            |            非洲\n"
    
    echo -e "19. 悉尼-Sydney            |  21.约翰内斯堡-Johannesburg\n"
    echo -e "20. 墨尔本-Melbourne\n"

    echo -e "\033[32m--------------------------------------------------------------------------------------\033[0m"
    echo "22: 返回上一级"
    echo "23: 退出脚本"

    speedtest_Location_Complete=1

    

    while [ $speedtest_Location_Complete -eq 1 ] ; do
        read -t 60  -p "请选择："  Zone_num

        [[ -z $Zone_num ]] && Zone_num=22
        [ $Zone_num == 'q' ] && Zone_num=22

        if [[ $Zone_num -ge 1 && $Zone_num -le 6 ]]; then
            speedtest_Zone='Americas'
            speedtest_Location_Complete=0
            
            
        elif [[ $Zone_num -ge 7 && $Zone_num -le 12 ]]; then
            speedtest_Zone='Asia'
            speedtest_Location_Complete=0
            Zone_num=$((Zone_num-6))
            

        elif [[ $Zone_num -ge 13 && $Zone_num -le 18 ]]; then
            speedtest_Zone='Europe'
            speedtest_Location_Complete=0
            Zone_num=$((Zone_num-12))
            

        elif [[ $Zone_num -ge 19 && $Zone_num -le 20 ]]; then
            speedtest_Zone='Oceania'
            speedtest_Location_Complete=0
            Zone_num=$((Zone_num-18))
            

        elif [[ $Zone_num -eq 21 ]]; then
            speedtest_Zone='Africa'
            speedtest_Location_Complete=0
            Zone_num=$((Zone_num-20))
            

        elif [ $Zone_num -eq 22 ]; then
            rm -rf speedtest-cli.py
            speedtest_Zone='null'
            speedtest_Location_Complete=2
            incycle=2

        elif [ $Zone_num -eq 23 ]; then
            speedtest_Location_Complete=2
            auto_Delete_Configuration
            
        else
            speedtest_Zone='error'
            echo "输入错误，请重新输入。"
        fi

    done

    if [ $speedtest_Location_Complete -eq 0 ]; then
        speedtest_Info
    fi

}

speedtest_Info () {

    start_Out_Info_Title

    if [ $speedtest_Zone == 'Americas' ]; then
        echo "选择的测速地区为： ${Americas[$Zone_num]}"
        select_Speedtest_Zone=$(echo ${Americas[$Zone_num]} | awk -F: '{print $2}')
        speedtest_List=$($python_exec speedtest-cli.py --search="$select_Speedtest_Zone" | grep -v "Retrieving" )
        speedtest_List_Count=$(echo $speedtest_List | tr -d '\n' | xargs -d] -n 1 | wc -l )
        [ $speedtest_List_Count -gt 10 ] && speedtest_List_Count=10

    elif [ $speedtest_Zone == 'Asia' ]; then
        echo "选择的测速地区为： ${Asia[$Zone_num]}"
        select_Speedtest_Zone=$(echo ${Asia[$Zone_num]} | awk -F: '{print $2}')
        speedtest_List=$($python_exec speedtest-cli.py --search="$select_Speedtest_Zone" | grep -v "Retrieving")
        speedtest_List_Count=$(echo $speedtest_List | tr -d '\n' | xargs -d] -n 1 | wc -l )
        [ $speedtest_List_Count -gt 10 ] && speedtest_List_Count=10

    elif [ $speedtest_Zone == 'Europe' ]; then
        echo "选择的测速地区为： ${Europe[$Zone_num]}"
        select_Speedtest_Zone=$(echo ${Europe[$Zone_num]} | awk -F: '{print $2}')
        speedtest_List=$($python_exec speedtest-cli.py --search="$select_Speedtest_Zone" | grep -v "Retrieving")
        speedtest_List_Count=$(echo $speedtest_List | tr -d '\n' | xargs -d] -n 1 | wc -l )
        [ $speedtest_List_Count -gt 10 ] && speedtest_List_Count=10

    elif [ $speedtest_Zone == 'Oceania' ]; then
        echo "选择的测速地区为： ${Oceania[$Zone_num]}"
        select_Speedtest_Zone=$(echo ${Oceania[$Zone_num]} | awk -F: '{print $2}')
        speedtest_List=$($python_exec speedtest-cli.py --search="$select_Speedtest_Zone" | grep -v "Retrieving")
        speedtest_List_Count=$(echo $speedtest_List | tr -d '\n' | xargs -d] -n 1 | wc -l )
        [ $speedtest_List_Count -gt 10 ] && speedtest_List_Count=10

    elif [ $speedtest_Zone == 'Africa' ]; then
        echo "选择的测速地区为： ${Africa[$Zone_num]}"
        select_Speedtest_Zone=$(echo ${Africa[$Zone_num]} | awk -F: '{print $2}')
        speedtest_List=$($python_exec speedtest-cli.py --search="$select_Speedtest_Zone" | grep -v "Retrieving")
        speedtest_List_Count=$(echo $speedtest_List | tr -d '\n' | xargs -d] -n 1 | wc -l )
        [ $speedtest_List_Count -gt 10 ] && speedtest_List_Count=10

    else
        echo
    fi


    for node in $(seq 1 $speedtest_List_Count); do
        server_Num=$(echo $speedtest_List | tr -d '\n' | xargs -d']' -n1 | awk -v line=$node 'NR==line' | egrep -o "^[[:space:]]{0,4}[0-9]+")
        server_Name=$(echo $speedtest_List | tr -d '\n' | xargs -d']' -n1 | awk -v line=$node 'NR==line' | grep -o ').*(' | tr -d '()' | xargs )
        server_Location=$(echo $speedtest_List | tr -d '\n' | xargs -d']' -n1 | awk -v line=$node 'NR==line' | grep -o "([[:alpha:][:space:],]\+) \[" | tr -d '()['| xargs )
        server_km=$(echo $speedtest_List | tr -d '\n' | xargs -d']' -n1 | awk -v line=$node 'NR==line' | grep -o '[[:digit:]]\+.[[:digit:]]\+ km')
        speedtest_Node[$node]=$(echo ${server_Num}:${server_Name}:${server_Location}:${server_km})
    done



    echo -e "\n\033[1m节点序号    节点名称                           区域                      距离\033[0m"
    echo -e "\033[32m--------------------------------------------------------------------------------------\033[0m"

    for node_Info in $(seq 1 $speedtest_List_Count);do
        echo "${speedtest_Node[$node_Info]}" | awk -F: -v num=$node_Info '{printf "   %-6s %-30s %-30s %s\n\n", num,$2,$3,$4}'
    done

    echo -e "\033[32m--------------------------------------------------------------------------------------\033[0m"

    echo "$((speedtest_List_Count+1)): 返回上一级"
    echo "$((speedtest_List_Count+2)): 随机测试3节点"
    echo "$((speedtest_List_Count+3)): 退出脚本"

    read -t 60 -p "请输入对应节点的序号: " node_num
    [ -z $node_num ] && node_num=$((speedtest_List_Count+1))
    [ $node_num == 'q' ] && node_num=$((speedtest_List_Count+1))

    if [[ -n ${speedtest_Node[$node_num]} ]]; then
        start_Out_Info_Title
        select_Node=$(echo ${speedtest_Node[$node_num]} | awk -F: '{print $1}')
        start_Speedtest
        speedtest_out
        
    elif [[ $node_num -eq $((speedtest_List_Count+1)) ]]; then
        rm -rf speedtest-cli.py
        incycle=2

    elif [[ $node_num -eq $((speedtest_List_Count+2)) ]]; then
        start_Out_Info_Title
        node_num1=0
        node_num2=0
        node_num3=0
        random_com=1

        while [ $random_com -eq 1 ];do

            if [[ $node_num1 -ne $node_num2 && $node_num2 -ne $node_num3 && $node_num1 -ne $node_num3 && $node_num1 -ne 0 && $node_num2 -ne 0 && $node_num3 -ne 0 ]]; then
                random_com=2
            else
                node_num1=$((RANDOM%speedtest_List_Count))
                node_num2=$((RANDOM%speedtest_List_Count))
                node_num3=$((RANDOM%speedtest_List_Count))
            fi

        done
        
        node_num=$node_num1
        select_Node=$(echo ${speedtest_Node[$node_num]} | awk -F: '{print $1}')
        start_Speedtest

        node_num=$node_num2
        select_Node=$(echo ${speedtest_Node[$node_num]} | awk -F: '{print $1}')
        start_Speedtest

        node_num=$node_num3
        select_Node=$(echo ${speedtest_Node[$node_num]} | awk -F: '{print $1}')
        start_Speedtest
        speedtest_out

    elif [[ $node_num -eq $((speedtest_List_Count+3)) ]]; then
        auto_Delete_Configuration
        
    fi

}

start_Speedtest () {
    echo -e "\033[1m测速节点: $(echo ${speedtest_Node[$node_num]} | awk -F: '{printf "%-s --- %-s", $2,$3}')\033[0m"
    echo -e "\033[32m----------------------------------------------------------------------------------\033[0m"

    speedtest_result=$($python_exec speedtest-cli.py --search="$select_Speedtest_Zone" --server "$select_Node" --share --json)
    timestamp=$(echo $speedtest_result | egrep -o 'timestamp": "202[0-9]-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}' | awk -F'"' '{print $3}' | awk -FT '{print $1,$2}')
    ping_ms=$(echo $speedtest_result | egrep -o 'ping": [[:digit:]]+\.[[:digit:]]+' | awk -F: '{print $2}' | xargs)
    download_Bps=$(echo $speedtest_result | egrep -o 'download": [[:digit:]]+\.[[:digit:]]+' | awk -F: '{print $2}' | xargs)
    download_Mbps=$(echo "$download_Bps 1000000" | awk '{printf "%.2f",$1/$2}')
    upload_Bps=$(echo $speedtest_result |  egrep -o 'upload": [[:digit:]]+\.[[:digit:]]+' | awk -F: '{print $2}' | xargs)
    upload_Mbps=$(echo "$upload_Bps 1000000" | awk '{printf "%.2f",$1/$2}')
    test_Ip=$(echo $speedtest_result | egrep -o 'ip":.*lat"' | awk -F'"' '{print $3}' )
    speedtest_Url=$(echo $speedtest_result |egrep -o 'share": "http://.*png' | awk -F'"' '{print $3}')
    


    echo -e "下载带宽: ${download_Mbps} Mbps   上传带宽: ${upload_Mbps} Mbps\n"
    echo -e "测速IP: $test_Ip     UTC时间戳: $timestamp   ping 延迟：${ping_ms} ms\n"
    echo -e "测速结果URL: $speedtest_Url\n\n"
}

speedtest_out () {
   echo -e "\033[32m-------------------------------------------------------------------\033[0m"
   read -t 300 -p "按任意键返回上一级" incycle
   incycle=2

}


### 2.7 镜像文件

if_Mirror_Complete () {

    if [ $? -eq 0 ]; then

            printf "生成镜像源 源数据          \033[32m[成功]\033[0m\n"
            mirror_Complete=1
        else
            printf "生成镜像源 源数据        \033[31m[失败]\033[0m\n"
            mirror_Complete=1
        fi


}

Mirror_Suppot () {

    if [[ $system_Type -ge 1 && $system_Type -le 4 ]]; then
        start_Out_Info_Title
        echo -e "\033[32m--- 拉取Rak Mirror File    ----------------------------\033[0m"
        printf "%-2s %-29s" "OS:" "${system_List[$system_Type]} $release" 
        printf "\033[32m[支持]\033[0m\n"
        ping_Mirror-Sv

    else
        start_Out_Info_Title
        echo -e "\033[32m--- 拉取Rak Mirror File    ----------------------------\033[0m"
        printf "%-2s %-29s" "OS:" "${system_List[$system_Type]} $release"
        printf "\033[31m[不支持]\033[0m\n\n"
        read  -t 30 -p "按回车键返回" incycle
        incycle=2
    fi
}

ping_Mirror-Sv () {
    if ping -c 2 -w 2 mirror-sv.raksmart.com &> /dev/null; then
        printf "链接mirror-sv.raksmart.com       \033[32m[正常]\033[0m\n"
        Mirror_Ping_Complete=1
    
    else
        printf "链接mirror-sv.raksmart.com       \033[31m[失败]\033[0m\n\n"
        read  -t 30 -p "按回车键返回" incycle
        Mirror_Ping_Complete=2
        incycle=2
    fi
}


pull_Mirror_File () {
    mv_time=$(date "+%Y-%m-%d_%H:%M:%S")
    start_Out_Info_Title
    echo -e "\033[32m--- 拉取Rak Mirror File    ----------------------------\033[0m"

    if [[ $system_Type -eq 1 && $release_2 -eq 7 ]]; then
    
        mkdir /etc/yum.repos.d/bak-$mv_time && 	mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak-$mv_time && \
        printf "备份已存在的yum文件       \033[32m[成功]\033[0m\n" || printf "备份已存在的yum文件       \033[31m[失败]\033[0m\n"

        curl -o /etc/yum.repos.d/CentOS-7-repo_file_All_In_One.tar.xz http://mirror-sv.raksmart.com/mirror-sv_source_file/centos-7/CentOS-7-repo_file_All_In_One.tar.xz  &>/dev/null && \
        curl -o /etc/yum.repos.d/CentOS-7-epel_file_All_In_One.tar.xz http://mirror-sv.raksmart.com/mirror-sv_source_file/epel/CentOS-7-epel_file_All_In_One.tar.xz  &>/dev/null && \
        printf "拉取yum文件               \033[32m[成功]\033[0m\n" || printf "拉取yum文件               \033[31m[失败]\033[0m\n"

        tar xf /etc/yum.repos.d/CentOS-7-repo_file_All_In_One.tar.xz -C /etc/yum.repos.d/  && \
        tar xf /etc/yum.repos.d/CentOS-7-epel_file_All_In_One.tar.xz -C /etc/yum.repos.d/  && \
        printf "解压缩                    \033[32m[成功]\033[0m\n" || printf "解压缩                    \033[31m[失败]\033[0m\n"

        rm -f /etc/yum.repos.d/CentOS-7-repo_file_All_In_One.tar.xz && \
        rm -f /etc/yum.repos.d/CentOS-7-epel_file_All_In_One.tar.xz && \
        printf "清理压缩包                \033[32m[成功]\033[0m\n" || printf "清理压缩包              \033[31m[失败]\033[0m\n"


        yum clean all  &>/dev/null &&  printf "清理旧yum源缓存           \033[32m[成功]\033[0m\n" || printf "清理旧yum源缓存         \033[31m[失败]\033[0m\n"
        yum makecache &>/dev/null
        
        if_Mirror_Complete


    elif [[ $system_Type -eq 1 && $release_2 -eq 8 ]]; then
        mkdir /etc/yum.repos.d/bak-$mv_time && 	mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak-$mv_time && \
        printf "备份已存在的yum文件       \033[32m[成功]\033[0m\n" || printf "备份已存在的yum文件       \033[31m[失败]\033[0m\n"

        curl -o /etc/yum.repos.d/CentOS-8-repo_file_All_In_One.tar.xz http://mirror-sv.raksmart.com/mirror-sv_source_file/centos-8/CentOS-8-repo_file_All_In_One.tar.xz  &>/dev/null && \
        curl -o /etc/yum.repos.d/CentOS-8-epel_file_All_In_One.tar.xz http://mirror-sv.raksmart.com/mirror-sv_source_file/epel/CentOS-8-epel_file_All_In_One.tar.xz  &>/dev/null && \
        curl -o /etc/yum.repos.d/RPM-GPG-KEY-EPEL-8 http://mirror-sv.raksmart.com/epel/RPM-GPG-KEY-EPEL-8  &>/dev/null && \
        printf "拉取yum文件               \033[32m[成功]\033[0m\n" || printf "拉取yum文件               \033[31m[失败]\033[0m\n"

        tar xf /etc/yum.repos.d/CentOS-8-repo_file_All_In_One.tar.xz -C /etc/yum.repos.d/ && \
        tar xf /etc/yum.repos.d/CentOS-8-epel_file_All_In_One.tar.xz -C /etc/yum.repos.d/ && \
        printf "解压缩                    \033[32m[成功]\033[0m\n" || printf "解压缩                    \033[31m[失败]\033[0m\n"

        rpm --import /etc/yum.repos.d/RPM-GPG-KEY-EPEL-8
        rm -f /etc/yum.repos.d/CentOS-8-repo_file_All_In_One.tar.xz && \
        rm -f /etc/yum.repos.d/CentOS-8-epel_file_All_In_One.tar.xz && \
        rm -f /etc/yum.repos.d/RPM-GPG-KEY-EPEL-8 && \
        printf "清理压缩包                \033[32m[成功]\033[0m\n" || printf "清理压缩包              \033[31m[失败]\033[0m\n"

        yum upgrade libmodulemd -qy &>/dev/null
        yum clean all &>/dev/null && printf "清理旧yum源缓存           \033[32m[成功]\033[0m\n" || printf "清理旧yum源缓存         \033[31m[失败]\033[0m\n"
        yum makecache &>/dev/null

        if_Mirror_Complete


    elif [[ $system_Type -eq 2 && $release -eq 8 ]]; then
        mkdir /etc/yum.repos.d/bak-$mv_time && 	mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak-$mv_time && \
        printf "备份已存在的yum文件       \033[32m[成功]\033[0m\n" || printf "备份已存在的yum文件       \033[31m[失败]\033[0m\n"

        curl -o /etc/yum.repos.d/CentOS-Stream-8-repo_file_All_In_One.tar.xz http://mirror-sv.raksmart.com/mirror-sv_source_file/centos-stream-8/CentOS-Stream-8-repo_file_All_In_One.tar.xz &>/dev/null && \
        curl -o /etc/yum.repos.d/CentOS-8-epel_file_All_In_One.tar.xz http://mirror-sv.raksmart.com/mirror-sv_source_file/epel/CentOS-8-epel_file_All_In_One.tar.xz &>/dev/null && \
        printf "拉取yum文件               \033[32m[成功]\033[0m\n" || printf "拉取yum文件               \033[31m[失败]\033[0m\n"
        
        tar xf /etc/yum.repos.d/CentOS-Stream-8-repo_file_All_In_One.tar.xz -C /etc/yum.repos.d/ && \
        tar xf /etc/yum.repos.d/CentOS-8-epel_file_All_In_One.tar.xz -C /etc/yum.repos.d/ && \
        printf "解压缩                    \033[32m[成功]\033[0m\n" || printf "解压缩                    \033[31m[失败]\033[0m\n"

        rm -f /etc/yum.repos.d/CentOS-Stream-8-repo_file_All_In_One.tar.xz && \
        rm -f /etc/yum.repos.d/CentOS-8-epel_file_All_In_One.tar.xz && \
        printf "清理压缩包                \033[32m[成功]\033[0m\n" || printf "清理压缩包              \033[31m[失败]\033[0m\n"

        yum clean all &>/dev/null && printf "清理旧yum源缓存           \033[32m[成功]\033[0m\n" || printf "清理旧yum源缓存         \033[31m[失败]\033[0m\n"
        yum makecache &>/dev/null

        if_Mirror_Complete


    elif [[ $system_Type -eq 2 && $release -eq 9 ]]; then
        mkdir /etc/yum.repos.d/bak-$mv_time && 	mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak-$mv_time && \
        printf "备份已存在的yum文件       \033[32m[成功]\033[0m\n" || printf "备份已存在的yum文件       \033[31m[失败]\033[0m\n"

        curl -o /etc/yum.repos.d/centos-addons.repo http://mirror-sv.raksmart.com/mirror-sv_source_file/centos-stream-9/centos-addons.repo &>/dev/null && \
        curl -o /etc/yum.repos.d/centos.repo http://mirror-sv.raksmart.com/mirror-sv_source_file/centos-stream-9/centos.repo &>/dev/null && \
        curl -o /etc/yum.repos.d/CentOS-9stream-epel_file_All_In_One.tar.xz http://mirror-sv.raksmart.com/mirror-sv_source_file/epel/CentOS-9stream-epel_file_All_In_One.tar.xz &>/dev/null && \
        printf "拉取yum文件               \033[32m[成功]\033[0m\n" || printf "拉取yum文件               \033[31m[失败]\033[0m\n"

        tar xf /etc/yum.repos.d/CentOS-9stream-epel_file_All_In_One.tar.xz -C /etc/yum.repos.d/ && \
        printf "解压缩                    \033[32m[成功]\033[0m\n" || printf "解压缩                    \033[31m[失败]\033[0m\n"

        yum clean all &>/dev/null && printf "清理旧yum源缓存           \033[32m[成功]\033[0m\n" || printf "清理旧yum源缓存         \033[31m[失败]\033[0m\n"
        yum makecache  &>/dev/null

        if_Mirror_Complete

    elif [[ $system_Type -eq 3 && $release -eq 10 ]]; then
        mv /etc/apt/sources.list /etc/apt/sources.list.$mv_time && \
        printf "备份已存在的sources.list文件       \033[32m[成功]\033[0m\n" || printf "备份已存在的sources.list文件       \033[31m[失败]\033[0m\n"

        wget http://mirror-sv.raksmart.com/mirror-sv_source_file/debian/debian10_sources.list -O /etc/apt/sources.list  &>/dev/null && \
        printf "拉取sources.list文件               \033[32m[成功]\033[0m\n" || printf "拉取sources.list文件               \033[31m[失败]\033[0m\n"
        
        apt update  &>/dev/null
        if_Mirror_Complete

    elif [[ $system_Type -eq 3 && $release -eq 11 ]]; then
        mv /etc/apt/sources.list /etc/apt/sources.list.$mv_time && \
        printf "备份已存在的sources.list文件       \033[32m[成功]\033[0m\n" || printf "备份已存在的sources.list文件       \033[31m[失败]\033[0m\n"

        wget http://mirror-sv.raksmart.com/mirror-sv_source_file/debian/debian11_sources.list -O /etc/apt/sources.list &>/dev/null && \
        printf "拉取sources.list文件               \033[32m[成功]\033[0m\n" || printf "拉取sources.list文件               \033[31m[失败]\033[0m\n"

        apt update &>/dev/null

        if_Mirror_Complete

    elif [[ $system_Type -eq 3 && $release -eq 12 ]]; then
        mv /etc/apt/sources.list /etc/apt/sources.list.$mv_time && \
        printf "备份已存在的sources.list文件       \033[32m[成功]\033[0m\n" || printf "备份已存在的sources.list文件       \033[31m[失败]\033[0m\n"

        wget http://mirror-sv.raksmart.com/mirror-sv_source_file/debian/debian12_sources.list -O /etc/apt/sources.list &>/dev/null && \
        printf "拉取sources.list文件               \033[32m[成功]\033[0m\n" || printf "拉取sources.list文件               \033[31m[失败]\033[0m\n"

        apt update &>/dev/null

        if_Mirror_Complete

    elif [[ $system_Type -eq 4 && $release_2 -eq 14 ]]; then
        mv /etc/apt/sources.list /etc/apt/sources.list.$mv_time && \
        printf "备份已存在的sources.list文件       \033[32m[成功]\033[0m\n" || printf "备份已存在的sources.list文件       \033[31m[失败]\033[0m\n"

        wget http://mirror-sv.raksmart.com/mirror-sv_source_file/ubuntu/ubuntu_14.04_sources.list -O /etc/apt/sources.list &>/dev/null && \
        printf "拉取sources.list文件               \033[32m[成功]\033[0m\n" || printf "拉取sources.list文件               \033[31m[失败]\033[0m\n"

        apt update &>/dev/null

        if_Mirror_Complete

    elif [[ $system_Type -eq 4 && $release_2 -eq 16 ]]; then
        mv /etc/apt/sources.list /etc/apt/sources.list.$mv_time && \
        printf "备份已存在的sources.list文件       \033[32m[成功]\033[0m\n" || printf "备份已存在的sources.list文件       \033[31m[失败]\033[0m\n"

        wget http://mirror-sv.raksmart.com/mirror-sv_source_file/ubuntu/ubuntu_16.04_sources.list -O /etc/apt/sources.list &>/dev/null && \
        printf "拉取sources.list文件               \033[32m[成功]\033[0m\n" || printf "拉取sources.list文件               \033[31m[失败]\033[0m\n"
        apt update &>/dev/null

        if_Mirror_Complete

    elif [[ $system_Type -eq 4 && $release_2 -eq 18 ]]; then
        mv /etc/apt/sources.list /etc/apt/sources.list.$mv_time && \
        printf "备份已存在的sources.list文件       \033[32m[成功]\033[0m\n" || printf "备份已存在的sources.list文件       \033[31m[失败]\033[0m\n"

        wget http://mirror-sv.raksmart.com/mirror-sv_source_file/ubuntu/ubuntu_18.04_sources.list -O /etc/apt/sources.list &>/dev/null && \
        printf "拉取sources.list文件               \033[32m[成功]\033[0m\n" || printf "拉取sources.list文件               \033[31m[失败]\033[0m\n"

        apt update &>/dev/null

        if_Mirror_Complete

    elif [[ $system_Type -eq 4 && $release_2 -eq 20 ]]; then
        mv /etc/apt/sources.list /etc/apt/sources.list.$mv_time && \
        printf "备份已存在的sources.list文件       \033[32m[成功]\033[0m\n" || printf "备份已存在的sources.list文件       \033[31m[失败]\033[0m\n"

        wget http://mirror-sv.raksmart.com/mirror-sv_source_file/ubuntu/ubuntu_20.04_sources.list -O /etc/apt/sources.list  &>/dev/null && \
        printf "拉取sources.list文件               \033[32m[成功]\033[0m\n" || printf "拉取sources.list文件               \033[31m[失败]\033[0m\n"
        apt update &>/dev/null

        if_Mirror_Complete

    elif [[ $system_Type -eq 4 && $release_2 -eq 22 ]]; then
        mv /etc/apt/sources.list /etc/apt/sources.list.$mv_time && \
        printf "备份已存在的sources.list文件       \033[32m[成功]\033[0m\n" || printf "备份已存在的sources.list文件       \033[31m[失败]\033[0m\n"

        wget http://mirror-sv.raksmart.com/mirror-sv_source_file/ubuntu/ubuntu_22.04_sources.list -O /etc/apt/sources.list  &>/dev/null && \
        printf "拉取sources.list文件               \033[32m[成功]\033[0m\n" || printf "拉取sources.list文件               \033[31m[失败]\033[0m\n"

        apt update &>/dev/null

        if_Mirror_Complete

    elif [[ $system_Type -eq 4 && $release_2 -eq 23 ]]; then
        mv /etc/apt/sources.list /etc/apt/sources.list.$mv_time && \
        printf "备份已存在的sources.list文件       \033[32m[成功]\033[0m\n" || printf "备份已存在的sources.list文件       \033[31m[失败]\033[0m\n"

        release=$(echo $release | awk -F. '{print $NF}')

        if [ $release -eq 10 ];then
	        wget http://mirror-sv.raksmart.com/mirror-sv_source_file/ubuntu/ubuntu_23.10_sources.list -O /etc/apt/sources.list  &>/dev/null && \
            printf "拉取sources.list文件               \033[32m[成功]\033[0m\n" || printf "拉取sources.list文件               \033[31m[失败]\033[0m\n"

	    else
	        wget http://mirror-sv.raksmart.com/mirror-sv_source_file/ubuntu/ubuntu_23.04_sources.list -O /etc/apt/sources.list &>/dev/null && \
            printf "拉取sources.list文件               \033[32m[成功]\033[0m\n" || printf "拉取sources.list文件               \033[31m[失败]\033[0m\n"
	    fi

	    apt update &>/dev/null

        if_Mirror_Complete

    elif [[ $system_Type -eq 4 && $release_2 -eq 24 ]]; then
        mv /etc/apt/sources.list /etc/apt/sources.list.$mv_time && \
        printf "备份已存在的sources.list文件       \033[32m[成功]\033[0m\n" || printf "备份已存在的sources.list文件       \033[31m[失败]\033[0m\n"

        wget http://mirror-sv.raksmart.com/mirror-sv_source_file/ubuntu/ubuntu_24.04_sources.list -O /etc/apt/sources.list &>/dev/null && \
        printf "拉取sources.list文件               \033[32m[成功]\033[0m\n" || printf "拉取sources.list文件               \033[31m[失败]\033[0m\n"

        apt update &>/dev/null

        if_Mirror_Complete
    fi



    if [ $mirror_Complete -eq 1 ]; then
        sub_Footer_Out
        read -t 240 -p '替换完成，按回车键返回' incycle
        incycle=2
    else
        sub_Footer_Out
        read -t 240 -p '替换失败，请手动排查问题，按回车键返回' incycle
        incycle=2
    fi
}


### 2.8  修改远程端口 

######## 2.8.1 远程端口检测
sshd_Info () {

    start_Out_Info_Title
    echo -e "\033[32m--- 修改远程端口        ------------------------------------\033[0m"

    ssh_Port_Listen=$(ss -tnlp  | grep "\<sshd\>" | awk -F: '{print $2}' | awk '{print $1}')
    ssh_Port_Config=$(grep "^Port[[:space:]][[:digit:]]\{2,6\}" /etc/ssh/sshd_config | awk '{print $2}')

    echo "本机sshd服务监听的端口为：$ssh_Port_Listen   配置文件中设置的端口为: $ssh_Port_Config"

    sub_Footer_Out

}
    
######### 2.8.2  远程端口修改
next_Page_Sshd () {

if [ $again_Output -eq 1 ]; then

    echo "1: 返回上一级"
    echo "2: 重新检查"
    echo "3: 重启sshd服务"
    echo "4: 退出脚本"

fi        

read -p "直接输入选项序号或端口号(1024-65535): " next_Want

[[ $next_Want == 'q' ]] && next_Want=1
[[ $next_Want =~ ^[0-9]+$ ]] || next_Want=invalid 
            
if [ $next_Want == invalid ]; then
    echo "非法数值, 请重新输入"
    again_Test=2
    again_Output=2
        
elif [ $next_Want -eq 1 ]; then
    incycle=2
          
elif [ $next_Want -eq 2 ]; then
    again_Test=1

elif [ $next_Want -eq 3 ]; then
    systemctl restart sshd.service && echo "sshd服务重启成功，3秒后自动重新检测。" || echo "sshd服务重启失败,请手动排查问题"
    sleep 5

elif [ $next_Want -eq 4 ]; then
   auto_Delete_Configuration

elif [ $next_Want -gt 65535 ]; then
    echo "不支持65535之后的端口，请重新输入"
    again_test=2
    again_Output=2

elif [ $next_Want -lt 1024 ]; then
    echo "不支持小于1024的端口，请重新输入"
    again_Test=2
    again_Output=2
 
elif [ $next_Want -eq $ssh_Port_Listen ]; then
    echo "目前监听的就是${ssh_Port_Listen}端口"
    again_Output=2
    again_Test=2

elif [[ $next_Want -ge 1024 && $next_Want -le 65535 ]];then
    local_Listen_Port=($(ss -tnl | awk -F: '/^LISTEN/{print $2}' | awk '{print $1}'))
    want_Port=($next_Want)
    port_Comm=($(comm -1 -2 <(printf "%s\n" ${want_Port[@]} | sort) <(printf "%s\n" ${local_Listen_Port[@]} | sort)))

    if [ ${#port_Comm[@]} -ne 0 ]; then
        echo "目前本机有监听${next_Want}端口的服务."
        again_Test=2
        again_Output=2

    else
        echo "正在修改端口...." &&  sed -i "/^Port/s/Port.*/Port ${next_Want}/" /etc/ssh/sshd_config && systemctl restart sshd.service
        [ $? -eq 0 ] && echo "远程端口修改成功，3秒后自动重新检测....." || echo "远程端口修改失败，请手动排查问题"
        iptables -I INPUT -p tcp --dport $next_Want -j ACCEPT && echo "防火墙已打开, 放行端口: $next_Want"
        again_Test=1
        again_Output=1
        sleep 5
    fi

else 

    echo "输入错误，请重新输入"
    again_Test=2
    again_Output=2
fi

}

##### 2.9  修改时区

timezones_Info () {

Count_List=("零" "一" "二" "三" "四" "五" "六" "七" "八" "九" "十")
Current_Location=$(timedatectl | awk '/Time/{print $3}')
eorw=$(timedatectl | awk -F, '/Time/{print $NF}')
eorw=${eorw:1:1}
how=$(timedatectl | awk -F, '/Time/{print $NF}')
how=${how:2:2}
how=$((10#$how))

local_time=$(date +"%Y年%m月%d日 %H时%M分")
utc_Time=$(timedatectl | awk '/Universal/{print $5}' | awk -F: '{printf "%-2s时%-2s分\n",$1,$2}')
utc_Day=$(timedatectl | awk '/Universal/{print $4}'| awk -F- '{printf "%-4s年%-2s月%-2s日\n",$1,$2,$3}')


for i in {1..10}; do

    if [ $i -eq $how ]; then
       how1="${Count_List[$i]}"
    fi

done

[ $eorw == "+" ] && eorw="东"
[ $eorw == "-" ] && eorw="西"
[[ $how -eq 10 ]] && how1=("${Count_List[10]}")
[[ $how -eq 11 ]] && how1=("${Count_List[10]}${Count_List[1]}")
[[ $how -eq 12 ]] && how1=("${Count_List[10]}${Count_List[2]}")


timezones=(
  "0"
  "1.  西十二区 (IDLW-国际换日线) UTC-12:00"
  "2.  西十一区 (SST-美属萨摩亚标准时间) UTC-11:00"
  "3.  西十区   (HST-夏威夷－阿留申标准时间) UTC-10:00"
  "4.  西九区   (AKST-阿拉斯加标准时间) UTC-09:00"
  "5.  西八区   (PST-北美太平洋标准时间) UTC-08:00 SV/LA-同为洛杉矶时区"
  "6.  西七区   (MST-北美山区标准时间) UTC-07:00"
  "7.  西六区   (CST-北美中部标准时间) UTC-06:00"
  "8.  西五区   (EST-北美东部标准时间) UTC-05:00"
  "9.  西四区   (ART-阿根廷时间) UTC-04:00"
  "10. 西三区   (GST-南乔治亚时间) UTC-03:00"
  "11. 西二区   (CVT-佛得角时间) UTC-02:00"
  "12. 西一区   (AZOT-亚速尔群岛时间) UTC-01:00"
  "13. 零时区 (WET:欧洲西部时区,GMT:格林尼治标准时间) UTC±00:00"
  "14. 东一区 (CET-中欧时间) UTC+01:00 FR机房时区"
  "15. 东二区 (EET-东欧时间) UTC+02:00"
  "16. 东三区 (MSK-莫斯科时间) UTC+03:00"
  "17. 东四区 (GST-阿拉伯标准时间) UTC+04:00"
  "18. 东五区 (AST-巴基斯坦标准时间) UTC+05:00"
  "19. 东六区 (IST-印度标准时间) UTC+06:00"
  "20. 东七区 (WAST-西亚标准时间) UTC+07:00"
  "21. 东八区 (CST-中国标准时间) UTC+08:00 HK/SG机房时区----26.SG时区"
  "22. 东九区 (JST-日本标准时间) UTC+09:00 TKY/KR机房时区---27.KR时区"
  "23. 东十区 (AEST-澳大利亚东部标准时间) UTC+10:00"
  "24. 东十一区 (VUT-瓦努阿图时间) UTC+11:00"
  "25. 东十二区 (NZST-新西兰标准时间) UTC+12:00"
)

start_Out_Info_Title
echo

printf "\033[1m系统时区：%s%s区-%s  |  系统时间：%-30s|   UTC时间：%s %s\033[0m\n" "$eorw" "${how1[@]}" "$Current_Location"  "$local_time" "$utc_Day" "$utc_Time"
echo -e "\033[32m----------------------------------------------------------------------------------------------------------\033[0m"

for i in {1..25};do

    if [ $i -eq 2 ] ||  [ $i -eq 23 ];then
       echo ${timezones[i]} | awk '{printf "%-3s %-s\t %-20s\t\t  %-s\n", $1,$2,$3,$4}' 
    elif [ $i -eq 3 ]; then
       echo ${timezones[i]} | awk '{printf "%-3s %-s\t %-20s\t  %-s\n", $1,$2,$3,$4}' 
    elif [ $i -eq 5 ]; then
       echo ${timezones[i]} | awk '{printf "%-3s %-s\t %-20s\t\t  %-13s %s\n", $1,$2,$3,$4,$5}' 
    elif [ $i -eq 13 ]; then
       echo ${timezones[i]} | awk '{printf "%-3s %-s\t %-20s  %-s\n", $1,$2,$3,$4}' 
    elif [ $i -eq 14 ]; then
       echo ${timezones[i]} | awk '{printf "%-3s %-s\t %-35s  %-13s %s\n", $1,$2,$3,$4,$5}' 
    elif [ $i -eq 21 ] ||  [ $i -eq 22 ]; then
       echo ${timezones[i]} | awk '{printf "%-3s %-s\t %-33s  %-13s %s\n", $1,$2,$3,$4,$5}' 
    else 
       echo ${timezones[i]} | awk '{printf "%-3s %-s\t %-30s\t  %-s\n", $1,$2,$3,$4}' 
    fi

done

echo -e "\033[32m----------------------------------------------------------------------------------------------------------\033[0m"

}

next_Page_Timezones () {


zone_Cmd_List=(
"0 0 0 0"
"1 Etc/GMT+12 国际换日线 xi 12"
"2 Pacific/Midway 美国-中途岛 xi 11"
"3 Pacific/Honolulu 美国-檀香山 xi 10"
"4 America/Juneau 美国-阿拉斯加-朱诺 xi 9"
"5 America/Los_Angeles 美国-洛杉矶 xi 8"
"6 America/Phoenix 美国-凤凰城 xi 7"
"7 America/Chicago 美国-芝加哥 xi 6"
"8 America/New_York 美国-纽约 xi 5"
"9 America/Halifax 加拿大-哈利法克斯 xi 4"
"10 America/Araguaina 巴西-阿拉瓜伊纳 xi 3"
"11 America/Noronha 巴西-迪诺罗尼亚群岛 xi  2"
"12 Atlantic/Cape_Verde 佛得角 xi 1"
"13 UTC 英国伦敦格林威治标准时间"
"14 Europe/Paris 法国-巴黎 d 1"
"15 Europe/Athens 希腊-雅典 d 2"
"16 Europe/Moscow 俄罗斯-莫斯科 d 3"
"17 Asia/Dubai 阿拉伯联合酋长国-迪拜 d 4"
"18 Asia/Karachi 巴基斯坦-卡拉奇 d 5"
"19 Asia/Dhaka 孟加拉国-达卡 d 6"
"20 Asia/Bangkok 泰国-曼谷 d 7"
"21 Asia/Hong_Kong 中国-香港 d 8"
"22 Asia/Tokyo 日本-东京 d 9"
"23 Australia/Brisbane 澳大利亚-布里斯班 d 10"
"24 Pacific/Efate 瓦努阿图 d 11"
"25 Pacific/Fiji 斐济 d 12"
"26 Asia/Singapore 新加坡 d 8"
"27 Asia/Seoul 韩国-首尔 d 8"
)

if [ $again_Output -eq 1 ] ;then

    echo "28: 返回上一级"
    echo "29: 重新检测"
    echo "30: 退出脚本"

fi

read -p "输入对应的选项序号: " next_Want

[ -z $next_Want ] && next_Want='invalid'
[ $next_Want == 'q' ] && next_Want=28

[[ $next_Want =~ ^[0-9]{1,2}$ ]] || next_Want='invalid'

if [ $next_Want == 'invalid' ]; then
    echo "输入错误，请重新输入."
    again_Test=2
    again_Output=2

elif [[ $next_Want =~ ^0 ]]; then
    echo "不支持以0开头, 需要使用对应序号."
    again_Test=2
    again_Output=2

elif [ $next_Want -gt 30 ]; then
    echo "不支持这个选项, 请重新输入."
    again_Test=2
    again_Output=2


elif [ $next_Want -ge 1 ] && [ $next_Want -le 27 ]; then
    modify_Timezone_Zone=$(echo ${zone_Cmd_List[$next_Want]} | awk '{print $2}')
    modify_Timezone_Name=$(echo ${zone_Cmd_List[$next_Want]} | awk '{print $3}')
    timedatectl set-timezone $modify_Timezone_Zone && echo -e "已将时区修改为\033[1m ${modify_Timezone_Name}\033[0m, 3秒后自动重新检测"
    sleep 5

elif [ $next_Want -eq 28 ]; then
    incycle=2

elif [ $next_Want -eq 29 ]; then
    again_Test=1

elif [ $next_Want -eq 30 ]; then
    auto_Delete_Configuration

else 
    echo "输入错误, 请重新输入."
    again_Test=2
    again_Output=2

fi

}




###  3、主程序 


while true; do
    start_Out_Option
    
    case $want in
    1)
        in_Cycle hardware_Info next_Page
        ;;

    2)
        in_Cycle_For_Ipconn link_State next_Page_For_Ipconn
        ;;

    3)
        in_Cycle ip_Info next_Page
        ;;

    4)
        in_Cycle_For_Ip output_Ip_Modify_usage next_Want_Ip_1
        ;;

    5)
        in_Cycle_For_Speedtest speedtest_Check
        ;;
    
    6)
        echo "敬请期待" && sleep 3
        ;;

    7)
        in_Cycle_For_Pull_Mirror_File Mirror_Suppot next_Want_Mirror 
        ;;

    8)
        in_Cycle sshd_Info next_Page_Sshd
        ;;

    9)
        in_Cycle timezones_Info next_Page_Timezones
        ;;

    q)
        auto_Delete_Configuration
        ;;
        
    *)
        echo "不支持这个选项！"
        ;;

    esac
    
done
