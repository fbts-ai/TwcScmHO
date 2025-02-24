tableextension 50031 PurchInvoiceLineExtension extends "Purch. Inv. Line"
{
    fields
    {
        // Add changes to table fields here
        // Add changes to table fields here
        field(50110; Remarks; Text[100])
        {
            Caption = 'Remarks';
        }


    }

    var
        myInt: Integer;
}