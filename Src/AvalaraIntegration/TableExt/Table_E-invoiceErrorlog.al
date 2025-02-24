table 50068 EINV_LogEntry
{
    DataClassification = ToBeClassified;


    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;

        }
        field(2; "Document Type"; Option)
        {
            DataClassification = ToBeClassified;
            // Caption = 'Status';
            OptionCaption = 'Invoice,Credit Memo,Transfer,Transfer Cancel';
            OptionMembers = Invoice,"Credit Memo",Transfer,"Transfer Cancel";
        }
        field(3; "Document No."; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(4; Message; Text[450])
        {
            DataClassification = ToBeClassified;
        }
        field(5; Message1; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(6; Message2; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(7; Message3; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Creation DateTime"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Entry Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Einvoice,Eway';
            OptionMembers = ,Einvoice,Eway;
        }

    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
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
    begin

    end;

    trigger OnRename()
    begin

    end;

    procedure GetErrorMessage(): Text
    begin
        //  EXIT(Message + Message1 + Message2 + Message3);
    end;



}