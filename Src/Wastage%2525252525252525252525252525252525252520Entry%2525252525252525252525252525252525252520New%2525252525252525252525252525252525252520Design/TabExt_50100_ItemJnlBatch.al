tableextension 50100 ItemJnlBatch extends "Item Journal Batch"
{
    fields
    {
        // Add changes to table fields here
        field(50100; "Location Code"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = Location;
        }
    }

    var
        myInt: Record 10000742;
}