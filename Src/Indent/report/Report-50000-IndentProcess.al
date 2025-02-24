report 50000 "Indent Process"
{
    // UsageCategory = ReportsAndAnalysis;
    //ApplicationArea = All;
    ProcessingOnly = true;


    dataset
    {

        dataitem(IndentHeader1; IndentHeader)
        {
            dataitem("Indent Mapping"; "Indent Mapping")
            {
                DataItemTableView = sorting("Source Location No.");
                DataItemLink = "Location Code" = field("To Location code");


                trigger OnPreDataItem()
                begin
                    // Clear(SourceLoc);
                end;

                trigger OnAfterGetRecord()
                begin
                    IndentLine.Reset();
                    IndentLine.SetRange("DocumentNo.", IndentHeader1."No.");
                    IndentLine.SetRange("Item Code", "Item No.");
                    IF IndentLine.FindFirst() then;



                    IF "Sourcing Method" = "Sourcing Method"::Transfer then begin
                        IF IndentLine."Item Code" = "Item No." then begin

                            IF SourceLoc <> "Source Location No." then begin
                                IndentHeader.Init();
                                IndentHeader.TransferFields(IndentHeader1);
                                IndentHeader."No." := '';
                                if IndentHeader1."Last Sub Indent No." = '' then
                                    IndentHeader."No." := IndentHeader1."No." + '-01'
                                else
                                    IndentHeader."No." := IncStr(IndentHeader1."Last Sub Indent No.");
                                IndentHeader."To Location Code" := IndentHeader1."To Location code";
                                IndentHeader."From Location code" := "Source Location No.";
                                IndentHeader."Main Indent No." := IndentHeader1."No.";
                                IndentHeader."Sub-Indent" := true;
                                IndentHeader.Status := IndentHeader.Status::Released;
                                IndentHeader.Insert();

                                IndentLine1.Init();

                                Indentline1.TransferFields(IndentLine);
                                IndentLine1."DocumentNo." := IndentHeader."No.";
                                IndentLine1."Location/StoreNo.To" := IndentHeader."To Location code";
                                ;
                                IndentLine1."Location/StoreNo.From" := IndentHeader."From Location Code";
                                IndentLine1."Sub-Indent" := true;
                                IndentLine1.Status := IndentLine1.Status::Released;
                                Indentline1.Insert();

                                IndentHeader1."Last Sub Indent No." := IndentHeader."No.";
                                IndentHeader1.Modify();
                                SourceLoc := "Source Location No.";
                            end
                            else begin
                                IndentLine2.Reset();
                                IndentLine2.SetRange("DocumentNo.", IndentHeader."No.");
                                IF IndentLine2.FindLast() then;
                                IndentLine1.Init();
                                Indentline1.TransferFields(IndentLine);
                                IndentLine1."DocumentNo." := IndentHeader."No.";
                                IndentLine1."LineNo." := IndentLine2."LineNo." + 10000;
                                IndentLine1."Location/StoreNo.To" := IndentHeader."To Location code";

                                IndentLine1."Location/StoreNo.From" := IndentHeader."From Location Code";
                                IndentLine1."Sub-Indent" := true;
                                IndentLine1.Status := IndentLine1.Status::Released;
                                Indentline1.Insert();
                            end;

                        end;
                    end
                    else
                        if ("Sourcing Method" = "Sourcing Method"::Purchase) then begin
                            IF IndentLine."Item Code" = "Item No." then begin
                                "Indent Mapping".TestField("Source Location No.");
                                IF SourceLoc <> "Source Location No." then begin
                                    IndentHeader.Init();
                                    IndentHeader.TransferFields(IndentHeader1);
                                    IndentHeader."No." := '';
                                    if IndentHeader1."Last Sub Indent No." = '' then
                                        IndentHeader."No." := IndentHeader1."No." + '-01'
                                    else
                                        IndentHeader."No." := IncStr(IndentHeader1."Last Sub Indent No.");
                                    IndentHeader."To Location Code" := IndentHeader1."To Location code";
                                    IndentHeader."From Location code" := "Source Location No.";
                                    IndentHeader."Main Indent No." := IndentHeader1."No.";
                                    IndentHeader."Sub-Indent" := true;
                                    IndentHeader.Insert();

                                    IndentLine1.Init();

                                    Indentline1.TransferFields(IndentLine);
                                    IndentLine1."DocumentNo." := IndentHeader."No.";
                                    IndentLine1."Location/StoreNo.To" := IndentHeader."To Location code";
                                    ;
                                    IndentLine1."Location/StoreNo.From" := IndentHeader."From Location Code";
                                    IndentLine1."Sub-Indent" := true;
                                    Indentline1.Insert();

                                    IndentHeader1."Last Sub Indent No." := IndentHeader."No.";
                                    IndentHeader1.Modify();
                                    SourceLoc := "Source Location No.";
                                end
                                else begin
                                    IndentLine2.Reset();
                                    IndentLine2.SetRange("DocumentNo.", IndentHeader."No.");
                                    IF IndentLine2.FindLast() then;
                                    IndentLine1.Init();
                                    Indentline1.TransferFields(IndentLine);
                                    IndentLine1."DocumentNo." := IndentHeader."No.";
                                    IndentLine1."LineNo." := IndentLine2."LineNo." + 10000;

                                    IndentLine1."Location/StoreNo.To" := IndentHeader."To Location code";

                                    IndentLine1."Location/StoreNo.From" := IndentHeader."From Location Code";
                                    IndentLine1."Sub-Indent" := true;
                                    Indentline1.Insert();
                                end;
                                IF VendNo <> "Indent Mapping"."Source Location No." then begin

                                    PurSetup.Get();
                                    purchHdr.Init();
                                    purchHdr.Validate("Document Type", purchHdr."Document Type"::Order);
                                    purchHdr.Validate("No.", noseriesmgt.GetNextNo(PurSetup."Order Nos.", WorkDate(), true));
                                    purchHdr.Insert();
                                    purchHdr.Validate("Buy-from Vendor No.", "Indent Mapping"."Source Location No.");
                                    purchHdr.Validate("Location Code", "Indent Mapping"."Location Code");
                                    // purchHdr.Validate("Shortcut Dimension 1 Code", IndentHeader1.DepartmentCode);
                                    purchHdr.Validate("Indent No.", IndentHeader1."No.");
                                    purchHdr.Validate("Document Date", Today);
                                    purchHdr.Validate("Order Date", IndentHeader1."Posting date");
                                    purchHdr.Modify();

                                    purchLine.Init();
                                    purchLine.Validate("Document Type", purchHdr."Document Type");
                                    purchLine.Validate("Document No.", purchHdr."No.");
                                    purchLine.Validate("Line No.", 10000);
                                    purchLine.Validate(Type, purchLine.Type::Item);
                                    purchLine.Validate("No.", IndentLine."Item Code");
                                    purchLine.Insert(); //AJ_ALLE_15122023
                                    IF Item.Get(IndentLine."Item Code") then;

                                    ItemUOM.Reset();
                                    ItemUOM.SetRange("Item No.", Item."No.");
                                    ItemUOM.SetRange(Code, Item."Purch. Unit of Measure");
                                    IF ItemUOM.FindFirst() then;

                                    IndentLine.CalcFields(UOM);
                                    IndentLine.CalcFields("Item UOM Qty.of measure");
                                    //  purchline.validate("Unit of Measure Code", IndentLine.UOM);
                                    IF ItemUOM."Qty. per Unit of Measure" <> 0 then
                                        purchLine.Validate(Quantity, (IndentLine.Quantity * IndentLine."Item UOM Qty.of measure") / ItemUOM."Qty. per Unit of Measure")
                                    else
                                        purchLine.Validate(Quantity, (IndentLine.Quantity * IndentLine."Item UOM Qty.of measure") / ItemUOM."Qty. per Unit of Measure");

                                    purchLine.Validate("Location Code", purchHdr."Location Code");
                                    purchHdr.Validate("Document Date", Today);
                                    // purchLine.Validate("Shortcut Dimension 1 Code", purchHdr."Shortcut Dimension 1 Code");
                                    //purchLine.Insert(); //AJ_ALLE_15122023
                                    purchLine.Modify();//AJ_ALLE_15122023
                                    VendNo := "Indent Mapping"."Source Location No.";
                                    PONo2.Add(purchHdr."No.");
                                end
                                else begin
                                    purchLine1.Reset();
                                    purchLine1.SetRange("Document Type", purchHdr."Document Type");
                                    purchLine1.SetRange("Document No.", purchHdr."No.");
                                    if purchLine1.FindLast() then;

                                    purchLine.Init();
                                    purchLine.Validate("Document Type", purchHdr."Document Type");
                                    purchLine.Validate("Document No.", purchHdr."No.");
                                    purchLine.Validate("Line No.", purchLine1."Line No." + 10000);
                                    purchLine.Validate(Type, purchLine.Type::Item);
                                    purchLine.Validate("No.", IndentLine."Item Code");
                                    purchLine.Insert();//AJ_ALLE_15122023
                                    IF Item.Get(IndentLine."Item Code") then;


                                    IndentLine.CalcFields("Item UOM Qty.of measure");
                                    ItemUOM.Reset();
                                    ItemUOM.SetRange("Item No.", Item."No.");
                                    ItemUOM.SetRange(Code, Item."Purch. Unit of Measure");
                                    IF ItemUOM.FindFirst() then;

                                    IF ItemUOM."Qty. per Unit of Measure" <> 0 then
                                        purchLine.Validate(Quantity, (IndentLine.Quantity * IndentLine."Item UOM Qty.of measure") / ItemUOM."Qty. per Unit of Measure")
                                    else
                                        purchLine.Validate(Quantity, (IndentLine.Quantity * IndentLine."Item UOM Qty.of measure") / ItemUOM."Qty. per Unit of Measure");


                                    //                                    purchLine.Validate(Quantity, IndentLine.Quantity);
                                    IndentLine.CalcFields(UOM);
                                    // purchline.validate("Unit of Measure Code", IndentLine.UOM);
                                    purchLine.Validate("Location Code", purchHdr."Location Code");
                                    purchLine.Validate("Shortcut Dimension 1 Code", purchHdr."Shortcut Dimension 1 Code");
                                    //purchLine.Insert();
                                    purchLine.Modify();//AJ_ALLE_15122023
                                end;

                                purchHdr1.Reset();
                                purchHdr1.SetRange("No.", purchHdr."No.");
                                IF purchHdr1.FindFirst() then begin
                                    purchHdr1.Validate(Status, purchHdr1.Status::Released);
                                    purchHdr1.Modify(true);
                                    // SendMail(purchHdr);
                                end;





                            end;

                        end;
                    IndentHeader1.Status := IndentHeader1.Status::Released;
                    IndentHeader1.Validate(Status);
                    IndentHeader1.Modify();
                    //IndentLine."Purchase Order No." := purchHdr."No.";
                    //IndentLine.Status := IndentLine.Status::Release;
                    // IndentLine.Modify();
                end;


            }
            trigger OnPreDataItem()
            begin

                Clear(PONO1);
                Clear(PONo2);
            end;

        }

    }

    trigger OnPostReport()
    var
        myInt: Integer;
    begin

        foreach POno1 in pono2 do begin
            SendMail(PONO1);
        end;
        Message('Indent Processed');
    end;

    local procedure CreateSubIndent(var IndentHeader1: Record IndentHeader; indentline: Record Indentline; indentmapp: Record "Indent Mapping")
    var
        sourceloc: Code[20];
        IndentHeader: Record IndentHeader;
        IndentLine1: Record Indentline;
        IndentLine2: Record Indentline;
    begin
        IF SourceLoc <> indentmapp."Source Location No." then begin
            IndentHeader.Init();
            IndentHeader.TransferFields(IndentHeader1);
            IndentHeader."No." := '';
            if IndentHeader1."Last Sub Indent No." = '' then
                IndentHeader."No." := IndentHeader1."No." + '-01'
            else
                IndentHeader."No." := IncStr(IndentHeader1."Last Sub Indent No.");
            IndentHeader."To Location Code" := IndentHeader1."To Location code";
            IndentHeader."From Location code" := indentmapp."Source Location No.";
            IndentHeader."Main Indent No." := IndentHeader1."No.";
            IndentHeader."Sub-Indent" := true;
            IndentHeader.Insert();

            IndentLine1.Init();

            Indentline1.TransferFields(IndentLine);
            IndentLine1."DocumentNo." := IndentHeader."No.";
            IndentLine1."Location/StoreNo.To" := IndentHeader."To Location code";
            ;
            IndentLine1."Location/StoreNo.From" := IndentHeader."From Location Code";
            IndentLine1."Sub-Indent" := true;
            Indentline1.Insert();

            IndentHeader1."Last Sub Indent No." := IndentHeader."No.";
            IndentHeader1.Modify();
            SourceLoc := indentmapp."Source Location No.";
        end
        else begin
            IndentLine2.Reset();
            IndentLine2.SetRange("DocumentNo.", IndentHeader."No.");
            IF IndentLine2.FindLast() then;
            IndentLine1.Init();
            Indentline1.TransferFields(IndentLine);
            IndentLine1."DocumentNo." := IndentHeader."No.";
            IndentLine1."LineNo." := IndentLine2."LineNo." + 10000;
            IndentLine1."Location/StoreNo.To" := IndentHeader."To Location code";

            IndentLine1."Location/StoreNo.From" := IndentHeader."From Location Code";
            IndentLine1."Sub-Indent" := true;
            Indentline1.Insert();
        end;
    end;

    local procedure CreatePO(var IndentHeader1: Record IndentHeader; indentline: Record Indentline; indentmapp: Record "Indent Mapping")
    var
        VendNo: Code[30];
        purchHdr: Record "Purchase Header";
        purchLine: Record "Purchase Line";
        purchLine1: Record "Purchase Line";
        PurSetup: Record "Purchases & Payables Setup";
        noseriesmgt: Codeunit NoSeriesManagement;
        purchHdr1: Record "Purchase Header";
    begin
        IF VendNo <> "Indent Mapping"."Source Location No." then begin
            PurSetup.Get();
            purchHdr.Init();
            purchHdr.Validate("Document Type", purchHdr."Document Type"::Order);
            purchHdr.Validate("No.", noseriesmgt.GetNextNo(PurSetup."Order Nos.", WorkDate(), true));
            purchHdr.Validate("Buy-from Vendor No.", "Indent Mapping"."Source Location No.");
            purchHdr.Validate("Location Code", "Indent Mapping"."Location Code");
            // purchHdr.Validate("Shortcut Dimension 1 Code", IndentHeader1.DepartmentCode);
            purchHdr.Validate("Indent No.", IndentHeader1."No.");
            purchHdr.Validate("Document Date", Today);
            purchHdr.Insert();

            purchLine.Init();
            purchLine.Validate("Document Type", purchHdr."Document Type");
            purchLine.Validate("Document No.", purchHdr."No.");
            purchLine.Validate("Line No.", 10000);
            purchLine.Validate(Type, purchLine.Type::Item);
            purchLine.Validate("No.", IndentLine."Item Code");
            purchLine.Validate(Quantity, IndentLine.Quantity);
            purchLine.Validate("Location Code", purchHdr."Location Code");
            // purchLine.Validate("Shortcut Dimension 1 Code", purchHdr."Shortcut Dimension 1 Code");
            purchLine.Insert();
            VendNo := "Indent Mapping"."Source Location No.";

        end
        else begin
            purchLine1.Reset();
            purchLine1.SetRange("Document Type", purchHdr."Document Type");
            purchLine1.SetRange("Document No.", purchHdr."No.");
            if purchLine1.FindLast() then;

            purchLine.Init();
            purchLine.Validate("Document Type", purchHdr."Document Type");
            purchLine.Validate("Document No.", purchHdr."No.");
            purchLine.Validate("Line No.", purchLine1."Line No." + 10000);
            purchLine.Validate(Type, purchLine.Type::Item);
            purchLine.Validate("No.", IndentLine."Item Code");
            purchLine.Validate(Quantity, IndentLine.Quantity);
            purchLine.Validate("Location Code", purchHdr."Location Code");
            purchLine.Validate("Shortcut Dimension 1 Code", purchHdr."Shortcut Dimension 1 Code");
            purchLine.Insert();
        end;

    end;

    procedure SendMail(PurchHead: Code[30])
    var
        EmailCodeunit: Codeunit Email;
        Tempblob: Codeunit "Temp Blob";
        IsStream: InStream;
        OStream: OutStream;
        UserSetup: Record "User Setup";
        EmailMessage: Codeunit "Email Message";
        currentuser: Record "User Setup";
        MessageBody: Text;
        MailList: List of [text];
        RequestRunPage: text;

        RecRef: RecordRef;
        Subject: Text;
        SubIndentPO1: Record "Sub Indent PO";
        parma: Text;

        //Mahendra start
        TempPurchHead: Record "Purchase Header";
        IsStream1: InStream;
        OStream1: OutStream;
        TempReportSelection: Record "Report Selections";
        TempVend: Record Vendor;
        RecRefPurch: RecordRef;
    //Mahendra end

    begin
        // MailList.Add('neha.gupta78@in.ey.com'); mahendra
        Subject := 'Indent Purchase Order' + PurchHead + '';
        MessageBody := 'Hello, ' + '<br><br>' + 'You have received Indent PO ' + ' ' + 'from Heisetasse Beverages Pvt. Ltd.';
        MessageBody += '<br><br> Best Regards';


        //mahendra start
        Tempblob.CreateOutStream(OStream1);
        TempPurchHead.Reset();
        TempPurchHead.SetRange("No.", PurchHead);
        IF TempPurchHead.FindFirst() Then;

        RecRefPurch.GetTable(TempPurchHead);

        IF TempVend.get(TempPurchHead."Buy-from Vendor No.") then;
        // IF TempVend."E-Mail" = '' then
        //  Error('Please enter the email on Vendor card to send indent notification');



        TempReportSelection.Reset();
        TempReportSelection.SetRange(Usage, TempReportSelection.Usage::"P.Order");
        IF TempReportSelection.FindFirst() Then;

        Report.SaveAs(TempReportSelection."Report ID", TempPurchHead."No.", ReportFormat::Pdf, OStream1, RecRefPurch);
        Tempblob.CreateInStream(IsStream1);
        //Mahendra End
        IF TempVend."E-Mail" <> '' then //mahendra
        Begin

            //EmailMessage.Create(MailList, Subject, MessageBody, true); mahendra
            EmailMessage.Create(TempVend."E-Mail", Subject, MessageBody, true);
            //mahendra
            EmailMessage.AddAttachment('Purchase Order.pdf', 'PDF', IsStream1);

            EmailCodeunit.Send(EmailMessage);
        end
        Else
            Message('Indent email has not been send as no mail id is define on vendor Card %1', TempVend."No.");

    end;

    var
        IndentHeader: Record IndentHeader;
        IndentLine: Record Indentline;
        //  IndentHeader1: Record IndentHeader;
        IndentLine1: Record Indentline;
        IndentLine2: Record Indentline;
        SourceLoc: Code[30];
        VendNo: Code[30];
        PONo2: List of [Code[30]];
        PONO: Code[1000];
        PONO1: Code[1000];

        purchHdr: Record "Purchase Header";
        purchHdr1: Record "Purchase Header";
        purchLine: Record "Purchase Line";
        purchLine1: Record "Purchase Line";
        PurSetup: Record "Purchases & Payables Setup";
        noseriesmgt: Codeunit NoSeriesManagement;
        Item: Record Item;
        ItemUOM: Record "Item Unit of Measure";
}