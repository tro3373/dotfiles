Write-Host -NoNewLine '>> Enable longpath settings first please. Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');

# Change execution policy
Set-ExecutionPolicy RemoteSigned -scope CurrentUser
# Install scoop
iex (new-object net.webclient).downloadstring('https://get.scoop.sh')

#(TODO) [Ctrl2Cap](https://docs.microsoft.com/ja-jp/sysinternals/downloads/ctrl2cap)

# Insatall first..
scoop install git
scoop install 7zip

# Add additional bucket
scoop bucket add extras
scoop bucket add versions
## For vim-kaoriya
scoop bucket add jp https://github.com/dooteeen/scoop-for-jp
## For sakura-editor,winmerge-jp
scoop bucket add iyokan-jp https://github.com/tetradice/scoop-iyokan-jp
## For google-japanese-input-np
scoop bucket add nonportable
## For java
scoop bucket add java
## For JetBrains
scoop bucket add JetBrains


# Install packages
scoop install dark innounp
scoop install concfg # theme of powershell
concfg import harmonic-dark

scoop install autohotkey
scoop install google-japanese-input-np
# scoop install googlechrome
scoop install vim-kaoriya
scoop install windows-terminal
scoop install virtualbox-with-extension-pack-np
scoop install vagrant
scoop install msys2

scoop install sumatrapdf
scoop install vscode
scoop install sakura-editor
scoop install winmerge-jp
scoop install winscp
scoop install mpc-hc
# scoop install tortoisesvn
scoop install dbeaver
scoop install firefox
scoop install slack
scoop install IntelliJ-IDEA

# Install lang..
scoop install go
# scoop install openjdk
# scoop install adopt8-hotspot

# Nouse
# scoop install gitkraken
#(TODO) scoop install virtualbox
# https://laptrinhx.com/docker-wsl2-to-vagrant-virtualbox-wo-windows-de-bing-yongsuru-huan-jing-zuo-cheng-fang-fa-2550350989/

Write-Host '>> Listing scoop packages..'
scoop list

# scoop checkup
# scoop cache rm *
# scoop update *
# scoop reset *
# scoop cleanup *
# scoop uninstall <package> --purge
# scoop uninstall scoop

Write-Host -NoNewLine '>> Done. Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
