pageextension 50029 SCMPurchLineExt extends "Purchase Lines"
{
    layout
    {
        // Add changes to page layout here
        addafter("Line Amount")
        {
            field(Remarks; Rec.Remarks)
            {
                caption = 'Remarks';
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