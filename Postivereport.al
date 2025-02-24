// report 50022 Postivecount
// {
//     DefaultLayout = RDLC;
//     RDLCLayout = '.vscode/Layouts/Postivecount.rdl';
//     UsageCategory = ReportsAndAnalysis;
//     ApplicationArea = all;
//     Caption = 'ILE Postive count';

//     dataset
//     {
//         dataitem("Item Ledger Entry"; "Item Ledger Entry")
//         {
//             DataItemTableView = SORTING("Entry No.")
//                                 ORDER(Ascending);

//             RequestFilterFields = "Entry Type";
//             column(Billcount; Billcount)
//             {

//             }
//             column(TotcountWithoutBill; Totcount)
//             {

//             }
//             trigger OnAfterGetRecord()
//             var
//                 myInt: Integer;
//             begin
//                 //if "Reservation Entry"."Item No." = 'FG00003' then
//                 // if "Item Ledger Entry"."Reason Code" = 'BILL' then begin
//                 //     Billcount := "Item Ledger Entry".Count;
//                 // end
//                 // else
//                 //     Totcount := "Item Ledger Entry".Count;
//             end;

//             trigger OnPreDataItem()
//             var
//                 myInt: Integer;
//             begin
//                 "Item Ledger Entry".SetRange("Posting Date", FromDate, ToDate);
//             end;

//             trigger OnPostDataItem()
//             var
//                 myInt: Integer;
//             begin
//                 if "Item Ledger Entry"."Reason Code" = 'BILL' then begin
//                     Billcount := "Item Ledger Entry".Count;
//                 end
//                 else
//                     Totcount := "Item Ledger Entry".Count;

//             end;
//         }
//     }
//     requestpage
//     {
//         SaveValues = true;
//         layout
//         {
//             area(Content)
//             {
//                 group(GroupName)
//                 {
//                     field(FromDate; FromDate)
//                     {
//                         Caption = 'From Date';
//                         ApplicationArea = all;
//                     }
//                     field(ToDate; ToDate)
//                     {
//                         Caption = 'To Date';
//                         ApplicationArea = all;
//                     }
//                 }
//             }
//         }

//         actions
//         {
//             area(processing)
//             {
//                 action(ActionName)
//                 {
//                     ApplicationArea = All;

//                 }
//             }
//         }
//     }

//     // rendering
//     // {
//     //     layout(LayoutName)
//     //     {
//     //         Type = RDLC;
//     //         LayoutFile = 'mylayout.rdl';
//     //     }
//     // }

//     var
//         myInt: Integer;
//         Billcount: Integer;
//         Totcount: Integer;

//         FromDate: Date;
//         ToDate: Date;
// }