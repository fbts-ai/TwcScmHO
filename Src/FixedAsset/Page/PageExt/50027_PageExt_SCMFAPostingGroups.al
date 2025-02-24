pageextension 50027 SCMFAPostingGroups extends "FA Posting Groups"
{
    layout
    {
        // Add changes to page layout here
        addlast(Control1)
        {
            field(CWIP; Rec.CWIP)
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