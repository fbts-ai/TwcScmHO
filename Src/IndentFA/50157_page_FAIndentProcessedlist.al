page 50157 "Indent List Processed"
{
    Caption = 'FA Indent List Processed';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = IndentHeader;
    CardPageId = FAProcessedIndentCard;
    Editable = false;
    SourceTableView = sorting("No.") order(descending) where("Sub-Indent" = const(false),
     Type = const("Fixed Asset"), Status = filter(Processed)); //Applies FA

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("To Location code"; Rec."To Location code")
                {
                    ApplicationArea = all;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = all;
                }
                field("Posting date"; Rec."Posting date")
                {
                    ApplicationArea = all;
                    Caption = 'Requested Delivery Date';
                }
                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = all;
                }
                field("CreatedBy"; Rec."CreatedBy")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Sub-Indent"; rec."Sub-Indent")
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
            //     action("View Sub-Indents")
            //     {
            //         RunObject = page "Sub Indent List unedit";
            //         RunPageLink = "Sub-Indent" = const(true), "Main Indent No." = field("No.");
            //         ApplicationArea = all;
            //         Promoted = true;
            //         PromotedIsBig = true;
            //         PromotedCategory = Process;
            //         Image = ViewPage;
            //     }
            //     action("ExcelTemplate")
            //     {
            //         Caption = 'Export Excel';
            //         ApplicationArea = all;
            //         Promoted = true;
            //         PromotedCategory = Process;
            //         Image = Export;
            //         trigger OnAction()
            //         begin
            //             Report.RunModal(Report::"Export Indent Temp", false, false, Rec);
            //         end;

            //     }
            //     action("Import Indent Data")
            //     {
            //         ApplicationArea = All;
            //         PromotedCategory = Process;
            //         Promoted = true;
            //         Image = ImportExcel;

            //         trigger OnAction()
            //         begin
            //             ReadExcelSheet();
            //             ImportOpenExcelData();
            //         end;
            //     }
        }
    }

    var
        DD: Page 50;
        usersetup: Record "User Setup";

    trigger OnOpenPage()
    begin
        usersetup.Get(UserId);
        // //rec.SetRange("To Location code", usersetup."Location Code");
        // Rec.FilterGroup(2);
        // Rec.Setfilter(Rec."To Location code", '=%1|=%2', UserSetup."Location Code", '');
        // Rec.FilterGroup(1);

        // //  rec.SetFilter("Posting date", '%1', Today);//AJ_Alle_06112023
        Rec.SetRange("To Location code", usersetup."Location Code");
    end;

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
        IndentHeader: Record IndentHeader;
        IndentLine: Record Indentline;
        Invsetup: Record 313;

    begin
        RowNo := 0;
        ColNo := 0;
        LineNo := 0;
        MaxRowNo := 0;
        Invsetup.Get();
        IndentHeader.Init();
        IndentHeader.Validate("Posting date", CalcDate(Invsetup."Indent Delivery date Cal", Today));
        IndentHeader.Insert(True);
        TempExcelBuffer.Reset();
        if TempExcelBuffer.FindLast() then
            MaxRowNo := TempExcelBuffer."Row No.";
        for RowNo := 2 to MaxRowNo do begin
            LineNo := 10000;
            IndentLine.Init();
            IndentLine.Validate("DocumentNo.", IndentHeader."No.");
            IndentLine."LineNo." := IndentLine."LineNo." + LineNo;
            IndentLine.Insert();
            Evaluate(IndentLine."Type Of Item", GetValueAtCell(RowNo, 1));
            if IndentLine."Type Of Item" = IndentLine."Type Of Item"::Item then begin
                Evaluate(IndentLine.Category, GetValueAtCell(RowNo, 2));
                IndentLine.Validate("Item Code", GetValueAtCell(RowNo, 3));
                Evaluate(IndentLine.Quantity, GetValueAtCell(RowNo, 4));
            end;
            if IndentLine."Type Of Item" = IndentLine."Type Of Item"::"Fixed Asset" then begin
                Evaluate(IndentLine.Category, GetValueAtCell(RowNo, 2));
                IndentLine.Validate("Item Code", GetValueAtCell(RowNo, 3));
                Evaluate(IndentLine.Quantity, GetValueAtCell(RowNo, 4));
            end;
            IndentLine.Validate(Quantity);
            IndentLine.Modify();

        end;
    end;

    var
        FileName: Text[100];
        SheetName: Text[100];
        TempExcelBuffer: Record "Excel Buffer" temporary;
        test: page 5742;
    //ALLENick091023_end


}