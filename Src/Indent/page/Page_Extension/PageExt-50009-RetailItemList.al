pageextension 50009 RetailItemExtn extends "LSC Retail Item List"
{

    layout
    {
        addafter(Description)
        {
            field("LSC Recipe Item Type"; rec."LSC Recipe Item Type")
            {
                ApplicationArea = all;
            }
        }
    }
    trigger OnOpenPage()
    begin
        // rec.SetFilter("LSC Created by User", '%1', '@*Dyn*');
        //  rec.SetFilter("LSC Last Modified by User", '%1', '@*Dyn*');
        rec.SetRange(Blocked, false);
    end;

    var
        myInt: Integer;
}