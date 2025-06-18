pageextension 50055 PostedSalesInvoiceListExt extends "Posted Sales invoices"
{
    layout
    {
        // Add changes to page layout here
        addafter("Bill-to Customer No.")
        {
            field("IRN Hash"; Rec."IRN Hash")
            {
                ApplicationArea = all;
            }
            field("E-Way Bill No."; Rec."E-Way Bill No.")
            {
                ApplicationArea = all;
            }
            field("QR Code"; Rec."QR Code")
            {

            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }
    var
        myInt: Integer;
}