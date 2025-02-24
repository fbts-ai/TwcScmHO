codeunit 50011 PostStatementAutoLot
{
    trigger OnRun()
    begin

    end;
    /*
        [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInsertGlobalGLEntry', '', true, true)]
        local procedure OnAfterInsertGlobalGLEntry(GenJnlLine: Record "Gen. Journal Line"; var GLEntry: Record "G/L Entry"; var TempGLEntryBuf: Record "G/L Entry"; var NextEntryNo: Integer)
        var
            singleCU: Codeunit SingleInstanceCU;
        begin
            singleCU.insertGL(GLEntry);
        end;
    */
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Statement-Post", 'OnBeforeItemJnlLinePostLine', '', true, true)]
    local procedure OnBeforeItemJnlLinePostLine()
    begin
        //Message('auto lot');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Retail BOM Jnl.-Post Line", 'OnBeforeItemJnlInsertLine', '', true, true)]
    local procedure RunOnBeforeItemJnlLinePostLine(var ItemJnlLine: Record "Item Journal Line"; var BOMJnlLine2: Record "LSC Retail BOM Journal Line")
    var
        tempItem: Record Item;
        Cutofftime: DateTime;
        TempJournalBatchName: Record "Item Journal Batch";
        NoSeriesMgmt: Codeunit NoSeriesManagement;

        DocNo: Code[20];
        TempILE: Record "Item Ledger Entry";


        //  TempTransferLine: Record "Transfer Line";
        // TempIetm: Record Item;

        ILE: Record "Item Ledger Entry";
        TotalQty: Decimal;
        qty_qtyBase: Decimal;
        TotalQtytoShipBase: Decimal;
        TotalQtytoReceiveBase: Decimal;
        ILE1: Record "Item Ledger Entry";
        qtyCount: Decimal;
        tempRetailSetup: Record "LSC Retail Setup";
    begin
        // Message('auto lot');
        tempRetailSetup.Get();
        IF tempItem.Get(ItemJnlLine."Item No.") then;
        IF ((ItemJnlLine."Source No." = BOMJnlLine2."Item No.") and (ItemJnlLine."Source Code" = tempRetailSetup."Source Code")) then Begin
            IF (tempItem."Item Tracking Code" <> '') then begin
                //Validation for insuffient qty
                qtyCount := 0;
                ILE1.Reset();
                ILE1.SetRange("Item No.", tempItem."No.");
                ILE1.SetRange("Location Code", ItemJnlLine."Location Code");
                ILE1.SetRange(Open, true);
                ILE1.SetFilter("Remaining Quantity", '>%1', 0);
                ILE1.SetFilter("Lot No.", '<>%1', '');
                IF ILE1.FindFirst() then
                    repeat
                        qtyCount := qtyCount + (ILE1."Remaining Quantity");
                    Until ILE1.Next() = 0;
                //Ashish  If qtyCount < (ItemJnlLine.Quantity * ItemJnlLine."Qty. per Unit of Measure") then
                //Ashish      Error('Qty avaliable consumtion for article %1 is less ', ItemJnlLine."Item No.");
                //Validation end
                TotalQty := ItemJnlLine."Quantity (Base)";
                TotalQtytoShipBase := ItemJnlLine."Quantity (Base)";// TempTransferLine."Qty. to Ship (Base)";
                TotalQtytoReceiveBase := ItemJnlLine."Quantity (Base)";//TempTransferLine."Qty. to Receive (Base)";
                IF TotalQty > 0 then Begin
                    //reservation entry creation
                    ILE.Reset();
                    ILE.SetCurrentKey("Entry No.");
                    ILE.SetAscending("Entry No.", true);
                    ILE.SetRange("Item No.", TempItem."No.");
                    ILE.SetRange("Location Code", ItemJnlLine."Location Code");
                    ILE.SetRange(Open, true);
                    ILE.SetFilter("Remaining Quantity", '>%1', 0);
                    ILE.SetFilter("Lot No.", '<>%1', '');
                    IF ILE.FindFirst() then begin
                        repeat
                            IF TotalQty > 0 then Begin
                                If ILE."Remaining Quantity" >= TotalQty then begin
                                    qty_qtyBase := TotalQty;// TotalQty * ItemJnlLine."Qty. per Unit of Measure";
                                    TotalQtytoShipBase := TotalQty;//TotalQty * ItemJnlLine."Qty. per Unit of Measure";
                                    TotalQtytoReceiveBase := TotalQty;//TotalQty * ItemJnlLine."Qty. per Unit of Measure";
                                    PostStatementBOMCompReservationEntry(ItemJnlLine, ILE."Lot No.",
                                    TotalQty, qty_qtyBase, TotalQtytoShipBase, TotalQtytoReceiveBase, ILE."Expiration Date");
                                    TotalQty := 0;
                                    TotalQtytoReceiveBase := 0;
                                    TotalQtytoReceiveBase := 0;
                                end else
                                    if (ILE."Remaining Quantity" < TotalQty) then begin
                                        qty_qtyBase := ILE."Remaining Quantity";//* ItemJnlLine."Qty. per Unit of Measure";
                                        PostStatementBOMCompReservationEntry(ItemJnlLine, ILE."Lot No.", ILE."Remaining Quantity",
                                        qty_qtyBase, qty_qtyBase, qty_qtyBase, ILE."Expiration Date");
                                        TotalQty := TotalQty - ILE."Remaining Quantity";
                                        TotalQtytoShipBase := TotalQtytoShipBase - qty_qtyBase;
                                        TotalQtytoReceiveBase := TotalQtytoReceiveBase - qty_qtyBase
                                    end;
                            End;
                        Until ILE.Next() = 0;
                    end
                    // Else //Ashish
                    //     error('No open LOT item ledger entry found for this article');

                End
                Else begin
                    IF TotalQty < 0 then begin
                        PostReturnSalesBOMCompReservationEntry(ItemJnlLine);
                    end;
                end;
            end;
        end;


    end;

    procedure PostStatementBOMCompReservationEntry(var ItemJnlLine: Record "Item Journal Line";
        var LotNo: Code[20]; var qty: Decimal; var qty_base: Decimal; var qtyshipbase: Decimal; var qtyreceviedbase: Decimal; var expdate1: Date)

    var
        n_reservationentry: Record "Reservation Entry";
        ReservationEntry: Record "Reservation Entry";
        entryNumber: Integer;
    begin
        IF n_reservationentry.FINDLAST THEN
            entryNumber := n_reservationentry."Entry No." + 1;


        ReservationEntry.RESET;
        ReservationEntry."Entry No." := entryNumber;
        ReservationEntry."Item No." := ItemJnlLine."Item No.";
        ReservationEntry."Location Code" := ItemJnlLine."Location Code";
        ReservationEntry."Qty. per Unit of Measure" := ItemJnlLine."Qty. per Unit of Measure";
        ReservationEntry.Quantity := (qty) * -1;
        ReservationEntry.Validate(ReservationEntry.Quantity);
        ReservationEntry."Quantity (Base)" := (ABS(qty_base)) * -1;
        ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Prospect;
        ReservationEntry.Description := ItemJnlLine.Description;
        ReservationEntry."Creation Date" := WORKDATE;
        ReservationEntry."Source Type" := 83;
        ReservationEntry."Source Subtype" := ReservationEntry."Source Subtype"::"3";
        //     ReservationEntry."Source ID" := WastageItemJnlLine."Journal Template Name";
        //   ReservationEntry."Source Batch Name" := WastageItemJnlLine."Journal Batch Name";
        ReservationEntry."Source Ref. No." := ItemJnlLine."Line No.";
        ReservationEntry."Created By" := USERID;
        ReservationEntry.Positive := False;
        ReservationEntry."Shipment Date" := ItemJnlLine."Posting Date";

        ReservationEntry."Qty. to Handle (Base)" := qtyshipbase * -1;
        ReservationEntry."Qty. to Invoice (Base)" := qtyreceviedbase * -1;

        ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot No.";
        ReservationEntry."Lot No." := LotNo;

        IF expdate1 <> 0D then
            ReservationEntry."Expiration Date" := expdate1;

        ReservationEntry.INSERT;


    end;


    procedure PostReturnSalesBOMCompReservationEntry(var ItemJnlLine: Record "Item Journal Line")

    var
        n_reservationentry: Record "Reservation Entry";
        ReservationEntry: Record "Reservation Entry";
        entryNumber: Integer;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        LotNo: Code[20];
        tempItem: Record "Item";
    begin
        IF n_reservationentry.FINDLAST THEN
            entryNumber := n_reservationentry."Entry No." + 1;

        if tempItem.Get(ItemJnlLine."Item No.") Then;
        ReservationEntry.RESET;
        ReservationEntry."Entry No." := entryNumber;

        LotNo := NoSeriesMgt.GetNextNo(tempItem."Lot Nos.", WorkDate(), true);
        ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot No.";
        ReservationEntry."Lot No." := LotNo;

        ReservationEntry."Item No." := ItemJnlLine."Item No.";
        ReservationEntry."Location Code" := ItemJnlLine."Location Code";
        ReservationEntry."Qty. per Unit of Measure" := ItemJnlLine."Qty. per Unit of Measure";
        ReservationEntry.Quantity := ItemJnlLine."Quantity (Base)" * -1;
        ReservationEntry.Validate(ReservationEntry.Quantity);
        ReservationEntry."Quantity (Base)" := ItemJnlLine."Quantity (Base)" * -1;
        ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Prospect;
        ReservationEntry.Description := ItemJnlLine.Description;
        ReservationEntry."Creation Date" := WORKDATE;
        ReservationEntry."Source Type" := 83;
        ReservationEntry."Source Subtype" := ReservationEntry."Source Subtype"::"3";
        ReservationEntry."Source ID" := ItemJnlLine."Journal Template Name";
        ReservationEntry."Source Batch Name" := ItemJnlLine."Journal Batch Name";
        ReservationEntry."Source Ref. No." := ItemJnlLine."Line No.";
        ReservationEntry."Created By" := USERID;
        ReservationEntry.Positive := true;
        ReservationEntry."Shipment Date" := ItemJnlLine."Posting Date";
        ReservationEntry."Qty. to Handle (Base)" := ItemJnlLine."Quantity (Base)" * -1;
        ReservationEntry."Qty. to Invoice (Base)" := ItemJnlLine."Quantity (Base)" * -1;

        ReservationEntry.INSERT;


    end;



    var
        myInt: Integer;
}