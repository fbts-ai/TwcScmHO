page 50165 "Custom BOM Group"
{
    ApplicationArea = All;
    Caption = 'Custom BOM Group';
    PageType = List;
    SourceTable = "Custom BOM Group";
    UsageCategory = Lists;
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the value of the Code field.', Comment = '%';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
            }
        }
    }
}
