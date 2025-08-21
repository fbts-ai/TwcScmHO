pageextension 50082 ItemExt extends "Item List"
{
    //ALLENick091023_Start
    layout
    {
        addafter(InventoryField) //PT-Fbts 16-08-24
        {
            // field("Qty. on Purch. Order"; "Qty. on Purch. Order")
            // {
            //     ApplicationArea = all;
            //     Caption = 'Open PO Qty.';
            // }
            field("Open PO Qty."; "Open PO Qty.")
            { ApplicationArea = all; }//PT-FBTS-11082025
        }
    }
    // trigger OnOpenPage()
    // var
    //     Usersetup: Record "User Setup";
    // begin
    //     if Usersetup.Get(UserId) then
    //         if Usersetup."Allow Master Modification" = false then begin
    //             Error('You are not authorized to Access the page');
    //             CurrPage.Close();

    //         end;
    // end;

    // trigger OnNewRecord(BelowxRec: Boolean)
    // var
    //     Usersetup: Record "User Setup";
    // begin
    //     if Usersetup.Get(UserId) then
    //         if Usersetup."Allow Master Modification" = false then begin
    //             Error('You do not have permission to modify');
    //         end;
    // end;

    // trigger OnModifyRecord(): Boolean
    // var
    //     Usersetup: Record "User Setup";
    // begin
    //     if Usersetup.Get(UserId) then
    //         if Usersetup."Allow Master Modification" = false then begin
    //             Error('You do not have permission to modify');
    //         end;
    // end;
    //ALLENick091023_End
}