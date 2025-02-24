table 50009 WastageEntryLotNo
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; WastageEntryNo; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'LotNo';

        }
        field(2; ItemNo; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'ItemNo';

        }
        field(3; LineNo; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'LineNo';

        }
        field(4; LotNo; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'LotNo';

        }
        field(5; Quantity; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Quantity';

        }
        field(6; LocationCode; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'LocationCode';

        }

    }

    keys
    {
        key(Key1; WastageEntryNo, ItemNo, LineNo, LotNo)
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