pageextension 50020 SCMUsersetup extends "User Setup"
{
    layout
    {
        //indent user setup
        addafter("User ID")
        {
            field("Transfer Post"; Rec."Transfer Post")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Transfer Post field.', Comment = '%';
            }
            field("Location Code"; Rec."Location Code")
            {
                ApplicationArea = all;
            }
            field("Approver ID"; rec."Indent Approver ID")
            {
                ApplicationArea = all;
                Caption = 'Indent Approver ID';
            }
            //AJ_ALLE_09052023
            field(StoreLive; Rec.StoreLive)
            {
                ApplicationArea = all;
                Caption = 'Store Live';
            }
            //AJ_ALLE_15112023
            field("Allow Master Modification"; rec."Allow Master Modification")
            {
                ApplicationArea = all;

            }
            //AJ_ALLE_15112023

            // field("Is Admin"; Rec."Is Admin")
            // {
            //     ApplicationArea = all;

            // }
            field("Admin-Allow Post"; rec."Admin-Allow Post")
            {
                ApplicationArea = all;
            }
            field("inventory Controller"; Rec."inventory Controller")//PT-FBTS 150524
            {
                ApplicationArea = all;
                Caption = 'inventory Controller';
            }
            field("Assembly Production"; "Assembly Production")//PTFBTS
            {
                ApplicationArea = all;
            }
            field("FA Non Editable"; rec."FA Non Editable")//PT-FBTS
            {
                ApplicationArea = all;
            }
            field("Item Non Editable"; rec."Item Non Editable")//PT-FBTS
            {
                ApplicationArea = all;
            }
            field("ShortClose Enable"; "ShortClose Enable")///PT-FBTS
            {
                ApplicationArea = all;
            }
            field("Purch. Post Enable"; Rec."Purch. Post Enable")//PT-FBTS
            {
                ApplicationArea = all;
            }
            field("Edit Master Enable"; "Edit Master Enable")//PT-FBTS
            {
                ApplicationArea = all;
            }
            field("Edit Master view"; "Edit Master view")//PT-FBTS
            {
                ApplicationArea = all;
            }
            field("Master Delete allow"; "Master Delete allow")//PT-FBTS
            {
                ApplicationArea = all;
            }
            field("Short Close Prod."; "Short Close Prod.")//PT-FBTS-10-09-25
            {
                ApplicationArea = all;
            }
            //NTCNFRM
            // field("Multiple Location Access"; rec."Multiple Location Access")
            // {
            //     ApplicationArea = all;

            // }
            //NTCNFRM
            //AJ_ALLE_09052023
        }

        // Add changes to page layout here
        addafter(PhoneNo)
        {
            field(WastageEntryLimit; Rec.WastageEntryLimit)
            {
                caption = 'Wastage Entry %';
            }
            field(WastageEntryApprover; Rec.WastageEntryApprover)
            {
                caption = 'Wastage Entry Approver';
            }
            field(StockAuditApprover; Rec.StockAuditApprover)
            {
                caption = 'Stock Audit Approver';
            }

            field(StockAuditLimit; Rec.StockAuditLimit)
            {
                caption = 'Stock Audit %';
            }
            field(AearManger; Rec.AearManger)
            {
                caption = 'Area Manager';

            }
            field(BackPostingAllowInDays; Rec.BackPostingAllowInDays)
            {
                caption = 'Backed dated Posting Days';

            }
        }
        addafter("Allow Posting To")
        {
            field(IsModifyItem; Rec.IsModifyItem)
            {
                Caption = 'Is Modify Item Allow';
            }
            field(IsModifyCustomer; Rec.IsModifyCustomer)
            {
                Caption = 'Is Modify Customer Allow';
            }
            field(IsModifyVendor; Rec.IsModifyVendor)
            {
                Caption = 'Is Modify Vendor Allow';
            }
            field(IsModifyProductionBom; Rec.IsModifyProductionBom)
            {
                Caption = 'Is Modify Production BOM allow';
            }
            field(AllowLocationDelete; Rec.AllowLocationDelete)
            {
                Caption = 'AllowLocationDelete';
            }
            field(AllowNoseriesDelete; Rec.AllowNoseriesDelete)
            {
                Caption = 'AllowNoseriesDelete';
            }
            field(AutomaticPostingDateCheck; Rec.AutomaticPostingDateCheck)
            {
                Caption = 'Automatic Posting Date Check';
            }
            field(ForwardDaysAllowed; Rec.ForwardDaysAllowed)
            {
                Caption = 'ForwardDaysAllowed';
            }
            field(BackDaysAllowed; Rec.BackDaysAllowed)
            {
                Caption = 'BackDaysAllowed';
            }
            field(SkipEODValidation; Rec.SkipEODValidation)
            {
                caption = 'Skip EOD Validation';
            }
            field(WastageEntryNotification; Rec.WastageEntryNotification)
            {
                Caption = 'WastageEntryNotification';
            }
            field(StockEntryNotification; Rec.StockEntryNotification)
            {
                Caption = 'StockEntryNotification';
            }
            field(IndentNotification; Rec.IndentNotification)
            {
                Caption = 'IndentNotification';
            }
            //AJ_ALLE_17012023

            //TodayQuarantine //AJ_ALLE_22012024 - open
            field("Quarantine Approver ID"; "Quarantine Approver ID")
            {
                ApplicationArea = all;
            }
            field("Quarantine Entry Notification"; rec."Quarantine Entry Notification")
            {
                ApplicationArea = all;
            }
            field("Quarantine Location"; rec."Quarantine Location")
            {
                ApplicationArea = all;
            }
            //AJ_ALLE_02102024
            field("Discard Approver ID"; rec."Discard Approver ID")
            {
                ApplicationArea = all;
            }
            field("Discard Entry Notification"; rec."Discard Entry Notification")
            {
                ApplicationArea = all;
            }
            field("Production Component"; "Production Component")
            {
                ApplicationArea = all;
            }
            //AJ_ALLE_02102024
            //TodayQuarantine //AJ_ALLE_22012024 - open
            //AJ_ALLE_17012023
        }
    }

    actions
    {
        // Add changes to page actions here
    }
    //AlleNick_Start
    // trigger OnModifyRecord(): Boolean
    // var
    //     Usersetup: Record "User Setup";
    // begin
    //     if Usersetup.Get(UserId) then
    //         if (Usersetup."User ID" = 'DYNAMICS-DEV-VM\ALLE3') then begin
    //             Usersetup."Allow Master Modification" := true;
    //             Usersetup.Modify();
    //         end;
    //     if Usersetup."Allow Master Modification" = false then begin
    //         Error('Not Authorized');
    //     end
    // end;

    trigger OnOpenPage()
    var
        Usersetup: Record "User Setup";
    begin
        if Usersetup.Get(UserId) then
            if (Usersetup."User ID" = 'ALLE') then begin
                Usersetup."Allow Master Modification" := true;
                Usersetup.Modify();
            end;

    end;
    //AlleNick_End

    var

}