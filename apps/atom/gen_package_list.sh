#!/bin/bash

main() {
    apm list --installed --bare > package-list.txt
}
main
