tableextension 50117 Vendor_Ledger_Entry extends "Vendor Ledger Entry"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "PO No."; Code[20])
        {

        }

        field(50001; "Vendor Bill No"; Code[20]) //PT-FBTS-28-10-25
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup("Purch. Inv. Header"."Vendor Bill No." where("No." = field("Document No.")));
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