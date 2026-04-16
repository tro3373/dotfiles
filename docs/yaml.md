## 改行表現
### ブロックスカラー
- `|` (literal style)
  - 改行をそのまま保持
  - 末尾の改行は1つ残る
  - Example:
    ```yaml
    ## `"line 1\nline 2\n"`
    description: |
      line 1
      line 2
    ```
- `>` (folded style)
  - 改行を空白に変換（折りたたみ）
  - 末尾の改行は1つ残る
  - Example:
    ```yaml
    ## `"line 1 line 2\n"`
    description: >
      line 1
      line 2
    ```

### チョンピングインジケーター（末尾処理）
- `|-` (strip)
  - 末尾の改行を全て削除
  - Example:
    ```yaml
    ## `"line 1\nline 2"`
    description: |-
      line 1
      line 2
    ```

- `|+` (keep)
  - 末尾の改行を全て保持
  - Example:
    ```yaml
    ## `"line 1\nline 2\n\n\n"`
    description: |+
      line 1
      line 2


    ```
### 組み合わせ例
  ```yaml
  ## 改行保持 + デフォルト（末尾改行1つ）
  ## => `"line 1\nline 2\n"`
  description: |
    line 1
    line 2
  ## 改行保持 + 末尾削除
  ## => `"line 1\nline 2"`
  description: |-
    line 1
    line 2
  ## 改行保持 + 末尾保持
  ## => `"line 1\nline 2\n\n\n"`
  description: |+
    line 1
    line 2


  ## 折りたたみ + デフォルト（末尾改行1つ）
  ## => `"line 1 line 2\n"`
  description: >
    line 1
    line 2
  ## 折りたたみ + 末尾削除
  ## => `"line 1 line 2"`
  description: >-
    line 1
    line 2
  ## 折りたたみ + 末尾保持
  ## => `"line 1 line 2\n\n\n"`
  description: >+
    line 1
    line 2


  ```
### インデントインジケーター
- 数字でインデントレベルを明示できる
  ```yaml
  ## `"  line 1\n  line 2\n"`
  description: |2
      line 1
      line 2
  ```
