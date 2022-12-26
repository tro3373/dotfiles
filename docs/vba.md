# 数式

## シート名入力セルを参照し、対象シートのデータを参照
```
=INDIRECT(B5&"!F2")
```

## シート名を参照
```
=MID(CELL("filename",A1),FIND("]",CELL("filename",A1))+1,LEN(CELL("filename",A1)))
```

# VBA Macro

## チート

```
Range("A1").Clear ' 値・書式設定・罫線などすべてクリア
Range("A1").ClearContents ' 値だけクリア
Range("A1").Font.ColorIndex = xlAutomatic '文字色を自動に
Range("A1").Font.ColorIndex = 2 '文字色変更（インデックス表記）
Range("A1").Font.Color = RGB(0, 0, 0) '文字色変更（RGB表記）
Range("A1").Interior.ColorIndex = xlNone '背景色をなしに
Range("A1").Interior.ColorIndex = 2 '背景色変更（インデックス表記）
Range("A1").Interior.ColorIndex = RGB(0, 0, 0) '背景色変更（RGB表記）

' 連続したデータが入っている範囲の最終端を取得
n = Range("A1").End(xlDown).Row '縦方向
n = Range("A1").End(xlToRight).Column '横方向

' 最後のセルから最終端を取得
n = Cells(Rows.Count, 1).End(xlUp).row '縦方向
n = Cells(1, Columns.Count).End(xlToLeft).Column '横方向

' シートで使われているセルの最終端を取得
n = ActiveSheet.UsedRange.Columns.count '最終行
n = ActiveSheet.UsedRange.Rows.count '最終列

' 変数を含んだ範囲指定
Range(Cells(a, b), Cells(c, d)).Select

' 選択されてる範囲の一部を取得
n = Selection.Cells(1).Row '最初のセルの行
n = Selection.Cells(Selection.Count).Row '最後のセルの行
n = Selection.Cells(1).Column '最初のセルの列
n = Selection.Cells(Selection.Count).Column '最後のセルの列

' 罫線の操作
' 基本形
Range("A1:E5").Borders.LineStyle = xlContinuous '実線をひく

' 線の種類
With Range("A1:E5").Borders
  .LineStyle = xlContinuous '実線
  .LineStyle = xlDash '破線
  .LineStyle = xlDot '点線
  .LineStyle = xlDouble '二重線
  .LineStyle = xlNone '削除
End With

'線の太さ
With Range("A1:E5").Borders
  .Weight = xlThin '細（指定しなければこれ）
  .Weight = xlMedium '中
  .Weight = xlThick '太
End With

'線の色
With Range("A1:E5").Borders
  .ColorIndex = xlAutomatic '自動（指定しなければこれ）
  .ColorIndex = 3 '赤
  .ColorIndex = 5 '青
End With

'線の細かい位置
With Range("A1:E5")
  .Borders.LineStyle = xlContinuous '枠と格子全部に適用
  .Borders(xlEdgeTop).LineStyle = xlContinuous '上辺
  .Borders(xlEdgeRight).LineStyle = xlContinuous '右辺
  .Borders(xlEdgeBottom).LineStyle = xlContinuous '下辺
  .Borders(xlEdgeLeft).LineStyle = xlContinuous '左辺
  .Borders(xlInsideHorizontal).LineStyle = xlContinuous '中横線
  .Borders(xlInsideVertical).LineStyle = xlContinuous '中縦線
  .Borders(xlDiagonalUp).LineStyle = xlContinuous '右上がり斜線
  .Borders(xlDiagonalDown).LineStyle = xlContinuous '右下がり斜線
End With

' 並び替え
'A1:E100範囲をC1を基準に昇順に並び替え
Range("A1:E100").Sort Key1:=Range("C1"), order1:=xlAscending '降順はxlDescending

'3つまで優先キーを設定できる
Range("A1:E100").Sort _
  Key1:=Range("C1"), order1:=xlAscending, _
  Key2:=Range("B1"), order2:=xlDescending, _
  Key3:=Range("D1"), order3:=xlAscending

' ブックを開く
Workbooks.Open "（フルパス）ブック名.xlsm"
Workbooks.Open Filename:="（フルパス）ブック名.xlsm", ReadOnly:=True '読み取り専用で開く
' 開いたブックを変数に格納
Dim wb As Workbook
Set wb = Workbooks.Open("（フルパス）ブック名.xlsm")

' ブックを閉じる
Workbooks("ブック名.xlsm").Close
Workbooks("ブック名.xlsm").Close saveChanges:=True '保存して閉じる
Workbooks("ブック名.xlsm").Close saveChanges:=False '保存しないで閉じる

' 保存
Workbooks("ブック名.xlsm").Save '上書き保存
Workbooks("ブック名.xlsm").SaveAs "（フルパス）新ブック名.xlsm" '別名保存

' コピペ
Range("A1").Copy 'コピー
Range("A1").PasteSpecial 'ペースト
Range("A1").PasteSpecial Paste:=xlPasteValues '値だけペースト
Range("A1").PasteSpecial Paste:=xlPasteFormats '書式だけペースト
Range("A1").AutoFill Destination:=Range("A1:A5") 'オートフィル
Application.CutCopyMode = False 'コピーモード解除

' ファイル・フォルダ操作
'ファイル名変更
Name 変更前のファイル名(フルパス) As 変更後のファイル名(フルパス)
'ファイルコピー
FileCopy コピー前のファイルのフルパス, コピー後のファイルのフルパス
'ファイル削除
Kill 対象ファイルのフルパス
'フォルダ作成
MkDir パス名

' ファイル・フォルダの存在場所
str = ThisWorkbook.Path '現在操作しているブックのパス
str = ThisWorkbook.Name '現在操作しているブックのファイル名
str = ThisWorkbook.FullName '現在操作しているブックのフルパス
str = CreateObject("WScript.Shell").SpecialFolders("MyDocuments") 'マイドキュメントのパス
str = CreateObject("WScript.Shell").SpecialFolders("Desktop") 'デスクトップのパス

' 数値を文字列に変換
str = CStr(n) '変数nは数値であること

' 総文字数を取得
n = Len(対象文字列)

' 文字の抜き出し
str = Left(対象文字列, n) '対象文字列の左からn文字抜き出す
str = Right(対象文字列, n) '対象文字列の右からn文字抜き出す
str = Mid(対象文字列, n, i) '対象文字列の左からn文字目からi文字抜き出す

' 置換
str = Replace(対象文字列, 置換前文字, 置換後文字)

' 含まれているか
n = InStr(対象文字列, 探す文字列) '見つかればその最初の文字数を返し、見つからなければ0を返す

' 日付のフォーマット変更
str = Format(対象物(Dateなどの日付), "yyyy/mm/dd")

' 日付の計算
d = DateAdd(設定値, 計算数, 対象) '設定値：年→"yyyy", 月→"m", 日→"d", 週→"ww", 時→"h", 分→"n", 秒→"s"

' 「ファイルを開く」ウインドウを出す
CreateObject("WScript.Shell").CurrentDirectory = 任意のパス '開くフォルダを指定
str = Application.GetOpenFilename("ﾌｧｲﾙ,*.*")
' strには選択されたファイルのフルパス、キャンセル時にはFalseが返る
' strをStringで宣言しているときには
' If str = "False" Then Exit Sub
' のように""で括ってエラー処理をする（Variantで宣言したほうが楽かも）

' メッセージボックス
MsgBox ("サンプルテキスト") 'OKのみ
n = MsgBox("サンプルテキスト", vbOKCancel) '戻り値(n)：OK→1, キャンセル→2
n = MsgBox("サンプルテキスト", vbYesNoCancel) '戻り値(n)：はい→6, いいえ→7, キャンセル→2
n = MsgBox("サンプルテキスト", vbYesNo) '戻り値(n)：はい→6, いいえ→7

```

