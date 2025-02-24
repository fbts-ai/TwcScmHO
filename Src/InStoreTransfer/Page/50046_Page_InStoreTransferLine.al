page 50046 "Instore Transfer Order Subform"
{
    AutoSplitKey = true;
    Caption = 'Instore Transfer Order Subform';
    DelayedInsert = true;
    LinksAllowed = false;
    InsertAllowed = true;
    DeleteAllowed = true;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "Transfer Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Location;
                    Lookup = true;
                    ToolTip = 'Specifies the number of the item that will be transferred.';

                    trigger OnValidate()
                    var
                        TempItem: Record "Item";
                    begin
                        UpdateForm(true);

                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        TempItem: Record "Item";
                    begin
                        TempItem.Reset();
                        TempItem.SetFilter(InstoreAllowed, '%1', true);
                        IF TempItem.FindSet() then;
                        IF PAGE.RUNMODAL(0, TempItem) = ACTION::LookupOK THEN begin
                            Rec."Item No." := TempItem."No.";
                            Rec.Validate(Rec."Item No.");
                        end;

                    end;


                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the variant of the item on the line.';
                    Visible = false;
                }

                field(Description; Description)
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies a description of the entry.';
                }

                field(Quantity; Quantity)
                {
                    ApplicationArea = Location;
                    BlankZero = true;
                    ToolTip = 'Specifies the quantity of the item that will be processed as the document stipulates.';
                }

                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                }
                field(ItemInventory; ItemInventory)
                {
                    ApplicationArea = all;
                    //ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the name of the item or resource''s unit of measure, such as piece or hour.';
                    Visible = false;
                }
                field("Qty. to Ship"; Rec."Qty. to Ship")
                {
                    ApplicationArea = Location;
                    BlankZero = true;
                    ToolTip = 'Specifies the quantity of items that remain to be shipped.';
                }
                field("Quantity Shipped"; Rec."Quantity Shipped")
                {
                    ApplicationArea = Location;
                    BlankZero = true;
                    ToolTip = 'Specifies how many units of the item on the line have been posted as shipped.';

                    trigger OnDrillDown()
                    var
                        TransShptLine: Record "Transfer Shipment Line";
                    begin
                        TestField("Document No.");
                        TestField("Item No.");
                        TransShptLine.SetCurrentKey("Transfer Order No.", "Item No.", "Shipment Date");
                        TransShptLine.SetRange("Transfer Order No.", "Document No.");
                        TransShptLine.SetRange("Line No.", "Line No.");
                        PAGE.RunModal(0, TransShptLine);
                    end;
                }
                field("Qty. to Receive"; Rec."Qty. to Receive")
                {
                    ApplicationArea = Location;
                    BlankZero = true;
                    Editable = NOT "Direct Transfer";
                    ToolTip = 'Specifies the quantity of items that remains to be received.';
                }
                field("Quantity Received"; Rec."Quantity Received")
                {
                    ApplicationArea = Location;
                    BlankZero = true;
                    ToolTip = 'Specifies how many units of the item on the line have been posted as received.';

                    trigger OnDrillDown()
                    var
                        TransRcptLine: Record "Transfer Receipt Line";
                    begin
                        TestField("Document No.");
                        TestField("Item No.");
                        TransRcptLine.SetCurrentKey("Transfer Order No.", "Item No.", "Receipt Date");
                        TransRcptLine.SetRange("Transfer Order No.", "Document No.");
                        TransRcptLine.SetRange("Line No.", "Line No.");
                        PAGE.RunModal(0, TransRcptLine);
                    end;
                }
                field("Shipment Date"; Rec."Shipment Date")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies when items on the document are shipped or were shipped. A shipment date is usually calculated from a requested delivery date plus lead time.';
                }
                field("Receipt Date"; Rec."Receipt Date")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the date that you expect the transfer-to location to receive the shipment.';
                }
                field(Remarks; Rec.Remarks)
                {
                    caption = 'Remarks';
                }


            }
        }
    }

    actions
    {
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";

            }
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                group("Item Availability by")
                {
                    Caption = 'Item Availability by';
                    Image = ItemAvailability;
                    action("Event")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Event';
                        Image = "Event";
                        ToolTip = 'View how the actual and the projected available balance of an item will develop over time according to supply and demand events.';

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromTransLine(Rec, ItemAvailFormsMgt.ByEvent());
                        end;
                    }
                    action(Period)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Period';
                        Image = Period;
                        ToolTip = 'Show the projected quantity of the item over time according to time periods, such as day, week, or month.';

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromTransLine(Rec, ItemAvailFormsMgt.ByPeriod());
                        end;
                    }
                    action(Variant)
                    {
                        ApplicationArea = Planning;
                        Caption = 'Variant';
                        Image = ItemVariant;
                        ToolTip = 'View or edit the item''s variants. Instead of setting up each color of an item as a separate item, you can set up the various colors as variants of the item.';

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromTransLine(Rec, ItemAvailFormsMgt.ByVariant());
                        end;
                    }
                    action(Location)
                    {
                        AccessByPermission = TableData Location = R;
                        ApplicationArea = Location;
                        Caption = 'Location';
                        Image = Warehouse;
                        ToolTip = 'View the actual and projected quantity of the item per location.';

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromTransLine(Rec, ItemAvailFormsMgt.ByLocation());
                        end;
                    }
                    action(Lot)
                    {
                        ApplicationArea = ItemTracking;
                        Caption = 'Lot';
                        Image = LotInfo;
                        RunObject = Page "Item Availability by Lot No.";
                        RunPageLink = "No." = field("Item No."),
                            "Variant Filter" = field("Variant Code");
                        ToolTip = 'View the current and projected quantity of the item in each lot.';
                    }
                    action("BOM Level")
                    {
                        ApplicationArea = Location;
                        Caption = 'BOM Level';
                        Image = BOMLevel;
                        ToolTip = 'View availability figures for items on bills of materials that show how many units of a parent item you can make based on the availability of child items.';

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromTransLine(Rec, ItemAvailFormsMgt.ByBOM());
                        end;
                    }
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
                        ShowDimensions();
                    end;
                }
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
                            ValidateReservationEntry.SetRange(AutoLotDocumentNo, Rec."Document No.");
                            if ValidateReservationEntry.FindFirst() then
                                Error('Lot is already assigned for this document , if you want to reassign lotno please delete a existing line first');
                            //
                            TempTransferLine.Reset();
                            TempTransferLine.SetRange("Document No.", Rec."Document No.");
                            if TempTransferLine.FindSet() then
                                repeat
                                    ValidateReservationEntry.Reset();
                                    ValidateReservationEntry.SetRange("Source ID", TempTransferLine."Document No.");
                                    ValidateReservationEntry.SetRange("Source Ref. No.", TempTransferLine."Line No.");
                                    IF not ValidateReservationEntry.FindFirst() then begin
                                        TotalQty := TempTransferLine.Quantity * TempTransferLine."Qty. per Unit of Measure";
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
                                            If qtyCount < (TempTransferLine.Quantity * TempTransferLine."Qty. per Unit of Measure") then
                                                Error('Qty available in Lot and Qty enter online is less , please reduce a qty available for item %1', TempTransferLine."Item No.");
                                            //Validation end

                                            //reservation entry creation
                                            ILE.Reset();
                                            ILE.SetRange("Item No.", TempIetm."No.");
                                            ILE.SetRange("Location Code", TempTransferLine."Transfer-from Code");
                                            ILE.SetRange(Open, true);
                                            ILE.SetFilter("Remaining Quantity", '>%1', 0);
                                            ILE.SetFilter("Lot No.", '<>%1', '');
                                            IF ILE.FindFirst() then
                                                repeat
                                                    IF TotalQty > 0 then Begin
                                                        If ILE."Remaining Quantity" >= TotalQty then begin
                                                            qty_qtyBase := TotalQty;// * TempTransferLine."Qty. per Unit of Measure";
                                                            TotalQtytoShipBase := TotalQtytoShipBase;//TotalQty * TempTransferLine."Qty. per Unit of Measure";
                                                            TotalQtytoReceiveBase := TotalQtytoReceiveBase;//TotalQty * TempTransferLine."Qty. per Unit of Measure";
                                                            Intestorecodeunit.InterstoreReservationEntry(TempTransferLine, ILE."Lot No.",
                                                            TotalQty, qty_qtyBase, TotalQtytoShipBase, TotalQtytoReceiveBase, ILE."Expiration Date", ILE.ManufacturingDate);
                                                            TotalQty := 0;
                                                            TotalQtytoReceiveBase := 0;
                                                            TotalQtytoReceiveBase := 0;
                                                        end else
                                                            if (ILE."Remaining Quantity" < TotalQty) then begin
                                                                qty_qtyBase := ILE."Remaining Quantity";// * TempTransferLine."Qty. per Unit of Measure";
                                                                Intestorecodeunit.InterstoreReservationEntry(TempTransferLine, ILE."Lot No.", ILE."Remaining Quantity",
                                                                qty_qtyBase, qty_qtyBase, qty_qtyBase, ILE."Expiration Date", ILE.ManufacturingDate);
                                                                TotalQty := TotalQty - ILE."Remaining Quantity";
                                                                TotalQtytoShipBase := TotalQtytoShipBase - qty_qtyBase;
                                                                TotalQtytoReceiveBase := TotalQtytoReceiveBase - qty_qtyBase
                                                            end;
                                                    End;
                                                Until ILE.Next() = 0;

                                        end;
                                    end;
                                Until TempTransferLine.next() = 0;

                            Message('Auto Lot no assigned successfully');


                        end;
                    }


                }
                group("Item &Tracking Lines")
                {
                    Caption = 'Item &Tracking Lines';
                    Image = AllLines;
                    action(Shipment)
                    {
                        ApplicationArea = ItemTracking;
                        Caption = 'Shipment';
                        Image = Shipment;
                        ShortCutKey = 'Ctrl+Alt+I';
                        ToolTip = 'View or edit serial numbers and lot numbers that are assigned to the item on the document or journal line.';

                        trigger OnAction()
                        begin
                            OpenItemTrackingLines("Transfer Direction"::Outbound);
                        end;
                    }

                    action(Receipt)
                    {
                        ApplicationArea = ItemTracking;
                        Caption = 'Receipt';
                        Image = Receipt;
                        ShortCutKey = 'Shift+Ctrl+R';
                        ToolTip = 'View or edit serial numbers and lot numbers that are assigned to the item on the document or journal line.';

                        trigger OnAction()
                        begin
                            OpenItemTrackingLinesWithReclass("Transfer Direction"::Inbound);
                        end;
                    }
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ShowShortcutDimCode(ShortcutDimCode);
    end;

    trigger OnDeleteRecord(): Boolean
    var
        TransferLineReserve: Codeunit "Transfer Line-Reserve";
    begin
        Commit();
        if not TransferLineReserve.DeleteLineConfirm(Rec) then
            exit(false);
        TransferLineReserve.DeleteLine(Rec);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Clear(ShortcutDimCode);
    end;

    trigger OnOpenPage()
    begin
        SetDimensionsVisibility();
    end;

    var
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";

    protected var
        ShortcutDimCode: array[8] of Code[20];
        DimVisible1: Boolean;
        DimVisible2: Boolean;
        DimVisible3: Boolean;
        DimVisible4: Boolean;
        DimVisible5: Boolean;
        DimVisible6: Boolean;
        DimVisible7: Boolean;
        DimVisible8: Boolean;

    procedure UpdateForm(SetSaveRecord: Boolean)
    begin
        CurrPage.Update(SetSaveRecord);
    end;

    local procedure ReserveSelectedLines()
    var
        TransLine: Record "Transfer Line";
    begin
        CurrPage.SetSelectionFilter(TransLine);
        ReserveFromInventory(TransLine);
    end;

    local procedure SetDimensionsVisibility()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimVisible1 := false;
        DimVisible2 := false;
        DimVisible3 := false;
        DimVisible4 := false;
        DimVisible5 := false;
        DimVisible6 := false;
        DimVisible7 := false;
        DimVisible8 := false;

        DimMgt.UseShortcutDims(
          DimVisible1, DimVisible2, DimVisible3, DimVisible4, DimVisible5, DimVisible6, DimVisible7, DimVisible8);

        Clear(DimMgt);
    end;
}

