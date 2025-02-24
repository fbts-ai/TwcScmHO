pageextension 50095 Gst extends "GST Group"
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
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}