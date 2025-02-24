page 50152 FAProcessedIndentCard
{
    PageType = Card;
    SourceTable = IndentHeader;
    Caption = 'FA Processed Indent Card';
    PromotedActionCategories = 'New," "," ",Process,Approval';
    Editable = false;

    layout
    {

        area(Content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    // Editable = false;
                    Editable = true;
                    trigger OnValidate()
                    var
                        myInt: Integer;
                    begin
                        if locationRec.Get(Rec."To Location code") then begin
                            if locationRec.IsStore = true then begin
                                Setedit1 := false;
                            end else begin
                                Setedit1 := true;
                            end;
                        end;
                    end;
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
                    Visible = true;
                    //RkAlle24Nov2023
                    trigger OnValidate()
                    var
                        LocationFrom: Record Location;
                    begin
                        if LocationFrom.Get(Rec."From Location Code") then
                            Rec."From Location Name" := LocationFrom.Name;
                    end;
                    //RkAlle24Nov2023
                }
                field("From Location Name"; Rec."From Location Name")
                {
                    ApplicationArea = all;
                    Visible = true;
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
                field(Category; Rec.Category)
                {
                    ApplicationArea = all;
                    Caption = 'FA Subclasses';
                    Editable = true;
                    TableRelation = if (Type = const("Fixed Asset")) "FA Subclass"; //RkAlle24Nov2023
                    // TableRelation = IF (Type = CONST(Item)) "Item Category".Code where("Indent Category" = const(true));
                    // else
                    //  if (Type = CONST("Fixed Asset")) "FA Subclass";
                    trigger OnValidate()
                    var
                        Item: Record "FA Subclass";
                        ItemforIndent: Record "Item For Indent" temporary;
                        FixedAssets: Record "Fixed Asset";
                        indentLine: Record Indentline;
                        ILE: Record "Item Ledger Entry";
                        IndentMappingsetup: Record "Indent Mapping";
                        indent: Record IndentHeader;
                        indent1: Record IndentHeader;
                        indentline1: Record Indentline;
                    begin
                        TestField(Status, Status::Open);
                        TestField("Posting date");
                        ItemforIndent.Reset();
                        IF ItemforIndent.FindSet() then
                            ItemforIndent.DeleteAll(true);

                        indent.Reset();
                        indent.SetRange("No.", Rec."No.");
                        if indent.FindFirst() then begin
                            if Rec.Type = Rec.Type::"Fixed Asset" then begin
                                FixedAssets.Reset();
                                FixedAssets.SetCurrentKey("FA Subclass Code");
                                FixedAssets.SetRange("FA Subclass Code", Rec.Category);
                                FixedAssets.SetRange("PO Item", true);
                                if FixedAssets.FindSet() then
                                    repeat
                                        ItemforIndent.Init();
                                        ItemforIndent."Item No." := FixedAssets."No.";
                                        ItemforIndent.Type := ItemforIndent.Type::"Fixed Asset";
                                        ItemforIndent.Description := FixedAssets.Description;
                                        ItemforIndent."Indent No." := Rec."No.";
                                        ItemforIndent."Item Category" := rec.Category;
                                        ItemforIndent."Stock In Hand" := 1;
                                        ItemforIndent."In-Transit" := 0;
                                        ItemforIndent.Insert();
                                    until FixedAssets.Next() = 0;

                                ItemforIndent.Reset();
                                ItemforIndent.SetFilter("Indent No.", Rec."No.");
                                IF ItemforIndent.FindSet() then;
                                Page.Run(50143, ItemforIndent);
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

            }
            part("FA Indent Line"; "FA Indent Line")
            {
                ApplicationArea = all;
                SubPageLink = "DocumentNo." = field("No.");

                UpdatePropagation = Both;
                Editable = false;
                // Editable = rec.Status = rec.Status::Open;
            }
        }
    }

    actions
    {
        area(Processing)
        {

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
        Rec.Type := Rec.Type::"Fixed Asset"; //23Nov2023
        Rec."Approval Required" := true;
    end;

    var
        Setedit1: Boolean;
        Invsetup: Record 313;
        locationRec: Record Location;

}