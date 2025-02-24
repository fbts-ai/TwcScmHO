page 50066 "StockAuditSubform"
{
    PageType = ListPart;
    // ApplicationArea = All;
    // UsageCategory = Lists;
    //Editable = false;
    DeleteAllowed = false;
    SourceTable = StockAuditLine;
    Caption = 'Stock Audit Subform';
    InsertAllowed = false;//ALLE_NICK_160124
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;


    layout
    {
        area(Content)
        {
            repeater(Line)
            {


                field("Item Code"; Rec."Item Code")
                {
                    ApplicationArea = all;
                    // Editable = false;

                }
                field(Description; Rec.Description)
                {
                    Editable = false; //18/10/20204-Aashish
                }
                field(UOM; Rec."Unit of Measure Code")
                {

                }
                field("Stock in hand"; "Stock in hand")
                {
                    ApplicationArea = all;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    Editable = false; //18/10/20204-Aashish
                }

                field(Quantity; Rec.Quantity)
                {
                    Editable = false;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field(NewUOM; Rec.NewUOM)
                {
                    Caption = 'Conversion UOM';
                    Editable = false;//PT-FBTS 30-08-24   
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field(QtyperUOM; Rec.QtyperUOM)
                {
                    Caption = 'Qty Per UOM';
                }
                field(StockQty; Rec.StockQty)
                {
                    caption = 'Physical Qty Inhand';
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Reserved Qty. on Inventory"; "Reserved Qty. on Inventory")
                {
                    ApplicationArea = all;
                }
                field("Qty. (Calculated)"; "Qty. (Calculated)")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                /*
                field(physicalQty; Rec."Qty. (Phys. Inventory)")
                {
                    caption = 'Qty. (Phys. Inventory)';
                }
                */

                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = all;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = all;
                }
                field(UnitPrice; UnitPrice)
                {
                    ApplicationArea = all;
                }
                field("Reason Code"; Rec."Reason Code")
                {

                }


            }
        }

    }

    actions
    {
        area(Processing)
        {
            //ALLENick091023_start
            action("ExcelTemplate")
            {
                Caption = 'Export Excel';
                ApplicationArea = all;
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                trigger OnAction()
                var
                    stockheader: Record StockAuditHeader;
                begin
                    //ALLE_NICK_220224
                    stockheader.SetRange("No.", rec."DocumentNo.");
                    stockheader.SetFilter(Status, '%1', stockheader.Status::Open);
                    if stockheader.FindFirst() then begin
                        Report.RunModal(Report::"Export Data", false, false, Rec);
                    end
                    else
                        Message('You cannot export data; data can only be exported when the status is open.');

                end;

            }
            action(ImportExcel)
            {
                ApplicationArea = All;
                PromotedCategory = Process;
                Promoted = true;
                Image = ImportExcel;

                trigger OnAction()
                var
                    stockheader: Record StockAuditHeader;
                begin
                    //ALLE_NICK_220224
                    stockheader.SetRange("No.", rec."DocumentNo.");
                    stockheader.SetFilter(Status, '%1', stockheader.Status::Open);
                    if stockheader.FindFirst() then begin
                        ReadExcelSheet();
                        ImportOpenExcelData();
                    end
                    else
                        Message('You cannot Import data; data can only be imported when the status is open.');

                end;
            }
        }
        //ALLENick091023_End
    }
    var
        ItemList: Page "Item List";


    trigger OnAfterGetRecord()
    var
        ItemCategory: Record "Item Category";

    begin



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
        StockAuditLine: Record 50011;
    begin
        RowNo := 0;
        ColNo := 0;
        LineNo := 0;
        MaxRowNo := 0;
        TempExcelBuffer.Reset();
        if TempExcelBuffer.FindLast() then
            MaxRowNo := TempExcelBuffer."Row No.";
        for RowNo := 2 to MaxRowNo do begin
            StockAuditLine.SetRange("DocumentNo.", GetValueAtCell(RowNo, 1));
            StockAuditLine.SetRange("Item Code", GetValueAtCell(RowNo, 2));
            if StockAuditLine.FindFirst() then
                Evaluate(StockAuditLine.StockQty, GetValueAtCell(RowNo, 4));
            StockAuditLine.Validate(StockQty);
            StockAuditLine.Modify();
        end;
    end;

    var
        FileName: Text[100];
        SheetName: Text[100];
        TempExcelBuffer: Record "Excel Buffer" temporary;
    //ALLENick091023_end

}