table 50041 LogLine
{
    DataClassification = ToBeClassified;

    fields
    {
        field(11; product_ID; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(1; product_description; Text[250])
        {
            DataClassification = ToBeClassified;

        }
        field(2; price_unit; Decimal)
        {
            DataClassification = ToBeClassified;

        }
        field(3; quantity; Decimal)
        {
            DataClassification = ToBeClassified;

        }
        field(4; "Tax name"; Text[20])
        {
            DataClassification = ToBeClassified;

        }
        field(5; "Tax Amount"; Decimal)
        {
            DataClassification = ToBeClassified;

        }
        field(6; "TAx Type"; Text[20])
        {
            DataClassification = ToBeClassified;

        }
        field(7; ID; Integer)
        {
            DataClassification = ToBeClassified;

        }
        field(8; bill_reference; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(9; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;

        }
        field(10; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;

        }
        field(12; "TDS_Name"; Text[100])
        {
            DataClassification = ToBeClassified;

        }
        field(13; "TDS_Description"; Text[250])
        {
            DataClassification = ToBeClassified;

        }
        field(14; "Price_Subtotal"; Decimal)
        {
            DataClassification = ToBeClassified;

        }
        field(15; "Price_Total"; Decimal)
        {
            DataClassification = ToBeClassified;

        }
        field(16; "internal_reference"; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(17; "product_hsn"; Code[10])
        {
            DataClassification = ToBeClassified;

        }
    }

    keys
    {
        key(Key1; "Entry No.", ID, bill_reference, "Line No.")
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