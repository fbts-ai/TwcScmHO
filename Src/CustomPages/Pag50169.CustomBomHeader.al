page 50169 CustomBom_Header
{
    // ApplicationArea = All;
    Caption = 'Custom Bom';
    PageType = Card;
    SourceTable = "Custom BOM_Header";
    UsageCategory = Documents;
    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("BOM Code"; Rec."BOM Code")
                {
                    ToolTip = 'Specifies the value of the BOM Code field.', Comment = '%';
                }
                field("BOM Status"; Rec."BOM Status")
                {
                    ToolTip = 'Specifies the value of the BOM Status field.', Comment = '%';
                }
                field("Custom BOM Group"; Rec."Custom BOM Group")
                {
                    ToolTip = 'Specifies the value of the Custom BOM Group field.', Comment = '%';
                    TableRelation = "Custom BOM Group";
                }
                field("Parent Item No."; Rec."Parent Item No.")
                {
                    ToolTip = 'Specifies the value of the Parent Item No. field.', Comment = '%';

                    trigger OnValidate()
                    var
                        Item: Record Item;
                    begin
                        if Item.Get("Parent Item No.") then
                            Rec."Parent Item Name" := Item.Description;
                        if Rec."Parent Item No." = '' then
                            Rec."Parent Item Name" := '';
                    end;
                }
                field("Parent Item Name"; "Parent Item Name")
                {
                    ToolTip = 'Specifies the value of the Parent Item No. field.', Comment = '%';
                    Editable = false;
                }
            }
            part(Lins; "Custom BOM")
            {
                SubPageLink = "BOM Code" = field("BOM Code");
                ApplicationArea = all;
            }
        }
    }
    // trigger OnQueryClosePage(CloseAction: Action): Boolean
    // var
    //     myInt: Integer;
    // begin
    //     Rec.TestField("Custom BOM Group");
    //     Rec.TestField("Parent Item No.");
    // end;
    trigger OnClosePage()
    var
        myInt: Integer;
    begin
        Rec.TestField("Custom BOM Group");
        Rec.TestField("Parent Item No.");
    end;
}
