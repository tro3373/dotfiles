#!/bin/bash

script_dir=$(cd $(dirname $0); pwd)
if ! type xdotool > /dev/null 2>&1; then
    sudo apt-get install -y xdotool
fi
if [[ ! -e $HOME/bin ]]; then
    mkdir -p $HOME/bin
fi
total_terminal=$script_dir/total_terminal
ln -sf $total_terminal ${HOME}/bin/total_terminal

# setup shortcut
#
#   Super key:                 <Super>
#   Control key:               <Primary> or <Control>
#   Alt key:                   <Alt>
#   Shift key:                 <Shift>
#   numbers:                   1 (just the number)
#   Spacebar:                  space
#   Slash key:                 slash
#   Asterisk key:              asterisk (so it would need `<Shift>` as well)
#   Ampersand key:             ampersand (so it would need <Shift> as well)
#
#   a few numpad keys:
#   Numpad divide key (`/`):   KP_Divide
#   Numpad multiply (Asterisk):KP_Multiply
#   Numpad number key(s):      KP_1
#   Numpad `-`:                KP_Subtract
#python3 ./setup_customshortcut.py 'TotalTerminal' '~/bin/total_terminal' '<Alt>Return'
python3 ./setup_customshortcut.py 'TotalTerminal' "$HOME/bin/total_terminal" '<Shift><Primary>'

# check list.
echo "List Custom key bindings...."
gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings

