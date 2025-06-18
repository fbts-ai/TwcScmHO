table 50040 LogHeader
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; ID; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "bill_reference"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Vendor Name"; Text[200])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Vendor Address"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "PIN"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "GST"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Period From"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Period To"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Bill Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Due Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Place of Supply"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Store Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Untaxed Amont"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(14; "GST Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Invoice Total"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(16; "currency"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Payment State"; Text[20])
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Status"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(19; "tds_bill_level_Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(20; "tds_bill_level_Description"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(21; "Vendor_ID"; code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(22; "REF"; code[250])
        {
            DataClassification = ToBeClassified;
        }
        field(23; "Created Error"; Text[2000])
        {
            DataClassification = ToBeClassified;
        }
        field(24; "Created"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(25; "Error"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(26; Select; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(27; "Invoice No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(28; Posted; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(29; "Posted Error"; Text[2000])
        {
            DataClassification = ToBeClassified;
        }
        field(30; "Posted Invoice No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }

    }

    keys
    {
        key(Key1; ID, bill_reference)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    var
        logline: Record LogLine;
    begin
        logline.Reset();
        logline.SetRange(ID, Rec.ID);
        if logline.FindSet() then
            repeat
                logline.Delete();
            until logline.Next() = 0;
    end;

    trigger OnRename()
    begin

    end;

}