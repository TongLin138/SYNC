## 《群规》
### 修订日期：2021 年 4 月 10 日

1. 本群为技术交流群，请不要发送、分享任何涉黄和与政治相关的内容或信息.
2. 任何人不得转发、分享群内资源和相关信息，若发现大规模传播将删库跑路。
3. 本群内部资源仅供内部使用，不允许存在脚踩两只船的行为，如果您不使用请自行退群，v4新版除外。
4. 关于本人自用的 Diy 脚本，如果您知道可自行使用，否则无可奉告，群内禁止宣传、讨论。
5. 请大家不要对外询问、泄露关于群内资源得任何信息，如有在其它群组发现直接封禁。

ㅤ★ 如有部署或使用相关的问题请先仔细查看文档，解决不了再@作者寻求帮助，看到后会回复的，请勿私聊。\
ㅤ★ 群内可随意自由讨论除规定内容外的任何内容，不带节奏即可。\
ㅤ★ 请大家遵守上述规定，如有发现违规者一律封禁处理，无警告等二次机会，请谨慎发言低调使用！\
ㅤ
ㅤ
# 《使用与更新》教程
## 修订日期：2021 年 4 月 23 日
ㅤ
## 一、基础使用教程
>附：[Docker 容器基础使用教程](https://www.runoob.com/docker/docker-container-usage.html)


#### 1. 容器的进入与退出：
- 进入容器

      docker exec -it jd /bin/bash
- 退出容器

      exit
> _ㅤ注意：1. 大部分命令都可在容器外部执行，但部分复杂命令只能在容器内执行，注意区分下面教程的命令执行位置。_\
> _ㅤㅤㅤㅤ2. 如果您修改了默认的容器名称，当使用下面所有的命令时则需要将 `jd`替换为新的名称。_\
> _ㅤㅤㅤㅤ3. 下面的命令中如果前面加上了 `docker exec -it jd` 则表示在容器外部运行此命令。_\
> _ㅤㅤㅤㅤ4. 例如 `docker exec -it newname bash jd.sh xxx now` ，也可使用 `容器ID`代替。_


#### 2. 手动运行一键脚本开始您的薅羊毛行为：
- 进入容器

      docker exec -it jd /bin/bash

- 执行一键脚本

      source run_all.sh 或 . run_all.sh
> _ㅤ注意：1. 此脚本的作用为执行所有活动脚本，共有高达几十个活动脚本，时间较长且与账号数量成正比。_\
> _ㅤㅤㅤㅤ2. 除手动运行活动脚本外该项目还会通过定时的方式自动执行活动脚本，可通过日志查看运行记录。_\
> _ㅤㅤㅤㅤ3. 执行此脚本后无需守在电脑旁，会自动在最后无限制运行挂机活动脚本，直到您手动停止运行为止。_
- 退出容器

      exit


#### 3. 一键更新脚本：
    docker exec -it jd bash git_pull.sh
> _注意：每次使用前请执行此命令，确保使用最新的项目脚本和活动脚本，此脚本也配置了定时任务可自动执行。_

> 常见报错：\
> 提示 `Repository more than 5 connections` 是由于 `Gitee` 限制了每秒同时拉取项目的IP不能超过 `5` 个所导致，此报错为正常现象，重新执行更新命令即可。\
> 提示 `ssh: connect to host gitee.com port 22: Connection timed out` 是由于您使用平台的 `22` 端口不可用所导致，自行解决处理。\
> 提示 `Could not resolve hostname gitee.com: Temporary failure in name resolution lost connection` 是由于无法解析到 `Gitee` 服务器地址所导致，表明网络环境异常，自行解决处理。


#### 4. 执行特定活动脚本：
    docker exec -it jd bash jd.sh xxx      # 如果设置了随机延迟并且当时时间不在0-2、30-31、59分内，将随机延迟一定秒数
    docker exec -it jd bash jd.sh xxx now  # 无论是否设置了随机延迟，均立即运行
> _注意：具体查看活动脚本列表可通过命令 `docker exec -it jd bash jd.sh` 查看， `xxx` 为脚本名。_


#### 5. 使用 Diy 自定义脚本扩展活动脚本数量：
- 使用需知

      1. 此脚本的用途为收集并添加第三方作者编写的活动脚本
      3. 您必须使用本项目中的模板文件根据说明自定义构建您的专属脚本
      4. 您还可以将自制的 Diy 脚本上传至您的仓库并使用自动同步功能
- 启用该功能

      docker exec -it jd cp -f sample/diy.sh.sample config/diy.sh
      docker exec -it jd sed -i 's/EnableExtraShell=""/EnableExtraShell="true"/g' config/config.sh
- 启用自动同步功能（选择）

      docker exec -it jd sed -i 's/EnableExtraShellUpdate=""/EnableExtraShellUpdate="true"/g' config/config.sh
> _ㅤ注意：1. 启用该功能后便可直接下载或同步更新本项目中的 Diy 脚本。_

#### 6. 查看帮助文档：
    docker exec -it jd cat README.md
> _注意：此文档为《使用与更新》教程，即当前页面内容，跟随项目同步更新。_

***

ㅤ
## 二、高阶使用教程
#### 1. 获取互助码：
    docker exec -it jd bash jd.sh get_share_code now


#### 2. 格式化导出互助码：
    docker exec -it jd bash export_sharecodes.sh
> _注意：其原理是从各个活动脚本的日志中获取，只有运行完所有活动脚本后才可使用。_


#### 3. 配置互助码与相互助力：
> 填法示例：
> 
> ################################## 1. 定义东东农场互助（选填） ##################################
> 
> MyFruit1="xxxxxxxxxxxxxxxxxxxxxxxxx"\
> MyFruit2="xxxxxxxxxxxxxxxxxxxxxxxxx"\
> MyFruit3=""\
> MyFruit4=""\
> MyFruit5=""\
> MyFruit6=""\
> MyFruitA=""\
> MyFruitB=""
> 
> ForOtherFruit1="${MyFruit1}@${MyFruit2}"
> ForOtherFruit2="${MyFruit1}@${MyFruit2}"\
> ForOtherFruit3=""\
> ForOtherFruit4=""\
> ForOtherFruit5=""\
> ForOtherFruit6=""
> 
> ################################## 2. 定义东东萌宠互助（选填） ##################################
> 
> MyPet1="xxxxxxxxxxxxxxxxxxxxxxxxx"\
> MyPet2="xxxxxxxxxxxxxxxxxxxxxxxxx"\
> MyPet3="xxxxxxxxxxxxxxxxxxxxxxxxx"\
> MyPet4="xxxxxxxxxxxxxxxxxxxxxxxxx"\
> MyPet5="xxxxxxxxxxxxxxxxxxxxxxxxx"\
> MyPet6="xxxxxxxxxxxxxxxxxxxxxxxxx"\
> MyPet7="xxxxxxxxxxxxxxxxxxxxxxxxx"\
> MyPet8="xxxxxxxxxxxxxxxxxxxxxxxxx"\
> MyPetA=""\
> MyPetB=""
> 
> ForOtherPet1="${MyPet1}@${MyPet2}@${MyPet3}@${MyPet4}@${MyPet5}@${MyPet6}@${MyPet7}@${MyPet8}"
> ForOtherPet2="${MyPet1}@${MyPet2}@${MyPet3}@${MyPet4}@${MyPet5}@${MyPet6}@${MyPet7}@${MyPet8}"
> ForOtherPet3="${MyPet1}@${MyPet2}@${MyPet3}@${MyPet4}@${MyPet5}@${MyPet6}@${MyPet7}@${MyPet8}"
> ForOtherPet4="${MyPet1}@${MyPet2}@${MyPet3}@${MyPet4}@${MyPet5}@${MyPet6}@${MyPet7}@${MyPet8}"
> ForOtherPet5="${MyPet1}@${MyPet2}@${MyPet3}@${MyPet4}@${MyPet5}@${MyPet6}@${MyPet7}@${MyPet8}"
> ForOtherPet6="${MyPet1}@${MyPet2}@${MyPet3}@${MyPet4}@${MyPet5}@${MyPet6}@${MyPet7}@${MyPet8}"
> ForOtherPet7="${MyPet1}@${MyPet2}@${MyPet3}@${MyPet4}@${MyPet5}@${MyPet6}@${MyPet7}@${MyPet8}"
> ForOtherPet8="${MyPet1}@${MyPet2}@${MyPet3}@${MyPet4}@${MyPet5}@${MyPet6}@${MyPet7}@${MyPet8}"


#### 4. 提交您的互助码到公共库(Telegram机器人)：
    Telegram Bot：  
    @TuringLabbot   https://t.me/TuringLabbot
    @LvanLamCommitCodeBot   https://t.me/LvanLamCommitCodeBot
    
    【随机互助Bot使用规则】
    1.用/Start开启bot 用/help获取帮助
    2.支持互助码批量提交(使用 & 隔开)每周期内最多提交同一活动5个互助码，尽量错峰提交。频繁提交，一经发现永 ban ！
    3.每个月1号，8号，16号，24号凌晨2点清理一次数据库，清理后需重新在Bot提交互助码。有啥问题别问我，下次回复这条信息禁言12小时。

    下面是提交格式

    Turing Lab Bot：

    ## 东东农场
    /submit_activity_codes farm &&&&
    ## 东东萌宠
    /submit_activity_codes pet &&&&
    ## 种豆得豆
    /submit_activity_codes bean &&&&
    ## 东东工厂
    /submit_activity_codes ddfactory &&&&
    ## 京喜工厂
    /submit_activity_codes jxfactory &&&&
    ## 闪购盲盒
    /submit_activity_codes sgmh &&&&
    ## 京喜财富岛
    /submit_activity_codes jxcfd &&&&
    ## 东东健康社区
    /submit_activity_codes health &&&&

    Commit Code Bot：

    ## 京东赚赚
    /jdzz &&&&
    ## 疯狂的JOY
    /jdcrazyjoy &&&&
    ## 签到领现金
    /jdcash &&&&

    ## 格式示例（已 & 划分开每个互助码）：
    /submit_activity_codes farm 123456&000000&abcde&ABCDE&123ABC

> _注意：此公共库由活动脚本作者 `lxk0301` 大佬开发并维护，用于活动间的相互助力以解决助力机会和被助力次数不足的问题，此库定时清空且名额有限，具体提交教程详见回复信息。_


#### 5. 启动/重启后台运行挂机活动脚本程序：
    docker exec -it jd bash jd.sh hangup
> _注意：当有新的账号添加后必须重启此程序，否则此程序将继续执行之前配置文件中的账号。_


#### 6. 停止后台运行挂机活动脚本程序：
    docker exec -it jd pm2 stop jd_crazy_joy_coin


#### 7. 导入并使用第三方活动脚本：
    1. 将脚本放置在该项目容器内 scripts 子目录下，也可放在外部的挂载目录（默认为/opt/jd/scripts）
    2. 然后通过命令 docker exec -it jd bash jd.sh xxx now 运行
    3. 如果您想将第三方脚本加入到 run_all.sh 一键脚本中可将脚本名改为"jd_"开头即可
> _注意：导入的第三方活动脚本不会随项目本身活动脚本的更新而删除。_


#### 8. 删除活动运行日志：
    docker exec -it jd bash rm_log.sh 
> _注意：默认删除 `7天` 以上的日志文件，可以通过配置文件中的相关变量更改默认时间值。_

***

ㅤ
## 三、控制面板教程
#### 1. 手动开启控制面板：
    docker exec -it jd pm2 start panel/ecosystem.config.js
> _注意：在某些环境下当系统重启导致控制面板无法访问提示拒绝连接时可用此命令恢复使用。_


#### 2. 手动关闭控制面板：
    docker exec -it jd pm2 stop panel/ecosystem.config.js
> _注意：`VPS` 平台用户关机前请先执行此命令手动停止控制面板，否则在仪表盘强制关机重启后可能会出现无法保存配置文件的问题。_


#### 3. 重启控制面板：
    docker exec -it jd pm2 restart panel/ecosystem.config.js


#### 4. 重置控制面板的用户名和密码：
    docker exec -it jd bash jd.sh resetpwd


#### 5. 升级控制面板：
    docker exec -it jd /bin/bash
    cd panel
    yarn install || yarn install --registry=https://registry.npm.taobao.org
    exit
> _注意：如果您更改了默认访问端口，那么在执行此命令后需要重新修改。_


#### 6. 重新安装控制面板：
    docker exec -it jd /bin/bash
    cd panel
    yarn install || yarn install --registry=https://registry.npm.taobao.org
    npm install -g pm2
    pm2 start ecosystem.config.js
    exit
> _注意：此命令适用于在容器初始化过程中安装失败时使用。_

***

ㅤ
## 四、更新教程
#### 1. 更新配置文件：
- 备份当前配置文件

      docker exec -it jd mv config/config.sh config/bak/config.sh
- 替换新版配置文件

      docker exec -it jd cp -f sample/config.sh.sample config/config.sh
> _ㅤ注意：操作为直接替换配置文件，您也可以通过控制面板对比工具自行修改。_

***

ㅤ
## 五、使用需知
#### 1.  `run_all.sh` 为一键执行所有活动脚本， `git_pull.sh` 为一键更新脚本
#### 2. 手动执行 `run_all.sh` 脚本后无需守在电脑旁，会自动在最后运行挂机活动脚本
#### 3. 执行 `run_all.sh` 脚本期间如果卡住，可按回车键尝试或通过命令 `Ctrl + Z` 跳过继续执行剩余活动脚本
#### 4. 由于京东活动一直变化可能会出现无法参加活动、报错等正常现象，可手动更新活动脚本
#### 5. 如果需要更新活动脚本，请执行一键更新脚本，它会同步更新 `run_all.sh` 一键执行所有活动脚本
#### 6. 除手动运行活动脚本外该项目还会通过定时的方式全天候自动运行活动脚本，具体运行记录可通过日志查看
#### 7. 该项目已默认配置好 `Crontab` 定时任务，定时配置文件 `crontab.list` 会通过活动脚本的更新而同步更新
#### 8. 之前填入的 `Cookie部分内容` 具有一定的时效性，若提示失效请根据教程重新获取并手动更新