table 50069 "E-Waybill Log Entry"
{
    Caption = 'E-Waybill Log Entry';
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
            OptionCaption = ' ,E-Waybill,CancelE-Waybill,E-Transaction';
            OptionMembers = " ","E-Waybill","CancelE-Waybill","E-Transaction";
        }
        field(3; "Order No."; Code[20])
        {
            Editable = false;
        }
        field(4; "Invoice No."; Code[20])
        {
            Editable = false;
        }
        field(6; "Request Validated"; Boolean)
        {
        }

        field(10; "Cancel E-way"; Boolean)
        {
            Editable = false;
        }
        field(15; "Trans type"; Option)
        {
            OptionCaption = 'NEFT,IMPS,RTGS';
            OptionMembers = NEFT,IMPS,RTGS;
        }
        field(18; Remarks; Text[200])
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
        key(Key1; "Entry No.")
        {
        }
        // key(Key2; "Invoice No.")
        // {
        // }
    }
}
