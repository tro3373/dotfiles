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
