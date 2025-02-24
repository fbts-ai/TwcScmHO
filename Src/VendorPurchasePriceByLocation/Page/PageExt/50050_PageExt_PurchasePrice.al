pageextension 50050 PurchasePriceExt extends "Purchase Prices"
{
    layout
    {
        // Add changes to page layout here
        addafter("Vendor No.")
        {
            field(LocationCode; Rec.LocationCode)
            {
                Caption = 'Location Code';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
    // myInt: Record 10044515;

    //codeunit 10044515 "LSCIN Statement GST Post"
}