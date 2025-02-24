page 50113 "Purchase Comment"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = CommentLine;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Sr No."; "Sr No.")
                {
                    ApplicationArea = All;

                }
                field(Comments; Comments)
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