pageextension 50033 TrackingSpecficationExt extends "Item Tracking Lines"
{
    layout
    {
        modify("Expiration Date")
        {
            Editable = True;
        }
        addafter("Lot No.")
        {

            field(BrandName; Rec.BrandName)
            {
                Caption = 'Brand Name';
            }
            field(ManufacturingDate; rec.ManufacturingDate)
            {
                Caption = 'ManufacturingDate';
            }

        }
        modify("New Expiration Date") //PT-FBTS
        {
            Visible = true;
            Editable = true;
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}