## 全てのシートで 左上にカーソルをあわせる
```
Sub select_a1_all()
    For Each s In Worksheets
        s.Select
        Cells(1, 1).Select
    Next
    Sheets(1).Activate
End Sub
```

## シート名一覧を作成する
```
Sub sheetNameList()
    Sheets.Add Before:=Sheets(1)
    ActiveSheet.Name = "シート名一覧"

    Dim i As Long
    For i = 2 To Sheets.Count
        Cells(i - 1, "A").Value = Sheets(i).Name
    Next i
End Sub
```

## 全シートコピー(Range指定)
```
Private Sub CommandButton1_Click()
    Dim Sheet As Worksheet
    For Each Sheet In ThisWorkbook.Worksheets
        If Sheet.Name <> "Definitions" And Sheet.Name <> "fx" And Sheet.Name <> "Needs" Then
            Sheet.Range("D12:L18").Copy
            Sheet.Range("Q12:Y18").PasteSpecial Paste:=xlValues, Operation:=xlNone, SkipBlanks:=False, Transpose:=False
        End If
    Next
End Sub
```

## 全シートコピー
```
Sub CopyAllH()

    Dim wrk  As Workbook    'Workbook object
    Dim sht  As Worksheet   'Object for handling worksheets in loop
    Set wrk = ActiveWorkbook    'Working in active workbook

    For Each sht In wrk.Worksheets
        If sht.name = "Master" Then
            sht.Delete
        End If
    Next sht

    'We don't want screen updating
    Application.ScreenUpdating = False

    'Add new worksheet as the last worksheet
    Dim trg  As Worksheet   'Master Worksheet as a target
    Set trg = wrk.Worksheets.Add(After:=wrk.Worksheets(wrk.Worksheets.Count))

    'Rename the new worksheet
    trg.name = "Master"

    'We can start loop
    Dim i    As Integer     'Some index
    Dim col  As Integer     'Column count
    Dim rng  As Range       'Range object
    Dim rng1 As Range       'Range object
    Dim rng2 As Range       'Range object
    For i = 1 To wrk.Worksheets.Count - 1

        'Select sheet
        Set sht = wrk.Worksheets(i)

        'Data range in worksheet
        Set rng1 = sht.Cells.Find("*", [A1], , , xlByRows, xlPrevious)
        Set rng2 = sht.Cells.Find("*", [A1], , , xlByColumns, xlPrevious)
        Set rng = sht.Range(sht.Cells(1, 1), sht.Cells(rng1.Row, rng2.Column))

        'Put data into the Master worksheet
        col = trg.Cells(2, Columns.Count).End(xlToLeft).Column
        rng.Copy
        With trg.Cells(1, col)
            .PasteSpecial xlPasteValues
            Application.CutCopyMode = False
        End With

    Next i

    'Fit the columns in Master worksheet
    trg.Columns.AutoFit

    'Screen updating should be activated
    Application.ScreenUpdating = True

End Sub
```

