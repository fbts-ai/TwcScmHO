pageextension 50195 ItemRelacss extends "Item Reclass. Journal"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here\
        addafter("Item &Tracking Lines")
        {
            action("Assign Lot No.Positive")
            {
                ApplicationArea = all;
                Image = Lot;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    ItemJnlLine: Record "Item Journal Line";
                    ItemJnlBatch: Record "Item Journal Batch";

                begin

                    ItemJnlLine.Reset();
                    ItemJnlLine.SetRange("Journal Batch Name", rec."Journal Batch Name");
                    ItemJnlLine.SetRange("Journal Template Name", Rec."Journal Template Name");
                    ItemJnlLine.SetFilter(Quantity, '<>%1', 0);
                    if ItemJnlLine.FindSet() then begin
                        repeat
                            "Assign Lot NO"(ItemJnlLine);
                        until ItemJnlLine.Next() = 0;
                        Message('Auto LOT Applied Successfully');
                    end;
                end;
            }
        }

    }

    local procedure "Assign Lot NO"(ItemJOunLline: Record "Item Journal Line")
    var
        myInt: Integer;
        NeDate: Date;
    begin
        QtyToAllocate := 0;
        QtyToAllocate := ItemJOunLline.Quantity;
        itemledentry.Reset();
        itemledentry.SetFilter("Remaining Quantity", '>%1', 0);
        ItemLedEntry.SetRange("Item No.", ItemJOunLline."Item No.");
        ItemLedEntry.SetRange("Location Code", ItemJOunLline."Location Code");
        ItemLedEntry.SetFilter(Open, '=%1', true);
        if itemledentry.FindSet() then begin
            repeat
                if QtyToAllocate = 0 then
                    exit;
                Clear(QtyToAllocate2);
                Clear(QtyToReservation);
                Clear(lotno);
                Clear(EXPDATE);
                lotno := itemledentry."Lot No.";
                EXPDATE := itemledentry."Expiration Date";
                ReservationEntry.Reset();
                ReservationEntry.SetRange(ReservationEntry."Item No.", ItemJOunLline."Item No.");
                ReservationEntry.SetRange(ReservationEntry."Location Code", ItemJOunLline."Location Code");
                ReservationEntry.SetRange(ReservationEntry."Lot No.", Lotno);
                ReservationEntry.SetRange("ILE No.", itemledentry."Entry No.");
                ReservationEntry.SetFilter(Quantity, '<%1', 0);
                ReservationEntry.CalcSums("Quantity (Base)");
                Reservationqty := abs(ReservationEntry."Quantity (Base)");

                if itemledentry."Remaining Quantity" > Reservationqty then begin
                    IF QtyToAllocate >= itemledentry."Remaining Quantity" - Reservationqty then
                        QtyToReservation := itemledentry."Remaining Quantity" - Reservationqty
                    else
                        QtyToReservation := QtyToAllocate;
                    QtyToAllocate := QtyToAllocate - QtyToReservation;
                    ReservationEntry2.RESET;
                    ReservationEntry2.SETRANGE("Source ID", ItemJOunLline."Document No.");
                    ReservationEntry2.SETRANGE("Source Ref. No.", ItemJOunLline."Line No.");
                    ReservationEntry2.SETRANGE("Item No.", ItemJOunLline."Item No.");
                    ReservationEntry2.CalcSums("Quantity (Base)");
                    TotalremQtyILE2 := ReservationEntry2."Quantity (Base)";
                    if ItemJOunLline.Quantity = TotalremQtyILE2 then
                        exit;
                    Clear(Entry);
                    ReservationEntry.Reset();
                    if ReservationEntry.FindLast() then
                        Entry := ReservationEntry."Entry No." + 1
                    else
                        Entry := 1;
                    ReservationEntry.Reset();
                    ReservationEntry.Init();
                    ReservationEntry."Entry No." := Entry;
                    ReservationEntry.validate("Item No.", ItemJOunLline."Item No.");
                    ReservationEntry.Validate("Location Code", ItemJOunLline."Location Code");
                    // ReservationEntry.Validate("Quantity (Base)", Abs(ItemJOunLline."Quantity (Base)"));
                    ReservationEntry.Validate("Reservation Status", ReservationEntry."Reservation Status"::Prospect);
                    ReservationEntry.Validate("Creation Date", WorkDate());
                    ReservationEntry.Validate("Expected Receipt Date", WorkDate());
                    ReservationEntry.Validate("Source Type", 83);
                    ReservationEntry.Validate("Source Subtype", 4);     //*** 3 by EY
                    ReservationEntry.Validate("Source ID", 'TRANSFER');
                    ReservationEntry.Validate("Source Batch Name", ItemJOunLline."Journal Batch Name");
                    ReservationEntry."Source Ref. No." := ItemJOunLline."Line No.";
                    ReservationEntry.Validate("Item Tracking", ReservationEntry."Item Tracking"::"Lot No.");
                    ReservationEntry.Validate("Lot No.", Lotno);
                    ReservationEntry.Validate("New Lot No.", Lotno);
                    //ReservationEntry."New Lot No." := lotno;
                    ReservationEntry.Validate(Quantity, -1 * (ReservationEntry.Quantity + QtyToReservation));
                    ReservationEntry."Quantity (Base)" := -1 * (ReservationEntry."Quantity (Base)" + QtyToReservation);
                    ReservationEntry."Qty. to Handle (Base)" := -1 * (ReservationEntry."Qty. to Handle (Base)" + QtyToReservation);
                    ReservationEntry."Qty. to Invoice (Base)" := -1 * (ReservationEntry."Qty. to Invoice (Base)" + QtyToReservation);
                    ReservationEntry."Qty. per Unit of Measure" := 1;
                    // ReservationEntry."New Expiration Date" := ReservationEntry."Expiration Date";
                    ReservationEntry.Positive := false;
                    ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Prospect;
                    ReservationEntry."Expected Receipt Date" := ItemJOunLline."Posting Date";
                    ReservationEntry."Creation Date" := ItemJOunLline."Order Date";
                    ReservationEntry."Created By" := UserId;
                    ReservationEntry."ILE No." := itemledentry."Entry No.";
                    //Message(Format(ReservationEntry."New Expiration Date"));
                    ReservationEntry."New Expiration Date" := EXPDATE;
                    ReservationEntry.Insert();
                    // ReservationEntry.Modify()
                    // ReservationEntry."New Expiration Date" := ReservationEntry."Expected Receipt Date";
                end
            until itemledentry.Next() = 0;
        end;

    end;





    var
        EXPDATE: Date;
        lotno: Code[20];
        itemledentry: Record "Item Ledger Entry";
        myInt: Integer;
        //ItemJnlLine: Record "Item Journal Line";
        Item: Record Item;
        NoSeries: Record "No. Series";
        ReservationEntry: Record "Reservation Entry";
        ReservationEntry2: Record "Reservation Entry";
        Entry: Integer;
        NoSeriesManagement: Codeunit NoSeriesManagement;


        QtyToAllocate: Decimal;
        QtyToReservation: Decimal;

        Reservationqty: Decimal;
        itemledentryqty: Decimal;
        QtyToAllocate2: Decimal;
        TotalremQtyILE: Decimal;
        TotalremQtyILE2: Decimal;
}