#!/bin/env bash
export red="\033[31m"
export green="\033[32m"
export yellow="\033[33m"
export blue="\033[34m"
export purple="\033[35m"
export cyan="\033[36m"
export white="\033[37m"
export background="\033[0m"
echo -e ${yellow}正在使用pnpm安装依赖${background}
if [ ! -d $HOME/.local/share/pnpm ];then
    mkdir -p $HOME/.local/share/pnpm
fi
export PATH=$PATH:/usr/local/node/bin
export PATH=$PATH:/root/.local/share/pnpm
export PNPM_HOME=/root/.local/share/pnpm
export PUPPETEER_SKIP_DOWNLOAD=true
i=0
until echo "Y" | pnpm install -P
do
    echo -e ${red}依赖安装失败 ${green}正在重试${background}
    if [ ! -d $HOME/.local/share/pnpm ];then
        mkdir -p $HOME/.local/share/pnpm
    fi
    export PATH=$PATH:/usr/local/node/bin
    export PATH=$PATH:/root/.local/share/pnpm
    export PNPM_HOME=/root/.local/share/pnpm
    if [ "${i}" == "3" ];then
        echo -e ${red}错误次数过多 退出${background}
        exit 
    fi
    pnpm setup
    source ~/.bashrc
    i=$((${i}+1))
    pnpm uninstall sqlite3
    pnpm install sqlite3@5.1.6
done
echo Y | pnpm install
pnpm install puppeteer@19.4.0 -w
pnpm install icqq@latest -w
echo -en ${yellow}正在初始化${background}
pnpm run start
sleep 3s
pnpm run stop
rm -rf ~/.pm2/logs/*.log
echo -en ${yellow}初始化完成${background}
echo