pageextension 50106 PaymentJournal extends "Payment Journal"
{
    layout
    {
        // Add changes to page layout here
        addafter(Description)
        {
            field("PO No."; Rec."PO No.")
            {
                ApplicationArea = all;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}