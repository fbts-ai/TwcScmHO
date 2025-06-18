page 51116 "Auto Create Invoice"
{
    PageType = List;
    Caption = 'Auto Create Invoice';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Purchase Header";
    CardPageId = "Purchase Invoice";
    //AutoSplitKey = true;
    SourceTableView = where("Response Details" = filter(true));

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = all;
                }
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.")
                {
                    ApplicationArea = all;
                }
                field("Buy-from Vendor Name"; Rec."Buy-from Vendor Name")
                {
                    ApplicationArea = all;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = all;
                }
                field("Assigned User ID"; Rec."Assigned User ID")
                {
                    ApplicationArea = all;
                }
                field("Response Details"; Rec."Response Details")
                {
                    ApplicationArea = all;
                }
                field(Amount; Rec.Amount)
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
            action("Get Response")
            {

                trigger OnAction()
                var
                    Cu: Codeunit "Global Codeunit";
                begin
                    // Cu.GetApiDetails();
                end;
            }

        }
    }
}

