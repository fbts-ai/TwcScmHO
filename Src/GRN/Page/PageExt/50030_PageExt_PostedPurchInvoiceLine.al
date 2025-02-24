pageextension 50030 PostedPurchInvoiceLineExt extends "Posted Purch. Invoice Subform"
{
    layout
    {
        // Add changes to page layout here
        addafter("Line Amount")
        {
            field(Remarks; Rec.Remarks)
            {
                Caption = 'Remarks';
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