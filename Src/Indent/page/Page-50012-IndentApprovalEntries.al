page 50012 "Indent Approval Entries"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = IndentHeader;
    CardPageId = IndentProcessingCard;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    SourceTableView = sorting("No.") order(descending) where("Sub-Indent" = const(false), "Approval Required" = const(true), Status = filter("Sent for Approval"));

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("To Location code"; "To Location code")
                {
                    ApplicationArea = all;
                }
                field("Reject Reason"; rec."Reject Reason")
                {
                    ApplicationArea = all;
                }


                field(Status; Rec.Status)
                {
                    ApplicationArea = all;
                }
                field("Posting date"; rec."Posting date")
                {
                    ApplicationArea = all;
                    Caption = 'Requested Delivery Date';
                }
                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = all;
                }
                field("CreatedBy"; Rec."CreatedBy")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Sub-Indent"; rec."Sub-Indent")
                {
                    ApplicationArea = all;
                }

            }
        }

    }
    actions
    {
        area(Processing)
        {
            action("Approve Indent")
            {
                ApplicationArea = all;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = Approve;
                trigger OnAction()
                var
                    IndentLine: Record Indentline;
                    IndentHdr: Record IndentHeader;
                    usersetup: Record "User Setup";
                    Invsetup: Record "Inventory Setup";
                    dur: Duration;
                    submitdatetime: DateTime;
                    approvadatetime: DateTime;
                begin
                    Clear(submitdatetime);
                    //PT-FBTS 03-07-2024
                    if Rec."Created Date" < Today then
                        Error('The Indet has expired. You cannot approve a backdated indent.');
                    Rec."Approved/Reject" := CurrentDateTime; //PT-FBTS
                    //PT-FBTS 03-07-2024
                    Invsetup.Get();

                    submitdatetime := system.CreateDateTime(Rec."Submit Date", Rec."Submit Time");

                    approvadatetime := System.CreateDateTime(Today, Invsetup."Area Manager Timelines");
                    //  dur := CurrentDateTime - submitdatetime;

                    //IF dur <> 0 then begin
                    IF approvadatetime < CurrentDateTime then begin
                        Rec.Status := Rec.Status::Rejected;
                        Rec."Reject Reason" := 'Area manager timelines exceeded';
                        Rec.Modify();
                        Message('You are not allowed to approve as timelines are closed');
                        // end;
                    end;
                    //end;



                    If usersetup.Get(rec.CreatedBy) then;

                    IF UserId <> usersetup."Indent Approver ID" then
                        Error('You are not authorised to approve');

                    Rec.TestField("Reject Reason", '');
                    Rec."Approved By" := UserId;
                    Rec."Approval Required" := false;
                    rec.Modify(true);

                    IndentLine.Reset();
                    IndentLine.SetRange("DocumentNo.", Rec."No.");
                    IF IndentLine.FindFirst() then begin
                        IndentLine."Approval Required" := false;
                        IndentLine.Modify();
                    end;


                    IndentHdr.Reset();
                    IndentHdr.SetRange("No.", Rec."No.");
                    IF IndentHdr.FindFirst() then
                        Report.Run(50000, false, false, IndentHdr);

                    Message('Successfully Approved');
                end;
            }
            action("Reject Indent")
            {
                ApplicationArea = all;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = Reject;
                trigger OnAction()
                var
                    IndentLine: Record Indentline;

                    usersetup: Record "User Setup";
                    Invsetup: Record "Inventory Setup";
                    dur: Duration;
                    submitdatetime: DateTime;
                    approvadatetime: DateTime;
                begin
                    //AJ_ALLE_020102024
                    if Rec."Reject Reason" = '' then Error('Reject Reason Is Mandatoty');
                    //AJ_ALLE_020102024
                    Clear(submitdatetime);
                    Invsetup.Get();

                    submitdatetime := system.CreateDateTime(Rec."Submit Date", Rec."Submit Time");

                    approvadatetime := System.CreateDateTime(Today, Invsetup."Area Manager Timelines");
                    //  dur := CurrentDateTime - submitdatetime;

                    //IF dur <> 0 then begin
                    IF approvadatetime < CurrentDateTime then begin
                        Rec.Status := Rec.Status::Rejected;
                        Rec."Reject Reason" := 'Area manager timelines exceeded';
                        Rec.Modify();
                        Message('You are not allowed to reject as timelines are closed');
                    end;
                    // end;


                    If usersetup.Get(rec.CreatedBy) then;

                    IF UserId <> usersetup."Indent Approver ID" then
                        Error('You are not authorised to reject');

                    //Rec.TestField("Reject Reason", '');
                    Rec.Status := Rec.Status::Rejected;
                    rec.Modify(true);

                    IndentLine.Reset();
                    IndentLine.SetRange("DocumentNo.", Rec."No.");
                    IF IndentLine.FindFirst() then begin
                        IndentLine.Status := IndentLine.Status::Rejected;
                        IndentLine.Modify();
                    end;
                end;
            }
        }
    }
    ///added by mahendra for approval entries filter 08 July
    trigger OnOpenPage()
    var
        usersetup: Record "User Setup";
    begin
        usersetup.Get(UserId);
        Rec.FilterGroup(2);
        // Rec.SetRange("Location Code", usersetup."Location Code");
        Rec.SetRange(Rec."Approver Name", UserId);
        Rec.FilterGroup(0);

    end;


}