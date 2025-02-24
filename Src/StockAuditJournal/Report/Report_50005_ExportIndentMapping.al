report 50005 "Export Indent Mapping Data"

{
    Caption = 'Export Indent Mapping Data';
    ProcessingOnly = True;
    dataset
    {
        dataitem("Indent Mapping"; "Indent Mapping")
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


    local procedure MakeExcelDataHeader()
    begin
        ExcelBuf.AddColumn('Location Code', FALSE, '', TRUE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Item Category', FALSE, '', TRUE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Item No.', FALSE, '', TRUE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        // ExcelBuf.AddColumn('Item Description', FALSE, '', TRUE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        //  ExcelBuf.AddColumn('Approval Required', FALSE, '', TRUE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Consolidation Applicable', FALSE, '', TRUE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Sourcing Method', FALSE, '', TRUE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Source Location No.', FALSE, '', TRUE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        // ExcelBuf.AddColumn('Max Qty.', FALSE, '', TRUE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Number);
        // ExcelBuf.AddColumn('Minimum Inventory in days', FALSE, '', TRUE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Number);
        // ExcelBuf.AddColumn('Maximun Inventory in days', FALSE, '', TRUE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Number);
        //  ExcelBuf.AddColumn('Lead Time', FALSE, '', TRUE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Number);
    end;

    local procedure MakeBody()
    begin
        ExcelBuf.NewRow();
        ExcelBuf.AddColumn("Indent Mapping"."Location Code", FALSE, '', FALSE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn("Indent Mapping"."Item Category", FALSE, '', FALSE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn("Indent Mapping"."Item No.", FALSE, '', FALSE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        // ExcelBuf.AddColumn("Indent Mapping"."Item Description", FALSE, '', FALSE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        // ExcelBuf.AddColumn("Indent Mapping"."Approval Required", FALSE, '', FALSE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn("Indent Mapping"."Consolidation Applicable", FALSE, '', FALSE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn("Indent Mapping"."Sourcing Method", FALSE, '', FALSE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn("Indent Mapping"."Source Location No.", FALSE, '', FALSE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Text);
        // ExcelBuf.AddColumn("Indent Mapping"."Max Qty.", FALSE, '', FALSE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Number);
        // ExcelBuf.AddColumn("Indent Mapping"."Minimum Inventory in days", FALSE, '', FALSE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Number);
        // ExcelBuf.AddColumn("Indent Mapping"."Maximun Inventory in days", FALSE, '', FALSE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Number);
        // ExcelBuf.AddColumn("Indent Mapping"."Lead Time", FALSE, '', FALSE, FALSE, TRUE, '', ExcelBuf."Cell Type"::Number);
    end;

    Local procedure CreateExcelBook();
    begin
        ExcelBuf.CreateNewBook('Export Indent Mapping Data');
        ExcelBuf.WriteSheet('Export Indent Mapping Data', COMPANYNAME, UserId);
        ExcelBuf.CloseBook();
        ExcelBuf.SetFriendlyFilename('Export Indent Mapping Data');
        ExcelBuf.OpenExcel();
    end;

}