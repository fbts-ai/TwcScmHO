tableextension 50138 RetailSetupExt_ICT extends "LSC Retail Setup"
{
    fields
    {
        field(70000; "Max Pending ICT"; Integer)
        {
            //'Total Pending record of ICT for further Replication';
        }
        field(70001; "Pending ICT Replication_W"; Integer)
        {
            Editable = false;
            //'Total Pending record of ICT from Warhouse DB need to replcaite';
        }
        field(70002; "Pending ICT Replication_F"; Integer)
        {
            Editable = false;
            //'Total Pending record of ICT from Finance DB need to replcaite';
        }
        field(70003; "Pending ICT Process"; Integer)
        {
            Editable = false;
            //'Total Pending record of ICT in Statment DB Need to process';
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