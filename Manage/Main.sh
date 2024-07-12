#!/bin/env bash
source config

RedisServerStart(){
PedisCliPing(){
if [ "$(redis-cli ping 2>&1)" == "PONG" ]
then
  return 0
else
  return 1
fi
}
if $(PedisCliPing)
then
  echo -e ${cyan}Redis-Server${green} 已启动${background}
else
  $(nohup redis-server > /dev/null 2>&1 &)
  echo -e ${cyan}等待Redis-Server启动中${background}
  until PedisCliPing
  do
    sleep 0.2s
  done
  echo -e ${cyan}Redis-Server${green} 启动成功${background}
fi
}
BackToFore(){
if pnpm pm2 list | grep ${BotName} | grep -q online
then
  pnpm pm2 stop ${BotName}
  afyz start ${BotName}
fi
}
CheckStart(){
if tmux ls | grep -q $1
then
  StartSoftware=tmux
  return 1
elif screen -ls | grep -q $1
  StartSoftware=screen
  return 2
elif pm2 list | grep -q $1
  StartSoftware=pm2
  return 3
elif ps -ef | sed '/grep/d' | grep $1
  return 4
else
  StartSoftware=tmux
  return 0
fi
}
CheckStartSoftware(){
CheckStart
case $? in
1)
  MsgboxSize
  whiptail --title "AF-BOT" \
  --msgbox "${BotName} 已在 [Tmux] 中启动" \
  ${HEIGHT} ${WIDTH}
;;
2)
  MsgboxSize
  whiptail --title "AF-BOT" \
  --msgbox "${BotName} 已在 [Screen] 中启动" \
  ${HEIGHT} ${WIDTH}
;;
3)
  MsgboxSize
  whiptail --title "AF-BOT" \
  --msgbox "${BotName} 已在 [Pm2] 中启动" \
  ${HEIGHT} ${WIDTH}
;;
4)
  MsgboxSize
  whiptail --title "AF-BOT" \
  --msgbox "${BotName} 已在 [前台] 中启动" \
  ${HEIGHT} ${WIDTH}
  BotManage
  exit
;;
esac
}

case $1 in
MZ|Miao-Yunzai)
  BotName="Miao-Yunzai"
  cd $AFHOME/${BotName}
  ;;
TZ|TRSS-Yunzai|Yunzai)
  BotName="TRSS-Yunzai"
  cd $AFHOME/${BotName}
  ;;
esac

case $2 in
CheckStart ${BotName}
start)
  RedisServerStart
  node app
  BackToFore
  exit
;;
stop)
  BotRun ${StartSoftware} stop ${BotName}
  exit
;;
restart)
  BotRun ${StartSoftware} restart ${BotName}
  exit
;;
log)
  BotRun ${StartSoftware} log ${BotName}
  exit
;;
SignApi)
  case ${BotName} in
    Miao-Yunai)
      ConfigFile="config/config/bot.yaml"
      NewSignApiAddr="$3"
      OldSignApiAddr=$(grep sign_api_addr ${ConfigFile})
      NewSignApiAddr=$(echo ${NewSignApiAddr} | sed "s|sign_api_addr: ||g")
      sed -i "s|${OldSignApiAddr}|sign_api_addr: ${NewSignApiAddr}|g" ${ConfigFile}
      API=$(grep sign_api_addr ${ConfigFile} | sed "s|sign_api_addr: ||g")
      echo -en ${cyan}SignApiAddr已修改为: ${green}${API}${background};read
    ;;
    TRSS-Yunzai)
      ConfigFile="config/config/ICQQ.yaml"
      NewSignApiAddr="$3"
      OldSignApiAddr=$(grep sign_api_addr ${ConfigFile})
      NewSignApiAddr=$(echo ${NewSignApiAddr} | sed "s|sign_api_addr: ||g")
      sed -i "s|${OldSignApiAddr}|  sign_api_addr: ${NewSignApiAddr}|g" ${ConfigFile}
      API=$(grep sign_api_addr ${ConfigFile} | sed "s|sign_api_addr: ||g")
      echo -en ${cyan}SignApiAddr已修改为: ${green}${API}${background};read
    ;;
  esac
  exit
