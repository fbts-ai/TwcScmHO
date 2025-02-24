pageextension 50174 AssemblyOrder extends "Assembly Order"
{
    layout
    {
        // Add changes to page layout here
        addafter("Assigned User ID")
        {
            field("Assembly Production"; "Assembly Production")
            {
                ApplicationArea = all;
            }
        }
        modify("Location Code")
        {
            Editable = EditBool;
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
    trigger OnInsertRecord(dd: Boolean): Boolean //PT-FBTS 190225
    var
        myInt: Integer;
    begin
        Rec."Assembly Production" := true;
        // Rec.Modify();
    end;

    trigger OnAfterGetRecord()
    var
        UserSetup: Record "User Setup";

    begin
        if UserSetup.Get(UserId) then begin
            if UserSetup."Assembly Production" = false then begin
                EditBool := false
            end else
                if UserSetup."Assembly Production" = true then
                    EditBool := true
        end;
    end;

    trigger OnAfterGetCurrRecord()
    var
        UserSetup: Record "User Setup";

    begin
        if UserSetup.Get(UserId) then begin
            if UserSetup."Assembly Production" = false then begin
                EditBool := false
            end else
                if UserSetup."Assembly Production" = true then
                    EditBool := true
        end;
    end;

    var
        EditBool: Boolean;
    // myInt: Integer;
}