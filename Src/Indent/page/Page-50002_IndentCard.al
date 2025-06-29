page 50002 IndentCard
{
    PageType = Card;
    //ApplicationArea = All;
    //  UsageCategory = Lists;
    SourceTable = IndentHeader;
    Caption = 'Indent Card';
    PromotedActionCategories = 'New," "," ",Process,Approval';
    layout
    {

        area(Content)
        {

            group(General)
            {
                // Editable = rec.Status <> Rec.Status::Release;
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;

                }
                field("To Location code"; Rec."To Location code")
                {
                    ApplicationArea = ALL;
                    Editable = false;
                }
                field("To Location Name"; Rec."To Location Name")
                {
                    ApplicationArea = all;

                }

                field("From Location Code"; Rec."From Location Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("From Location Name"; Rec."From Location Name")
                {
                    ApplicationArea = all;
                    Visible = false;
                }


                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Editable = false;

                }
                field(DepartmentCode; Rec."DepartmentCode")
                {
                    ApplicationArea = All;
                    Caption = 'Department Code';
                    Editable = false;
                }
                field("Posting date"; Rec."Posting date")
                {
                    ApplicationArea = All;
                    Caption = 'Requested Delivery Date';
                    Editable = Setedit1;

                }
                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = All;
                    Caption = 'Created Date';
                    Editable = false;
                }
                field("CreatedBy"; Rec."CreatedBy")
                {
                    ApplicationArea = All;
                    Caption = 'Created By';
                    Editable = false;
                }
                field("Submit Date"; rec."Submit Date")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Submit Time"; rec."Submit Time")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = all;
                    Visible = true;
                }
                field("Order Type"; "Order Type") //PT-FBTS 19052025
                {
                    ApplicationArea = all;
                    Visible = true;
                }
                field(Category; Rec.Category)
                {
                    ApplicationArea = all;
                    Editable = rec.Type = rec.Type::Item;
                    TableRelation = IF (Type = CONST(Item)) "Item Category".Code where("Indent Category" = const(true));
                    trigger OnValidate()
                    var
                        Item: Record Item;
                        ItemforIndent: Record "Item For Indent" temporary;
                        indentLine: Record Indentline;
                        ILE: Record "Item Ledger Entry";
                        IndentMappingsetup: Record "Indent Mapping";
                        indent: Record IndentHeader;
                        indent1: Record IndentHeader;
                        indentline1: Record Indentline;
                    begin
                        TestField(Status, Status::Open);
                        TestField("Posting date");

                        // IF ItemforIndent.FindSet() then
                        //  ItemforIndent.DeleteAll(true);

                        indent.Reset();
                        indent.SetRange("No.", Rec."No.");
                        if indent.FindFirst() then begin
                            if Rec.Type = Rec.Type::Item then begin
                                IF Rec."Order Type" = Rec."Order Type"::Regular then begin
                                    Item.reset;
                                    Item.SetRange(Special, false);
                                    Item.SetRange("Item Category Code", rec.Category);
                                    if item.FindFirst() then
                                        repeat
                                            IndentMappingsetup.Reset();
                                            IndentMappingsetup.SetRange("Location Code", Rec."To Location code");
                                            IndentMappingsetup.SetRange("Item No.", Item."No.");
                                            IndentMappingsetup.SetRange("Block Indent", false);//PT-FBTS
                                            IndentMappingsetup.SetRange("Item Category", Item."Item Category Code");
                                            IF IndentMappingsetup.FindFirst() then begin

                                                ItemforIndent.Init();
                                                ItemforIndent.Type := ItemforIndent.Type::Item;
                                                ItemforIndent."Item No." := Item."No.";
                                                ItemforIndent.Description := Item.Description;
                                                ItemforIndent."Unit of Measure" := Item."Base Unit of Measure";
                                                ItemforIndent."Indent No." := rec."No.";
                                                ItemforIndent."Item Category" := rec.Category;
                                                //ItemforIndent."Location Code" := rec."To Location code";//PT-FBTS


                                                ILE.Reset();
                                                ILE.SetRange("Item No.", Item."No.");
                                                ILE.SetRange("Location Code", Rec."To Location code");
                                                IF ILE.FindSet() then begin
                                                    ILE.CalcSums(Quantity);
                                                    ItemforIndent."Stock In Hand" := ILE.Quantity;
                                                end;

                                                //Clear("In-Transit");
                                                ILE.Reset();
                                                ILE.SetRange("Item No.", Item."No.");
                                                ILE.SetRange("Location Code", Rec."To Location code");//PTFBTS 
                                                ILE.SetRange("Entry Type", ILE."Entry Type"::Transfer);
                                                IF ILE.FindSet() then begin
                                                    ILE.CalcSums(Quantity);
                                                    ItemforIndent."In-Transit" := ILE.Quantity;
                                                end;
                                                //    Message('%1', ItemforIndent."In-Transit");
                                                ItemforIndent.Insert();
                                            end;

                                        until Item.Next() = 0;
                                    ItemforIndent.SetFilter("Indent No.", Rec."No.");
                                    IF ItemforIndent.FindSet() then;
                                    Page.Run(50003, ItemforIndent);

                                end;
                                IF Rec."Order Type" = Rec."Order Type"::Special then begin
                                    Item.reset;
                                    Item.SetRange(Special, True);
                                    Item.SetRange("Item Category Code", rec.Category);
                                    if item.FindFirst() then
                                        repeat
                                            IndentMappingsetup.Reset();
                                            IndentMappingsetup.SetRange("Location Code", Rec."To Location code");
                                            IndentMappingsetup.SetRange("Item No.", Item."No.");
                                            IndentMappingsetup.SetRange("Block Indent", false);//PT-FBTS
                                            IndentMappingsetup.SetRange("Item Category", Item."Item Category Code");
                                            IF IndentMappingsetup.FindFirst() then begin

                                                ItemforIndent.Init();
                                                ItemforIndent.Type := ItemforIndent.Type::Item;
                                                ItemforIndent."Item No." := Item."No.";
                                                ItemforIndent.Description := Item.Description;
                                                ItemforIndent."Unit of Measure" := Item."Base Unit of Measure";
                                                ItemforIndent."Indent No." := rec."No.";
                                                ItemforIndent."Item Category" := rec.Category;
                                                //   ItemforIndent."Location Code" := rec."To Location code";//PT-FBTS


                                                ILE.Reset();
                                                ILE.SetRange("Item No.", Item."No.");
                                                ILE.SetRange("Location Code", Rec."To Location code");
                                                IF ILE.FindSet() then begin
                                                    ILE.CalcSums(Quantity);
                                                    ItemforIndent."Stock In Hand" := ILE.Quantity;
                                                end;

                                                //Clear("In-Transit");
                                                ILE.Reset();
                                                ILE.SetRange("Item No.", Item."No.");
                                                ILE.SetRange("Location Code", Rec."To Location code");//PTFBTS 
                                                ILE.SetRange("Entry Type", ILE."Entry Type"::Transfer);
                                                IF ILE.FindSet() then begin
                                                    ILE.CalcSums(Quantity);
                                                    ItemforIndent."In-Transit" := ILE.Quantity;
                                                end;
                                                //    Message('%1', ItemforIndent."In-Transit");
                                                ItemforIndent.Insert();
                                            end;

                                        until Item.Next() = 0;
                                    ItemforIndent.SetFilter("Indent No.", Rec."No.");
                                    IF ItemforIndent.FindSet() then;
                                    Page.Run(50003, ItemforIndent);

                                end;
                            end;
                            Rec.Category := '';
                            Rec.Modify();
                        end;

                    end;

                }

                field("Main Indent No."; rec."Main Indent No.")
                {
                    ApplicationArea = all;
                    Editable = false;
                    Visible = false;
                }
                field("Sub-Indent"; rec."Sub-Indent")
                {
                    ApplicationArea = all;
                    Editable = false;
                    Visible = false;
                }
                field("Approval Required"; rec."Approval Required")
                {
                    ApplicationArea = all;
                    Editable = false;
                    Visible = false;
                }
                field("Approved By"; rec."Approved By")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                //PT-FBTS 03-07-2024
                field("Approved/Reject"; Rec."Approved/Reject")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                //PT-FBTS 03-07-2024


            }
            part(IndentLine; "Indent Line")
            {
                ApplicationArea = all;
                SubPageLink = "DocumentNo." = field("No.");
                UpdatePropagation = Both;
                // Editable = rec.Status = rec.Status::Open;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Send for Approval")
            {
                ApplicationArea = all;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = SendApprovalRequest;

                trigger OnAction()
                var
                    usersetup: Record "User Setup";
                    invsetup: Record "Inventory Setup";
                    processdate: DateTime;
                    dur: Duration;
                    currentdatetime: DateTime;
                    hours: bigInteger;
                    submitdate: Date;
                    submittime: Time;
                    approvalreq: Boolean;
                    indentline: Record Indentline;
                    Item: Record Item;
                    indentline1: Record Indentline;
                begin
                    indentline.Reset();
                    indentline.SetRange("DocumentNo.", "No.");
                    IF not indentline.FindFirst() then
                        Error('Nothing to send for approval');
                    //ALLE-AS-20012024
                    indentline1.Reset();
                    indentline1.SetRange("DocumentNo.", rec."No.");
                    indentline1.SetFilter("Type Of Item", '%1', indentline1."Type Of Item"::" ");
                    IF indentline1.FindFirst() then
                        Error('Please remove the blank line');
                    //ALLE-AS-20012024
                    indentline.Reset();
                    indentline.SetRange("DocumentNo.", Rec."No.");
                    IF indentline.FindSet() then
                        repeat
                            IF Item.Get(indentline."Item Code") then begin
                                IF Rec."Order Type" = Rec."Order Type"::Special then
                                    Item.TestField(Special);
                            end;
                            IF Item.IsFixedAssetItem then begin
                                indentline.TestField("FA Subclass");
                            end;
                        until indentline.Next() = 0;


                    indentline.Reset();
                    indentline.SetRange("DocumentNo.", Rec."No.");
                    indentline.SetRange("Approval Required", true);
                    IF indentline.FindFirst() then begin
                        Rec."Approval Required" := true;
                        Rec.Modify();
                    end;

                    Clear(approvalreq);
                    Clear(submitdate);
                    Clear(submittime);
                    invsetup.Get();
                    submitdate := Today;
                    submittime := time;
                    //Rec.Modify(true);


                    IF Rec."Order Type" = Rec."Order Type"::Special Then
                        processdate := CreateDateTime(Rec."Posting date", invsetup."Indent Time")
                    Else
                        processdate := CreateDateTime(Rec."Posting date", invsetup."Indent Time");
                    currentdatetime := CreateDateTime(submitdate, submittime);

                    dur := processdate - currentdatetime;
                    Rec."Submit Date" := Today;
                    Rec."Submit Time" := Time;

                    IF dur <> 0 then begin
                        IF Rec."Order Type" = Rec."Order Type"::Special then begin
                            IF invsetup."Max Submission limit Special" > (dur / 1800000) then begin
                                Rec."Approval Required" := true;
                                Rec."Approver Name" := usersetup."Indent Approver ID";
                                indentline.Reset();
                                indentline.SetRange("DocumentNo.", Rec."No.");
                                IF indentline.FindSet() then begin
                                    indentline.ModifyAll("Approval Required", true);

                                    indentline.ModifyAll("Approval Remarks", indentline."Approval Remarks"::"Submitted Beyond timeline");
                                end;
                                approvalreq := true;
                                Rec.Modify();
                                CurrPage.Update(true);
                            end;
                        end;
                        IF Rec."Order Type" = Rec."Order Type"::Regular then begin

                            IF invsetup."Max Submission limit" > (dur / 3600000) then begin
                                Rec."Approval Required" := true;
                                Rec."Approver Name" := usersetup."Indent Approver ID";
                                indentline.Reset();
                                indentline.SetRange("DocumentNo.", Rec."No.");
                                IF indentline.FindSet() then begin
                                    indentline.ModifyAll("Approval Required", true);

                                    indentline.ModifyAll("Approval Remarks", indentline."Approval Remarks"::"Submitted Beyond timeline");
                                end;
                                approvalreq := true;
                                Rec.Modify();
                                CurrPage.Update(true);
                            end;
                        End;
                    end;
                    Commit();
                    IF Rec.Status = Rec.Status::Rejected then
                        Error('Indent is already rejected');

                    IF Rec.Status = Rec.Status::Released then
                        Error('Indent is already released');

                    Rec.TestField(DepartmentCode);

                    IF rec."Posting date" < Today then
                        Error('Requested Delivery date should not be less than current date');

                    IF approvalreq or Rec."Approval Required" then begin
                        IF usersetup.Get(UserId) then;
                        IF usersetup."Indent Approver ID" <> UserId then begin
                            Rec.Status := Rec.Status::"Sent For Approval";
                            Rec."Approver Name" := usersetup."Indent Approver ID";
                            Rec.Modify();
                            CurrPage.Update(true);
                            Message('Indent is sent for approval to %1', usersetup."Indent Approver ID");


                        end
                        else begin
                            Rec.Status := Rec.Status::Released;
                            Rec.Modify();
                            IndentHdr.Reset();
                            IndentHdr.SetRange("No.", Rec."No.");
                            IF IndentHdr.FindFirst() then
                                Report.Run(50000, false, false, IndentHdr);
                        end;
                    end
                    else begin
                        Rec.Status := Rec.Status::Released;
                        Rec.Modify();
                        IndentHdr.Reset();
                        IndentHdr.SetRange("No.", Rec."No.");
                        IF IndentHdr.FindFirst() then
                            Report.Run(50000, false, false, IndentHdr);
                    end;

                    IF Rec.Status = Rec.Status::"Sent For Approval" then begin
                        SendEmail(Rec."No.");
                    end;


                    /*
                    IF not rec."Approval Required" then begin
                        Rec.Status := Rec.Status::Released;
                        Rec.Modify();
                        CurrPage.Update(true);
                        IndentHdr.Reset();
                        IndentHdr.SetRange("No.", Rec."No.");
                        IF IndentHdr.FindFirst() then
                            Report.Run(50001, false, false, IndentHdr);
                    end;
*/
                end;
            }
            /*
            action(Submit)
            {
                ApplicationArea = all;

                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = Process;
                trigger OnAction()
                var
                    IndentHeader: Record IndentHeader;
                    Indentmap: Record "Indent Mapping";
                    indentline: Record Indentline;
                    invsetup: Record "Inventory Setup";
                    processdate: DateTime;
                    dur: Duration;
                    currentdatetime: DateTime;
                    hours: bigInteger;

                begin
                    invsetup.Get();
                    Rec."Submit Date" := Today;
                    Rec."Submit Time" := Time;
                    Rec.Modify(true);

                    processdate := CreateDateTime(Rec."Posting date", invsetup."Indent Time");
                    currentdatetime := CreateDateTime(Rec."Submit Date", Rec."Submit Time");

                    dur := processdate - currentdatetime;

                    IF dur <> 0 then begin
                        IF invsetup."Max Submission limit" > (dur / 3600000) then begin
                            Rec."Approval Required" := true;
                            Rec.Modify();
                        end;
                    end;
                    Commit();

                    IF not (rec."Approval Required") then begin
                        indentline.Reset();
                        indentline.SetRange("DocumentNo.", Rec."No.");
                        IF indentline.FindFirst() then
                            repeat
                                Indentmap.Reset();
                                Indentmap.SetRange("Location Code", Rec."To Location code");
                                Indentmap.SetRange("Item No.", indentline."Item Code");
                                IF not Indentmap.FindFirst() then begin
                                    indentline.Error := 'Mapping setup does nor exist';
                                    indentline.Modify();
                                end;

                            until indentline.Next() = 0;

                        IF Confirm('Are you sure to submit the indent? You will not be able to modify after submitting.', true) then begin
                            IF rec.Status <> Rec.Status::Release then begin
                                IndentHdr.Reset();
                                IndentHdr.SetRange("No.", Rec."No.");
                                IF IndentHdr.FindFirst() then
                                    Report.Run(50001, false, false, IndentHdr);
                            end
                            else
                                Error('Indent is already released');
                        end;
                    end
                    else begin
                        Message('Indent requires approval first');
                    end;
                end;

            }
            */
            action("View Sub-Indents")
            {
                RunObject = page "Sub Indent List unedit";
                RunPageLink = "Sub-Indent" = const(true), "Main Indent No." = field("No.");
                ApplicationArea = all;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = ViewPage;
            }
        }

    }

    var
        IndentHdr: Record IndentHeader;

    procedure SendEmail(DocumentNo: code[20])
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
    begin
        Commit();
        if UserSetup.get(UserId) then begin
            //  if currentuser.get(UserSetup."Area Manager Approver ID") then begin
            MailList.Add(UserSetup.IndentNotification);
            Subject := 'Indent Approval Request ' + rec."No." + '';
            MessageBody := 'Hello, ' + currentuser."User ID" + '<br><br>' + 'You have received Indent Approval Request ' + Rec."No." + ' ' + 'from Heisetasse Beverages Pvt. Ltd.';
            MessageBody += '<br><br>' + 'https://erptwc.thirdwavecoffee.in/BC220/?company=HBPL&page=50012&dc=0' + '<br><br> Best Regards,<br><br>Procurement Team';

            //Regards,Procurement Team Email ID – procurement.twc@thirdwavecoffee.in';
            //'This is a system generated mail.Please do not reply this email';
            EmailMessage.Create(MailList, Subject, MessageBody, true);
            //  EmailMessage.AddAttachment('Order.pdf', 'application/pdf', IsStream);
            //EmailCodeunit.OpenInEditorModally(EmailMessage);
            //  EmailCodeunit.SaveAsDraft(EmailMessage);
            if EmailCodeunit.Send(EmailMessage) then begin
                Message('Email Sent');
                Commit();
                // rec.Status := rec.Status::"Sent For Approval";
                //rec.Modify();

            end;
        end;
        //end;


    end;
    // end;
    trigger OnOpenPage()
    var
        myInt: Integer;
        Invsetup: Record 313;
        locationRec: Record Location;
    begin
        //rec.Validate("No.");
        if locationRec.Get(Rec."To Location code") then begin
            if locationRec.IsStore = true then begin
                Setedit1 := false;
            end else begin
                Setedit1 := true;
            end;
        end;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        locationRec: Record Location;
        usersetup: Record "User Setup";
    begin
        usersetup.Get(UserId);
        if locationRec.Get(usersetup."Location Code") then begin
            if locationRec.IsStore = true then begin
                Setedit1 := false;
            end else begin
                Setedit1 := true;
            end;
        end;
        Rec.Type := Rec.Type::Item; //23Nov2023
    end;

    var
        Setedit1: Boolean;
        Invsetup: Record 313;
        locationRec: Record Location;

}