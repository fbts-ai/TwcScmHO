// pageextension 50092 GSTGroupExt extends 18001
// {
//     layout
//     {
//         // Add changes to page layout here
//     }

//     actions
//     {
//         // Add changes to page actions here
//     }
//     //NICK
//     // trigger OnOpenPage()
//     // var
//     //     usersetup: Record "User Setup";
//     // begin
//     //     if Usersetup."Allow Master Modification" = false then begin
//     //         // Error('You are not authorized to Access the page');
//     //         // CurrPage.Close();
//     //         CurrPage.Editable(false);

//     //     end;
//     // end;

//     // trigger OnInsertRecord(BelowxRec: Boolean): Boolean
//     // var
//     //     usersetup: Record "User Setup";
//     // begin
//     //     if Usersetup."Allow Master Modification" = false then begin
//     //         Error('You do not have permission to modify');
//     //     end;
//     // end;

//     // trigger OnNewRecord(BelowxRec: Boolean)
//     // var
//     //     usersetup: Record "User Setup";
//     // begin
//     //     if Usersetup."Allow Master Modification" = false then begin
//     //         Error('You do not have permission to modify');
//     //     end;
//     // end;

//     // trigger OnDeleteRecord(): Boolean
//     // var
//     //     usersetup: Record "User Setup";
//     // begin
//     //     if Usersetup."Allow Master Modification" = false then begin
//     //         Error('You do not have permission to modify');
//     //     end;
//     // end;

//     var
//         myInt: Integer;
// }