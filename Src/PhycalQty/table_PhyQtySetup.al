table 50032 "Physical Qty. Setup"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Physical Qty. Setup";
    DrillDownPageId = "Physical Qty. Setup";

    fields
    {
        field(1; "Location Group"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Location Group";
        }
        field(2; "DAILY"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "WEEKLY"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(4; "MONTHLY"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "QUARTERLY"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(5; Formula; Text[1000])
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Location Group", DAILY, WEEKLY, MONTHLY)
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