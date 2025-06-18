table 50149 "Consolidate indent Header"
{
    DataClassification = ToBeClassified;
    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                UserSetup: Record "User Setup";
            begin
                if "No." <> xRec."No." then begin
                    Invsetup.Get();
                    NoSeriesMgt.TestManual(Invsetup."Conslid.indent Nos.");
                end;
            end;
        }
        field(2; "Delivery Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(3; Post; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "No.")
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
        Invsetup: Record "Inventory Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;

    trigger OnInsert()
    begin
        IF "No." = '' THEN BEGIN
            Invsetup.Get();
            Invsetup.TESTFIELD("Conslid.indent Nos.");
            NoSeriesMgt.InitSeries(Invsetup."Conslid.indent Nos.", '', 0D, "No.", Invsetup."Conslid.indent Nos.");
        END;
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

}