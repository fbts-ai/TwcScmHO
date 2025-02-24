pageextension 50073 LSCPostedStatementext extends "LSC Posted Statement Lines"
{
    layout
    {
        // Add changes to page layout here
        addafter("Trans. Amount")
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