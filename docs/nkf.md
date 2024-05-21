# nkf cheat
```sh
# Check file encode.
nkf -g hoge.txt
# Check file encode and return code.
nkf --guess hoge.txt
# convert to shiftjis,crlf
nkf -Lw -s --overwrite hoge.txt
# convert to utf8,lf
nkf -Lu -w --overwrite hoge.txt
# Convert to Zenkaku
nkf -W hoge.txt
```
# iconv
```sh
# available encoding
iconv -l
# convert to utf8 to shiftjis
iconv -f UTF8 -t SHIFT_JIS hoge.txt -o hoge.txt
# convert to shiftjis to utf8
iconv -f SHIFT_JIS -t UTF8 hoge.txt -o hoge.txt
```

