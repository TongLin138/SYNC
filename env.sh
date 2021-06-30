#!/usr/bin/env bash
## Version: 1.0
## Author: SuperManito
## 目前仅支持 生成/更新 JD_COOKIE 全局环境变量脚本

## 路径
ShellDir=${JD_DIR:-$(
    cd $(dirname $0)
    pwd
)}
[ ${JD_DIR} ] && HelpJd=jd || HelpJd=jd.sh
ConfigDir=${ShellDir}/config
FileConf=${ConfigDir}/config.sh
SystemEnvFile=/etc/profile

## 导入config.sh
function Import_Conf() {
    if [ -f ${FileConf} ]; then
        . ${FileConf}
        if [ -z "${Cookie1}" ]; then
            echo -e "请先在config.sh中配置好Cookie...\n"
            exit 1
        fi
    else
        echo -e "配置文件 ${FileConf} 不存在，请先按教程配置好该文件...\n"
        exit 1
    fi
}

## 用户数量UserSum
function Count_UserSum() {
    for ((i = 1; i <= 35; i++)); do
        Tmp=Cookie$i
        CookieTmp=${!Tmp}
        [[ ${CookieTmp} ]] && UserSum=$i || break
    done
}

## 组合Cookie和互助码子程序
function Combin_Sub() {
    CombinAll=""
    for ((i = 1; i <= ${UserSum}; i++)); do
        for num in ${TempBlockCookie}; do
            if [[ $i -eq $num ]]; then
                continue 2
            fi
        done
        Tmp1=$1$i
        Tmp2=${!Tmp1}
        case $# in
        1)
            CombinAll="${CombinAll}&${Tmp2}"
            ;;
        2)
            CombinAll="${CombinAll}&${Tmp2}@$2"
            ;;
        3)
            if [ $(($i % 2)) -eq 1 ]; then
                CombinAll="${CombinAll}&${Tmp2}@$2"
            else
                CombinAll="${CombinAll}&${Tmp2}@$3"
            fi
            ;;
        4)
            case $(($i % 3)) in
            1)
                CombinAll="${CombinAll}&${Tmp2}@$2"
                ;;
            2)
                CombinAll="${CombinAll}&${Tmp2}@$3"
                ;;
            0)
                CombinAll="${CombinAll}&${Tmp2}@$4"
                ;;
            esac
            ;;
        esac
    done
    echo ${CombinAll} | perl -pe "{s|^&||; s|^@+||; s|&@|&|g; s|@+|@|g}"
}

function CreateENV() {
    grep -q "JD_COOKIE" ${SystemEnvFile} && sed -i "/JD_COOKIE/d" ${SystemEnvFile}
    echo "JD_COOKIE=$(Combin_Sub Cookie)" >>${SystemEnvFile}
    sed -i 's/JD_COOKIE=/export JD_COOKIE="/g' ${SystemEnvFile}
    sed -i '/export JD_COOKIE*/ s/$/"/' ${SystemEnvFile}
    source ${SystemEnvFile}
    echo -e "\nJD_COOKIE 环境变量已更新...\n"
}

Import_Conf
Count_UserSum
CreateENV