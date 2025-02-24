page 50102 TwcMDMRoleCenter
{
    Caption = 'TWC MDM Role Center';
    PageType = RoleCenter;
    UsageCategory = None;


    layout
    {
        area(rolecenter)
        {
            group(Control1900724808)
            {
                ShowCaption = false;
                /*
                part(Control1907692008; "My Items")
                {
                    ApplicationArea = RelationshipMgmt;
                }
                */
            }
            group(Control1900724708)
            {
                ShowCaption = false;
                /*
                part(Control11; "My customers")
                {
                    ApplicationArea = RelationshipMgmt;
                }
                */

            }
        }
    }

    actions
    {
        area(reporting)
        {


        }
        area(embedding)
        {
            action(Items)
            {
                ApplicationArea = All;
                Caption = 'Item List';
                Image = Item;
                RunObject = Page "Item List";
                ToolTip = 'Item list';
            }
            action(Vendor)
            {
                ApplicationArea = All;
                Caption = 'Vendors';
                Image = Vendor;
                RunObject = Page "Vendor List";
                ToolTip = 'Vendor List';
            }
            action(Customer)
            {
                ApplicationArea = All;
                Caption = 'Customer List';
                Image = Customer;
                RunObject = Page "Customer List";
                ToolTip = 'Customer List';
            }

            action(Location)
            {
                ApplicationArea = All;
                Caption = 'Locations';
                RunObject = Page "Production BOM List";
                ToolTip = 'Production BOM List';
            }
            action(BomComponent)
            {
                ApplicationArea = All;
                Caption = 'BOM Component';
                Image = BOM;
                RunObject = Page "Production BOM List";
                ToolTip = 'Production BOM List';
            }
            action(ItemModifier)
            {
                ApplicationArea = All;
                Caption = 'LSC Item Modifier List';
                Image = Order;
                RunObject = Page "LSC Item Modifier List";
                ToolTip = 'LSC Item Modifier List';
            }

            action(ItemCategory)
            {
                ApplicationArea = All;
                Caption = 'Item Category ';
                RunObject = Page "Item Categories";
                ToolTip = 'Item Category';
            }
            action(ItemDivision)
            {
                ApplicationArea = All;
                Caption = 'Divisions';
                RunObject = Page "LSC Divisions";
                ToolTip = 'LSC Divisions';
            }
            action(TwcPurchasePrices)
            {
                ApplicationArea = All;
                Caption = 'Twc Purchase Prices';
                RunObject = Page TwcPurchasePrices;
                ToolTip = 'TwcPurchasePrices';
            }
            action(salesPrices)
            {
                ApplicationArea = All;
                Caption = 'Sales prices';
                RunObject = Page "Sales Prices";
                ToolTip = 'Sales Prices';
            }
            action(indentMapping)
            {
                ApplicationArea = All;
                Caption = 'Indent Mapping setup';
                RunObject = Page "Indent Mapping Setup";
                ToolTip = 'Indent Mapping Setup';
            }
            action(userSetup)
            {
                ApplicationArea = All;
                Caption = 'User setup';
                RunObject = Page "User Setup";
                ToolTip = 'User Setup';
            }
            action(UOM)
            {
                ApplicationArea = All;
                Caption = 'unit of measure';
                RunObject = Page "Units of Measure";
                ToolTip = 'Unit of measure';
            }








        }
        area(sections)
        {
            group("PostedDocuments")
            {
                Caption = 'Posted Document';
                Image = AdministrationSalesPurchases;
                action(Postedstatement)
                {
                    ApplicationArea = All;
                    Caption = 'LSC Posted Statement List';
                    Image = "Order";
                    RunObject = Page "LSC Posted Statement List";
                    ToolTip = 'LSC Posted Statement List';
                }
                action(fininishedProduction)
                {
                    ApplicationArea = All;
                    Caption = 'Finished Production Order List';
                    Image = "Order";
                    RunObject = Page "Finished Production Orders";
                    ToolTip = 'Finished Production Order List';
                }
                action("Posted Wastage Entry")
                {
                    ApplicationArea = All;
                    Caption = 'Posted Wastage Entry';
                    Image = "Order";
                    RunObject = Page "PostedWastage Entry List";
                    ToolTip = 'Posted Wastage Entry';
                }

                action("Posted Stock Audit")
                {
                    ApplicationArea = All;
                    Caption = 'Posted Stock Audit List';
                    Image = "Order";
                    RunObject = Page "Posted Stock Audit List";
                    ToolTip = 'Posted Stock Audit';
                }
                action(PostedTransferShipment)
                {
                    ApplicationArea = All;
                    Caption = 'Posted Transfer Shipments';
                    Image = "Order";
                    RunObject = Page "Posted Transfer Shipments";
                    ToolTip = 'Posted Transfer Shipments';
                }
                action(PostedTransferReceipt)
                {
                    ApplicationArea = All;
                    Caption = 'Posted Transfer Receipts';
                    Image = "Order";
                    RunObject = Page "Posted Transfer Receipts";
                    ToolTip = 'Posted Transfer Receipts';
                }


            }
        }
        area(processing)
        {
            separator(Action48)
            {
                Caption = 'Tasks';
                IsHeader = true;
            }





        }
    }
}

