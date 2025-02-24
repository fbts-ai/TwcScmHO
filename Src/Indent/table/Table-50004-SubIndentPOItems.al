table 50004 "Sub Indent PO"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "PO NO."; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(2; "PO Line No."; Integer)
        { }
        field(3; "Location Code"; Code[20])
        { }
        field(4; "Item No."; Code[20])
        { }
        field(5; "Item Description"; Text[250])
        { }
        field(6; "Quantity"; Integer)
        { }
        field(7; Remarks; Text[100])
        { }
        field(8; "Vendor No."; Code[20])
        { }
        field(9; "Vendor Name"; Text[100])
        { }
        field(10; "Indent No."; Code[25])
        { }
        field(11; "Indent Quantity"; Decimal)
        { }
        field(12; "Store No."; Code[20])
        { }

    }


    keys
    {
        key(PKey; "Item No.", "PO Line No.", "PO NO.")
        {
            Clustered = true;
        }
    }


}