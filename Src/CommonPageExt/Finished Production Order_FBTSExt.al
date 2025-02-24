// pageextension 50080 FinishedProductionOrder extends "Finished Production Order"
// {
//     layout
//     {
//         // Add changes to page layout here
//     }

//     actions
//     {
//         // Add changes to page actions here
//     }

//     var
//         myInt: Integer;

//     trigger OnDeleteRecord(): Boolean; /// PT-FBTS 11-09-24 
//     var
//         myInt: Integer;
//     begin
//         Error('You can not delete this documnet');
//     end;
// }