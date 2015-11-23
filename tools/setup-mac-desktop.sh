#!/bin/bash

# .DS_Store not make settings.
defaults write com.apple.desktopservices DSDontWriteNetworkStores true
# Show All Files in Finder.
defaults write com.apple.finder AppleShowAllFiles TRUE
# Quicklookで文字を選択・コピペできるようにする
defaults write com.apple.finder QLEnableTextSelection -bool true
# Finderの音を消す
# dvexec defaults write com.apple.finder FinderSounds -bool no
# Dockにスペース(空白)を挿入
# dvexec defaults write com.apple.dock persistent-others -array-add '{tile-data={}; tile-type="spacer-tile";}'
# Dockの隠しアニメーション「Suck」を有効にする
# dvexec defaults write com.apple.dock mineffect suck
# Mission Controlの速度を変更する
# defaults write com.apple.dock expose-animation-duration -float 0.1

# Delete Localized directory names, and to set eng name Setting.
delifexist ~/Applications/.localized
delifexist ~/Desktop/.localized
delifexist ~/Documents/.localized
delifexist ~/Downloads/.localized
delifexist ~/Movies/.localized
delifexist ~/Music/.localized
delifexist ~/Pictures/.localized
delifexist ~/Public/.localized
delifexist ~/Library/.localized

echo "#================================================================"
echo "# Finder extend"
echo "#================================================================"
echo "   Install App XtraFinder.app"
echo ""
echo "#================================================================"
echo "# mouse scroll and touch pad setting..."
echo "#================================================================"
echo "   Install App Scroll Reverser.app"
echo ""
echo "#================================================================"
echo "# Window snaping tools"
echo "#================================================================"
echo "   Install App Better touch tool.app"
echo ""
echo "#================================================================"
echo "# Keybind tools"
echo "#================================================================"
echo "   Install App Karabiner.app"
echo ""
echo "#================================================================"
echo "# Keybind setting"
echo "#================================================================"
echo "  caps lock to command."
echo "    System Enviroments - Keyboard - modification key"
echo ""
echo "#================================================================"
echo "# Mission Control disable."
echo "#================================================================"
echo "  System Enviroments - Keyboard - shortcut - Mission Control"
echo ""
echo "#================================================================"
echo "# Change KeyMap for change window of same App "
echo "#================================================================"
echo "  System Enviroments - Keyboard - modification key - shortcut - keyboard - 次のウィンドウを操作対処にする"
echo ""
