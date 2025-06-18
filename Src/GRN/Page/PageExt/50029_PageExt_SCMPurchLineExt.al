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
        addafter("Document No.") //PT-FBTS 090425
        {
            field("Document Date"; Rec."Document Date")
            {
                ApplicationArea = all;
            }
            field(CreatedDateTime; Rec.SystemCreatedAt)
            {
                ApplicationArea = all;
            }
            //PT-FBTS 090425
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}