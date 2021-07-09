#!/usr/bin/env bash
## 安装目前环境所需要的软件包

ShellDir=${JD_DIR:-$(
    cd $(dirname $0)
    pwd
)}
[[ ${JD_DIR} ]] && ShellJd=jd || ShellJd=${ShellDir}/jd.sh
ScriptsDir=${ShellDir}/scripts

apk update
apk add --no-cache python3 py3-pip sudo
pip3 install --upgrade pip
cd ${ScriptsDir}
pip3 install requests
npm install -g npm npm-install-peers
npm install -g ts-node typescript axios @types/node --unsafe-perm=true --allow-root
echo -e '\n\033[32m ------- 忽略 WARN 警告类输出内容 -------\033[0m'