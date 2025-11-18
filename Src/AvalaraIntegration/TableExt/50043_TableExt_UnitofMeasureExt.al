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
            trigger OnValidate()  //PT-FBTS 17-11-2025 
            var
                myInt: Integer;
            begin
                if "E UOM" <> '' then begin
                    if (StrLen("E UOM") < 3) or (StrLen("E UOM") > 8) then
                        Error('E UOM must be between 3 and 8 characters.');
                end;
            end;
        }
    }

    var
        myInt: Integer;
}