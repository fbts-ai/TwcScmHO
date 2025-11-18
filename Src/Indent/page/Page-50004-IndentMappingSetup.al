page 50004 "Indent Mapping Setup"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Indent Mapping";
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Location Code"; rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field("Item Category"; rec."Item Category")
                {
                    ApplicationArea = all;
                }
                field("Item No."; rec."Item No.")
                {
                    ApplicationArea = all;
                }
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = all;
                }
                field("Approval Required"; rec."Approval Required")
                {
                    ApplicationArea = all;
                }
                field("Consolidation Applicable"; rec."Consolidation Applicable")
                {
                    ApplicationArea = all;
                }
                field("Sourcing Method"; rec."Sourcing Method")
                {
                    ApplicationArea = all;
                }
                //PT-FBTS 03-07-2024
                field("Block Indent"; Rec."Block Indent")
                {
                    ApplicationArea = all;
                }
                //PT-FBTS 03-07-2024
                field("Source Location No."; rec."Source Location No.")
                {
                    ApplicationArea = all;
                }
                field("Max Qty."; rec."Max Qty.")
                {
                    ApplicationArea = all;
                }
                field("Min Qty."; rec."Min Qty.")
                {
                    ApplicationArea = all;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            // action("ExcelTemplate")
            // {
            //     Caption = 'Export Indent Mapping Data';
            //     ApplicationArea = all;
            //     Promoted = true;
            //     PromotedCategory = Process;
            //     Image = Export;
            //     trigger OnAction()
            //     begin
            //         Report.RunModal(Report::"Export Indent Mapping Data", false, false, Rec);
            //     end;

            // }
            // action("Import Indent Mapping Data")
            // {
            //     ApplicationArea = All;
            //     PromotedCategory = Process;
            //     Promoted = true;
            //     Image = ImportExcel;

            //     trigger OnAction()
            //     begin

            //         ReadExcelSheet();
            //         ImportOpenExcelData();

            //     end;
            // }
        }
    }

    //ALLENick091023_start
    procedure ReadExcelSheet()
    var
        myInt: Integer;
        FileMgt: Codeunit "File Management";
        IStream: InStream;
        FromFile: Text[100];

    begin
        UploadIntoStream('Choose Your Excel File', '', '', FromFile, IStream);
        if FromFile <> '' then begin
            FileName := FileMgt.GetFileName(FromFile);
            SheetName := TempExcelBuffer.SelectSheetsNameStream(IStream);
        end else
            Error('No File Found');
        TempExcelBuffer.Reset();
        TempExcelBuffer.DeleteAll();
        TempExcelBuffer.OpenBookStream(IStream, SheetName);
        TempExcelBuffer.ReadSheet();
    end;

    local procedure GetValueAtCell(RowNo: Integer; ColNo: Integer): Text
    begin
        TempExcelBuffer.Reset();
        if TempExcelBuffer.Get(RowNo, ColNo) then
            exit(TempExcelBuffer."Cell Value as Text")
        else
            exit('');
    end;

    procedure ImportOpenExcelData()
    var
        myInt: Integer;
        RowNo: Integer;
        ColNo: Integer;
        LineNo: Integer;
        MaxRowNo: Integer;
        IndentMapping: Record "Indent Mapping";
    begin
        RowNo := 0;
        ColNo := 0;
        LineNo := 0;
        MaxRowNo := 0;
        TempExcelBuffer.Reset();
        if TempExcelBuffer.FindLast() then
            MaxRowNo := TempExcelBuffer."Row No.";
        for RowNo := 2 to MaxRowNo do begin
            // StockAuditLine.SetRange("DocumentNo.", GetValueAtCell(RowNo, 1));
            // StockAuditLine.SetRange("Item Code", GetValueAtCell(RowNo, 2));
            // if StockAuditLine.FindFirst() then
            //     Evaluate(StockAuditLine.StockQty, GetValueAtCell(RowNo, 4));
            // StockAuditLine.Validate(StockQty);
            // StockAuditLine.Modify();
            IndentMapping.Init();
            IndentMapping.Validate("Location Code", GetValueAtCell(RowNo, 1));
            IndentMapping.Validate("Item Category", GetValueAtCell(RowNo, 2));
            IndentMapping.Validate("Item No.", GetValueAtCell(RowNo, 3));
            IndentMapping.Insert();
            Evaluate(IndentMapping."Consolidation Applicable", GetValueAtCell(RowNo, 4));
            Evaluate(IndentMapping."Sourcing Method", GetValueAtCell(RowNo, 5));
            Evaluate(IndentMapping."Source Location No.", GetValueAtCell(RowNo, 6));
            IndentMapping.Modify();
        end;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        IndentMapp: Record "Indent Mapping";
        ErrorText: Text;
    begin
        IndentMapp.Copy(Rec);
        ErrorText := '';

        if IndentMapp.FindSet() then
            repeat
                // Location Code
                if IndentMapp."Location Code" = '' then
                    ErrorText += StrSubstNo(
                        'Location Code is blank. Item: %1\',
                        IndentMapp."Item No.");

                // Item No.
                if IndentMapp."Item No." = '' then
                    ErrorText += StrSubstNo(
                        'Item No. is blank. Location: %1\',
                        IndentMapp."Location Code");

                // Sourcing Method
                if IndentMapp."Sourcing Method" = IndentMapp."Sourcing Method"::" " then
                    ErrorText += StrSubstNo(
                        'Sourcing Method is blank. Location: %1  Item: %2\',
                        IndentMapp."Location Code", IndentMapp."Item No.");

                // Source Location No.
                if IndentMapp."Source Location No." = '' then
                    ErrorText += StrSubstNo(
                        'Source Location No. is blank. Location: %1  Item: %2\',
                        IndentMapp."Location Code", IndentMapp."Item No.");
            until IndentMapp.Next() = 0;

        // Show all errors together
        if ErrorText <> '' then
            Error('Please correct the following before closing:\' + ErrorText);

        exit(true);
    end;

    var
        FileName: Text[100];
        SheetName: Text[100];
        TempExcelBuffer: Record "Excel Buffer" temporary;
    //ALLENick091023_end
}