table 50002 "Item For Indent"
{
    DataClassification = ToBeClassified;
    //TableType = Temporary;

    fields
    {
        field(1; "Item No."; code[30])
        {
            DataClassification = ToBeClassified;
            Caption = 'No.';

        }
        field(2; "Description"; text[100])
        {

        }
        field(3; "Unit of Measure"; code[30])
        {

        }
        field(4; "Stock In Hand"; Decimal)
        {

        }
        field(6; "In-Transit"; Decimal)
        {

        }
        field(7; "Indent Qty"; Integer)
        {

        }
        field(11; "Item UOM"; Code[20])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Item."Base Unit of Measure" where("No." = field("Item No.")));

        }
        field(12; "Item UOM Qty.of measure"; Decimal)
        {
            FieldClass = FlowField;
            DecimalPlaces = 0 : 5;
            CalcFormula = lookup("Item Unit of Measure"."Qty. per Unit of Measure" where("Item No." = field("Item No."), Code = field("Indent Unit of Measure")));
        }
        field(100; "Indent No."; Code[30])
        {

        }
        field(101; "Item Category"; code[30])
        {

        }
        field(50106; "Type"; Option)
        {
            OptionMembers = " ",Item,"Fixed Asset";
        }
        field(50107; "Remarks"; Text[100])
        {

        }

        field(50108; "Indent Unit of Measure"; Code[20])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Item."Indent Unit of Measure" where("No." = field("Item No.")));
        }
        field(50110; "Location Code"; Code[20])//PT-FBTS
        {
        }
    }

    keys
    {
        key(Key1; "Item No.")
        {
            Clustered = true;
        }
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