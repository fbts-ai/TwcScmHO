// //AJ_Alle_03112023
// codeunit 50040 ValidationForAurth
// {
//     trigger OnRun()
//     begin

//     end;

//     [EventSubscriber(ObjectType::Table, Database::"Tax Rate", 'OnBeforeInsertEvent', '', false, false)]
//     local procedure OnBeforeInsertEventTaxrate()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;



//     [EventSubscriber(ObjectType::Table, Database::"Tax Rate", 'OnBeforeDeleteEvent', '', false, false)]
//     local procedure OnBeforeDeleteEventTaxrate()

//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"Tax Rate", 'OnBeforeModifyEvent', '', false, false)]
//     local procedure OnBeforeModifyEventTaxrate()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"Item Category", 'OnBeforeInsertEvent', '', false, false)]
//     local procedure OnBeforeInsertEventItemcat()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;



//     [EventSubscriber(ObjectType::Table, Database::"Item Category", 'OnBeforeDeleteEvent', '', false, false)]
//     local procedure OnBeforeDeleteEventTItemcat()

//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"Item Category", 'OnBeforeModifyEvent', '', false, false)]
//     local procedure OnBeforeModifyEventitemCat()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;


//     [EventSubscriber(ObjectType::Table, Database::"Item Unit of Measure", 'OnBeforeInsertEvent', '', false, false)]
//     local procedure OnBeforeInsertEventIuom()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;



//     [EventSubscriber(ObjectType::Table, Database::"Item Unit of Measure", 'OnBeforeDeleteEvent', '', false, false)]
//     local procedure OnBeforeDeleteEventIuom()

//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"Item Unit of Measure", 'OnBeforeModifyEvent', '', false, false)]
//     local procedure OnBeforeModifyEventIuom()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;


//     //  [EventSubscriber(ObjectType::Table, Database::Currency, 'OnBeforeInsertEvent', '', false, false)]
//     // local procedure OnBeforeInsertEventCurrency()
//     // var
//     //     usersetup: Record "User Setup";
//     // begin
//     //  usersetup.Get(UserId);
//     //     if Usersetup."Allow Master Modification" = false then begin
//     //         Error('Not Authorized');
//     //     end;
//     // end;



//     [EventSubscriber(ObjectType::Table, Database::Currency, 'OnBeforeDeleteEvent', '', false, false)]
//     local procedure OnBeforeDeleteEventCurrency()

//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::Currency, 'OnBeforeModifyEvent', '', false, false)]
//     local procedure OnBeforeModifyEventCurrency()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;


//     [EventSubscriber(ObjectType::Table, Database::"Purchases & Payables Setup", 'OnBeforeInsertEvent', '', false, false)]
//     local procedure OnBeforeInsertEventPurchPay()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;



//     [EventSubscriber(ObjectType::Table, Database::"Purchases & Payables Setup", 'OnBeforeDeleteEvent', '', false, false)]
//     local procedure OnBeforeDeleteEventPurchpay()

//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"Purchases & Payables Setup", 'OnBeforeModifyEvent', '', false, false)]
//     local procedure OnBeforeModifyEventPurchPay()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"Sales & Receivables Setup", 'OnBeforeInsertEvent', '', false, false)]
//     local procedure OnBeforeInsertEventSaleRec()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;



//     [EventSubscriber(ObjectType::Table, Database::"Sales & Receivables Setup", 'OnBeforeDeleteEvent', '', false, false)]
//     local procedure OnBeforeDeleteEventSalesRec()

//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"Sales & Receivables Setup", 'OnBeforeModifyEvent', '', false, false)]
//     local procedure OnBeforeModifyEventCSaleRec()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;


//     [EventSubscriber(ObjectType::Table, Database::"Inventory Setup", 'OnBeforeInsertEvent', '', false, false)]
//     local procedure OnBeforeInsertEventinvSetup()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;



//     [EventSubscriber(ObjectType::Table, Database::"Inventory Setup", 'OnBeforeDeleteEvent', '', false, false)]
//     local procedure OnBeforeDeleteEventInvSetu()

//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"Inventory Setup", 'OnBeforeModifyEvent', '', false, false)]
//     local procedure OnBeforeModifyEventInvSet()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;


//     [EventSubscriber(ObjectType::Table, Database::"Manufacturing Setup", 'OnBeforeInsertEvent', '', false, false)]
//     local procedure OnBeforeInsertEventCManu()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;



//     [EventSubscriber(ObjectType::Table, Database::"Manufacturing Setup", 'OnBeforeDeleteEvent', '', false, false)]
//     local procedure OnBeforeDeleteEventCManu()

//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"Manufacturing Setup", 'OnBeforeModifyEvent', '', false, false)]
//     local procedure OnBeforeModifyEventManu()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;


