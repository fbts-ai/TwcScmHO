table 50142 "Custom BOM Line"
{

    DataClassification = ToBeClassified;
    fields
    {

        field(1; "Child ItemNo."; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = Item;
        }

        field(2; "Unit of Measure"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Item Unit of Measure".code where("Item No." = field("Child ItemNo."));
            ValidateTableRelation = true;

        }
        field(3; "Quantity per"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(4; "BOM Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;

        }
        field(6; "Actual Qty."; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 3;
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                "Quantity per" := ("Actual Qty." * "Wastage %") / 100 + "Actual Qty.";
                rec.Modify();
                // if "Actual Qty." = 0 then
                //     "Quantity per" := 0;

            end;

        }
        field(7; "Wastage %"; Decimal)
        {
            Caption = 'Wastage %';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                RetailBOMComponents: Codeunit "LSC Retail BOM Components";
                IsHandled: Boolean;
            begin
                "Quantity per" := ("Actual Qty." * "Wastage %") / 100 + "Actual Qty.";//PT-FBTS 
                Rec.Modify();
            end;
        }
        field(8; "Child Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            //  TableRelation = Item.Description where("No." = field("Child ItemNo."));
        }

    }
    keys
    {
        key(Key1; "BOM Code", "Line No.")
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