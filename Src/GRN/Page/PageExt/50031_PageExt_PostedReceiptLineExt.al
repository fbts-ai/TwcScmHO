pageextension 50031 PostedReceiptLineExt extends "Posted Purchase Rcpt. Subform"
{
    layout
    {
        // Add changes to page layout here
        addafter("Order Date")
        {
            field(Remarks; Rec.Remarks)
            {
                Caption = 'Remarks';
            }
        }
        addafter("Unit of Measure Code")
        {
            field("Direct Unit Cost"; Rec."Direct Unit Cost")
            {
                Caption = 'Direct Unit Cost';
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