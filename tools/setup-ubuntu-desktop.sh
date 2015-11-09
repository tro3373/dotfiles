# Chrome install
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
sudo apt-get update
sudo apt-get install google-chrome-stable


# 日本語ディレクトリ名を英語化
env LANGUAGE=C LC_MESSAGES=C xdg-user-dirs-gtk-update

# Unity Tweak Tool
sudo apt-get install unity-tweak-tool

# Numix Icon theme
sudo apt-add-repository ppa:numix/ppa
sudo apt-get update
sudo apt-get install numix-gtk-theme numix-icon-theme numix-wallpaper-saucy numix-icon-theme-circle

# visudo エディタをvimに設定
sudo update-alternatives --config editor

# atom,sublime install
sudo add-apt-repository ppa:webupd8team/atom
sudo add-apt-repository ppa:webupd8team/sublime-text-3
sudo apt-get update
sudo apt-get install atom sublime-text-installer
npm stars --install

# Meld, rapidsvn
sudo apt-get install meld rapidsvn
