pageextension 50037 ProductionOrderListExt extends "Production Order List"
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
        IF usersetup.Get(UserId) then;
        IF usersetup."Location Code" <> '' then Begin
            Rec.FilterGroup(2);
            Rec.SetFilter("Location Code", '=%1', usersetup."Location Code");
            Rec.FilterGroup(0);
        End;

    end;

    var
        myInt: Integer;
}