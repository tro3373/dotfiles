#!/bin/bash

# 対象ディレクトリ
target_dir=${PWD}
# UTF-8,LFでないファイルパスを出力するかどうか
output_invalid_file=0
# BOM付きUTF-8をUTF-8へ変換するかどうか
bom_remove=1
# LF変換,BOM削除を実際に変換するかどうか
execute=0
args="$@"
if [ "$args" = "exec" ]; then
    execute=1
fi

if ! type nkf >/dev/null 2>&1; then
    echo "No nkf found error...."
    exit 1
fi

set -e

alltype=()
for file in `find $target_dir -name ".git" -prune -o \
    -type f \( \
        -name "*.MF" -o \
        -name "*.prefs" -o \
        -name "*.properties" -o \
        -name "*.component" -o \
        -name "*.xml" -o \
        -name "*.jrxml" -o \
        -name "*.html" -o \
        -name "*.js" -o \
        -name "*.css" -o \
        -name "*.jsp" -o \
        -name "*.java" \
    \) -print`; do

    # ファイルの情報（エンコード、BOM、改行コード）取得
    nkf_result=`nkf --guess $file`
    # nkf --guess 結果に空白が存在する為、一旦@@@に置き換える
    nkf_result_escape=`echo $nkf_result |sed -e 's/ /@@@/g'`
    # 配列へ追加
    alltype=("${alltype[@]}" ${nkf_result_escape})

    if [ $output_invalid_file -eq 1 ]; then
        if ! echo $nkf_result |grep "UTF-8" |grep "(LF)" >/dev/null 2>&1; then
            echo "Invalid File... ${nkf_result} ===> "$file
        fi
    fi

    if [ $execute -eq 1 ]; then
        if ! echo $nkf_result |grep "(LF)" >/dev/null 2>&1; then
            echo "  LF Converting...===> "$file
            # 改行コードをLFへ変換
            nkf -Lu --overwrite $file
        fi
    fi

    if [ $execute -eq 1 ] && [ $bom_remove -eq 1 ]; then
        # UTF-8,BOM付きを削除
        if echo $nkf_result |grep "UTF-8" |grep "BOM" >/dev/null 2>&1; then
            echo "  BOM Removing... "$nkf_result" ===> "$file
            # ファイルエンコードをUTF8へ変換
            nkf -w --overwrite $file
        fi
    fi
done

echo -e ""
echo "==> Below type file existed."
echo ${alltype[@]} |tr ' ' '\n' |sed -e 's/@@@/ /g' |sort |uniq -c |sort -n

