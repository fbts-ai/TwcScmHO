pageextension 50051 CommonItemPageExtension extends "Item Card"
{
    layout
    {

        // Add changes to page layout here
        addlast(Item)
        {
            field(InstoreAllowed; Rec.InstoreAllowed)
            {
                Caption = 'Instore Allowed';
            }
            field(LocalPurchase; Rec.LocalPurchase)
            {
                Caption = 'Local Purchase allow';
            }
            field(IsFixedAssetItem; Rec.IsFixedAssetItem)
            {
                Caption = 'IsFixedAssetItem';
            }
            field(IsStoreProductionItem; Rec.IsStoreProductionItem)
            {
                caption = 'IsStoreProductionItem';
            }
        }

        // Add changes to page layout here
        addafter(Inventory)
        {
            field("Max Qty"; Rec."Max Qty")
            {
                ApplicationArea = all;
            }
            field("Min Qty"; Rec."Min Qty")
            {
                ApplicationArea = all;
            }
            field("Indent Unit of Measure"; rec."Indent Unit of Measure")
            {
                ApplicationArea = all;
            }

        }


    }

    actions
    {
        // Add changes to page actions here
        modify(PurchPricesandDiscounts)
        {
            Enabled = false;
        }
        addafter(PurchPricesandDiscounts)
        {
            action(TwcPrices)
            {
                ApplicationArea = Suite;
                Caption = 'TWC Purchase Prices';

                Image = Price;
                //Visible = not ExtendedPriceEnabled;
                RunObject = Page TwcPurchasePrices;
                RunPageLink = "Item No." = FIELD("No.");
                RunPageView = SORTING("Item No.");
                ToolTip = 'Set up purchase prices for the item. An item price is automatically granted on invoice lines when the specified criteria are met, such as vendor, quantity, or ending date.';

            }
        }
    }
    // trigger OnOpenPage()
    // var
    //     Usersetup: Record "User Setup";
    // begin
    //     if Usersetup.Get(UserId) then
    //         if Usersetup."Allow Master Modification" = false then begin
    //             CurrPage.Editable(false);
    //         end;
    // end;

    var
        myInt: Integer;
}