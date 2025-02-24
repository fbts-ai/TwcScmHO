tableextension 50006 "ItemCategory" extends "Item Category"
{
    fields
    {
        field(50000; "Require Approval"; Boolean)
        {

        }
        field(50001; "Indent Category"; Boolean)
        {

        }
        //SCM
        field(50100; Comment; Text[80])
        {
            Caption = 'Comment';
        }
    }

}