pageextension 50043 "LscPostedStatementList" extends "LSC Posted Statement List"
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
        TempUserSetup: Record "User Setup";
    begin
        //mahendra
        IF TempUserSetup.Get(UserId) Then;
        IF TempUserSetup."Location Code" <> '' then Begin
            Rec.FilterGroup(2);
            Rec.setfilter(Rec."Store No.", '=%1', TempUserSetup."Location Code");
            Rec.FilterGroup(0);
        End;
        //end
    end;

    var
        myInt: Integer;
}