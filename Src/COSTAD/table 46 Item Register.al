tableextension 51107 "Item Register" extends "Item Register"
{
    fields
    {
        field(50000; "Cost Adjustment Run Guid"; Guid)
        {
            Caption = 'Cost Adjustment Run Guid';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key4; "Cost Adjustment Run Guid")
        {
        }
    }
}