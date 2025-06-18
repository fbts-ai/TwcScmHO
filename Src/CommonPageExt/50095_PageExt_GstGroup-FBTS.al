pageextension 50095 GstExt extends "GST Group"
{
    layout
    {
        // Add changes to page layout here
        addafter(Description)
        {
            field("GST Rate"; "GST Rate")
            {
                ApplicationArea = all;
            }
            // field(ForkLyft_GSt; Rec.ForkLyft_GSt)
            // {
            //     ApplicationArea = All;
            // }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}