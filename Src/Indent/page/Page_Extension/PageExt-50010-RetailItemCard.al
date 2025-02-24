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