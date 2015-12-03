#!/bin/bash

install() {
    dvexec export PATH=~/bin:$PATH
    dvexec "curl -L git.io/gomi | sh"
    #if [ "$OS" = "mac" ]; then
    #    dvexec sudo brew tap b4b4r07/gomi
    #    dvexec sudo brew install gomi
    #fi
}

