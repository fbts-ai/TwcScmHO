Page 50040 "Transfer Order Out Subform"
{
    AutoSplitKey = true;
    Caption = 'Transfer Order Out Subform';
    DelayedInsert = true;
    DeleteAllowed = false;//PT-FBTS
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    InsertAllowed = false;
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
                    Editable = false; //PT-FBTS
                    Lookup = true;
                    ToolTip = 'Specifies the number of the item that will be transferred.';

                    trigger OnValidate()
                    var
                        TempItem: Record "Item";
                        TempILE: Record "Item Ledger Entry";
                        qty: Decimal;

                    begin
                        IF TempItem.Get(Rec."Item No.") Then;

                        IF TempItem.IsFixedAssetItem then
                            IsFixedAsset := true;


                        TempILE.Reset();
                        TempILE.SetRange("Item No.", Rec."Item No.");
                        TempILE.SetRange("Location Code", Rec."Transfer-from Code");
                        IF TempILE.FindSet() then
                            repeat
                                qty := qty + TempILE.Quantity;
                                until TempILE.Next() = 0;
                                ItemInventory := qty;
                                CurrPage.Update();
                                UpdateForm(true);


                    end;



                }
                //AJ_ALLE_19122023
                //TodayFixedasset
                field("Parent Fixed Asset"; rec."Parent Fixed Asset")
                {
                    ApplicationArea = all;
                    Editable = false; //PT-FBTS
                }
                //AJ_ALLE_19122023

                field(Description; Description)
                {
                    ApplicationArea = Location;
                    Editable = false; //PT-FBTS
                    ToolTip = 'Specifies a description of the entry.';
                }
                field(FixedAssetNo; Rec.FixedAssetNo)
                {
                    Caption = 'Fixed Asset No.';
                    ApplicationArea = All;
                    Editable = true; //PT-FBTS
                    // Editable = IsFixedAsset;

                    trigger OnLookup(var Text: Text): Boolean//ALLE_NICK_190124 //TodayFixedasset
                    var
                        myInt: Integer;
                        fixedassed: Record "Fixed Asset";
                    begin
                        fixedassed.SetFilter(fixedassed."Used To", '%1', false);
                        fixedassed.SetFilter(fixedassed."PO Item", '%1', false);
                        fixedassed.SetFilter("Location Code", '%1', rec."Transfer-from Code");
                        fixedassed.SetFilter("Parent Fixed Asset", '%1', rec."Parent Fixed Asset");
                        IF PAGE.RUNMODAL(0, fixedassed) = ACTION::LookupOK THEN begin
                            Rec.Validate(Rec.FixedAssetNo, fixedassed."No.");
                        end;
                    end;
                }
                field("Indent Qty."; rec."Indent Qty.")
                {
                    Editable = false;
                }

                field(Quantity; Quantity)
                {
                    ApplicationArea = Location;
                    BlankZero = true;
                    Editable = false;
                    ToolTip = 'Specifies the quantity of the item that will be processed as the document stipulates.';

                    trigger OnValidate()
                    var
                        TaxCaseExecution: Codeunit "Use Case Execution";
                    begin
                        CurrPage.SaveRecord();
                        TaxCaseExecution.HandleEvent('OnAfterTransferPrirce', Rec, '', 0);
                    end;
                }
                field("Qty. to Ship"; Rec."Qty. to Ship")
                {
                    ApplicationArea = all;
                }
                field(ItemInventory; Rec.ItemInventory)
                {
                    Caption = 'Inventory';
                    Editable = False;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false; //PT-FBTS
                    ToolTip = 'Specifies the amount for the item on the transfer line.';
                }
                field("Transfer Price"; Rec."Transfer Price")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false; //PT-FBTS
                    ToolTip = 'Specifies the Transfer Price for the item on the transfer line.';

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord();
                    end;
                }
                field("GST Credit"; Rec."GST Credit")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false; //PT-FBTS
                    ToolTip = 'Specifies whether the GST credit should be availed or not';
                    trigger OnValidate()
                    var
                        TaxCaseExecution: Codeunit "Use Case Execution";
                    begin
                        CurrPage.SaveRecord();
                        TaxCaseExecution.HandleEvent('OnAfterTransferPrirce', Rec, '', 0);
                    end;
                }
                field(Remarks; Rec.Remarks)
                {
                    Caption = 'Remarks';
                    Editable = false; //PT-FBTS
                }
                field("Reserved Quantity Inbnd."; Rec."Reserved Quantity Inbnd.")
                {
                    ApplicationArea = Reservation;
                    BlankZero = true;
                    Editable = false; //PT-FBTS
                    ToolTip = 'Specifies the quantity of the item reserved at the transfer-to location.';
                }
                field("Reserved Quantity Shipped"; Rec."Reserved Quantity Shipped")
                {
                    ApplicationArea = Reservation;
                    BlankZero = true;
                    Editable = false; //PT-FBTS
                    ToolTip = 'Specifies how many units on the shipped transfer order are reserved.';
                }

                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = Location;
                    Editable = false; //PT-FBTS
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                }
                //added by Mahendra 14 Aug
                field("Qty. per Unit of Measure"; Rec."Qty. per Unit of Measure")
                {
                    Editable = false;
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the name of the item or resource''s unit of measure, such as piece or hour.';
                    Visible = false;
                }
                //added mahendra 14 Aug 
                /*
                field("Qty. to Ship"; Rec."Qty. to Ship")
                {
                    ApplicationArea = Location;
                    BlankZero = true;
                    ToolTip = 'Specifies the quantity of items that remain to be shipped.';
                }
                */
                field("Quantity Shipped"; Rec."Quantity Shipped")
                {
                    ApplicationArea = Location;
                    Editable = false; //PT-FBTS
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
                    //Editable = NOT "Direct Transfer";
                    Editable = false; //PT-FBTS
                    ToolTip = 'Specifies the quantity of items that remains to be received.';
                }
                field("Quantity Received"; Rec."Quantity Received")
                {
                    ApplicationArea = Location;
                    BlankZero = true;
                    Editable = false; //PT-FBTS
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
                    Editable = false; //PT-FBTS
                    ToolTip = 'Specifies when items on the document are shipped or were shipped. A shipment date is usually calculated from a requested delivery date plus lead time.';
                }
                field("Receipt Date"; Rec."Receipt Date")
                {
                    ApplicationArea = Location;
                    Editable = false; //PT-FBTS
                    ToolTip = 'Specifies the date that you expect the transfer-to location to receive the shipment.';
                }

                field("Custom Duty Amount"; Rec."Custom Duty Amount")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false; //PT-FBTS
                    ToolTip = 'Specifies the custom duty amount  on the transfer line.';

                    trigger OnValidate()
                    var
                        TaxCaseExecution: Codeunit "Use Case Execution";
                    begin
                        CurrPage.SaveRecord();
                        TaxCaseExecution.HandleEvent('OnAfterTransferPrirce', Rec, '', 0);
                    end;
                }
                field("GST Assessable Value"; Rec."GST Assessable Value")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false; //PT-FBTS
                    ToolTip = 'Specifies the GST assessable value on the transfer line.';

                    trigger OnValidate()
                    var
                        TaxCaseExecution: Codeunit "Use Case Execution";
                    begin
                        CurrPage.SaveRecord();
                        TaxCaseExecution.HandleEvent('OnAfterTransferPrirce', Rec, '', 0);
                    end;
                }
                field("GST Group Code"; Rec."GST Group Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false; //PT-FBTS
                    ToolTip = 'Specifies the GST Group code for the calculation of GST on transfer line.';

                    trigger OnValidate()
                    var
                        TaxCaseExecution: Codeunit "Use Case Execution";
                    begin
                        TaxCaseExecution.HandleEvent('OnAfterTransferPrirce', Rec, '', 0);
                    end;
                }
                field("HSN/SAC Code"; Rec."HSN/SAC Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false; //PT-FBTS
                    ToolTip = 'Specifies the HSN/SAC code for the calculation of GST on transfer line.';

                    trigger OnValidate()
                    var
                        TaxCaseExecution: Codeunit "Use Case Execution";
                    begin
                        TaxCaseExecution.HandleEvent('OnAfterTransferPrirce', Rec, '', 0);
                    end;
                }

                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field("ShortcutDimCode[3]"; ShortcutDimCode[3])
                {
                    ApplicationArea = Location;
                    CaptionClass = '1,2,3';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(3),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(3, ShortcutDimCode[3]);
                    end;
                }
                field("ShortcutDimCode[4]"; ShortcutDimCode[4])
                {
                    ApplicationArea = Location;
                    CaptionClass = '1,2,4';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(4),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(4, ShortcutDimCode[4]);
                    end;
                }
                field("ShortcutDimCode[5]"; ShortcutDimCode[5])
                {
                    ApplicationArea = Location;
                    CaptionClass = '1,2,5';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(5),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(5, ShortcutDimCode[5]);
                    end;
                }
                field("ShortcutDimCode[6]"; ShortcutDimCode[6])
                {
                    ApplicationArea = Location;
                    CaptionClass = '1,2,6';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(6),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(6, ShortcutDimCode[6]);
                    end;
                }
                field("ShortcutDimCode[7]"; ShortcutDimCode[7])
                {
                    ApplicationArea = Location;
                    CaptionClass = '1,2,7';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(7),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(7, ShortcutDimCode[7]);
                    end;
                }
                field("ShortcutDimCode[8]"; ShortcutDimCode[8])
                {
                    ApplicationArea = Location;
                    CaptionClass = '1,2,8';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(8),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(8, ShortcutDimCode[8]);
                    end;
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
                action(Reserve)
                {
                    ApplicationArea = Reservation;
                    Caption = '&Reserve';
                    Image = Reserve;
                    ToolTip = 'Reserve the quantity that is required on the document line that you opened this window for.';

                    trigger OnAction()
                    begin
                        Rec.Find();
                        Rec.ShowReservation();
                    end;
                }
                action(ReserveFromInventory)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Reserve from &Inventory';
                    Image = LineReserve;
                    ToolTip = 'Reserve items for the selected line from inventory.';

                    trigger OnAction()
                    begin
                        ReserveSelectedLines();
                    end;
                }
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

                                    TotalQty := TempTransferLine."Qty. to Ship" * TempTransferLine."Qty. per Unit of Measure"; //PT-FBTS 09-08-24
                                    TotalQtytoShipBase := (TempTransferLine."Qty. to Ship" * TempTransferLine."Qty. per Unit of Measure"); //PT-FBTS 09-08-24// TempTransferLine."Qty. to Ship (Base)";
                                    TotalQtytoReceiveBase := (TempTransferLine."Qty. to Ship" * TempTransferLine."Qty. per Unit of Measure");//PT-FBTS 09-08-24//TempTransferLine."Qty. to Receive (Base)";
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
                                        If qtyCount < (TempTransferLine."Qty. to Ship" * TempTransferLine."Qty. per Unit of Measure") then//PT-FBTS 09-08-24
                                            Error('Qty available in Lot and Qty enter online is less , please reduce a qty available for Item %1', TempTransferLine."Item No.");
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
                                                        qty_qtyBase := TotalQty;//TotalQty * TempTransferLine."Qty. per Unit of Measure";
                                                        TotalQtytoShipBase := TotalQtytoShipBase;//TotalQty * TempTransferLine."Qty. per Unit of Measure";
                                                        TotalQtytoReceiveBase := TotalQtytoReceiveBase;//TotalQty * TempTransferLine."Qty. per Unit of Measure";
                                                        Intestorecodeunit.TransferOrderReservationEntry(TempTransferLine, ILE."Lot No.",
                                                        TotalQty, qty_qtyBase, TotalQtytoShipBase, TotalQtytoReceiveBase, ILE."Expiration Date", ILE.ManufacturingDate);
                                                        TotalQty := 0;
                                                        TotalQtytoReceiveBase := 0;
                                                        TotalQtytoReceiveBase := 0;
                                                    end else
                                                        if (ILE."Remaining Quantity" < TotalQty) then begin
                                                            qty_qtyBase := ILE."Remaining Quantity";// * TempTransferLine."Qty. per Unit of Measure";
                                                            Intestorecodeunit.TransferOrderReservationEntry(TempTransferLine, ILE."Lot No.", ILE."Remaining Quantity",
                                                            qty_qtyBase, qty_qtyBase, qty_qtyBase, ILE."Expiration Date", ILE.ManufacturingDate);
                                                            TotalQty := TotalQty - ILE."Remaining Quantity";
                                                            TotalQtytoShipBase := TotalQtytoShipBase - qty_qtyBase;
                                                            TotalQtytoReceiveBase := TotalQtytoReceiveBase - qty_qtyBase
                                                        end;
                                                End;
                                            Until ILE.Next() = 0;

                                    end;
                                End;
                            Until TempTransferLine.next() = 0;

                        Message('Auto Lot no assigned successfully');
                    end;
                }
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
        [InDataSet]
        IsFixedAsset: Boolean;

        ItemInventory: Decimal;

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

    trigger OnAfterGetCurrRecord()
    var
        TempILE: Record "Item Ledger Entry";
        qty: Decimal;
    begin

        TempILE.Reset();
        TempILE.SetRange("Item No.", Rec."Item No.");
        TempILE.SetRange("Location Code", Rec."Transfer-from Code");
        IF TempILE.FindSet() then
            repeat
                qty := qty + TempILE.Quantity;
            until TempILE.Next() = 0;
        ItemInventory := qty;

    end;

    local procedure "Assign Lot NO"(transferline: Record "Transfer Line")
    var
        myInt: Integer;
        transferline2: Record "Transfer Line";
        Fromlocationline: Integer;
        Tolocationline: Integer;
    begin
        Clear(Reservationqty);
        QtyToAllocate := transferline."Qty. to Ship (Base)";
        itemledentry.Reset();
        itemledentry.SetFilter("Remaining Quantity", '<>%1', 0);
        ItemLedEntry.SetRange("Item No.", transferline."Item No.");
        itemledentry.SetRange("Location Code", transferline."Transfer-from Code");
        if itemledentry.FindSet() then begin
            repeat
                if QtyToAllocate = 0 then
                    exit;
                Clear(QtyToAllocate2);
                Clear(QtyToReservation);
                Clear(lotno);
                lotno := itemledentry."Lot No.";
                // ReservationEntry.Reset();
                // ReservationEntry.SetRange(ReservationEntry."Item No.", transferline."Item No.");
                // ReservationEntry.SetRange(ReservationEntry."Location Code", transferline."Transfer-from Code");
                // ReservationEntry.SetRange(ReservationEntry."Lot No.", Lotno);
                // ReservationEntry.SetRange("ILE No.", itemledentry."Entry No.");
                // ReservationEntry.SetFilter(Quantity, '<%1', 0);
                // ReservationEntry.CalcSums("Quantity (Base)");
                // Reservationqty := abs(ReservationEntry."Quantity (Base)");

                // if itemledentry."Remaining Quantity" > Reservationqty then begin

                //     IF QtyToAllocate >= itemledentry."Remaining Quantity" - Reservationqty then
                //         QtyToReservation := itemledentry."Remaining Quantity" - Reservationqty
                //     else
                //         QtyToReservation := QtyToAllocate;
                //     QtyToAllocate := QtyToAllocate - QtyToReservation;

                //     ReservationEntry2.RESET;
                //     ReservationEntry2.SetFilter("Lot No.", '<>%1', '');
                //     ReservationEntry2.SETRANGE("Source ID", TransferLine."Document No.");
                //     ReservationEntry2.SETRANGE("Source Ref. No.", TransferLine."Line No.");
                //     ReservationEntry2.SETRANGE("Item No.", TransferLine."Item No.");
                //     ReservationEntry2.CalcSums("Quantity (Base)");
                //     TotalremQtyILE2 := ReservationEntry2."Quantity (Base)";
                //     if transferline."Quantity (Base)" = TotalremQtyILE2 then
                //         exit;
                transferline2.SetRange("Transfer-from Code", transferline."Transfer-from Code");
                transferline2.SetRange("Item No.", transferline."Item No.");
                if transferline2.FindFirst() then begin
                    Fromlocationline := transferline2."Line No."
                end;
                transferline2.SetRange("Transfer-to Code", transferline."Transfer-to Code");
                transferline2.SetRange("Item No.", transferline."Item No.");
                if transferline2.FindFirst() then begin
                    Tolocationline := transferline2."Line No."
                end;
                Clear(Entry);
                ReservationEntry.Reset();
                if ReservationEntry.FindLast() then
                    Entry := ReservationEntry."Entry No." + 1
                else
                    Entry := 1;
                ReservationEntry.INIT;
                ReservationEntry."Entry No." := Entry + 2;
                ReservationEntry.Positive := TRUE;
                ReservationEntry."Item No." := TransferLine."Item No.";
                ReservationEntry."Location Code" := Rec."Transfer-to Code";
                ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Surplus;
                ReservationEntry."Creation Date" := transferline."Shipment Date";
                ReservationEntry."Source Type" := 5741;
                ReservationEntry."Source Subtype" := 1;
                ReservationEntry."Source ID" := TransferLine."Document No.";
                ReservationEntry."Source Ref. No." := Fromlocationline;
                ReservationEntry."Source Prod. Order Line" := Tolocationline;
                ReservationEntry."Expected Receipt Date" := transferline."Shipment Date";
                ReservationEntry."Created By" := USERID;
                ReservationEntry."Qty. per Unit of Measure" := TransferLine."Qty. per Unit of Measure";
                ReservationEntry.Validate(Quantity, TransferLine."Quantity (Base)");
                ReservationEntry."Quantity (Base)" := TransferLine."Quantity (Base)";
                ReservationEntry."Qty. to Handle (Base)" := TransferLine."Quantity (Base)";
                ReservationEntry."Qty. to Invoice (Base)" := TransferLine."Quantity (Base)";
                ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot No.";
                ReservationEntry.Validate("Lot No.", lotno);
                //ReservationEntry."ILE No." := itemledentry."Entry No.";
                ReservationEntry.INSERT(TRUE);
            //   end;
            until itemledentry.Next() = 0;
        end

    end;

    var
        myInt: Integer;
        ReservationEntry: Record "Reservation Entry"; // "Reservation Entry"
        ReservationEntry2: Record "Reservation Entry";
        Item: Record Item;
        transferHeader1: Record "Transfer Header";
        // NoSeriesMgt: Codeunit NoSeriesManagement;
        Entry: Integer;
        Start: Integer;
        Close: Integer;
        Lotno: Code[50];
        itemledentry: Record "Item Ledger Entry";
        itemledentry2: Record "Item Ledger Entry";
        QtyToAllocate: Decimal;
        QtyToReservation: Decimal;
        Reservationqty: Decimal;
        itemledentryqty: Decimal;
        QtyToAllocate2: Decimal;
        TotalremQtyILE: Decimal;
        TotalremQtyILE2: Decimal;
}

