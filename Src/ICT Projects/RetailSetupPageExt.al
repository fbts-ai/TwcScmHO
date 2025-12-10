pageextension 50221 RetailPageExt_ICT extends "LSC Retail Setup"
{
    layout
    {
        addafter(Discounts)
        {
            group("ÏCT Setup")
            {
                field("Max Pending ICT"; "Max Pending ICT")
                {
                    ToolTip = 'Total Pending record of ICT for further Replication';
                }
                field("Pending ICT Replication_W"; "Pending ICT Replication_W")
                {
                    ToolTip = 'Total Pending record of ICT from Warhouse DB: Need to replicate';
                }
                field("Pending ICT Replication_F"; "Pending ICT Replication_F")
                {
                    ToolTip = 'Total Pending record of ICT from Finance DB need to replicate';
                }
                field("Pending ICT Process"; "Pending ICT Process")
                {
                    ToolTip = 'Total Pending record of ICT in Statment DB Need to process';
                }
            }
        }
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}