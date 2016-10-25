#!/bin/bash

setconfig() {
    make_link_dot2home $script_dir
    if get_gitsettingcnt "user.name"; then
        log "@@@@@ Input Your Git user.name"
        read gitusername
        if [ ! "$gitusername" = "" ]; then
            dvexec git config --global user.name "$gitusername"
        else
            log "  => Do Nothing for git user.name"
        fi
    fi
    if get_gitsettingcnt "user.email"; then
        log "@@@@@ Input Your Git user.email"
        read gituseremail
        if [ ! "$gituseremail" = "" ]; then
            dvexec git config --global user.email "$gituseremail"
        else
            log "  => Do Nothing for git user.email"
        fi
    fi
    # Git Global 設定
    set_gitconfig
}

set_gitconfig() {
    if get_gitsettingcnt "core.editor"; then
        dvexec "git config --global core.editor \"vim -c 'set fenc=utf-8'\""
    fi
    if get_gitsettingcnt "core.quotepath="; then
        dvexec git config --global core.quotepath false
    fi
    if get_gitsettingcnt "color.ui="; then
        dvexec git config --global color.ui auto
    fi
    if get_gitsettingcnt "push.default="; then
        dvexec git config --global push.default simple
    fi
    if get_gitsettingcnt "http.sslverify="; then
        dvexec git config --global http.sslVerify false
    fi
    if get_gitsettingcnt "core.preloadindex="; then
        dvexec git config --global core.preloadindex true
    fi
    if get_gitsettingcnt "core.fscache="; then
        dvexec git config --global core.fscache true
    fi
    if get_gitsettingcnt "alias.co="; then
        dvexec git config --global alias.co checkout
    fi
    if get_gitsettingcnt "alias.cm="; then
        dvexec git config --global alias.cm commit
    fi
    if get_gitsettingcnt "alias.st="; then
        dvexec git config --global alias.st status
    fi
    if get_gitsettingcnt "alias.br="; then
        dvexec git config --global alias.br branch
    fi
    if get_gitsettingcnt "alias.lgo="; then
        dvexec "git config --global alias.lgo \"log --oneline\""
    fi
    if get_gitsettingcnt "alias.lg="; then
        dvexec "git config --global alias.lg \"log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative\""
    fi
    if get_gitsettingcnt "alias.lga="; then
        dvexec "git config --global alias.lga \"log --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative\""
    fi
    if get_gitsettingcnt "alias.tar="; then
        dvexec "git config --global alias.tar \"archive --format=tar HEAD -o\""
    fi
    if get_gitsettingcnt "alias.tgz="; then
        dvexec "git config --global alias.tgz \"archive --format=tgz HEAD -o\""
    fi
    if get_gitsettingcnt "alias.zip="; then
        dvexec "git config --global alias.zip \"archive --format=zip HEAD -o\""
    fi
    if get_gitsettingcnt "alias.or="; then
        dvexec git config --global alias.or orphan
    fi
    if get_gitsettingcnt "init.templatedir="; then
        dvexec git config --global init.templatedir '~/.git_template'
    fi
    if get_gitsettingcnt "alias.ignore="; then
        dvexec git config --global alias.ignore '!gi() { curl -L -s https://www.gitignore.io/api/$@ ;}; gi'
    fi
}

get_gitsettingcnt() {
    target=$1
    count=`git config --list |grep $target |wc -l`
    return $count
}

execGitConfigForce() {
    git config --global user.name sample_username
    git config --global user.email sample_email@domain.com
    git config --global core.editor "vim -c 'set fenc=utf-8'"
    git config --global core.quotepath false
    git config --global color.ui auto
    git config --global push.default simple
    git config --global http.sslVerify false
    git config --global core.preloadindex true
    git config --global core.fscache true
    git config --global alias.co checkout
    git config --global alias.cm commit
    git config --global alias.st status
    git config --global alias.br branch
    git config --global alias.lgo "log --oneline"
    git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
    git config --global alias.lga "log --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
    git config --global alias.tar "archive --format=tar HEAD -o"
    git config --global alias.tgz "archive --format=tgz HEAD -o"
    git config --global alias.zip "archive --format=zip HEAD -o"
    git config --global alias.or orphan
    git config --global init.templatedir '~/.git_template'
    git config --global alias.ignore '!gi() { curl -L -s https://www.gitignore.io/api/$@ ;}; gi'
}
