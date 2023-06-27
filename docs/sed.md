# Replace only line number 3

```
sed -e "3 s/start/end/g" hoge.txt
```

# Insert `hoge` to line number 3

```
sed -i -e "3i hoge" hoge.txt
```

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
# Delete 1 line number
sed '1d' /path/to/file
# Delete 2 to 4 line number
sed '2,4d' /path/to/file
# Delete contain specify word
sed '/target_word/d' /path/to/file
# Delete contain specify word(head)
sed '/^target_word/d' /path/to/file
# Delete contain specify word(tail)
sed '/target_word$/d' /path/to/file
```

