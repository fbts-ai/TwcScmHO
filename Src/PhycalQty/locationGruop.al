table 50031 "Location Group"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Location Group";
    DrillDownPageId = "Location Group";

    fields
    {
        field(1; Code; code[50])
        {
            DataClassification = ToBeClassified;

        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
        }
    }

    keys
    {
        key(Key1; Code)
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