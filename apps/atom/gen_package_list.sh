#!/bin/bash

main() {
    apm list --installed --bare > package-list.txt
    sed -ie 's/@.\+$//g' package-list.txt
}
main
