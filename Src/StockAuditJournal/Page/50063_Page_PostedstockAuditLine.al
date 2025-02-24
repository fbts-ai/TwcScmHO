page 50063 "PostedStockAuditSubform"
{
    PageType = ListPart;
    // ApplicationArea = All;
    // UsageCategory = Lists;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    SourceTable = StockAuditLine;

    Caption = 'Stock Audit Subform';

    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;


    layout
    {
        area(Content)
        {
            repeater(Line)
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

                field(Quantity; Rec.Quantity)
                {
                    Editable = false;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field(NewUOM; Rec.NewUOM)
                {
                    Caption = 'Conversion UOM';

                }
                field(QtyperUOM; Rec.QtyperUOM)
                {
                    Caption = 'Qty Per UOM';
                }
                field(StockQty; Rec.StockQty)
                {
                    caption = 'Stock qty';
                }

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

                trigger OnAction();
                begin

                end;
            }
        }
    }
    var
        ItemList: Page "Item List";


    trigger OnAfterGetRecord()
    var
        ItemCategory: Record "Item Category";

    begin

    end;

}