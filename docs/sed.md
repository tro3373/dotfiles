# sed tips

## Replace not match keyword

```bash
sed -e "/keyword/!s/old/new/" hoge.txt
```

## Add `hoge` after match keyword

```bash
sed -e "/keyword/a hoge" hoge.txt
```

## Add `hoge` before match keyword

```bash
sed -e "/keyword/i hoge" hoge.txt
```

## Add file content after match keyword

```bash
sed -i -e "/keyword/r file.txt" hoge.txt
```

## Add file content before match keyword

```bash
sed -i -e "/keyword/{e cat file.txt\n}" hoge.txt
```

## Replace match line by file content

```bash
sed -i -e "s/keyword/cat file.txt/e" hoge.txt
```

## Replace only line number 3

```bash
sed -e "3 s/start/end/g" hoge.txt
```

## Insert `hoge` to line number 3

```bash
sed -i -e "3i hoge" hoge.txt
```

## 最短一致

`[^A]*`

```bash
$ less test.txt
{"hoge":"fuga","piyo":"foobar"}
$ less test.txt | sed -r "s/^.*?\"hoge\":\"([^\"]*)\".*$/\1/"
fuga
```

## Lower/Upper

```bash
# Lower
sed -e 's/\(.*\)/\L\1/'
# Upper
sed -e 's/\(.*\)/\U\1/'
```
## Delete empty row

```bash
sed '/^$/d' /path/to/file
```

## Delete specify row

```bash
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

## Change in specify keyword

```bash
sed -e "/keyword/s/old/new/" "$config_file"
```
