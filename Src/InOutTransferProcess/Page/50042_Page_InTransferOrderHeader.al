page 50042 "In Transfer Order"
{
    Caption = 'In Transfer Order';
    PageType = Document;
    RefreshOnActivate = true;
    Editable = true;
    SourceTable = "Transfer Header";
    InsertAllowed = false;
    DeleteAllowed = false;

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
                field(TransferFromname; Rec."Transfer-from Name")
                {

                }
                field("Transfer-to Code"; Rec."Transfer-to Code")
                {
                    ApplicationArea = Location;
                    //Editable = (Status = Status::Open) AND EnableTransferFields;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the code of the location that the items are transferred to.';

                    trigger OnValidate()
                    begin
                        IsTransferLinesEditable := Rec.TransferLinesEditable();
                        CurrPage.Update();
                    end;
                }
                field(TransfertoName; Rec."Transfer-to Name")
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
                //Mahendra 16 Aug start
                field("Last Shipment No."; Rec."Last Shipment No.")
                {
                    ApplicationArea = All;
                    Caption = 'Shipment No.';
                    Editable = False;
                }
                field(ShipmentDate; Rec."Shipment Date")
                {
                    Caption = 'Shipment Date';
                    Editable = False;
                }
                //end
            }
            part(TransferLines; "In Transfer Order Subform")
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
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = Location;
                    Editable = (Status = Status::Open) AND EnableTransferFields;
                    ToolTip = 'Specifies the code for the shipping agent who is transporting the items.';

                    trigger OnValidate()
                    begin
                        ShippingAgentCodeOnAfterValida();
                    end;
                }
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
            action("Qty. to Receive") //PT-FBTS 19-11-25
            {
                ApplicationArea = Dimensions;
                Caption = 'Update Qty. to Receive';
                Image = UpdateDescription;

                trigger OnAction()
                var
                    TransferLine: Record "Transfer Line";
                begin
                    // if not Confirm('Do you want to update Qty. to Receive from Qty. in Transit?', false) then
                    //     exit;

                    TransferLine.SetRange("Document No.", Rec."No.");
                    TransferLine.SetRange("Derived From Line No.", 0);
                    if TransferLine.FindSet() then
                        repeat
                            TransferLine.Validate("Qty. to Receive", TransferLine."Qty. in Transit");
                            TransferLine.Modify(true);
                        until TransferLine.Next() = 0;

                    Message('Qty. to Receive updated successfully.');
                end;
            }
            group(Release)
            {

            }
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";


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
                        TempTransferLine1: Record "Transfer Line";
                        Invetsetup: Record "Inventory Setup";
                        TempItemJnlLine1: Record "Item Journal Line";
                        TempItemJnlLine: Record "Item Journal Line";
                        ItemJournalName: Code[10];
                        ItemJournalBatchName: Code[10];
                        DocNo: Code[20];
                        TempJournalBatchName: Record "Item Journal Batch";
                        TempItem: Record Item;
                        IsFixedAssetTransfer: Boolean;
                        TransferLocation: Code[20];
                        FixedAssetNo: Code[20];
                        TempFixedAsset: Record "Fixed Asset";
                        TempILE: Record "Item Ledger Entry";
                        CodeunittransferInOut: Codeunit TransferInOut;
                        //Dimension
                        DefaultDim: Record "Default Dimension";
                        GLSetup: Record "General Ledger Setup";
                        //AJ_Alle_09072023
                        TransferLineRec: Record "Transfer Line";
                        TransferLineRec1: Record "Transfer Line";
                        TransferLineRec2: Record "Transfer Line";
                        TransferLineRec3: Record "Transfer Line";
                        AvialableAvail: Boolean;
                        AvialableNonAvail: Boolean;
                        TransferLineHeaderRec: Record "Transfer Header";
                        RecReservationEntry2: Record "Reservation Entry";
                        SourceId: Code[20];
                        RecReservationEntry: Record "Reservation Entry";
                        ItemJournalLineLRec: Record "Item Journal Line";
                        //ALLE_Nick_250224
                        transferline2: Record "Transfer Line";
                        transferline3: Record "Transfer Line";
                        SourceProdOrderLine: Integer;
                        SourceRefNo: Integer;
                        AllSCMCustomization: Codeunit AllSCMCustomization;
                    //AJ_Alle_09072023
                    begin
                        //validation to check if location code is coorect
                        /*  if TempUserSetup.Get(UserId) then;

                          if ((Rec."Transfer-to Code" <> TempUserSetup."Location Code") and
                           (Rec."Transfer-from Code" <> TempUserSetup."Location Code")) then
                              Error('Location Mentioned on User setup and transfer To / Form location must be same , For Posting In transfer');

                         */
                        //ALLE_NICK_170124_DLT RESERVATION 
                        //Remove as no need 250224
                        // RecReservationEntry.SetRange("Location Code", rec."Transfer-from Code");
                        // RecReservationEntry.SetFilter("Source ID", '<>%1', Rec."No.");
                        // RecReservationEntry.SetFilter("Source Type", '%1', 5741);
                        // RecReservationEntry.SetFilter("Source Prod. Order Line", '%1', 0);
                        // RecReservationEntry.SetFilter(Positive, '%1', false);
                        // if RecReservationEntry.FindSet() then
                        //     repeat
                        //         RecReservationEntry2.SetRange("Source ID", RecReservationEntry."Source ID");
                        //         if RecReservationEntry2.FindSet() then
                        //             RecReservationEntry2.DeleteAll();
                        //     until RecReservationEntry.Next() = 0;
                        RecReservationEntry.SetRange("Source ID", rec."No.");
                        RecReservationEntry.SetFilter("Source Type", '%1', 5741);
                        if not RecReservationEntry.FindSet() then begin
                            TransferLine2.SETRANGE("Document No.", rec."No.");
                            IF TransferLine2.FINDSET THEN BEGIN
                                repeat
                                    Clear(SourceProdOrderLine);
                                    Clear(SourceRefNo);
                                    transferline3.SetRange("Document No.", TransferLine2."Document No.");
                                    transferline3.SetRange("Transfer-from Code", 'INTRANSIT1');
                                    transferline3.SetRange("Item No.", TransferLine2."Item No.");
                                    if transferline3.FindFirst() then begin
                                        SourceProdOrderLine := transferline3."Line No.";
                                        SourceRefNo := transferline3."Derived From Line No.";
                                    end;
                                    AllSCMCustomization."Assign Lot NO"(transferline2, SourceProdOrderLine, SourceRefNo);
                                until transferline2.next = 0;
                            end;
                        end;
                        TempUserSetup.Get(UserId);
                        if Rec."Transfer-to Code" <> TempUserSetup."Location Code" then
                            Error('Location Mentioned on User setup and transfer to location must be same , For Posting Instore transfer');
                        TempTransferLine1.Reset();
                        TempTransferLine1.SetRange("Document No.", Rec."No.");
                        TempTransferLine1.SetFilter(FixedAssetNo, '<>%1', '');
                        TempTransferLine1.SetFilter("Derived From Line No.", '=%1', 0);//PT-FBTS
                        TempTransferLine1.SetFilter("Qty. to Receive", '%1', 0); //Aashish
                        IF TempTransferLine1.FindSet() then
                            repeat
                                Clear(TempFixedAsset);
                                IF TempFixedAsset.Get(TempTransferLine1.FixedAssetNo) then begin
                                    TempFixedAsset."Used To" := false; //PT-FBTS
                                    TempFixedAsset.Modify();
                                end;
                            Until TempTransferLine1.Next() = 0;


                        TempTransferLine1.Reset();
                        TempTransferLine1.SetRange("Document No.", Rec."No.");
                        TempTransferLine1.SetFilter(FixedAssetNo, '<>%1', '');
                        TempTransferLine1.SetFilter("Derived From Line No.", '=%1', 0);//PT-FBTS
                        TempTransferLine1.SetFilter("Qty. to Receive", '<>%1', 0); //Aashish
                        IF TempTransferLine1.FindSet() then
                            repeat

                                IF TempItem.Get(TempTransferLine1."Item No.") then;
                                IF TempItem.IsFixedAssetItem then Begin
                                    IsFixedAssetTransfer := True;
                                    FixedAssetNo := TempTransferLine1.FixedAssetNo;
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

                                    TempItemJnlLine."Entry Type" := TempItemJnlLine."Entry Type"::"Negative Adjmt.";
                                    TempItemJnlLine.Validate(TempItemJnlLine."Entry Type");

                                    TempItemJnlLine."Item No." := TempTransferLine1."Item No.";

                                    TempItemJnlLine.Validate(TempItemJnlLine."Item No.");

                                    IF TempItem.Get(TempItemJnlLine."Item No.") then;
                                    TempItemJnlLine."Gen. Prod. Posting Group" := TempItem."Gen. Prod. Posting Group";
                                    TempItemJnlLine.Validate(TempItemJnlLine."Gen. Prod. Posting Group");

                                    TempItemJnlLine."Document Date" := Rec."Posting date";
                                    TempItemJnlLine.Validate(TempItemJnlLine."Document Date");

                                    TempItemJnlLine."Location Code" := Rec."Transfer-to Code";
                                    TransferLocation := Rec."Transfer-to Code";

                                    TempItemJnlLine.Validate(TempItemJnlLine."Location Code");
                                    TempTransferLine1.CalcSums("Qty. to Receive");//PT-FBTS
                                    TempItemJnlLine.Quantity := TempTransferLine1."Qty. to Receive";
                                    //TempItemJnlLine.Quantity := TempTransferLine1.Quantity; OldCode

                                    TempItemJnlLine.Validate(TempItemJnlLine.Quantity);
                                    //TempItemJnlLine."Unit Cost" := TempTransferLine1.UnitPrice;
                                    //TempItemJnlLine.Amount := TempTransferLine1.Amount; //OLD code
                                    TempItemJnlLine.Validate("Unit Amount", 0.01); //PT-FBTS NewCode
                                    TempItemJnlLine.Validate(TempItemJnlLine."Unit Amount");

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
                                    //  CODEUNIT.Run(CODEUNIT::"Item Jnl.-Post", TempItemJnlLine);
                                End;
                                //AJ_ALLE_30012024
                                IF TempFixedAsset.Get(TempTransferLine1.FixedAssetNo) then begin
                                    if TempTransferLine1."Qty. to Receive" <> 0 then begin //PT-FBTS
                                        TempFixedAsset."Location Code" := TempTransferLine1."Transfer-to Code";
                                        TempFixedAsset."FA Location Code" := TempTransferLine1."Transfer-to Code";
                                        TempFixedAsset."Used To" := false; //PT-FBTS 19-06-2024
                                                                           //TempFixedAsset.Validate(TempFixedAsset."Location Code");
                                        TempFixedAsset.Modify();
                                    end;
                                end;
                            //AJ_ALLE_30012024
                            Until TempTransferLine1.Next() = 0;
                        //  CODEUNIT.Run(CODEUNIT::"TransferOrder-Post (Yes/No)", Rec);
                        //AJ_Alle_09072023
                        //Commneted As Modified Below
                        // CodeunittransferInOut.TransferInoutPost(Rec, false, True);
                        //AJ_Alle_09072023

                        //AJ_Alle_09072023
                        // IF Confirm('Please make sure that you have calculate GST on transfer order , Do you want to continue') Then begin
                        AvialableAvail := false;
                        AvialableNonAvail := false;
                        TransferLineRec2.Reset();
                        TransferLineRec2.SetRange("Document No.", Rec."No.");
                        TransferLineRec2.SetFilter("Qty. to Receive", '<>%1', 0);//Ashish FBTS
                        TransferLineRec2.SetFilter("GST Credit", '%1', TransferLineRec."GST Credit"::Availment);
                        if TransferLineRec2.FindFirst() then begin
                            AvialableAvail := true;
                        end;
                        TransferLineRec3.Reset();
                        TransferLineRec3.SetRange("Document No.", Rec."No.");
                        TransferLineRec3.SetFilter("Qty. to Receive", '<>%1', 0);//Ashish FBTS
                        TransferLineRec3.SetFilter("GST Credit", '%1', TransferLineRec."GST Credit"::"Non-Availment");
                        if TransferLineRec3.FindFirst() then begin
                            AvialableNonAvail := true;
                        end;
                        if (AvialableAvail = true) and (AvialableNonAvail = true) then begin
                            TransferLineRec.SetRange("Document No.", Rec."No.");
                            TransferLineRec.SetFilter("GST Credit", '%1', TransferLineRec."GST Credit"::"Non-Availment");
                            if TransferLineRec.FindSet() then begin
                                repeat
                                    TransferLineRec."Qty. to Receive" := 0;
                                    TransferLineRec.Modify();
                                until TransferLineRec.Next() = 0;
                                CodeunittransferInOut.TransferInoutPost(Rec, false, True);
                            end;

                            TransferLineRec1.SetRange("Document No.", Rec."No.");
                            TransferLineRec1.SetFilter("GST Credit", '%1', TransferLineRec1."GST Credit"::"Non-Availment");
                            if TransferLineRec1.FindSet() then begin
                                repeat
                                    TransferLineRec1."Qty. to Receive" := TransferLineRec1."Quantity Shipped";
                                    TransferLineRec1.Modify();
                                until TransferLineRec1.Next() = 0;
                                CodeunittransferInOut.TransferInoutPost(Rec, false, True);
                            end;
                        end else begin
                            CodeunittransferInOut.TransferInoutPost(Rec, false, True);
                        end;
                        // CODEUNIT.Run(CODEUNIT::"TransferOrder-Post (Yes/No)", Rec);
                        //end;
                        //AJ_Alle_09072023

                        IF IsFixedAssetTransfer Then begin
                            TempILE.Reset();
                            TempILE.SetRange("Document No.", Rec."No.");
                            TempILE.SetFilter("Document Type", '=%1', TempILE."Entry Type"::"Negative Adjmt.");
                            IF Not TempILE.FindFirst() Then Begin
                                ItemJournalLineLRec.Reset();
                                ItemJournalLineLRec.SetCurrentKey("Document No.");
                                ItemJournalLineLRec.SetRange("Document No.", Rec."No.");
                                if ItemJournalLineLRec.FindSet() then
                                    CODEUNIT.Run(CODEUNIT::"Item Jnl.-Post", TempItemJnlLine);
                                // IF TempFixedAsset.Get(FixedAssetNo) then begin
                                //     TempFixedAsset."Location Code" := TransferLocation;
                                //     TempFixedAsset.Validate(TempFixedAsset."Location Code");
                                //     TempFixedAsset.Modify();
                                // end;
                            End;

                        end;

                        //For 
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


    //ALLE_NICK_261223
    trigger OnOpenPage()
    var
        TrackingSpecification: Record "Tracking Specification";
        ItemLedgEntry: Record "Item Ledger Entry";
        reserent: Record "Reservation Entry";
    begin
        //Alle+ AS_06092023
        SetDocNoVisible();
        EnableTransferFields := not IsPartiallyShipped();
        ActivateFields();
        //     reserent.Reset();
        //     //TrackingSpecification.SETCURRENTKEY("Source ID");
        //     //TrackingSpecification.SETRANGE("Source ID");
        //     reserent.SETRANGE("Source ID", Rec."No.");
        //     //TrackingSpecification.SetFilter("Source ID", Rec."No.");
        //     IF reserent.FindSet() then
        //         repeat
        //             ItemLedgEntry.Reset();
        //             ItemLedgEntry.SetRange("Lot No.", reserent."Lot No.");
        //             ItemLedgEntry.SetRange("Item No.", reserent."Item No.");
        //             ItemLedgEntry.SetRange("Order No.", reserent."Source ID");
        //             ItemLedgEntry.SetRange("Remaining Quantity", reserent."Quantity (Base)");
        //             // ItemLedgEntry.SetRange("Location Code", 'INTRANSIT');//AsPerREQ12102023
        //             ItemLedgEntry.SetRange("Location Code", 'IN-TRANSIT');
        //             if ItemLedgEntry.FindFirst() then begin
        //                 //reserent."Appl.-to Item Entry" := ItemLedgEntry."Entry No.";
        //                 reserent."Reservation Status" := reserent."Reservation Status"::Prospect;
        //                 reserent.Modify();
        //             end;
        //         until reserent.Next() = 0;
        //     //Alle+ AS_06092023
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

    var

        tets: Record 2000000110;
}