## テーブル定義からSQL DDL生成(MySQL)

```
Public row As Integer
Public OutBookName As String
Public OutSheetName As String

' 入力ファイル選択
Function getInputFilePath() As String
    Dim OpenFileName As String
    ChDir ThisWorkbook.Path
    OpenFileName = Application.GetOpenFilename("Microsoft Excelブック,*.xls?", MultiSelect:=False)
    If OpenFileName = "False" Then
        OpenFileName = ""
    End If
    getInputFilePath = OpenFileName
End Function


' シートクリア
Sub clearOutSheet()
    Dim tmp As Worksheet, flag As Boolean
    For Each tmp In ThisWorkbook.Worksheets
        If tmp.Name = OutSheetName Then
            Application.DisplayAlerts = False
            Sheets(OutSheetName).Delete
            Application.DisplayAlerts = True
            Exit For
        End If
    Next tmp
    ' 新規シート作成
    Sheets.Add after:=Worksheets(Worksheets.Count)
    ActiveSheet.Cells.Font.Name = "Meiryo UI"
    ActiveWindow.Zoom = 80
    ActiveSheet.Columns(1).ColumnWidth = 100
    ActiveSheet.Name = OutSheetName
End Sub

' セル出力
Function output2Cell(val As String)
    Dim wb As Workbook
    Set wb = ThisWorkbook
    wb.Worksheets(OutSheetName).Cells(row, 1).Value = val
    row = row + 1
End Function


Sub output2Sheet()
    row = 1
    OutBookName = ActiveWorkbook.Name
    OutSheetName = "SQL"

    ThisWorkbook.Activate
    Dim inputFilePath As String
    inputFilePath = getInputFilePath
    If Len(inputFilePath) = 0 Then
        Exit Sub
    End If

    clearOutSheet

    Dim targetWb As Workbook
    'Application.ScreenUpdating = False
    Set targetWb = Workbooks.Open(inputFilePath, UpdateLinks:=0, ReadOnly:=True)
    ActiveWindow.Visible = False

    Dim sht As Worksheet
'    For Each sht In ThisWorkbook.Worksheets
    For Each sht In targetWb.Worksheets
        If Not LCase(sht.Name) Like "m_*" And Not LCase(sht.Name) Like "t_*" And Not LCase(sht.Name) Like "s_*" And Not LCase(sht.Name) Like "mst_*" And Not LCase(sht.Name) Like "trn_*" Then
            GoTo Continue
        End If

        If (sht.Name Like "*_データ") Then
            GoTo Continue
        End If

        ' ===============================================================
        ' ！！！オプションキー指定！！！
        ' ===============================================================
        optKeys1 = sht.Cells(1, 54).Value
        optKeys2 = sht.Cells(2, 54).Value
        optKeys3 = sht.Cells(3, 54).Value

        If (optKeys1 = "NT") Then
            GoTo Continue
        End If

        tableName = LCase(sht.Name)
        'tableName = LCase(sht.Cells(1, 23).Value)

        If (tableName Like "s_*") Then
            Call output2Cell("CREATE TABLE `" & tableName & "` (id MEDIUMINT NOT NULL) ENGINE=MyISAM;")
            Call output2Cell("INSERT INTO `" & tableName & "` VALUES (0);")
            GoTo Continue
        End If

        Call output2Cell("DROP TABLE IF EXISTS `" & tableName & "`;")
        Call output2Cell("CREATE TABLE `" & tableName & "` (")

        n = sht.Cells(Rows.Count, 3).End(xlUp).row
        pkeys = ""

        For i = 6 To n
            ' カラム名
            colId = sht.Cells(i, 3).Value
            ' カラム日本語名
            colName = Replace(sht.Cells(i, 11).Value, vbLf, "")
            ' 型
            colType = sht.Cells(i, 19).Value

            autoIncrement = ""
            If (colId = "id" Or colId = "ID") And (colName = "id" Or colName = "ID") And (colType Like "*INT") Then
                ' colTypeStr = "INT UNSIGNED"
                colTypeStr = colType
                autoIncrement = " AUTO_INCREMENT"
            ' ElseIf colType = "INT" Then → INTEGER は INT のシノニム
            '     colTypeStr = "INTEGER"
            ElseIf colType = "DEC" Then
                colTypeStr = "DECIMAL"
            Else
                colTypeStr = colType
            End If

            ' カラム桁
            colLen1 = sht.Cells(i, 23).Value
            ' カラム少数桁
            colLen2 = sht.Cells(i, 25).Value
            If colTypeStr = "TEXT" Or colTypeStr = "BLOB" Then
                ' 桁部分を無視
            ElseIf colLen1 <> "" And Trim(colLen2) <> "" Then
                colTypeStr = colTypeStr & "(" & colLen1 & "," & colLen2 & ")"
            ElseIf colLen1 <> "" Then
                colTypeStr = colTypeStr & "(" & colLen1 & ")"
            End If
            colTypeStr = colTypeStr & autoIncrement

            ' NOT NULL の指定
            nn = sht.Cells(i, 27).Value
            If Trim(nn) <> "" Then
                nn = "NOT NULL"
            End If

            ' PKEY項目の収集
            pkey = sht.Cells(i, 30).Value
            If Trim(pkey) = "UK" Then
                colTypeStr = colTypeStr & " UNIQUE"
            ElseIf Trim(pkey) <> "" Then
                If pkeys <> "" Then
                    pkeys = pkeys & ","
                End If
                pkeys = pkeys & "`" & colId & "`"
            End If

            Call output2Cell("`" & colId & "` " & colTypeStr & " " & nn & " COMMENT '" & colName & "',")
        Next i

        If pkeys <> "" Then
            tmpComma = ""
            If optKeys1 <> "" Or optKeys2 <> "" Or optKeys3 <> "" Then
                tmpComma = ", "
            End If
            Call output2Cell("PRIMARY KEY (" & pkeys & ")" & tmpComma)
        End If
        If optKeys1 <> "" Then
            Call output2Cell("" & optKeys1)
        End If
        If optKeys2 <> "" Then
            Call output2Cell("" & optKeys2)
        End If
        If optKeys3 <> "" Then
            Call output2Cell("" & optKeys3)
        End If

        Call output2Cell(") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci")
        tableComment = sht.Cells(2, 23).Value
        Call output2Cell("comment='" & tableComment & "';")
        Call output2Cell("")


Continue:
    Next
    targetWb.Close SaveChanges:=False

    ThisWorkbook.Activate
    Sheets(OutSheetName).Activate
    lastrow = Sheets(OutSheetName).Range("A65536").End(xlUp).row
    Sheets(OutSheetName).Range("A1:A" & lastrow).Select
    MsgBox "出力しました。"
End Sub


' ' ファイル生成(Depricated)
'Sub output2SqlFile()
'    Dim ddlFile As String
'    ddlFile = ActiveWorkbook.Path & "\create_table.sql"
'
'    Open ddlFile For Output As #1
'
'    Dim Sheet As Worksheet
'    For Each sht In ThisWorkbook.Worksheets
'        If sht.Name Like "MST*" Or sht.Name Like "TRN*" Then
'            Print #1, "DROP TABLE IF EXISTS `" & sht.Name & "`;"
'            Print #1, "CREATE TABLE `" & sht.Name & "` ("
'
'            n = sht.Range("C6").End(xlDown).row
'            pkeys = ""
'            For i = 6 To n
'                colId = sht.Cells(i, 3).Value
'                colName = sht.Cells(i, 11).Value
'
'                colType = sht.Cells(i, 19).Value
'
'                If colId = "id" And colName = "id" Then
'                    colTypeStr = "INTEGER AUTO_INCREMENT"
'                ElseIf colType = "INT" Then
'                    colTypeStr = "INTEGER"
'                ElseIf colType = "DEC" Then
'                    colTypeStr = "DECIMAL"
'                Else
'                    colTypeStr = colType
'                End If
'
'                colLen1 = sht.Cells(i, 23).Value
'                colLen2 = sht.Cells(i, 25).Value
'                If colLen1 <> "" And colLen2 <> "" Then
'                    colTypeStr = colTypeStr & "(" & colLen1 & "," & colLen2 & ")"
'                ElseIf colLen1 <> "" Then
'                    colTypeStr = colTypeStr & "(" & colLen1 & ")"
'                End If
'
'                nn = sht.Cells(i, 27).Value
'                If nn <> "" Then
'                    nn = "NOT NULL"
'                End If
'
'                pkey = sht.Cells(i, 30).Value
'                If pkey <> "" Then
'                    If pkeys <> "" Then
'                        pkeys = pkeys & ","
'                    End If
'                    pkeys = pkeys & "`" & colId & "`"
'                End If
'
'                Print #1, "`" & colId & "` " & colTypeStr & " " & nn & " COMMENT '" & colName & "',"
'            Next i
'            If pkeys <> "" Then
'                Print #1, "PRIMARY KEY (" & pkeys & ")"
'            End If
'            If optKeys <> "" Then
'                If pkeys <> "" Then
'                    optKeys = "," & optKeys
'                End If
'                Print #1, optKeys
'            End If
'
'            Print #1, ") ENGINE=InnoDB DEFAULT CHARSET=utf8;"
'            Print #1, ""
'        End If
'    Next
'
'    Close #1
'    MsgBox "create_table.sqlに書き出しました"
'End Sub
'
```

## 非表示の名前リストを表示設定
```
Public Sub VisibleNames()
    Dim name As Object
    For Each name In Names
        If name.Visible = False Then
            name.Visible = True
        End If
    Next
    MsgBox "すべての名前の定義を表示しました。Ctrl+F3で表示", vbOKOnly
End Sub
```
