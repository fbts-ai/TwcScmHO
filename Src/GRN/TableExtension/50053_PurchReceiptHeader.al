tableextension 50053 PurchReceiptHeader extends "Purch. Rcpt. Header"
{
    fields
    {
        // Add changes to table fields here
        field(50003; "Indent No."; Code[25])
        {

        }
        field(50105; ProformaInvoice; Code[20])
        {
            Caption = 'Proforma Invoice Number';

        }
        field(50106; FreightCost; Boolean)
        {
            Caption = 'Freight Cost';
        }
        field(50107; VendorInvoiceDate; Date)
        {
            Caption = 'Vendor Invoice Date';
        }
        field(50108; VendorInvoiceNo; Code[35])
        {
            Caption = 'Vendor Invoice No';
        }
        field(50109; "Creation Location"; code[20])
        {
            Caption = 'Creation Location';

        }
    }

    var
        myInt: Integer;
}