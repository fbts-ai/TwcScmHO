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