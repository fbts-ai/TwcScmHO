table 50014 PurchCommentLine
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; CommentCode; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; LineNo; Integer)
        {
            DataClassification = ToBeClassified;

        }
        field(3; SrNo; Text[10])
        {
            DataClassification = ToBeClassified;

        }
        field(4; Comment; Text[1048])
        {
            DataClassification = ToBeClassified;

        }
    }

    keys
    {
        key(Key1; CommentCode, LineNo)
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