tableextension 50035 PurchCommentLineExt extends "Purch. Comment Line"
{
    fields
    {
        // Add changes to table fields here
        field(50000; PurchCommentLine; Text[1048])
        {
            Caption = 'Purchase Comment Line';
        }
    }

    var
        myInt: Integer;
}