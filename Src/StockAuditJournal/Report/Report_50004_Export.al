report 50004 "Export Data"

{
    Caption = 'Export Data';
    ProcessingOnly = True;
    dataset
    {
        dataitem(StockAuditLine; StockAuditLine)
        {
            trigger OnAfterGetRecord()
            var
                myInt: Integer;
            begin
                MakeBody;
            end;
        }
    }
    trigger OnPostReport()
    begin
        createExcelBook;
    end;

    trigger OnPreReport()
    begin
        MakeExcelDataHeader();
    end;

    var
        ExcelBuf: Record "Excel Buffer" temporary;
        ReportCaption: Label 'Posted Transfer Receipts';

    local procedure MakeExcelDataHeader()
    begin
        ExcelBuf.AddColumn('Document No.', FALSE, '', TRUE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Item No.', FALSE, '', TRUE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Description', FALSE, '', TRUE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Physical Qty Inhand', FALSE, '', TRUE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
    end;

    local procedure MakeBody()
    begin
        ExcelBuf.NewRow();
        ExcelBuf.AddColumn(StockAuditLine."DocumentNo.", FALSE, '', FALSE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(StockAuditLine."Item Code", FALSE, '', FALSE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(StockAuditLine.Description, FALSE, '', FALSE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn(StockAuditLine.StockQty, FALSE, '', FALSE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
    end;

    Local procedure CreateExcelBook();
    begin
        ExcelBuf.CreateNewBook('Stock Audit Line excel');
        ExcelBuf.WriteSheet('Stock Audit Line excel', COMPANYNAME, UserId);
        ExcelBuf.CloseBook();
        ExcelBuf.SetFriendlyFilename('Stock Audit Line excel');
        ExcelBuf.OpenExcel();
    end;

}