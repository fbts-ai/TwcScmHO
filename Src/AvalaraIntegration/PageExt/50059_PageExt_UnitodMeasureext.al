pageextension 50059 UnitofmeasureExt extends "Units of Measure"
{
    layout
    {
        // Add changes to page layout here
        addafter("LSC Weight Unit Of Measure")
        {
            field(UCQ; Rec.UCQ)
            {
                caption = 'UCQ';
            }
            field("E UOM"; Rec."E UOM")
            {
                ApplicationArea = all;
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
    //end;
    //AlleNick_End

    var
        myInt: Integer;
}