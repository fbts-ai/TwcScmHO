pageextension 50028 SCMFixedAssetCard extends "Fixed Asset Card"
{
    layout
    {
        // Add changes to page layout here
        addlast(General)
        {
            field("PO Item"; Rec."PO Item")
            {
                ApplicationArea = All;
            }
            field("Parent Fixed Asset"; Rec."Parent Fixed Asset")
            {
                Editable = true;
                ApplicationArea = All;
                //ALLE_NICK_120124
                //TodayFixedasset
                // trigger OnLookup(var Text: Text): Boolean//PT-FBTS oldCode Comment  17-11-25
                // var
                //     FixedAsset1: Page "Fixed Asset List_";
                //     FixedAsset: Record "Fixed Asset";

                // begin
                //     FixedAsset.SetFilter("PO Item", '%1', true);
                //     IF Page.RUNMODAL(50112, FixedAsset) = ACTION::LookupOK THEN begin
                //         Rec.Validate(Rec."Parent Fixed Asset", FixedAsset."No.");
                //     end;
                // end;
            }
            field("Location Code"; rec."Location Code")
            {
                ApplicationArea = all;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }
    //ALLENick_Start
    // trigger OnOpenPage()
    // var
    //     usersetup: Record "User Setup";
    // begin
    //     if Usersetup."Allow Master Modification" = false then begin
    //         Error('You are not authorized to Access the page');
    //         CurrPage.Close();
    //     end;

    // end;
    //ALLENick_End
    var
        myInt: Integer;
}