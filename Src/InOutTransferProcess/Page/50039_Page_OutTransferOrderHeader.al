page 50039 "Out Transfer Order"
{
    Caption = 'Out Transfer Order';
    PageType = Document;
    RefreshOnActivate = true;
    SourceTable = "Transfer Header";
    InsertAllowed = false; //added mahendra 14 Aug
    DeleteAllowed = false; //added mahendra 14 Aug

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
                    Editable = false;//PT-FBTS- 30-08-24
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
                    //Editable = (Status = Status::Open) AND EnableTransferFields;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the code of the location that items are transferred from.';

                    trigger OnValidate()
                    begin
                        IsTransferLinesEditable := Rec.TransferLinesEditable();
                        CurrPage.Update();
                    end;
                }
                field(TransferFromName; Rec."Transfer-from Name")
                {

                }
                field("Transfer-to Code"; Rec."Transfer-to Code")
                {
                    ApplicationArea = Location;
                    Editable = (Status = Status::Open) AND EnableTransferFields;

                    Importance = Promoted;
                    ToolTip = 'Specifies the code of the location that the items are transferred to.';

                    trigger OnValidate()
                    begin
                        IsTransferLinesEditable := Rec.TransferLinesEditable();
                        CurrPage.Update();
                    end;
                }
                Field(Transfertoname; Rec."Transfer-to Name")
                {


                }
                field("PARTIAL Shipped"; "PARTIAL Shipped")
                {
                    ApplicationArea = all;
                } //ALLE_NICK_220224
                field("PARTIAL Received"; "PARTIAL Received")
                {
                    ApplicationArea = all;
                } //ALLE_NICK_220224
                /*
                field("Direct Transfer"; Rec."Direct Transfer")
                {
                    ApplicationArea = Location;
                    Editable = (Status = Status::Open) AND EnableTransferFields;

                    Importance = Promoted;
                    ToolTip = 'Specifies that the transfer does not use an in-transit location. When you transfer directly, the Qty. to Receive field will be locked with the same value as the quantity to ship.';

                    trigger OnValidate()
                    begin
                        IsTransferLinesEditable := Rec.TransferLinesEditable();
                        CurrPage.Update();
                    end;
                }
                */
                field("In-Transit Code"; Rec."In-Transit Code")
                {
                    ApplicationArea = Location;
                    Editable = EnableTransferFields;
                    Enabled = (NOT "Direct Transfer") AND (Status = Status::Open);
                    ToolTip = 'Specifies the in-transit code for the transfer order, such as a shipping agent.';

                    trigger OnValidate()
                    begin
                        IsTransferLinesEditable := Rec.TransferLinesEditable();
                        CurrPage.Update();
                    end;
                }
                //AJ_ALLE_04122023
                field(Hide; rec.Hide)
                {
                    ApplicationArea = all;
                    Editable = true;
                }
                //AJ_ALLE_04122023
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the posting date of the transfer order.';

                    trigger OnValidate()
                    begin
                        PostingDateOnAfterValidate();
                    end;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    Editable = EnableTransferFields;
                    Importance = Additional;
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                }
                field("Requistion No."; rec."Requistion No.")
                {
                    ApplicationArea = all;
                    Caption = 'Indent No.';
                    Editable = false;//AJ_Alle_02112023
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    Editable = EnableTransferFields;
                    Importance = Additional;
                    ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                }
                field("Assigned User ID"; Rec."Assigned User ID")
                {
                    ApplicationArea = Location;
                    Editable = EnableTransferFields;
                    Importance = Additional;
                    ToolTip = 'Specifies the ID of the user who is responsible for the document.';
                }
                field(Status; Status)
                {
                    ApplicationArea = Location;
                    Importance = Promoted;
                    ToolTip = 'Specifies whether the transfer order is open or has been released for warehouse handling.';
                }
            }
            part(TransferLines; "Transfer Order Out Subform")
            {
                ApplicationArea = Location;
                Editable = IsTransferLinesEditable;
                Enabled = IsTransferLinesEditable;
                SubPageLink = "Document No." = FIELD("No."),
                              "Derived From Line No." = CONST(0);
                UpdatePropagation = Both;
            }
            group(Shipment)
            {
                Caption = 'Shipment';
                field("Shipment Date"; Rec."Shipment Date")
                {
                    ApplicationArea = Location;
                    Editable = (Status = Status::Open) AND EnableTransferFields;
                    ToolTip = 'Specifies when items on the document are shipped or were shipped. A shipment date is usually calculated from a requested delivery date plus lead time.';

                    trigger OnValidate()
                    begin
                        ShipmentDateOnAfterValidate();
                    end;
                }
                field("Outbound Whse. Handling Time"; Rec."Outbound Whse. Handling Time")
                {
                    ApplicationArea = Warehouse;
                    Editable = (Status = Status::Open) AND EnableTransferFields;
                    ToolTip = 'Specifies a date formula for the time it takes to get items ready to ship from this location. The time element is used in the calculation of the delivery date as follows: Shipment Date + Outbound Warehouse Handling Time = Planned Shipment Date + Shipping Time = Planned Delivery Date.';

                    trigger OnValidate()
                    begin
                        OutboundWhseHandlingTimeOnAfte();
                    end;
                }
                field("Shipment Method Code"; Rec."Shipment Method Code")
                {
                    ApplicationArea = Location;
                    Editable = (Status = Status::Open) AND EnableTransferFields;
                    ToolTip = 'Specifies the delivery conditions of the related shipment, such as free on board (FOB).';
                }
                field(ShippingAgentCode; ShippingAgentCode)
                {
                    Caption = 'Shipping Agent Code';
                    TableRelation = "Shipping Agent";

                    trigger OnValidate()
                    begin
                        Rec."Shipping Agent Code" := ShippingAgentCode;
                        Rec.Modify();
                    end;
                }
                /*
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = Location;
                    Editable = true;//(Status = Status::Open) AND EnableTransferFields;
                    ToolTip = 'Specifies the code for the shipping agent who is transporting the items.';
                    
                      trigger OnValidate()
                      begin
                          ShippingAgentCodeOnAfterValida();
                      end;
                    
                }
                */
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    ApplicationArea = Location;
                    Editable = (Status = Status::Open) AND EnableTransferFields;
                    Importance = Additional;
                    ToolTip = 'Specifies the code for the service, such as a one-day delivery, that is offered by the shipping agent.';

                    trigger OnValidate()
                    begin
                        ShippingAgentServiceCodeOnAfte();
                    end;
                }
                field("Shipping Time"; Rec."Shipping Time")
                {
                    ApplicationArea = Location;
                    Editable = (Status = Status::Open) AND EnableTransferFields;
                    ToolTip = 'Specifies how long it takes from when the items are shipped from the warehouse to when they are delivered.';

                    trigger OnValidate()
                    begin
                        ShippingTimeOnAfterValidate();
                    end;
                }
                field("Shipping Advice"; Rec."Shipping Advice")
                {
                    ApplicationArea = Location;
                    Editable = (Status = Status::Open) AND EnableTransferFields;
                    Importance = Additional;
                    ToolTip = 'Specifies an instruction to the warehouse that ships the items, for example, that it is acceptable to do partial shipment.';

                    trigger OnValidate()
                    begin
                        if "Shipping Advice" <> xRec."Shipping Advice" then
                            if not Confirm(Text000, false, FieldCaption("Shipping Advice")) then
                                Error('');
                    end;
                }
                field("Receipt Date"; Rec."Receipt Date")
                {
                    ApplicationArea = Location;
                    Editable = Status = Status::Open;
                    ToolTip = 'Specifies the date that you expect the transfer-to location to receive the shipment.';

                    trigger OnValidate()
                    begin
                        ReceiptDateOnAfterValidate();
                    end;
                }
            }
            group("Transfer-from")
            {
                Caption = 'Transfer-from';
                Editable = (Status = Status::Open) AND EnableTransferFields;
                field("Transfer-from Name"; Rec."Transfer-from Name")
                {
                    ApplicationArea = Location;
                    Caption = 'Name';
                    ToolTip = 'Specifies the name of the sender at the location that the items are transferred from.';
                }
                field("Transfer-from Name 2"; Rec."Transfer-from Name 2")
                {
                    ApplicationArea = Location;
                    Caption = 'Name 2';
                    Importance = Additional;
                    ToolTip = 'Specifies an additional part of the name of the sender at the location that the items are transferred from.';
                }
                field("Transfer-from Address"; Rec."Transfer-from Address")
                {
                    ApplicationArea = Location;
                    Caption = 'Address';
                    Importance = Additional;
                    QuickEntry = false;
                    ToolTip = 'Specifies the address of the location that the items are transferred from.';
                }
                field("Transfer-from Address 2"; Rec."Transfer-from Address 2")
                {
                    ApplicationArea = Location;
                    Caption = 'Address 2';
                    Importance = Additional;
                    QuickEntry = false;
                    ToolTip = 'Specifies an additional part of the address of the location that items are transferred from.';
                }
                field("Transfer-from City"; Rec."Transfer-from City")
                {
                    ApplicationArea = Location;
                    Caption = 'City';
                    Importance = Additional;
                    QuickEntry = false;
                    ToolTip = 'Specifies the city of the location that the items are transferred from.';
                }
                group(Control17)
                {
                    ShowCaption = false;
                    Visible = IsFromCountyVisible;
                    field("Transfer-from County"; Rec."Transfer-from County")
                    {
                        ApplicationArea = Location;
                        Caption = 'County';
                        Importance = Additional;
                        QuickEntry = false;
                    }
                }
                field("Transfer-from Post Code"; Rec."Transfer-from Post Code")
                {
                    ApplicationArea = Location;
                    Caption = 'Post Code';
                    Importance = Additional;
                    QuickEntry = false;
                    ToolTip = 'Specifies the postal code of the location that the items are transferred from.';
                }
                field("Trsf.-from Country/Region Code"; Rec."Trsf.-from Country/Region Code")
                {
                    ApplicationArea = Location;
                    Caption = 'Country/Region';
                    Importance = Additional;
                    QuickEntry = false;

                    trigger OnValidate()
                    begin
                        IsFromCountyVisible := FormatAddress.UseCounty("Trsf.-from Country/Region Code");
                    end;
                }
                field("Transfer-from Contact"; Rec."Transfer-from Contact")
                {
                    ApplicationArea = Location;
                    Caption = 'Contact';
                    Importance = Additional;
                    ToolTip = 'Specifies the name of the contact person at the location that the items are transferred from.';
                }
            }
            group("Transfer-to")
            {
                Caption = 'Transfer-to';
                Editable = (Status = Status::Open) AND EnableTransferFields;
                field("Transfer-to Name"; Rec."Transfer-to Name")
                {
                    ApplicationArea = Location;
                    Caption = 'Name';
                    ToolTip = 'Specifies the name of the recipient at the location that the items are transferred to.';
                }
                field("Transfer-to Name 2"; Rec."Transfer-to Name 2")
                {
                    ApplicationArea = Location;
                    Caption = 'Name 2';
                    Importance = Additional;
                    ToolTip = 'Specifies an additional part of the name of the recipient at the location that the items are transferred to.';
                }
                field("Transfer-to Address"; Rec."Transfer-to Address")
                {
                    ApplicationArea = Location;
                    Caption = 'Address';
                    Importance = Additional;
                    QuickEntry = false;
                    ToolTip = 'Specifies the address of the location that the items are transferred to.';
                }
                field("Transfer-to Address 2"; Rec."Transfer-to Address 2")
                {
                    ApplicationArea = Location;
                    Caption = 'Address 2';
                    Importance = Additional;
                    QuickEntry = false;
                    ToolTip = 'Specifies an additional part of the address of the location that the items are transferred to.';
                }
                field("Transfer-to City"; Rec."Transfer-to City")
                {
                    ApplicationArea = Location;
                    Caption = 'City';
                    Importance = Additional;
                    QuickEntry = false;
                    ToolTip = 'Specifies the city of the location that items are transferred to.';
                }
                group(Control24)
                {
                    ShowCaption = false;
                    Visible = IsToCountyVisible;
                    field("Transfer-to County"; Rec."Transfer-to County")
                    {
                        ApplicationArea = Location;
                        Caption = 'County';
                        Importance = Additional;
                        QuickEntry = false;
                    }
                }
                field("Transfer-to Post Code"; Rec."Transfer-to Post Code")
                {
                    ApplicationArea = Location;
                    Caption = 'Post Code';
                    Importance = Additional;
                    QuickEntry = false;
                    ToolTip = 'Specifies the postal code of the location that the items are transferred to.';
                }
                field("Trsf.-to Country/Region Code"; Rec."Trsf.-to Country/Region Code")
                {
                    ApplicationArea = Location;
                    Caption = 'Country/Region';
                    Importance = Additional;
                    QuickEntry = false;

                    trigger OnValidate()
                    begin
                        IsToCountyVisible := FormatAddress.UseCounty("Trsf.-to Country/Region Code");
                    end;
                }
                field("Transfer-to Contact"; Rec."Transfer-to Contact")
                {
                    ApplicationArea = Location;
                    Caption = 'Contact';
                    Importance = Additional;
                    ToolTip = 'Specifies the name of the contact person at the location that items are transferred to.';
                }
            }
            group(Control19)
            {
                Caption = 'Warehouse';
                field("Inbound Whse. Handling Time"; Rec."Inbound Whse. Handling Time")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the time it takes to make items part of available inventory, after the items have been posted as received.';

                    trigger OnValidate()
                    begin
                        InboundWhseHandlingTimeOnAfter();
                    end;
                }
            }
            group("Foreign Trade")
            {
                Caption = 'Foreign Trade';
                Editable = (Status = Status::Open) AND EnableTransferFields;
                field("Transaction Type"; Rec."Transaction Type")
                {
                    ApplicationArea = BasicEU, BasicNO;
                    Importance = Promoted;
                    ToolTip = 'Specifies the type of transaction that the document represents, for the purpose of reporting to INTRASTAT.';
                }
                field("Transaction Specification"; Rec."Transaction Specification")
                {
                    ApplicationArea = BasicEU, BasicNO;
                    ToolTip = 'Specifies a specification of the document''s transaction, for the purpose of reporting to INTRASTAT.';
                }
                field("Transport Method"; Rec."Transport Method")
                {
                    ApplicationArea = BasicEU, BasicNO;
                    Importance = Promoted;
                    ToolTip = 'Specifies the transport method, for the purpose of reporting to INTRASTAT.';
                }
                field("Area"; Area)
                {
                    ApplicationArea = BasicEU, BasicNO;
                    ToolTip = 'Specifies the area of the customer or vendor, for the purpose of reporting to INTRASTAT.';
                }
                field("Entry/Exit Point"; Rec."Entry/Exit Point")
                {
                    ApplicationArea = BasicEU, BasicNO;
                    ToolTip = 'Specifies the code of either the port of entry at which the items passed into your country/region, or the port of exit.';
                }
                field("Partner VAT ID"; Rec."Partner VAT ID")
                {
                    ApplicationArea = BasicEU, BasicNO;
                    ToolTip = 'Specifies the counter party''s VAT number.';
                }
            }
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
            group("O&rder")
            {
                Caption = 'O&rder';
                Image = "Order";
                action(Statistics)
                {
                    ApplicationArea = Location;
                    Caption = 'Statistics';
                    Image = Statistics;
                    RunObject = Page "Transfer Statistics";
                    RunPageLink = "No." = FIELD("No.");
                    ShortCutKey = 'F7';
                    ToolTip = 'View statistical information about the transfer order, such as the quantity and total weight transferred.';
                }
                action("Co&mments")
                {
                    ApplicationArea = Comments;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    RunObject = Page "Inventory Comment Sheet";
                    RunPageLink = "Document Type" = CONST("Transfer Order"),
                                    "No." = FIELD("No.");
                    ToolTip = 'View or add comments for the record.';
                }
                action(Dimensions)
                {
                    AccessByPermission = TableData Dimension = R;
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Alt+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction()
                    begin
                        ShowDocDim();
                        CurrPage.SaveRecord();
                    end;
                }
            }
            group(Documents)
            {
                Caption = 'Documents';
                Image = Documents;
                action("S&hipments")
                {
                    ApplicationArea = Location;
                    Caption = 'S&hipments';
                    Image = Shipment;
                    RunObject = Page "Posted Transfer Shipments";
                    RunPageLink = "Transfer Order No." = FIELD("No.");
                    ToolTip = 'View related posted transfer shipments.';
                }
                action("Re&ceipts")
                {
                    ApplicationArea = Location;
                    Caption = 'Re&ceipts';
                    Image = PostedReceipts;
                    RunObject = Page "Posted Transfer Receipts";
                    RunPageLink = "Transfer Order No." = FIELD("No.");
                    ToolTip = 'View related posted transfer receipts.';
                }
            }
            /*
            group(AutoLotAssignment)
            {
                action(AutoLotAssignShipment)
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'AutoLotAssignShipment';
                    Image = Shipment;

                    ShortCutKey = 'Ctrl+Alt+I';
                    ToolTip = 'View or edit serial numbers and lot numbers that are assigned to the item on the document or journal line.';

                    trigger OnAction()
                    var
                        ReservEntry: Record "Reservation Entry";
                        CreateReservEntry: Codeunit "Create Reserv. Entry";
                        TempTransferLine: Record "Transfer Line";
                        TempIetm: Record Item;
                        Intestorecodeunit: Codeunit AllSCMCustomization;
                        ILE: Record "Item Ledger Entry";
                        TotalQty: Decimal;
                        qty_qtyBase: Decimal;
                        TotalQtytoShipBase: Decimal;
                        TotalQtytoReceiveBase: Decimal;
                        ILE1: Record "Item Ledger Entry";
                        qtyCount: Decimal;
                        ValidateReservationEntry: Record "Reservation Entry";

                    begin
                        //validation to check 
                        ValidateReservationEntry.Reset;
                        ValidateReservationEntry.SetRange(AutoLotDocumentNo, Rec."No.");
                        if ValidateReservationEntry.FindFirst() then
                            Error('Lot is already assigned for this document , if you want to reassign lotno please delete a existing line first');
                        //


                        TempTransferLine.Reset();
                        TempTransferLine.SetRange("Document No.", Rec."No.");
                        if TempTransferLine.FindSet() then
                            repeat

                                ValidateReservationEntry.Reset();
                                ValidateReservationEntry.SetRange("Source ID", TempTransferLine."Document No.");
                                ValidateReservationEntry.SetRange("Source Ref. No.", TempTransferLine."Line No.");
                                IF not ValidateReservationEntry.FindFirst() then begin
                                    TotalQty := TempTransferLine.Quantity;
                                    TotalQtytoShipBase := (TempTransferLine.Quantity * TempTransferLine."Qty. per Unit of Measure");// TempTransferLine."Qty. to Ship (Base)";
                                    TotalQtytoReceiveBase := (TempTransferLine.Quantity * TempTransferLine."Qty. per Unit of Measure");//TempTransferLine."Qty. to Receive (Base)";
                                    IF TempIetm.Get(TempTransferLine."Item No.") then;
                                    if TempIetm."Item Tracking Code" <> '' then Begin

                                        //Validation for insuffient qty 
                                        qtyCount := 0;
                                        ILE1.Reset();
                                        ILE1.SetRange("Item No.", TempIetm."No.");
                                        ILE1.SetRange("Location Code", TempTransferLine."Transfer-from Code");
                                        ILE1.SetRange(Open, true);
                                        ILE1.SetFilter("Remaining Quantity", '>%1', 0);
                                        ILE1.SetFilter("Lot No.", '<>%1', '');
                                        IF ILE1.FindFirst() then
                                            repeat
                                                qtyCount := qtyCount + ILE1."Remaining Quantity";
                                            Until ILE1.Next() = 0;
                                        If qtyCount < TempTransferLine.Quantity then
                                            Error('Qty avaliable in Lot and Qty enter online is less , please redure a qty available');
                                        //Validation end

                                        //reservation entry creation
                                        ILE.Reset();
                                        ILE.SetCurrentKey("Entry No.");
                                        ILE.SetAscending("Entry No.", true);
                                        ILE.SetRange("Item No.", TempIetm."No.");
                                        ILE.SetRange("Location Code", TempTransferLine."Transfer-from Code");
                                        ILE.SetRange(Open, true);
                                        ILE.SetFilter("Remaining Quantity", '>%1', 0);
                                        ILE.SetFilter("Lot No.", '<>%1', '');
                                        IF ILE.FindFirst() then
                                            repeat
                                                IF TotalQty > 0 then Begin
                                                    If ILE."Remaining Quantity" >= TotalQty then begin
                                                        qty_qtyBase := TotalQty * TempTransferLine."Qty. per Unit of Measure";
                                                        TotalQtytoShipBase := TotalQty * TempTransferLine."Qty. per Unit of Measure";
                                                        TotalQtytoReceiveBase := TotalQty * TempTransferLine."Qty. per Unit of Measure";
                                                        Intestorecodeunit.TransferOrderReservationEntry(TempTransferLine, ILE."Lot No.",
                                                        TotalQty, qty_qtyBase, TotalQtytoShipBase, TotalQtytoReceiveBase);
                                                        TotalQty := 0;
                                                        TotalQtytoReceiveBase := 0;
                                                        TotalQtytoReceiveBase := 0;
                                                    end else
                                                        if (ILE."Remaining Quantity" < TotalQty) then begin
                                                            qty_qtyBase := ILE."Remaining Quantity" * TempTransferLine."Qty. per Unit of Measure";
                                                            Intestorecodeunit.TransferOrderReservationEntry(TempTransferLine, ILE."Lot No.", ILE."Remaining Quantity",
                                                            qty_qtyBase, qty_qtyBase, qty_qtyBase);
                                                            TotalQty := TotalQty - ILE."Remaining Quantity";
                                                            TotalQtytoShipBase := TotalQtytoShipBase - qty_qtyBase;
                                                            TotalQtytoReceiveBase := TotalQtytoReceiveBase - qty_qtyBase
                                                        end;
                                                End;
                                            Until ILE.Next() = 0;

                                    end;
                                End;
                            Until TempTransferLine.next() = 0;

                        Message('Auto Lot no assigned sussessfully');
                    end;
                }
            }
            */

        }
        area(processing)
        {
            action("&Print")
            {
                ApplicationArea = Location;
                Caption = '&Print';
                Ellipsis = true;
                Image = Print;
                ToolTip = 'Prepare to print the document. A report request window for the document opens where you can specify what to include on the print-out.';

                trigger OnAction()
                var
                    DocPrint: Codeunit "Document-Print";
                begin
                    DocPrint.PrintTransferHeader(Rec);
                end;
            }
            group(Release)
            {
                Caption = 'Release';
                Image = ReleaseDoc;
                action("Re&lease")
                {

                    ApplicationArea = Location;
                    Caption = 'Re&lease';
                    Image = ReleaseDoc;
                    RunObject = Codeunit "Release Transfer Document";
                    ShortCutKey = 'Ctrl+F9';
                    ToolTip = 'Release the document to the next stage of processing. You must reopen the document before you can make changes to it.';

                    trigger OnAction()
                    var
                        TempUserSetup: Record "User Setup";
                        TempTransferLine: Record "Transfer Line";
                        TempItem: Record Item;
                        ValidateReservationEntry: Record "Reservation Entry";
                    begin
                        TempTransferLine.Reset();
                        TempTransferLine.SetRange("Document No.", Rec."No.");
                        IF TempTransferLine.FindSet() then
                            repeat
                                IF TempItem.get(TempTransferLine."Item No.") then;
                                IF TempItem."Item Tracking Code" <> '' then begin
                                    ValidateReservationEntry.Reset();
                                    ValidateReservationEntry.SetRange("Source ID", TempTransferLine."Document No.");
                                    ValidateReservationEntry.SetRange("Source Ref. No.", TempTransferLine."Line No.");
                                    IF Not ValidateReservationEntry.FindFirst() then
                                        Error('Please assign lot No for Item No. %1 ', TempTransferLine."Item No.");
                                end;
                            until TempTransferLine.Next() = 0;
                    end;
                }
                action("Reo&pen")
                {
                    ApplicationArea = Location;
                    Caption = 'Reo&pen';
                    Image = ReOpen;
                    ToolTip = 'Reopen the transfer order after being released for warehouse handling.';

                    trigger OnAction()
                    var
                        ReleaseTransferDoc: Codeunit "Release Transfer Document";

                    begin
                        //Mahendra added 16 Aug 
                        IF Rec."Last Shipment No." <> '' then
                            Error('It is not allowed to reopen a transfer order once it get shipped');
                        //  Error('For inter store transfer you can not reopen a transfer order once release');

                        ReleaseTransferDoc.Reopen(Rec);
                    end;
                }
            }
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("Create Whse. S&hipment")
                {
                    AccessByPermission = TableData "Warehouse Shipment Header" = R;
                    ApplicationArea = Warehouse;
                    Caption = 'Create Whse. S&hipment';
                    Image = NewShipment;
                    ToolTip = 'Create a warehouse shipment to start a pick a ship process according to an advanced warehouse configuration.';

                    trigger OnAction()
                    var
                        GetSourceDocOutbound: Codeunit "Get Source Doc. Outbound";
                    begin
                        GetSourceDocOutbound.CreateFromOutbndTransferOrder(Rec);
                    end;
                }
                action("Create &Whse. Receipt")
                {
                    AccessByPermission = TableData "Warehouse Receipt Header" = R;
                    ApplicationArea = Warehouse;
                    Caption = 'Create &Whse. Receipt';
                    Image = NewReceipt;
                    ToolTip = 'Create a warehouse receipt to start a receive and put-away process according to an advanced warehouse configuration.';

                    trigger OnAction()
                    var
                        GetSourceDocInbound: Codeunit "Get Source Doc. Inbound";
                    begin
                        GetSourceDocInbound.CreateFromInbndTransferOrder(Rec);
                    end;
                }
                action("Create Inventor&y Put-away/Pick")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Create Inventor&y Put-away/Pick';
                    Ellipsis = true;
                    Image = CreateInventoryPickup;
                    ToolTip = 'Create an inventory put-away or inventory pick to handle items on the document with a basic warehouse process that does not require warehouse receipt or shipment documents.';

                    trigger OnAction()
                    begin
                        CreateInvtPutAwayPick();
                    end;
                }
                action("Get Bin Content")
                {
                    AccessByPermission = TableData "Bin Content" = R;
                    ApplicationArea = Warehouse;
                    Caption = 'Get Bin Content';
                    Ellipsis = true;
                    Image = GetBinContent;
                    ToolTip = 'Use a function to create transfer lines with items to put away or pick based on the actual content in the specified bin.';

                    trigger OnAction()
                    var
                        BinContent: Record "Bin Content";
                        GetBinContent: Report "Whse. Get Bin Content";
                    begin
                        BinContent.SetRange("Location Code", "Transfer-from Code");
                        GetBinContent.SetTableView(BinContent);
                        GetBinContent.InitializeTransferHeader(Rec);
                        GetBinContent.RunModal();
                    end;
                }
                action(GetReceiptLines)
                {
                    ApplicationArea = Location;
                    Caption = 'Get Receipt Lines';
                    Image = Receipt;
                    ToolTip = 'Add transfer order lines from posted purchase receipt lines.';

                    trigger OnAction()
                    begin
                        GetReceiptLines();
                    end;
                }
            }
            group("P&osting")
            {
                Caption = 'P&osting';
                Image = Post;
                action(Post)
                {
                    ApplicationArea = Location;
                    Caption = 'P&ost';
                    Ellipsis = true;
                    Image = PostOrder;
                    ShortCutKey = 'F9';
                    ToolTip = 'Finalize the document or journal by posting the amounts and quantities to the related accounts in your company books.';

                    trigger OnAction()
                    var
                        TempUserSetup: Record "User Setup";
                        GSTLedgerEntry: Record "GST Ledger Entry";
                        GSTAmount: Decimal;
                        TempTransferLine: Record "Transfer Line";
                        TempItem: Record Item;
                        ValidateReservationEntry: Record "Reservation Entry";
                        TempTransferLine1: Record "Transfer Line";
                        Invetsetup: Record "Inventory Setup";
                        TempItemJnlLine1: Record "Item Journal Line";
                        TempItemJnlLine: Record "Item Journal Line";
                        ItemJournalName: Code[10];
                        ItemJournalBatchName: Code[10];
                        DocNo: Code[20];
                        TempJournalBatchName: Record "Item Journal Batch";
                        TempILE: Record "Item Ledger Entry";

                        CodeunittransferInOut: Codeunit TransferInOut;

                        //Dimension
                        DefaultDim: Record "Default Dimension";
                        GLSetup: Record "General Ledger Setup";
                        TotalQTYToShip: Decimal;
                        RecTransferLine: Record "Transfer Line";
                        RecReservationEntry2: Record "Reservation Entry";
                        SourceId: Code[20];
                        RecReservationEntry: Record "Reservation Entry";


                    begin
                        ///Post shiping Agent code
                        /// 
                        // IF Rec."Shipping Agent Code" = '' then
                        //  Error('Shipping Agent code should not be blank');

                        //auto lot assignment check
                        //ALLE_NICK_170124_DLT RESERVATION 
                        RecReservationEntry.SetRange("Location Code", rec."Transfer-from Code");
                        RecReservationEntry.SetFilter("Source ID", '<>%1', Rec."No.");
                        RecReservationEntry.SetFilter("Source Type", '%1', 5741);
                        RecReservationEntry.SetFilter("Source Prod. Order Line", '%1', 0);
                        RecReservationEntry.SetFilter(Positive, '%1', false);
                        if RecReservationEntry.FindSet() then
                            repeat
                                RecReservationEntry2.SetRange("Source ID", RecReservationEntry."Source ID");
                                if RecReservationEntry2.FindSet() then
                                    RecReservationEntry2.DeleteAll();
                            until RecReservationEntry.Next() = 0;

                        TempTransferLine.Reset();
                        TempTransferLine.SetRange("Document No.", Rec."No.");
                        TempTransferLine.SetFilter("Qty. to Ship", '<>%1', 0);//PT-FBTS- 09-08-24   
                        IF TempTransferLine.FindSet() then
                            repeat
                                IF TempItem.get(TempTransferLine."Item No.") then;
                                IF TempItem."Item Tracking Code" <> '' then begin
                                    ValidateReservationEntry.Reset();
                                    ValidateReservationEntry.SetRange("Source ID", TempTransferLine."Document No.");
                                    ValidateReservationEntry.SetRange("Source Ref. No.", TempTransferLine."Line No.");
                                    IF Not ValidateReservationEntry.FindFirst() then
                                        Error('Please assign lot No for Item No. %1 ', TempTransferLine."Item No.");
                                end;
                            until TempTransferLine.Next() = 0;
                        //validation to check if location code is coorect
                        TempUserSetup.Get(UserId);
                        if Rec."Transfer-from Code" <> TempUserSetup."Location Code" then
                            Error('Location Mentioned on User setup and transfer to location must be same , For Posting Instore transfer');

                        TempTransferLine1.Reset();
                        TempTransferLine1.SetRange("Document No.", Rec."No.");
                        IF TempTransferLine1.FindSet() then
                            repeat
                                IF TempItem.Get(TempTransferLine1."Item No.") then;
                                IF TempItem.IsFixedAssetItem then begin
                                    IF TempTransferLine1.FixedAssetNo = '' then
                                        Error('As you have selected fixed Asset Item , It is manadatory to select fixed asset number');
                                end;
                            Until TempTransferLine1.Next() = 0;

                        TempTransferLine1.Reset();
                        TempTransferLine1.SetRange("Document No.", Rec."No.");
                        TempTransferLine1.SetFilter(FixedAssetNo, '<>%1', '');
                        IF TempTransferLine1.FindSet() then
                            TempTransferLine1.CalcSums("Qty. to Ship");//PT-FBTS
                        repeat
                            TempILE.Reset();
                            TempILE.SetRange("Document No.", Rec."No.");
                            TempILE.SetFilter("Document Type", '=%1', TempILE."Entry Type"::"Positive Adjmt.");
                            IF Not TempILE.FindFirst() Then Begin

                                IF TempItem.Get(TempTransferLine1."Item No.") then;
                                IF TempItem.IsFixedAssetItem then Begin

                                    Invetsetup.get;
                                    ItemJournalName := Invetsetup.FATransferTemplateName;
                                    ItemJournalBatchName := Invetsetup.FATransferBatchName;
                                    Invetsetup.TestField(Invetsetup.FATransferTemplateName);
                                    Invetsetup.TestField(Invetsetup.FATransferBatchName);


                                    // if TempJournalBatchName.Get(Invetsetup.FATransferTemplateName, Invetsetup.FATransferBatchName) Then;

                                    TempItemJnlLine1.Reset();
                                    TempItemJnlLine1.SetRange("Journal Template Name", Invetsetup.FATransferTemplateName);
                                    TempItemJnlLine1.SetRange("Journal Batch Name", Invetsetup.FATransferBatchName);
                                    IF TempItemJnlLine1.FindSet() then
                                        TempItemJnlLine1.DeleteAll(true);
                                    TempItemJnlLine.Init();
                                    TempItemJnlLine."Journal Template Name" := ItemJournalName;
                                    TempItemJnlLine."Journal Batch Name" := ItemJournalBatchName;

                                    DocNo := Rec."No.";//NoSeriesMgmt.GetNextNo(TempJournalBatchName."No. Series", Rec."Posting date", false);
                                    TempItemJnlLine."Document No." := DocNo;

                                    TempItemJnlLine."Line No." := TempTransferLine1."Line No.";

                                    TempItemJnlLine."Posting No. Series" := TempJournalBatchName."No. Series";
                                    TempItemJnlLine.Validate(TempItemJnlLine."Posting No. Series");
                                    //TempItemJnlLine.Validate(TempItemJnlLine."Document No.");

                                    //Message(TempItemJnlLine."Document No.");

                                    TempItemJnlLine."Posting Date" := Rec."Posting date";
                                    TempItemJnlLine.Validate(TempItemJnlLine."Posting Date");

                                    TempItemJnlLine."Entry Type" := TempItemJnlLine."Entry Type"::"Positive Adjmt.";
                                    TempItemJnlLine.Validate(TempItemJnlLine."Entry Type");

                                    TempItemJnlLine."Item No." := TempTransferLine1."Item No.";

                                    TempItemJnlLine.Validate(TempItemJnlLine."Item No.");

                                    IF TempItem.Get(TempItemJnlLine."Item No.") then;
                                    TempItemJnlLine."Gen. Prod. Posting Group" := TempItem."Gen. Prod. Posting Group";
                                    TempItemJnlLine.Validate(TempItemJnlLine."Gen. Prod. Posting Group");

                                    TempItemJnlLine."Document Date" := Rec."Posting date";
                                    TempItemJnlLine.Validate(TempItemJnlLine."Document Date");

                                    TempItemJnlLine."Location Code" := Rec."Transfer-from Code";
                                    TempItemJnlLine.Validate(TempItemJnlLine."Location Code");

                                    TempItemJnlLine.Quantity := TempTransferLine1."Qty. to Ship";
                                    TempItemJnlLine.Validate(TempItemJnlLine.Quantity);
                                    //TempItemJnlLine."Unit Cost" := TempTransferLine1.UnitPrice;
                                    // TempItemJnlLine.Amount := TempTransferLine1.Amount;//OLD Code -PT-FBTS
                                    TempItemJnlLine.Validate("Unit Amount", 0.01); //PT-FBTS NewCode
                                    TempItemJnlLine.Validate(TempItemJnlLine."Unit Amount");
                                    //TempItemJnlLine.Validate(TempItemJnlLine.Amount);
                                    //Dimension
                                    GLSetup.Get();
                                    DefaultDim.Reset();
                                    DefaultDim.SetRange("Table ID", 14);
                                    DefaultDim.SetRange("No.", TempItemJnlLine."Location Code");
                                    DefaultDim.SetRange("Dimension Code", GLSetup."Global Dimension 1 Code");
                                    if DefaultDim.FindFirst() then begin
                                        TempItemJnlLine."Shortcut Dimension 1 Code" := DefaultDim."Dimension Value Code";
                                        TempItemJnlLine.Validate(TempItemJnlLine."Shortcut Dimension 1 Code");
                                    end;

                                    GLSetup.Get();
                                    DefaultDim.Reset();
                                    DefaultDim.SetRange("Table ID", 14);
                                    DefaultDim.SetRange("No.", TempItemJnlLine."Location Code");
                                    DefaultDim.SetRange("Dimension Code", GLSetup."Global Dimension 2 Code");
                                    if DefaultDim.FindFirst() then begin
                                        TempItemJnlLine."Shortcut Dimension 2 Code" := DefaultDim."Dimension Value Code";
                                        TempItemJnlLine.Validate(TempItemJnlLine."Shortcut Dimension 2 Code");
                                    end;
                                    //end

                                    TempItemJnlLine.Insert();
                                    Commit();
                                    CODEUNIT.Run(CODEUNIT::"Item Jnl.-Post", TempItemJnlLine);
                                End;
                            End;
                        Until TempTransferLine1.Next() = 0;

                        GSTAmount := 0;
                        GSTLedgerEntry.Reset();
                        GSTLedgerEntry.SetRange("Document No.", Rec."No.");
                        if GSTLedgerEntry.FindSet() then
                            repeat
                                GSTAmount += Abs(GSTLedgerEntry."GST Amount");
                            until GSTLedgerEntry.Next() = 0;

                        IF GSTAmount = 0 then;

                        IF Confirm('Please make sure that you have calculate GST on transfer order , Do you want to continue') Then
                            CodeunittransferInOut.TransferInoutPost(Rec, true, false);
                        // CODEUNIT.Run(CODEUNIT::"TransferOrder-Post (Yes/No)", Rec);
                    end;
                }
                /*
                action(PostAndPrint)
                {
                    ApplicationArea = Location;
                    Caption = 'Post and &Print';
                    Image = PostPrint;
                    ShortCutKey = 'Shift+F9';
                    ToolTip = 'Finalize and prepare to print the document or journal. The values and quantities are posted to the related accounts. A report request window where you can specify what to include on the print-out.';

                    trigger OnAction()
                    begin
                        CODEUNIT.Run(CODEUNIT::"TransferOrder-Post + Print", Rec);
                    end;
                }
                */
            }
            group(DeleteLine)
            {
                action(DeleteTransferLine)
                {
                    ApplicationArea = All;
                    Caption = 'Delete Zero Qty Lines';
                    Image = PostPrint;
                    ToolTip = 'Delete Zero Qty Lines';

                    trigger OnAction()
                    var
                        TempTransLine: Record "Transfer Line";
                    begin
                        IF Rec.Status = Rec.Status::Open then begin
                            TempTransLine.Reset();
                            TempTransLine.SetRange("Document No.", Rec."No.");
                            TempTransLine.SetFilter(Quantity, '=%1', 0);
                            IF TempTransLine.FindSet() Then begin
                                TempTransLine.DeleteAll();
                                CurrPage.Update();
                            end;
                        end;
                    end;
                }
            }
        }
        area(reporting)
        {

        }

    }

    trigger OnAfterGetRecord()
    begin
        EnableTransferFields := not IsPartiallyShipped();
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        TestField(Status, Status::Open);
    end;

    //mahendra
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        tempusersetup: Record "User Setup";
    begin
        if tempusersetup.get(UserId) then;
        Rec."Transfer-from Code" := tempusersetup."Location Code";
        Rec.Validate(Rec."Transfer-from Code");

    end;

    trigger OnOpenPage()
    begin
        SetDocNoVisible();
        EnableTransferFields := not IsPartiallyShipped();
        ActivateFields();
    end;



    var
        FormatAddress: Codeunit "Format Address";

        ShippingAgentCode: Code[10];
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
}

