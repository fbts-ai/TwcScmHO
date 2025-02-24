pageextension 50068 AssenblyBomExt extends "Assembly BOM"
{
    layout
    {
        // Add changes to page layout here
        addbefore("Quantity per")
        {
            field("Actual Qty."; Rec."Actual Qty.")
            {
                ApplicationArea = ALL;
                DecimalPlaces = 3;
            }
        }
        addafter("Actual Qty.")
        {
            field("LSC Wastage %"; Rec."LSC Wastage %")
            {
                ApplicationArea = all;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
        dfd: report 795;

        fd: codeunit 5895;
}