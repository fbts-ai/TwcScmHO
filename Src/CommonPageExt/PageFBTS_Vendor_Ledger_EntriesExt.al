pageextension 50118 VendorLedgerEntry extends "Vendor Ledger Entries"
{
    layout
    {
        // Add changes to page layout here]
        addafter("Document No.")
        {
            field("PO No."; "PO No.")
            {
                ApplicationArea = all;
                Editable = false;
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