pageextension 50007 PurchaseCardExt extends "Purchase Order"
{

    layout
    {
        addafter(Status)
        {
            // field("Creation Location"; "Creation Location")
            // {
            //     ApplicationArea = all;
            // }
        }


        //AJ_Alle_09282023
        //NTCNFRM
        // modify("Location Code")
        // {
        //  Editable = Seteditable;
        // Caption = 'Sell to Location';
        // Visible = false;
        //     trigger OnLookup(var Text: Text): Boolean
        //     var
        //         myInt: Integer;
        //         Useracces: Record "User Access1";
        //         Usersetup: Record "User Setup";
        //         Location: Record Location;
        //         i: Integer;
        //         Filtercode: Code[1024];
        //         location1: Record Location;
        //     begin
        //         if Usersetup.Get(UserId) then;
        //         if Usersetup."Is Admin" = true then begin
        //             if Page.RunModal(Page::"Location List", Location1) = Action::LookupOK then begin
        //                 Rec.Validate("Location Code", Location1.Code);
        //                 Rec.Modify()
        //             end;
        //         end;
        //         if Usersetup."Multiple Location Access" = true then begin
        //             Useracces.SetFilter("User ID", '%1', Usersetup."User ID");
        //             if Useracces.FindFirst() then;

        //             for i := 1 to 1024 do begin
        //                 if i = 1 then
        //                     if Strlen(Filtercode) = 0 then
        //                         Filtercode := format(Useracces."Location Code")
        //                 // else begin
        //                 //     if strlen(Filtercode + '|' + format(i)) <= 1024 then
        //                 //         Filtercode := Filtercode + '|' + format(i);
        //                 // end;
        //             end;
        //             Location.setfilter(Code, Filtercode);
        //             if Page.RunModal(Page::"Location List", Location) = Action::LookupOK then begin
        //                 Rec.Validate("Location Code", Location.Code);
        //                 Rec.Modify()
        //             end;
        //         end;
        //     end;
        //  }
        //NTCNFRM
        //AJ_Alle_09282023
        addafter("Vendor Order No.")
        {
            field("Order No"; Rec."Order No")
            { ApplicationArea = all; }
        }

        modify("Buy-from Vendor No.")
        {
            trigger OnLookup(var Text: Text): Boolean
            var
                TwcPurchPrice: Record TWCPurchasePrice;
                TempVendor: Record Vendor;


            begin
                IF Rec."Location Code" <> '' then begin
                    TempVendor.Reset();
                    TempVendor.SetFilter(TempVendor."No.", '<>%1', '');
                    IF TempVendor.FindSet() Then
                        repeat
                            TwcPurchPrice.Reset();
                            TwcPurchPrice.SetRange(TwcPurchPrice.PurchPricetype, TwcPurchPrice.PurchPricetype::Item);
                            TwcPurchPrice.SetRange(TwcPurchPrice."Vendor No.", TempVendor."No.");
                            TwcPurchPrice.SetRange(TwcPurchPrice."Location Code", Rec."Location Code");
                            IF TwcPurchPrice.FindFirst() then
                                TempVendor.Mark(true);

                        until TempVendor.Next() = 0;

                    TempVendor.MarkedOnly(true);
                    //IF TempItem.FindSet() then;
                    IF PAGE.RUNMODAL(0, TempVendor) = ACTION::LookupOK THEN begin
                        Rec."Buy-from Vendor No." := TempVendor."No.";
                        Rec.Validate(Rec."Buy-from Vendor No.");
                    end;

                end
                else begin
                    TempVendor.Reset();
                    TempVendor.SetFilter(TempVendor."No.", '<>%1', '');
                    IF TempVendor.FindSet() Then;
                    IF PAGE.RUNMODAL(0, TempVendor) = ACTION::LookupOK THEN begin
                        Rec."Buy-from Vendor No." := TempVendor."No.";
                        Rec.Validate(Rec."Buy-from Vendor No.");
                    end;
                end;
            End;
        }
        addafter("Remit-to Code")//PT-FBTS -02-08-24
        {
            field("Thrid Party vendor"; Rec."Thrid Party vendor")
            {
                ApplicationArea = all;
            }
        }
        modify("Buy-from Vendor Name")
        {
            trigger OnLookup(var Text: Text): Boolean
            var
                TwcPurchPrice: Record TWCPurchasePrice;
                TempVendor: Record Vendor;


            begin
                IF Rec."Location Code" <> '' then begin
                    TempVendor.Reset();
                    TempVendor.SetFilter(TempVendor."No.", '<>%1', '');
                    IF TempVendor.FindSet() Then
                        repeat
                            TwcPurchPrice.Reset();
                            TwcPurchPrice.SetRange(TwcPurchPrice.PurchPricetype, TwcPurchPrice.PurchPricetype::Item);
                            TwcPurchPrice.SetRange(TwcPurchPrice."Vendor No.", TempVendor."No.");
                            TwcPurchPrice.SetRange(TwcPurchPrice."Location Code", Rec."Location Code");
                            IF TwcPurchPrice.FindFirst() then
                                TempVendor.Mark(true);

                        until TempVendor.Next() = 0;

                    TempVendor.MarkedOnly(true);
                    //IF TempItem.FindSet() then;
                    IF PAGE.RUNMODAL(0, TempVendor) = ACTION::LookupOK THEN begin
                        Rec."Buy-from Vendor No." := TempVendor."No.";
                        Rec.Validate(Rec."Buy-from Vendor No.");
                    end;

                end
                else begin
                    TempVendor.Reset();
                    TempVendor.SetFilter(TempVendor."No.", '<>%1', '');
                    IF TempVendor.FindSet() Then;
                    IF PAGE.RUNMODAL(0, TempVendor) = ACTION::LookupOK THEN begin
                        Rec."Buy-from Vendor No." := TempVendor."No.";
                        Rec.Validate(Rec."Buy-from Vendor No.");
                    end;
                end;
            End;
        }

        modify("Posting Date")
        {
            ShowMandatory = true;
        }
        // Add changes to page layout here
        addlast(General)
        {
            field("Requistion No."; Rec."Indent No.")
            {
                ApplicationArea = all;
                Caption = 'Indent No.';
                Editable = false;
            }
            field("Email Sent"; Rec."Email Sent")
            {
                ApplicationArea = all;
                // Editable = false;
                //Visible = false;
            }
        }

        addafter(Status)
        {
            field(LocationCode; Rec."Location Code")
            {
                Caption = 'Location Code';
                Editable = false;
            }
            field(ShortClosed; Rec.ShortClosed)
            {
                Caption = 'Order Short Closed';
                Editable = false;
            }
            field(CommentCode; Rec.CommentCode)
            {
                Caption = 'CommentCode';

            }

            field(FreightCost; Rec.FreightCost)
            {
                Caption = 'Freight Cost Included';
            }
            field(ProformaInvoice; Rec.ProformaInvoice)
            {
                Caption = 'Proforma Invoice Number';
            }
        }
        addafter("Vendor Invoice No.")
        {
            field(VendorInvoiceDate; Rec.VendorInvoiceDate)
            {
                Caption = 'Vendor Invoice Date';
            }
        }

    }

    actions
    {

        modify(Post)
        {
            Visible = Seteditable; //PT-FBTS 15-07-2024 
            // Enabled = false;
        }
        modify("Post &Batch")
        {
            Enabled = false;
            Visible = false;
        }
        modify("Post and &Print")
        {
            Enabled = false;
        }
        modify(PostAndNew)
        {
            Enabled = false;
        }
        modify("Request Approval")
        {
            Enabled = false;
            Visible = false;
        }
        modify(SendApprovalRequest)
        {
            Enabled = false;
            Visible = false;
        }
        modify(CancelApprovalRequest)
        {
            Enabled = false;
            Visible = false;
        }
        addafter("Update Reference Invoice No.")
        {
            action("Advance Payment Against PO") //PT-FBTS-23-10-24
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = page "Vendor Ledger Entries";
                RunPageLink = "PO No." = field("No.");

            }
        }
        // Add changes to page actions here



        addlast(processing)
        {
            action("Print Report")
            {
                ApplicationArea = All;
                Image = Print;
                trigger OnAction()
                var
                    PurchaseHeader: Record "Purchase Header";
                begin
                    PurchaseHeader.SetRange("No.", Rec."No.");
                    if PurchaseHeader.FindFirst() then begin
                        Report.Run(50101, true, false, PurchaseHeader);

                    end;

                end;
            }

            action("Email-PO")
            {
                ApplicationArea = All;
                Image = Email;
                trigger OnAction()
                var
                    EmailCodeunit: Codeunit Email;
                    Tempblob: Codeunit "Temp Blob";
                    IsStream: InStream;
                    OStream: OutStream;
                    PurchaseorderReport: Report Order;
                    EmailMessage: Codeunit "Email Message";
                    Vendor: Record Vendor;
                    MessageBody: Text;
                    MailList: List of [text];
                    RequestRunPage: text;
                    PurchaseHeader: Record "Purchase Header";
                    RecRef: RecordRef;


                begin
                    SendEmail(rec."No.");
                    //     if not Rec."Email Sent" then begin
                    //         PurchaseHeader.SetRange("No.", rec."No.");
                    //         if not PurchaseHeader.FindFirst() then exit;
                    //         RecRef.GetTable(PurchaseHeader);
                    //         if Rec.Status <> Rec.Status::Released then
                    //             Error('Status must be released');
                    //         Tempblob.CreateInStream(IsStream);
                    //         Tempblob.CreateOutStream(OStream);
                    //         PurchaseorderReport.SetTableView(Rec);
                    //         //   RequestRunPage := PurchaseorderReport.RunRequestPage();

                    //         PurchaseorderReport.SaveAs('', ReportFormat::Pdf, OStream, RecRef);
                    //         if Vendor.get(rec."Buy-from Vendor No.") then;
                    //         MailList.Add(Vendor."E-Mail");
                    //         MessageBody := 'This is a system generated mail.Please do not reply this email';
                    //         EmailMessage.Create(MailList, 'E-Mail', MessageBody, true);
                    //         EmailMessage.AddAttachment('Order.pdf', 'application/pdf', IsStream);
                    //         //EmailCodeunit.OpenInEditorModally(EmailMessage);
                    //         //  EmailCodeunit.SaveAsDraft(EmailMessage);
                    //         if EmailCodeunit.Send(EmailMessage) then begin
                    //             Message('Email Sent');
                    //             EmailSent := true;



                    //         end;
                    //         Commit();
                    //         //PurchaseHeader.Modify(false);
                    //         //CurrPage.Update(true);
                    //     end;

                end;
            }


            action("&printreport12")
            {
                ApplicationArea = All;
                Image = Print;
                trigger OnAction()
                var
                    PurchaseHeader: Record "Purchase Header";
                begin
                    PurchaseHeader.SetRange("No.", Rec."No.");
                    if PurchaseHeader.FindFirst() then begin
                        Report.Run(50103, true, false, PurchaseHeader);

                    end;

                end;
            }
        }

        ///scm start
        addafter("Archive Document")
        {
            action(purchaseShortclose)
            {
                ApplicationArea = All;
                Caption = 'Short Close PO';
                ToolTip = 'Short Close PO';

                trigger OnAction()
                var
                    PurchClose: Codeunit AllSCMCustomization;
                begin
                    PurchClose.ShortClosePurchaseOrder(Rec."No.");
                    Message('PO short closed successfully , please chck the posted short close');
                    CurrPage.Update();
                end;
            }

        }
        addafter("Request Approval")
        {
            group("TWCRequestApproval")
            {
                Caption = 'TWC Request Approval';

                action(TWCSendApprovalRequest)
                {
                    ApplicationArea = All;
                    Promoted = true;
                    // PromotedIsBig = false;
                    // PromotedCategory = New;
                    //  PromotedCategory = ;                
                    Caption = 'Send A&pproval Request';
                    // Promoted = true;
                    // PromotedCategory = Category9;
                    // Enabled = NOT OpenApprovalEntriesExist AND CanRequestApprovalForFlow;
                    Image = SendApprovalRequest;

                    ToolTip = 'Request approval of the document.';

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                        tempPurchPrice: Record TWCPurchasePrice;
                        TempPurchLine: Record "Purchase Line";
                        PriceMistach: Boolean;
                        ReleasePurchDoc: Codeunit "Release Purchase Document";

                    begin
                        TempPurchLine.Reset();
                        TempPurchLine.SetRange("Document No.", Rec."No.");
                        TempPurchLine.SetRange(TempPurchLine.Type, TempPurchLine.Type::Item);
                        TempPurchLine.SetFilter(TempPurchLine."No.", '<>%1', '');
                        IF TempPurchLine.FindSet() then
                            repeat
                                tempPurchPrice.Reset();
                                tempPurchPrice.SetRange(tempPurchPrice."Item No.", TempPurchLine."No.");
                                tempPurchPrice.SetRange(tempPurchPrice."Vendor No.", TempPurchLine."Pay-to Vendor No.");
                                tempPurchPrice.SetRange(tempPurchPrice."Location Code", TempPurchLine."Location Code");
                                tempPurchPrice.SetRange(tempPurchPrice."Direct Unit Cost", TempPurchLine."Direct Unit Cost");
                                IF TempPurchLine."Unit of Measure Code" <> '' Then
                                    tempPurchPrice.SetRange(tempPurchPrice."Unit of Measure Code", TempPurchLine."Unit of Measure Code");
                                tempPurchPrice.SetFilter(tempPurchPrice."Starting Date", '<=%1', Rec."Document Date");
                                //tempPurchPrice.SetFilter(tempPurchPrice."Ending Date", '=%1', 0D);
                                tempPurchPrice.SetFilter(tempPurchPrice."Ending Date", '=%1|>=%2', 0D, Rec."Document Date");
                                IF Not tempPurchPrice.FindFirst() then begin
                                    PriceMistach := true;
                                End;
                            until TempPurchLine.Next() = 0;

                        //Message(format(PurchaseLine."Direct Unit Cost"));
                        //Message(Format(tempPurchPrice."Direct Unit Cost"));
                        IF PriceMistach Then Begin

                            if ApprovalsMgmt.CheckPurchaseApprovalPossible(Rec) then
                                ApprovalsMgmt.OnSendPurchaseDocForApproval(Rec);
                        end
                        else begin
                            // ReleasePurchDoc.PerformManualRelease(Rec);
                            Rec.Status := Rec.Status::Released;
                            Rec.Modify();
                            CurrPage.Update();
                            CurrPage.PurchLines.PAGE.ClearTotalPurchaseHeader();
                        end;
                    end;
                }
                action(TWCCancelApprovalRequest)
                {
                    ApplicationArea = Basic, Suite;
                    Promoted = true;
                    //    PromotedIsBig = true;
                    // PromotedCategory = Process;
                    Caption = 'Cancel Approval Re&quest';
                    // Promoted = true;
                    // PromotedCategory = Category5;
                    //   Enabled = CanCancelApprovalForRecord OR CanCancelApprovalForFlow;
                    Image = CancelApprovalRequest;
                    ToolTip = 'Cancel the approval request.';

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
                    begin
                        ApprovalsMgmt.OnCancelPurchaseApprovalRequest(Rec);
                        WorkflowWebhookMgt.FindAndCancel(RecordId);
                    end;
                }

                // }
            }
        }
        //SCM END

    }
    trigger OnOpenPage()
    var
        TempUserSetup: Record "User Setup";
    begin
        // if rec."Created userId" <> '' then begin
        //     if TempUserSetup.Get(UserId) then;
        //     if TempUserSetup."User ID" <> rec."Created userId" then begin
        //         CurrPage.Editable(false);
        //     end;
        // end;

        Rec.FilterGroup(2);
        Rec.SetRange(Rec.ShortClosed, false);
        Rec.FilterGroup(0);

        //AJ_ALLE_09282023
        //NTCNFRM
        // if TempUserSetup.Get(UserId) then;
        //  //ALLENick
        // rec."Creation Location" := TempUserSetup."Location Code";
        // IF (TempUserSetup."Is Admin" = true) or (TempUserSetup."Multiple Location Access" = true) then begin
        //     Seteditable := true;
        // end else begin
        //     Seteditable := false;
        // end;
        //NTCNFRM
        //AJ_ALLE_09282023
    end;

    trigger OnAfterGetCurrRecord() //PT-FBTS 15-07-2024
    var
        UserSetup: Record "User Setup";
    begin
        UserSetup.Get(UserId);
        if UserSetup."Purch. Post Enable" then begin
            Seteditable := true;
        end else
            if not UserSetup."Purch. Post Enable" then
                Seteditable := false;
    end;

    trigger OnAfterGetRecord()//PT-FBTS 15-07-2024
    var
        UserSetup: Record "User Setup";
    begin
        UserSetup.Get(UserId);
        if UserSetup."Purch. Post Enable" then begin
            Seteditable := true;
        end else
            if not UserSetup."Purch. Post Enable" then
                Seteditable := false;

    end;
    //ALLENick
    //  trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    // var
    //     userssetup: Record "User Setup";
    // begin
    //     if userssetup.Get(UserId) then
    //         rec."Created userId" := userssetup."User ID";
    //     rec."Creation Location" := userssetup."Location Code";
    // end;

    // trigger OnNewRecord(BelowxRec: Boolean)
    // var
    //     userssetup: Record "User Setup";
    // begin
    //     if userssetup.Get(UserId) then
    //         rec."Created userId" := userssetup."User ID";
    //     rec."Creation Location" := userssetup."Location Code";

    // end;

    var
        EmailSent: Boolean;
        Seteditable: Boolean;


    procedure SendEmail(DocumentNo: code[20])
    var
        EmailCodeunit: Codeunit Email;
        Tempblob: Codeunit "Temp Blob";
        IsStream: InStream;
        OStream: OutStream;
        PurchaseorderReport: Report Order;
        EmailMessage: Codeunit "Email Message";
        Vendor: Record Vendor;
        MessageBody: Text;
        MailList: List of [text];
        RequestRunPage: text;
        PurchaseHeader: Record "Purchase Header";
        RecRef: RecordRef;
        Subject: Text;
    begin
        Commit();
        PurchaseHeader.LockTable();

        PurchaseHeader.SetRange("No.", DocumentNo);
        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
        if not PurchaseHeader.FindFirst() then exit;
        if not PurchaseHeader."Email Sent" then begin
            RecRef.GetTable(PurchaseHeader);
            if PurchaseHeader.Status <> PurchaseHeader.Status::Released then
                Error('Status must be released');
            Tempblob.CreateInStream(IsStream);
            Tempblob.CreateOutStream(OStream);
            PurchaseorderReport.SetTableView(Rec);
            PurchaseorderReport.SaveAs('', ReportFormat::Pdf, OStream, RecRef);
            if Vendor.get(rec."Buy-from Vendor No.") then;
            MailList.Add(Vendor."E-Mail");
            Subject := 'Purchase order ' + PurchaseHeader."No." + '';
            MessageBody := 'Hello, ' + Vendor.Name + '<br><br>' + 'You have received purchase order ' + PurchaseHeader."No." + ' ' + 'from Heisetasse Beverages Pvt. Ltd.';
            MessageBody += '<br><br> Best Regards,<br><br>Procurement Team';
            //Regards,Procurement Team Email ID – procurement.twc@thirdwavecoffee.in';
            //'This is a system generated mail.Please do not reply this email';
            EmailMessage.Create(MailList, Subject, MessageBody, true);
            EmailMessage.AddAttachment('Order.pdf', 'application/pdf', IsStream);
            //EmailCodeunit.OpenInEditorModally(EmailMessage);
            //  EmailCodeunit.SaveAsDraft(EmailMessage);
            if EmailCodeunit.Send(EmailMessage) then begin
                Message('Email Sent');
                Commit();
                PurchaseHeader.LockTable();
                PurchaseHeader.Validate("Email Sent", true);
                PurchaseHeader.Modify();
            end;
        end;
    end;
}