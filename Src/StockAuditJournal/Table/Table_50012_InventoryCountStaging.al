table 50012 InventoryCountingStaging
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; ItemNo; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Item No.';
            TableRelation = Item."No.";
        }
        field(2; Region; Enum Region_InventoryCount)
        {
            DataClassification = ToBeClassified;
            Caption = 'Region';
        }
        field(3; UnitCost; Decimal)
        {
            Caption = 'UnitCost';
        }
    }

    keys
    {
        key(Key1; ItemNo, Region)
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