tableextension 50131 detailedgstext extends "Detailed GST Ledger Entry"
{
    fields
    {
        field(50102; "Create ICT"; Boolean)
        { }
        // Add changes to table fields here
    }

    keys
    {
        key(SK2; "Document No.")
        { }

        // Add changes to keys here
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;
}