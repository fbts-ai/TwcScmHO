table 50148 CategoryGroupCode
{
    LookupPageId = CategoryGroupCode;
    DrillDownPageId = CategoryGroupCode;
    DataClassification = ToBeClassified;
    Caption = 'Category Group Code';
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
        field(3; GroupCode; Code[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'Group Code';
            TableRelation = SuperCategoryGroup;
        }
    }
    keys
    {
        key(Key1; code_)
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