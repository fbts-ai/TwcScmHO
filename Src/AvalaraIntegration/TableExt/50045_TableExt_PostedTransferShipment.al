tableextension 50045 PostedTransferShipmentExt extends "Transfer Shipment Header"
{
    fields
    {
        //aded for indent flow
        // Add changes to table fields here
        field(50000; "Requistion No."; Code[25])
        {
            DataClassification = ToBeClassified;
            Caption = 'Indent No.';
            //  Editable = false;
        }
        // Add changes to table fields here
        // Add changes to table fields here
        field(50006; "Acknowledgement No."; Text[30])
        {
            Caption = 'Acknowledgement No.';
            DataClassification = CustomerContent;
        }
        field(50001; "IRN Hash"; Text[64])
        {
            Caption = 'IRN Hash';
            DataClassification = CustomerContent;
        }
        field(50002; "QR Code"; Blob)
        {
            Subtype = Bitmap;
            Caption = 'QR Code';
            DataClassification = CustomerContent;
        }
        field(50003; "Acknowledgement Date"; DateTime)
        {
            Caption = 'Acknowledgement Date';
            DataClassification = CustomerContent;
        }
        field(50004; "IsJSONImported"; Boolean)
        {
            Caption = 'IsJSONImported';
            DataClassification = EndUserPseudonymousIdentifiers;
        }
        field(50005; "E-Way Bill No."; Text[50])
        {
            Caption = 'E-Way Bill No.';
            DataClassification = CustomerContent;
        }
        field(50103; TransferOrderReferenceNo; Code[20])
        {
            Caption = 'TransferOrderReferenceNo';
            //TableRelation = "Transfer Receipt Header"."No.";
        }
        //PT-FBTS 10-11-2025 RepCounter

        field(50104; "Replication Counter"; Integer)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                // Transaction: Record "LSC Transaction Header";
                Transaction: Record "Transfer Shipment Header";
                ClientSessionUtility: Codeunit "LSC Client Session Utility";
            begin
                // Transaction.SetCurrentKey("Replication Counter");
                // Transaction.SetRange("Transfer-from Code", "Transfer-from Code");
                // if Transaction.FindLast then
                //     "Replication Counter" := Transaction."Replication Counter" + 1
                // else
                //     "Replication Counter" := 1;
            end;
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

    var
        myInt: Integer;

    trigger OnDelete() /// PT-FBTS 11-09-24 
    var
        myInt: Integer;
    begin
        Error('You can not delete this documnet');
    end;
}