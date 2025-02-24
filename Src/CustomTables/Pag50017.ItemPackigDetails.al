page 50168 "Item Packig Details"
{
    ApplicationArea = All;
    Caption = 'Item Packig Details';
    PageType = List;
    SourceTable = "Item Packing Details";
    UsageCategory = Lists;


    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Sales Type"; "Sales Type")
                {
                    ToolTip = 'Specifies the value of the Quantity per field.', Comment = '%';
                    TableRelation = "LSC Sales Type";
                }
                field("Parent Item No."; Rec."Parent Item No.")
                {
                    ToolTip = 'Specifies the value of the Parent Item No. field.', Comment = '%';
                }
                field("Child Item No."; Rec."Child Item No.")
                {
                    ToolTip = 'Specifies the value of the Child Item No. field.', Comment = '%';
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ToolTip = 'Specifies the value of the Unit of Measure field.', Comment = '%';
                    TableRelation = Item."Base Unit of Measure" where("No." = field("Child Item No."));
                    // trigger OnValidate()
                    // var
                    //     UOM: Record "Item Unit of Measure";
                    //     Items: Record Item;
                    // begin
                    //     Items.Reset();
                    //     Items.SetRange("No.", Rec."Child Item No.");
                    //     if Items.FindFirst() then
                    //         Rec.Validate("Unit of Measure", Items."Base Unit of Measure");
                    //     Rec.Modify();
                    // end;

                }

                field("Quantity per"; Rec."Quantity per")
                {
                    ToolTip = 'Specifies the value of the Quantity per field.', Comment = '%';
                }
            }
        }
    }
}
