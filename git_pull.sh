#!/usr/bin/env bash

## 文件路径、脚本网址、文件版本以及各种环境的判断
ShellDir=${JD_DIR:-$(
    cd $(dirname $0)
    pwd
)}
[[ ${JD_DIR} ]] && ShellJd=jd || ShellJd=${ShellDir}/jd.sh
LogDir=${ShellDir}/log
[ ! -d ${LogDir} ] && mkdir -p ${LogDir}
ScriptsDir=${ShellDir}/scripts
ConfigDir=${ShellDir}/config
FileRunAll=${ShellDir}/run_all.sh
FileConf=${ConfigDir}/config.sh
FileDiy=${ConfigDir}/diy.sh
FileConfSample=${ShellDir}/sample/config.sh.sample
ListCron=${ConfigDir}/crontab.list
ListCronLxk=${ScriptsDir}/docker/crontab_list.sh
ListTask=${LogDir}/task.list
ListJs=${LogDir}/js.list
ListJsAdd=${LogDir}/js-add.list
ListJsDrop=${LogDir}/js-drop.list
ContentVersion=${ShellDir}/version
ContentNewTask=${ShellDir}/new_task
ContentDropTask=${ShellDir}/drop_task
SendCount=${ShellDir}/send_count
isTermux=${ANDROID_RUNTIME_ROOT}${ANDROID_ROOT}
ScriptsURL=https://ghproxy.com/https://github.com/JDHelloWorld/jd_scripts.git

