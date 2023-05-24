# 最短一致

`[^A]*`

```
$ less test.txt
{"hoge":"fuga","piyo":"foobar"}
$ less test.txt | sed -r "s/^.*?\"hoge\":\"([^\"]*)\".*$/\1/"
fuga
```

# Lower/Upper

```
# Lower
sed -e 's/\(.*\)/\L\1/'
# Upper
sed -e 's/\(.*\)/\U\1/'
```

# Delete specify row

```
# Delete 2 to 4 line number
sed '2,4d' /path/to/file
# Delete contain specify word
sed '/target_word/d' /path/to/file
# Delete contain specify word(head)
sed '/^target_word/d' /path/to/file
# Delete contain specify word(tail)
sed '/target_word$/d' /path/to/file
```

# Delete line matched

```
sed -i '/pattern to match/d' ./infile
```
