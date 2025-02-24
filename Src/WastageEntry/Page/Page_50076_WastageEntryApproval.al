page 50076 "Wastage Entry Approval Page"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = WastageEntryHeader;
    CardPageId = WastageEntryCard;
    Editable = false;


    SourceTableView = sorting("No.") order(descending) where(Status = filter(PendingApproval));

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = all;
                }

                field("Posting date"; rec."Posting date")
                {
                    ApplicationArea = all;
                    Caption = 'Requested Delivery Date';
                }
                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = all;
                }
                field("CreatedBy"; Rec."CreatedBy")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = all;
                }
            }
        }

    }
    actions
    {
        area(Processing)
        {
            action(Approve)
            {
                ApplicationArea = all;

                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = Approve;
                trigger OnAction()
                var
                    tempusersetup: Record "User Setup";
                    TempItemJnlLine: Record "Item Journal Line";
                    TempItemJnlLine1: Record "Item Journal Line";
                    TempWastageEntryLine: Record WastageEntryLine;
                    Cutofftime: DateTime;
                    TempJournalBatchName: Record "Item Journal Batch";
                    NoSeriesMgmt: Codeunit NoSeriesManagement;
                    TempItem: Record Item;
                    DocNo: Code[20];
                    TempILE: Record "Item Ledger Entry";

                    ReservEntry: Record "Reservation Entry";
                    CreateReservEntry: Codeunit "Create Reserv. Entry";
                    //  TempTransferLine: Record "Transfer Line";
                    // TempIetm: Record Item;
                    WastageEntryCodeunit: Codeunit AllSCMCustomization;
                    ILE: Record "Item Ledger Entry";
                    TotalQty: Decimal;
                    qty_qtyBase: Decimal;
                    TotalQtytoShipBase: Decimal;
                    TotalQtytoReceiveBase: Decimal;
                    ILE1: Record "Item Ledger Entry";
                    qtyCount: Decimal;
                    InventSetup: Record "Inventory Setup";
                    ItemJournalTemplate: Code[10];
                    ItemJournalBatchName: Code[10];
                    WastageEntryLotNo: Record WastageEntryLotNo;
                    QtyLotCountForManual: Decimal;
                    manuallotbasedqty: Decimal;
                    TempTransactionHeader: Record "LSC Transaction Header";
                    TempUnitofUOM: Record "Item Unit of Measure";
                    qty: Decimal;
                    ScmCodeunit: Codeunit AllSCMCustomization;

                    TempItemJnlLine6: Record "Item Journal Line";
                    LineNo: Integer;
                    TempWastageEntryLineForlot: Record WastageEntryLine;
                begin

                    //ALLE_NICK_11/1/23_LotFix
                    TempWastageEntryLineForlot.Reset();
                    TempWastageEntryLineForlot.SetRange("DocumentNo.", Rec."No.");
                    IF TempWastageEntryLineForlot.FindSet() then begin
                        repeat
                            QTYvalidate(TempWastageEntryLineForlot, rec."Posting date")
                        until TempWastageEntryLineForlot.Next() = 0

                    end;

                    IF Confirm('Are sure you want approve selected wastage entry ', true) then begin
                        IF Rec.Status = Rec.Status::PendingApproval then begin

                            Rec.Status := Rec.Status::Approved;
                            Rec.Modify();


                            CurrPage.Update();

                            TempWastageEntryLine.Reset();
                            TempWastageEntryLine.SetRange("DocumentNo.", Rec."No.");
                            TempWastageEntryLine.SetFilter("Reason Code", '=%1', '');
                            IF TempWastageEntryLine.FindFirst() then begin
                                Error('Reason code must have value in Line No. %1', TempWastageEntryLine."LineNo.");
                            end;

                            IF Confirm('Are you sure to submit the Wastage Entry? You will not be able to modify after submitting.', true) then begin
                                IF Rec.Status = Rec.Status::Approved then begin
                                    InventSetup.Get();
                                    ItemJournalTemplate := InventSetup.WastageEntryTemplateName;
                                    ItemJournalBatchName := InventSetup.WastageEntryBatchName;
                                    InventSetup.TestField(InventSetup.WastageEntryTemplateName);
                                    InventSetup.TestField(InventSetup.WastageEntryBatchName);
                                    if TempJournalBatchName.Get(ItemJournalTemplate, ItemJournalBatchName) Then;

                                    //delete resveration entry
                                    TempItemJnlLine1.Reset();
                                    TempItemJnlLine1.SetRange("Journal Template Name", ItemJournalTemplate);
                                    TempItemJnlLine1.SetRange("Journal Batch Name", ItemJournalBatchName);
                                    TempItemJnlLine1.SetRange("Document No.", Rec."No."); //added document number
                                    IF TempItemJnlLine1.FindSet() then
                                        Repeat
                                            ScmCodeunit.DeleteReserverationLine(TempItemJnlLine1);
                                        Until TempItemJnlLine1.Next() = 0;
                                    ///delete item jounal line
                                    TempItemJnlLine1.Reset();
                                    TempItemJnlLine1.SetRange("Journal Template Name", ItemJournalTemplate);
                                    TempItemJnlLine1.SetRange("Journal Batch Name", ItemJournalBatchName);
                                    TempItemJnlLine1.SetRange("Document No.", Rec."No."); //document No.
                                    IF TempItemJnlLine1.FindSet() then
                                        TempItemJnlLine1.DeleteAll(true);

                                    TempWastageEntryLine.Reset();
                                    TempWastageEntryLine.SetRange("DocumentNo.", Rec."No.");
                                    IF TempWastageEntryLine.FindSet() then
                                        repeat

                                            TempItemJnlLine.Init();
                                            TempItemJnlLine."Journal Template Name" := ItemJournalTemplate;
                                            TempItemJnlLine."Journal Batch Name" := ItemJournalBatchName;
                                            //TempItemJnlLine."Source Code" := 'ITEMJNL';

                                            DocNo := Rec."No.";//NoSeriesMgmt.GetNextNo(TempJournalBatchName."No. Series", Rec."Posting date", false);
                                            TempItemJnlLine."Document No." := DocNo;

                                            TempItemJnlLine6.Reset();
                                            TempItemJnlLine6.SetRange("Journal Template Name", TempItemJnlLine."Journal Template Name");
                                            TempItemJnlLine6.SetRange("Journal Batch Name", TempItemJnlLine."Journal Batch Name");
                                            if TempItemJnlLine6.FindLast() then
                                                LineNo := TempItemJnlLine6."Line No." + 10000
                                            else
                                                LineNo := 10000;

                                            TempItemJnlLine."Line No." := LineNo;


                                            TempItemJnlLine."Posting No. Series" := TempJournalBatchName."No. Series";
                                            TempItemJnlLine.Validate(TempItemJnlLine."Posting No. Series");
                                            TempItemJnlLine."Posting Date" := Rec."Posting date";
                                            TempItemJnlLine.Validate(TempItemJnlLine."Posting Date");

                                            TempItemJnlLine."Entry Type" := TempItemJnlLine."Entry Type"::"Negative Adjmt.";
                                            TempItemJnlLine.Validate(TempItemJnlLine."Entry Type");
                                            TempItemJnlLine."Item No." := TempWastageEntryLine."Item Code";
                                            TempItemJnlLine.Validate(TempItemJnlLine."Item No.");


                                            IF TempItem.Get(TempItemJnlLine."Item No.") then;
                                            TempItemJnlLine."Gen. Prod. Posting Group" := TempItem."Gen. Prod. Posting Group";
                                            TempItemJnlLine.Validate(TempItemJnlLine."Gen. Prod. Posting Group");

                                            TempItemJnlLine."Document Date" := Rec."Posting date";
                                            TempItemJnlLine.Validate(TempItemJnlLine."Document Date");

                                            TempItemJnlLine."Location Code" := Rec."Location Code";
                                            TempItemJnlLine.Validate(TempItemJnlLine."Location Code");

                                            // TempItemJnlLine."Unit of Measure Code" := TempWastageEntryLine."Unit of Measure Code";
                                            // TempItemJnlLine.Validate(TempItemJnlLine."Unit of Measure Code");
                                            TempUnitofUOM.Reset();
                                            TempUnitofUOM.SetRange("Item No.", TempWastageEntryLine."Item Code");
                                            TempUnitofUOM.SetRange(Code, TempWastageEntryLine."Unit of Measure Code");
                                            IF TempUnitofUOM.FindFirst() Then;
                                            qty := TempWastageEntryLine.Quantity * TempUnitofUOM."Qty. per Unit of Measure";

                                            TempItemJnlLine.Quantity := qty;
                                            TempItemJnlLine.Validate(TempItemJnlLine.Quantity);
                                            TempItemJnlLine."Source Code" := 'ITEMJNL';
                                            TempItemJnlLine.Validate(TempItemJnlLine."Source Code");


                                            TempItemJnlLine."Reason Code" := TempWastageEntryLine."Reason Code";
                                            //as we validation location code on item journal commenting this code
                                            /*
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

                                                GLSetup.Get();
                                                DefaultDim.Reset();
                                                DefaultDim.SetRange("Table ID", 14);
                                                DefaultDim.SetRange("No.", TempItemJnlLine."Location Code");
                                                DefaultDim.SetRange("Dimension Code", GLSetup."Shortcut Dimension 3 Code");
                                                if DefaultDim.FindFirst() then begin
                                                    TempItemJnlLine.ValidateShortcutDimCode(3, DefaultDim."Dimension Value Code");
                                                    // TempItemJnlLine. := DefaultDim."Dimension Value Code";
                                                    //  TempItemJnlLine.Validate(TempItemJnlLine."Shortcut Dimension 2 Code");
                                                end;
                                                //end
                                                */

                                            //Validation for insuffient qty 
                                            IF TempItem."Item Tracking Code" <> '' then begin
                                                qtyCount := 0;

                                                ILE1.Reset();
                                                ILE1.SetCurrentKey("Entry No.");
                                                ILE1.SetRange("Item No.", TempItem."No.");
                                                ILE1.SetRange("Location Code", TempItemJnlLine."Location Code");
                                                ILE1.SetRange(Open, true);
                                                ILE1.SetFilter("Remaining Quantity", '>%1', 0);
                                                ILE1.SetFilter("Lot No.", '<>%1', '');
                                                IF ILE1.FindSet() then
                                                    repeat
                                                        qtyCount := qtyCount + (ILE1."Remaining Quantity" * ILE1."Qty. per Unit of Measure");
                                                    Until ILE1.Next() = 0;
                                                If qtyCount < qty then
                                                    Error('Qty available in Lot and Qty enter online is less , please reduce a qty availablefor Item %1', TempItem."No.");

                                            End;
                                            TempItemJnlLine.Insert(true);
                                            Commit();
                                            //For AutoLotAssignmemnt
                                            IF TempItem."Item Tracking Code" <> '' then begin


                                                //wastageEntry Manual cacilate qty
                                                QtyLotCountForManual := 0;

                                                WastageEntryLotNo.reset;
                                                WastageEntryLotNo.SetRange(WastageEntryLotNo.WastageEntryNo, Rec."No.");
                                                WastageEntryLotNo.SetRange(WastageEntryLotNo.ItemNo, TempWastageEntryLine."Item Code");
                                                WastageEntryLotNo.SetRange(WastageEntryLotNo.LineNo, TempWastageEntryLine."LineNo.");
                                                WastageEntryLotNo.SetFilter(WastageEntryLotNo.LotNo, '<>%1', '');
                                                WastageEntryLotNo.SetFilter(WastageEntryLotNo.Quantity, '<>%1', 0);

                                                IF WastageEntryLotNo.FindSet() then Begin
                                                    repeat
                                                        QtyLotCountForManual := QtyLotCountForManual + WastageEntryLotNo.Quantity;
                                                    Until WastageEntryLotNo.Next = 0;

                                                    if QtyLotCountForManual <> TempWastageEntryLine.Quantity then
                                                        Error('Quantity on wasatge entry and and qty on manual must be match')

                                                End;
                                                //wastageEntry Manual assignment
                                                WastageEntryLotNo.reset;
                                                WastageEntryLotNo.SetRange(WastageEntryLotNo.WastageEntryNo, Rec."No.");
                                                WastageEntryLotNo.SetRange(WastageEntryLotNo.ItemNo, TempWastageEntryLine."Item Code");
                                                WastageEntryLotNo.SetRange(WastageEntryLotNo.LineNo, TempWastageEntryLine."LineNo.");
                                                WastageEntryLotNo.SetFilter(WastageEntryLotNo.LotNo, '<>%1', '');
                                                WastageEntryLotNo.SetFilter(WastageEntryLotNo.Quantity, '<>%1', 0);

                                                IF WastageEntryLotNo.FindSet() then Begin
                                                    repeat
                                                        manuallotbasedqty := WastageEntryLotNo.Quantity * TempItemJnlLine."Qty. per Unit of Measure";
                                                        WastageEntryCodeunit.WastageEntryManualCreationReservationEntry(
                                                            TempItemJnlLine, WastageEntryLotNo.LotNo, WastageEntryLotNo.Quantity, manuallotbasedqty, manuallotbasedqty, manuallotbasedqty
                                                            );


                                                    Until WastageEntryLotNo.Next = 0;

                                                End
                                                Else begin ///auto lot assignment
                                                    //manual Lot assignment 
                                                    TotalQty := TempItemJnlLine.Quantity;
                                                    TotalQtytoShipBase := (TempItemJnlLine.Quantity * TempItemJnlLine."Qty. per Unit of Measure");// TempTransferLine."Qty. to Ship (Base)";
                                                    TotalQtytoReceiveBase := (TempItemJnlLine.Quantity * TempItemJnlLine."Qty. per Unit of Measure");//TempTransferLine."Qty. to Receive (Base)";

                                                    //reservation entry creation
                                                    ILE.Reset();
                                                    ILE.SetCurrentKey("Entry No.");
                                                    ILE.SetAscending("Entry No.", true);
                                                    ILE.SetRange("Item No.", TempItem."No.");
                                                    ILE.SetRange("Location Code", TempItemJnlLine."Location Code");
                                                    ILE.SetRange(Open, true);
                                                    ILE.SetFilter("Remaining Quantity", '>%1', 0);
                                                    ILE.SetFilter("Lot No.", '<>%1', '');
                                                    IF ILE.FindSet() then
                                                        repeat
                                                            IF TotalQty > 0 then Begin
                                                                If ILE."Remaining Quantity" >= TotalQty then begin
                                                                    qty_qtyBase := TotalQty * TempItemJnlLine."Qty. per Unit of Measure";
                                                                    TotalQtytoShipBase := TotalQty * TempItemJnlLine."Qty. per Unit of Measure";
                                                                    TotalQtytoReceiveBase := TotalQty * TempItemJnlLine."Qty. per Unit of Measure";
                                                                    WastageEntryCodeunit.WastageEntryReservationEntry(TempItemJnlLine, ILE."Lot No.",
                                                                    TotalQty, qty_qtyBase, TotalQtytoShipBase, TotalQtytoReceiveBase, ILE."Expiration Date");
                                                                    TotalQty := 0;
                                                                    TotalQtytoReceiveBase := 0;
                                                                    TotalQtytoReceiveBase := 0;
                                                                end else
                                                                    if (ILE."Remaining Quantity" < TotalQty) then begin
                                                                        qty_qtyBase := ILE."Remaining Quantity" * TempItemJnlLine."Qty. per Unit of Measure";
                                                                        WastageEntryCodeunit.WastageEntryReservationEntry(TempItemJnlLine, ILE."Lot No.", ILE."Remaining Quantity",
                                                                        qty_qtyBase, qty_qtyBase, qty_qtyBase, ILE."Expiration Date");
                                                                        TotalQty := TotalQty - ILE."Remaining Quantity";
                                                                        TotalQtytoShipBase := TotalQtytoShipBase - qty_qtyBase;
                                                                        TotalQtytoReceiveBase := TotalQtytoReceiveBase - qty_qtyBase
                                                                    end;
                                                            End;
                                                        Until ILE.Next() = 0;

                                                end;

                                            end;


                                        Until TempWastageEntryLine.Next() = 0;

                                    TempItemJnlLine1.Reset();
                                    TempItemJnlLine1.SetRange("Journal Template Name", ItemJournalTemplate);
                                    TempItemJnlLine1.SetRange("Journal Batch Name", ItemJournalBatchName);
                                    TempItemJnlLine1.SetRange("Document No.", Rec."No."); //document No.
                                    IF TempItemJnlLine1.FindSet() then;
                                    IF TempItemJnlLine1.Count() > 0 Then
                                        codeunit.Run(Codeunit::"Item Jnl.-Post Batch", TempItemJnlLine1);

                                    TempILE.Reset();
                                    TempILE.SetRange(TempILE."Document No.", Rec."No.");
                                    if TempILE.FindFirst() then begin

                                        Rec.Status := Rec.Status::Posted;
                                        Rec.Modify();
                                        CurrPage.Update();
                                        Message('Wastage Entry Posted successfully');

                                    end;




                                end else
                                    Error('Status must be pending for approval');
                            end;
                        end;
                    end;
                End;


            }

            action(Reject)
            {
                ApplicationArea = all;

                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = Approve;
                trigger OnAction()
                var
                    tempusersetup: Record "User Setup";
                    MyDialog: Dialog;
                    TempInputDialogPage: Page "InputDialogPage";

                begin

                    IF Confirm('Are sure you want Reject selected wastage entry ', true) then begin
                        IF Rec.Status = Rec.Status::PendingApproval then begin

                            // TempInputDialogPage.RunModal()
                            TempInputDialogPage.setWastegeEntry(Rec);
                            if TempInputDialogPage.RunModal() = Action::OK then begin
                                IF Rec.RejectionRemark = '' then
                                    Error('It is mandatory to enter Rejection remark');
                                Message('Wastage Entry is rejected ');
                            end;
                            CurrPage.Update();


                        end else
                            Error('Status must be pending for approval');
                    end;
                end;


            }
        }
    }

    var

        usersetup: Record "User Setup";

    trigger OnOpenPage()
    begin
        usersetup.Get(UserId);
        Rec.FilterGroup(2);
        //Rec.SetRange("Location Code", usersetup."Location Code");
        Rec.SetRange(ApproverID, UserId);
        Rec.FilterGroup(0);

    end;
    //ALLE_NICK_11/1/23_LotFix
    //start
    local procedure QTYvalidate(WastageLine: Record WastageEntryLine; DATE: Date)
    var
        TempItem: Record Item;

        ILE1: Record "Item Ledger Entry";
        Postingdate: text;
        InvSetUp: Record "Inventory Setup";
        AssignQty: Decimal;
    begin
        WastageLine.CalcFields("Stock in hand");
        If WastageLine."Stock in hand" < WastageLine.Quantity then begin
            AssignQty := WastageLine."Stock in hand" - WastageLine.Quantity;
            if InvSetUp.Get() then
                if InvSetUp."Wastage Post. Allow" then begin
                    Evaluate(Postingdate, Format(date));
                    CreateIJL(WastageLine, Postingdate, AssignQty);
                end
                else
                    Error('Inventory is not avaliable for this Item, please reduce a qty for Item No %1', WastageLine."Item Code");
        end;


    end;

    local procedure CreateIJL(WASTAGELINE: Record WastageEntryLine; DTLocal: Text; qty: Decimal)
    var
        IJLineTmp: Record 83;
        DTLoc: Date;
        Store: Record 99001470;
        Item: Record Item;
        lotNo: Code[20];
        NoSeriesMgt: Codeunit NoSeriesManagement;
        ItemJnlBatch: Record "Item Journal Batch";
        TempItemJnlLine1: Record "Item Journal Line";
        TempItemJnlLine2: Record "Item Journal Line";
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
    begin
        // ItemJnlBatch.SetRange("Journal Template Name", 'ITEM');
        // if ItemJnlBatch.FindFirst() then;
        Item.Get(WASTAGELINE."Item Code");
        if Item.Type = Item.Type::Inventory then begin
            IJLine.INIT;
            IJLine.VALIDATE("Journal Template Name", 'ITEM');
            // IJLine.VALIDATE("Journal Batch Name", ItemJnlBatch.Name);
            IJLine.VALIDATE("Journal Batch Name", 'WTENTRY');
            //ALLE-AS-20012024
            IJLine.VALIDATE("Document No.", WASTAGELINE."DocumentNo.");
            IJLineTmp.RESET;
            IJLineTmp.SETRANGE("Journal Template Name", 'ITEM');
            // IJLineTmp.SETRANGE("Journal Batch Name", ItemJnlBatch.Name);
            IJLineTmp.SETRANGE("Journal Batch Name", 'WTENTRY');
            IF IJLineTmp.FINDLAST THEN
                IJLine."Line No." := IJLineTmp."Line No." + 10000
            ELSE
                IJLine."Line No." := 10000;
            IJLine.VALIDATE("Entry Type", IJLine."Entry Type"::"Positive Adjmt.");
            IJLine.VALIDATE("Item No.", (WASTAGELINE."Item Code"));
            EVALUATE(DTLoc, DTLocal);
            Evaluate(IJLine."Posting Date", DTLocal);
            IJLine.VALIDATE("Posting Date");
            IJLine.VALIDATE("Location Code", WASTAGELINE."Location Code");
            IJLine."Reason Code" := 'WP';
            //ALLE-AS-20012024
            IJLine.VALIDATE(Quantity, Abs(qty));
            IF Store.GET(WASTAGELINE."Location Code") THEN
                IJLine.VALIDATE("Shortcut Dimension 1 Code", Store."Global Dimension 1 Code");
            IJLine.INSERT(TRUE);
            // PostWastageEntry;
            Clear(lotNo);
            IJLine.TestField("Item No.");
            if Item.Get(IJLine."Item No.") then begin
                if Item."Item Tracking Code" <> '' then begin
                    lotNo := NoSeriesMgt.GetNextNo(Item."Lot Nos.", WorkDate(), true);
                    ReservationEntry.Init();
                    if ReservationEntry.FindLast() then
                        Entry := ReservationEntry."Entry No." + 1
                    else
                        Entry := 1;
                    ReservationEntry."Entry No." := Entry;
                    ReservationEntry.Positive := true;
                    ReservationEntry.validate("Item No.", IJLine."Item No.");
                    ReservationEntry.Validate("Location Code", IJLine."Location Code");
                    ReservationEntry.Validate("Quantity (Base)", IJLine."Quantity (Base)");
                    ReservationEntry.Validate("Reservation Status", ReservationEntry."Reservation Status"::Prospect);
                    ReservationEntry.Validate("Creation Date", WorkDate());
                    ReservationEntry.Validate("Expected Receipt Date", WorkDate());
                    ReservationEntry.Validate("Source Type", 83);
                    ReservationEntry.Validate("Source Subtype", 2);
                    ReservationEntry.Validate("Source ID", 'ITEM');
                    ReservationEntry.Validate("Source Batch Name", 'WTENTRY');
                    ReservationEntry."Source Ref. No." := IJLine."Line No.";
                    ReservationEntry.Validate("Item Tracking", ReservationEntry."Item Tracking"::"Lot No.");
                    ReservationEntry.Validate("Lot No.", lotNo);
                    ReservationEntry.Validate("New Lot No.", '');
                    ReservationEntry.Validate("Source Prod. Order Line", 0);
                    ReservationEntry.Validate("Shipment Date", 0D);
                    ReservationEntry.Validate(AutoLotDocumentNo, '');
                    ReservationEntry.Validate("Appl.-to Item Entry", 0);
                    ReservationEntry.Validate("Created By", UserId);
                    ReservationEntry.Validate(ManufacturingDate, 0D);
                    ReservationEntry.Validate(BrandName, '');
                    ReservationEntry.Validate("Warranty Date", IJLine."Warranty Date");
                    ReservationEntry.Insert();
                    Commit();
                end;
                ItemJnlPostBatch.Run(IJLine);
            end;
        end;

    end;
    //ALLE_NICK_11/1/23_LotFix
    //END




    var
        IJLine: Record 83;
        ItemJnlLine: Record "Item Journal Line";
        Item: Record Item;
        NoSeries: Record "No. Series";
        ReservationEntry: Record "Reservation Entry";
        Entry: Integer;
        NoSeriesManagement: Codeunit NoSeriesManagement;







}