// tableextension 50062 ReciptLine extends "Purch. Rcpt. Line"
// {
//     fields
//     {
//         // Add changes to table fields here
//         field(50000; "PI Qty."; Decimal)
//         {

//         }
//         field(50001; "GRN Rate"; Decimal)
//         {

//         }
//         field(50002; "DC No."; Code[20])
//         {

//         }
//         field(50003; "DC Date"; Date)
//         {

//         }
//         field(50004; "Purchase Order No."; Code[20])
//         {

//         }
//         field(50005; "Extra Quantity"; Decimal)
//         {

//         }


//         field(50006; "Extra Receipt No."; Code[20])
//         {
//             Editable = false;
//         }
//         field(50007; "Extra Receipt Line No."; Integer)
//         {
//             Editable = false;
//         }
//         field(50008; "Entry No."; Integer)
//         {

//         }
//     }

//     keys
//     {
//         // Add changes to keys here
//     }

//     fieldgroups
//     {
//         // Add changes to field groups here
//     }

//     var
//         myInt: Integer;
// }