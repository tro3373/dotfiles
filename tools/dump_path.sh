#/bin/bash

split_dump() {
    target="$@"
    for tmp in `echo $target |sed -e 's/:/ /g'`; do
        echo $tmp
    done
}

split_dump $PATH

