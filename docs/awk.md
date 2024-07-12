# Replace specify column

```awk
awk -F'\t' '{OFS='\t'; gsub(/^000/, '', $155); print $0}'
```


# Print specify row

```awk
cat aaa.txt | awk 'NR==1 {print $0}'
```
