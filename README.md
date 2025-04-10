# my dotfiles

# todos
- font app settings
- enable fcitx5 in wslg but not work
  # enable fcitx5

  ```
  yay -S fcitx5-mozc
  ```

  => fcitx5 command not work
  => fcitx5-config-tool not work

  # enable sysytemd
  => systemcd process will be running! also arch too!

  ```/etc/wsl.conf
  [boot]
  systemd=true
  ```

  if systemd is running, dbus is enable, and fcitx5 is enable!
  fcitx5-config-tool is works fine!

  ```.pam_environment
  GTK_IM_MODULE DEFAULT=fcitx
  QT_IM_MODULE  DEFAULT=fcitx
  XMODIFIERS    DEFAULT=@im=fcitx
  ```

  ```.profile
  export GTK_IM_MODULE="fcitx5"
  export QT_IM_MODULE="fcitx5"
  export XMODIFIERS='@im=fcitx5'
  ```
