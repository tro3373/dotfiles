#!/bin/zsh

dirs=".zplug/autoload
.zplug/misc/completions
.zplug/base/sources
.zplug/base/utils
.zplug/base/job
.zplug/base/log
.zplug/base/io
.zplug/base/core
.zplug/base/base
.zplug/autoload/commands
.zplug/autoload/options
.zplug/autoload/tags
.zsh/Completion
.zplug
.zplug/misc
.zplug/base
.zplug/base
.zplug/base
.zplug/base
.zplug/base
.zplug/base
.zplug/base
.zplug/autoload
.zplug/autoload
.zplug/autoload
.zsh"
main() {
    # dirs=$(compaudit)
    for f in `echo $dirs`; do
        chmod 755 ~/$f
    done
}
main $*

