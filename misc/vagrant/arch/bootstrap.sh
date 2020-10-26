#!/usr/bin/env bash

readonly bootstrapped_path=/etc/bootstrapped

bootstrapped() { test -f $bootstrapped_path; }
finalize() { date | sudo tee $bootstrapped_path >/dev/null; }

setup_dot() {
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
  bootstrapped && return
  setup_dot
  finalize
}
main "$@"
