page 50015 IndentProcessingCard
{
    PageType = Card;
    //ApplicationArea = All;
    //  UsageCategory = Lists;
    SourceTable = IndentHeader;
    Caption = 'Indent Card';
    PromotedActionCategories = 'New," "," ",Process,Approval';
    // InsertAllowed = false; //AJ_ALLE_020102024
    //  ModifyAllowed = false;
    //DeleteAllowed = true;


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
                    Editable = false;

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
                    Editable = false;

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
                //AJ_ALLE_020102024
                field("Reject Reason"; "Reject Reason")
                {
                    ApplicationArea = all;
                    Editable = true;
                }
                //AJ_ALLE_020102024
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

                field(Category; Rec.Category)
                {
                    ApplicationArea = all;
                    Editable = false;
                    TableRelation = IF (Type = CONST(Item)) "Item Category".Code where("Indent Category" = const(true));
                    trigger OnValidate()
                    var
                        Item: Record Item;
                        ItemforIndent: Record "Item For Indent";
                        indentLine: Record Indentline;
                        ILE: Record "Item Ledger Entry";
                        IndentMappingsetup: Record "Indent Mapping";
                        indent: Record IndentHeader;
                    begin
                        TestField("Posting date");
                        ItemforIndent.DeleteAll();

                        indent.Reset();
                        indent.SetRange("No.", Rec."No.");
                        if indent.FindFirst() then begin
                            if Rec.Type = Rec.Type::Item then begin
                                Item.reset;
                                Item.SetRange("Item Category Code", rec.Category);
                                if item.FindFirst() then
                                    repeat
                                        IndentMappingsetup.Reset();
                                        IndentMappingsetup.SetRange("Location Code", Rec."To Location code");
                                        IndentMappingsetup.SetRange("Item No.", Item."No.");
                                        IndentMappingsetup.SetRange("Item Category", Item."Item Category Code");
                                        IF IndentMappingsetup.FindFirst() then begin
                                            ItemforIndent.Init();
                                            ItemforIndent.Type := ItemforIndent.Type::Item;
                                            ItemforIndent."Item No." := Item."No.";
                                            ItemforIndent.Description := Item.Description;
                                            ItemforIndent."Unit of Measure" := Item."Base Unit of Measure";
                                            ItemforIndent."Indent No." := rec."No.";
                                            ItemforIndent."Item Category" := rec.Category;
                                            Item.CalcFields(Inventory);
                                            ItemforIndent."Stock In Hand" := Item.Inventory;

                                            ILE.Reset();
                                            ILE.SetRange("Item No.", Item."No.");
                                            ILE.SetRange("Entry Type", ILE."Entry Type"::Transfer);
                                            IF ILE.FindSet() then begin
                                                ILE.CalcSums(Quantity);


                                            end;
                                            ItemforIndent."In-Transit" := ILE.Quantity;
                                            ItemforIndent.Insert();
                                        end;

                                    until Item.Next() = 0;
                                Page.Run(50014, ItemforIndent);
                                Rec.Category := '';
                                Rec.Modify();
                            end;
                        end;
                    end;

                }

                field("Main Indent No."; rec."Main Indent No.")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Sub-Indent"; rec."Sub-Indent")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Approval Required"; rec."Approval Required")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Approved By"; rec."Approved By")
                {
                    ApplicationArea = all;
                    Editable = false;
                }



            }
            part(IndentLine; "Indent Line")
            {
                ApplicationArea = all;
                SubPageLink = "DocumentNo." = field("No.");
                UpdatePropagation = Both;
                Editable = false;
                // Editable = rec.Status = rec.Status::Open;
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
            MailList.Add(currentuser."E-Mail");
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
                rec.Status := rec.Status::"Sent For Approval";
                rec.Modify();

            end;
        end;
        //end;


    end;


    // end;
}