table 50144 "Item Packing Details"
{
    DataClassification = ToBeClassified;
    fields
    {
        field(1; "Parent Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Item;
        }
        field(2; "Child Item No."; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = Item;
        }
        field(3; "Unit of Measure"; Code[20])
        {

        }
        field(4; "Sales Type"; Code[20])
        {

        }
        field(5; "Quantity per"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Sales Type", "Parent Item No.")
        {
            Clustered = true;
        }
        key(Key2; "Child Item No.")
        {

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