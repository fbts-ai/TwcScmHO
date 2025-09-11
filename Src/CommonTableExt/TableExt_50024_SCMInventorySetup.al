tableextension 50024 SCMInventorySetupExt extends "Inventory Setup"
{
    fields
    {

        //Indent 
        // Add changes to table fields here
        field(50000; "Indent Nos."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";

        }
        field(50001; "Indent Time"; Time)
        {

        }
        field(50003; "Max Submission limit"; Integer)
        { }
        field(50004; "Indent Delivery date Cal"; DateFormula)
        { }
        field(50005; "Area Manager Timelines"; Time)
        { }

        field(50002; WastageEntryNo; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Wastege Entry No.';
            TableRelation = "No. Series";

        }
        // Add changes to table fields here
        field(50100; StockAuditNo; Code[20])
        {
            Caption = 'Stock Audit No.';
            TableRelation = "No. Series";
        }
        field(50101; StockAuditTemplateName; Code[10])
        {
            Caption = 'StockAudit Teplate Name';
            TableRelation = "Item Journal Template";
        }
        field(50102; StockAuditBatchName; Code[10])
        {
            Caption = 'StockAudit Batch Name';
            // TableRelation = "Item Journal Batch";
        }
        field(50103; WastageEntryTemplateName; Code[10])
        {
            Caption = 'WastageEntry Teplate Name';
            TableRelation = "Item Journal Template";
        }
        field(50104; WastageEntryBatchName; Code[10])
        {
            Caption = 'WastageEntry Batch Name';
            //  TableRelation = "Item Journal Batch";
        }
        field(50105; IndentMinMaxCalDays; Integer)
        {
            Caption = 'Indent min Max Calculation Days';
            //  TableRelation = "Item Journal Batch";
        }
        field(50106; IndentMaxCalculation; Integer)
        {
            Caption = 'IndentMaxCalculation';
            //  TableRelation = "Item Journal Batch";
        }

        field(50107; FATransferTemplateName; Code[10])
        {
            Caption = 'Fixed Asset Transfer Template Name';
            TableRelation = "Item Journal Template";
        }
        field(50108; FATransferBatchName; Code[10])
        {
            Caption = 'Fixed asset Transfer Batch Name';
            //  TableRelation = "Item Journal Batch";
        }
        field(50120; "Cost Adjustment Logging"; Enum "Cost Adjustment Logging Level")
        {
            Caption = 'Cost Adjustment Logging';
            DataClassification = CustomerContent;
        }
        field(50109; OfflineSalesBatchName; Code[10])
        {
            Caption = 'Offline Sales Process';
            //  TableRelation = "Item Journal Batch";
        }
        field(50110; OfflineSalesNoSeries; Code[20])
        {
            Caption = 'Offline Sales No Series ';
            TableRelation = "No. Series";
        }
        //AJ_ALLE_25102023
        field(50111; "Item Non Editable"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50112; "FA Non Editable"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        //AJ_ALLE_25102023
        //AJ_ALLE_17012023
        //TodayQuarantine  //AJ_ALLE_22012024 - open
        field(50113; "Qurantine location Sr."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series".Code;
        }
        field(50118; "Quarantine-Discard Temp"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Item Journal Template";
        }
        field(50114; "Quarantine Batch Name"; Text[30])
        {
            DataClassification = ToBeClassified;

        }
        field(50115; "Transfer Batch Name"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        //AJ_ALLE_22012024 - open
        //TodayQuarantine
        //AJ_ALLE_17012023
        //ALLE_NICK_11/1/23_LotFix
        field(50116; "Wastage Post. Allow"; Boolean)
        {
            DataClassification = ToBeClassified;

        }
        field(50117; "Inventory Post. Allow"; Boolean)
        {
            DataClassification = ToBeClassified;

        }
        //ALLE_NICK_220224
        field(50119; "Caluclate statment Error"; text[200])
        {
            DataClassification = ToBeClassified;

        }
        field(50121; "Custom Bom Nos"; Code[20])
        {
            Caption = 'Custom Bom Nos.';
            TableRelation = "No. Series";
        }
        field(50124; "Conslid.indent Nos."; Code[20])
        {
            Caption = 'Conslid.indent Nos.';
            TableRelation = "No. Series";
        }
        field(50125; "Max Submission limit Special"; Integer)
        { }
        field(50122; "Min. Quantity Percent"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(50123; "Max. Quantity Percent"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(50126; ConsumptionEntryNo; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Replacement&Dialling No.';
            TableRelation = "No. Series";

        }

    }

    var
        myInt: Integer;
}