// page 50160 "Store_"
// {
//     PageType = List;
//     ApplicationArea = All;
//     UsageCategory = Lists;
//     SourceTable = "LSC Store";
//     SourceTableView = where("Only Accept Statement" = CONST(true));
//     layout
//     {
//         area(Content)
//         {
//             repeater(GroupName)
//             {
//                 field("No."; "No.")
//                 {
//                     ApplicationArea = All;

//                 }
//                 field("Statment No"; "Statment No")
//                 {
//                     ApplicationArea = all;
//                 }
//                 field("Statment caluclated"; "Statment caluclated")
//                 {
//                     ApplicationArea = all;
//                 }
//             }
//         }
//         area(Factboxes)
//         {

//         }
//     }

//     actions
//     {
//         area(Processing)
//         {
//             action(ActionName)
//             {
//                 ApplicationArea = All;

//                 trigger OnAction();
//                 begin

//                 end;
//             }
//         }
//     }
// }