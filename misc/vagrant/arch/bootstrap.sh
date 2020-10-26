#!/usr/bin/env bash

readonly bootstrapped_path=/etc/bootstrapped

bootstrapped() { test -f $bootstrapped_path; }
finalize() { date | sudo tee $bootstrapped_path >/dev/null; }

setup_dot() {
  echo "==> setupping .dot .."
  if [[ ! -e ~/.dot ]]; then
    curl -fSsL git.io/tr3s | bash
  fi
  cd ~/.dot/bin
  ./setup -e vag_arch
}

main() {
  set -e
  bootstrapped && return
  setup_dot
  finalize
}
main "$@"
