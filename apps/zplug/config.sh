#!/bin/bash

install() {
    if [ ! -d ~/.zplug ] && [ ! -L ~/.zplug ]; then
        dvexec "curl -fLo ~/.zplug/zplug --create-dirs git.io/zplug"
    fi
}

