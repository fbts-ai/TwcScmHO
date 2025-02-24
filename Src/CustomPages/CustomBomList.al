page 50170 "Custom Bom List"
{
    ApplicationArea = All;
    Caption = 'Custom Bom List';
    PageType = List;
    SourceTable = "Custom BOM_Header";
    UsageCategory = Lists;
    CardPageId = CustomBom_Header;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("BOM Code"; Rec."BOM Code")
                {
                    ToolTip = 'Specifies the value of the BOM Code field.', Comment = '%';
                }
                field("Custom BOM Group"; Rec."Custom BOM Group")
                {
                    ToolTip = 'Specifies the value of the Custom BOM Group field.', Comment = '%';
                }
                field("BOM Status"; Rec."BOM Status")
                {
                    ToolTip = 'Specifies the value of the BOM Status field.', Comment = '%';
                }
                field("Parent Item No."; Rec."Parent Item No.")
                {
                    ToolTip = 'Specifies the value of the Parent Item No. field.', Comment = '%';
                }
                field("Parent Item Name"; "Parent Item Name")
                {
                    ToolTip = 'Specifies the value of the Parent Item No. field.', Comment = '%';
                }

            }
        }
    }
}
