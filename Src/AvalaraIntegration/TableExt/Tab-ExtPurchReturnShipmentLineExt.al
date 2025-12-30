tableextension 50062 ReturnShipmentLine extends "Return Shipment Line"
{
    fields
    {
        // Add changes to table fields here
        field(50011; "Order Line No"; Integer) //PT-FBTS 02-09-2-2025
        {
            DataClassification = ToBeClassified;
        }
        field(50010; "Order No"; Code[20]) //PT-FBTS 02-09-2-2025
        {
            DataClassification = ToBeClassified;
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