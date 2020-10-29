#!/usr/bin/env bash

readonly bootstrapped_path=/etc/bootstrapped

_bootstrapped() { test -f $bootstrapped_path; }
_finalize() { date | sudo tee $bootstrapped_path >/dev/null; }

_setup_dot() {
  echo "==> Setting up .dot .."
  if [[ ! -e ~/.dot ]]; then
    curl -fSsL git.io/tr3s | bash
  fi
  echo "===> Done. Please execute 'setup -e vag_arch' manualy."
  # cd ~/.dot/bin
  # ./setup -e vag_arch
}

main() {
  set -e
  _bootstrapped && return
  _setup_dot
  _finalize
}
main "$@"
