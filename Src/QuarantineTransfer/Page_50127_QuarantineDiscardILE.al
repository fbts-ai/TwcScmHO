page 50127 "Quarantine Discard ILE"
{
    PageType = List;
    Caption = 'Quarantine Discard ILE';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Item Ledger Entry";
    SourceTableView = SORTING("Entry No.")
                      ORDER(Descending) where("Quarantine Location" = const(true), "Entry Type" = const("Negative Adjmt."));

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Select; rec.Select)
                {
                    ApplicationArea = all;
                    Editable = true;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting date for the entry.';
                    Editable = false;
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies which type of transaction that the entry is created from.';
                    Editable = false;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies what type of document was posted to create the item ledger entry.';
                    Editable = false;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number on the entry. The document is the voucher that the entry was based on, for example, a receipt.';
                    Editable = false;
                }

                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the item in the entry.';
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the entry.';
                    Editable = false;
                }
                field("Location Code"; rec."Location Code")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Discard Location Code"; GetDiscardLocCode(Rec."Document No."))
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Discard Location Name"; GetDiscardLocName(Rec."Document No."))
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                //AJ_ALLE_08022024
                field("MAP Value "; GETMAP(rec."Entry No."))
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                //AJ_ALLE_08022024
                field(Remarks; rec.Remarks)
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Lot No."; Rec."Lot No.") //sks 07-02-24
                {
                    ApplicationArea = all;
                }
                field("BUOM"; Rec."Unit of Measure Code") //sks 07-02-24
                {
                    ApplicationArea = all;
                }
                field(Quantity; rec.Quantity)
                {
                    ApplicationArea = all;
                }
                field("Cost Amount (Actual)"; rec."Cost Amount (Actual)") //sks 07-02-24
                {
                    ApplicationArea = all;
                }
                field("Approval Date"; DT2Date(Rec.SystemCreatedAt)) //sks 07-02-24
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
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction();
                begin

                end;
            }
        }
    }

    //sks 08-02-24
    procedure GetDiscardLocCode(ILEDocumentNo: Code[20]): Code[20]
    var
        TransferReceiptHeader: Record "Transfer Receipt Header";
    begin
        if TransferReceiptHeader.Get(ILEDocumentNo) then
            exit(TransferReceiptHeader."Transfer-from Code")
        else
            exit('');
    end;

    procedure GetDiscardLocName(ILEDocumentNo: Code[20]): Code[20]
    var
        TransferReceiptHeader: Record "Transfer Receipt Header";
        Location: Record Location;
    begin
        if TransferReceiptHeader.Get(ILEDocumentNo) then begin
            Location.Get(TransferReceiptHeader."Transfer-from Code");
            exit(Location.Name);
        end else
            exit('');
    end;
    //sks 08-02-24

    // procedure GetMAP(ILEDocumentNo: Code[20]): Code[20]
    // var
    //     TransferReceiptHeader: Record "Transfer Receipt Header";
    //     Location: Record Location;
    // begin
    //     rec.CalcFields("Cost Amount (Actual)");
    //     UnitPrice := Rec."Cost Amount (Actual)" / Rec.Quantity;
    // end;
    //AJ_ALLE_08022024
    procedure GETMAP(EntyNo: Integer): Decimal
    var
        ILERec: Record "Item Ledger Entry";
        MAPValue: Decimal;
    begin
        if ILERec.Get(EntyNo) then begin
            ILERec.CalcFields("Cost Amount (Actual)");
            MAPValue := ILERec."Cost Amount (Actual)" / ILERec.Quantity;
            exit(MAPValue);
        end else
            exit(0);
    end;
    //AJ_ALLE_08022024

    Var
        UnitPrice: Decimal;
}