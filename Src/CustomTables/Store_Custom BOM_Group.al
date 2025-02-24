// table 50141 "Store Custom BOM Group"
// {
//     DataClassification = ToBeClassified;
//     fields
//     {
//         field(1; "Custom BOM Group Code"; Code[20])
//         {
//             DataClassification = ToBeClassified;
//         }
//         field(2; "Store No."; Code[10])
//         {
//             DataClassification = ToBeClassified;
//             TableRelation = "LSC Store";
//         }
//     }
//     keys
//     {
//         key(Key1; "Custom BOM Group Code")
//         {
//             Clustered = true;
//         }
//     }
//     fieldgroups
//     {
//         // Add changes to field groups here
//     }
//     var

//     trigger OnInsert()
//     begin
//     end;

//     trigger OnModify()
//     begin
//     end;

//     trigger OnDelete()
//     begin
//     end;

//     trigger OnRename()
//     begin
//     end;
// }