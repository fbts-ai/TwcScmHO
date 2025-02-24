tableextension 50077 PurchReceviableExt extends "Purchases & Payables Setup"
{
    fields
    {
        // Add changes to table fields here
        field(50100; SDVendPostingGrp; Code[10])
        {
            Caption = 'SD Vendor Posting Group';
            // TableRelation = Vendor."Vendor Posting Group";

        }
    }

    var
        myInt: Integer;
}