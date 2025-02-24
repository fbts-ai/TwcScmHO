tableextension 50044 GSTTableAvalaraExt extends "GST Setup"
{
    fields
    {
        // Add changes to table fields here
        field(50000; AvalaraEinvoiceApi; Text[500])
        {
            Caption = 'Avalara E-Invoice API';
        }
        field(50001; EinvoiceSecurityToken; Text[200])
        {
            Caption = 'Avalara E-Invoice Security Token';
        }
        field(50002; IRNtoEwayBillApi; Text[500])
        {
            Caption = 'Avalara IRN to Eway API';
        }
        field(50003; IRNtoEwayBillSecurityToken; Text[200])
        {
            Caption = 'IRN to Eway Bill Secuirty Token';
        }
        field(50004; EwayBillApi; Text[500])
        {
            Caption = 'Eway Bill API';
        }
        field(50005; EwayBillSecurityToken; Text[200])
        {
            Caption = 'Eway Bill Security token';
        }

    }

    var
        myInt: Integer;
}