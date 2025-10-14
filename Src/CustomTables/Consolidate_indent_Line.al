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
            // TableRelation = Item;
            // ValidateTableRelation = true;
            TableRelation = if (Type = const(" ")) "Standard Text"
            else
            if (Type = const("G/L Account")) "G/L Account" where("Direct Posting" = const(true), "Account Type" = const(Posting), Blocked = const(false))
            else
            if (Type = const("G/L Account")) "G/L Account" where(Blocked = filter(false), "Direct Posting" = filter(true))
            else
            if (Type = const("Fixed Assets")) "Fixed Asset"
            else
            if (Type = const(Item)) Item where(Blocked = const(false), Type = const(Inventory),
            "Base Unit of Measure" = filter(<> ''), "HSN/SAC Code" = filter(<> ''), "GST Credit" = filter('Availment' | 'Non-Availment'));
            ValidateTableRelation = true;
            trigger OnValidate()
            var
                myInt: Integer;
            begin

            End;
        }
        field(3; "Item Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                myInt: Integer;
            begin

                if Rec.Quantity < 0 then
                    Error('You Can Not Select Negative Quantity');
            end;
        }
        field(5; "UOM"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Store"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Location where("Use As In-Transit" = const(false));
            //Aashish 22-09-2024
            ValidateTableRelation = true;
            trigger OnValidate()
            var
                myInt: Integer;
                DimensionValue: Record "Dimension Value";
            begin
                if Rec."Source Location No." = Store then
                    Error('You Cannot Select Same location');
                DimensionValue.Reset();
                DimensionValue.SetRange(Code, Rec.Store);
                DimensionValue.SetFilter(Blocked, '%1', true);
                if DimensionValue.FindFirst() then
                    Error('Location is Blocked Plase Connect withn Admin');
            end;
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
            OptionMembers = " ","Item","G/L Account","Fixed Assets";
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                if xRec.Type <> Type then begin
                    Clear("Item No");
                    Clear("Item Name");
                    Clear("UOM");
                    Clear("vendor Code");
                end;
            end;
        }
        //T64-NS
        field(10; "Sourcing Method"; Option)
        {
            // OptionCaption = '', "Transfer", "Purchase", "Production";
            OptionMembers = " ","Transfer","Purchase","Production";
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                if Rec.Type <> Rec.Type::Item then begin
                    if Rec."Sourcing Method" = Rec."Sourcing Method"::Transfer then
                        Error('Transfer sourcing method is only allowed for Item type lines.');

                end;
            end;
        }
        field(11; "Source Location No."; Code[20])
        {
            TableRelation = if ("Sourcing Method" = filter(Purchase)) Vendor where("Privacy Blocked" = const(false)) else
            Location where("Use As In-Transit" = const(false));
            ValidateTableRelation = true;
            trigger OnValidate()
            var
                myInt: Integer;
                DimensionValue: Record "Dimension Value";
            begin
                if Rec."Source Location No." = Store then
                    Error('You Cannot Select Same location');
                DimensionValue.Reset();
                DimensionValue.SetRange(Code, Rec."Source Location No.");
                DimensionValue.SetRange(Blocked, true);
                if DimensionValue.FindFirst() then
                    Error('Location is Blocked Plase Connect withn Admin');
            end;
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
        GLAcc: Record "G/L Account";

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

    local procedure CopyFromStandardText()
    var
        StandardText: Record "Standard Text";
    begin
        // "Tax Area Code" := '';
        // "Tax Liable" := false;
        StandardText.Get("Item No");
        "Item Name" := StandardText.Description;
        // "Allow Item Charge Assignment" := false;
        // OnAfterAssignStdTxtValues(Rec, StandardText);
    end;


}