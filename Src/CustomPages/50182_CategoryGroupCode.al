page 50182 CategoryGroupCode
{
    PageType = List;
    Caption = 'Category Group Code';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = CategoryGroupCode;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(code_; Rec.code_)
                {
                    ApplicationArea = All;

                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = all;

                }
                field(GroupCode; Rec.GroupCode)
                {
                    ApplicationArea = all;
                }
            }
        }
        area(Factboxes)
        {

        }
    }
    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction();
                begin

                end;
            }
        }
    }
}