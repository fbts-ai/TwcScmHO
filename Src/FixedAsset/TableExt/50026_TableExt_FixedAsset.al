tableextension 50026 FixedAssetExt extends "Fixed Asset"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "PO Item"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50001; "Parent Fixed Asset"; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        //TodayFixedasset
        field(50002; "Used To"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}