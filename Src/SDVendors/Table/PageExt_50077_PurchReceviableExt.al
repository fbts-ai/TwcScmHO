pageextension 50077 PurchReceviableSetupExt extends "Purchases & Payables Setup"
{
    layout
    {
        addlast(General)
        {
            // Add changes to page layout here
            field(SDVendPostingGrp; Rec.SDVendPostingGrp)
            {
                ApplicationArea = All;
                Caption = 'SD Vendor Posting Group';

            }
        }

    }

    actions
    {
        // Add changes to page actions here
    }
    //AlleNick_Start
    // trigger OnOpenPage()
    // var
    //     usersetup: Record "User Setup";
    // begin
    //     if Usersetup."Allow Master Modification" = false then begin
    //         Error('You are not authorized to Access the page');
    //         CurrPage.Close();

    //     end;
    // end;
    //AlleNick_End

    var
        myInt: Integer;
}