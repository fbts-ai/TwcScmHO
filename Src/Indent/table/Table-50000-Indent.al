table 50000 IndentHeader
{
    DataClassification = ToBeClassified;


    fields
    {
        field(1; "No."; Code[25])
        {
            DataClassification = ToBeClassified;
            Caption = 'No.';

            trigger OnValidate()
            var
                UserSetup: Record "User Setup";
            begin
                if "No." <> xRec."No." then begin
                    Invsetup.Get();
                    NoSeriesMgt.TestManual(Invsetup."Indent Nos.");
                    "No. Series" := '';
                end;

            end;
        }
        field(2; "From Location Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'From Location Code';
            TableRelation = Location.Code;
        }

        field(3; "Posting date"; Date)
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                InvSetup: Record "Inventory Setup";
                CalDate: Date;
            begin
                if Rec.Type = Rec.Type::Item then begin
                    Clear(CalDate);
                    InvSetup.Get();
                    IF Rec."Order Type" = Rec."Order Type"::Regular then begin
                        CalDate := CalcDate(InvSetup."Indent Delivery date Cal", Today);
                        IF xRec."Posting date" <> 0D then begin
                            //   IF xRec."Posting date" >= Rec."Posting date" then
                            //     Error('Delivery Date should not be less than current delivery date');
                            IF Rec."Posting date" < Today then
                                Error('Delivery Date should  be less than %1', Today);

                            IF Rec."Posting date" > CalDate then
                                Error('Delivery Date should  be greater than %1', CalDate);
                        end;
                    end;

                    IF Rec."Order Type" = Rec."Order Type"::Special then begin
                        CalDate := CalcDate(InvSetup."Indent Delivery date Cal", Today - 1);
                        IF xRec."Posting date" <> 0D then begin
                            //   IF xRec."Posting date" >= Rec."Posting date" then
                            //     Error('Delivery Date should not be less than current delivery date');
                            IF Rec."Posting date" < Today then
                                Error('Delivery Date should  be less than %1', Today);

                            IF Rec."Posting date" > CalDate then
                                Error('Delivery Date should  be greater than %1', CalDate);
                        end;
                    end;
                end;
            end;
        }
        field(4; "CreatedBy"; Code[50])
        {
            Caption = 'Created By';
            DataClassification = ToBeClassified;
        }
        field(5; "Created Date"; Date)
        {
            DataClassification = ToBeClassified;
        }

        field(6; "DepartmentCode"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code where("Dimension Code" = const('STORE'));
        }
        field(7; Status; Enum Status_indent)
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                IndentLine: Record Indentline;
            begin
                IndentLine.Reset();
                IndentLine.SetRange("DocumentNo.", rec."No.");
                IF IndentLine.FindFirst() then begin
                    IndentLine.Validate(Status, Rec.Status);
                    IndentLine.Modify();
                end;
            end;

        }

        field(10; "No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(12; "To Location code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
        }


        field(50018; "Category"; code[30])
        {

        }
        //AJ_A;lle_25012024
        field(50019; "Type"; Option)
        {
            //TodayFixedasset
            OptionMembers = " ",Item,"Fixed Asset";
            Editable = false;
        }
        // field(50019; "Type"; Option)
        // {
        //     //TodayFixedassetRemoved
        //     OptionMembers = " ",Item;
        //     Editable = false;
        // }
        //AJ_A;lle_25012024

        field(50023; Select; Boolean)
        {
            trigger OnValidate()
            var
                indentLine: Record Indentline;
            begin
                indentLine.Reset();
                indentLine.SetRange("DocumentNo.", "No.");
                if indentLine.FindSet() then
                    indentLine.ModifyAll(Select, Rec.Select);
            end;

        }
        field(50027; "To Location Name"; Text[100])
        {
            FieldClass = FlowField;

            CalcFormula = lookup(Location.Name where(Code = field("To Location code")));
        }
        field(50028; "From Location Name"; text[100])
        {
            FieldClass = FlowField;

            CalcFormula = lookup(Location.Name where(Code = field("From Location Code")));
        }
        field(50029; "Last Sub Indent No."; Code[30])
        {

        }
        field(50030; "Main Indent No."; Code[25])
        {

        }
        field(50031; "Sub-Indent"; Boolean)
        {

        }
        field(50032; "Purchase Order No."; Code[20])
        { }
        field(50033; "Transfer Order No."; Code[30])
        { }
        field(50034; "RPO No."; Code[20])
        { }
        field(50035; "Approval Required"; Boolean)
        { }
        field(50036; "Approved By"; Code[50])
        {
            TableRelation = User."User Name";
        }
        field(50037; "Submit Date"; Date)
        {

        }
        field(50038; "Submit Time"; Time)
        {

        }
        field(50039; "Reject Reason"; Text[50])
        { }
        field(50040; "Processed Date & time"; DateTime)
        { }
        field(50041; "Processed By"; Code[50])
        {
            TableRelation = User;
        }
        field(50042; "Approver Name"; Code[50])
        {
            TableRelation = User;
        }
        //AJ_ALLE_04122023
        field(50043; "For Bulk Indent"; Boolean)
        {
            DataClassification = ToBeClassified;
        }

        field(50045; "Created Transfer FA"; Boolean) //ALLE_RK_28NOV2023
        {
            DataClassification = ToBeClassified;
            Caption = 'Created Transfer FA';
        }
        //AJ_ALLE_04122023
        field(50046; "Approved/Reject"; DateTime) //PT-FBTS 03-07-2024
        {
            DataClassification = ToBeClassified;
            Caption = 'Approved/Reject';

        }
        field(50047; "Order Type"; Option) //PT-FBTS
        {
            OptionMembers = "Regular","Special";
            OptionCaption = 'Regular,Next day delivery';
            trigger OnValidate()
            var
                myInt: Integer;
                Indentline: Record Indentline;
            begin
                Indentline.Reset();
                Indentline.SetRange("DocumentNo.", Rec."No.");
                IF Indentline.FindSet() then begin
                    Error('You Can not changes');
                end;
                Invsetup.Get;
                IF Rec."Order Type" = Rec."Order Type"::Regular then
                    Rec."Posting date" := CalcDate(Invsetup."Indent Delivery date Cal", Today);

                IF Rec."Order Type" = Rec."Order Type"::Special then
                    Rec."Posting date" := CalcDate(Invsetup."Indent Delivery date Cal", Today - 1);
                Validate("Posting date");
            end;
        }
    }


    keys
    {
        key(pk; "No.")
        {
            Clustered = true;
        }
    }


    var
        myInt: Integer;
        Invsetup: Record 313;
        NoSeriesMgt: Codeunit 396;
        UserSetup: Record "User Setup";
        DefaultDim: Record "Default Dimension";
        GLSetup: Record "General Ledger Setup";

    var
        Location: Record Location;

    trigger OnInsert()
    begin
        IF "No." = '' THEN BEGIN
            Invsetup.Get();
            Invsetup.TESTFIELD("Indent Nos.");
            NoSeriesMgt.InitSeries(Invsetup."Indent Nos.", xRec."No. Series", 0D, "No.", "No. Series");
        END;
        CreatedBy := UserId;
        "Created Date" := WorkDate;
        Status := Status::Open;
        if UserSetup.get(UserId) then begin
            "To Location code" := UserSetup."Location Code";
            Validate("To Location code", UserSetup."Location Code");
            "Posting date" := CalcDate(Invsetup."Indent Delivery date Cal", Today);
            Validate("Posting date");
            // Type := Type::Item;
        end;


        GLSetup.Get();
        DefaultDim.Reset();
        DefaultDim.SetRange("Table ID", 14);
        DefaultDim.SetRange("No.", UserSetup."Location Code");
        DefaultDim.SetRange("Dimension Code", GLSetup."Global Dimension 1 Code");
        if DefaultDim.FindFirst() then begin
            DepartmentCode := DefaultDim."Dimension Value Code";
        end;

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin
        //AJ_Alle_04102023
        if (rec.Status = Rec.Status::Released) OR (rec.Status = Rec.Status::Processed) then //PT-FBTS 09-07-2024
            Error('Indent Is Released & can not be Deleted');
        //AJ_Alle_04102023
    end;

    trigger OnRename()
    begin

    end;

}