//     [EventSubscriber(ObjectType::Table, Database::Currency, 'OnBeforeInsertEvent', '', false, false)]
//     local procedure OnBeforeInsertEventCurrency()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"FA Setup", 'OnBeforeInsertEvent', '', false, false)]
//     local procedure OnBeforeInsertEventFASetup()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"FA Setup", 'OnBeforeDeleteEvent', '', false, false)]
//     local procedure OnBeforeDeleteEventfasSetup()

//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"FA Setup", 'OnBeforeModifyEvent', '', false, false)]
//     local procedure OnBeforeModifyEventFASetup()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     // [EventSubscriber(ObjectType::Page, Page::"Customer Card", 'OnInsertRecordEvent', '', false, false)]
//     // local procedure OnBeforeModifyEventCus()
//     // var
//     //     usersetup: Record "User Setup";
//     // begin
//     // usersetup.Get(UserId);
//     //     if Usersetup."Allow Master Modification" = false then begin
//     //         Error('Not Authorized');
//     //     end;
//     // end;

//     // [EventSubscriber(ObjectType::Page, Page::"Customer Card", 'OnModifyRecordEvent', '', false, false)]
//     // local procedure OnModifyRecordEventCus()
//     // var
//     //     usersetup: Record "User Setup";
//     // begin
//     // usersetup.Get(UserId);
//     //     if Usersetup."Allow Master Modification" = false then begin
//     //         Error('Not Authorized');
//     //     end;
//     // end;

//     [EventSubscriber(ObjectType::Table, Database::"Warehouse Setup", 'OnBeforeInsertEvent', '', false, false)]
//     local procedure OnBeforeInsertEventWHSSetup()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"Warehouse Setup", 'OnBeforeDeleteEvent', '', false, false)]
//     local procedure OnBeforeDeleteEventWHSSetup()

//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"Warehouse Setup", 'OnBeforeModifyEvent', '', false, false)]
//     local procedure OnBeforeModifyEventWHSSetup()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"General Posting Setup", 'OnBeforeInsertEvent', '', false, false)]
//     local procedure OnBeforeInsertEventGPSSetup()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"General Posting Setup", 'OnBeforeDeleteEvent', '', false, false)]
//     local procedure OnBeforeDeleteEventGPSSetup()

//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"General Posting Setup", 'OnBeforeModifyEvent', '', false, false)]
//     local procedure OnBeforeModifyEventGPSSetup()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"GST Setup", 'OnBeforeInsertEvent', '', false, false)]
//     local procedure OnBeforeInsertEventGSTSetup()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"GST Setup", 'OnBeforeDeleteEvent', '', false, false)]
//     local procedure OnBeforeDeleteEventGSTSetup()

//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"GST Setup", 'OnBeforeModifyEvent', '', false, false)]
//     local procedure OnBeforeModifyEventGSTSetup()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::Dimension, 'OnBeforeInsertEvent', '', false, false)]
//     local procedure OnBeforeInsertEventDMNSetup()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::Dimension, 'OnBeforeDeleteEvent', '', false, false)]
//     local procedure OnBeforeDeleteEventDMNSetup()

//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::Dimension, 'OnBeforeModifyEvent', '', false, false)]
//     local procedure OnBeforeModifyEventDMNSetup()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"No. Series", 'OnBeforeInsertEvent', '', false, false)]
//     local procedure OnBeforeInsertEventNosSetup()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"No. Series", 'OnBeforeDeleteEvent', '', false, false)]
//     local procedure OnBeforeDeleteEventNosSetup()

//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"No. Series", 'OnBeforeModifyEvent', '', false, false)]
//     local procedure OnBeforeModifyEventNosSetup()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"BOM Component", 'OnBeforeInsertEvent', '', false, false)]
//     local procedure OnBeforeInsertEventBOMSetup()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"BOM Component", 'OnBeforeDeleteEvent', '', false, false)]
//     local procedure OnBeforeDeleteEventBomSetup()

//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"BOM Component", 'OnBeforeModifyEvent', '', false, false)]
//     local procedure OnBeforeModifyEventBOMSetup()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;


//     [EventSubscriber(ObjectType::Table, Database::"Comment Line", 'OnBeforeInsertEvent', '', false, false)]
//     local procedure OnBeforeInsertEventCommentLine()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"Comment Line", 'OnBeforeDeleteEvent', '', false, false)]
//     local procedure OnBeforeDeleteEventCommentline()

//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"Comment Line", 'OnBeforeModifyEvent', '', false, false)]
//     local procedure OnBeforeModifyEventCommentLine()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::User, 'OnBeforeInsertEvent', '', false, false)]
//     local procedure OnBeforeInsertEventuser()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::User, 'OnBeforeDeleteEvent', '', false, false)]
//     local procedure OnBeforeDeleteEventUser()

