page 50068 "StockAuditList"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = StockAuditHeader;
    CardPageId = StockAuditHeader;
    Editable = false;
    Caption = 'Inventory Counting Line';
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
                field("Inventory Type"; Rec."Inventory Type")//Aashish-18/10/2024
                {
                    ApplicationArea = all;
                }
                field(SystemCreatedAt; SystemCreatedAt) //Aashish-18/10/2024
                {
                    ApplicationArea = all;
                    Caption = 'Create Time';
                }

                field("Sand Date&Time"; "Sand Date&Time") //Aashish-18/10/2024
                {
                    ApplicationArea = all;
                    Caption = 'Send Date & Time';
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
        Rec.SetRange(OfflineSales, false);
        Rec.SetFilter(Status, '<>%1', Rec.Status::Posted);
        Rec.FilterGroup(0);

    end;

    trigger OnInit()
    var
        myInt: Integer;
    begin
        IF not Confirm(StrSubstNo('Click on "YES" button if you have completed the pending Transfer IN/OUT, Wastage Entry otherwise Click on "NO" button', false)) then
            Error('Please complete your Transfer IN/OUT, Wastage Entry then proceed for Physical Stock Entry')
        else
            CurrPage.Close();
    end;


}