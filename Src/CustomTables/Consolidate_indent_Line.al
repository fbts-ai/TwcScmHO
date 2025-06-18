table 50151 "Consolidate indent Line"
{
    DataClassification = ToBeClassified;
    fields
    {
        field(1; " Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Item No"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Item;
            ValidateTableRelation = true;
        }
        field(3; "Item Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "UOM"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Store"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "vendor Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Type"; Option)
        {
            OptionMembers = "","Item","G/L Account","Fixed Assets";
        }
        //T64-NS
        field(10; "Sourcing Method"; Option)
        {
            // OptionCaption = '', "Transfer", "Purchase", "Production";
            OptionMembers = " ","Transfer","Purchase","Production";
        }
        field(11; "Source Location No."; Code[20])
        {
            TableRelation = if ("Sourcing Method" = filter(Purchase)) Vendor else
            Location;
        }
        field(12; "Referance No."; Code[20])
        {

        }

        //T64-NE
    }
    keys
    {
        key(Key1; " Document No.", "Line No.")
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
    var
        ExistingLine: Record "Consolidate indent Line";
    begin
        if ("Sourcing Method" in ["Sourcing Method"::Transfer, "Sourcing Method"::Purchase]) then begin
            ExistingLine.SetRange(" Document No.", " Document No.");
            ExistingLine.SetRange("Item No", "Item No");
            ExistingLine.SetRange(Store, Store);
            ExistingLine.SetRange("Sourcing Method", "Sourcing Method");
            if ExistingLine.FindFirst() then
                Error('You cannot add the same Item for the same Store more than once when Sourcing Method is %1.', Format("Sourcing Method"));
        end;
    end;

    trigger OnModify()
    var
        ExistingLine: Record "Consolidate indent Line";
    begin
        if ("Sourcing Method" in ["Sourcing Method"::Transfer, "Sourcing Method"::Purchase]) then begin
            ExistingLine.SetRange(" Document No.", " Document No.");
            ExistingLine.SetRange("Item No", "Item No");
            ExistingLine.SetRange(Store, Store);
            ExistingLine.SetRange("Sourcing Method", "Sourcing Method");
            ExistingLine.SetFilter("Line No.", '<>%1', "Line No.");
            if ExistingLine.FindFirst() then
                Error('You cannot add the same Item for the same Store more than once when Sourcing Method is %1.', Format("Sourcing Method"));
        end;
    end;



    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}