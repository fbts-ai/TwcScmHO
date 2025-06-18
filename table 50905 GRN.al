table 50905 "GRN"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "GRN No."; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "GRN Date"; date)
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Doc No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Purchase Order No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Location Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Vendor No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Vendor Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Type"; Text[20])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Description"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Invoiced Qty"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(14; "Qty. Rcd. Not Invoiced"; Decimal)
        {
            DataClassification = ToBeClassified;
        }


        field(15; "GRN Rate"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(16; "Vendor Invoice No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Vendor Invoice Date"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(18; "PI Qty."; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(19; "PI Rate"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Doc Date"; Date)
        {
            DataClassification = ToBeClassified;
        }

        field(21; "GRN Amout Without GST"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Create Invoice"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(23; "DC Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(24; "Invoice No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(25; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}