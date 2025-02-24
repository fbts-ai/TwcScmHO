page 50154 "RSTN In Tranfer Order"
{
    Caption = 'RSTN In Transfer Order';
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
                Field("TransferfromName"; Rec."Transfer-from Name")
                {
                }
                field("Transfer-to Code"; Rec."Transfer-to Code")
                {
                    ApplicationArea = Location;
                    Editable = False; //(Status = Status::Open) AND EnableTransferFields;

                    Importance = Promoted;
                    ToolTip = 'Specifies the code of the location that the items are transferred to.';

                    trigger OnValidate()
                    begin
                        IsTransferLinesEditable := Rec.TransferLinesEditable();
                        CurrPage.Update();
                    end;
                    /*
                                        trigger OnLookup(var Text: Text): Boolean
                                        var
                                            tempLocation: Record Location;
                                            tempusersetup: Record "User Setup";
                                            BuddyWarehousetext: Text[50];
                                            TempString: Text[50];
                                            // TempstandardText: Record "Standard Text";
                                            String1: Text[10];
                                            String2: Text[10];
                                            String3: Text[10];
                                            tempLocation1: Record Location;


                                        begin
                                            //TempstandardText.DeleteAll();
                                            //if tempusersetup.Get(UserId) then;
                                            tempLocation.Get(Rec."Transfer-from Code");
                                            BuddyWarehousetext := tempLocation.BuddyWarehouse;
                                            IF BuddyWarehousetext <> '' Then Begin
                                                //converting string

                                                String1 := CopyStr(BuddyWarehousetext, 1, 5);
                                                String2 := CopyStr(BuddyWarehousetext, 7, 5);
                                                String3 := CopyStr(BuddyWarehousetext, 13, 5);

                                                /*
                                                                            IF tempLocation1.Get(String1) then;
                                                                            TempstandardText.Init();
                                                                            TempstandardText.Code := String1;
                                                                            TempstandardText.Description := tempLocation1.Name;
                                                                            TempstandardText.Insert();

                                                                            String2 := CopyStr(BuddyWarehousetext, 7, 5);

                                                                            IF tempLocation1.Get(String2) then;
                                                                            TempstandardText.Init();
                                                                            TempstandardText.Code := String2;
                                                                            TempstandardText.Description := tempLocation1.Name;
                                                                            TempstandardText.Insert();

                                                                            String3 := CopyStr(BuddyWarehousetext, 13, 5);

                                                                            IF tempLocation1.Get(String3) then;
                                                                            TempstandardText.Init();
                                                                            TempstandardText.Code := String3;
                                                                            TempstandardText.Description := tempLocation1.Name;
                                                                            TempstandardText.Insert();

                                                tempLocation.Reset();
                                                tempLocation.SetFilter(tempLocation.Code, '=%1|=%2|=%3', String1, String2, String3);
                                                IF tempLocation.FindSet() then begin
                                                    IF PAGE.RUNMODAL(0, tempLocation) = ACTION::LookupOK THEN begin
                                                        Rec."Transfer-to Code" := tempLocation.Code;
                                                    end;

                                                end
                                            End
                                            Else begin
                                                tempLocation.Reset();
                                                IF tempLocation.FindSet() then begin
                                                    IF PAGE.RUNMODAL(0, tempLocation) = ACTION::LookupOK THEN begin
                                                        Rec."Transfer-to Code" := tempLocation.Code;
                                                    end;
                                                end
                                            end;
                                        End;
                                        */





                }
                Field("TransfertoName"; Rec."Transfer-to Name")
                {

                }
                field("Direct Transfer"; Rec."Direct Transfer")
                {
                    ApplicationArea = Location;
                    //  Editable = (Status = Status::Open) AND EnableTransferFields;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies that the transfer does not use an in-transit location. When you transfer directly, the Qty. to Receive field will be locked with the same value as the quantity to ship.';

                    trigger OnValidate()
                    begin
                        IsTransferLinesEditable := true;//Rec.TransferLinesEditable();
                        CurrPage.Update();
                        CurrPage.TransferLines.Page.Update();
                    end;
                }
                field("In-Transit Code"; Rec."In-Transit Code")
                {
                    ApplicationArea = Location;
                    Editable = false;// EnableTransferFields;
                                     //  Enabled = (NOT "Direct Transfer") AND (Status = Status::Open);
                    ToolTip = 'Specifies the in-transit code for the transfer order, such as a shipping agent.';

                    trigger OnValidate()
                    begin
                        IsTransferLinesEditable := Rec.TransferLinesEditable();
                        CurrPage.Update();
                    end;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the posting date of the transfer order.';

                    trigger OnValidate()
                    begin
                        PostingDateOnAfterValidate();
                    end;
                }
                field(TransferOrderReferenceNo; Rec.TransferOrderReferenceNo)
                {
                    Caption = 'Transfer Receipt No.';

                    trigger OnValidate()
                    var
                        TempReceiptHeader: Record "Transfer Receipt Header";
                        TempReceiptLine: Record "Transfer Receipt Line";
                        TempTransferLine1: Record "Transfer Line";
                        TempTransferLine2: Record "Transfer Line";
                    begin
                        TempReceiptHeader.Reset();
                        TempReceiptHeader.SetRange(TempReceiptHeader."No.", Rec.TransferOrderReferenceNo);
                        IF TempReceiptHeader.FindFirst() then begin
                            Rec."Transfer-to Code" := TempReceiptHeader."Transfer-from Code";
                            Rec.Validate(Rec."Transfer-to Code");
                            // Rec."In-Transit Code" := 'INTRANSIT'; //AsPerREQ12102023
                            Rec."In-Transit Code" := 'INTRANSIT1';
                            Rec.Validate(Rec."In-Transit Code");
                            CurrPage.Update();

                            TempTransferLine2.Reset();
                            TempTransferLine2.SetRange("Document No.", Rec."No.");
                            IF TempTransferLine2.FindSet() then
                                TempTransferLine2.DeleteAll();

                            TempReceiptLine.Reset();
                            TempReceiptLine.SetRange("Document No.", Rec.TransferOrderReferenceNo);
                            IF TempReceiptLine.FindSet() then
                                repeat
                                    TempTransferLine1.Init();
                                    TempTransferLine1."Document No." := Rec."No.";
                                    TempTransferLine1."Line No." := TempReceiptLine."Line No.";
                                    TempTransferLine1."Item No." := TempReceiptLine."Item No.";
                                    TempTransferLine1.Validate(TempTransferLine1."Item No.");
                                    TempTransferLine1.Insert();
                                until TempReceiptLine.Next() = 0;
                            CurrPage.TransferLines.Page.Editable(true);

                            CurrPage.TransferLines.Page.Update();
                            CurrPage.TransferLines.Page.Editable(true);



                        end;
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

                field(Status; Status)
                {
                    ApplicationArea = Location;
                    Importance = Promoted;
                    ToolTip = 'Specifies whether the transfer order is open or has been released for warehouse handling.';
                }
            }
            part(TransferLines; "RSTN Transfer Order Subform")
            {
                ApplicationArea = Location;
                Editable = true;
                Enabled = true;
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
                    /*
                    trigger OnAction()
                    var
                        ReleaseDoc: Codeunit "Release Transfer Document";
                    begin
                        IF Rec."Shipping Agent Code" = '' then
                            Error('Please enter value in shipping agent code');

                        ReleaseDoc.Run(Rec);
                    end;
                    */
                }
                action("Reo&pen")
                {
                    ApplicationArea = Location;
                    Visible = false;//PT-FBTS 30-01-2025
                    Caption = 'Reo&pen';
                    Image = ReOpen;
                    ToolTip = 'Reopen the transfer order after being released for warehouse handling.';

                    trigger OnAction()
                    var
                        ReleaseTransferDoc: Codeunit "Release Transfer Document";

                    begin
                        // IF Rec.Status = Rec.Status::Released then
                        //    Error('For inter store transfer you can not reopen a transfer order once release');

                        ReleaseTransferDoc.Reopen(Rec);
                    end;
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
                                                    Intestorecodeunit.InterstoreReservationEntry(TempTransferLine, ILE."Lot No.",
                                                    TotalQty, qty_qtyBase, TotalQtytoShipBase, TotalQtytoReceiveBase, ILE."Expiration Date");
                                                    TotalQty := 0;
                                                    TotalQtytoReceiveBase := 0;
                                                    TotalQtytoReceiveBase := 0;
                                                end else
                                                    if (ILE."Remaining Quantity" < TotalQty) then begin
                                                        qty_qtyBase := ILE."Remaining Quantity" * TempTransferLine."Qty. per Unit of Measure";
                                                        Intestorecodeunit.InterstoreReservationEntry(TempTransferLine, ILE."Lot No.", ILE."Remaining Quantity",
                                                        qty_qtyBase, qty_qtyBase, qty_qtyBase, ILE."Expiration Date");
                                                        TotalQty := TotalQty - ILE."Remaining Quantity";
                                                        TotalQtytoShipBase := TotalQtytoShipBase - qty_qtyBase;
                                                        TotalQtytoReceiveBase := TotalQtytoReceiveBase - qty_qtyBase
                                                    end;
                                            End;
                                        Until ILE.Next() = 0;

                                end;
                            Until TempTransferLine.next() = 0;

                        Message('Auto Lot no assigned sussessfully');


                    end;
                }
                


        }
        */

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
                        CodeunittransferInOut: Codeunit TransferInOut;
                    begin

                        IF Rec.Status = Rec.Status::Open then
                            Error('Order Must be released before posting');
                        //validation to check if location code is coorect
                        TempUserSetup.Get(UserId);
                        //if Rec."Transfer-to Code" <> TempUserSetup."Location Code" then
                        //    Error('Location Mentioned on User setup and transfer to location must be same , For Posting Instore transfer');
                        //ALLE_NICK_130224-RSTN
                        // CODEUNIT.Run(CODEUNIT::"TransferOrder-Post (Yes/No)", Rec);
                        CodeunittransferInOut.TransferInoutPost(Rec, false, true);
                    end;
                }
                action(PostAndPrint)
                {
                    ApplicationArea = Location;
                    Caption = 'Post and &Print';
                    Image = PostPrint;
                    ShortCutKey = 'Shift+F9';
                    ToolTip = 'Finalize and prepare to print the document or journal. The values and quantities are posted to the related accounts. A report request window where you can specify what to include on the print-out.';
                    Visible = false;
                    trigger OnAction()
                    begin
                        CODEUNIT.Run(CODEUNIT::"TransferOrder-Post + Print", Rec);
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



    trigger OnOpenPage()
    begin
        SetDocNoVisible();
        EnableTransferFields := not IsPartiallyShipped();
        ActivateFields();
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

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        tempusersetup: Record "User Setup";
    begin
        if tempusersetup.get(UserId) then;
        Rec."Transfer-from Code" := tempusersetup."Location Code";
        rec.RSTN := true;
        Rec.Validate(Rec."Transfer-from Code");

    end;
}

