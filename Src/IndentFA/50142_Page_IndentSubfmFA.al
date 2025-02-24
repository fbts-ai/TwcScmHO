page 50142 "FA Indent Line"
{
    PageType = ListPart;
    SourceTable = Indentline;
    Caption = 'Fixed Asset Indent Subform';
    // SourceTableView = where(Status = filter(<> 'Processed'));

    layout
    {
        area(Content)
        {
            repeater(Line)
            {
                field("Type Of Item"; Rec."Type Of Item")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Item Code"; rec."Item Code")
                {
                    ApplicationArea = all;
                    Editable = false;
                    Caption = 'Fixed Asset No.';
                }
                field("Item UOM"; rec."Item UOM")
                {
                    ApplicationArea = all;
                    Editable = false;
                    Visible = false;
                }
                field("Item UOM Qty.of measure"; rec."Item UOM Qty.of measure")
                {
                    ApplicationArea = all;
                    Editable = false;
                    Visible = false;
                }
                field(UOM; rec.UOM)
                {
                    Caption = 'Indent UOM';
                    ApplicationArea = all;
                    Editable = false;
                    Visible = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("FA Subclass"; Rec."FA Subclass")
                {
                    ApplicationArea = all;
                }
                field(Department; rec.Department)
                {
                    ApplicationArea = all;
                    Visible = false;
                }

                field("Sub-Indent"; rec."Sub-Indent")
                {
                    ApplicationArea = all;
                    Visible = false;
                }
                field(Select; Rec.Select)
                {
                    ApplicationArea = all;
                    Visible = false;
                }
                field("Request Delivery Date"; Rec."Request Delivery Date")
                {
                    ApplicationArea = all;
                    Editable = false;
                    Visible = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = all;
                    Visible = false;
                }

                field(Error; rec.Error)
                {
                    ApplicationArea = all;
                    Visible = false;
                }
                field("LineNo."; Rec."LineNo.")
                {
                    ApplicationArea = all;
                    Visible = false;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = all;
                    trigger OnValidate()
                    var
                        Item: Record Item;
                    begin
                        Rec.TestField(Quantity, 1);
                    end;

                }
                field("FA Qty. to Ship"; "FA Qty. to Ship")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("FA Qty. Shipped"; "FA Qty. Shipped")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = all;

                }
                field("Approval Required"; rec."Approval Required")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Approval Remarks"; rec."Approval Remarks")
                {
                    ApplicationArea = all;
                    Editable = false;
                }


            }
        }

    }


    var
        ItemList: Page "Item List";

    trigger OnAfterGetRecord()
    var
    begin

    end;

}