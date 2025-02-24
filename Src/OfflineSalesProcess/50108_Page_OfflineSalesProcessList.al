page 50108 OfflineSalesProcessList
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = StockAuditHeader;
    CardPageId = OfflineSalesHeader;
    Editable = false;
    Caption = 'Agave Inventory Counting List';
    //SourceTableView = sorting("No.") order(descending) where(Status  const(Posted));

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
        //AJ_Alle_09052023
        if UserSetup.StoreLive = true then
            Error('Store is Live ,You do not have permission open this page');
        //AJ_Alle_09052023
        Rec.FilterGroup(2);
        Rec.SetRange("Location Code", usersetup."Location Code");
        Rec.SetRange(OfflineSales, true);
        Rec.SetFilter(Status, '<>%1', Rec.Status::Posted);
        Rec.FilterGroup(0);


    end;


}