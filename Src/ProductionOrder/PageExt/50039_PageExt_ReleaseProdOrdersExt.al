pageextension 50039 ReleaseProdOrdersExt extends "Released Production Orders"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
    }
    trigger OnOpenPage()
    var
        usersetup: Record "User Setup";

    begin
        usersetup.Get(UserId);
        Rec.FilterGroup(2);
        Rec.SetFilter("Location Code", '=%1', usersetup."Location Code");
        Rec.SetRange(Shortclose, false);//PT-FBTS-10-10-25
        Rec.FilterGroup(0);
    end;

    var
        myInt: Integer;
}