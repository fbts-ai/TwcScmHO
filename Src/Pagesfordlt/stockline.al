page 50116 "Dlt StockAuditLine"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = StockAuditLine;


    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Item Code"; Rec."Item Code")
                {
                    ApplicationArea = all;
                    // Editable = false;

                }
                field(Description; Rec.Description)
                {

                }
                field(UOM; Rec."Unit of Measure Code")
                {

                }
                field("Stock in hand"; "Stock in hand")
                {
                    ApplicationArea = all;
                }

                field(Quantity; Rec.Quantity)
                {
                    Editable = false;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field(NewUOM; Rec.NewUOM)
                {
                    Caption = 'Conversion UOM';
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field(QtyperUOM; Rec.QtyperUOM)
                {
                    Caption = 'Qty Per UOM';
                }
                field(StockQty; Rec.StockQty)
                {
                    caption = 'Physical Qty Inhand';
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                /*
                field(physicalQty; Rec."Qty. (Phys. Inventory)")
                {
                    caption = 'Qty. (Phys. Inventory)';
                }
                */

                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = all;
                }
                field("Reason Code"; Rec."Reason Code")
                {

                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        myInt: Integer;
}