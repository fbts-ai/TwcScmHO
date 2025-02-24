tableextension 50043 UnitofMeasureExt extends "Unit of Measure"
{
    fields
    {
        // Add changes to table fields here
        field(50001; UCQ; Code[10])
        {

        }
        field(50000; "E UOM"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}