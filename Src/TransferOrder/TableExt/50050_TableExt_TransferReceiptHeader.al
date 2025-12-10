tableextension 50050 TransfreReceiptHeadExt extends "Transfer Receipt Header"
{
    fields
    {
        field(50103; TransferOrderReferenceNo; Code[20])
        {
            Caption = 'TransferOrderReferenceNo';
            //TableRelation = "Transfer Receipt Header"."No.";
        }
        field(50000; "Requistion No."; Code[25])
        {
            DataClassification = ToBeClassified;
            Caption = 'Indent No.';
            //  Editable = false;
        }
        //PT-FBTS 10-11-2025 RepCounter

        field(50104; "Replication Counter"; Integer)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
            // trigger OnValidate()
            // var
            //     // Transaction: Record "LSC Transaction Header";
            //     Transaction: Record "Transfer Receipt Header";
            //     ClientSessionUtility: Codeunit "LSC Client Session Utility";
            // begin
            //     Transaction.SetCurrentKey("Replication Counter");
            //     if Transaction.FindLast then
            //         "Replication Counter" := Transaction."Replication Counter" + 1
            //     else
            //         "Replication Counter" := 1;
            // end;
        }
        // PT-FBTS 10-11-2025 RepCounter


    }
    keys
    {
        // Add changes to keys here
        key(sec; "Replication Counter") //PT-FBTS 10-11-2025 RepCounter
        {

        }
    }

}