tableextension 50018 ItemJnlLineExt extends "Item Journal Line"
{
    fields
    {
        // Add changes to table fields here
        field(50100; BrandName; Text[20])
        {
            Caption = 'Brand Name';
        }
        field(50101; ProdutionOrderQtyChanged; Boolean)
        {
            Caption = 'ProdutionOrderQtyChanged';
        }
        field(50102; ProdutionOrderRemark; Text[50])
        {
            Caption = 'ProdutionOrderRemark';
        }

        field(50105; ManufacturingDate; Date)
        {
            Caption = 'Manufacturing Date';
        }
        field(50110; "Stock in Hand"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50111; Status; Enum Status_Wastage)
        {
            DataClassification = CustomerContent;
        }
        //AJ_ALLE_17012023
        //TodayQuarantine
        field(50114; Remarks; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(50115; "ILE Entry No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(50116; "Quarantine Location Boolean"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50221; "Approver"; Code[30])
        {
            DataClassification = ToBeClassified;
            //OptionMembers = Open,"Sent for Approval",Rejected,Approved;
        }
        //AJ_22012024
        // field(50113; "Approval Status"; Option)
        // {
        //     DataClassification = ToBeClassified;
        //     OptionMembers = Open,"Sent for Approval",Rejected,Approved;
        // }
        field(50220; "Rejection Remarks"; Text[200])
        {
            DataClassification = ToBeClassified;
            //OptionMembers = Open,"Sent for Approval",Rejected,Approved;
        }
        field(50224; LotNo; Text[200])
        {
            DataClassification = ToBeClassified;
            //OptionMembers = Open,"Sent for Approval",Rejected,Approved;
        }
        //AJ_22012024
        //TodayQuarantine
        //AJ_ALLE_17012023
        // field(50222; "Select"; Boolean)
        // {
        //     DataClassification = ToBeClassified;
        //     //OptionMembers = Open,"Sent for Approval",Rejected,Approved;
        // }
    }

    // trigger OnAfterInsert()
    // var
    //     ItemJnlBatch: Record "Item Journal Batch";
    //     LSCUserSetup: Record "LSC Retail User";
    // begin
    //     if Rec."Journal Template Name" = 'ITEM' then begin
    //         LSCUserSetup.Get(UserId);
    //         ItemJnlBatch.SetRange("Journal Template Name", 'ITEM');
    //         ItemJnlBatch.SetRange("Location Code", LSCUserSetup."Location Code");
    //         if ItemJnlBatch.FindFirst() then
    //             Rec."Journal Batch Name" := ItemJnlBatch.Name;
    //     end;
    // end;

    var
        myInt: Integer;
}