pageextension 50053 PostedSalesCreditMemoExt extends "Posted Sales Credit Memos"
{
    layout
    {
        // Add changes to page layout here
        addafter("Bill-to Customer No.")
        {
            field("IRN Hash"; Rec."IRN Hash")
            {

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