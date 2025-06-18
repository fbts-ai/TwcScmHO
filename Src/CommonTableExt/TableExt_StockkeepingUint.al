tableextension 50058 StockkeepingUnitExt extends "Stockkeeping Unit"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Base Unit of Measure"; Code[20])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Item."Base Unit of Measure" where("No." = field("Item No.")));
        }
        field(50002; "Location Name"; Code[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Location.Name where(Code = field("Location Code")));
        }
        field(50003; "InventoryCounting"; Boolean)//PT-FBTS 130325
        {
            DataClassification = ToBeClassified;
        }
        field(50004; "WastageItem"; Boolean)
        {
            DataClassification = ToBeClassified;

        }
        //PT-FBTS 130325
    }

    keys
    {
        // Add changes to keys here
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;
}