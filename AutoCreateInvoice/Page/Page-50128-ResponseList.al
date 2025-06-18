page 50128 "Response list"
{
    PageType = List;
    Caption = 'Response list';
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "Create Response Page";
    SourceTable = LogHeader;
    InsertAllowed = false;
    // ModifyAllowed = false;


    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(ID; Rec.ID)
                {
                    ApplicationArea = All;
                }
                field(REF; Rec.REF)
                {
                    ApplicationArea = All;
                    Caption = 'Vendor ID';
                }
                field(Select; Rec.Select)
                {
                    ApplicationArea = All;
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
                }
                field("Vendor Address"; Rec."Vendor Address")
                {
                    ApplicationArea = All;
                    Caption = ' Address';
                }
                field(Created; Rec.Created)
                {
                    ApplicationArea = All;
                }
                field(Posted; Rec.Posted)
                {
                    ApplicationArea = All;
                }
                field("Created Error"; Rec."Created Error")
                {
                    ApplicationArea = All;
                }
                field("Posted Error"; Rec."Posted Error")
                {
                    ApplicationArea = All;
                }
                field("Period From"; Rec."Period From")
                {
                    ApplicationArea = All;
                }
                field("Period To"; Rec."Period To")
                {
                    ApplicationArea = All;
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = All;
                }
                field("Invoice No."; Rec."Invoice No.")
                {
                    ApplicationArea = All;
                }
                field("Posted Invoice No."; Rec."Posted Invoice No.")
                {
                    ApplicationArea = All;
                }
            }
        }

    }

    actions
    {
        area(Processing)
        {
            action("Get Response")
            {
                ApplicationArea = All;
                Caption = 'Get Response';
                PromotedCategory = Process;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                Image = Refresh;

                trigger OnAction()
                var
                    DialogPage: Page "Date Range Dialog";
                    Dates: Dictionary of [Text, Date];
                    Cu: Codeunit "Global Codeunit";
                begin
                    ShowDateDialog;
                end;
            }
            action("Create Purchase Invoice")
            {
                ApplicationArea = All;
                Caption = 'Create Purchase Invoice';
                PromotedCategory = Process;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                Image = CreateDocuments;

                trigger OnAction()
                var
                    Glb_Cu: Codeunit "Global Codeunit";
                    Log_Header: Record LogHeader;
                begin
                    Log_Header.Reset();
                    Log_Header.SetCurrentKey(ID);
                    Log_Header.SetRange(Select, true);
                    CurrPage.SetSelectionFilter(Log_Header);
                    if Log_Header.FindSet() then begin
                        ProcesstoCreatePurchaseInvoice();
                    end;

                end;
            }
            action("Posted Purchase Invoice")
            {
                ApplicationArea = All;
                Caption = 'Posted Purchase Invoice';
                PromotedCategory = Process;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                Image = PostDocument;

                trigger OnAction()
                var
                    Glb_Cu: Codeunit "Global Codeunit";
                    Log_Header: Record LogHeader;
                begin
                    Log_Header.Reset();
                    Log_Header.SetCurrentKey(ID);
                    Log_Header.SetRange(Select, true);
                    Log_Header.SetRange(Created, true);
                    Log_Header.SetRange(Posted, false);
                    Log_Header.SetFilter("Invoice No.", '<>%1', '');
                    CurrPage.SetSelectionFilter(Log_Header);
                    if Log_Header.FindSet() then begin
                        ProcesstoPostPurchaseInvoice();
                    end;

                end;
            }

        }
    }
    var
        Window: Dialog;


    procedure ProcesstoCreatePurchaseInvoice()
    var
        Text001: label 'TO Creating  #1##########';
        Log_Header: Record LogHeader;
        Log_Header2: Record LogHeader;
        NoSeriesLine: Record "No. Series Line";
        LastNo: Code[20];
        createdPurchInvoice: Codeunit "Create Purchase Invoice";
        NoSeriesCode: Code[50];
    begin
        if GuiAllowed then
            Window.Open(Text001);

        CurrPage.SetSelectionFilter(Log_Header);

        Log_Header.Reset();
        Log_Header.SetCurrentKey(ID);
        // Log_Header.SetRange(Error, false);/
        Log_Header.SetRange(Created, false);
        Log_Header.SetRange(Select, true);
        if Log_Header.FindSet() then
            repeat
                Commit();
                ClearLastError();

                if GuiAllowed then Window.Update(1, Log_Header.ID);
                Log_Header2.Reset;
                Log_Header2.SetRange(ID, Log_Header.ID);
                if Log_Header2.FindSet then
                    if not createdPurchInvoice.Run(Log_Header2) then begin
                        createdPurchInvoice.GetFieldsValue(NoSeriesCode);
                        Log_Header2."Error" := true;
                        Log_Header2."Created Error" := CopyStr(GetLastErrorText, 1, 250);
                        Log_Header2.Modify();
                    end;
            UNTIl Log_Header.Next() = 0;
    end;

    procedure ProcesstoPostPurchaseInvoice()
    var
        Text001: label 'TO Creating  #1##########';
        Log_Header: Record LogHeader;
        Log_Header2: Record LogHeader;
        NoSeriesLine: Record "No. Series Line";
        LastNo: Code[20];
        PostedPurchInvoice: Codeunit "Post Purchase Invoice";
        NoSeriesCode: Code[50];
    begin
        if GuiAllowed then
            Window.Open(Text001);

        CurrPage.SetSelectionFilter(Log_Header);

        Log_Header.Reset();
        Log_Header.SetCurrentKey(ID);
        Log_Header.SetRange(posted, false);
        Log_Header.SetRange(Created, true);
        Log_Header.SetRange(Select, true);
        if Log_Header.FindSet() then
            repeat
                Commit();
                ClearLastError();

                if GuiAllowed then Window.Update(1, Log_Header.ID);
                Log_Header2.Reset;
                Log_Header2.SetRange(ID, Log_Header.ID);
                if Log_Header2.FindSet then
                    if not PostedPurchInvoice.Run(Log_Header2) then begin
                        Log_Header2."Posted Error" := CopyStr(GetLastErrorText, 1, 250);
                        Log_Header2.Modify();
                    end;
            UNTIl Log_Header.Next() = 0;
    end;

    trigger OnDeleteRecord(): Boolean
    var
        myInt: Integer;
        logheader: record LogHeader;
        logline: record LogLine;
    begin
        CurrPage.SetSelectionFilter(logheader);
        logline.Reset();
        logline.SetRange(ID, logheader.ID);
        if logline.FindSet() then
            repeat
                logline.Delete();
            until logline.Next() = 0;
    end;

    procedure ShowDateDialog()
    var
        DateDialog: Page "Date Range Dialog";
        Dates: Dictionary of [Text, Date];
        VendorBillAPI: Codeunit "Global Codeunit";
        Result: Action;
        // Dates: Dictionary of [Text, Date];
        StartDate: Date;
        EndDate: Date;
    begin
        if DateDialog.RunModal() = Action::OK then begin
            Dates := DateDialog.GetDates();
            VendorBillAPI.GetApiDetails(Dates.Get('StartDate'), Dates.Get('EndDate'));
        end;
    end;


    var
        pur: Page "Purchase Order List";
}