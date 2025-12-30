tableextension 50055 PurchCrMemoGSTExt extends "Purch. Cr. Memo Hdr."
{
    fields
    {
        // Add changes to table fields here
        field(50010; "Acknowledgement No."; Text[30])
        {
            Caption = 'Acknowledgement No.';
            DataClassification = CustomerContent;
        }
        field(50011; "IRN Hash"; Text[64])
        {
            Caption = 'IRN Hash';
            DataClassification = CustomerContent;
        }
        field(50020; "Order No"; Code[20]) //PT-FBTS 02-09-2-2025
        {
            DataClassification = ToBeClassified;
        }
        field(50012; "QR Code"; Blob)
        {
            Subtype = Bitmap;
            Caption = 'QR Code';
            DataClassification = CustomerContent;
        }
        field(50013; "Acknowledgement Date"; DateTime)
        {
            Caption = 'Acknowledgement Date';
            DataClassification = CustomerContent;
        }
        field(50014; "IsJSONImported"; Boolean)
        {
            Caption = 'IsJSONImported';
            DataClassification = EndUserPseudonymousIdentifiers;
        }
        //PT-FBTS 10-11-2025 RepCounter

        field(50018; "Replication Counter"; Integer)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                // Transaction: Record "LSC Transaction Header";
                Transaction: Record "Purch. Cr. Memo Hdr.";
                ClientSessionUtility: Codeunit "LSC Client Session Utility";
            begin
                Transaction.SetCurrentKey("Replication Counter");
                if Transaction.FindLast then
                    "Replication Counter" := Transaction."Replication Counter" + 1
                else
                    "Replication Counter" := 1;
            end;
        }
        // PT-FBTS 10-11-2025 RepCounter


    }
    keys
    {
        // Add changes to keys here
        key(sec; "Replication Counter") //PT-FBTS 10-11-2025 RepCounter ICT
        {

        }
    }
    trigger OnInsert()
    var
        myInt: Integer;
    begin
        Validate("Replication Counter"); //PT-FBTS 10-11-2025 RepCounterICT
    end;

    trigger OnModify()
    var
        myInt: Integer;
    begin
        Validate("Replication Counter"); //PT-FBTS 10-11-2025 RepCounter ICT
    end;

    var

    var
        myInt: Integer;
}