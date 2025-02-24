tableextension 50041 PurchasePriceExt extends "Purchase Price"
{
    fields
    {
        // Add changes to table fields here
        field(50001; LocationCode; Code[20])
        {
            caption = 'Location Code';
            TableRelation = Location;
        }
    }

    var
        myInt: Integer;
}