table 50067 "E-Invoice Log Entry"
{
    Caption = 'E-Invoice Log Entry';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Editable = false;
        }
        field(2; "Request Type"; Option)
        {
            Editable = false;
            OptionCaption = ' ,E-Invoice,E-Transaction';
            OptionMembers = " ","E-Invoice","E-Transaction";
        }
        field(3; "Order No."; Code[20])
        {
            Editable = false;
        }
        field(4; "Invoice No."; Code[20])
        {
            Editable = false;
        }
        field(5; "IRN No."; Text[64])
        {
            Editable = false;
        }
        field(6; "Request Validated"; Boolean)
        {
        }
        field(7; "OTP Request By"; Text[100])
        {
            Editable = false;
        }
        field(8; "OTP Request Sent"; Boolean)
        {
            Editable = false;
        }
        field(9; "OTP Value"; Code[20])
        {
            Editable = false;
        }
        field(10; "Payment Validated"; Boolean)
        {
            Editable = false;
        }
        field(11; "Invoice Amount"; Decimal)
        {
        }
        field(12; "OTP Shared By"; Text[50])
        {
            Editable = false;
        }
        field(13; "URN Number"; Code[50])
        {
        }
        field(14; "Customer Acc Name"; Text[30])
        {
        }
        field(15; "Trans type"; Option)
        {
            OptionCaption = 'NEFT,IMPS,RTGS';
            OptionMembers = NEFT,IMPS,RTGS;
        }
        field(16; "OTP Request Time"; Time)
        {
            Editable = false;
        }
        field(17; "OTP Send Date"; Date)
        {
            Editable = false;
        }
        field(18; Remarks; Text[200])
        {
        }
        field(19; "OTP by User"; Code[20])
        {
        }
        field(20; AckNo; Code[50])
        {
        }
        field(21; "Ack DateTime"; Text[30])
        {
        }
        field(23; "SignedInvoice(Encrypted)"; Text[250])
        {
        }
        field(24; "SignedQRCode(Encrypted)"; Text[250])
        {
        }
        field(25; "IRN Req Status"; Text[30])
        {
        }
        field(26; "Einvoice Res Message"; Text[250])
        {
        }
        field(27; "Einvoice QR Code"; BLOB)
        {
            SubType = Bitmap;
        }
        field(28; "E-Waybill No."; Code[50])
        {

        }
        field(29; "E-waybillDate"; DateTime)
        {
        }
    }

    keys
    {
        key(Key1; "Entry No.", "Order No.")
        {
        }
        key(Key2; "Invoice No.")
        {
        }
    }
}
