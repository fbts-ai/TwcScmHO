tableextension 50136 RetailICTHeaderExt extends "LSC Retail ICT Header"
{
    fields
    {
        field(50000; "HO ICT Entry"; Boolean)
        { }
        field(50001; "TransferCreated"; Boolean)
        { }
        field(50002; "Skip From Replication"; Boolean)
        { }
    }

    keys
    {
        key(SK1; "Source TableNo")
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