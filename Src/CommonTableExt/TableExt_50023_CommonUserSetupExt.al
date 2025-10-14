tableextension 50023 CommonUserSetupExt extends "User Setup"
{
    fields
    {
        ///Indent
 // Add changes to table fields here
        field(50000; "Phys.Inventory approval"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Phys.Inventory approval';
        }
        field(50001; "Location Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Location;
            Caption = 'Location';
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                // rec."Multiple Location Access" := false;
                // rec."Is Admin" := false;
                // rec.Modify();
            end;


        }
        field(50002; "Indent Approver ID"; code[30])
        {
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(50003; "Indent View"; code[30])
        {

        }

        //indent end
        // Add changes to table fields here

        field(50100; IsModifyItem; Boolean)
        {
            Caption = 'Is Modify Item Allow';
        }

        field(50101; IsModifyCustomer; Boolean)
        {
            Caption = 'Is Modify Customer Allow';
        }

        field(50102; IsModifyVendor; Boolean)
        {
            Caption = 'Is Modify Vendor Allow';
        }
        field(50107; WastageEntryApprover; Code[50])
        {
            TableRelation = "User Setup";
        }
        field(50104; WastageEntryLimit; Decimal)
        {

        }
        field(50108; StockAuditApprover; Code[50])
        {
            Caption = 'Stock Audit Approver';
            TableRelation = "User Setup";
        }
        field(50105; StockAuditLimit; Decimal)
        {
            Caption = 'Stock Audit Limit';

        }
        field(50109; AearManger; Boolean)
        {
            Caption = 'Area Manager';

        }
        // field(50110; BackPostingAllowInDays; Text[2])
        // {
        //     Caption = 'CackDated Posting Allow days';

        // }
        field(50110; BackPostingAllowInDays; Text[4]) //EY
        {
            Caption = 'CackDated Posting Allow days';

        }
        field(50111; IsModifyProductionBom; Boolean)
        {
            Caption = 'Is Modify Production BOM Allowed';

        }
        field(50112; AutomaticPostingDateCheck; Boolean)
        {
            Caption = 'Automatic Posting Date Check';

        }
        field(50113; BackDaysAllowed; DateFormula)
        {
            Caption = 'BackDaysAllowed';

        }
        field(50114; ForwardDaysAllowed; DateFormula)
        {
            Caption = 'ForwardDaysAllowed';

        }
        field(50115; SkipEODValidation; Boolean)
        {
            Caption = 'SkipEODValidation Wastage/Stock ';
            trigger OnValidate()
            var
                myInt: Integer;
                UserSetup: Record "User Setup";
            begin
                //Commented-19012024
                //AJ_ALLE_12062023
                // UserSetup.Get(UserId);
                // if UserSetup."User ID" <> 'ALLE' then
                //     Error('Not Authorised to change this value');
                //AJ_ALLE_12062023
            end;
        }
        field(50116; WastageEntryNotification; Text[100])
        {
            Caption = 'WastageEntryNotification';
        }
        field(50117; StockEntryNotification; Text[100])
        {
            Caption = 'StockEntryNotification';
        }
        field(50118; IndentNotification; Text[100])
        {
            Caption = 'IndentNotification';
        }
        field(50140; AllowLocationDelete; Boolean)
        {
            Caption = 'AllowLocationDelete1';
        }
        field(50141; AllowNoseriesDelete; Boolean)
        {
            Caption = 'AllowNoseriesDelete1';
        }
        field(50142; AllowItemTrackingPage; Boolean)
        {
            Caption = 'AllowItemTrackingPage';
        }
        //field(50141;FinanaceSet)
        //AJ_ALLE_09052023
        field(50143; StoreLive; Boolean)
        {
            Caption = 'Store Live';
        }
        field(50144; "Allow Master Modification"; Boolean)
        {
            DataClassification = ToBeClassified;

        }
        field(50175; "Short Close Prod."; Boolean) //PT-FBTS 10-09-25
        {
            DataClassification = ToBeClassified;

        }
        field(50145; "Is Admin"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Location Admin';
            //AlleNick_Start
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                // rec."Location Code" := '';
                rec."Multiple Location Access" := false;
                rec.Modify();

            end;
            //AlleNick_End
        }
        field(50146; "Admin-Allow Post"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50147; "Multiple Location Access"; Boolean)
        {
            DataClassification = ToBeClassified;
            //AlleNick_Start
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                // rec."Location Code" := '';
                rec."Is Admin" := false;
                rec.Modify();

            end;
            //AlleNick_Start
        }
        //AJ_ALLE_17012023
        //TodayQuarantine++         //AJ_ALLE_22012024 - open
        field(50149; "Quarantine Location"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Location.Code where("Quarantine Location" = const(true));
        }
        field(50150; "Quarantine Approver ID"; code[30])
        {
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(50151; "Quarantine Entry Notification"; Text[100])
        {
            // Caption = 'StockEntryNotification';
            DataClassification = ToBeClassified;
        }
        //AJ_ALLE_02102024
        field(50152; "Discard Approver ID"; code[30])
        {
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(50153; "Discard Entry Notification"; Text[100])
        {
            // Caption = 'StockEntryNotification';
            DataClassification = ToBeClassified;
        }
        field(50154; "inventory Controller"; Boolean)//PT-Fbts 150524
        {
            // Caption = 'StockEntryNotification';
            DataClassification = ToBeClassified;
        }
        field(50155; "Item Non Editable"; Boolean)//PT-Fbts
        {

            DataClassification = ToBeClassified;
        }
        field(50156; "FA Non Editable"; Boolean)//PT-Fbts
        {

            DataClassification = ToBeClassified;
        }
        field(50157; "ShortClose Enable"; Boolean)//PT-Fbts
        {

            DataClassification = ToBeClassified;
        }
        field(50159; "Purch. Post Enable"; Boolean)//PT-Fbts
        {
            DataClassification = ToBeClassified;
        }
        field(50162; "Production Component"; Boolean)//PT-Fbts
        {
            DataClassification = ToBeClassified;
        }
        field(50163; "Transfer Post"; Boolean)//PT-Fbts
        {
            DataClassification = ToBeClassified;
        }
        field(50165; "Assembly Production"; Boolean)//PT-Fbts
        {
            DataClassification = ToBeClassified;
        }
        field(50158; "Master Delete allow"; Boolean)//PT-Fbts
        {
            DataClassification = ToBeClassified;
        }
        field(50160; "Edit Master Enable"; Boolean)//PT-Fbts
        {
            DataClassification = ToBeClassified;
        }
        field(50161; "Edit Master view"; Boolean)//PT-Fbts
        {
            DataClassification = ToBeClassified;
        }
        // field(50168; "ShortCloseProd."; Boolean) //PT-Fbts-260625
        // {
        //     DataClassification = ToBeClassified;
        // }
        //AJ_ALLE_02102024
        //TodayQuarantine //AJ_ALLE_22012024 - open
        //AJ_ALLE_17012023

        //AJ_Alle_09252023

    }



    var
        myInt: Integer;
}