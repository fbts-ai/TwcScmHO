table 50147 SuperCategoryGroup //PT-FBTS
{
    DrillDownPageId = SuperCategoryGroup;
    LookupPageId = SuperCategoryGroup;
    Caption = 'SuperCategoryGroup';

    fields
    {
        field(1; code_; Code[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'Code';
        }
        field(2; Description; text[250])
        {
            DataClassification = ToBeClassified;
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; code_, Description)
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