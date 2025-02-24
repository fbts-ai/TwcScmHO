table 50010 StockAuditHeader
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
                    NoSeriesMgt.TestManual(Invsetup.StockAuditNo);

                end;

            end;
        }
        field(2; "Location Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Location Code';
            TableRelation = Location.Code;
            Editable = false;
        }

        field(3; "Posting date"; Date)
        {
            DataClassification = ToBeClassified;
            trigger OnValidate() //PT-FBTS 09-07-2024
            var
                StockAudit: Record StockAuditHeader;
            begin
                StockAudit.Reset();
                StockAudit.SetRange("Location Code", Rec."Location Code");
                StockAudit.SetRange("Posting date", rec."Posting date");
                if StockAudit.FindLast() then begin
                    if Rec."Posting date" = StockAudit."Posting date" then
                        Error('Physical Counting Already created');
                    // if Rec."Posting date" < StockAudit."Created Date" - 1 then
                    //     Error('BackDate is not allow');  
                end;
                if Rec."Posting date" > Today then
                    Error('Future posting date not allowed');
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


        field(7; Status; Enum Status_StockAudit)
        {
            DataClassification = ToBeClassified;
            Caption = 'Status';
        }
        field(8; TotalStockValue; Decimal)
        {
            Caption = 'TotalStockValue';
            FieldClass = FlowField;

            CalcFormula = sum("StockAuditLine".Amount
            WHERE("DocumentNo." = Field("No."))
            );

        }
        field(9; ApproverID; Code[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'ApproverID';
        }
        field(10; RejectionRemark; Text[50])
        {
            //Editable = false;
            Caption = 'Rejection Remark';

        }
        field(11; OfflineSales; Boolean)
        {
            Caption = 'Offline Sales';
        }
        field(12; "Inventory Type"; Option)//PT-FBTS 16-10-24
        {
            OptionMembers = " ",Daily,WEEKLEY,MONTHLY,QUARTERLY;
        }
        field(13; "Sand Date&Time"; DateTime)//PT-FBTS 16-10-24
        {
            DataClassification = CustomerContent;
            Caption = 'Send Date & Time'; //Aashish-12092024
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
        tempStockAuditHeader: Record StockAuditHeader; //PT-FBTS 09-07-2024
                                                       //////////////////////// //PT-FBTS PT-FBTS 16-10-24
        RetailCalendarManagement: Codeunit "LSC Retail Calendar Management";
        RetailCalendar: Record "LSC Retail Calendar";
        Times: Time;
        Date_: Date;
        insetDate: Date;
    //////////////////////// /PT-FBTS 16-10-24
    begin

        IF "No." = '' THEN BEGIN
            Invsetup.Get();
            Invsetup.TESTFIELD(StockAuditNo);
            NoSeriesMgt.InitSeries(Invsetup.StockAuditNo, '', 0D, "No.", Invsetup.StockAuditNo);
        END;
        if tempusersetup.Get(UserId) then;
        IF Not Rec.OfflineSales Then
            IF tempusersetup.StockAuditApprover = '' then
                Error('Please enter the approve id for the user in user setup');
        "Location Code" := tempusersetup."Location Code";

        CreatedBy := UserId;

        //"Posting date" := today;
        //////////////////////////// //PT-FBTS 16-10-24
        Times := time;
        Date_ := Today;
        insetDate := RetailCalendarManagement.GetStoreTransactionDate
         (Rec."Location Code", RetailCalendar."Calendar Type"::"Opening Hours", Date_, Times);
        Rec.Validate("Posting date", insetDate);
        ///////////////////////////////PT-FBTS-PT-FBTS 16-10-24
        "Created Date" := WorkDate;
        Status := Status::Open;
        ApproverID := tempusersetup.StockAuditApprover;

        //////////////////////////////// //PT-FBTS 09-07-2024
        tempStockAuditHeader.Reset();
        tempStockAuditHeader.SetRange("Location Code", tempusersetup."Location Code");
        tempStockAuditHeader.SetRange("Posting date", Today);
        if tempStockAuditHeader.Findlast() then begin
            if Today = tempStockAuditHeader."Posting date" then
                Error('Physical Counting Already created');
        end;
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

    procedure AssistEdit(OldStockAuditHeader: Record StockAuditHeader): Boolean
    var
        InventSetp: Record "Inventory Setup";
    begin

        InventSetp.get();

        InventSetp.TestField(InventSetp.StockAuditNo);
        if NoSeriesMgt.SelectSeries(InventSetp.StockAuditNo, '', InventSetp.StockAuditNo) then begin

            NoSeriesMgt.SetSeries("No.");
            exit(true);
        end;
    end;

    procedure StockAuditLineEditable() IsEditable: Boolean;
    begin
        // IF Rec.Status = Rec.Status::Open then begin
        //     IsEditable := true;
        // end
        // else
        //     IsEditable := false;
        IF (Rec.Status = Rec.Status::Open) or (Rec.Status = Rec.Status::PendingApproval) then begin //PT-FBTS 150424
            IsEditable := true;
        end
        else
            IsEditable := false;


    end;


}