page 50106 "Physical Qty. Setup"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Physical Qty. Setup";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Location Group"; "Location Group")
                {
                    ApplicationArea = All;

                }
                field(DAILY; DAILY)
                {
                    ApplicationArea = All;

                }
                field(MONTHLY; MONTHLY)
                {
                    ApplicationArea = All;

                }
                field(WEEKLY; WEEKLY)
                {
                    ApplicationArea = All;

                }
                field(QUARTERLY; QUARTERLY)
                {
                    ApplicationArea = all;
                }
                field(Formula; Formula)
                {
                    ApplicationArea = All;

                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        myInt: Integer;
}