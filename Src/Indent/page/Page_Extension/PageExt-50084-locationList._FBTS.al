pageextension 50083 LocationLists extends "Location List"
{



    layout
    {
        // Add changes to page layout here
        addafter(Name)//PT-FBTS-02-09-25
        {
            field(Address; Rec.Address)
            {
                ApplicationArea = ALL;
            }
            field(City; City)
            {
                ApplicationArea = ALL;
            }
            field("Post Code"; "Post Code")
            {
                ApplicationArea = ALL;
            }
            field("Phone No."; "Phone No.")
            {
                ApplicationArea = ALL;
            }
        }

    }

    actions
    {
        // Add changes to page actions here
    }

    var
        EnableBool: Boolean;

    //     trigger OnOpenPage() //PT-FBTS
    //     var
    //         Usersetup: Record "User Setup";
    //     begin
    //         Usersetup.get(UserId);
    //         if Usersetup."Edit Master Enable" = false then begin
    //             EnableBool := false;
    //             CurrPage.Editable := EnableBool
    //         end else

    //             if Usersetup."Edit Master Enable" = true then begin
    //                 EnableBool := true;
    //                 CurrPage.Editable := EnableBool;

    //             end;
    //         if Usersetup."Edit Master view" = false then begin
    //             Error('Do not a Prmission View please contect tha Administrator');

    //         end;

    //     end;
}