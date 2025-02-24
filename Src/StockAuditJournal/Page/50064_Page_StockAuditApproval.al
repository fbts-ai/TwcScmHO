page 50064 "Stock Audit Approval Page"
{
    PageType = List;
    ApplicationArea = All;
    Caption = 'Inventory Counting Approval';
    UsageCategory = Lists;
    SourceTable = StockAuditHeader;
    CardPageId = StockAuditHeader;
    DeleteAllowed = False;
    Editable = false;
    SourceTableView = sorting("No.") order(descending) where(Status = filter(PendingApproval));

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
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = all;
                    Editable = false;
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
                field(Status; Rec.Status)
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
            action(Approve)
            {
                ApplicationArea = all;

                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = Approve;
                trigger OnAction()
                var
                    tempusersetup: Record "User Setup";

                begin

                    IF Confirm('Are sure you want approve selected Stock Audit Card', true) then begin
                        IF Rec.Status = Rec.Status::PendingApproval then begin

                            Rec.Status := Rec.Status::Approved;
                            Rec.Modify();

                            CurrPage.Update();

                        end else
                            Error('Status must be pending for approval');
                    end;
                end;


            }
            action(Reject)
            {
                ApplicationArea = all;

                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = Approve;
                trigger OnAction()
                var
                    tempusersetup: Record "User Setup";
                    MyDialog: Dialog;
                    TempInputDialogPage: Page StkRejectionInputDialogPage;

                begin

                    IF Confirm('Are you sure to Reject selected Stock Audit ', true) then begin
                        IF Rec.Status = Rec.Status::PendingApproval then begin

                            // TempInputDialogPage.RunModal()
                            TempInputDialogPage.setstockAudit(Rec);
                            if TempInputDialogPage.RunModal() = Action::OK then begin
                                IF Rec.RejectionRemark = '' Then
                                    Error('It is mandatory to enter stock audit rejection remark');
                                Message('StockAudit is rejected');
                            end;
                            CurrPage.Update();


                        end else
                            Error('Status must be pending for approval');
                    end;
                end;


            }
        }
    }

    var

        usersetup: Record "User Setup";

    trigger OnOpenPage()
    begin
        usersetup.Get(UserId);
        Rec.FilterGroup(2);
        // Rec.SetRange("Location Code", usersetup."Location Code");
        Rec.SetRange(ApproverID, UserId);
        Rec.FilterGroup(0);

    end;


}