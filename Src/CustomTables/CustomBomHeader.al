table 50145 "Custom BOM_Header"
{
    DataClassification = ToBeClassified;
    fields
    {
        field(1; "BOM Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            trigger OnValidate()
            var
                UserSetup: Record "User Setup";
            begin
                if "BOM Code" <> xRec."BOM Code" then begin
                    Invsetup.Get();
                    NoSeriesMgt.TestManual(Invsetup."Custom Bom Nos");
                end;
            end;
        }
        field(2; "Custom BOM Group"; Code[10])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                CustBomHeader: Record "Custom BOM_Header";
            begin
                CustBomHeader.Reset();
                CustBomHeader.SetRange("Custom BOM Group", Rec."Custom BOM Group");
                CustBomHeader.SetRange("Parent Item No.", Rec."Parent Item No.");
                IF CustBomHeader.FindFirst() then
                    Error('already exists');
            end;
        }
        field(3; "BOM Status"; Option)
        {
            OptionMembers = "",Draft,Trial,Approved;
        }
        field(4; "Parent Item No."; Code[10]) //Child ItemNo.
        {
            DataClassification = ToBeClassified;
            TableRelation = Item;
            trigger OnValidate()
            var
                CustBomHeader: Record "Custom BOM_Header";
            begin
                CustBomHeader.Reset();
                CustBomHeader.SetRange("Custom BOM Group", Rec."Custom BOM Group");
                CustBomHeader.SetRange("Parent Item No.", Rec."Parent Item No.");
                IF CustBomHeader.FindFirst() then
                    Error('already exists');
            end;
        }
        field(5; "Parent Item Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            // TableRelation = Item.Description where("No." = field("Parent Item No."));
        }

    }
    keys
    {
        key(Key1; "BOM Code", "Custom BOM Group", "Parent Item No.")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        // Add changes to field groups here
    }
    var
        Invsetup: Record 313;
        NoSeriesMgt: Codeunit 396;
        CustomLine: Record "Custom BOM Line";

    trigger OnInsert()
    begin
        IF "BOM Code" = '' THEN BEGIN
            Invsetup.Get();
            Invsetup.TESTFIELD(StockAuditNo);
            NoSeriesMgt.InitSeries(Invsetup."Custom Bom Nos", '', 0D, "BOM Code", Invsetup."Custom Bom Nos");
        END;
    end;

    trigger OnModify()
    begin
    end;

    trigger OnDelete()
    begin
        CustomLine.Reset();
        CustomLine.SetRange("BOM Code", Rec."BOM Code");
        if FindFirst() then begin
            CustomLine.DeleteAll();
        end;
    end;

    trigger OnRename()
    begin
    end;

}