#!/bin/bash

warn_if_not_exist_msmtp() {
    if ! type msmtp >/dev/null 2>&1; then
        echo "==> [Warn]"
        echo "    No msmtp exist. intall msmtp or use sendmail?"
    fi
}
main() {
    warn_if_not_exist_msmtp
    cp ./rc ~/.ssh/
    chmod 600 ~/.ssh/rc
    echo "==> Make rc file into ~/.ssh"
    echo "==> Set up it."
    echo "==> Done."
}
main
