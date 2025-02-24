page 50110 "OfflineSalesLine"
{
    PageType = ListPart;
    // ApplicationArea = All;
    // UsageCategory = Lists;
    //Editable = false;
    SourceTable = StockAuditLine;
    Caption = 'Agave Sales Subform';

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

                /*
                                field(NewUOM; Rec.NewUOM)
                                {
                                    Caption = 'Conversion UOM';
                                    trigger OnValidate()
                                    begin
                                        CurrPage.Update();
                                    end;
                                }
                */
                field(QtyperUOM; Rec.QtyperUOM)
                {
                    Caption = 'Qty Per UOM';
                }
                field(physicalQty; Rec."Qty. (Calculated)")
                {
                    caption = 'Stock in Hand';
                    Editable = False;
                }
                field(StockQty; Rec.StockQty)
                {
                    caption = 'Physical Qty Inhand';
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field(Quantity; Rec.Quantity)
                {
                    Editable = false;
                    Caption = 'Sold Qunatity';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
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