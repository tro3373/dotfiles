#!/bin/bash

main() {
    cd ./tmp/hugo/mysite
    cat << EOF > config.yaml
---
contentdir: "content"
layoutdir: "layouts"
publishdir: "public"
indexes:
  category: "categories"
baseurl: ""
title: ""
EOF
}
main
