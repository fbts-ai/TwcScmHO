page 50070 ILELotPage
{
    PageType = list;
    ApplicationArea = All;
    UsageCategory = Administration;
    Editable = false;
    InsertAllowed = false;
    SourceTable = "Item Ledger Entry";

    layout
    {
        area(Content)
        {
            repeater(Control1100409000)
            {
                field(LotNo; Rec."Lot No.")
                {
                    ApplicationArea = All;

                }
                field(RemainingQuantity; Rec."Remaining Quantity")
                {
                    ApplicationArea = All;

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