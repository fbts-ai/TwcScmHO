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
    }

}