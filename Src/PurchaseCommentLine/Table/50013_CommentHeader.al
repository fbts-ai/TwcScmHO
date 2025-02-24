table 50013 PurchCommentHeader
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; CommentCode; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Code';

        }
        field(2; Description; Text[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'Description';

        }
        field(3; Mandatory; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Mandatory';

        }

    }

    keys
    {
        key(Key1; CommentCode)
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