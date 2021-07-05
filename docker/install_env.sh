#!/usr/bin/env bash
## 安装环境所需要的软件包

ShellDir=${JD_DIR:-$(
    cd $(dirname $0)
    pwd
)}
[[ ${JD_DIR} ]] && ShellJd=jd || ShellJd=${ShellDir}/jd.sh
ScriptsDir=${ShellDir}/scripts

apk update
apk add --no-cache build-base g++ cairo-dev jpeg-dev pango-dev giflib-dev python3 py3-pip
pip3 install --upgrade pip
cd ${ScriptsDir}
pip3 install requests
npm install -g npm npm-install-peers
npm install -g ts-node typescript axios --unsafe-perm=true --allow-root