
Page 50037 "Purchase Order GRN Subform"
{
    AutoSplitKey = true;
    Caption = 'Lines';
    InsertAllowed = false;
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "Purchase Line";
    SourceTableView = WHERE("Document Type" = FILTER(Order));

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;

                field("Select for Fixed Asset"; Rec.SelectforFixedAsset)
                {
                    ApplicationArea = All;
                }

                field(Type; Type)
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the line type.';

                    trigger OnValidate()
                    begin
                        NoOnAfterValidate();

                        UpdateEditableOnRow();
                        UpdateTypeText();
                        DeltaUpdateTotals();
                    end;
                }
                field(FilteredTypeField; TypeAsText)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Type';
                    //Editable = CurrPageIsEditable;
                    Editable = False;

                    LookupPageID = "Option Lookup List";
                    TableRelation = "Option Lookup Buffer"."Option Caption" WHERE("Lookup Type" = CONST(Purchases));
                    ToolTip = 'Specifies the type of transaction that will be posted with the document line. If you select Comment, then you can enter any text in the Description field, such as a message to a customer. ';
                    Visible = IsFoundation;

                    trigger OnValidate()
                    begin
                        TempOptionLookupBuffer.SetCurrentType(Type.AsInteger());
                        if TempOptionLookupBuffer.AutoCompleteLookup(TypeAsText, TempOptionLookupBuffer."Lookup Type"::Purchases) then
                            Validate(Type, TempOptionLookupBuffer.ID);
                        TempOptionLookupBuffer.ValidateOption(TypeAsText);
                        UpdateEditableOnRow();
                        UpdateTypeText();
                        DeltaUpdateTotals();
                    end;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Suite;
                    Editable = False;
                    ShowMandatory = Type <> Type::" ";
                    ToolTip = 'Specifies what you are buying, such as a product or a fixed asset. You’ll see different lists of things to choose from depending on your choice in the Type field.';

                    trigger OnValidate()
                    begin
                        ShowShortcutDimCode(ShortcutDimCode);
                        NoOnAfterValidate();

                        UpdateTypeText();
                        DeltaUpdateTotals();

                        CurrPage.Update();
                    end;
                }


                //Mahendra 06 April 2023
                /*

                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the variant of the item on the line.';
                    ShowMandatory = VariantCodeMandatory;
                    Visible = false;

                    trigger OnValidate()
                    var
                        Item: Record "Item";
                    begin
                        DeltaUpdateTotals();
                        if "Variant Code" = '' then
                            VariantCodeMandatory := Item.IsVariantMandatory(Rec.Type = Rec.Type::Item, Rec."No.");
                    end;
                }
                */

                field(Description; Rec.Description)
                {
                    ApplicationArea = Suite;
                    Editable = False;
                    ToolTip = 'Describes what is being purchased. The suggested text comes from the item itself. You can change it to suit your needs for this document. If you change it here, the source of the text will not change. If the line''s Type field is set to Comment, you can use this field to write the comment, and leave the other fields empty.';

                    trigger OnValidate()
                    begin
                        //Mahendra 06 April 2023
                        /*

                         Rec.RestoreLookupSelection();
                         */

                        if Rec."No." = xRec."No." then
                            exit;

                        Rec.ShowShortcutDimCode(ShortcutDimCode);
                        NoOnAfterValidate();
                        DeltaUpdateTotals();
                    end;

                    trigger OnAfterLookup(Selected: RecordRef)
                    begin
                        // Rec.SaveLookupSelection(Selected); mahendra 06 April 2023
                    end;
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies information in addition to the description.';
                    Visible = false;
                }

                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Location;
                    // Editable = NOT IsBlankNumber;
                    // Enabled = NOT IsBlankNumber;
                    Editable = False;
                    ToolTip = 'Specifies a code for the location where you want the items to be placed when they are received.';

                    trigger OnValidate()
                    begin
                        ShowShortcutDimCode(ShortcutDimCode);
                        DeltaUpdateTotals();
                    end;
                }
                field(LocationName; LocationName)
                {
                    Caption = 'Location Name';
                    Editable = False;
                }

                field(Quantity; Quantity)
                {
                    ApplicationArea = Suite;
                    BlankZero = true;
                    Editable = False;
                    //Editable = NOT IsBlankNumber;
                    // Enabled = NOT IsBlankNumber;
                    ShowMandatory = (Type <> Type::" ") AND ("No." <> '');
                    ToolTip = 'Specifies the quantity of what you''re buying. The number is based on the unit chosen in the Unit of Measure Code field.';

                    trigger OnValidate()
                    begin
                        Rec.Validate("FA Qty.", Rec.Quantity);//PT-FBTS 09-08-24
                        DeltaUpdateTotals();
                        SetItemChargeFieldsStyle();
                        if PurchasesPayablesSetup."Calc. Inv. Discount" and (Quantity = 0) then
                            CurrPage.Update(false);
                    end;
                }
                field("GST Group Code"; "GST Group Code")
                {
                    ApplicationArea = all;
                }

                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = Suite;
                    Editable = False;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';

                    trigger OnValidate()
                    begin
                        DeltaUpdateTotals();
                    end;
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the unit of measure.';
                    Visible = false;
                }
                field("Direct Unit Cost"; rec."Direct Unit Cost")
                {
                    trigger OnValidate()
                    var
                        myInt: Integer;
                        InventorySetup: Record "Inventory Setup";
                        ItemRec: Record Item;
                        UserSetupRec: Record "User Setup";
                    begin
                        UserSetupRec.Get(UserId);
                        if rec."Direct Unit Cost" <> 0 then begin
                            if xRec."Direct Unit Cost" <> Rec."Direct Unit Cost" then begin
                                if (rec."No." <> '') and (rec.Quantity <> 0) then begin
                                    //  InventorySetup.Get();
                                    if Rec.Type = Rec.Type::"Fixed Asset" then begin
                                        //if InventorySetup."FA Non Editable" = true then oldcode
                                        if UserSetupRec."Fa Non Editable" = false then//PT-FBTS -4-10-24
                                            Error('FA- Direct Unit Cost is Uneditable');
                                    end;
                                    if Rec.Type = Rec.Type::Item then begin
                                        if ItemRec.Get(Rec."No.") then   //AJ_ALLE_30012024
                                            if ItemRec.Type = ItemRec.Type::Inventory then //AJ_ALLE_30012024
                                                                                           //if InventorySetup."Item Non Editable" = true then 
                                                if UserSetupRec."Item Non Editable" = false then //PT-FBTS -4-10-24
                                                    Error('Item Direct Unit Cost is Uneditable'); //AJ_ALLE_10112023
                                    end;
                                end;
                            end;
                        end;
                    end;
                }




                field("Line Amount"; Rec."Line Amount")
                {
                    ApplicationArea = Suite;
                    BlankZero = true;
                    Editable = NOT IsBlankNumber;
                    Enabled = NOT IsBlankNumber;
                    ToolTip = 'Specifies the net amount, excluding any invoice discount amount, that must be paid for products on the line.';

                    trigger OnValidate()
                    begin
                        DeltaUpdateTotals();
                    end;
                }

                field("FA Qty."; Rec."FA Qty.")//PT-FBTS 09-08-24
                {
                    ApplicationArea = all;
                    Editable = false;
                }

                field("Qty. to Receive"; Rec."Qty. to Receive")
                {
                    ApplicationArea = Suite;
                    BlankZero = true;
                    ToolTip = 'Specifies the quantity of items that remains to be received.';

                    trigger OnValidate()
                    begin
                        SetItemChargeFieldsStyle();
                    end;
                }
                field("Quantity Received"; Rec."Quantity Received")
                {
                    ApplicationArea = Suite;
                    BlankZero = true;
                    ToolTip = 'Specifies how many units of the item on the line have been posted as received.';
                }
                field("Qty. to Invoice"; Rec."Qty. to Invoice")
                {
                    ApplicationArea = Suite;
                    BlankZero = true;
                    Editable = false;
                    ToolTip = 'Specifies the quantity that remains to be invoiced. It is calculated as Quantity - Qty. Invoiced.';

                    trigger OnValidate()
                    begin
                        SetItemChargeFieldsStyle();
                    end;
                }
                field("Quantity Invoiced"; Rec."Quantity Invoiced")
                {
                    ApplicationArea = Suite;
                    BlankZero = true;
                    ToolTip = 'Specifies how many units of the item on the line have been posted as invoiced.';
                }
                field("HSN/SAC Code"; Rec."HSN/SAC Code")
                {
                    caption = 'HSN/SAC Code';
                }
                field(Remarks; Rec.Remarks)
                {
                    Caption = 'Remarks';
                }
                field("Requested Receipt Date"; Rec."Requested Receipt Date")
                {
                    ApplicationArea = Suite;
                    Editable = False;
                    ToolTip = 'Specifies the date that you want the vendor to deliver to the ship-to address. The value in the field is used to calculate the latest date you can order the items to have them delivered on the requested receipt date. If you do not need delivery on a specific date, you can leave the field blank.';
                    Visible = false;
                }
                field("Promised Receipt Date"; Rec."Promised Receipt Date")
                {
                    ApplicationArea = OrderPromising;
                    Editable = False;
                    ToolTip = 'Specifies the date that the vendor has promised to deliver the order.';
                    Visible = true;
                }
                field("Planned Receipt Date"; Rec."Planned Receipt Date")
                {
                    ApplicationArea = Suite;
                    Editable = False;
                    ToolTip = 'Specifies the date when the item is planned to arrive in inventory. Forward calculation: planned receipt date = order date + vendor lead time (per the vendor calendar and rounded to the next working day in first the vendor calendar and then the location calendar). If no vendor calendar exists, then: planned receipt date = order date + vendor lead time (per the location calendar). Backward calculation: order date = planned receipt date - vendor lead time (per the vendor calendar and rounded to the previous working day in first the vendor calendar and then the location calendar). If no vendor calendar exists, then: order date = planned receipt date - vendor lead time (per the location calendar).';
                }
                field("Expected Receipt Date"; Rec."Expected Receipt Date")
                {
                    ApplicationArea = Suite;
                    Editable = False;
                    ToolTip = 'Specifies the date you expect the items to be available in your warehouse. If you leave the field blank, it will be calculated as follows: Planned Receipt Date + Safety Lead Time + Inbound Warehouse Handling Time = Expected Receipt Date.';
                }
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = Suite;
                    Editable = False;
                    ToolTip = 'Specifies the date when the order was created.';
                    Visible = false;
                }


                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Suite;
                    Editable = false;

                    ToolTip = 'Specifies the document number.';
                    Visible = false;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = Suite;
                    Editable = false;

                    ToolTip = 'Specifies the number of this line.';
                    Visible = false;
                }
                field("Over-Receipt Quantity"; Rec."Over-Receipt Quantity")
                {
                    ApplicationArea = All;
                    Visible = OverReceiptAllowed;
                    ToolTip = 'Specifies over-receipt quantity.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }

                field("Gross Weight"; Rec."Gross Weight")
                {
                    Caption = 'Unit Gross Weight';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the gross weight of one unit of the item. In the purchase statistics window, the gross weight on the line is included in the total gross weight of all the lines for the particular purchase document.';
                    Visible = false;
                }
                field("Net Weight"; Rec."Net Weight")
                {
                    Caption = 'Unit Net Weight';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the net weight of one unit of the item. In the purchase statistics window, the net weight on the line is included in the total net weight of all the lines for the particular purchase document.';
                    Visible = false;
                }
                field("Unit Volume"; Rec."Unit Volume")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the volume of one unit of the item. In the purchase statistics window, the volume of one unit of the item on the line is included in the total volume of all the lines for the particular purchase document.';
                    Visible = false;
                }
                field("Units per Parcel"; Rec."Units per Parcel")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of units per parcel of the item. In the purchase statistics window, the number of units per parcel on the line helps to determine the total number of units for all the lines for the particular purchase document.';
                    Visible = false;
                }
                field("FA Posting Date"; Rec."FA Posting Date")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the FA posting date if you have selected Fixed Asset in the Type field for this line.';
                    Visible = false;
                }
            }
            group(Control43)
            {
                ShowCaption = false;
                group(Control37)
                {
                    ShowCaption = false;
                    field(AmountBeforeDiscount; TotalPurchaseLine."Line Amount")
                    {
                        ApplicationArea = Suite;
                        AutoFormatExpression = Currency.Code;
                        AutoFormatType = 1;
                        CaptionClass = DocumentTotals.GetTotalLineAmountWithVATAndCurrencyCaption(Currency.Code, TotalPurchaseHeader."Prices Including VAT");
                        Caption = 'Subtotal Excl. VAT';
                        Editable = false;
                        ToolTip = 'Specifies the sum of the value in the Line Amount Excl. VAT field on all lines in the document.';

                        trigger OnValidate()
                        begin
                            DocumentTotals.PurchaseDocTotalsNotUpToDate();
                        end;
                    }
                    field("Invoice Discount Amount"; InvoiceDiscountAmount)
                    {
                        ApplicationArea = Suite;
                        AutoFormatExpression = Currency.Code;
                        AutoFormatType = 1;
                        CaptionClass = DocumentTotals.GetInvoiceDiscAmountWithVATAndCurrencyCaption(FieldCaption("Inv. Discount Amount"), Currency.Code);
                        Caption = 'Invoice Discount Amount';
                        Editable = InvDiscAmountEditable;
                        ToolTip = 'Specifies a discount amount that is deducted from the value of the Total Incl. VAT field, based on purchase lines where the Allow Invoice Disc. field is selected. You can enter or change the amount manually.';

                        trigger OnValidate()
                        begin
                            ValidateInvoiceDiscountAmount();
                            DocumentTotals.PurchaseDocTotalsNotUpToDate();
                        end;
                    }
                    field("Invoice Disc. Pct."; InvoiceDiscountPct)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Invoice Discount %';
                        DecimalPlaces = 0 : 3;
                        Editable = InvDiscAmountEditable;
                        ToolTip = 'Specifies a discount percentage that is applied to the invoice, based on purchase lines where the Allow Invoice Disc. field is selected. The percentage and criteria are defined in the Vendor Invoice Discounts page, but you can enter or change the percentage manually.';

                        trigger OnValidate()
                        begin
                            AmountWithDiscountAllowed := DocumentTotals.CalcTotalPurchAmountOnlyDiscountAllowed(Rec);
                            InvoiceDiscountAmount := Round(AmountWithDiscountAllowed * InvoiceDiscountPct / 100, Currency."Amount Rounding Precision");
                            ValidateInvoiceDiscountAmount();
                            DocumentTotals.PurchaseDocTotalsNotUpToDate();
                        end;
                    }
                }
                group(Control19)
                {
                    ShowCaption = false;
                    field("Total Amount Excl. VAT"; TotalPurchaseLine.Amount)
                    {
                        ApplicationArea = Suite;
                        AutoFormatExpression = Currency.Code;
                        AutoFormatType = 1;
                        CaptionClass = DocumentTotals.GetTotalExclVATCaption(Currency.Code);
                        Caption = 'Total Amount Excl. VAT';
                        DrillDown = false;
                        Editable = false;
                        ToolTip = 'Specifies the sum of the value in the Line Amount Excl. VAT field on all lines in the document minus any discount amount in the Invoice Discount Amount field.';
                    }
                    field("Total VAT Amount"; VATAmount)
                    {
                        ApplicationArea = Suite;
                        AutoFormatExpression = Currency.Code;
                        AutoFormatType = 1;
                        CaptionClass = DocumentTotals.GetTotalVATCaption(Currency.Code);
                        Caption = 'Total VAT';
                        Editable = false;
                        ToolTip = 'Specifies the sum of VAT amounts on all lines in the document.';
                    }
                    field("Total Amount Incl. VAT"; TotalPurchaseLine."Amount Including VAT")
                    {
                        ApplicationArea = Suite;
                        AutoFormatExpression = Currency.Code;
                        AutoFormatType = 1;
                        CaptionClass = DocumentTotals.GetTotalInclVATCaption(Currency.Code);
                        Caption = 'Total Amount Incl. VAT';
                        Editable = false;
                        ToolTip = 'Specifies the sum of the value in the Line Amount Incl. VAT field on all lines in the document minus any discount amount in the Invoice Discount Amount field.';
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(SelectMultiItems)
            {
                AccessByPermission = TableData Item = R;
                ApplicationArea = Basic, Suite;
                Caption = 'Select items';
                Ellipsis = true;
                Image = NewItem;
                ToolTip = 'Add two or more items from the full list of your inventory items.';

                trigger OnAction()
                begin
                    SelectMultipleItems();
                end;
            }
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                group("Item Availability by")
                {
                    Caption = 'Item Availability by';
                    Image = ItemAvailability;
                    Enabled = Type = Type::Item;
                    action("Event")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Event';
                        Image = "Event";
                        ToolTip = 'View how the actual and the projected available balance of an item will develop over time according to supply and demand events.';

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromPurchLine(Rec, ItemAvailFormsMgt.ByEvent())
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
                            ItemAvailFormsMgt.ShowItemAvailFromPurchLine(Rec, ItemAvailFormsMgt.ByPeriod())
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
                            ItemAvailFormsMgt.ShowItemAvailFromPurchLine(Rec, ItemAvailFormsMgt.ByVariant())
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
                            ItemAvailFormsMgt.ShowItemAvailFromPurchLine(Rec, ItemAvailFormsMgt.ByLocation())
                        end;
                    }
                    action(Lot)
                    {
                        ApplicationArea = ItemTracking;
                        Caption = 'Lot';
                        Image = LotInfo;
                        RunObject = Page "Item Availability by Lot No.";
                        RunPageLink = "No." = field("No."),
                            "Location Filter" = field("Location Code"),
                            "Variant Filter" = field("Variant Code");
                        ToolTip = 'View the current and projected quantity of the item in each lot.';
                    }
                    action("BOM Level")
                    {
                        AccessByPermission = TableData "BOM Buffer" = R;
                        ApplicationArea = Assembly;
                        Caption = 'BOM Level';
                        Image = BOMLevel;
                        ToolTip = 'View availability figures for items on bills of materials that show how many units of a parent item you can make based on the availability of child items.';

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromPurchLine(Rec, ItemAvailFormsMgt.ByBOM())
                        end;
                    }
                }
                action("Reservation Entries")
                {
                    AccessByPermission = TableData Item = R;
                    ApplicationArea = Reservation;
                    Caption = 'Reservation Entries';
                    Image = ReservationLedger;
                    Enabled = Type = Type::Item;
                    ToolTip = 'View all reservation entries for the selected item. This action is available only for lines that contain an item.';

                    trigger OnAction()
                    begin
                        ShowReservationEntries(true);
                    end;
                }
                action("Item Tracking Lines")
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Item &Tracking Lines';
                    Image = ItemTrackingLines;
                    ShortCutKey = 'Ctrl+Alt+I';
                    Enabled = Type = Type::Item;
                    ToolTip = 'View or edit serial and lot numbers for the selected item. This action is available only for lines that contain an item.';

                    trigger OnAction()
                    begin
                        OpenItemTrackingLines();
                    end;
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
                action("Co&mments")
                {
                    ApplicationArea = Comments;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    ToolTip = 'View or add comments for the record.';

                    trigger OnAction()
                    begin
                        ShowLineComments();
                    end;
                }
                action(ItemChargeAssignment)
                {
                    AccessByPermission = TableData "Item Charge" = R;
                    ApplicationArea = ItemCharges;
                    Caption = 'Item Charge &Assignment';
                    Image = ItemCosts;
                    Enabled = Type = Type::"Charge (Item)";
                    ToolTip = 'Record additional direct costs, for example for freight. This action is available only for Charge (Item) line types.';

                    trigger OnAction()
                    begin
                        ShowItemChargeAssgnt();
                        SetItemChargeFieldsStyle();
                    end;
                }
                action(DocumentLineTracking)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Document &Line Tracking';
                    ToolTip = 'View related open, posted, or archived documents or document lines.';

                    trigger OnAction()
                    begin
                        ShowDocumentLineTracking();
                    end;
                }
                action(DeferralSchedule)
                {
                    ApplicationArea = Suite;
                    Caption = 'Deferral Schedule';
                    Enabled = "Deferral Code" <> '';
                    Image = PaymentPeriod;
                    ToolTip = 'View or edit the deferral schedule that governs how revenue made with this sales document is deferred to different accounting periods when the document is posted.';

                    trigger OnAction()
                    begin
                        ShowDeferralSchedule();
                    end;
                }
                action(DocAttach)
                {
                    ApplicationArea = All;
                    Caption = 'Attachments';
                    Image = Attach;
                    ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';

                    trigger OnAction()
                    var
                        DocumentAttachmentDetails: Page "Document Attachment Details";
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        DocumentAttachmentDetails.OpenForRecRef(RecRef);
                        DocumentAttachmentDetails.RunModal();
                    end;
                }
            }
            Group(CreateFixedAssetProcess)
            {
                action(CreateFixedAsset)
                {
                    ApplicationArea = All;
                    Caption = 'Create New Fixed Assets', comment = 'NLB="YourLanguageCaption"';
                    Image = FixedAssets;
                    trigger OnAction()
                    var
                        PurchHeader: Record "Purchase Header";
                        PurchLine: Record "Purchase Line";
                        qtyupdate: Decimal; //PT-FBTS 03-07-2024
                        i: Integer;
                        ArchiveManagement: Codeunit ArchiveManagement;
                        FixedAsset: Record "Fixed Asset";
                        PurcHeader1: record "Purchase Header";
                        PurcHeader2: record "Purchase Header";
                    begin
                        //AJ_Alle_02112023
                        PurcHeader1.SetRange("No.", Rec."Document No.");
                        if PurcHeader1.FindFirst() then begin
                            PurcHeader1.Status := PurcHeader1.Status::Open;
                            PurcHeader1.Modify();
                        end;
                        //AJ_Alle_02112023
                        PurchLine.Reset();
                        PurchLine.SetRange("Document Type", Rec."Document Type");
                        PurchLine.SetRange("Document No.", Rec."Document No.");
                        //  PurchLine.SetRange(Type, PurchLine.Type::"Fixed Asset"); //AJ_ALLE_02112023
                        PurchLine.SetRange(SelectforFixedAsset, true);
                        IF PurchLine.FindSet() then begin
                            if (PurchLine.Type = PurchLine.type::"Fixed Asset") or (PurchLine."No." = '9999999') then begin //AJ_ALLE_02112023
                                PurchHeader.get(Rec."Document Type", Rec."Document No.");
                                PurchHeader.CalcFields("No. of Archived Versions");
                                IF PurchHeader."No. of Archived Versions" = 0 then
                                    ArchiveManagement.ArchivePurchDocument(PurchHeader);
                                repeat
                                    i := 1;
                                    // while i <= PurchLine.Quantity do begin
                                    while i <= PurchLine."Qty. to Receive" do begin //PT=FBTS
                                        IF CreateFixedAssetCard(PurchLine, FixedAsset) then
                                            CreatePurchline(PurchLine, FixedAsset);
                                        i += 1;
                                    end;
                                    qtyupdate := PurchLine.Quantity - PurchLine."Qty. to Receive"; //PT-FBTS
                                    PurchLine.Validate(Quantity, qtyupdate);
                                    PurchLine.Validate("Qty. to Receive", 0);
                                    PurchLine.Modify();
                                    if PurchLine.Quantity = 0 then //PT-FBTS
                                        PurchLine.Delete();


                                until PurchLine.Next() = 0;
                            end; //AJ_ALLE_02112023
                        end;
                        //AJ_Alle_02112023
                        PurcHeader2.SetRange("No.", PurcHeader1."No.");
                        if PurcHeader2.FindFirst() then begin
                            PurcHeader2.Status := PurcHeader2.Status::Released;
                            PurcHeader2.Modify();
                        end;
                        //AJ_Alle_02112023
                    end;
                }
            }


            group(AutoLotAssignment)
            {
                action(AutoLotAssignShipment)
                {
                    ApplicationArea = All;
                    Caption = 'AutoLotAssignShipment';
                    Image = Purchase;

                    // ShortCutKey = 'Ctrl+Alt+I';
                    ToolTip = 'Auto Lot Assignement';

                    trigger OnAction()
                    var

                        TempPurchLine: Record "Purchase Line";
                        TempIetm: Record Item;
                        GRNcodeunit: Codeunit AllSCMCustomization;
                        ValidateReservationEntry: Record "Reservation Entry";
                    begin

                        //validation to check 
                        ValidateReservationEntry.Reset;
                        ValidateReservationEntry.SetRange(AutoLotDocumentNo, Rec."Document No.");
                        if ValidateReservationEntry.FindFirst() then
                            Error('Lot is already assigned for this document , if you want to reassign lotno please delete a existing line first');
                        //
                        TempPurchLine.Reset();
                        TempPurchLine.SetRange("Document No.", Rec."Document No.");
                        TempPurchLine.SetRange(TempPurchLine.Type, TempPurchLine.Type::Item);
                        TempPurchLine.SetFilter("Qty. to Receive", '<>%1', 0);//PT-FBTS-23
                        if TempPurchLine.FindSet() then
                            repeat
                                ValidateReservationEntry.Reset();
                                ValidateReservationEntry.SetRange("Source ID", TempPurchLine."Document No.");
                                ValidateReservationEntry.SetRange("Source Ref. No.", TempPurchLine."Line No.");
                                IF not ValidateReservationEntry.FindFirst() then begin

                                    IF TempIetm.Get(TempPurchLine."No.") then;
                                    if TempIetm."Item Tracking Code" <> '' then Begin
                                        TempPurchLine.TestField(TempPurchLine."Location Code");
                                        TempPurchLine.TestField(TempPurchLine."Qty. to Invoice (Base)");
                                        TempPurchLine.TestField(TempPurchLine."Qty. to Receive (Base)");

                                        GRNcodeunit.GRNReservationEntry(TempPurchLine);
                                    end;
                                end;
                            Until TempPurchLine.next() = 0;


                        Message('Auto Lot no assigned sussessfully');


                    end;
                }


            }



            group(Errors)
            {
                Caption = 'Issues';
                Image = ErrorLog;
                Visible = BackgroundErrorCheck;
                action(ShowLinesWithErrors)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Show Lines with Issues';
                    Image = Error;
                    Visible = BackgroundErrorCheck;
                    Enabled = not ShowAllLinesEnabled;
                    ToolTip = 'View a list of purchase lines that have issues before you post the document.';

                    trigger OnAction()
                    begin
                        SwitchLinesWithErrorsFilter(ShowAllLinesEnabled);
                    end;
                }
                action(ShowAllLines)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Show All Lines';
                    Image = ExpandAll;
                    Visible = BackgroundErrorCheck;
                    Enabled = ShowAllLinesEnabled;
                    ToolTip = 'View all purchase lines, including lines with and without issues.';

                    trigger OnAction()
                    begin
                        SwitchLinesWithErrorsFilter(ShowAllLinesEnabled);
                    end;
                }
            }
            group("Page")
            {
                Caption = 'Page';


            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        TempLocation: Record Location;
    begin
        GetTotalsPurchaseHeader();
        CalculateTotals();
        UpdateEditableOnRow();
        UpdateTypeText();
        SetItemChargeFieldsStyle();

        if Rec."Location Code" <> '' Then begin
            IF TempLocation.Get(Rec."Location Code") then;
            LocationName := TempLocation.Name;
        end;
    end;

    trigger OnAfterGetRecord()
    var
        Item: Record "Item";
        TempLocation: Record Location;
    begin
        ShowShortcutDimCode(ShortcutDimCode);
        UpdateTypeText();
        SetItemChargeFieldsStyle();
        //Mahnedr

        if Rec."Location Code" <> '' Then begin
            IF TempLocation.Get(Rec."Location Code") then;
            LocationName := TempLocation.Name;
        end;
        //Mahendra 
        /*
        if "Variant Code" = '' then
            VariantCodeMandatory := Item.IsVariantMandatory(Type = Type::Item, "No.");  */
    end;

    trigger OnDeleteRecord(): Boolean
    var
        PurchLineReserve: Codeunit "Purch. Line-Reserve";
    begin
        if (Quantity <> 0) and ItemExists("No.") then begin
            Commit();
            if not PurchLineReserve.DeleteLineConfirm(Rec) then
                exit(false);
            PurchLineReserve.DeleteLine(Rec);
        end;
        DocumentTotals.PurchaseDocTotalsNotUpToDate();
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        DocumentTotals.PurchaseCheckAndClearTotals(Rec, xRec, TotalPurchaseLine, VATAmount, InvoiceDiscountAmount, InvoiceDiscountPct);
        exit(Find(Which));
    end;

    trigger OnInit()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        PurchasesPayablesSetup.Get();
        InventorySetup.Get();
        TempOptionLookupBuffer.FillLookupBuffer(TempOptionLookupBuffer."Lookup Type"::Purchases);
        IsFoundation := ApplicationAreaMgmtFacade.IsFoundationEnabled();
        Currency.InitRoundingPrecision();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        DocumentTotals.PurchaseCheckIfDocumentChanged(Rec, xRec);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        InitType();
        SetDefaultType();

        Clear(ShortcutDimCode);
        UpdateTypeText();
    end;

    trigger OnOpenPage()
    begin
        SetOpenPage();

        SetDimensionsVisibility();
        SetOverReceiptControlsVisibility();
        SetItemReferenceVisibility();
    end;

    local procedure CreateFixedAssetCard(PurchLine: Record "Purchase Line"; var FixedAsset: Record "Fixed Asset"): Boolean
    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
        FASetup: Record "FA Setup";
        FAPurchLine: Record "Fixed Asset";
        CopyFA: Report "Copy Fixed Asset";
        DefaultDim: Record "Default Dimension";
        DefaultDim2: Record "Default Dimension";
        FADeprBook: Record "FA Depreciation Book";
        FADeprBook2: Record "FA Depreciation Book";
    begin
        FAPurchLine.Get(PurchLine."No.");
        //CopyFA.SetFANo(PurchLine."No.");
        //CopyFA.InitializeRequest(PurchLine."No.",PurchLine.Quantity,);
        //CopyFA.RunModal();
        DefaultDim.LockTable();
        FADeprBook.LockTable();
        FixedAsset.LockTable();
        FASetup.GET();
        FixedAsset.Init();
        FixedAsset.TransferFields(FAPurchLine);
        FixedAsset.Validate("No.", NoSeriesMgt.GetNextNo(FASetup."Fixed Asset Nos.", WorkDate(), true));
        FixedAsset."PO Item" := false;
        FixedAsset."Parent Fixed Asset" := FAPurchLine."No.";
        FixedAsset."Location Code" := PurchLine."Location Code";//Alle_Nick_010124
        FixedAsset."FA Location Code" := PurchLine."Location Code";//Alle_Nick_010124
        FADeprBook."FA No." := PurchLine."No.";
        FADeprBook.SetRange("FA No.", PurchLine."No.");
        DefaultDim."Table ID" := DATABASE::"Fixed Asset";
        DefaultDim."No." := PurchLine."No.";
        DefaultDim.SetRange("Table ID", DATABASE::"Fixed Asset");
        DefaultDim.SetRange("No.", PurchLine."No.");
        DefaultDim2 := DefaultDim;
        FixedAsset.Insert();

        if DefaultDim.Find('-') then
            repeat
                DefaultDim2 := DefaultDim;
                DefaultDim2."No." := FixedAsset."No.";
                DefaultDim2.Insert(true);
            until DefaultDim.Next() = 0;
        if FADeprBook.Find('-') then
            repeat
                FADeprBook2 := FADeprBook;
                FADeprBook2."FA No." := FixedAsset."No.";
                FADeprBook2."Depreciation Book Code" := 'Company';//ALLE_NICK_170124
                FADeprBook2."FA Posting Group" := FixedAsset."FA Subclass Code";//ALLE_NICK_170124
                FADeprBook2.Insert(true);
            until FADeprBook.Next() = 0;

        IF FixedAsset.Modify() then
            exit(true)
        else
            exit(false);
    end;

    local procedure CreatePurchline(var PurchLine: Record "Purchase Line"; F_Assest: Record "Fixed Asset")
    var
        PurchaseLine: Record "Purchase Line";
        RecPurchLine: Record "Purchase Line";
        LineNum: Integer;
    begin
        PurchaseLine.Reset();
        PurchaseLine.SetRange("Document Type", PurchLine."Document Type");
        PurchaseLine.SetRange("Document No.", PurchLine."Document No.");
        If PurchaseLine.FindLast() then
            LineNum := PurchaseLine."Line No." + 10000
        else
            LineNum := 10000;

        RecPurchLine.Init();
        RecPurchLine.TransferFields(PurchLine);
        RecPurchLine.Validate("No.", F_Assest."No.");
        RecPurchLine.Validate("Line No.", LineNum);
        RecPurchLine.Validate("Location Code", PurchLine."Location Code");
        RecPurchLine.Validate(Quantity, 1);
        RecPurchLine.Validate("Direct Unit Cost", PurchLine."Direct Unit Cost");
        RecPurchLine.SelectforFixedAsset := false;
        RecPurchLine.Insert();
    end;



    var
        PurchaseHeader: Record "Purchase Header";

        LocationName: Text[50];
        Currency: Record Currency;
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        InventorySetup: Record "Inventory Setup";
        TempOptionLookupBuffer: Record "Option Lookup Buffer" temporary;
        TransferExtendedText: Codeunit "Transfer Extended Text";
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        Text001: Label 'You cannot use the Explode BOM function because a prepayment of the purchase order has been invoiced.';
        PurchCalcDiscByType: Codeunit "Purch - Calc Disc. By Type";
        DocumentTotals: Codeunit "Document Totals";
        AmountWithDiscountAllowed: Decimal;
        TypeAsText: Text[30];
        ItemChargeStyleExpression: Text;
        ItemChargeToHandleStyleExpression: Text;
        VariantCodeMandatory: Boolean;
        InvDiscAmountEditable: Boolean;
        BackgroundErrorCheck: Boolean;
        ShowAllLinesEnabled: Boolean;
        IsFoundation: Boolean;
        IsSaaSExcelAddinEnabled: Boolean;
        UpdateInvDiscountQst: Label 'One or more lines have been invoiced. The discount distributed to invoiced lines will not be taken into account.\\Do you want to update the invoice discount?';
        CurrPageIsEditable: Boolean;
        SuppressTotals: Boolean;
        ExcelFileNameTxt: Label 'Purchase Order %1 - Lines', Comment = '%1 = document number, ex. 10000';

    protected var
        TotalPurchaseHeader: Record "Purchase Header";
        TotalPurchaseLine: Record "Purchase Line";
        ShortcutDimCode: array[8] of Code[20];
        InvoiceDiscountAmount: Decimal;
        InvoiceDiscountPct: Decimal;
        VATAmount: Decimal;
        DimVisible1: Boolean;
        DimVisible2: Boolean;
        DimVisible3: Boolean;
        DimVisible4: Boolean;
        DimVisible5: Boolean;
        DimVisible6: Boolean;
        DimVisible7: Boolean;
        DimVisible8: Boolean;
        IsBlankNumber: Boolean;
        [InDataSet]
        IsCommentLine: Boolean;
        OverReceiptAllowed: Boolean;
        [InDataSet]
        ItemReferenceVisible: Boolean;

    local procedure SetOpenPage()
    var
        ServerSetting: Codeunit "Server Setting";
        DocumentErrorsMgt: Codeunit "Document Errors Mgt.";
    begin
        OnBeforeSetOpenPage();

        IsSaaSExcelAddinEnabled := ServerSetting.GetIsSaasExcelAddinEnabled();
        SuppressTotals := CurrentClientType() = ClientType::ODataV4;
        BackgroundErrorCheck := DocumentErrorsMgt.BackgroundValidationEnabled();
    end;

    procedure ApproveCalcInvDisc()
    begin
        CODEUNIT.Run(CODEUNIT::"Purch.-Disc. (Yes/No)", Rec);
        DocumentTotals.PurchaseDocTotalsNotUpToDate();
    end;

    local procedure ValidateInvoiceDiscountAmount()
    var
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if SuppressTotals then
            exit;

        PurchaseHeader.Get("Document Type", "Document No.");
        if PurchaseHeader.InvoicedLineExists() then
            if not ConfirmManagement.GetResponseOrDefault(UpdateInvDiscountQst, true) then
                exit;

        DocumentTotals.PurchaseDocTotalsNotUpToDate();
        PurchCalcDiscByType.ApplyInvDiscBasedOnAmt(InvoiceDiscountAmount, PurchaseHeader);
        CurrPage.Update(false);
    end;

    local procedure ExplodeBOM()
    begin
        if "Prepmt. Amt. Inv." <> 0 then
            Error(Text001);
        CODEUNIT.Run(CODEUNIT::"Purch.-Explode BOM", Rec);
        DocumentTotals.PurchaseDocTotalsNotUpToDate();
    end;

    local procedure OpenSalesOrderForm()
    var
        SalesHeader: Record "Sales Header";
        SalesOrder: Page "Sales Order";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeOpenSalesOrderForm(Rec, SalesHeader, SalesOrder, IsHandled);
        if IsHandled then
            exit;

        TestField("Sales Order No.");
        SalesHeader.SetRange("No.", "Sales Order No.");
        SalesOrder.SetTableView(SalesHeader);
        SalesOrder.Editable := false;
        SalesOrder.Run();
    end;

    procedure InsertExtendedText(Unconditionally: Boolean)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInsertExtendedText(Rec, IsHandled);
        if IsHandled then
            exit;

        if TransferExtendedText.PurchCheckIfAnyExtText(Rec, Unconditionally) then begin
            CurrPage.SaveRecord();
            TransferExtendedText.InsertPurchExtText(Rec);
        end;
        if TransferExtendedText.MakeUpdate() then
            UpdateForm(true);
    end;

    procedure ShowTracking()
    var
        TrackingForm: Page "Order Tracking";
    begin
        TrackingForm.SetPurchLine(Rec);
        TrackingForm.RunModal();
    end;

    protected procedure OpenSpecOrderSalesOrderForm()
    var
        SalesHeader: Record "Sales Header";
        SalesOrder: Page "Sales Order";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeOpenSpecOrderSalesOrderForm(Rec, SalesHeader, SalesOrder, IsHandled);
        if IsHandled then
            exit;

        TestField("Special Order Sales No.");
        SalesHeader.SetRange("No.", "Special Order Sales No.");
        SalesOrder.SetTableView(SalesHeader);
        SalesOrder.Editable := false;
        SalesOrder.Run();
    end;

    procedure UpdateForm(SetSaveRecord: Boolean)
    begin
        CurrPage.Update(SetSaveRecord);
    end;

    procedure NoOnAfterValidate()
    begin
        UpdateEditableOnRow();
        InsertExtendedText(false);
        if (Type = Type::"Charge (Item)") and ("No." <> xRec."No.") and
           (xRec."No." <> '')
        then
            CurrPage.SaveRecord();

        OnAfterNoOnAfterValidate(Rec, xRec);
    end;

    procedure ShowDocumentLineTracking()
    var
        DocumentLineTracking: Page "Document Line Tracking";
    begin
        Clear(DocumentLineTracking);
        DocumentLineTracking.SetDoc(1, "Document No.", "Line No.", "Blanket Order No.", "Blanket Order Line No.", '', 0);
        DocumentLineTracking.RunModal();
    end;

    procedure RedistributeTotalsOnAfterValidate()
    begin
        if SuppressTotals then
            exit;

        CurrPage.SaveRecord();

        DocumentTotals.PurchaseRedistributeInvoiceDiscountAmounts(Rec, VATAmount, TotalPurchaseLine);
        CurrPage.Update(false);
    end;

    local procedure GetTotalsPurchaseHeader()
    begin
        DocumentTotals.GetTotalPurchaseHeaderAndCurrency(Rec, TotalPurchaseHeader, Currency);
    end;

    procedure ClearTotalPurchaseHeader();
    begin
        Clear(TotalPurchaseHeader);
    end;

    procedure CalculateTotals()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCalculateTotals(Rec, SuppressTotals, DocumentTotals, IsHandled);
        if IsHandled then
            exit;

        if SuppressTotals then
            exit;

        DocumentTotals.PurchaseCheckIfDocumentChanged(Rec, xRec);
        DocumentTotals.CalculatePurchaseSubPageTotals(
          TotalPurchaseHeader, TotalPurchaseLine, VATAmount, InvoiceDiscountAmount, InvoiceDiscountPct);
        DocumentTotals.RefreshPurchaseLine(Rec);
    end;

    procedure DeltaUpdateTotals()
    begin
        if SuppressTotals then
            exit;

        OnBeforeDeltaUpdateTotals(Rec, xRec);
        DocumentTotals.PurchaseDeltaUpdateTotals(Rec, xRec, TotalPurchaseLine, VATAmount, InvoiceDiscountAmount, InvoiceDiscountPct);
        CheckSendLineInvoiceDiscountResetNotification();
    end;

    procedure ForceTotalsCalculation()
    begin
        DocumentTotals.PurchaseDocTotalsNotUpToDate();
    end;

    local procedure CheckSendLineInvoiceDiscountResetNotification()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckSendLineInvoiceDiscountResetNotification(Rec, IsHandled);
        if IsHandled then
            exit;

        if "Line Amount" <> xRec."Line Amount" then
            SendLineInvoiceDiscountResetNotification();
    end;

    procedure UpdateEditableOnRow()
    begin
        IsCommentLine := Type = Type::" ";
        IsBlankNumber := IsCommentLine;

        CurrPageIsEditable := CurrPage.Editable;
        InvDiscAmountEditable :=
            CurrPageIsEditable and not PurchasesPayablesSetup."Calc. Inv. Discount" and
            (TotalPurchaseHeader.Status = TotalPurchaseHeader.Status::Open);

        OnAfterUpdateEditableOnRow(Rec, IsCommentLine, IsBlankNumber);
    end;

    procedure UpdateTypeText()
    var
        RecRef: RecordRef;
    begin
        if not IsFoundation then
            exit;

        OnBeforeUpdateTypeText(Rec);

        RecRef.GetTable(Rec);
        TypeAsText := TempOptionLookupBuffer.FormatOption(RecRef.Field(FieldNo(Type)));
    end;

    local procedure SetItemChargeFieldsStyle()
    begin
        ItemChargeStyleExpression := '';
        ItemChargeToHandleStyleExpression := '';
        if AssignedItemCharge() then begin
            if "Qty. To Assign" <> (Quantity - "Qty. Assigned") then
                ItemChargeStyleExpression := 'Unfavorable';
            if "Item Charge Qty. to Handle" <> "Qty. to Invoice" then
                ItemChargeToHandleStyleExpression := 'Unfavorable';
        end;
    end;

    local procedure SetItemReferenceVisibility()
    var
        ItemReference: Record "Item Reference";
    begin
        ItemReferenceVisible := not ItemReference.IsEmpty();
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

        OnAfterSetDimensionsVisibility();
    end;

    local procedure SetDefaultType()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeSetDefaultType(Rec, xRec, IsHandled);
        if IsHandled then
            exit;

        if xRec."Document No." = '' then
            Type := GetDefaultLineType();
    end;



    local procedure SetOverReceiptControlsVisibility()
    var
        OverReceiptMgt: Codeunit "Over-Receipt Mgt.";
    begin
        OverReceiptAllowed := OverReceiptMgt.IsOverReceiptAllowed();
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnAfterNoOnAfterValidate(var PurchaseLine: Record "Purchase Line"; var xPurchaseLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateEditableOnRow(PurchaseLine: Record "Purchase Line"; var IsCommentLine: Boolean; var IsBlankNumber: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateShortcutDimCode(var PurchaseLine: Record "Purchase Line"; var ShortcutDimCode: array[8] of Code[20]; DimIndex: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalculateTotals(var PurchLine: Record "Purchase Line"; SuppressTotals: Boolean; var DocumentTotals: Codeunit "Document Totals"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckSendLineInvoiceDiscountResetNotification(var PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertExtendedText(var PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOpenSpecOrderSalesOrderForm(var PurchaseLine: Record "Purchase Line"; var SalesHeader: Record "Sales Header"; var SalesOrder: Page "Sales Order";

    var
        IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetDefaultType(var PurchaseLine: Record "Purchase Line"; var xPurchaseLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateTypeText(var PurchaseLine: Record "Purchase Line")
    begin
    end;

#if not CLEAN20
    [Obsolete('Replaced by event OnItemReferenceNoOnLookup()', '20.0')]
    [IntegrationEvent(false, false)]
    local procedure OnCrossReferenceNoOnLookup(var PurchaseLine: Record "Purchase Line")
    begin
    end;
#endif

    [IntegrationEvent(false, false)]
    local procedure OnItemReferenceNoOnLookup(var PurchaseLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOpenSalesOrderForm(var PurchaseLine: Record "Purchase Line"; var SalesHeader: Record "Sales Header"; var SalesOrder: Page "Sales Order";

    var
        IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSetOpenPage()
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterSetDimensionsVisibility()
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeDeltaUpdateTotals(var PurchaseLine: Record "Purchase Line"; xPurchaseLine: Record "Purchase Line")
    begin
    end;
}


