pageextension 50026 SCMPostedPurchaseInvoice extends "Posted Purchase Invoices"
{
    layout
    {
        // Add changes to page layout herei\
        addafter(Amount)
        {
            field("GST Amount"; Rec."GST Amount")
            {
                ApplicationArea = all;
            }
            // field("Order No"; REC."Order No")
            // { ApplicationArea = ALL; }//pt-FBTS-12-12-25
            field("Vendor Bill No."; "Vendor Bill No.")
            { ApplicationArea = ALL; }//pt-FBTS-09-10-25
        }
    }

    actions
    {
        // Add changes to page actions here
    }
    trigger OnOpenPage()
    var
        tempusersetup: Record "User Setup";
    begin
        IF tempusersetup.get(UserId) then;
        IF tempusersetup."Location Code" <> '' then begin
            //mahendra

            Rec.FilterGroup(2);
            Rec.setfilter(Rec."Location Code", '=%1', TempUserSetup."Location Code");
            Rec.FilterGroup(0);
            //end
        end;



    end;

    var
        myInt: Integer;
}