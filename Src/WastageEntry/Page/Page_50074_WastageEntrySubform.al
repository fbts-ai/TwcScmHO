page 50074 "WastageEntrySubform"
{
    PageType = ListPart;
    // ApplicationArea = All;
    // UsageCategory = Lists;
    SourceTable = WastageEntryLine;
    Caption = 'Wastage Entry Subform';
    //Editable = true;
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

                    trigger OnValidate()
                    var
                        TempILE: Record "Item Ledger Entry";
                        qty: Decimal;
                        TempWastageHeader: Record WastageEntryHeader;

                    begin
                        TempWastageHeader.Reset();
                        TempWastageHeader.SetRange("No.", Rec."DocumentNo.");
                        IF TempWastageHeader.FindFirst() Then;
                        rec."Location Code" := TempWastageHeader."Location Code";//ALLE_NICK_11/1/23_LotFix
                        TempILE.Reset();
                        TempILE.SetRange("Item No.", Rec."Item Code");
                        TempILE.SetRange("Location Code", TempWastageHeader."Location Code");
                        IF TempILE.FindSet() then
                            repeat
                                qty := qty + TempILE.Quantity;
                            until TempILE.Next() = 0;
                        QtyInHand := qty;

                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        TempItem: Record "Item";
                        tempIndentMapping: Record "Indent Mapping";
                        TempWastageEntrySubform: Record WastageEntryHeader;
                        TempWastageHeader: Record WastageEntryHeader;

                    begin
                        TempWastageEntrySubform.Reset();
                        TempWastageEntrySubform.SetRange("No.", Rec."DocumentNo.");
                        IF TempWastageEntrySubform.FindFirst() then;
                        TempItem.Reset();
                        TempItem.SetFilter(TempItem."No.", '<>%1', '');
                        IF TempItem.FindSet() then
                            repeat
                                tempIndentMapping.reset();
                                tempIndentMapping.SetFilter("Item No.", '=%1', TempItem."No.");
                                IF tempIndentMapping.FindSet() then
                                    repeat
                                        IF ((tempIndentMapping."Location Code" = TempWastageEntrySubform."Location Code")
                                        or (tempIndentMapping."Source Location No." = TempWastageEntrySubform."Location Code")) then
                                            TempItem.Mark(true);

                                    until tempIndentMapping.Next() = 0;

                            Until TempItem.Next() = 0;

                        TempItem.MarkedOnly(true);

                        IF PAGE.RUNMODAL(0, TempItem) = ACTION::LookupOK THEN begin
                            Rec."Item Code" := TempItem."No.";
                            Rec.Validate(Rec."Item Code");

                        end;
                        TempWastageHeader.Reset();
                        TempWastageHeader.SetRange("No.", Rec."DocumentNo.");
                        IF TempWastageHeader.FindFirst() Then;
                        rec."Location Code" := TempWastageHeader."Location Code";//ALLE_NICK_11/1/23_LotFix
                    End;



                }
                field(Description; Rec.Description)
                {

                }
                field("Stock in hand"; "Stock in hand")
                {
                    ApplicationArea = all;
                }
                field(QtyInHand; QtyInHand)
                {
                    Caption = 'Qty In Hand';
                    Editable = false;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = all;
                    trigger OnValidate()
                    begin
                        if Rec.Quantity > GetQtyIHandValue() then //*** ALLE MY_09-10-2023
                            Error('Quantity Should be less or equal to Quantity in Hand.');

                        CurrPage.Update();
                    end;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    Editable = false;
                    trigger OnValidate()
                    begin
                        CurrPage.Update();

                    end;

                }
                field(UnitPrice; Rec.UnitPrice)
                {
                    ApplicationArea = all;
                }
                field(Amount; rec.Amount)
                {
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;

                }

                field(Status; Rec.Status)
                {
                    ApplicationArea = all;
                    Visible = false;
                }

                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = all;
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    TableRelation = "Reason Code";
                }


            }
        }

    }

    actions
    {
        area(Processing)
        {
            action(LotNoAssignment)
            {
                ApplicationArea = All;
                RunObject = page WastageEntryLotNoList;

                trigger OnAction();
                var
                    TempWastageEntryLotNo: Record WastageEntryLotNo;
                    PageWastageEntryLotNo: Page WastageEntryLotNoList;

                begin


                    Clear(PageWastageEntryLotNo);
                    TempWastageEntryLotNo.Reset();
                    TempWastageEntryLotNo.SetRange(WastageEntryNo, Rec."DocumentNo.");
                    TempWastageEntryLotNo.SetRange(ItemNo, Rec."Item Code");
                    TempWastageEntryLotNo.SetRange(LineNo, Rec."LineNo.");
                    TempWastageEntryLotNo.SetRange(LocationCode, rec."Location Code");
                    IF TempWastageEntryLotNo.FindSet() then;

                    PageWastageEntryLotNo.SetTableView(TempWastageEntryLotNo);
                    PageWastageEntryLotNo.SetRecord(TempWastageEntryLotNo);
                    PageWastageEntryLotNo.setwastageentryhead(Rec);

                    if PageWastageEntryLotNo.RunModal = Action::LookupOK then begin

                    end;

                    //  PageWastageEntryLotNo.Run();


                End;
            }

        }
    }
    var
        ItemList: Page "Item List";
        QtyInHand: Decimal;


    trigger OnAfterGetRecord()
    var
        ItemCategory: Record "Item Category";
        TempILE: Record "Item Ledger Entry";
        qty: Decimal;
        TempWastageHeader: Record WastageEntryHeader;

    begin
        TempWastageHeader.Reset();
        TempWastageHeader.SetRange("No.", Rec."DocumentNo.");
        IF TempWastageHeader.FindFirst() Then;

        TempILE.Reset();
        TempILE.SetRange("Item No.", Rec."Item Code");
        TempILE.SetRange("Location Code", TempWastageHeader."Location Code");
        IF TempILE.FindSet() then
            repeat
                qty := qty + TempILE.Quantity;
            until TempILE.Next() = 0;
        QtyInHand := qty;
    end;


    trigger OnAfterGetCurrRecord()
    var
        TempILE: Record "Item Ledger Entry";
        qty: Decimal;

        TempWastageHeader: Record WastageEntryHeader;

    begin

        TempWastageHeader.Reset();
        TempWastageHeader.SetRange("No.", Rec."DocumentNo.");
        IF TempWastageHeader.FindFirst() Then;

        TempILE.Reset();
        TempILE.SetRange("Item No.", Rec."Item Code");
        TempILE.SetRange("Location Code", TempWastageHeader."Location Code");
        IF TempILE.FindSet() then
            repeat
                qty := qty + TempILE.Quantity;
            until TempILE.Next() = 0;
        QtyInHand := qty;

    end;

    trigger OnDeleteRecord(): Boolean
    begin
        CurrPage.Update();
    end;

    //*** ALLE MY_09-10-2023  BEGIN
    local procedure GetQtyIHandValue(): Decimal
    var
        ItemCategory: Record "Item Category";
        TempILE: Record "Item Ledger Entry";
        qty: Decimal;
        TempWastageHeader: Record WastageEntryHeader;

    begin
        TempWastageHeader.Reset();
        TempWastageHeader.SetRange("No.", Rec."DocumentNo.");
        IF TempWastageHeader.FindFirst() Then;

        TempILE.Reset();
        TempILE.SetRange("Item No.", Rec."Item Code");
        TempILE.SetRange("Location Code", TempWastageHeader."Location Code");
        IF TempILE.FindSet() then
            repeat
                qty := qty + TempILE.Quantity;
            until TempILE.Next() = 0;
        exit(qty);
    end;
    //***ALLE MY_09-10-023  END
}