page 50123 "Quarantine Approval"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Transfer Header";
    CardPageId = "Quarantine Card";
    //Editable = tru;
    InsertAllowed = false;
    Caption = 'Quanrantine Approval';
    SourceTableView = sorting("No.") order(descending) where(Status_ = const("Sent For Approval"));

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

                field("Posting date"; rec."Posting date")
                {
                    ApplicationArea = all;
                    Caption = 'Requested Delivery Date';
                    Editable = false;
                }
                field("Assigned User ID"; "Assigned User ID")
                {
                    //Editable = false;
                    Visible = false;
                    ApplicationArea = all;
                }
                field(Remarks; rec.Remarks)
                {
                    ApplicationArea = all;
                    Editable = true;
                }
                // field(Status; Rec.Status)
                // {
                //     ApplicationArea = all;
                // }

            }
        }

    }
    actions
    {

        area(Processing)
        {

            action(Aprove)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                Image = Approval;
                trigger OnAction()
                begin
                    Rec.Status_ := Rec.Status_::Approved;
                    Rec.Status := rec.Status::Released;
                    Rec.Modify();
                end;

            }
            action(Reject)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                Image = Cancel;
                trigger OnAction()
                begin
                    if rec.Remarks = '' then
                        Error('Please Add Reason for Rejection');
                    rec.Status_ := rec.Status_::Rejected;
                    rec.Modify();
                end;

            }
        }
    }

    var
        DD: Page 50;
        usersetup: Record "User Setup";
        Test: page "Item Ledger Entries";

    trigger OnOpenPage()
    begin
        usersetup.Get(UserId);
        Rec.FilterGroup(2);
        //Rec.SetRange("To Location Code", usersetup."Quarantine Location");
        rec.SetRange(Status_, rec.Status_::"Sent For Approval");
        rec.SetRange("Quaratine Location", true);
        rec.SetRange("Assigned User ID", usersetup."User ID");
        // IF usersetup."Location Code" <> '' then
        //     Rec.SetRange("Location Code", usersetup."Location Code");
        // IF usersetup."Quarantine Location" <> '' then
        //     Rec.SetRange(RejectionRemark, usersetup."Quarantine Location");
        //Rec.SetRange(OfflineSales, false);
        // Rec.SetFilter(Status, '%1', Rec.Status::PendingApproval);
        //rec.SetFilter("No.", '%1', 'QTR*');
        //Rec.FilterGroup(0);

    end;


}