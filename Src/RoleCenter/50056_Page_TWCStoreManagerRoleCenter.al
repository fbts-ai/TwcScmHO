page 50056 "TWC Store Manager Role Center"
{
    Caption = 'TWC Store Manager';
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

            action(Report1)
            {
                /*
                ApplicationArea = Suite;
                Caption = 'Salesperson - &Commission';
                Image = "Report";
                RunObject = Report "Salesperson - Commission";
                ToolTip = 'View a list of invoices for each salesperson for a selected period. The following information is shown for each invoice: Customer number, sales amount, profit amount, and the commission on sales amount and profit amount. The report also shows the adjusted profit and the adjusted profit commission, which are the profit figures that reflect any changes to the original costs of the goods sold.';
                */
            }
            separator(Action22)
            {
            }
            action(Report2)
            {
                ApplicationArea = RelationshipMgmt;
                Caption = 'Campaign - &Details';
                Image = "Report";
                RunObject = Report "Campaign - Details";
                ToolTip = 'Show detailed information about the campaign.';
            }
        }
        area(embedding)
        {
            action(Indent)
            {
                ApplicationArea = All;
                Caption = 'Indent List';
                Image = "Order";
                RunObject = Page "Indent List";
                ToolTip = 'Indent list';
            }
            action(WastageEntry)
            {
                ApplicationArea = All;
                Caption = 'Wastage Entry List';
                Image = "Order";
                RunObject = Page "Wastage Entry List";
                ToolTip = 'Wastage Entry List';
            }
            action(AgavaeInventoryCounting)
            {
                ApplicationArea = All;
                Caption = 'Agave Inventory Counting List';
                Image = "Order";
                RunObject = Page OfflineSalesProcessList;
                ToolTip = 'Agave Inventory Counting List';
            }
            action(InventoryCounting)
            {
                ApplicationArea = All;
                Caption = 'Inventory Counting List';
                Image = "Order";
                RunObject = Page StockAuditList;
                ToolTip = 'Inventory Counting List';
            }
            action("Pending GRN Lists")
            {
                ApplicationArea = RelationshipMgmt;
                Caption = 'Pending GRN Lists';
                RunObject = Page "Purchase Order GRN List";
                ToolTip = 'Pending GRN Lists';
            }
            action("Transfer In")
            {
                ApplicationArea = All;
                Caption = 'Pending In Transfer';
                RunObject = Page "InTransferOrderList";
                ToolTip = 'Pending Transfer In Orders.';
            }
            action("Transfer Out")
            {
                ApplicationArea = All;
                Caption = 'Pending Out Transfer';
                RunObject = Page "OutTransferOrderList";
                ToolTip = 'Out Transfer';
            }
            action("Interstore Transfer")
            {
                ApplicationArea = RelationshipMgmt;
                Caption = 'InterStore Transfer';
                Image = Quote;
                RunObject = Page "InStore Transfer Order List";
                ToolTip = 'For Inter Store Direct Transfer';
            }
            action(LocalPurchase)
            {
                ApplicationArea = All;
                Caption = 'Local Purchase Order List';
                Image = "Order";
                RunObject = Page "Local Purchase Order List";
                ToolTip = 'Local Purchase Order List';
            }
            action(RSTNTransferOrder)
            {
                ApplicationArea = All;
                Caption = 'RSTN Transfer Order List';
                Image = "Order";
                RunObject = Page "RSTN Transfer Order List";
                ToolTip = 'RSTN Transfer Order List';
            }

            action(ProductionOrders)
            {
                ApplicationArea = All;
                Caption = ' Released Prod. Order List';
                Image = "Order";
                RunObject = Page "Released Production Orders";
                ToolTip = 'Released Prod. Order List';
            }

            action(PurchaseOrders)
            {
                ApplicationArea = All;
                Caption = 'Purchase Order List';
                Image = "Order";
                RunObject = Page "Purchase Order List";
                ToolTip = 'Purchase Order List';
            }
            action(PurchaseReturn)
            {
                ApplicationArea = All;
                Caption = 'Purchase Return Orders';
                Image = "Order";
                RunObject = Page "Purchase Return Orders";
                ToolTip = 'Purchase Return Orders';
            }
            //TodayFixedasset
            action("Indent List FA")
            {
                ApplicationArea = All;
                Caption = 'Indent List FA';
                Image = "Order";
                RunObject = Page "Indent List FA";
                ToolTip = 'Twc Indent List FA';
            }
            action("FA Direct Transfer Orders")
            {
                ApplicationArea = All;
                Caption = 'FA Direct Transfer Orders';
                Image = "Order";
                RunObject = Page "FA Direct Transfer Orders";
                ToolTip = 'Twc FA Direct Transfer Orders';
            }
            //TodayFixedasset




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
                action("Posted Wastage Entry")
                {
                    ApplicationArea = All;
                    Caption = 'Posted Wastage Entry';
                    Image = "Order";
                    RunObject = Page "PostedWastage Entry List";
                    ToolTip = 'Posted Wastage Entry';
                }

                action("PostedStockAudit")
                {
                    ApplicationArea = All;
                    Caption = 'Posted Inventory Counting List';
                    Image = "Order";
                    RunObject = Page "Posted Stock Audit List";
                    ToolTip = 'Posted Inventory Counting Line';
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
                action(PostedPurchaseReceipt)
                {
                    ApplicationArea = All;
                    Caption = 'Posted Purchase Receipts';
                    Image = "Order";
                    RunObject = Page "Posted Purchase Receipts";
                    ToolTip = 'Posted Purchase Receipts';
                }
                action(PostedPurchaseReturn)
                {
                    ApplicationArea = All;
                    Caption = 'Posted Purchase Returns';
                    Image = "Order";
                    RunObject = Page "Posted Purchase Credit Memos";
                    ToolTip = 'Posted Purchase Credit Memos';
                }

                action(fininishedProduction)
                {
                    ApplicationArea = All;
                    Caption = 'Finished Production Order List';
                    Image = "Order";
                    RunObject = Page "Finished Production Orders";
                    ToolTip = 'Finished Production Order List';
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



            action("OpenStatement")
            {
                ApplicationArea = All;
                Caption = 'Open Statemnts';
                RunObject = Page "LSC Open Statement List";
                ToolTip = 'Open Statemnts';
            }


            separator(History)
            {
                Caption = 'History';
                IsHeader = true;
            }

        }
    }
}

