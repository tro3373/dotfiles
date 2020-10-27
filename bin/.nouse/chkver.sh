#!/bin/bash

#######################################################################
# 必要なパッケージのバージョンを確認しスクリプト内で事前定義された    #
# バージョンより古い場合またはインストールされていない場合は通知する  #
#                                                                     #
# 確認するパッケージ    (必要なバージョン)                            #
#       - zsh           (4.3.17)                                      #
#       - git           (1.7.9.5)                                     #
#       - vim           (7.3)                                         #
#       - gvim          (7.3)                                         #
#       - tmux          (1.8)                                         #
#       - tig           (1.2.1)                                       #
#######################################################################

REQUIRED_VERSION_ZSH="4.3.17"
REQUIRED_VERSION_GIT="1.7.9.5"
REQUIRED_VERSION_VIM="7.3"
REQUIRED_VERSION_GVIM="7.3"
REQUIRED_VERSION_TMUX="1.8"
REQUIRED_VERSION_TIG="1.2.1"


# req_verと$2のバージョンを比較する
# $1:RequiredVersion, $2:CurrentVersion
# 戻り値
#   $1<=$2  (現在のバージョンが要求バージョン以上)      : 0
#   $1>$2   (現在のバージョンが要求バージョンより古い)  : 1
is_required_version() {

  # 先頭,各番号の先頭の'0'を除去
  local req_ver=`echo $1 | sed 's/^0//'| sed 's/\.0\([0-9]\+\)/\.\1/g'`
  local cur_ver=`echo $2 | sed 's/^0//'| sed 's/\.0\([0-9]\+\)/\.\1/g'`

  # バージョンを文字列比較
  if [ "${req_ver}" = "${cur_ver}" ]; then
    # 同一バージョン
    ret=0
  elif [[ "${req_ver}" < "${cur_ver}" ]]; then
    # 現在のバージョンの方が大きい
    ret=0
  else
    # 要求バージョンの方が大きい
    ret=1
  fi
  return ${ret}
}



###############################
# zsh
###############################

# zshがインストールされているか
inst=`which zsh`
if [ ! "${inst}" = "" ]; then

  # バージョンの取得
  ver=`zsh --version | awk {'print $2'}`

  # バージョンの比較を行う
  is_required_version ${REQUIRED_VERSION_ZSH} ${ver}
  if [ $? -eq 0 ]; then
    # 要求バージョン以上
    echo "'zsh ${ver}' is already installed"
  else
    # 要求バージョンに満たない
    echo "[!]'zsh ${ver}' is installed. Please update to ${REQUIRED_VERSION_ZSH} and over."
  fi

else
  # ソフトがインストールされてない
  echo "'[!]zsh' is not installed"
fi



###############################
# git
###############################

# gitがインストールされているか
inst=`which git`
if [ ! "${inst}" = "" ]; then

  # バージョンの取得
  ver=`git --version | awk {'print $3'}`

  # バージョンの比較を行う
  is_required_version ${REQUIRED_VERSION_GIT} ${ver}
  if [ $? -eq 0 ]; then
    # 要求バージョン以上
    echo "'git ${ver}' is already installed"
  else
    # 要求バージョンに満たない
    echo "[!]'git ${ver}' is installed. Please update to ${REQUIRED_VERSION_GIT} and over."
  fi

else
  # ソフトがインストールされてない
  echo "'[!]git' is not installed"
fi



###############################
# vim
###############################

# vimがインストールされているか
inst=`which vim`
if [ ! "${inst}" = "" ]; then

  # バージョンの取得
  ver=`vim --version | head -n 1 | awk {'print $5'}`

  # バージョンの比較を行う
  is_required_version ${REQUIRED_VERSION_VIM} ${ver}
  if [ $? -eq 0 ]; then
    # 要求バージョン以上
    echo "'vim ${ver}' is already installed"
  else
    # 要求バージョンに満たない
    echo "[!]'vim ${ver}' is installed. Please update to ${REQUIRED_VERSION_VIM} and over."
  fi

else
  # ソフトがインストールされてない
  echo "'[!]vim' is not installed"
fi



###############################
# gvim
###############################

# gvimがインストールされているか
inst=`which gvim`
if [ ! "${inst}" = "" ]; then

  # バージョンの取得
  ver=`gvim --version | head -n 1 | awk {'print $5'}`

  # バージョンの比較を行う
  is_required_version ${REQUIRED_VERSION_GVIM} ${ver}
  if [ $? -eq 0 ]; then
    # 要求バージョン以上
    echo "'gvim ${ver}' is already installed"
  else
    # 要求バージョンに満たない
    echo "[!]'gvim ${ver}' is installed. Please update to ${REQUIRED_VERSION_GVIM} and over."
  fi

else
  # ソフトがインストールされてない
  echo "'[!]gvim' is not installed"
fi



###############################
# tmux
###############################

# tmuxがインストールされているか
inst=`which tmux`
if [ ! "${inst}" = "" ]; then

  # バージョンの取得
  ver=`tmux -V | awk {'print $2'}`

  # バージョンの比較を行う
  is_required_version ${REQUIRED_VERSION_TMUX} ${ver}
  if [ $? -eq 0 ]; then
    # 要求バージョン以上
    echo "'tmux ${ver}' is already installed"
  else
    # 要求バージョンに満たない
    echo "[!]'tmux ${ver}' is installed. Please update to ${REQUIRED_VERSION_TMUX} and over."
  fi

else
  # ソフトがインストールされてない
  echo "'[!]tmux' is not installed"
fi



###############################
# tig
###############################

# tigがインストールされているか
inst=`which tig`
if [ ! "${inst}" = "" ]; then

  # バージョンの取得
  ver=`tig --version | awk {'print $3'}`

  # バージョンの比較を行う
  is_required_version ${REQUIRED_VERSION_TIG} ${ver}
  if [ $? -eq 0 ]; then
    # 要求バージョン以上
    echo "'tig ${ver}' is already installed"
  else
    # 要求バージョンに満たない
    echo "[!]'tig ${ver}' is installed. Please update to ${REQUIRED_VERSION_TIG} and over."
  fi

else
  # ソフトがインストールされてない
  echo "'[!]tig' is not installed"
fi


# 終了
echo "done."

