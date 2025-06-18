page 50163 "Consolidate Indent List"
{
    PageType = List;
    SourceTable = "Consolidate indent Header";
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "Consolidate Indent Card";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                }
                field("Delivery Date"; "Delivery Date")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
        }
        area(navigation)
        {
        }
    }
}
