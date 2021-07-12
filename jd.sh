#!/usr/bin/env bash

## 路径
ShellDir=${JD_DIR:-$(
    cd $(dirname $0)
    pwd
)}
[ ${JD_DIR} ] && HelpJd=jd || HelpJd=jd.sh
ScriptsDir=${ShellDir}/scripts
ConfigDir=${ShellDir}/config
FileConf=${ConfigDir}/config.sh
FileConfSample=${ShellDir}/sample/config.sh.sample
LogDir=${ShellDir}/log
ListCron=${ConfigDir}/crontab.list

## 导入config.sh
function Import_Conf() {
    if [ -f ${FileConf} ]; then
        . ${FileConf}
        if [ -z "${Cookie1}" ]; then
            echo -e "\n\033[31m[ERROR]\033[0m 请先在 config.sh 配置文件中配置好 Cookie ！\n"
            exit 1
        fi
    else
        echo -e "\n\033[31m[ERROR]\033[0m 配置文件 ${FileConf} 不存在，请先按教程配置好该文件！\n"
        exit 1
    fi
}

## 更新crontab
function Detect_Cron() {
    if [[ $(cat ${ListCron}) != $(crontab -l) ]]; then
        crontab ${ListCron}
    fi
}

## 用户数量UserSum
function Count_UserSum() {
    for ((i = 1; i <= 35; i++)); do
        Tmp=Cookie$i
        CookieTmp=${!Tmp}
        [[ ${CookieTmp} ]] && UserSum=$i || break
    done

    for ((d = 36; d <= 2000; d++)); do
        Del=Cookie$d
        grep -q "Cookie36" ${FileConf} && sed -i "/${!Del}/d" ${FileConf} || break
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

## 组合全部变量
function Combin_All() {
    export JD_COOKIE=$(Combin_Sub Cookie)
    Combin_SHARECODES
}

## 组合Token与互助码
function Combin_SHARECODES() {
    ## 东东农场(jd_fruit.js)
    export FRUITSHARECODES=$(Combin_Sub ForOtherFruit)
    ## 东东萌宠(jd_pet.js)
    export PETSHARECODES=$(Combin_Sub ForOtherPet)
    ## 种豆得豆(jd_plantBean.js)
    export PLANT_BEAN_SHARECODES=$(Combin_Sub ForOtherBean)
    ## 东东工厂(jd_jdfactory.js)
    export DDFACTORY_SHARECODES=$(Combin_Sub ForOtherJdFactory)
    ## 京喜工厂(jd_dreamFactory.js)
    export DREAM_FACTORY_SHARE_CODES=$(Combin_Sub ForOtherDreamFactory)
    ## 京东赚赚(jd_jdzz.js)
    export JDZZ_SHARECODES=$(Combin_Sub ForOtherJdzz)
    ## 疯狂的Joy(jd_crazy_joy.js)
    export JDJOY_SHARECODES=$(Combin_Sub ForOtherJoy)
    ## 口袋书店(jd_bookshop.js)
    export BOOKSHOP_SHARECODES=$(Combin_Sub ForOtherBookShop)
    ## 签到领现金(jd_cash.js)
    export JD_CASH_SHARECODES=$(Combin_Sub ForOtherCash)
    ## 闪购盲盒(jd_sgmh.js)
    export JDSGMH_SHARECODES=$(Combin_Sub ForOtherSgmh)
    ## 京喜财富岛(jd_cfd.js)
    export JDCFD_SHARECODES=$(Combin_Sub ForOtherCfd)
    ## 东东健康社区(jd_health.js)
    export JDHEALTH_SHARECODES=$(Combin_Sub ForOtherHealth)
}

## 转换JD_BEAN_SIGN_STOP_NOTIFY或JD_BEAN_SIGN_NOTIFY_SIMPLE
function Trans_JD_BEAN_SIGN_NOTIFY() {
    case ${NotifyBeanSign} in
    0)
        export JD_BEAN_SIGN_STOP_NOTIFY="true"
        ;;
    1)
        export JD_BEAN_SIGN_NOTIFY_SIMPLE="true"
        ;;
    esac
}

## 转换UN_SUBSCRIBES
function Trans_UN_SUBSCRIBES() {
    export UN_SUBSCRIBES="${goodPageSize}\n${shopPageSize}\n${jdUnsubscribeStopGoods}\n${jdUnsubscribeStopShop}"
}

## 申明变量
function Set_Env() {
    Count_UserSum
    Trans_JD_BEAN_SIGN_NOTIFY
    Trans_UN_SUBSCRIBES
}

