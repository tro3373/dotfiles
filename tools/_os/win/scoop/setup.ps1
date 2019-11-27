Set-ExecutionPolicy RemoteSigned -scope CurrentUser
iex (new-object net.webclient).downloadstring('https://get.scoop.sh')

scoop install git
scoop bucket add extras
scoop bucket add versions
scoop install vscode
