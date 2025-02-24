table 50036 "CommentLine"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Sr No."; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;

        }
        field(2; Comments; Text[1000])
        {
            DataClassification = ToBeClassified;

        }
    }

    keys
    {
        key(Key1; "Sr No.")
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