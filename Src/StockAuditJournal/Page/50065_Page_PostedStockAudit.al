page 50065 "Posted Stock Audit List"
{
    PageType = List;
    Caption = 'Posted Inventory Counting';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = StockAuditHeader;
    CardPageId = PostedStockAuditHeader;
    DeleteAllowed = false;
    Editable = false;
    SourceTableView = sorting("No.") order(descending) where(Status = const(Posted), Status = const(Rejected));

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

        }
    }

    var
        DD: Page 50;
        usersetup: Record "User Setup";

    trigger OnOpenPage()
    begin
        usersetup.Get(UserId);
        Rec.FilterGroup(2);
        IF usersetup."Location Code" <> '' then
            Rec.SetRange("Location Code", usersetup."Location Code");
        Rec.SetFilter(Status, '=%1', Rec.Status::Posted);
        Rec.FilterGroup(0);

    end;


}