## 使用说明
function Help() {
    echo -e "本脚本的用法为："
    echo -e "1. bash ${HelpJd} list         # 查看可执行的活动脚本列表"
    echo -e "2. bash ${HelpJd} <xxx>        # 如果设置了随机延迟并且当时时间不在0-2、30-31、59分内，将随机延迟一定秒数"
    echo -e "3. bash ${HelpJd} <xxx> now    # 依次执行，无论是否设置了随机延迟，均立即运行，前台会输出日志，同时记录在日志文件中"
    echo -e "4. bash ${HelpJd} <xxx> conc   # 并发执行，无论是否设置了随机延迟，均立即运行，前台不产生日志，直接记录在日志文件中"
    echo -e "5. bash ${HelpJd} <xxx> <num>  # 指定某 Cookie 账号单独运行脚本，num为某 Cookie 账号在配置文件中的具体编号"
    echo -e "6. bash ${HelpJd} <url> raw    # 拉取远程仓库的脚本并通过方法3执行，在末尾加上可选参数 -p 可通过代理进行下载"
    echo -e "7. bash ${HelpJd} hangup       # 启动或重启后台挂机程序，目前不建议使用"
    echo -e "8. bash ${HelpJd} resetpwd     # 重置控制面板的用户名和密码"
    echo -e "9. source runall        # 执行所有活动脚本，非常耗时，Ctrl+Z 跳过执行当前脚本，Ctrl+C 退出执行"
    echo -e "\n支持运行 \"js、py、ts\" 三种类型的脚本，如果脚本同名则优先执行的是 \"js\" 脚本。"
    echo -e "针对用法 2~5 中的 \"xxx\" 为脚本名，可以不输入文件后缀格式，另外如果前缀是 \"jd_\" 的话前缀也可以省略。"
    echo -e "在最新版本镜像启动的容器中，bash ${HelpJd} 命令可以由 jtask 或 jd 代替，并且预装了 Python、TypeScript 环境。\n"
}