## 更新crontab，gitee服务器同一时间限制5个链接，因此每个人更新代码必须错开时间，每次执行git_pull随机生成。
## 每天次数随机，更新时间随机，更新秒数随机，至少6次，至多12次，大部分为8-10次，符合正态分布。
function Update_Cron() {
    if [[ $(date "+%-H") -le 2 ]] && [ -f ${ListCron} ]; then
        RanMin=$((${RANDOM} % 60))
        RanSleep=$((${RANDOM} % 56))
        RanHourArray[0]=$((${RANDOM} % 3))
        for ((i = 1; i < 14; i++)); do
            j=$(($i - 1))
            tmp=$((${RANDOM} % 3 + ${RanHourArray[j]} + 2))
            [[ ${tmp} -lt 24 ]] && RanHourArray[i]=${tmp} || break
        done
        RanHour=${RanHourArray[0]}
        for ((i = 1; i < ${#RanHourArray[*]}; i++)); do
            RanHour="${RanHour},${RanHourArray[i]}"
        done
        perl -i -pe "s|.+(bash.+git_pull.+log.*)|${RanMin} ${RanHour} \* \* \* sleep ${RanSleep} && \1|" ${ListCron}
        crontab ${ListCron}
    fi
}

## 更新Shell源码
function Git_PullShell() {
    echo -e "\n开始更新仓库 /jd\n"
    cd ${ShellDir}
    git fetch --all
    ExitStatusShell=$?
    git reset --hard origin/master
    git pull
}

## 克隆scripts
function Git_CloneScripts() {
    echo -e "\n开始克隆仓库 /jd/scripts\n"
    git clone -b main ${ScriptsURL} ${ScriptsDir}
    ExitStatusScripts=$?
    [ -d ${ScriptsDir}/docker ] || mkdir -p ${ScriptsDir}/docker
    [ -f ${ListCronLxk} ] || cp -rf ${ShellDir}/docker/crontab_list.sh ${ListCronLxk}
    ExitStatusCronLxk=$?
}

## 更新scripts
function Git_PullScripts() {
    echo -e "\n开始更新仓库 /jd/scripts\n"
    cd ${ScriptsDir}
    [ -d ${ScriptsDir}/docker ] || mkdir -p ${ScriptsDir}/docker
    wget -q https://gitee.com/SuperManito/scripts/raw/master/crontab_list.sh -O ${ListCronLxk}
    ExitStatusCronLxk=$?
    [ ${ExitStatusCronLxk} -ne 0 ] && mv -f ${ShellDir}/docker/crontab_list.sh ${ListCronLxk}
    git fetch --all
    ExitStatusScripts=$?
    git reset --hard origin/main
    git pull
}

## 用户数量UserSum
function Count_UserSum() {
    i=1
    while [ $i -le 1000 ]; do
        Tmp=Cookie$i
        CookieTmp=${!Tmp}
        [[ ${CookieTmp} ]] && UserSum=$i || break
        let i++
    done
}

## 把config.sh中提供的所有账户的PIN附加在jd_joy_run.js中，让各账户相互进行宠汪汪赛跑助力
function Change_JoyRunPins() {
    j=${UserSum}
    PinALL=""
    while [[ $j -ge 1 ]]; do
        Tmp=Cookie$j
        CookieTemp=${!Tmp}
        PinTemp=$(echo ${CookieTemp} | perl -pe "{s|.*pt_pin=(.+);|\1|; s|%|\\\x|g}")
        PinTempFormat=$(printf ${PinTemp})
        PinALL="${PinTempFormat},${PinALL}"
        let j--
    done
    perl -i -pe "{s|(let invite_pins = \[\')(.+\'\];?)|\1${PinALL}\2|; s|(let run_pins = \[\')(.+\'\];?)|\1${PinALL}\2|}" ${ScriptsDir}/jd_joy_run.js
}

## 修改lxk0301大佬js文件的函数汇总
function Change_ALL() {
    if [ -f ${FileConf} ]; then
        . ${FileConf}
        if [ -n "${Cookie1}" ]; then
            Count_UserSum
            # Change_JoyRunPins
        fi
    fi
}

## 检测文件：lxk0301/jd_scripts 仓库中的 docker/crontab_list.sh
## 检测定时任务是否有变化，此函数会在Log文件夹下生成四个文件，分别为：
## task.                       list    crontab.list中的所有任务清单，仅保留脚本名
## js.list      上述检测文件中用来运行js脚本的清单（去掉后缀.js，非运行脚本的不会包括在内）
## js-add.list  如果上述检测文件增加了定时任务，这个文件内容将不为空
## js-drop.list 如果上述检测文件删除了定时任务，这个文件内容将不为空
function Diff_Cron() {
    if [ -f ${ListCron} ]; then
        if [ -n "${JD_DIR}" ]; then
            grep -E " j[drx]_\w+" ${ListCron} | perl -pe "s|.+ (j[drx]_\w+).*|\1|" | sort -u >${ListTask}
        else
            grep "${ShellDir}/" ${ListCron} | grep -E " j[drx]_\w+" | perl -pe "s|.+ (j[drx]_\w+).*|\1|" | sort -u >${ListTask}
        fi

        cat ${ListCronLxk} | grep -E "j[drx]_\w+\.js" | perl -pe "s|.+(j[drx]_\w+)\.js.+|\1|" | sort -u >${ListJs}

        if [[ -n ${EnableExtraShell} && ${EnableExtraShell} == "true" ]]; then
            grep "my_scripts_list" ${FileDiy} | grep -v '#' | grep -ioE "\w+\.js" | sed "s/\.js//g" | grep -v 'Tokens' | sort -u >>${ListJs}
            grep "my_scripts_list" ${FileDiy} | grep -v '#' | grep -ioE "\w+\.js" | sed "s/\.js//g" | grep -v 'Tokens' | sort -u >>${ListTask}
        fi

        grep -vwf ${ListTask} ${ListJs} >${ListJsAdd}
        grep -vwf ${ListJs} ${ListTask} >${ListJsDrop}
    else
        echo -e "${ListCron} 文件不存在，请先定义您自己的crontab.list...\n"
    fi
}

## 发送删除失效定时任务的消息
function Notify_DropTask() {
    cd ${ShellDir}
    node update.js
    [ -f ${ContentDropTask} ] && rm -f ${ContentDropTask}
}

## 发送新的定时任务消息
function Notify_NewTask() {
    cd ${ShellDir}
    node update.js
    [ -f ${ContentNewTask} ] && rm -f ${ContentNewTask}
}

## 检测配置文件版本
function Notify_Version() {
    ## 识别出两个文件的版本号
    VerConfSample=$(grep " Version: " ${FileConfSample} | perl -pe "s|.+v((\d+\.?){3})|\1|")
    [ -f ${FileConf} ] && VerConf=$(grep " Version: " ${FileConf} | perl -pe "s|.+v((\d+\.?){3})|\1|")

    ## 删除旧的发送记录文件
    [ -f "${SendCount}" ] && [[ $(cat ${SendCount}) != ${VerConfSample} ]] && rm -f ${SendCount}

    ## 识别出更新日期和更新内容
    UpdateDate=$(grep " Date: " ${FileConfSample} | awk -F ": " '{print $2}')
    UpdateContent=$(grep " Update Content: " ${FileConfSample} | awk -F ": " '{print $2}')

    ## 如果是今天，并且版本号不一致，则发送通知
    if [ -f ${FileConf} ] && [[ "${VerConf}" != "${VerConfSample}" ]] && [[ ${UpdateDate} == $(date "+%Y-%m-%d") ]]; then
        if [ ! -f ${SendCount} ]; then
            echo -e "日期: ${UpdateDate}\n版本: ${VerConf} -> ${VerConfSample}\n内容: ${UpdateContent}\n\n" | tee ${ContentVersion}
            echo -e "如需更新请手动操作，仅更新当天通知一次!" >>${ContentVersion}
            cd ${ShellDir}
            node update.js
            if [ $? -eq 0 ]; then
                echo "${VerConfSample}" >${SendCount}
                [ -f ${ContentVersion} ] && rm -f ${ContentVersion}
            fi
        fi
    else
        [ -f ${ContentVersion} ] && rm -f ${ContentVersion}
        [ -f ${SendCount} ] && rm -f ${SendCount}
    fi
}

## npm install 子程序，判断是否为安卓，判断是否安装有yarn
function Npm_InstallSub() {
    if [ -n "${isTermux}" ]; then
        npm install --no-bin-links || npm install --no-bin-links --registry=https://registry.npm.taobao.org
    elif ! type yarn >/dev/null 2>&1; then
        npm install || npm install --registry=https://registry.npm.taobao.org
    else
        echo -e "检测到本机安装了 yarn，使用 yarn 替代 npm...\n"
        yarn install || yarn install --registry=https://registry.npm.taobao.org
    fi
}

## npm install
function Npm_Install() {
    cd ${ScriptsDir}
    if [[ "${PackageListOld}" != "$(cat package.json)" ]]; then
        echo -e "安装环境所需的软件包 ...\n"
        echo -e "检测到package.json有变化，运行 npm install...\n"
        Npm_InstallSub
        if [ $? -ne 0 ]; then
            echo -e "\nnpm install 运行不成功，自动删除 ${ScriptsDir}/node_modules 后再次尝试一遍..."
            rm -rf ${ScriptsDir}/node_modules
        fi
        echo
    fi

    if [ ! -d ${ScriptsDir}/node_modules ]; then
        echo -e "运行 npm install...\n"
        Npm_InstallSub
        if [ $? -ne 0 ]; then
            echo -e "\nnpm install 运行不成功，自动删除 ${ScriptsDir}/node_modules...\n"
            echo -e "请进入 ${ScriptsDir} 目录后按照wiki教程手动运行 npm install...\n"
            echo -e "当 npm install 失败时，如果检测到有新任务或失效任务，只会输出日志，不会自动增加或删除定时任务...\n"
            echo -e "3...\n"
            sleep 1
            echo -e "2...\n"
            sleep 1
            echo -e "1...\n"
            sleep 1
            rm -rf ${ScriptsDir}/node_modules
        fi
    fi
}

## 输出是否有新的定时任务
function Output_ListJsAdd() {
    if [ -s ${ListJsAdd} ]; then
        echo -e "检测到有新的定时任务：\n"
        cat ${ListJsAdd}
        echo
    fi
}

## 输出是否有失效的定时任务
function Output_ListJsDrop() {
    if [ ${ExitStatusScripts} -eq 0 ] && [ -s ${ListJsDrop} ]; then
        echo -e "检测到有失效的定时任务：\n"
        cat ${ListJsDrop}
        echo
    fi
}

## 自动删除失效的脚本与定时任务，需要5个条件：1.AutoDelCron 设置为 true；2.正常更新js脚本，没有报错；3.js-drop.list不为空；4.crontab.list存在并且不为空；5.已经正常运行过npm install
## 检测文件：lxk0301/jd_scripts 仓库中的 docker/crontab_list.sh
## 如果检测到某个定时任务在上述检测文件中已删除，那么在本地也删除对应定时任务
function Del_Cron() {
    if [ "${AutoDelCron}" = "true" ] && [ -s ${ListJsDrop} ] && [ -s ${ListCron} ] && [ -d ${ScriptsDir}/node_modules ]; then
        echo -e "开始尝试自动删除定时任务如下：\n"
        cat ${ListJsDrop}
        echo
        JsDrop=$(cat ${ListJsDrop})
        for Cron in ${JsDrop}; do
            perl -i -ne "{print unless / ${Cron}( |$)/}" ${ListCron}
        done
        crontab ${ListCron}
        echo -e "成功删除失效的脚本与定时任务，当前的定时任务清单如下：\n\n--------------------------------------------------------------\n"
        crontab -l
        echo -e "\n--------------------------------------------------------------\n"
        if [ -d ${ScriptsDir}/node_modules ]; then
            echo -e "删除失效的定时任务：\n\n${JsDrop}" >${ContentDropTask}
            Notify_DropTask
        fi
    fi
}

## 自动增加新的定时任务，需要5个条件：1.AutoAddCron 设置为 true；2.正常更新js脚本，没有报错；3.js-add.list不为空；4.crontab.list存在并且不为空；5.已经正常运行过npm install
## 检测文件：lxk0301/jd_scripts 仓库中的 docker/crontab_list.sh
## 如果检测到检测文件中增加新的定时任务，那么在本地也增加
## 本功能生效时，会自动从检测文件新增加的任务中读取时间，该时间为北京时间
function Add_Cron() {
    if [ "${AutoAddCron}" = "true" ] && [ -s ${ListJsAdd} ] && [ -s ${ListCron} ] && [ -d ${ScriptsDir}/node_modules ]; then
        echo -e "开始尝试自动添加定时任务如下：\n"
        cat ${ListJsAdd}
        echo
        JsAdd=$(cat ${ListJsAdd})

        for Cron in ${JsAdd}; do
            if [[ ${Cron} == jd_bean_sign ]]; then
                echo "4 0,9 * * * bash ${ShellJd} ${Cron}" >>${ListCron}
            else
                cat ${ListCronLxk} | grep -E "\/${Cron}\." | perl -pe "s|(^.+)node */scripts/(j[drx]_\w+)\.js.+|\1bash ${ShellJd} \2|" >>${ListCron}
            fi
        done

        if [ $? -eq 0 ]; then
            crontab ${ListCron}
            echo -e "成功添加新的定时任务，当前的定时任务清单如下：\n\n--------------------------------------------------------------\n"
            crontab -l
            echo -e "\n--------------------------------------------------------------\n"
            if [ -d ${ScriptsDir}/node_modules ]; then
                echo -e "成功添加新的定时任务：\n\n${JsAdd}" >${ContentNewTask}
                Notify_NewTask
            fi
        else
            echo -e "添加新的定时任务出错，请手动添加...\n"
            if [ -d ${ScriptsDir}/node_modules ]; then
                echo -e "尝试自动添加以下新的定时任务出错，请手动添加：\n\n${JsAdd}" >${ContentNewTask}
                Notify_NewTask
            fi
        fi
    fi
}

## 自定义脚本功能
function ExtraShell() {
    ## 自动同步用户自定义的diy.sh
    if [[ ${EnableExtraShellUpdate} == true ]]; then
        wget -q $EnableExtraShellURL -O ${FileDiy}
        if [ $? -eq 0 ]; then
            echo -e "自定义脚本同步完成 [Done]\n"
            sleep 2s
        else
            echo -e "\033[31m自定义脚本同步失败，请检查原因或再次执行更新命令 ......\033[0m\n"
            sleep 2s
        fi
    fi

    ## 调用用户自定义的diy.sh
    if [[ ${EnableExtraShell} == true ]]; then
        if [ -f ${FileDiy} ]; then
            . ${FileDiy}
        else
            echo -e "${FileDiy} 文件不存在，跳过执行自定义 DIY 脚本...\n"
            echo -e ''
        fi
    fi
}

## 一键执行所有活动脚本
function Run_All() {
    ## 默认将 "jd、jx、jr" 开头的活动脚本加入其中
    rm -rf ${FileRunAll}
    cat ${ListJs} | grep -v bean_change >${FileRunAll}

    ## 调整执行顺序
    sed -i "1i\jd_bean_change" ${FileRunAll} ## 置顶京豆变动通知
    echo "jd_crazy_joy_coin" >>${FileRunAll} ## 末尾加入挂机脚本

    ## 去除不适合的活动脚本
    ## 例：sed -i '/xxx/d' ${FileRunAll}
    sed -i '/jd_delCoupon/d' ${FileRunAll} ## 不执行 "京东家庭号" 活动
    sed -i '/jd_family/d' ${FileRunAll}    ## 不执行 "删除优惠券" 活动
    ## 第三方脚本
    sed -i '/jd_try/d' ${FileRunAll}
    sed -i '/jx_cfdtx/d' ${FileRunAll}

    sed -i "s/^/bash ${ShellJd} &/g" ${FileRunAll}
    sed -i 's/$/&.js now/g' ${FileRunAll}
    sed -i '1i\#!/bin/env bash' ${FileRunAll}
    sed -i '/^\s*$/d' ${FileRunAll}
}

## 在日志中记录时间与路径
echo -e "+----------------- 开 始 执 行 更 新 脚 本 -----------------+"
echo -e ''
echo -e "   脚本跟目录：${ShellDir}"
echo -e ''
echo -e "   活动脚本目录：${ScriptsDir}"
echo -e ''
echo -e "   当前系统时间：$(date "+%Y-%m-%d %H:%M")"
echo -e ''
echo -e "+-----------------------------------------------------------+"

## 更新crontab
[[ $(date "+%-H") -le 2 ]] && Update_Cron

## 更新源码
[ -d ${ShellDir}/.git ] && Git_PullShell
## 赋权
chmod 777 ${ShellDir}/*

## 克隆或更新js脚本
[ -f ${ScriptsDir}/package.json ] && PackageListOld=$(cat ${ScriptsDir}/package.json)
[ -d ${ScriptsDir}/.git ] && Git_PullScripts || Git_CloneScripts
# [ -f ${ScriptsDir}/sendNotify.js ] && sed -i '/desp += author;/a\  if (text.includes("FreeFuck") || desp.includes("FreeFuck")) return ;' ${ScriptsDir}/sendNotify.js

echo -e "\n+----------------------- 郑 重 提 醒 -----------------------+"
echo -e ""
echo -e "  本项目目前闭源并且仅面向内部开放，脚本免费使用仅供于学习！"
echo -e ""
echo -e "  圈内资源禁止以任何形式发布到咸鱼等国内平台，否则后果自负！"
echo -e ""
echo -e "  我们始终致力于打击使用本项目进行违法贩卖行为的个人或组织！"
echo -e ""
echo -e "  我们不会放纵某些行为，不保证不采取非常手段，请勿挑战底线！"
echo -e ""
echo -e "+-----------------------------------------------------------+\n"

[ ${ExitStatusCronLxk} -ne 0 ] && echo -e "\033[33mScripts仓库脚本定时任务清单拉取失败，已启用备份\033[0m\n"

## 执行各函数
if [[ ${ExitStatusScripts} -eq 0 ]]; then
    Change_ALL
    [ -d ${ScriptsDir}/node_modules ] && Notify_Version
    Diff_Cron
    Npm_Install
    Output_ListJsAdd
    Output_ListJsDrop
    Del_Cron
    Add_Cron
    ExtraShell
    Run_All
    echo -e "活动脚本更新完成......\n"
else
    echo -e "\033[31mScripts仓库脚本更新失败，请检查原因或再次执行更新命令 ......\033[0m\n"
    Change_ALL
    ExtraShell
    Run_All
fi

chmod 777 ${ShellDir}/*