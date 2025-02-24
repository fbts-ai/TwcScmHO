report 50006 "Export Indent Temp"

{
    Caption = 'Export Indent Temp';
    ProcessingOnly = True;
    dataset
    {
        dataitem(IndentHeader; IndentHeader)
        {

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
        ExcelBuf.AddColumn('No.', FALSE, '', TRUE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Type', FALSE, '', TRUE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        // ExcelBuf.AddColumn('Category', FALSE, '', TRUE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Item No.', FALSE, '', TRUE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Quantity', FALSE, '', TRUE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        // ExcelBuf.AddColumn('Amount', FALSE, '', TRUE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        // ExcelBuf.AddColumn('Qty. (Calculated)', FALSE, '', TRUE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        // ExcelBuf.AddColumn('Physical Qty Inhand', FALSE, '', TRUE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
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