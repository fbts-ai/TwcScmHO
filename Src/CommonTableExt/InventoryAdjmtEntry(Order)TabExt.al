tableextension 50120 InvAdjustOrder extends "Inventory Adjmt. Entry (Order)"
{
    fields//FBTS AA
    {
        field(50000; "Cost adjusted Manual"; Boolean)
        { }
        field(50001; "Allow online Adjust Manual"; Boolean)
        { }
        field(50002; "Manual Closed-Open"; Boolean)
        { }
        // Add changes to table fields here
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


// tableextension 3 Item extends "Item"
// {
//     fields
//     {


//     }

//     keys
//     {
//         // Add changes to keys here
//     }

//     fieldgroups
//     {
//         // Add changes to field groups here
//     }

//     var
//         myInt: Integer;
// }