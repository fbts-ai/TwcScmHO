pageextension 50052 PostedTransfershipmentListext extends "Posted Transfer Shipments"
{
    layout
    {
        // Add changes to page layout here
        //PT-FBTS 03-07-2024
        addafter("No.")
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
        addafter("Transfer-to Code") //PT-FBTS 21052024
        {
            field("Transfer-to Name"; Rec."Transfer-to Name")
            {
                ApplicationArea = all;
            }
        }
        addafter("Transfer-from Code")//PT-FBTS 21052024
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
        TempUserSetup: Record "User Setup";
    begin
        //mahendra
        IF TempUserSetup.Get(UserId) Then;
        IF TempUserSetup."Location Code" <> '' then Begin
            Rec.FilterGroup(2);
            Rec.setfilter(Rec."Transfer-from Code", '=%1', TempUserSetup."Location Code");
            Rec.FilterGroup(0);
        End;
        //end
    end;

    var
        myInt: Integer;
}