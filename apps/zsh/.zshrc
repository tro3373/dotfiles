# users generic .zshrc file for zsh(1)

## 個人設定
#
[ -f ${HOME}/.zshrc.mine ] && source ${HOME}/.zshrc.mine

# 便利機能ショートカット
#
[ -f ${HOME}/.zshrc.mine.funcs ] && source ${HOME}/.zshrc.mine.funcs

# ssh-agentを起動
#
[ -f ${HOME}/.zshrc.mine.ssh-agent ] && source ${HOME}/.zshrc.mine.ssh-agent

# vcs_info-hook 設定
#
#[ -f ${HOME}/.zshrc.mine.vcs_info ] && source ${HOME}/.zshrc.mine.vcs_info

# 各職場環境のみの設定
#
[ -f ${HOME}/.zshrc.mine.work ] && source ${HOME}/.zshrc.mine.work

# 自宅環境のみの設定
#
[ -f ${HOME}/.zshrc.mine.home ] && source ${HOME}/.zshrc.mine.home

