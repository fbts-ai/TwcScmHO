pageextension 50010 LSCRetailItemCard extends "LSC Retail Item Card"
{
    layout
    {
        addafter(Blocked)
        {
            field("LSC Recipe Category"; rec."LSC Recipe Category")
            {
                ApplicationArea = all;
            }
            field("LSC Recipe Item Type"; rec."LSC Recipe Item Type")
            {
                ApplicationArea = all;
            }
        }
        addafter("Explode BOM in Statem. Posting") //PT-FBTS
        {
            field("Auto Assembly"; Rec."Auto Assembly")
            {
                ApplicationArea = all;
            }
        }
        addafter(Description)
        {
            field("BI Super Category"; Rec."BI Super Category") //PT-FBTS 11/06/2025
            {
                ApplicationArea = all;
            }
            field("BI Category Code"; Rec."BI Category Code")//PT-FBTS 11/06/2025
            {
                ApplicationArea = all;
            }
            field("Send to AP"; Rec."Send to AP")
            {
                ApplicationArea = all;
            }
        }
        modify(Pricing)
        {
            Visible = true;
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}