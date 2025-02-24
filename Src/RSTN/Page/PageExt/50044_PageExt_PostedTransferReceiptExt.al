pageextension 50044 PostedTransferReceiptExt extends "Posted Transfer Receipts"
{
    layout
    {
        addafter("No.") //PT-FBTS 03-07-2024
        {
            field("Transfer Order No."; "Transfer Order No.")
            {
                ApplicationArea = all;
            }
            field("Requistion No."; "Requistion No.")
            {
                ApplicationArea = all;
            }
        }//PT-FBTS 03-07-2024
        // Add changes to page layout here
        addafter("Transfer-to Code") //PT-FBTS 22052024
        {
            field("Transfer-to Name"; Rec."Transfer-to Name")
            {
                ApplicationArea = all;
            }
        }
        addafter("Transfer-from Code")//PT-FBTS 22052024
        {
            field("Transfer-from Name"; Rec."Transfer-from Name")
            {
                ApplicationArea = all;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }
    trigger OnOpenPage()
    var
        tempUserSetup: Record "User Setup";

    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Location Code" <> '' then begin
            Rec.FilterGroup(10);

            Rec.SetRange("Transfer-to Code", TempUsersetup."Location Code");
            Rec.FilterGroup(0);
        end;

    end;

}