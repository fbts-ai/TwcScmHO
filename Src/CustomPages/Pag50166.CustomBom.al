page 50166 "Custom Bom"
{
    // ApplicationArea = All;
    Caption = 'Custom Bom';
    PageType = ListPart;
    SourceTable = "Custom BOM Line";
    AutoSplitKey = true;
    // UsageCategory = Lists; 
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Child ItemNo."; Rec."Child ItemNo.")
                {
                    ToolTip = 'Specifies the value of the Child ItemNo. field.', Comment = '%';
                    trigger OnValidate()
                    var
                        Item: Record Item;
                    begin
                        if Item.Get("Child ItemNo.") then
                            Rec."Child Name" := Item.Description;
                        if Rec."Child ItemNo." = '' then
                            Rec."Child Name" := '';
                    end;
                }
                field("Child Name"; Rec."Child Name")
                {
                    ToolTip = 'Specifies the value of the Child ItemNo. field.', Comment = '%';
                    Caption = 'Child Item Name';
                    Editable = false;
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ToolTip = 'Specifies the value of the Unit of Measure field.', Comment = '%';
                    // TableRelation = Item."Base Unit of Measure" where("No." = field("Child ItemNo."));


                }
                field("Actual Qty."; Rec."Actual Qty.")
                {
                    ToolTip = 'Specifies the value of the Quantity per field.', Comment = '%';
                }
                field("Wastage %"; Rec."Wastage %")
                {
                    ToolTip = 'Specifies the value of the Quantity per field.', Comment = '%';
                }
                field("Quantity per"; Rec."Quantity per")
                {
                    ToolTip = 'Specifies the value of the Quantity per field.', Comment = '%';
                }
            }
        }
    }
}
