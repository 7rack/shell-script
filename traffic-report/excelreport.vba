Sub instertpng()
    Dim i As Integer
    Dim FilPath As String
    Dim rng As Range
    Dim S As String
    Dim prepng As Shape

    With Sheet3
       
'删除已有图片
    For Each prepng In ActiveSheet.Shapes
      If prepng.Type <> 8 Then
        prepng.Delete
      End If
    Next prepng
'插入今天的流量图
    DirPath = ThisWorkbook.Path & "\pngfile\"
    For i = 7 To .Range("j65536").End(xlUp).Row 'Step 6
    If Cells(i, 10).Text <> "" Then
     
        FilePath = DirPath & .Cells(i, 10).Text & ".png"
        ' MyFile = Dir(FilePath)
        If FilePath <> DirPath And Dir(FilePath) <> "" Then '判断文件是否存在或者读到空行
        '.Pictures.Insert(FilePath).Select
        .Shapes.AddPicture(FilePath, False, True, rl, rt, rw, rh).Select
        Set rng = Range(Cells(i, 4), Cells(i + 5, 4))
        With Selection
               'ActiveSheet.Rows(i).RowHeight = 179.25 '调整行高适合图片大小 Selection.ShapeRange.Height * imgHeight
               ActiveSheet.Columns(4).ColumnWidth = 73.75 '粗略调整列宽适合图片大小 Selection.ShapeRange.Width * imgWidth

            .Top = rng.Top + 1
            .Left = rng.Left + 1
            .Width = rng.Width - 1
            .Height = rng.Height - 1
         End With
        Else
         S = S & Chr(10) & .Cells(i, 10).Text
        End If
        
    End If
    Next i
    '.Cells(i + 6, 15).Select
    End With
If S <> "" Then
    MsgBox S & Chr(10) & "没有图片!"
End If
End Sub

Sub Importdata()
        Dim fso As Object, sFile As Object, blnExist As Boolean
        Dim FileName As String, LineText As Variant, i As Integer, iCol As Integer
        Const ForReading = 1
        
        With Sheet3
        
        Set fso = CreateObject("Scripting.FileSystemObject")    '创建FileSystemObject对象
        FileName = ThisWorkbook.Path & "\reportlist.txt" '指定文本文件名
        blnExist = fso.FileExists(FileName) '判断文件是否存在，如果不存在，则退出过程
        If Not blnExist Then MsgBox "文件不存在！": Exit Sub
        Set sFile = fso.OpenTextFile(FileName, ForReading) '创建并打开名为sFile的TextStream对象
        '读取第一行数据
        'Sheet3.Range("A1").Value = Replace(sFile.ReadLine, "-", "")
        sFile.SkipLine  '跳过第一行标题
        sFile.SkipLine  '跳过第二行的空行
        
        iCol = 0
        
        Do While Not sFile.AtEndOfStream    '如果不是文本文件的尾端，则读取数据
            LineText = Split(sFile.ReadLine, "|")   '拆分读取到的数据到数组中
            
            For j = 7 To .Range("j65536").End(xlUp).Row
                '判断索引列是否有空值
                If .Cells(j, 10).Text <> "" Then
                    If Replace(LineText(iCol + 1), " ", "") = .Cells(j, 10).Text Then '判断两者客户的ID是否匹配
                        If Replace(LineText(iCol + 2), " ", "") = "InboundMaximum" Then
                            .Cells(j + 1, iCol + 7).Value = Replace(LineText(iCol + 3), " ", "")
                        ElseIf Replace(LineText(iCol + 2), " ", "") = "OutboundMaximum" Then
                            .Cells(j + 2, iCol + 7).Value = Replace(LineText(iCol + 3), " ", "")
                        ElseIf Replace(LineText(iCol + 2), " ", "") = "InboundAverage" Then
                            .Cells(j + 4, iCol + 7).Value = Replace(LineText(iCol + 3), " ", "")
                        ElseIf Replace(LineText(iCol + 2), " ", "") = "OutboundAverage" Then
                            .Cells(j + 5, iCol + 7).Value = Replace(LineText(iCol + 3), " ", "")
                            sFile.SkipLine '跳过下划线这行
                        End If
                     Exit For '跳出for循环
                    End If
           
                End If
            Next j
        Loop
        '#这里可以加入设置单元格格式的代码
        sFile.Close
        Set fso = Nothing
        Set sFile = Nothing
        
        End With
 End Sub
