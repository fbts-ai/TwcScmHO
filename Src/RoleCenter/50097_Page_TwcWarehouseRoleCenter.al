page 50097 TwcWarehouseManagerRoleCenter
{
    Caption = 'Twc Warehouse RoleCenter';
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
            action(IndentApprover)
            {

                ApplicationArea = All;
                Caption = 'Indent approver';
                Image = Approval;
                RunObject = Page "Indent Approval Entries";
                ToolTip = 'IndentApprover';

            }
            separator(Action22)
            {
            }
            action(WastageEntryApprover)
            {
                ApplicationArea = All;
                Caption = 'Wastage Entry approver';
                Image = Approval;
                RunObject = Page "Wastage Entry Approval Page";
                ToolTip = 'WastageApprover';
            }
            separator(Action23)
            {
            }
            action(InventoryEntryApprover1)
            {
                ApplicationArea = All;
                Caption = 'Inventory Counting Approver';
                Image = Approval;
                RunObject = Page "Stock Audit Approval Page";
                ToolTip = 'Invenory counting Approver';
            }
            action(PurchaseOrdersApprove)
            {
                ApplicationArea = All;
                Caption = 'Purchase Orders Approval';
                Image = Approval;
                RunObject = Page "Requests to Approve";
                ToolTip = 'Purchase Orders Approval';
            }

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
            action("Pending GRN Lists")
            {
                ApplicationArea = RelationshipMgmt;
                Caption = 'Pending GRN Lists';
                RunObject = Page "Purchase Order GRN List";
                ToolTip = 'Pending GRN Lists';
            }
            action(ProductionOrders)
            {
                ApplicationArea = All;
                Caption = ' Released Prod. Order List';
                Image = "Order";
                RunObject = Page "Released Production Orders";
                ToolTip = 'Released Prod. Order List';
            }

            action(ProductionBom)
            {
                ApplicationArea = All;
                Caption = 'Production BOM List';
                Image = "Order";
                RunObject = Page "Production BOM List";
                ToolTip = 'Production BOM List';
            }
            action(Indent)
            {
                ApplicationArea = All;
                Caption = 'Indent List';
                Image = Order;
                RunObject = Page "Indent List";
                ToolTip = 'Indent List';
            }
            action(IndentProcessing)
            {
                ApplicationArea = All;
                Caption = 'Indent Processing';
                Image = Order;
                RunObject = Page "Sub Indent List";
                ToolTip = 'Indent Processsing Page';
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

            action(PurchaseOrder)
            {
                ApplicationArea = All;
                Caption = 'Purchase Order List';
                Image = "Order";
                RunObject = Page "Purchase Orders";
                ToolTip = ' Purchase Order List';
            }
            action(PurchaseReturnOrder)
            {
                ApplicationArea = All;
                Caption = 'Purchase Return Order List';
                Image = "Order";
                RunObject = Page "Purchase Return Orders";
                ToolTip = 'Purchase Return Order List';
            }

            action(RSTNTransferOrder)
            {
                ApplicationArea = All;
                Caption = 'RSTN Transfer Order List';
                Image = "Order";
                RunObject = Page "RSTN Transfer Order List";
                ToolTip = 'RSTN Transfer Order List';
            }

            action(WastageEntry)
            {
                ApplicationArea = All;
                Caption = 'Wastage Entry List';
                Image = "Order";
                RunObject = Page "Wastage Entry List";
                ToolTip = 'Wastage Entry List';
            }
            action(InventoryCounting)
            {
                ApplicationArea = All;
                Caption = 'StockAuditHeader  List';
                Image = "Order";
                RunObject = Page StockAuditList;
                ToolTip = 'Inventory Counting List';
            }
            action(TwcTransferOrder)
            {
                ApplicationArea = All;
                Caption = 'Tranfer Order Lines';
                Image = "Order";
                RunObject = Page TwcTransferOrderLineList;
                ToolTip = 'Twc Tranfer Order Lines';
            }





        }
        area(sections)
        {
            group("PostedDocuments")
            {
                Caption = 'Posted Document';
                Image = AdministrationSalesPurchases;

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
                    Caption = 'Posted Inventory Counting List';
                    Image = "Order";
                    RunObject = Page "Posted Stock Audit List";
                    ToolTip = 'Posted Inventory Counting';
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
                action(PostedPurchaseInvoice)
                {
                    ApplicationArea = All;
                    Caption = 'Posted Purchase Invoices';
                    Image = "Order";
                    RunObject = Page "Posted Purchase Invoices";
                    ToolTip = 'Posted Purchase Invoices';
                }
                action(PurchaseOrderShortclose)
                {
                    ApplicationArea = All;
                    Caption = 'Purchase Order Short Close list';
                    Image = "Order";
                    RunObject = Page "Purchase Short Close List";
                    ToolTip = 'Purchase Order Short Close';
                }
                action(PostedPurchaseCreditMemo)
                {
                    ApplicationArea = All;
                    Caption = 'Posted Purchase Credit Memos';
                    Image = "Order";
                    RunObject = Page "Posted Purchase Credit Memos";
                    ToolTip = 'Purchase Order Short Close';
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

