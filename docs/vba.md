```
Sub シート名一覧を作成する()
    Dim i As Long

    Sheets.Add Before:=Sheets(1)
    ActiveSheet.Name = "シート名一覧"

    For i = 2 To Sheets.Count
        Cells(i - 1, "A").Value = Sheets(i).Name
    Next i

End Sub
```

' シート名入力セルを参照し、対象シートのデータを参照
=INDIRECT(B5&"!F2")

' シート名を参照
=MID(CELL("filename",A1),FIND("]",CELL("filename",A1))+1,LEN(CELL("filename",A1)))
