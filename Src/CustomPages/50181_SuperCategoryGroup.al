page 50181 SuperCategoryGroup
{
    PageType = List;
    Caption = 'Super Category Group';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = SuperCategoryGroup;

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
            action("Product Sub Group")
            {
                ApplicationArea = All;
                Caption = 'Product Sub Group';

                trigger OnAction();
                begin
                    Page.Run(50101);
                end;
            }
        }
    }
}