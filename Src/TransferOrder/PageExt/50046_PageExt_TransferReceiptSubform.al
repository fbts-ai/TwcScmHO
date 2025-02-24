pageextension 50046 TransferReceiptLineExt extends "Posted Transfer Rcpt. Subform"
{
    layout
    {
        // Add changes to page layout here
        addafter(Amount)
        {
            field(Remarks; Rec.Remarks)
            {
                Caption = 'Remarks';
            }
            field(FixedAssetNo; Rec.FixedAssetNo)
            {
                Caption = 'FixedAssetNo';
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