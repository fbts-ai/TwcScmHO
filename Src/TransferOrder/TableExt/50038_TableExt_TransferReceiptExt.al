tableextension 50038 TransferReceiptExt extends "Transfer Receipt Line"
{
    fields
    {
        // Add changes to table fields here
        field(50100; Remarks; Text[100])
        {
            Caption = 'Remarks';
        }
        field(50101; FixedAssetNo; Code[20])
        {
            Caption = 'Fixed Asset No.';
        }
    }

    var
        myInt: Integer;
}