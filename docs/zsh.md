# Zsh Tips

```sh
# ~/script/test.zsh に対して
${0}        ==> ./test.zsh
${0:a}      ==> /Users/username/script/test.zsh
${0:h}      ==> .
${0:t}      ==> test.zsh
${0:a:h}    ==> /Users/username/script
${0:a:h:h}  ==> /Users/username
${0:a:h:t}  ==> script
```

