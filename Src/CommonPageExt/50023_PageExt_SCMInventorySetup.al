pageextension 50023 SCMInventorySetup extends "Inventory Setup"
{
    layout
    {
        addlast(General)
        {
            //AJ_Alle_14112023
            //TodayQuarantine

            field("Qurantine location Sr."; rec."Qurantine location Sr.")
            {
                ApplicationArea = all;
            }
            field("Quarantine-Discard Temp"; rec."Quarantine-Discard Temp")
            {
                ApplicationArea = all;
            }
            field("Quarantine Batch Name"; rec."Quarantine Batch Name")
            {
                ApplicationArea = all;
            }
            field("Transfer Batch Name"; rec."Transfer Batch Name")
            {
                ApplicationArea = all;
            }
            //TodayQuarantine
            //AJ_Alle_14112023
            field(WastageEntryTemplateName; Rec.WastageEntryTemplateName)
            {
                caption = 'WastageEntryTemplateName';
            }
            field(WastageEntryBatchName; Rec.WastageEntryBatchName)
            {
                caption = 'WastageEntryBatchName';
            }
            field(StockAuditTemplateName; Rec.StockAuditTemplateName)
            {
                Caption = 'StockAudit TemplateName';
            }
            field(StockAuditBatchName; Rec.StockAuditBatchName)
            {
                Caption = 'StockAuditBatchName';
            }
            field(IndentMinMaxCalDays; Rec.IndentMinMaxCalDays)
            {
                Caption = 'Indent Min Max Calculation Days';
            }
            field(IndentMaxCalculation; Rec.IndentMaxCalculation)
            {
                Caption = 'IndentMaxCalculation';
            }

            field(FATransferTemplateName; Rec.FATransferTemplateName)
            {
                Caption = 'Fixed Asset Transfer Template Name';
            }
            field(FATransferBatchName; Rec.FATransferBatchName)
            {
                Caption = 'Fixed asset Transfer Batch Name';
            }
            field(OfflineSalesBatchName; Rec.OfflineSalesBatchName)
            {
                Caption = 'Offline Sales Process';
            }
            //ALLE_NICK_11/1/23_LotFix
            field("Wastage Post. Allow"; "Wastage Post. Allow")
            {
                ApplicationArea = all;
            }
            field("Inventory Post. Allow"; "Inventory Post. Allow")
            {
                ApplicationArea = all;
            }
            field("Max Submission limit Special"; rec."Max Submission limit Special")
            {
                ApplicationArea = all;
            }
            field("Max. Quantity Percent"; Rec."Max. Quantity Percent")
            {
                ApplicationArea = All;
                Caption = 'Max. Production Limit Percentage';
            }
            field("Min. Quantity Percent"; Rec."Min. Quantity Percent")
            {
                ApplicationArea = All;
                Caption = 'Min. Production Limit Percentage';
            }


        }
        addlast(Numbering)
        {
            field(WastageEntryNo; Rec.WastageEntryNo)
            {
                Caption = 'Wastage Entry No.';
            }

            field(StockAuditNo; Rec.StockAuditNo)
            {
                Caption = 'Stock Audit No.';
            }
            field(OfflineSalesNoSeries; rec.OfflineSalesNoSeries)
            {
                Caption = 'Offline Sales No Series';
            }

        }

        //indent
        addlast(General)
        {
            field("Indent Nos."; Rec."Indent Nos.")
            {
                ApplicationArea = All;

            }
            field("Custom Bom Nos"; "Custom Bom Nos") //PT-FBTS 20/11/24
            {
                ApplicationArea = All;

            }
            field("Conslid.indent Nos."; "Conslid.indent Nos.")
            {
                Caption = 'Conslid.indent Nos.';
                ApplicationArea = all;
            }
            field("Indent Time"; rec."Indent Time")
            {
                ApplicationArea = all;
            }
            field("Max Submission limit"; rec."Max Submission limit")
            {
                ApplicationArea = all;
            }
            field("Indent Delivery date Cal"; rec."Indent Delivery date Cal")
            {
                ApplicationArea = all;
            }
            field("Area Manager Timelines"; rec."Area Manager Timelines")
            {
                ApplicationArea = all;
            }
            //AJ_Alle_25102023
            field("Item Non Editable"; rec."Item Non Editable")
            {
                ApplicationArea = all;
                Caption = 'Item DUC Non-Editable';
            }
            field("FA Non Editable"; rec."FA Non Editable")
            {
                ApplicationArea = all;
                Caption = 'FA DUC Non-Editable';
            }
            //AJ_Alle_25102023
        }
    }

    actions
    {
        // Add changes to page actions here
    }
    // trigger OnOpenPage()
    // var
    //     usersetup: Record "User Setup";
    // begin
    //     if Usersetup."Allow Master Modification" = false then begin
    //         Error('You are not authorized to Access the page');
    //         CurrPage.Close();

    //     end;
    // end;


    var
        myInt: Integer;
}