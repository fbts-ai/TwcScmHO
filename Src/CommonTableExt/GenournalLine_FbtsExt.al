tableextension 50127 GenournalLine extends "Gen. Journal Line"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "PO No."; Code[20])
        {
            TableRelation = "Purchase Header"."No." where("Document Type" = const(Order), "Buy-from Vendor No." = field("Account No."));
        }
    }

    keys
    {
        // Add changes to keys here
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;
}