;;
Master)
  ConfigFile="config/config/bot.yaml"
  sed -i "/master/a\  - $3" ${ConfigFile}
  exit
;;

esac


BotManage(){
OtherFunctions(){
case $1 in
Miao-Yunzai)
MenuSize
Number=$(whiptail \
--title "白狐 QQ群:705226976" \
--menu "${BotName}管理" \
${HEIGHT} ${WIDTH} ${OPTION} \
"1" "填写ICQQ签名" \
"2" "修改主人账号" \
"3" "重装依赖文件" \
"4" "自动退群人数" \
"5" "好友申请同意" \
"0" "返回上级菜单" \
3>&1 1>&2 2>&3)
case ${Number} in
1)
  case ${BotName} in
    Miao-Yunai)
      ConfigFile="config/config/bot.yaml"
      MsgboxSize
      if NewSignApiAddr=$(whiptail --title "AF-YZ"  \
      --yes-button "确认" \
      --no-button "返回" \
      --inputbox "请输入您的签名服务器链接" \
      ${HEIGHT} ${WIDTH} \
      3>&1 1>&2 2>&3)
      then
        OldSignApiAddr=$(grep sign_api_addr ${ConfigFile})
        OldSignApiAddr=$(grep sign_api_addr ${ConfigFile})
        NewSignApiAddr=$(echo ${NewSignApiAddr} | sed "s|sign_api_addr: ||g")
        sed -i "s|${OldSignApiAddr}|sign_api_addr: ${NewSignApiAddr}|g" ${ConfigFile}
        API=$(grep sign_api_addr ${ConfigFile} | sed "s|sign_api_addr: ||g")
        echo -en ${cyan}SignApiAddr已修改为: ${green}${API}${background};read
      else
        OtherFunctions
        BotManage
      fi
    ;;
    TRSS-Yunzai)
      ConfigFile="config/ICQQ.yaml"
      MsgboxSize
      if NewSignApiAddr=$(whiptail --title "AF-YZ"  \
      --yes-button "确认" \
      --no-button "返回" \
      --inputbox "请输入您的签名服务器链接" \
      ${HEIGHT} ${WIDTH} \
      3>&1 1>&2 2>&3)
      then
        OldSignApiAddr=$(grep sign_api_addr ${ConfigFile})
        NewSignApiAddr=$(echo ${NewSignApiAddr} | sed "s|sign_api_addr: ||g")
        sed -i "s|${OldSignApiAddr}|  sign_api_addr: ${NewSignApiAddr}|g" ${ConfigFile}
        API=$(grep sign_api_addr ${ConfigFile} | sed "s|sign_api_addr: ||g")
        echo -en ${cyan}SignApiAddr已修改为: ${green}${API}${background};read
      else
        OtherFunctions
        BotManage
      fi
    ;;
  esac
;;
2)
  ConfigFile="config/config/bot.yaml"
  MsgboxSize
  if Master=$(whiptail --title "AF-YZ"  \
  --yes-button "确认" \
  --no-button "返回" \
  --inputbox "请输入您的主人账号" \
  ${HEIGHT} ${WIDTH} \
  3>&1 1>&2 2>&3)
  then
    sed -i "/master/a\  - ${Master}" ${ConfigFile}
    echo -en ${cyan}修改完成 ${green}回车返回${background};read
  else
    OtherFunctions
    BotManage
  fi
  ;;