## 活动列表
function ScriptsList() {
    ListScripts=($(
        cd ${ScriptsDir}
        ls *.js | grep -E "j[drx]_" | grep -Eiv "jd_update.js|validate|api_test|env_copy"
    ))
    ListPythonScripts=($(
        cd ${ScriptsDir}
        ls *.py | grep -Eiv "getCookie.py|jdEnv|Notify"
    ))
    ListTypeScriptScripts=($(
        cd ${ScriptsDir}
        ls *.ts | grep -Eiv "ts_test|AGENTS|validate"
    ))
    ListOtherScripts=($(
        cd ${ScriptsDir}
        ls *.js | grep -Eiv "j[drx]_|$(git ls-files)|ShareCodes|AGENTS|index.js|validate|JDJR|MovementFaker|tencentscf|Notify|Cookie|Tokens|app.|main."
    ))
    cd ${ScriptsDir}
    echo -e "\n################################## 当前有以下活动脚本可以运行 ##################################"
    echo -e "\n注：所有以 jd、jr、jx 开头的js脚本会被识别成 Scripts 仓库的脚本，本地导入的脚本不会随更新而自动删除"

    echo -e "\nScripts 仓库的js脚本："
    for ((i = 0; i < ${#ListScripts[*]}; i++)); do
        grep -Eq "^[const $ = ].*Env" ${ListScripts[i]}
        if [ $? -eq 0 ]; then
            Name=$(grep -E "^[const $ = ].*Env" ${ListScripts[i]} | awk -F "'|\"" '{print $2}' | head -n 1)
        else
            Name=$(grep -w "script-path" ${ListScripts[i]} | sed "s/\W//g" | sed "s/[0-9a-zA-Z_]//g" | head -n 1)
        fi
        echo -e "$(($i + 1)).${Name}：${ListScripts[i]}"
    done

    echo -e "\nTypeScript 脚本（随缘使用）："
    for ((i = 0; i < ${#ListTypeScriptScripts[*]}; i++)); do
        if [ ${ListTypeScriptScripts[i]} = "jd_joy_park.ts" ]; then
            Name="汪汪乐园"
        elif [ ${ListTypeScriptScripts[i]} = "jd_jxmc.ts" ]; then
            Name="京喜牧场"
        elif [ ${ListTypeScriptScripts[i]} = "jd_qq_pasture.ts" ]; then
            Name="星系牧场"
        elif [ ${ListTypeScriptScripts[i]} = "jd_reward.ts" ]; then
            Name="宠汪汪兑换二代目"
        elif [ ${ListTypeScriptScripts[i]} = "jd_wishingPool.ts" ]; then
            Name="众筹许愿池"
        elif [ ${ListTypeScriptScripts[i]} = "jd_cfd.ts" ]; then
            Name="京喜财富岛"
        elif [ ${ListTypeScriptScripts[i]} = "jd_cfd_loop.ts" ]; then
            Name="京喜财富岛接待游客"
        else
            Name=""
        fi
        echo -e "$(($i + 1)).${Name}：${ListTypeScriptScripts[i]}"
    done

    echo -e "\nPython 脚本："
    for ((i = 0; i < ${#ListPythonScripts[*]}; i++)); do
        echo -e "$(($i + 1)).${ListPythonScripts[i]}"
    done

    echo -e "\n第三方脚本："
    for ((i = 0; i < ${#ListOtherScripts[*]}; i++)); do
        grep -Eq "^[const $ = ].*Env" ${ListOtherScripts[i]}
        if [ $? -eq 0 ]; then
            Name=$(grep -E "^[const $ = ].*Env" ${ListOtherScripts[i]} | awk -F "'|\"" '{print $2}' | head -n 1)
        else
            Name=$(grep -w "script-path" ${ListOtherScripts[i]} | sed "s/\W//g" | sed "s/[0-9a-zA-Z_]//g" | head -n 1)
        fi
        echo -e "$(($i + 1)).${Name}：${ListOtherScripts[i]}"
    done
    echo ''
}

## nohup
function Run_Nohup() {
    if [[ $(ps -ef | grep "${scripts}" | grep -v "grep") != "" ]]; then
        ps -ef | grep "${scripts}" | grep -v "grep" | awk '{print $2}' | xargs kill -9
    fi
    [ ! -d ${LogDir}/${scripts} ] && mkdir -p ${LogDir}/${scripts}
    LogTime=$(date "+%Y-%m-%d-%H-%M-%S")
    LogFile="${LogDir}/${scripts}/${LogTime}.log"
    nohup ts-node ${scripts}.ts >${LogFile} &
}

## 运行挂机脚本
function Run_HangUp() {
    HangUpScripts="jd_cfd_loop"
    cd ${ScriptsDir}
    for scripts in ${HangUpScripts}; do
        Import_Conf ${scripts}
        Set_Env
        Combin_All
        if type pm2 >/dev/null 2>&1; then
            pm2 stop ${scripts}.ts 2>/dev/null
            pm2 flush
            pm2 start -a ${scripts}.ts --interpreter /usr/bin/ts-node --watch "${ScriptsDir}/${scripts}.ts" --name="${scripts}"
        else
            Run_Nohup >/dev/null 2>&1
        fi
    done
}

## 重置密码
function Reset_Pwd() {
    cp -f ${ShellDir}/sample/auth.json ${ConfigDir}/auth.json
    echo -e "\033[32m[Done]\033[0m 控制面板登录密码重置成功，用户名：useradmin  密码：supermanito\n"
}

## 确认脚本
function Find_Script() {
    FileNameTmp1=$(echo $1 | perl -pe "{s|\.js||; s|\.py||; s|\.ts||}")
    FileNameTmp2=$(echo $1 | perl -pe "{s|jd_||; s|\.js||; s|\.py||; s|\.ts||; s|^|jd_|}")
    SeekDir="${ScriptsDir} ${ScriptsDir}/backUp ${ScriptsDir}/tools ${ConfigDir}"
    FileName=""
    WhichDir=""

    for dir in ${SeekDir}; do
        if [ -f ${dir}/${FileNameTmp1}.js ]; then
            FileName=${FileNameTmp1}
            FileFormat="js"
            WhichDir=${dir}
            break
        elif [ -f ${dir}/${FileNameTmp1}.py ]; then
            FileName=${FileNameTmp1}
            FileFormat="py"
            WhichDir=${dir}
            break
        elif [ -f ${dir}/${FileNameTmp1}.ts ]; then
            FileName=${FileNameTmp1}
            FileFormat="ts"
            WhichDir=${dir}
            break
        elif [ -f ${dir}/${FileNameTmp2}.js ]; then
            FileName=${FileNameTmp2}
            FileFormat="js"
            WhichDir=${dir}
            break
        elif [ -f ${dir}/${FileNameTmp2}.py ]; then
            FileName=${FileNameTmp2}
            FileFormat="py"
            WhichDir=${dir}
            break
        elif [ -f ${dir}/${FileNameTmp2}.ts ]; then
            FileName=${FileNameTmp2}
            FileFormat="ts"
            WhichDir=${dir}
            break
        fi
    done
}

## 随机延迟
function Random_Delay() {
    if [[ -n ${RandomDelay} ]] && [[ ${RandomDelay} -gt 0 ]]; then
        CurMin=$(date "+%-M")
        if [[ ${CurMin} -gt 2 && ${CurMin} -lt 30 ]] || [[ ${CurMin} -gt 31 && ${CurMin} -lt 59 ]]; then
            CurDelay=$((${RANDOM} % ${RandomDelay} + 1))
            echo -e "\n\033[33m[*]\033[0m 命令未添加 \"now\"，随机延迟 ${CurDelay} 秒后再执行任务，如需立即终止，请按 Ctrl+C...\n"
            sleep ${CurDelay}
        fi
    fi
}

## 正常运行单个京东脚本
function Run_Normal() {
    local p=$1
    Find_Script $p
    if [ -n "${FileName}" ] && [ -n "${WhichDir}" ]; then
        Import_Conf $1
        Detect_Cron
        Set_Env
        Combin_All
        [ $# -eq 1 ] && Random_Delay
        LogTime=$(date "+%Y-%m-%d-%H-%M-%S")
        LogFile="${LogDir}/${FileName}/${LogTime}.log"
        [ ! -d ${LogDir}/${FileName} ] && mkdir -p ${LogDir}/${FileName}
        cd ${WhichDir}
        if [ ${FileFormat} == "js" ]; then
            node ${FileName}.js | tee ${LogFile}
        elif [ ${FileFormat} == "py" ]; then
            python3 ${FileName}.py | tee ${LogFile}
        elif [ ${FileFormat} == "ts" ]; then
            ts-node ${FileName}.ts | tee ${LogFile}
        fi
    else
        echo -e "\n\033[31m[ERROR]\033[0m 在 ${ScriptsDir}、${ScriptsDir}/backUp、${ConfigDir}、${ScriptsDir}/tools 四个目录下均未检测到 $1 脚本的存在，请确认！\n"
        Help
    fi
}

## 并发执行，因为是并发，所以日志只能直接记录在日志文件中（日志文件以Cookie编号结尾），前台执行并发跑时不会输出日志
## 并发执行时，设定的 RandomDelay 不会生效，即所有任务立即执行
function Run_Concurrent() {
    local p=$1
    Find_Script $p
    if [ -n "${FileName}" ] && [ -n "${WhichDir}" ]; then
        Import_Conf $1
        Detect_Cron
        Set_Env
        Combin_SHARECODES
        LogTime=$(date "+%Y-%m-%d-%H-%M-%S")
        [ ! -d ${LogDir}/${FileName} ] && mkdir -p ${LogDir}/${FileName}
        echo -e "\n各账号间已经在后台开始并发执行，前台不输入日志，日志直接写入文件中。\n"
        for ((user_num = 1; user_num <= $UserSum; user_num++)); do
            for num in ${TempBlockCookie}; do
                [[ $user_num -eq $num ]] && continue 2
            done
            Cookie_Num=Cookie$user_num
            export JD_COOKIE=${!Cookie_Num}
            LogFile="${LogDir}/${FileName}/${LogTime}_${user_num}.log"
            cd ${WhichDir}
            if [ ${FileFormat} == "js" ]; then
                node ${FileName}.js &>$LogFile &
            elif [ ${FileFormat} == "py" ]; then
                python3 ${FileName}.py &>$LogFile &
            elif [ ${FileFormat} == "ts" ]; then
                ts-node ${FileName}.ts &>$LogFile &
            fi
        done
        echo -e "\033[33m[*]\033[0m 并发任务正在执行中，请等候...\n"
        wait
        echo -e "\033[32m[Done]\033[0m 所有并发任务已全部完成，如需查看执行结果，请直接查看相关日志\n"
    else
        echo -e "\n\033[31m[ERROR]\033[0m 在 ${ScriptsDir}、${ScriptsDir}/backUp、${ConfigDir}、${ScriptsDir}/tools 四个目录下均未检测到 $1 脚本的存在，请确认！\n"
        Help
    fi
}

## 指定只运行某一个Cookie
Run_Specify() {
    local p=$1
    local ck_num=$2
    Find_Script $p
    if [ -n "${FileName}" ] && [ -n "${WhichDir}" ]; then
        Import_Conf
        Detect_Cron
        Set_Env
        Combin_SHARECODES
        LogTime=$(date "+%Y-%m-%d-%H-%M-%S")
        [ ! -d ${LogDir}/${FileName} ] && mkdir -p ${LogDir}/${FileName}
        LogFile="${LogDir}/${FileName}/${LogTime}_${user_num}.log"
        Cookie_Num=Cookie$ck_num
        export JD_COOKIE=${!Cookie_Num}
        cd ${WhichDir}
        if [ ${FileFormat} == "js" ]; then
            node ${FileName}.js | tee ${LogFile}
        elif [ ${FileFormat} == "py" ]; then
            python3 ${FileName}.py | tee ${LogFile}
        elif [ ${FileFormat} == "ts" ]; then
            ts-node ${FileName}.ts | tee ${LogFile}
        fi
    else
        echo -e "\n\033[31m[ERROR]\033[0m 在 ${ScriptsDir}、${ScriptsDir}/backUp、${ConfigDir}、${ScriptsDir}/tools 四个目录下均未检测到 $1 脚本的存在，请确认！\n"
        Help
    fi
}

## 拉取远程仓库的脚本并执行
Run_RawScript() {
    local Raw_Url=$1
    FileName=$(echo $Raw_Url | awk -F "/" '{print $NF}')
    RepositoryName=$(echo $Raw_Url | egrep -o "github|gitee|gitlab")
    if [[ ${RepositoryName} == "github" ]]; then
        RepositoryJudge=" Github "
    elif [[ ${RepositoryName} == "gitee" ]]; then
        RepositoryJudge=" Gitee "
    elif [[ ${RepositoryName} == "gitlab" ]]; then
        RepositoryJudge=" GitLab "
    else
        RepositoryJudge=""
    fi
    if [ -n "$3" ]; then
        local Raw_Functions=$3
        if [ $Raw_Functions = "-p" ]; then
            DownloadJudgment="https://ghproxy.com/"
        else
            echo -e "\n\033[31m[ERROR]\033[0m 命令错误，请重新输入！\n"
            Help
            exit
        fi
    else
        DownloadJudgment=""
    fi
    echo -e "\n\033[33m[*]\033[0m 开始从$RepositoryJudge远程仓库下载 ${FileName} 脚本..."
    wget -q --no-check-certificate ${DownloadJudgment}$Raw_Url -O "${ScriptsDir}/${FileName}.new"
    if [[ $? -eq 0 ]]; then
        mv -f "${ScriptsDir}/${FileName}.new" "${ScriptsDir}/${FileName}"
        echo -e "\n\033[32m[Done]\033[0m 下载完成，倒计时 3 秒后开始执行\n"
        sleep 1 && echo -e "3..." && sleep 1 && echo -e "2.." && sleep 1 && echo -e "1." && sleep 1
        FormatFileName=$(echo ${FileName} | perl -pe "{s|\.js||; s|\.py||; s|\.ts||}")
        Run_Normal ${FormatFileName} now
    else
        [ -f "${ScriptsDir}/${FileName}.new" ] && rm -rf "${ScriptsDir}/${FileName}.new"
        echo -e "\n\033[31m[ERROR]\033[0m 下载 ${FileName} 失败，请检查 URL 地址是否正确或网络连通性问题...\n"
    fi
}

## 命令检测
case $# in
0)
    echo
    Help
    ;;
1)
    case $1 in
    list)
        ScriptsList
        ;;
    hangup)
        Run_HangUp
        ;;
    resetpwd)
        Reset_Pwd
        ;;
    *)
        Run_Normal $1
        ;;
    esac
    ;;
2)
    case $2 in
    now)
        Run_Normal $1 $2
        ;;
    conc)
        Run_Concurrent $1 $2
        ;;
    [1-9] | [1-3][0-9])
        Run_Specify $1 $2
        ;;
    raw)
        Run_RawScript $1
        ;;
    *)
        echo -e "\n\033[31m[ERROR]\033[0m 命令错误，请重新输入！\n"
        Help
        ;;
    esac
    ;;
3)
    if [[ $2 == raw ]]; then
        Run_RawScript $1 $2 $3
    else
        echo -e "\n\033[31m[ERROR]\033[0m 输入命令过多！\n"
        Help
    fi
    ;;
*)
    echo -e "\n\033[31m[ERROR]\033[0m 输入命令过多！\n"
    Help
    ;;
esac