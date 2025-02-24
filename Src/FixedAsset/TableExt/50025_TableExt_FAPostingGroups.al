tableextension 50025 FAPostingGroupsExt extends "FA Posting Group"
{
    fields
    {
        // Add changes to table fields here
        field(50100; CWIP; Boolean)
        {
            Caption = 'CWIP';
        }
    }

    var
        myInt: Integer;
}