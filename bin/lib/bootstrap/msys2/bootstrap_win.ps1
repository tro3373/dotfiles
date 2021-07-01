Write-Host -NoNewLine '>> Enable longpath settings first please. Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');

# Change execution policy
Set-ExecutionPolicy RemoteSigned -scope CurrentUser
# Install scoop
iex (new-object net.webclient).downloadstring('https://get.scoop.sh')

#(TODO) [Ctrl2Cap](https://docs.microsoft.com/ja-jp/sysinternals/downloads/ctrl2cap)


scoop install git
scoop install 7zip
scoop bucket add extras
scoop bucket add versions

scoop install dark innounp
# scoop checkup

# theme of powershell
scoop install concfg
concfg import harmonic-dark

scoop install googlechrome
scoop install firefox

scoop install windows-terminal
scoop install vscode
scoop install go
scoop install winscp
scoop install sumatrapdf
scoop install mpc-hc
# scoop install gitkraken
scoop install tortoisesvn

#(TODO) scoop install virtualbox
# https://laptrinhx.com/docker-wsl2-to-vagrant-virtualbox-wo-windows-de-bing-yongsuru-huan-jing-zuo-cheng-fang-fa-2550350989/
#(TODO) scoop install virtualbox-with-extension-pack-np
scoop install vagrant
scoop install slack
scoop install autohotkey

scoop bucket add jp https://github.com/dooteeen/scoop-for-jp
scoop install vim-kaoriya

scoop bucket add iyokan-jp https://github.com/tetradice/scoop-iyokan-jp
scoop install sakura-editor
scoop install winmerge-jp

scoop bucket add nonportable
scoop install google-japanese-input-np

scoop bucket add java
scoop install openjdk
scoop install adopt8-hotspot

scoop install dbeaver
# scoop cache rm *
scoop list
# scoop update *
# scoop reset *
# scoop cleanup *
# scoop uninstall <package> --purge
# scoop uninstall scoop

Write-Host -NoNewLine '>> Done. Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
