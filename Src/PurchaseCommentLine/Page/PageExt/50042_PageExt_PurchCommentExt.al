pageextension 50042 PurchCommentLineExt extends "Purch. Comment Sheet"
{
    layout
    {
        // Add changes to page layout here
        addafter(Comment)
        {
            field(PurchCommentLine; Rec.PurchCommentLine)
            {
                caption = 'Purch Comment Line';
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