page 51018 "Posted GRN List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = GRN;
    SourceTableView = where("Create Invoice" = const(true));

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("GRN No."; Rec."GRN No.")
                {
                    ToolTip = 'Specifies the value of the GRN No. field.', Comment = '%';
                    ApplicationArea = all;
                }
                field("GRN Date"; Rec."GRN Date")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the GRN Date field.', Comment = '%';
                }
                field("Doc No."; Rec."Doc No.")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Doc No. field.', Comment = '%';
                }
                field("DC Date"; Rec."DC Date")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Doc No. field.', Comment = '%';
                }

                field("Purchase Order No."; Rec."Purchase Order No.")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Purchase Order No. field.', Comment = '%';
                }
                field("Create Invoice"; Rec."Create Invoice")
                {
                    ApplicationArea = all;
                    Editable = false;

                    ToolTip = 'Specifies the value of the Create Invoice field.', Comment = '%';
                }
                field("Invoice No."; Rec."Invoice No.")
                {
                    ApplicationArea = all;
                    Editable = false;

                    ToolTip = 'Specifies the value of the Invoice No. field.', Comment = '%';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Location Code field.', Comment = '%';
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Vendor No. field.', Comment = '%';
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Vendor Name field.', Comment = '%';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Item No. field.', Comment = '%';
                }
                field("Type"; Rec."Type")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Type field.', Comment = '%';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Quantity field.', Comment = '%';
                }
                field("Invoiced Qty"; Rec."Invoiced Qty")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Invoiced Qty field.', Comment = '%';
                }
                field("Qty. Rcd. Not Invoiced"; Rec."Qty. Rcd. Not Invoiced")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Qty. Rcd. Not Invoiced field.', Comment = '%';
                }
                field("GRN Rate"; Rec."GRN Rate")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the GRN Rate field.', Comment = '%';
                }
                field("GRN Amout Without GST"; Rec."GRN Amout Without GST")
                {
                    ApplicationArea = all;

                    ToolTip = 'Specifies the value of the GRN Amout Without GST field.', Comment = '%';
                }
                field("Vendor Invoice No."; Rec."Vendor Invoice No.")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Vendor Invoice No. field.', Comment = '%';
                }
                field("Vendor Invoice Date"; Rec."Vendor Invoice Date")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Vendor Invoice Date field.', Comment = '%';
                }
                field("PI Qty."; Rec."PI Qty.")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the PI Qty. field.', Comment = '%';
                }
                field("PI Rate"; Rec."PI Rate")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the PI Rate field.', Comment = '%';
                }
            }
        }
    }
}