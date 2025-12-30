tableextension 50127 GenournalLine extends "Gen. Journal Line"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "PO No."; Code[20])
        {
            TableRelation = "Purchase Header"."No." where("Document Type" = const(Order), "Buy-from Vendor No." = field("Account No."));
        }
        field(50001; "Order NO"; Code[20]) { } //PT-FBTS 11-12-2025
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