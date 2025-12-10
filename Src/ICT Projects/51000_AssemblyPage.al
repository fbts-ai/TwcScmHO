// pageextension 51000 AssemblyOrderPageExt extends "Assembly Order"
// {
//     layout
//     {
//         // Add changes to page layout here
//     }

//     trigger OnOpenPage()
//     var
//         myInt: Integer;
//     begin
//         if Rec."Order Posted" then
//             Editable := false
//         else
//             Editable := true;
//     end;

//     trigger OnModifyRecord(): Boolean
//     begin
//         if Rec."Order Posted" then
//             Error('user cannot modify this Posted Order');
//     end;

//     trigger OnDeleteRecord(): Boolean
//     begin
//         if Rec."Order Posted" then
//             Error('user cannot modify this Posted Order');
//     end;

//     var
//         CheckPosting: Boolean;
//         prod: Page 99000831;
// }