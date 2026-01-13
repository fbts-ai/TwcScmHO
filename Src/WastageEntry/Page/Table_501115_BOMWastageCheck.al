table 50187 "Bom Wastage Check"
{
    DataClassification = ToBeClassified;
    // TableType = Temporary;

    fields
    {
        field(1; "LineNo."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "item Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; Description; text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(4; Date; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(5; UOM; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Sale qty."; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(8; stock; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Adj. Required"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(10; "From Data"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(12; Reason; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Parent Item No."; code[20])
        {
            trigger OnValidate()
            var
                ItemRec: Record Item;
            begin
                // if ItemRec.Get(Rec."Parent Item No.") then
                //     Rec.Validate("Parent Item Descrption", ItemRec.Description);
            end;
        }
    }

    keys
    {
        key(Key1; "Document No.", "LineNo.", "item Code")
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