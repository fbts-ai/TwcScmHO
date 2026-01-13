table 50007 WastageEntryHeader
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
                    NoSeriesMgt.TestManual(Invsetup.WastageEntryNo);

                end;

            end;
        }
        field(2; "Location Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Location Code';
            TableRelation = Location.Code;
        }

        field(3; "Posting date"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                //Message('Please check the Pending STN, GRN, ISTN, RSTN, Statement posting');
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

        field(7; Status; Enum Status_Wastage)
        {
            DataClassification = ToBeClassified;
            Caption = 'Status';
        }
        field(8; TotalWastageValue; Decimal)
        {
            Editable = false;
            Caption = 'TotalStockValue';
            FieldClass = FlowField;

            CalcFormula = sum("WastageEntryLine".Amount
            WHERE("DocumentNo." = Field("No."))
            );

        }
        field(9; RejectionRemark; Text[50])
        {
            //Editable = false;
            Caption = 'Rejection Remark';
        }
        field(10; ApproverID; Code[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'ApproverID';
        }
        field(11; Exploed; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Exploed';
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
    var
        tempusersetup: Record "User Setup";
    begin

        IF "No." = '' THEN BEGIN
            Invsetup.Get();
            Invsetup.TESTFIELD(WastageEntryNo);
            NoSeriesMgt.InitSeries(Invsetup.WastageEntryNo, '', 0D, "No.", Invsetup.WastageEntryNo);
        END;

        if tempusersetup.Get(UserId) then;

        IF tempusersetup.WastageEntryApprover = '' then
            Error('Please enter the approve id for the user in user setup');

        "Location Code" := tempusersetup."Location Code";

        "Posting date" := Today;
        CreatedBy := UserId;
        "Created Date" := WorkDate;
        Status := Status::Open;
        ApproverID := tempusersetup.WastageEntryApprover;

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





    procedure WastageEntryLineEditable() IsEditable: Boolean;
    begin
        IF Rec.Status = Rec.Status::Open then begin
            IsEditable := true;
        end
        else
            IsEditable := false;


    end;

    procedure AssistEdit(OldWastageentryHeader: Record WastageEntryHeader): Boolean
    var
        InventSetp: Record "Inventory Setup";
    begin

        InventSetp.get();

        InventSetp.TestField(InventSetp.WastageEntryNo);
        if NoSeriesMgt.SelectSeries(InventSetp.WastageEntryNo, '', InventSetp.WastageEntryNo) then begin

            NoSeriesMgt.SetSeries("No.");
            exit(true);
        end;
    end;


}