tableextension 50060 BomComponentTabExt extends "BOM Component"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Actual Qty."; Decimal)
        {
            DecimalPlaces = 3;
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                "Quantity per" := ("Actual Qty." * "LSC Wastage %") / 100 + "Actual Qty.";
                rec.Modify();
                // if "Actual Qty." = 0 then
                //     "Quantity per" := 0;
            end;
        }
        modify("LSC Wastage %")
        {
            trigger OnAfterValidate()
            var
                myInt: Integer;
            begin
                "Quantity per" := ("Actual Qty." * "LSC Wastage %") / 100 + "Actual Qty.";//PT-FBTS 
                Rec.Modify();
            end;
        }
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