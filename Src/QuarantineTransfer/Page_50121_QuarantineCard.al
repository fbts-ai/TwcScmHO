page 50121 "Quarantine Card"
{
    Caption = 'Quarantine';
    PageType = Document;
    RefreshOnActivate = true;
    SourceTable = "Transfer Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = Location;
                    Importance = Promoted;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                    Visible = DocNoVisible;

                    trigger OnAssistEdit()
                    begin
                        if AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field("Transfer-from Code"; Rec."Transfer-from Code")
                {
                    ApplicationArea = Location;
                    // Editable = (Status = Status::Open) AND EnableTransferFields;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the code of the location that items are transferred from.';

                    trigger OnValidate()
                    begin
                        IsTransferLinesEditable := Rec.TransferLinesEditable();
                        CurrPage.Update();
                    end;
                }
                field("Transfer-to Code"; Rec."Transfer-to Code")
                {
                    ApplicationArea = Location;
                    // Editable = (Status = Status::Open) AND EnableTransferFields;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the code of the location that the items are transferred to.';

                    trigger OnValidate()
                    begin
                        IsTransferLinesEditable := Rec.TransferLinesEditable();
                        CurrPage.Update();
                    end;
                }
                field("Direct Transfer"; Rec."Direct Transfer")
                {
                    ApplicationArea = Location;
                    //Editable = (Status = Status::) AND EnableTransferFields;
                    Editable = false;
                    Importance = Promoted;

                    ToolTip = 'Specifies that the transfer does not use an in-transit location. When you transfer directly, the Qty. to Receive field will be locked with the same value as the quantity to ship.';

                    trigger OnValidate()
                    begin
                        IsTransferLinesEditable := Rec.TransferLinesEditable();
                        CurrPage.Update();
                    end;
                }
                // field("In-Transit Code"; Rec."In-Transit Code")
                // {
                //     ApplicationArea = Location;
                //     Editable = EnableTransferFields;
                //     Enabled = (NOT "Direct Transfer") AND (Status = Status::Open);
                //     ToolTip = 'Specifies the in-transit code for the transfer order, such as a shipping agent.';

                //     trigger OnValidate()
                //     begin
                //         IsTransferLinesEditable := Rec.TransferLinesEditable();
                //         CurrPage.Update();
                //     end;
                // }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the posting date of the transfer order.';

                    trigger OnValidate()
                    begin
                        PostingDateOnAfterValidate();
                    end;
                }
                // field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                // {
                //     ApplicationArea = Dimensions;
                //     Editable = EnableTransferFields;
                //     Importance = Additional;
                //     ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                // }
                // field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                // {
                //     ApplicationArea = Dimensions;
                //     Editable = EnableTransferFields;
                //     Importance = Additional;
                //     ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                // }
                field("Assigned User ID"; Rec."Assigned User ID")
                {
                    ApplicationArea = all;
                    Editable = false;
                    // Editable = EnableTransferFields;
                    // Importance = Additional;
                    Caption = 'Approver';
                    //ToolTip = 'Specifies the ID of the user who is responsible for the document.';
                }
                field(Status; rec.Status)
                {
                    Visible = false;
                    ApplicationArea = Location;
                    Importance = Promoted;
                    ToolTip = 'Specifies whether the transfer order is open or has been released for warehouse handling.';
                }
                field(Status_; rec.Status_)
                {
                    Editable = false;
                    ApplicationArea = Location;
                    Importance = Promoted;
                    ToolTip = 'Specifies whether the transfer order is open or has been released for warehouse handling.';
                }
                // field(Remarks; rec.Remarks)
                // {
                //     ApplicationArea = all;
                // }
            }
            part(TransferLines; "Quarantine Subform")
            {
                ApplicationArea = Location;
                Editable = True;
                Enabled = True;
                SubPageLink = "Document No." = FIELD("No."),
                              "Derived From Line No." = CONST(0);
                UpdatePropagation = Both;
            }
            // group(Shipment)
            // {
            //     Caption = 'Shipment';
            //     field("Shipment Date"; Rec."Shipment Date")
            //     {
            //         ApplicationArea = Location;
            //         Editable = (Status = Status::Open) AND EnableTransferFields;
            //         ToolTip = 'Specifies when items on the document are shipped or were shipped. A shipment date is usually calculated from a requested delivery date plus lead time.';

            //         trigger OnValidate()
            //         begin
            //             ShipmentDateOnAfterValidate();
            //         end;
            //     }
            // field("Outbound Whse. Handling Time"; Rec."Outbound Whse. Handling Time")
            // {
            //     ApplicationArea = Warehouse;
            //     Editable = (Status = Status::Open) AND EnableTransferFields;
            //     ToolTip = 'Specifies a date formula for the time it takes to get items ready to ship from this location. The time element is used in the calculation of the delivery date as follows: Shipment Date + Outbound Warehouse Handling Time = Planned Shipment Date + Shipping Time = Planned Delivery Date.';

            //     trigger OnValidate()
            //     begin
            //         OutboundWhseHandlingTimeOnAfte();
            //     end;
            // }
            //     field("Shipment Method Code"; Rec."Shipment Method Code")
            //     {
            //         ApplicationArea = Location;
            //         Editable = (Status = Status::Open) AND EnableTransferFields;
            //         ToolTip = 'Specifies the delivery conditions of the related shipment, such as free on board (FOB).';
            //     }
            //     field("Shipping Agent Code"; Rec."Shipping Agent Code")
            //     {
            //         ApplicationArea = Location;
            //         Editable = (Status = Status::Open) AND EnableTransferFields;
            //         ToolTip = 'Specifies the code for the shipping agent who is transporting the items.';

            //         trigger OnValidate()
            //         begin
            //             ShippingAgentCodeOnAfterValida();
            //         end;
            //     }
            //     field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
            //     {
            //         ApplicationArea = Location;
            //         Editable = (Status = Status::Open) AND EnableTransferFields;
            //         Importance = Additional;
            //         ToolTip = 'Specifies the code for the service, such as a one-day delivery, that is offered by the shipping agent.';

            //         trigger OnValidate()
            //         begin
            //             ShippingAgentServiceCodeOnAfte();
            //         end;
            //     }
            //     field("Shipping Time"; Rec."Shipping Time")
            //     {
            //         ApplicationArea = Location;
            //         Editable = (Status = Status::Open) AND EnableTransferFields;
            //         ToolTip = 'Specifies how long it takes from when the items are shipped from the warehouse to when they are delivered.';

            //         trigger OnValidate()
            //         begin
            //             ShippingTimeOnAfterValidate();
            //         end;
            //     }
            //     field("Shipping Advice"; Rec."Shipping Advice")
            //     {
            //         ApplicationArea = Location;
            //         Editable = (Status = Status::Open) AND EnableTransferFields;
            //         Importance = Additional;
            //         ToolTip = 'Specifies an instruction to the warehouse that ships the items, for example, that it is acceptable to do partial shipment.';

            //         trigger OnValidate()
            //         begin
            //             if "Shipping Advice" <> xRec."Shipping Advice" then
            //                 if not Confirm(Text000, false, FieldCaption("Shipping Advice")) then
            //                     Error('');
            //         end;
            //     }
            //     field("Receipt Date"; Rec."Receipt Date")
            //     {
            //         ApplicationArea = Location;
            //         Editable = Status = Status::Open;
            //         ToolTip = 'Specifies the date that you expect the transfer-to location to receive the shipment.';

            //         trigger OnValidate()
            //         begin
            //             ReceiptDateOnAfterValidate();
            //         end;
            //     }
            // }
            // group("Transfer-from")
            // {
            //     Caption = 'Transfer-from';
            //     Editable = (Status = Status::Open) AND EnableTransferFields;
            //     field("Transfer-from Name"; Rec."Transfer-from Name")
            //     {
            //         ApplicationArea = Location;
            //         Caption = 'Name';
            //         ToolTip = 'Specifies the name of the sender at the location that the items are transferred from.';
            //     }
            //     field("Transfer-from Name 2"; Rec."Transfer-from Name 2")
            //     {
            //         ApplicationArea = Location;
            //         Caption = 'Name 2';
            //         Importance = Additional;
            //         ToolTip = 'Specifies an additional part of the name of the sender at the location that the items are transferred from.';
            //     }
            //     field("Transfer-from Address"; Rec."Transfer-from Address")
            //     {
            //         ApplicationArea = Location;
            //         Caption = 'Address';
            //         Importance = Additional;
            //         QuickEntry = false;
            //         ToolTip = 'Specifies the address of the location that the items are transferred from.';
            //     }
            //     field("Transfer-from Address 2"; Rec."Transfer-from Address 2")
            //     {
            //         ApplicationArea = Location;
            //         Caption = 'Address 2';
            //         Importance = Additional;
            //         QuickEntry = false;
            //         ToolTip = 'Specifies an additional part of the address of the location that items are transferred from.';
            //     }
            //     field("Transfer-from City"; Rec."Transfer-from City")
            //     {
            //         ApplicationArea = Location;
            //         Caption = 'City';
            //         Importance = Additional;
            //         QuickEntry = false;
            //         ToolTip = 'Specifies the city of the location that the items are transferred from.';
            //     }
            //     group(Control17)
            //     {
            //         ShowCaption = false;
            //         Visible = IsFromCountyVisible;
            //         field("Transfer-from County"; Rec."Transfer-from County")
            //         {
            //             ApplicationArea = Location;
            //             Caption = 'County';
            //             Importance = Additional;
            //             QuickEntry = false;
            //         }
            //     }
            //     field("Transfer-from Post Code"; Rec."Transfer-from Post Code")
            //     {
            //         ApplicationArea = Location;
            //         Caption = 'Post Code';
            //         Importance = Additional;
            //         QuickEntry = false;
            //         ToolTip = 'Specifies the postal code of the location that the items are transferred from.';
            //     }
            //     field("Trsf.-from Country/Region Code"; Rec."Trsf.-from Country/Region Code")
            //     {
            //         ApplicationArea = Location;
            //         Caption = 'Country/Region';
            //         Importance = Additional;
            //         QuickEntry = false;

            //         trigger OnValidate()
            //         begin
            //             IsFromCountyVisible := FormatAddress.UseCounty("Trsf.-from Country/Region Code");
            //         end;
            //     }
            //     field("Transfer-from Contact"; Rec."Transfer-from Contact")
            //     {
            //         ApplicationArea = Location;
            //         Caption = 'Contact';
            //         Importance = Additional;
            //         ToolTip = 'Specifies the name of the contact person at the location that the items are transferred from.';
            //     }
            // }
            // group("Transfer-to")
            // {
            //     Caption = 'Transfer-to';
            //     Editable = (Status = Status::Open) AND EnableTransferFields;
            //     field("Transfer-to Name"; Rec."Transfer-to Name")
            //     {
            //         ApplicationArea = Location;
            //         Caption = 'Name';
            //         ToolTip = 'Specifies the name of the recipient at the location that the items are transferred to.';
            //     }
            //     field("Transfer-to Name 2"; Rec."Transfer-to Name 2")
            //     {
            //         ApplicationArea = Location;
            //         Caption = 'Name 2';
            //         Importance = Additional;
            //         ToolTip = 'Specifies an additional part of the name of the recipient at the location that the items are transferred to.';
            //     }
            //     field("Transfer-to Address"; Rec."Transfer-to Address")
            //     {
            //         ApplicationArea = Location;
            //         Caption = 'Address';
            //         Importance = Additional;
            //         QuickEntry = false;
            //         ToolTip = 'Specifies the address of the location that the items are transferred to.';
            //     }
            //     field("Transfer-to Address 2"; Rec."Transfer-to Address 2")
            //     {
            //         ApplicationArea = Location;
            //         Caption = 'Address 2';
            //         Importance = Additional;
            //         QuickEntry = false;
            //         ToolTip = 'Specifies an additional part of the address of the location that the items are transferred to.';
            //     }
            //     field("Transfer-to City"; Rec."Transfer-to City")
            //     {
            //         ApplicationArea = Location;
            //         Caption = 'City';
            //         Importance = Additional;
            //         QuickEntry = false;
            //         ToolTip = 'Specifies the city of the location that items are transferred to.';
            //     }
            //     group(Control24)
            //     {
            //         ShowCaption = false;
            //         Visible = IsToCountyVisible;
            //         field("Transfer-to County"; Rec."Transfer-to County")
            //         {
            //             ApplicationArea = Location;
            //             Caption = 'County';
            //             Importance = Additional;
            //             QuickEntry = false;
            //         }
            //     }
            //     field("Transfer-to Post Code"; Rec."Transfer-to Post Code")
            //     {
            //         ApplicationArea = Location;
            //         Caption = 'Post Code';
            //         Importance = Additional;
            //         QuickEntry = false;
            //         ToolTip = 'Specifies the postal code of the location that the items are transferred to.';
            //     }
            //     field("Trsf.-to Country/Region Code"; Rec."Trsf.-to Country/Region Code")
            //     {
            //         ApplicationArea = Location;
            //         Caption = 'Country/Region';
            //         Importance = Additional;
            //         QuickEntry = false;

            //         trigger OnValidate()
            //         begin
            //             IsToCountyVisible := FormatAddress.UseCounty("Trsf.-to Country/Region Code");
            //         end;
            //     }
            //     field("Transfer-to Contact"; Rec."Transfer-to Contact")
            //     {
            //         ApplicationArea = Location;
            //         Caption = 'Contact';
            //         Importance = Additional;
            //         ToolTip = 'Specifies the name of the contact person at the location that items are transferred to.';
            //     }
            // }
            // group(Control19)
            // {
            //     Caption = 'Warehouse';
            //     field("Inbound Whse. Handling Time"; Rec."Inbound Whse. Handling Time")
            //     {
            //         ApplicationArea = Warehouse;
            //         ToolTip = 'Specifies the time it takes to make items part of available inventory, after the items have been posted as received.';

            //         trigger OnValidate()
            //         begin
            //             InboundWhseHandlingTimeOnAfter();
            //         end;
            //     }
            // }
            //     group("Foreign Trade")
            //     {
            //         Caption = 'Foreign Trade';
            //         Editable = (Status = Status::Open) AND EnableTransferFields;
            //         field("Transaction Type"; Rec."Transaction Type")
            //         {
            //             ApplicationArea = BasicEU, BasicNO;
            //             Importance = Promoted;
            //             ToolTip = 'Specifies the type of transaction that the document represents, for the purpose of reporting to INTRASTAT.';
            //         }
            //         field("Transaction Specification"; Rec."Transaction Specification")
            //         {
            //             ApplicationArea = BasicEU, BasicNO;
            //             ToolTip = 'Specifies a specification of the document''s transaction, for the purpose of reporting to INTRASTAT.';
            //         }
            //         field("Transport Method"; Rec."Transport Method")
            //         {
            //             ApplicationArea = BasicEU, BasicNO;
            //             Importance = Promoted;
            //             ToolTip = 'Specifies the transport method, for the purpose of reporting to INTRASTAT.';
            //         }
            //         field("Area"; Area)
            //         {
            //             ApplicationArea = BasicEU, BasicNO;
            //             ToolTip = 'Specifies the area of the customer or vendor, for the purpose of reporting to INTRASTAT.';
            //         }
            //         field("Entry/Exit Point"; Rec."Entry/Exit Point")
            //         {
            //             ApplicationArea = BasicEU, BasicNO;
            //             ToolTip = 'Specifies the code of either the port of entry at which the items passed into your country/region, or the port of exit.';
            //         }
            //         field("Partner VAT ID"; Rec."Partner VAT ID")
            //         {
            //             ApplicationArea = BasicEU, BasicNO;
            //             ToolTip = 'Specifies the counter party''s VAT number.';
            //         }
            //     }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            // group("O&rder")
            // {
            //     Caption = 'O&rder';
            //     Image = "Order";
            //     action(Statistics)
            //     {
            //         ApplicationArea = Location;
            //         Caption = 'Statistics';
            //         Image = Statistics;
            //         RunObject = Page "Transfer Statistics";
            //         RunPageLink = "No." = FIELD("No.");
            //         ShortCutKey = 'F7';
            //         ToolTip = 'View statistical information about the transfer order, such as the quantity and total weight transferred.';
            //     }
            //     action("Co&mments")
            //     {
            //         ApplicationArea = Comments;
            //         Caption = 'Co&mments';
            //         Image = ViewComments;
            //         RunObject = Page "Inventory Comment Sheet";
            //         RunPageLink = "Document Type" = CONST("Transfer Order"),
            //                       "No." = FIELD("No.");
            //         ToolTip = 'View or add comments for the record.';
            //     }
            //     action(Dimensions)
            //     {
            //         AccessByPermission = TableData Dimension = R;
            //         ApplicationArea = Dimensions;
            //         Caption = 'Dimensions';
            //         Image = Dimensions;
            //         ShortCutKey = 'Alt+D';
            //         ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

            //         trigger OnAction()
            //         begin
            //             ShowDocDim();
            //             CurrPage.SaveRecord();
            //         end;
            //     }
            // }
            // group(Documents)
            // {
            //     Caption = 'Documents';
            //     Image = Documents;
            //     action("S&hipments")
            //     {
            //         ApplicationArea = Location;
            //         Caption = 'S&hipments';
            //         Image = Shipment;
            //         RunObject = Page "Posted Transfer Shipments";
            //         RunPageLink = "Transfer Order No." = FIELD("No.");
            //         ToolTip = 'View related posted transfer shipments.';
            //     }
            //     action("Re&ceipts")
            //     {
            //         ApplicationArea = Location;
            //         Caption = 'Re&ceipts';
            //         Image = PostedReceipts;
            //         RunObject = Page "Posted Transfer Receipts";
            //         RunPageLink = "Transfer Order No." = FIELD("No.");
            //         ToolTip = 'View related posted transfer receipts.';
            //     }
            // }
            // group(Warehouse)
            // {
            //     Caption = 'Warehouse';
            //     Image = Warehouse;
            //     action("Whse. Shi&pments")
            //     {
            //         ApplicationArea = Warehouse;
            //         Caption = 'Whse. Shi&pments';
            //         Image = Shipment;
            //         RunObject = Page "Whse. Shipment Lines";
            //         RunPageLink = "Source Type" = CONST(5741),
            //                       "Source Subtype" = CONST("0"),
            //                       "Source No." = FIELD("No.");
            //         RunPageView = SORTING("Source Type", "Source Subtype", "Source No.", "Source Line No.");
            //         ToolTip = 'View outbound items that have been shipped with warehouse activities for the transfer order.';
            //     }
            //     action("&Whse. Receipts")
            //     {
            //         ApplicationArea = Warehouse;
            //         Caption = '&Whse. Receipts';
            //         Image = Receipt;
            //         RunObject = Page "Whse. Receipt Lines";
            //         RunPageLink = "Source Type" = CONST(5741),
            //                       "Source Subtype" = CONST("1"),
            //                       "Source No." = FIELD("No.");
            //         RunPageView = SORTING("Source Type", "Source Subtype", "Source No.", "Source Line No.");
            //         ToolTip = 'View inbound items that have been received with warehouse activities for the transfer order.';
            //     }
            //     action("In&vt. Put-away/Pick Lines")
            //     {
            //         ApplicationArea = Warehouse;
            //         Caption = 'In&vt. Put-away/Pick Lines';
            //         Image = PickLines;
            //         RunObject = Page "Warehouse Activity List";
            //         RunPageLink = "Source Document" = FILTER("Inbound Transfer" | "Outbound Transfer"),
            //                       "Source No." = FIELD("No.");
            //         RunPageView = SORTING("Source Document", "Source No.", "Location Code");
            //         ToolTip = 'View items that are inbound or outbound on inventory put-away or inventory pick documents for the transfer order.';
            //     }
            //}
        }
        area(processing)
        {
            // action("&Print")
            // {
            //     ApplicationArea = Location;
            //     Caption = '&Print';
            //     Ellipsis = true;
            //     Image = Print;
            //     ToolTip = 'Prepare to print the document. A report request window for the document opens where you can specify what to include on the print-out.';

            //     trigger OnAction()
            //     var
            //         DocPrint: Codeunit "Document-Print";
            //     begin
            //         DocPrint.PrintTransferHeader(Rec);
            //     end;
            // }
            // group(Release)
            // {
            //     Caption = 'Release';
            //     Image = ReleaseDoc;
            // action("Re&lease")
            // {
            //     ApplicationArea = Location;
            //     Caption = 'Re&lease';
            //     Image = ReleaseDoc;
            //     RunObject = Codeunit "Release Transfer Document";
            //     ShortCutKey = 'Ctrl+F9';
            //     ToolTip = 'Release the document to the next stage of processing. You must reopen the document before you can make changes to it.';
            // }
            // action("Reo&pen")
            // {
            //     ApplicationArea = Location;
            //     Caption = 'Reo&pen';
            //     Image = ReOpen;
            //     ToolTip = 'Reopen the transfer order after being released for warehouse handling.';

            //     trigger OnAction()
            //     var
            //         ReleaseTransferDoc: Codeunit "Release Transfer Document";
            //     begin
            //         ReleaseTransferDoc.Reopen(Rec);

            //     end;
            // }
            // }
            // group("F&unctions")
            // {
            //     Caption = 'F&unctions';
            //     Image = "Action";
            //     action("Create Whse. S&hipment")
            //     {
            //         AccessByPermission = TableData "Warehouse Shipment Header" = R;
            //         ApplicationArea = Warehouse;
            //         Caption = 'Create Whse. S&hipment';
            //         Image = NewShipment;
            //         ToolTip = 'Create a warehouse shipment to start a pick a ship process according to an advanced warehouse configuration.';

            //         trigger OnAction()
            //         var
            //             GetSourceDocOutbound: Codeunit "Get Source Doc. Outbound";
            //         begin
            //             GetSourceDocOutbound.CreateFromOutbndTransferOrder(Rec);
            //         end;
            //     }
            //     action("Create &Whse. Receipt")
            //     {
            //         AccessByPermission = TableData "Warehouse Receipt Header" = R;
            //         ApplicationArea = Warehouse;
            //         Caption = 'Create &Whse. Receipt';
            //         Image = NewReceipt;
            //         ToolTip = 'Create a warehouse receipt to start a receive and put-away process according to an advanced warehouse configuration.';

            //         trigger OnAction()
            //         var
            //             GetSourceDocInbound: Codeunit "Get Source Doc. Inbound";
            //         begin
            //             GetSourceDocInbound.CreateFromInbndTransferOrder(Rec);
            //         end;
            //     }
            //     action("Create Inventor&y Put-away/Pick")
            //     {
            //         ApplicationArea = Warehouse;
            //         Caption = 'Create Inventor&y Put-away/Pick';
            //         Ellipsis = true;
            //         Image = CreateInventoryPickup;
            //         ToolTip = 'Create an inventory put-away or inventory pick to handle items on the document with a basic warehouse process that does not require warehouse receipt or shipment documents.';

            //         trigger OnAction()
            //         begin
            //             CreateInvtPutAwayPick();
            //         end;
            //     }
            //     action("Get Bin Content")
            //     {
            //         AccessByPermission = TableData "Bin Content" = R;
            //         ApplicationArea = Warehouse;
            //         Caption = 'Get Bin Content';
            //         Ellipsis = true;
            //         Image = GetBinContent;
            //         ToolTip = 'Use a function to create transfer lines with items to put away or pick based on the actual content in the specified bin.';

            //         trigger OnAction()
            //         var
            //             BinContent: Record "Bin Content";
            //             GetBinContent: Report "Whse. Get Bin Content";
            //         begin
            //             BinContent.SetRange("Location Code", "Transfer-from Code");
            //             GetBinContent.SetTableView(BinContent);
            //             GetBinContent.InitializeTransferHeader(Rec);
            //             GetBinContent.RunModal();
            //         end;
            //     }
            //     action(GetReceiptLines)
            //     {
            //         ApplicationArea = Location;
            //         Caption = 'Get Receipt Lines';
            //         Image = Receipt;
            //         ToolTip = 'Add transfer order lines from posted purchase receipt lines.';

            //         trigger OnAction()
            //         begin
            //             GetReceiptLines();
            //         end;
            //     }
            // }
            group("P&osting")
            {
                Caption = 'P&osting';
                Image = Post;
                action(SendForApproval)
                {
                    ApplicationArea = all;

                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    Image = SendTo;
                    trigger OnAction()
                    var
                        tempusersetup: Record "User Setup";
                        totalStockLine: Record StockAuditLine;
                        TotalAmount: Decimal;
                        tempitem: Record Item;
                        TransSalesEntry: Record "LSC Trans. Sales Entry";
                        TodaysSales: Decimal;
                        //TransSalesEntry: Record "LSC Trans. Sales Entry";
                        totalPercentageValue: Decimal;

                        EmailCodeunit: Codeunit Email;
                        Tempblob: Codeunit "Temp Blob";
                        IsStream: InStream;
                        OStream: OutStream;
                        UserSetup: Record "User Setup";
                        EmailMessage: Codeunit "Email Message";
                        currentuser: Record "User Setup";
                        MessageBody: Text;
                        MailList: List of [text];
                        RequestRunPage: text;
                        RecRef: RecordRef;
                        Subject: Text;
                        parma: Text;
                        TransHead: Record "LSC Transaction Header";

                        TransLine: Record "Transfer Line";
                        TransLine1: Record "Transfer Line";

                    begin
                        TransLine.SetRange("Document No.", rec."No.");
                        if TransLine.FindSet() then begin
                            repeat
                                if TransLine.Remarks = '' then
                                    Error('Remarks Can Not Be Empty For Line No %1', TransLine."Line No.");
                            // TransLine1.SetRange("Document No.", TransLine."Document No.");
                            // TransLine1.SetRange("Line No.", TransLine."Line No.");
                            // if TransLine1.FindFirst() then begin
                            //     if TransLine1.Remarks = '' then
                            //         Error('Remarks Can Not Be Empty For Line No %1', TransLine1."Line No.");
                            // end;
                            until TransLine.Next() = 0;
                        end;

                        if Rec.Status_ = Rec.Status_::Open then begin
                            if tempusersetup.get(UserId) then;
                            if Rec."Assigned User ID" = tempusersetup."User ID" then begin //For Approver
                                rec.Status := Rec.Status::Released;
                                rec.Status_ := rec.Status_::Approved;
                                rec.Modify();
                            end else begin
                                IF Confirm('Are want to send this order for approval?', true) then begin
                                    //IF Rec.Status = Rec.Status::Open then begin
                                    Rec.Status_ := rec.Status_::"Sent For Approval";
                                    Rec.Modify();

                                    //MailList.Add('mahendra.patil@in.ey.com');
                                    Subject := 'Quarantine Approval For :' + Rec."No.";
                                    MessageBody := 'Dear Approver, ' + '<br><br> This Document No. ' + Rec."No." + ' is pending for approval' + '<br><br>' + 'https://erptwc.thirdwavecoffee.in/BC220/?company=HBPL&page=50064&dc=0'
                                    + '<br><br>' + 'Regards' + '<br><br>' + 'IT - Team.';
                                    EmailMessage.Create(tempusersetup."Quarantine Entry Notification", Subject, MessageBody, true);
                                    EmailCodeunit.Send(EmailMessage);
                                    // end;
                                end;
                            end;
                        end else
                            Error('Status Must be equal to open');
                    end;
                }

                action("Open Approval Request")
                {
                    ApplicationArea = all;

                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    Image = ReOpen;
                    trigger OnAction()
                    var
                        UserSetup: Record "User Setup";
                    begin
                        //UserSetup.Get(UserId);
                        // if rec."Assigned User ID" = UserSetup."User ID" then Error('Not able to reopen the Request,As Approval is not raised by this ID');
                        if Rec.Status_ = Rec.Status_::"Sent For Approval" then begin
                            rec.Status_ := rec.Status_::Open;
                            //rec.Status := Rec.Status::Open;
                            rec.Modify();
                        end;
                    end;
                }

                action(Post)
                {
                    ApplicationArea = all;

                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    Image = Post;
                    ToolTip = 'Finalize the document or journal by posting the amounts and quantities to the related accounts in your company books.';

                    trigger OnAction()
                    begin
                        if Rec.Status_ <> Rec.Status_::Approved then
                            Error('Status must be approved')
                        else
                            CODEUNIT.Run(CODEUNIT::"TransferOrder-Post (Yes/No)", Rec);
                    end;
                }
                // action(PostAndPrint)
                // {
                //     ApplicationArea = Location;
                //     Caption = 'Post and &Print';
                //     Image = PostPrint;
                //     ShortCutKey = 'Shift+F9';
                //     ToolTip = 'Finalize and prepare to print the document or journal. The values and quantities are posted to the related accounts. A report request window where you can specify what to include on the print-out.';

                //     trigger OnAction()
                //     begin
                //         CODEUNIT.Run(CODEUNIT::"TransferOrder-Post + Print", Rec);
                //     end;
                // }
            }
        }
        //         area(reporting)
        //         {
        //             action("Inventory - Inbound Transfer")
        //             {
        //                 ApplicationArea = Warehouse;
        //                 Caption = 'Inventory - Inbound Transfer';
        //                 Image = "Report";
        //                 RunObject = Report "Inventory - Inbound Transfer";
        //                 ToolTip = 'View which items are currently on inbound transfer orders.';
        //             }
        //         }
        //         area(Promoted)
        //         {
        //             group(Category_Process)
        //             {
        //                 Caption = 'Process', Comment = 'Generated from the PromotedActionCategories property index 1.';

        //                 group(Category_Category5)
        //                 {
        //                     Caption = 'Posting', Comment = 'Generated from the PromotedActionCategories property index 4.';
        //                     ShowAs = SplitButton;

        //                     actionref(Post_Promoted; Post)
        //                     {
        //                     }
        //                     actionref(PostAndPrint_Promoted; PostAndPrint)
        //                     {
        //                     }
        //                 }
        //                 actionref("Create Whse. S&hipment_Promoted"; "Create Whse. S&hipment")
        //                 {
        //                 }
        //                 group(Category_Category4)
        //                 {
        //                     Caption = 'Release', Comment = 'Generated from the PromotedActionCategories property index 3.';
        //                     ShowAs = SplitButton;

        //                     actionref("Re&lease_Promoted"; "Re&lease")
        //                     {
        //                     }
        //                     actionref("Reo&pen_Promoted"; "Reo&pen")
        //                     {
        //                     }
        //                 }
        //                 actionref("Create &Whse. Receipt_Promoted"; "Create &Whse. Receipt")
        //                 {
        //                 }
        //                 actionref("Create Inventor&y Put-away/Pick_Promoted"; "Create Inventor&y Put-away/Pick")
        //                 {
        //                 }
        //             }
        //             group(Category_Prepare)
        //             {
        //                 Caption = 'Prepare';

        //                 actionref(GetReceiptLines_Promoted; GetReceiptLines)
        //                 {
        //                 }
        //                 actionref("Get Bin Content_Promoted"; "Get Bin Content")
        //                 {
        //                 }
        //             }
        //             group(Category_Category8)
        //             {
        //                 Caption = 'Print/Send', Comment = 'Generated from the PromotedActionCategories property index 7.';

        //                 actionref("&Print_Promoted"; "&Print")
        //                 {
        //                 }
        //             }
        //             group(Category_Category6)
        //             {
        //                 Caption = 'Order', Comment = 'Generated from the PromotedActionCategories property index 5.';

        //                 actionref(Dimensions_Promoted; Dimensions)
        //                 {
        //                 }
        //                 actionref(Statistics_Promoted; Statistics)
        //                 {
        //                 }
        //                 actionref("Co&mments_Promoted"; "Co&mments")
        //                 {
        //                 }

        //                 separator(Navigate_Separator)
        //                 {
        //                 }

        //                 actionref("S&hipments_Promoted"; "S&hipments")
        //                 {
        //                 }
        //                 actionref("Re&ceipts_Promoted"; "Re&ceipts")
        //                 {
        //                 }
        //             }
        //             group(Category_Category7)
        //             {
        //                 Caption = 'Documents', Comment = 'Generated from the PromotedActionCategories property index 6.';
        //             }
        //             group(Category_Category9)
        //             {
        //                 Caption = 'Navigate', Comment = 'Generated from the PromotedActionCategories property index 8.';
        //             }
        //             group(Category_Report)
        //             {
        //                 Caption = 'Report', Comment = 'Generated from the PromotedActionCategories property index 2.';

        // #if not CLEAN21
        //                 actionref("Inventory - Inbound Transfer_Promoted"; "Inventory - Inbound Transfer")
        //                 {
        //                     Visible = false;
        //                     ObsoleteState = Pending;
        //                     ObsoleteReason = 'Action is being demoted based on overall low usage.';
        //                     ObsoleteTag = '21.0';
        //                 }
        // #endif
    }


    trigger OnAfterGetRecord()
    begin
        EnableTransferFields := not IsPartiallyShipped();
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        TestField(Status, Status::Open);
    end;

    trigger OnOpenPage()
    begin
        SetDocNoVisible();
        EnableTransferFields := not IsPartiallyShipped();
        ActivateFields();
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        myInt: Integer;
        Invsetup: Record 313;
        NoSeriesMgt: Codeunit 396;
        UserSetup: Record "User Setup";
    begin
        UserSetup.get(UserId);
        Invsetup.Get();
        Invsetup.TESTFIELD("Qurantine location Sr.");
        NoSeriesMgt.InitSeries(Invsetup."Qurantine location Sr.", '', 0D, rec."No.", Invsetup."Qurantine location Sr.");
        rec."Transfer-from Code" := UserSetup."Location Code";
        Rec."Quaratine Location" := true;
        rec."Posting Date" := Today;
        rec."Direct Transfer" := true;
        rec."Assigned User ID" := UserSetup."Quarantine Approver ID"; //For Approver
        rec."Transfer-to Code" := UserSetup."Quarantine Location";
    end;


    var
        FormatAddress: Codeunit "Format Address";
        DocNoVisible: Boolean;
        IsFromCountyVisible: Boolean;
        IsToCountyVisible: Boolean;
        [InDataSet]
        IsTransferLinesEditable: Boolean;

        Text000: Label 'Do you want to change %1 in all related records in the warehouse?';

    protected var
        EnableTransferFields: Boolean;

    local procedure ActivateFields()
    begin
        IsFromCountyVisible := FormatAddress.UseCounty("Trsf.-from Country/Region Code");
        IsToCountyVisible := FormatAddress.UseCounty("Trsf.-to Country/Region Code");
        IsTransferLinesEditable := Rec.TransferLinesEditable();
    end;

    local procedure PostingDateOnAfterValidate()
    begin
        CurrPage.TransferLines.PAGE.UpdateForm(true);
    end;

    local procedure ShipmentDateOnAfterValidate()
    begin
        CurrPage.TransferLines.PAGE.UpdateForm(false);
    end;

    local procedure ShippingAgentServiceCodeOnAfte()
    begin
        CurrPage.TransferLines.PAGE.UpdateForm(false);
    end;

    local procedure ShippingAgentCodeOnAfterValida()
    begin
        CurrPage.TransferLines.PAGE.UpdateForm(false);
    end;

    local procedure ShippingTimeOnAfterValidate()
    begin
        CurrPage.TransferLines.PAGE.UpdateForm(false);
    end;

    local procedure OutboundWhseHandlingTimeOnAfte()
    begin
        CurrPage.TransferLines.PAGE.UpdateForm(false);
    end;

    local procedure ReceiptDateOnAfterValidate()
    begin
        CurrPage.TransferLines.PAGE.UpdateForm(false);
    end;

    local procedure InboundWhseHandlingTimeOnAfter()
    begin
        CurrPage.TransferLines.PAGE.UpdateForm(false);
    end;

    local procedure SetDocNoVisible()
    var
        DocumentNoVisibility: Codeunit DocumentNoVisibility;
    begin
        DocNoVisible := DocumentNoVisibility.TransferOrderNoIsVisible();
    end;

    local procedure IsPartiallyShipped(): Boolean
    var
        TransferLine: Record "Transfer Line";
    begin
        TransferLine.SetRange("Document No.", "No.");
        TransferLine.SetFilter("Quantity Shipped", '> 0');
        exit(not TransferLine.IsEmpty);
    end;

    trigger OnModifyRecord(): Boolean
    var
        myInt: Integer;
    begin
        If Rec.Status_ = rec.Status_::"Sent For Approval" then
            Error('Reopen the Request to make any changes');
    end;
}






