page 50060 RegionWisePrices
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = InventoryCountingStaging;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(ItemNo; Rec.ItemNo)
                {
                    Caption = 'Item No.';
                }
                field(Region; Rec.Region)
                {
                    Caption = 'Region';
                }
                field(UnitCost; Rec.UnitCost)
                {
                    Caption = 'UnitCost';
                }

            }
        }

    }

    actions
    {

    }

    var
        myInt: Integer;
}