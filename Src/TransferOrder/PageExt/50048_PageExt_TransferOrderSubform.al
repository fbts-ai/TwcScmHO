pageextension 50048 TransferOrderSubformExt extends "Transfer Order Subform"
{
    layout
    {
        // Add changes to page layout here
        moveafter("Transfer Price"; "Qty. to Receive")

        moveafter(Amount; "Quantity Received")

        addafter("Receipt Date")
        {
            field(FixedAssetNo; Rec.FixedAssetNo)
            {
                Caption = 'Fixed Asset No.';
            }
            field(Remarks; Rec.Remarks)
            {
                Caption = 'Remarks';
            }

        }
        addafter(Quantity)
        {
            field("Indent Qty."; rec."Indent Qty.")
            {
                ApplicationArea = all;

            }
            field("FA Subclass"; rec."FA Subclass")
            {
                ApplicationArea = all;
            }
        }

    }

    actions
    {
        // Add changes to page actions here

        addafter("&Line")
        {
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
                                    // If qtyCount < TempTransferLine.Quantity then //PT-FBTS old Code Commnet 17-11-25
                                    //     Error('Qty avaliable in Lot and Qty enter online is less, please redure a qty available');//PT-FBTS old Code Commnet 17-11-25
                                    If qtyCount < (TempTransferLine.Quantity * TempTransferLine."Qty. per Unit of Measure") then//PT-FBTS 17-11-2025
                                        Error('Qty available in Lot and Qty enter online is less , please reduce a qty available for Item %1', TempTransferLine."Item No."); //PT-FBTS 17-11-2025
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
                                                    qty_qtyBase := TotalQty;// TotalQty * TempTransferLine."Qty. per Unit of Measure";
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
                            Until TempTransferLine.next() = 0;

                        Message('Auto Lot no assigned sussessfully');


                    end;
                }


            }

        }
        addafter(Lot)
        {
            action(AutoLotAssignafterShipment)
            {
                ApplicationArea = ItemTracking;
                Caption = 'AutoLotAssignafterShipment';
                Image = Shipment;
                ShortCutKey = 'Ctrl+Alt+I';
                ToolTip = 'View or edit serial numbers and lot numbers that are assigned to the item on the document or journal line.';

                trigger OnAction()
                var
                    ValidateReservationEntry: Record "Reservation Entry";
                    transferline2: Record "Transfer Line";
                    transferline3: Record "Transfer Line";
                    SourceProdOrderLine: Integer;
                    SourceRefNo: Integer;
                    Usersetup: Record "User Setup";
                    AllSCMCustomization: Codeunit AllSCMCustomization;
                begin

                    if Usersetup.Get(UserId) then
                        if Usersetup."Allow Master Modification" = true then begin
                            TransferLine2.RESET;
                            TransferLine2.SETRANGE("Document No.", rec."Document No.");
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
                                Message('Auto Lot no assigned sussessfully');
                            end;
                        end;
                end;
            }

        }
    }
    // procedure "Assign Lot NO"(transferline: Record "Transfer Line"; SourceProdOrderLine: Integer; SourceRefNo: Integer)
    // var
    //     myInt: Integer;
    //     Item: Record Item;
    // begin
    //     if Item.get(transferline."Item No.") then
    //         if Item."Item Tracking Code" <> '' then begin
    //             Clear(Reservationqty);
    //             QtyToAllocate := transferline."Quantity (Base)";
    //             itemledentry.Reset();
    //             itemledentry.SetFilter("Remaining Quantity", '<>%1', 0);
    //             itemledentry.SetRange("Order No.", transferline."Document No.");
    //             ItemLedEntry.SetRange("Item No.", transferline."Item No.");
    //             itemledentry.SetRange("Location Code", transferline."Transfer-from Code");
    //             if itemledentry.FindSet() then begin
    //                 repeat
    //                     if QtyToAllocate = 0 then
    //                         exit;
    //                     Clear(QtyToAllocate2);
    //                     Clear(QtyToReservation);
    //                     Clear(lotno);
    //                     lotno := itemledentry."Lot No.";
    //                     ReservationEntry.Reset();
    //                     ReservationEntry.SetRange(ReservationEntry."Item No.", transferline."Item No.");
    //                     ReservationEntry.SetRange(ReservationEntry."Location Code", transferline."Transfer-from Code");
    //                     ReservationEntry.SetRange(ReservationEntry."Lot No.", Lotno);
    //                     ReservationEntry.SetRange("ILE No.", itemledentry."Entry No.");
    //                     ReservationEntry.SetFilter(Quantity, '<%1', 0);
    //                     ReservationEntry.CalcSums("Quantity (Base)");
    //                     Reservationqty := abs(ReservationEntry."Quantity (Base)");

    //                     if itemledentry."Remaining Quantity" > Reservationqty then begin

    //                         IF QtyToAllocate >= itemledentry."Remaining Quantity" - Reservationqty then
    //                             QtyToReservation := itemledentry."Remaining Quantity" - Reservationqty
    //                         else
    //                             QtyToReservation := QtyToAllocate;
    //                         QtyToAllocate := QtyToAllocate - QtyToReservation;

    //                         ReservationEntry2.RESET;
    //                         ReservationEntry2.SetFilter("Lot No.", '<>%1', '');
    //                         ReservationEntry2.SETRANGE("Source ID", TransferLine."Document No.");
    //                         ReservationEntry2.SETRANGE("Source Ref. No.", TransferLine."Line No.");
    //                         ReservationEntry2.SETRANGE("Item No.", TransferLine."Item No.");
    //                         ReservationEntry2.CalcSums("Quantity (Base)");
    //                         TotalremQtyILE2 := ReservationEntry2."Quantity (Base)";
    //                         if transferline."Quantity (Base)" = TotalremQtyILE2 then
    //                             exit;

    //                         Clear(Entry);
    //                         ReservationEntry.Reset();
    //                         if ReservationEntry.FindLast() then
    //                             Entry := ReservationEntry."Entry No." + 1
    //                         else
    //                             Entry := 1;
    //                         ReservationEntry.INIT;
    //                         ReservationEntry."Entry No." := Entry + 2;
    //                         ReservationEntry.Positive := TRUE;
    //                         ReservationEntry."Item No." := TransferLine."Item No.";
    //                         ReservationEntry."Location Code" := Rec."Transfer-to Code";
    //                         ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Surplus;
    //                         ReservationEntry."Creation Date" := transferline."Shipment Date";
    //                         ReservationEntry."Source Type" := 5741;
    //                         ReservationEntry."Source Subtype" := 1;
    //                         ReservationEntry."Source ID" := TransferLine."Document No.";
    //                         ReservationEntry."Source Ref. No." := SourceProdOrderLine;
    //                         ReservationEntry."Source Prod. Order Line" := SourceRefNo;
    //                         ReservationEntry."Expected Receipt Date" := transferline."Shipment Date";
    //                         ReservationEntry."Created By" := USERID;
    //                         ReservationEntry."Qty. per Unit of Measure" := TransferLine."Qty. per Unit of Measure";
    //                         ReservationEntry.Validate(Quantity, (ReservationEntry.Quantity + QtyToReservation));
    //                         ReservationEntry."Quantity (Base)" := (ReservationEntry."Quantity (Base)" + QtyToReservation);
    //                         ReservationEntry."Qty. to Handle (Base)" := (ReservationEntry."Qty. to Handle (Base)" + QtyToReservation);
    //                         ReservationEntry."Qty. to Invoice (Base)" := (ReservationEntry."Qty. to Invoice (Base)" + QtyToReservation);
    //                         ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot No.";
    //                         ReservationEntry.Validate("Lot No.", lotno);
    //                         //ReservationEntry."ILE No." := itemledentry."Entry No.";
    //                         ReservationEntry.INSERT(TRUE);
    //                     end;
    //                 until itemledentry.Next() = 0;
    //             end
    //         end;
    // end;

    // var
    //     myInt: Integer;
    //     ReservationEntry: Record "Reservation Entry"; // "Reservation Entry"
    //     ReservationEntry2: Record "Reservation Entry";
    //     // NoSeriesMgt: Codeunit NoSeriesManagement;
    //     Entry: Integer;

    //     Lotno: Code[50];
    //     itemledentry: Record "Item Ledger Entry";
    //     itemledentry2: Record "Item Ledger Entry";
    //     QtyToAllocate: Decimal;
    //     QtyToReservation: Decimal;
    //     Reservationqty: Decimal;

    //     TotalremQtyILE2: Decimal;
    //     QtyToAllocate2: Decimal;

}


