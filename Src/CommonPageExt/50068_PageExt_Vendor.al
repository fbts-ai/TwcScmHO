// pageextension 50068 vendorExt extends "Vendor List"
// {
//     trigger OnOpenPage()
//     var
//         PurchReceivableSetup: Record "Purchases & Payables Setup";
//         Usersetup: Record "User Setup";
//     begin
//         //rec.SetFilter(Blocked, '%1', Rec.Blocked::" ");
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('You are not authorized to Access the page');
//             CurrPage.Close();

//         end;
//         PurchReceivableSetup.Get();
//         IF PurchReceivableSetup.SDVendPostingGrp <> '' then begin
//             Rec.FilterGroup(2);
//             Rec.SetFilter("Vendor Posting Group", '<>%1', PurchReceivableSetup.SDVendPostingGrp);
//             Rec.FilterGroup(1);
//         end;
//     end;
// }