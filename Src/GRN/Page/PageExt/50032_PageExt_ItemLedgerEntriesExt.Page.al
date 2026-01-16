pageextension 50032 ItemLedgerEntriesExt extends "Item Ledger Entries"
{
    layout
    {
        addafter("Item No.")
        {
            field("W_Parent Item No."; Rec."W_Parent Item No.") //PT-FBTS-16-01-26
            { ApplicationArea = all; }
            field("W_Parent Item Descrption"; Rec."W_Parent Item Descrption")  //PT-FBTS-16-01-26
            { ApplicationArea = all; }
        }
        addafter("Lot No.")
        {
            field(BrandName; Rec.BrandName)
            {
                Caption = 'Brand Name';
            }
            field(ManufacturingDate; rec.ManufacturingDate)
            {
                Caption = 'Manufacturing Date';
            }
            field(ExpirationDate; Rec."Expiration Date")
            {
                Caption = 'Expiration Date';
            }
            /*
            field(Uom; Rec."Unit of Measure Code")
            {
                Caption = 'Unit of Measure Code';
            }
            */
            field(BaseUoM; BaseUoM)
            {
                Caption = 'Base Unit Of Measure';
            }


        }
        addafter("Entry Type") ///PT-FBTS
        {
            field(SystemCreatedAt; SystemCreatedAt)
            {
                ApplicationArea = all;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    trigger OnAfterGetRecord()
    var
    begin
        IF TempItem.Get(Rec."Item No.") then
            BaseUoM := TempItem."Base Unit of Measure";
    end;

    trigger OnOpenPage()
    var
        TempUserSetup: Record "User Setup";
    begin
        //mahendra
        IF TempUserSetup.Get(UserId) Then;
        IF TempUserSetup."Location Code" <> '' then Begin
            Rec.FilterGroup(2);
            Rec.setfilter(Rec."Location Code", '=%1', TempUserSetup."Location Code");
            Rec.FilterGroup(0);
        End;
        //end
    end;

    var
        myInt: Integer;
        TempItem: Record Item;
        BaseUoM: Code[10];
}