//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::User, 'OnBeforeModifyEvent', '', false, false)]
//     local procedure OnBeforeModifyEventUser()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"User Setup", 'OnBeforeInsertEvent', '', false, false)]
//     local procedure OnBeforeInsertEventUserSetup()
//     var
//         usersetup: Record "User Setup";
//     begin
//         // if Usersetup.Get(UserId) then
//         //     if (Usersetup."User ID" = 'DYNAMICS-DEV-VM\ALLE3') then begin
//         //         Usersetup."Allow Master Modification" := true;
//         //         Usersetup.Modify();
//         //     end;
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"User Setup", 'OnAfterInsertEvent', '', false, false)]
//     local procedure OnAfterInsertEventUserSetup()
//     var
//         usersetup: Record "User Setup";
//     begin
//         // if Usersetup.Get(UserId) then
//         //     if (Usersetup."User ID" = 'DYNAMICS-DEV-VM\ALLE3') then begin
//         //         Usersetup."Allow Master Modification" := true;
//         //         Usersetup.Modify();
//         //     end;
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"User Setup", 'OnBeforeDeleteEvent', '', false, false)]
//     local procedure OnBeforeDeleteEventUserSetup()

//     var
//         usersetup: Record "User Setup";
//     begin
//         // if Usersetup.Get(UserId) then
//         //     if (Usersetup."User ID" = 'DYNAMICS-DEV-VM\ALLE3') then begin//NeedtoChange
//         //         Usersetup."Allow Master Modification" := true;
//         //         Usersetup.Modify();
//         //     end;
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"User Setup", 'OnBeforeModifyEvent', '', false, false)]
//     local procedure OnBeforeModifyEventUSSetup()
//     var
//         usersetup: Record "User Setup";
//     begin
//         if Usersetup.Get(UserId) then
//             if (Usersetup."User ID" = 'ALLE') then begin
//                 Usersetup."Allow Master Modification" := true;
//                 //  Usersetup.Modify();
//             end;
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"Reason Code", 'OnBeforeInsertEvent', '', false, false)]
//     local procedure OnBeforeInsertEventReason()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"Reason Code", 'OnBeforeDeleteEvent', '', false, false)]
//     local procedure OnBeforeDeleteEventReasonCode()

//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"Reason Code", 'OnBeforeModifyEvent', '', false, false)]
//     local procedure OnBeforeModifyEventRsCode()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;


//     [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeInsertEvent', '', false, false)]
//     local procedure OnBeforeInsertEventCustomer()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;



//     [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeDeleteEvent', '', false, false)]
//     local procedure OnBeforeDeleteEventCustomer()

//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeModifyEvent', '', false, false)]
//     local procedure OnBeforeModifyEventCustomer()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnBeforeInsertEvent', '', false, false)]
//     local procedure OnBeforeInsertEventBank()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;



//     [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnBeforeDeleteEvent', '', false, false)]
//     local procedure OnBeforeDeleteEventBank()

//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnBeforeModifyEvent', '', false, false)]
//     local procedure OnBeforeModifyEventBank()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;


//     [EventSubscriber(ObjectType::Table, Database::"Payment Terms", 'OnBeforeInsertEvent', '', false, false)]
//     local procedure OnBeforeInsertEventPayment()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;



//     [EventSubscriber(ObjectType::Table, Database::"Payment Terms", 'OnBeforeDeleteEvent', '', false, false)]
//     local procedure OnBeforeDeleteEventPayment()

//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"Payment Terms", 'OnBeforeModifyEvent', '', false, false)]
//     local procedure OnBeforeModifyEventPayment()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;


//     [EventSubscriber(ObjectType::Table, Database::"Payment Method", 'OnBeforeInsertEvent', '', false, false)]
//     local procedure OnBeforeInsertEventPaymentM()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;



//     [EventSubscriber(ObjectType::Table, Database::"Payment Method", 'OnBeforeDeleteEvent', '', false, false)]
//     local procedure OnBeforeDeleteEventPaymentM()

//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"Payment Method", 'OnBeforeModifyEvent', '', false, false)]
//     local procedure OnBeforeModifyEventPaymentM()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnBeforeInsertEvent', '', false, false)]
//     local procedure OnBeforeInsertEventGLAcc()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;



//     [EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnBeforeDeleteEvent', '', false, false)]
//     local procedure OnBeforeDeleteEventGL()

//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnBeforeModifyEvent', '', false, false)]
//     local procedure OnBeforeModifyEventGL()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;


//     [EventSubscriber(ObjectType::Table, Database::"LSC Store", 'OnBeforeInsertEvent', '', false, false)]
//     local procedure OnBeforeInsertEventLscStore()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;



//     [EventSubscriber(ObjectType::Table, Database::"LSC Store", 'OnBeforeDeleteEvent', '', false, false)]
//     local procedure OnBeforeDeleteLSCstore()

//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"LSC Store", 'OnBeforeModifyEvent', '', false, false)]
//     local procedure OnBeforeModifyLSCStore()
//     var
//         usersetup: Record "User Setup";
//     begin
//         usersetup.Get(UserId);
//         if Usersetup."Allow Master Modification" = false then begin
//             Error('Not Authorized');
//         end;
//     end;


//     var
//         myInt: Integer;
// }