3)
  for PluginFolder in $(ls plugins)
  do
    if [ -d plugins/${PluginFolder}/node_modules ]
    then
      Name=$(grep name plugins/${PluginFolder}/package.json | grep name | awk '{print $2}' | sed 's|,||g')
      echo -e ${yellow}正在删除 ${cyan}${Name}${yellow} 的依赖文件${background}
      rm -rvf plugins/${PluginFolder}/node_modules
    fi
  done
  echo -e ${yellow}正在安装依赖${background}
  echo Y | pnpm install
  echo -en ${cyan}依赖重装完成 ${green}回车返回${background};read
  ;;
4)
  ConfigFile="config/config/bot.yaml"
  MsgboxSize
  if NewAutoQuit=$(whiptail --title "AF-YZ"  \
  --yes-button "确认" \
  --no-button "返回" \
  --inputbox "请输入自动退群人数" \
  ${HEIGHT} ${WIDTH} \
  3>&1 1>&2 2>&3)
  then
    OldAutoQuit=$(grep autoQuit ${ConfigFile})
    sed -i "s|${OldAutoQuit}|autoQuit: ${NewAutoQuit}|g" ${ConfigFile}
    echo -en ${cyan}修改完成 ${green}回车返回${background};read
  else
    OtherFunctions
    BotManage
  fi
  ;;
5)
  if (whiptail --title "AF-YZ"  \
  --yes-button "开启" \
  --no-button "关闭" \
  --yesno "设置好友申请自动同意" ${HEIGHT} ${WIDTH})
  then
    OldAutoFriend=$(grep autoFriend ${ConfigFile})
    sed -i "s|${OldAutoQuit}|autoQuit: 1|g" ${ConfigFile}
    echo -en ${cyan}修改完成 ${green}回车返回${background};read
  else
    OldAutoFriend=$(grep autoFriend ${ConfigFile})
    sed -i "s|${OldAutoQuit}|autoQuit: 0|g" ${ConfigFile}
    echo -en ${cyan}修改完成 ${green}回车返回${background};read
  fi
  ;;
esac
}
BotName="$1"
MenuSize
Number=$(whiptail \
--title "白狐 QQ群:705226976" \
--menu "请选择操作" \
${HEIGHT} ${WIDTH} ${OPTION} \
Number=$(whiptail \
--title "白狐 QQ群:705226976" \
--menu "${BotName}管理" \
${HEIGHT} ${WIDTH} ${OPTION} \
"1" "启动运行" \
"2" "前台启动" \
"3" "停止运行" \
"4" "重新启动" \
"5" "打开日志" \
"6" "插件管理" \
"7" "全部更新" \
"8" "其他功能" \
"0" "  返回  " \
3>&1 1>&2 2>&3)
case ${Number} in
1)
  if CheckStart
  then
    RedisServerStart
    if Error=$(BotRun ${StartSoftware} start ${BotName} "afyz start ${BotName}")
    then
      MsgboxSize
      if whiptail --title "AF-BOT"  \
      --yes-button "打开日志" \
      --no-button "返回菜单" \
      --yesno "${BotName} [已启动]" \
      ${HEIGHT} ${WIDTH} \
      3>&1 1>&2 2>&3
      then
        if ! Error=$(BotRun ${StartSoftware} log ${BotName})
        then
          MsgboxSize
          whiptail --title "AF-BOT" \
          --msgbox "${BotName} 日志 [打开失败] \n原因: ${Error}" \
          ${HEIGHT} ${WIDTH}
        fi
      else
        BotManage
      fi
    else
      MsgboxSize
      whiptail --title "AF-BOT" \
      --msgbox "${BotName} [未启动] \n原因: ${Error}" \
      ${HEIGHT} ${WIDTH}
    fi
  else
    BotManage
  fi
;;
2)
  if CheckStart
  then
    afyz start ${BotName}
    BotManage
  else
    BotManage
  fi
