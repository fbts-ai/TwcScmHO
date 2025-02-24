pageextension 50104 ItemJnlBatch extends "Item Journal Batches"
{
    layout
    {
        // Add changes to page layout here
        addafter(Description)
        {
            field("Location Code"; Rec."Location Code")
            {
                ApplicationArea = all;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    trigger OnOpenPage()
    var
        LscRetUser: Record "LSC Retail User";
        oldFilter: Integer;
    begin
        if LscRetUser.Get(UserId) then begin
            oldFilter := Rec.FilterGroup();
            Rec.FilterGroup(2);
            Rec.SetFilter("Location Code", '=%1', LscRetUser."Location Code");
            Rec.FilterGroup(oldFilter);
        end;
    end;

    var
        myInt: Integer;
}