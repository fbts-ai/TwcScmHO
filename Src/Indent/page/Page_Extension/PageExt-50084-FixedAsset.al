pageextension 50084 FixedAssetListExt extends "Fixed Asset List"
{
    layout
    {
        // Add changes to page layout here
        addafter("FA Location Code")
        {
            field("Parent Fixed Asset"; rec."Parent Fixed Asset") //AJ_Alle_2802024 
            {
                ApplicationArea = all;
            }

        }
    }

    actions
    {
        // Add changes to page actions here
    }
    // trigger OnOpenPage()
    // var
    //     usersetup: Record "User Setup";
    // begin
    //     if Usersetup."Allow Master Modification" = false then begin
    //         Error('You are not authorized to Access the page');
    //         CurrPage.Close();
    //     end;

    // end;

    var
        myInt: Integer;

    trigger OnOpenPage()
    var
        myInt: Integer;
    begin
        Rec.FilterGroup(2); //PT-FBTS 12-012025
        Rec.SetRange(Rec."Used To", false);
        Rec.FilterGroup(0);
        //PT-FBTS 12-012025
    end;

}