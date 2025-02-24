pageextension 50047 PostedReceiptsubformext extends "Get Post.Doc - P.RcptLn Sbfrm"
{
    layout
    {
        // Add changes to page layout here
        addafter("Expected Receipt Date")
        {
            field("Posting Date"; Rec."Posting Date")
            {
                Caption = 'Posting Date';
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