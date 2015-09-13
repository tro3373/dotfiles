// 新規作成時に文字コードをUTF-8,改行コードをLFに設定
if (ExpandParameter('$F') == '(無題)') {
    FileReopenUTF8(0);
    ChgmodEOL(3);
}
