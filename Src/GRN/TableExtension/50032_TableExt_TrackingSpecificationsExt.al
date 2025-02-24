tableextension 50032 TrackingSpecificationExt extends "Tracking Specification"
{
    fields
    {
        field(50001; BrandName; Text[20])
        {
            Caption = 'Brand Name';
        }
        field(50105; ManufacturingDate; Date)
        {
            Caption = 'Manufacturing Date';
        }
    }

    var
        myInt: Integer;
}