table 51116 DPTransfer
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; DocNo; Code[20])
        {
            DataClassification = CustomerContent;

        }
    }

    keys
    {
        key(Key1; DocNo)
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