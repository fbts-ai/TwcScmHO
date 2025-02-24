report 50001 "Create Consolidation Orders"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;
    UseRequestPage = false;

    dataset
    {
        dataitem(IndentLine; IndentLine)
        {
            //DataItemTableView = where("Sub-Indent" = const(true), Select = const(true));
            DataItemTableView = sorting("Source Loc") where(Select = const(true), "Sub-Indent" = const(true));

            dataitem("Indent Mapping"; "Indent Mapping")
            {
                DataItemTableView = sorting("Source Location No.");
                DataItemLink = "Location Code" = field("Location/StoreNo.From"), "Item No." = field("Item Code");

                trigger OnAfterGetRecord()
                begin
                    IndentLine.CalcFields("Source Loc");
                    IndentLine.SetAscending("Source Loc", true);
                    Clear(totalqty);
                    indentline1.Reset();
                    indentline1.SetRange("Item Code", "Item No.");
                    indentline1.SetRange(Select, true);
                    indentline1.SetRange("Sub-Indent", true);
                    indentline1.SetRange("Location/StoreNo.From", usersetup."Location Code");
                    IF indentline1.FindSet() then
                        repeat

                            //IndentLine1.CalcSums(Quantity);
                            totalqty += IndentLine1.Quantity;
                            indentline1.Select := false;
                            indentline1.Status := indentline1.Status::Processed;
                            indentline1.Modify();
                        until indentline1.Next() = 0;


                    //  IndentLine.SetAscending("Item Code", true);

                    // IF IndentLine.Select then begin
                    IF "Sourcing Method" = "Sourcing Method"::Purchase then begin
                        IF IndentLine."Item Code" = "Item No." then begin
                            "Indent Mapping".TestField("Source Location No.");
                            IF (SourceLoc <> "Indent Mapping"."Source Location No.") then begin



                                PurSetup.Get();
                                purchHdr.Init();
                                purchHdr.Validate("Document Type", purchHdr."Document Type"::Order);
                                purchHdr.Validate("No.", noseriesmgt.GetNextNo(PurSetup."Order Nos.", WorkDate(), true));
                                purchHdr.Insert(true);
                                purchHdr.Validate("Buy-from Vendor No.", "Indent Mapping"."Source Location No.");
                                purchHdr.Validate("Location Code", IndentLine."Location/StoreNo.From");
                                purchHdr.Validate("Indent No.", IndentLine."DocumentNo.");
                                // purchHdr.Validate("Shortcut Dimension 1 Code", IndentHeader1.DepartmentCode);
                                purchHdr.Validate("Indent No.", IndentLine."DocumentNo.");
                                purchHdr.Validate("Document Date", Today);
                                purchHdr.Validate("Order Date", IndentLine."Request Delivery Date");

                                purchHdr.Modify();

                                purchLine.Init();
                                purchLine.Validate("Document Type", purchHdr."Document Type");
                                purchLine.Validate("Document No.", purchHdr."No.");
                                purchLine.Validate("Line No.", 10000);
                                purchLine.Validate(Type, purchLine.Type::Item);
                                purchLine.Validate("No.", IndentLine."Item Code");
                                purchLine.Insert(); //AJ_ALLE_15122023
                                IF Item.Get(IndentLine."Item Code") then;


                                IndentLine.CalcFields("Item UOM Qty.of measure");
                                ItemUOM.Reset();
                                ItemUOM.SetRange("Item No.", Item."No.");
                                ItemUOM.SetRange(Code, Item."Purch. Unit of Measure");
                                IF ItemUOM.FindFirst() then;

                                IF ItemUOM."Qty. per Unit of Measure" <> 0 then
                                    purchLine.Validate(Quantity, (totalqty * IndentLine."Item UOM Qty.of measure") / ItemUOM."Qty. per Unit of Measure")
                                else
                                    purchLine.Validate(Quantity, (totalqty * IndentLine."Item UOM Qty.of measure") / ItemUOM."Qty. per Unit of Measure");

                                //                                purchLine.Validate(Quantity, totalqty);
                                purchLine.Validate("Location Code", purchHdr."Location Code");

                                // purchLine.Validate("Shortcut Dimension 1 Code", purchHdr."Shortcut Dimension 1 Code");

                                //purchLine.Insert();Commente AJ_ALLE_15122023
                                purchLine.Modify();//AJ_ALLE_15122023
                                InitSubindentPOLIST(purchLine, purchHdr, IndentLine);
                                SourceLoc := "Indent Mapping"."Source Location No.";
                                //   PONO += purchHdr."No." + '|';

                                PONo2.Add(purchHdr."No.");
                                Itemno := "Indent Mapping"."Item No.";

                                indentHdr.Reset();
                                indentHdr.SetRange("No.", IndentLine."DocumentNo.");
                                if indentHdr.FindFirst() then begin
                                    indentHdr."Purchase Order No." := purchHdr."No.";
                                    indentHdr.Status := indentHdr.Status::Processed;
                                    indentHdr.Validate(Status);
                                    //indentHdr.Validate(Select, false);
                                    indentHdr.Modify();
                                end;

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
                                IndentLine.CalcFields("Item UOM Qty.of measure");
                                IF Item.Get(IndentLine."Item Code") then;

                                ItemUOM.Reset();
                                ItemUOM.SetRange("Item No.", Item."No.");
                                ItemUOM.SetRange(Code, Item."Purch. Unit of Measure");
                                IF ItemUOM.FindFirst() then;

                                IF ItemUOM."Qty. per Unit of Measure" <> 0 then
                                    purchLine.Validate(Quantity, (totalqty * IndentLine."Item UOM Qty.of measure") / ItemUOM."Qty. per Unit of Measure")
                                else
                                    purchLine.Validate(Quantity, (totalqty * IndentLine."Item UOM Qty.of measure") / ItemUOM."Qty. per Unit of Measure");

                                purchLine.Validate("Location Code", purchHdr."Location Code");
                                IndentLine.CalcFields(UOM);
                                //  purchline.validate("Unit of Measure Code", IndentLine.UOM);
                                purchLine.Validate("Shortcut Dimension 1 Code", purchHdr."Shortcut Dimension 1 Code");

                                // purchLine.Insert();//AJ_ALLE_15122023
                                purchLine.Modify(); //AJ_ALLE_15122023
                                Itemno := "Indent Mapping"."Item No.";
                                InitSubindentPOLIST(purchLine, purchHdr, IndentLine);
                            end;
                            PurHdr.Reset();
                            PurHdr.SetRange("No.", purchHdr."No.");
                            IF PurHdr.FindFirst() then begin
                                purHdr.Validate(Status, PurHdr.Status::Released);
                                PurHdr.Modify(true);

                                /*
                                                                subindentPO.Reset();
                                                                subindentPO.SetRange("PO NO.", purHdr."No.");
                                                                IF subindentPO.FindFirst() then
                                                                    SendMail(SubIndentPO);
                                                                    */
                                //end;
                                //  end;
                            end;



                        end;


                        // end;


                    end
                    else
                        if ("Sourcing Method" = "Sourcing Method"::Production) then begin
                            IF IndentLine."Item Code" = "Item No." then begin
                                ManufSetup.Get();
                                Prodorder.Init();
                                Prodorder.Validate(Status, Prodorder.Status::Released);
                                Prodorder.Validate("No.", noseriesmgt.GetNextNo(ManufSetup."Released Order Nos.", WorkDate(), true));
                                Prodorder.Validate("Source Type", Prodorder."Source Type"::Item);
                                Prodorder.Validate("Source No.", "Item No.");

                                IndentLine.CalcFields("Item UOM Qty.of measure");

                                Prodorder.Validate(Quantity, totalqty * IndentLine."Item UOM Qty.of measure");
                                Prodorder.Validate("Location Code", IndentLine."Location/StoreNo.From");

                                Prodorder.Insert();

                                ProdOrder1.Reset();
                                ProdOrder1.SetRange(Status, Prodorder.Status);
                                ProdOrder1.SetRange("No.", ProdOrder."No.");
                                IF ProdOrder1.FindFirst() then begin
                                    Prodorder1.Validate("Starting Date-Time", CurrentDateTime);
                                    Prodorder1.Validate("Due Date", Today);
                                    ProdOrder1.Modify();
                                    Commit();
                                    REPORT.RunModal(REPORT::"Refresh Production Order", false, false, ProdOrder1);
                                end;
                                indentHdr.Reset();
                                indentHdr.SetRange("No.", IndentLine."DocumentNo.");
                                if indentHdr.FindFirst() then begin
                                    indentHdr."RPO No." := Prodorder."No.";
                                    indentHdr.Status := indentHdr.Status::Processed;
                                    indentHdr.Validate(Status);
                                    //   indentHdr.Validate(Select, false);
                                    indentHdr.Modify();

                                end;
                            end;
                        end
                        else
                            if (("Sourcing Method" = "Sourcing Method"::Transfer) AND ("Source Location No." = '')) then begin
                                IF location.Get(IndentLine."Location/StoreNo.From") then;
                                inventorySetup.Get();
                                IF location."Transfer Location" then begin
                                    IF IndentLine."Item Code" = "Item No." then begin
                                        IF Transno <> IndentLine."Location/StoreNo.To" then begin
                                            transHdr.Init();
                                            transHdr.Validate("No.", noseriesmgt.GetNextNo(inventorySetup."Transfer Order Nos.", WorkDate(), true));
                                            transHdr.Validate("Transfer-from Code", IndentLine."Location/StoreNo.From");
                                            transHdr.Validate("Transfer-to Code", IndentLine."Location/StoreNo.To");
                                            transHdr.Validate("Posting Date", IndentLine."Request Delivery Date");
                                            transHdr.Validate("Shipment Date", IndentLine."Request Delivery Date");
                                            transHdr.Validate("Requistion No.", IndentLine."DocumentNo.");
                                            // transHdr.Validate("In-Transit Code", 'INTRANSIT');//AsPerREQ12102023
                                            transHdr.Validate("In-Transit Code", 'INTRANSIT1');
                                            transHdr.Validate("Shipment Date", indentHdr."Posting date");
                                            transHdr.Validate("Receipt Date", indentHdr."Posting date");
                                            transHdr.Insert(true);


                                            transline.Init();
                                            transline.Validate("Document No.", transHdr."No.");
                                            transline.Validate("Line No.", 10000);
                                            transline.Validate("Item No.", IndentLine."Item Code");
                                            transline.Validate(Quantity, totalqty);
                                            IndentLine.CalcFields(UOM);
                                            transline.validate("Unit of Measure Code", IndentLine.UOM);
                                            transline.Validate("Indent Qty.", totalqty);
                                            transline.Validate("FA Subclass", IndentLine."FA Subclass");
                                            transline.Insert(true);
                                            Transno := IndentLine."Location/StoreNo.To";
                                        end
                                        else begin
                                            transline1.Reset();
                                            transline1.SetRange("Document No.", transHdr."No.");
                                            if transline1.FindLast() then;
                                            transline.Init();
                                            transline.Validate("Document No.", transHdr."No.");
                                            transline.Validate("Line No.", transline1."Line No." + 10000);
                                            transline.Validate("Item No.", IndentLine."Item Code");
                                            transline.Validate(Quantity, totalqty);
                                            IndentLine.CalcFields(UOM);
                                            transline.validate("Unit of Measure Code", IndentLine.UOM);
                                            transline.Validate("Indent Qty.", totalqty);
                                            transline.Validate("FA Subclass", IndentLine."FA Subclass");
                                            transline.Insert(true);
                                            Transno := IndentLine."Location/StoreNo.To";
                                        end;

                                        indentHdr.Reset();
                                        indentHdr.SetRange("No.", IndentLine."DocumentNo.");
                                        if indentHdr.FindFirst() then begin
                                            indentHdr."Transfer Order No." := Prodorder."No.";
                                            //   indentHdr.Status := indentHdr.Status::Processed;
                                            // indentHdr.Validate(Status);
                                            //      indentHdr.Validate(Select, false);
                                            indentHdr.Modify();
                                        end;
                                    end;
                                end;
                                transHdr1.Reset();
                                transHdr1.SetRange("No.", transHdr."No.");
                                IF transHdr1.FindFirst() then begin
                                    transHdr1.Status := transHdr1.Status::Released;
                                    transHdr1.Validate(Status);
                                    transHdr1.Modify(true)
                                end;
                                // */
                                // IndentLine.Modify(select, false)
                            end;




                    IH.Reset();
                    IH.SetRange("No.", indentHdr."No.");
                    IF IH.FindFirst() then begin
                        IH."Processed Date & time" := CurrentDateTime;
                        IH."Processed By" := UserId;
                        IH.Status := IH.Status::Released;
                        // IH.Select := false;
                        IH.Validate(Status);
                        IH.Modify(true);
                    end;

                end;
                //end;
            }
            trigger OnPreDataItem()
            begin
                IF usersetup.Get(UserId) then;
                Indentline.SetRange("Location/StoreNo.From", usersetup."Location Code");

                Clear(PONO1);
                Clear(PONo2);
            end;

        }
    }
    trigger OnPostReport()
    var

    begin

        //PONO1 := CopyStr(PONO, 1, StrLen(PONO) - 1);

        foreach POno1 in pono2 do begin
            SendMail(PONO1);
        end;



        Message('Orders Created');
    end;



    var
        usersetup: Record "User Setup";
        indentHdr: Record IndentHeader;
        location: Record Location;
        PONo2: List of [Code[30]];

        indentline1: Record Indentline;
        purchHdr: Record "Purchase Header";
        purchLine: Record "Purchase Line";
        purchLine1: Record "Purchase Line";
        PurSetup: Record "Purchases & Payables Setup";
        noseriesmgt: Codeunit NoSeriesManagement;
        SourceLoc: Code[25];
        subindentPO: Record "Sub Indent PO";
        IH: Record IndentHeader;
        Itemno: Code[50];
        PONO: Code[1000];
        PONO1: Code[1000];
        ManufSetup: Record "Manufacturing Setup";
        Prodorder: Record "Production Order";
        ProdOrder1: Record "Production Order";
        totalqty: Integer;
        transHdr: Record "Transfer Header";
        transHdr1: Record "Transfer Header";
        transline: Record "Transfer Line";
        transline1: Record "Transfer Line";
        inventorySetup: Record "Inventory Setup";
        Transno: code[20];
        PurHdr: Record "Purchase Header";
        Item: Record Item;
        ItemUOM: Record "Item Unit of Measure";


    local procedure InitSubindentPOLIST(PurchLine: Record "Purchase Line"; PH: Record "Purchase Header"; IL: Record Indentline)
    var
        SubIndentPO: Record "Sub Indent PO";
    begin
        SubIndentPO.Init();
        SubIndentPO."PO NO." := PurchLine."Document No.";
        SubIndentPO."Item No." := PurchLine."No.";
        SubIndentPO."Item Description" := PurchLine.Description;
        SubIndentPO."PO Line No." := PurchLine."Line No.";
        SubIndentPO."Indent Quantity" := PurchLine.Quantity;
        SubIndentPO."Vendor No." := PurchLine."Buy-from Vendor No.";
        SubIndentPO."Vendor Name" := PH."Buy-from Vendor Name";
        SubIndentPO."Location Code" := PH."Location Code";
        SubIndentPO."Store No." := IL."Location/StoreNo.To";
        SubIndentPO.Insert();


    end;

    procedure SendMail(SubIndentPO: Code[30])
    var
        EmailCodeunit: Codeunit Email;
        Tempblob: Codeunit "Temp Blob";
        Tempblob1: Codeunit "Temp Blob";
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
        RecrefPurch: RecordRef;
        RecrefPOLIST: RecordRef;
    //Mahendra end

    begin
        // MailList.Add('neha.gupta78@in.ey.com'); mahendra
        Subject := 'Indent Purchase Order' + SubIndentPO + '';
        MessageBody := 'Hello, ' + '<br><br>' + 'You have received Indent PO ' + ' ' + 'from Heisetasse Beverages Pvt. Ltd.';
        MessageBody += '<br><br> Best Regards';
        Tempblob.CreateOutStream(OStream);
        SubIndentPO1.Reset();
        SubIndentPO1.SetRange("PO NO.", SubIndentPO);
        IF SubIndentPO1.FindLast() then;

        RecrefPOLIST.GetTable(SubIndentPO1);
        Report.SaveAs(Report::"Sub-Indent PO List", SubIndentPO1."PO NO.", ReportFormat::Pdf, OStream, RecrefPOLIST);
        //Report.SaveAsExcel(Report::"Sub-Indent PO List", 'Indent PO List', SubIndentPO1);
        Tempblob.CreateInStream(IsStream);
        //mahendra start

        Tempblob1.CreateOutStream(OStream1);
        TempPurchHead.Reset();
        TempPurchHead.SetRange("No.", SubIndentPO);
        IF TempPurchHead.FindFirst() Then;

        RecrefPurch.GetTable(TempPurchHead);

        IF TempVend.get(TempPurchHead."Buy-from Vendor No.") then;
        // IF TempVend."E-Mail" = '' then
        //  Error('Please enter the email on Vendor card to send indent notification');



        TempReportSelection.Reset();
        TempReportSelection.SetRange(Usage, TempReportSelection.Usage::"P.Order");
        IF TempReportSelection.FindFirst() Then;


        Report.SaveAs(TempReportSelection."Report ID", TempPurchHead."No.", ReportFormat::Pdf, OStream1, RecrefPurch);
        // Report.SaveAsPdf(TempReportSelection."Report ID", 'PurchaseOrder.pdf', TempPurchHead);
        Tempblob1.CreateInStream(IsStream1);
        //Mahendra End
        IF TempVend."E-Mail" <> '' then //mahendra
        Begin

            //EmailMessage.Create(MailList, Subject, MessageBody, true); mahendra
            EmailMessage.Create(TempVend."E-Mail", Subject, MessageBody, true);


            //mahendra
            EmailMessage.AddAttachment('Indent Purchase Order.pdf', 'PDF', IsStream);

            EmailMessage.AddAttachment('Purchase Order.pdf', 'PDF', IsStream1);

            //EmailMessage.Attachments_Next()
            IF EmailCodeunit.Send(EmailMessage) then;
        end
        Else
            Message('Indent email has not been send as no mail id is define on vendor Card %1', TempVend."E-Mail");

    end;

}