;;
3)
  if CheckStart
  then
    MsgboxSize
    whiptail --title "AF-BOT" \
    --msgbox "${BotName} [未启动] 无需停止" \
    ${HEIGHT} ${WIDTH}
    BotManage
  else
    if Error=$(BotRun ${StartSoftware} stop ${BotName})
    then
      MsgboxSize
      whiptail --title "AF-BOT" \
      --msgbox "${BotName} 停止 [成功]" \
      ${HEIGHT} ${WIDTH}
      BotManage
    else
      MsgboxSize
      whiptail --title "AF-BOT" \
      --msgbox "${BotName} 停止 [失败] \n原因: ${Error}" \
      ${HEIGHT} ${WIDTH}
      BotManage
    fi
  fi
;;
4)
  if CheckStart
  then
    MsgboxSize
    whiptail --title "AF-BOT" \
    --msgbox "${BotName} [未启动] 无需重启" \
    ${HEIGHT} ${WIDTH}
    BotManage
  else
    if Error=$(BotRun ${StartSoftware} restart ${BotName})
    then
      MsgboxSize
      whiptail --title "AF-BOT" \
      --msgbox "${BotName} 重启 [成功]" \
      ${HEIGHT} ${WIDTH}
      BotManage
    else
      MsgboxSize
      whiptail --title "AF-BOT" \
      --msgbox "${BotName} 重启 [失败] \n原因: ${Error}" \
      ${HEIGHT} ${WIDTH}
      BotManage
    fi
  fi
;;
5)
  if CheckStart 
  then
    MsgboxSize
    whiptail --title "AF-BOT" \
    --msgbox "${BotName} [未启动] 无法打开日志" \
    ${HEIGHT} ${WIDTH}
    BotManage
  else
    if Error=$(BotRun ${StartSoftware} log ${BotName})
    then
      MsgboxSize
      whiptail --title "AF-BOT" \
      --msgbox "打开 ${BotName} 日志 [成功]" \
      ${HEIGHT} ${WIDTH}
      BotManage
    else
      MsgboxSize
      whiptail --title "AF-BOT" \
      --msgbox "打开 ${BotName} 日志 [失败] \n原因: ${Error}" \
      ${HEIGHT} ${WIDTH}
      BotManage
    fi
  fi
;;
6)
  MsgboxSize
  whiptail --title "AF-BOT" \
  --msgbox "还没写" \
  ${HEIGHT} ${WIDTH}
  BotManage
;;
7)
  git_pull(){
  echo -e ${yellow}正在更新 ${folder}${background}
  if ! git pull -f
  then
    echo -en ${red}${folder}更新失败 ${yellow}是否强制更新 [Y/N]${background};read YN
    case ${YN} in
    Y|y)
      remote=$(grep 'remote =' .git/config | sed 's/remote =//g')
      remote=$(echo ${remote})
      branch=$(grep branch .git/config | sed "s/\[branch \"//g" | sed 's/"//g' | sed "s/\]//g")
      branch=$(echo ${branch})
      git fetch --all
      git reset --hard ${remote}/${branch}
      git_pull
    esac
  fi
  }
  Name=${BotName}
  git_pull
  for folder in $(ls plugins)
  do
    if [ -d plugins/${folder}/.git ];then
      cd plugins/${folder}
      git_pull ${folder}
      cd ../../
    fi
  done
  echo -e ${yellow}正在更新NPM${background}
  npm install -g npm@latest
  echo -e ${yellow}正在更新PNPM${background}
  pnpm install -g pnpm@latest
  echo -en ${cyan}更新完成 回车返回${background};read
  BotManage
;;
8)
  ConfigManage ${BotName}
  BotManage
;;
esac
}

MenuSize
Number=$(whiptail \
--title "白狐 QQ群:705226976" \
--menu "请选择bot" \
${HEIGHT} ${WIDTH} ${OPTION} \
"1" "Miao-Yunzai" \
"2" "TRSS-Yunzai" \
"0" "退出" \
3>&1 1>&2 2>&3)
case ${Number} in
1)
  BotManage Miao-Yunzai
  cd 
  ;;
2)
  BotManage TRSS-Yunzai
  ;;
0)
  exit
  ;;
esac