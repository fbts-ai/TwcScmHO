pageextension 50001 "Item Categories" extends "Item Category Card"
{
    layout
    {
        // Add changes to page layout here
        addafter("Parent Category")
        {
            field("Require Approval"; Rec."Require Approval")
            {
                ApplicationArea = all;
                Visible = false;
            }
            field("Indent Category"; rec."Indent Category")
            {
                ApplicationArea = all;
            }
        }
        addlast(General)
        {
            field(Comment; rec.Comment)
            {
                Caption = 'Comment For Purch Line';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }
    //ALLENick091023_start
    // trigger OnNewRecord(BelowxRec: Boolean)
    // var
    //     Usersetup: Record "User Setup";
    // begin
    //     if Usersetup.Get(UserId) then
    //         if Usersetup."Allow Master Modification" = false then begin
    //             CurrPage.Editable(false);
    //         end;
    // end;

    // trigger OnModifyRecord(): Boolean
    // var
    //     Usersetup: Record "User Setup";
    // begin
    //     if Usersetup.Get(UserId) then
    //         if Usersetup."Allow Master Modification" = false then begin
    //             CurrPage.Editable(false);
    //         end;

    // end;

    // trigger OnOpenPage()
    // var
    //     Usersetup: Record "User Setup";
    // begin
    //     if Usersetup.Get(UserId) then
    //         if Usersetup."Allow Master Modification" = false then begin
    //             CurrPage.Editable(false);
    //         end;
    // end;
    // //ALLENick091023_End


    var
        myInt: Integer;
}