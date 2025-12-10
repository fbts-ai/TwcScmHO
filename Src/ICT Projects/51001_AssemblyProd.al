// pageextension 51001 AssemblyProdExt_1 extends "Assembly Productions"
// {
//     layout
//     {
//         // Add changes to page layout here
//     }

//     actions
//     {
//         // Add changes to page actions here
//     }
//     trigger OnModifyRecord(): Boolean
//     begin
//         if Rec."Order Posted" then
//             Error('user cannot modify this Posted Order');
//     end;

//     trigger OnDeleteRecord(): Boolean
//     var
//         myInt: Integer;
//     begin
//         if Rec."Order Posted" then
//             Error('user cannot modify this Posted Order');
//     end;

//     var
//         myInt: Integer;
// }