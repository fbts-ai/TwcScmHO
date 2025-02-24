//No Publish
page 50149 "Quarantine - ILE"
{
    AdditionalSearchTerms = 'Quarantine - ILE';
    ApplicationArea = Basic, Suite;
    Caption = 'Quarantine - ILE';
    // DataCaptionExpression = GetCaption();
    DataCaptionFields = "Item No.";
    //Editable = false;
    PageType = List;
    SourceTable = "Item Ledger Entry";
    SourceTableView = SORTING("Entry No.")
                      ORDER(Descending) where("Quarantine Location" = const(true), Open = const(true), Completed = const(false));
    UsageCategory = History;
    Permissions = tabledata "Item Ledger Entry" = rim;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Select; rec.Select)
                {
                    ApplicationArea = all;
                    Editable = true;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting date for the entry.';
                    Editable = false;
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies which type of transaction that the entry is created from.';
                    Editable = false;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies what type of document was posted to create the item ledger entry.';
                    Editable = false;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number on the entry. The document is the voucher that the entry was based on, for example, a receipt.';
                    Editable = false;
                }

                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the item in the entry.';
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the entry.';
                    Editable = false;
                }
                field("Location Code"; rec."Location Code")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Discard Location Code"; QuarantineDiscardILE.GetDiscardLocCode(Rec."Document No."))//sks 08-02-24
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Discard Location Name"; QuarantineDiscardILE.GetDiscardLocName(Rec."Document No."))//sks 08-02-24
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                //AJ_ALLE_08022024
                field("MAP Value "; GETMAP(rec."Entry No."))
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                //AJ_ALLE_08022024
                field(Remarks; rec.Remarks)
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Lot No."; Rec."Lot No.") //sks 07-02-24
                {
                    ApplicationArea = all;
                }
                field("BUOM"; Rec."Unit of Measure Code") //sks 07-02-24
                {
                    ApplicationArea = all;
                }
                field(Quantity; rec.Quantity)
                {
                    ApplicationArea = all;
                }
                field("Cost Amount (Actual)"; rec."Cost Amount (Actual)") //sks 07-02-24
                {
                    ApplicationArea = all;
                }
                field("Approval Date"; DT2Date(Rec.SystemCreatedAt)) //sks 07-02-24
                {
                    ApplicationArea = all;
                }
            }
        }
        // area(factboxes)
        // {
        //     systempart(Control1900383207; Links)
        //     {
        //         ApplicationArea = RecordLinks;
        //         Visible = false;
        //     }
        //     systempart(Control1905767507; Notes)
        //     {
        //         ApplicationArea = Notes;
        //         Visible = false;
        //     }
        // }
    }

    actions
    {

        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action(Discard)
                {
                    ApplicationArea = All;
                    Image = UnitConversions;

                    trigger OnAction()
                    var
                        TempItemJnlLine1: Record "Item Journal Line";
                        TempItemJnlLine: Record "Item Journal Line";
                        TempItemJnlLineDel: Record "Item Journal Line";
                        TempItem: Record Item;
                        CodeunittransferInOut: Codeunit TransferInOut;

                        //Dimension
                        DefaultDim: Record "Default Dimension";
                        GLSetup: Record "General Ledger Setup";
                        Ilerec: Record "Item Ledger Entry";
                        LineNo: Integer;
                        Ilerec1: Record "Item Ledger Entry";
                        TempJournalBatchName: Record "Item Journal Batch";
                        NoSeriesMgmt: Codeunit NoSeriesManagement;
                        Item1: Record Item;
                        InventorySetup: Record "Inventory Setup";
                        UserSetup: Record "User Setup";
                    begin
                        //SetSelectionFilter(Rec);
                        InventorySetup.Get();
                        InventorySetup.TestField("Qurantine location Sr.");
                        InventorySetup.TestField("Quarantine-Discard Temp");
                        InventorySetup.TestField("Quarantine Batch Name");
                        TempJournalBatchName.Get(InventorySetup."Quarantine-Discard Temp", InventorySetup."Quarantine Batch Name"); //Setup Base
                        Ilerec1.SetRange(Select, true);
                        // Ilerec1.SetRange(Open, true);
                        Ilerec1.SetRange(Completed, false);
                        if Ilerec1.FindSet() then begin
                            repeat
                                TempItemJnlLineDel.SetRange("Journal Template Name", InventorySetup."Quarantine-Discard Temp"); //NAme Changed
                                TempItemJnlLineDel.SetRange("Journal Batch Name", InventorySetup."Quarantine Batch Name");
                                TempItemJnlLineDel.SetRange("ILE Entry No", Ilerec1."Entry No.");
                                if TempItemJnlLineDel.FindFirst() then begin
                                    TempItemJnlLineDel.Delete();
                                end;

                                LineNo := 0;
                                TempItemJnlLine1.SetRange("Journal Template Name", InventorySetup."Quarantine-Discard Temp");
                                TempItemJnlLine1.SetRange("Journal Batch Name", InventorySetup."Quarantine Batch Name");
                                if TempItemJnlLine1.FindLast() then begin
                                    LineNo := 10000 + TempItemJnlLine1."Line No.";
                                end else begin
                                    LineNo := 10000;
                                end;
                                TempItemJnlLine.Init();
                                TempItemJnlLine."Journal Template Name" := InventorySetup."Quarantine-Discard Temp";
                                TempItemJnlLine."Journal Batch Name" := InventorySetup."Quarantine Batch Name";

                                TempItemJnlLine.Validate("Document No.", Ilerec1."Document No.");
                                //TempItemJnlLine.Validate("Document No.", NoSeriesMgmt.GetNextNo(TempJournalBatchName."No. Series", Rec."Posting date", false));
                                TempItemJnlLine."Order No." := Ilerec1."Order No.";
                                TempItemJnlLine."Order Line No." := Ilerec1."Order Line No.";
                                TempItemJnlLine."Line No." := LineNo;
                                TempItemJnlLine.Insert();
                                TempItemJnlLine."Quarantine Location Boolean" := true;//AJ_ALLE_07022024
                                TempItemJnlLine."ILE Entry No" := Ilerec1."Entry No.";
                                TempItemJnlLine.Validate("Posting Date", Ilerec1."Posting date");
                                TempItemJnlLine.Validate(TempItemJnlLine."Entry Type", TempItemJnlLine."Entry Type"::"Negative Adjmt.");
                                TempItemJnlLine.Validate("Item No.", Ilerec1."Item No.");
                                //IF TempItem.Get(TempItemJnlLine."Item No.") then
                                //TempItemJnlLine.Validate("Gen. Prod. Posting Group", TempItem."Gen. Prod. Posting Group");
                                //TempItemJnlLine.Validate("Document Date", Ilerec1."Posting date");

                                TempItemJnlLine.Validate("Location Code", Ilerec1."Location Code");
                                TempItemJnlLine.Validate(Quantity, Ilerec1.Quantity);
                                Ilerec1.CalcFields("Cost Amount (Actual)");
                                TempItemJnlLine.Validate(Amount, Ilerec1."Cost Amount (Actual)");

                                //Dimension
                                GLSetup.Get();
                                DefaultDim.Reset();
                                DefaultDim.SetRange("Table ID", 14);
                                DefaultDim.SetRange("No.", TempItemJnlLine."Location Code");
                                DefaultDim.SetRange("Dimension Code", GLSetup."Global Dimension 1 Code");
                                if DefaultDim.FindFirst() then begin
                                    // TempItemJnlLine."Shortcut Dimension 1 Code" := DefaultDim."Dimension Value Code";
                                    TempItemJnlLine.Validate(TempItemJnlLine."Shortcut Dimension 1 Code", DefaultDim."Dimension Value Code");
                                end;

                                GLSetup.Get();
                                DefaultDim.Reset();
                                DefaultDim.SetRange("Table ID", 14);
                                DefaultDim.SetRange("No.", TempItemJnlLine."Location Code");
                                DefaultDim.SetRange("Dimension Code", GLSetup."Global Dimension 2 Code");
                                if DefaultDim.FindFirst() then begin
                                    //TempItemJnlLine."Shortcut Dimension 2 Code" := DefaultDim."Dimension Value Code";
                                    TempItemJnlLine.Validate(TempItemJnlLine."Shortcut Dimension 2 Code", DefaultDim."Dimension Value Code");
                                end;
                                //end

                                if Item1.get(Ilerec1."Item No.") then begin
                                    if Item1."Lot Nos." = '' then begin
                                        TempItemJnlLine."Applies-to Entry" := Ilerec1."Entry No.";
                                    end else begin
                                        "Assign Lot NO"(TempItemJnlLine, Ilerec1."Lot No.", Ilerec1."Entry No.");//New
                                        //"Assign Lot NO"(TempItemJnlLine);//Old
                                    end;
                                end;
                                if UserSetup.get(UserId) then begin
                                    UserSetup.TestField("Discard Approver ID");
                                    TempItemJnlLine.Approver := UserSetup."Discard Approver ID";
                                end;
                                TempItemJnlLine.Remarks := Ilerec1.Remarks;
                                TempItemJnlLine.LotNo := Ilerec1."Lot No.";
                                TempItemJnlLine.Modify();
                                // CODEUNIT.Run(CODEUNIT::"Item Jnl.-Post", TempItemJnlLine);
                                Ilerec1.Select := false;
                                Ilerec1.Completed := true;
                                Ilerec1.Modify();
                            // CurrPage.Update();
                            //End;
                            until ilerec1.Next() = 0;
                            //CODEUNIT.Run(CODEUNIT::"Item Jnl.-Post", TempItemJnlLine);
                            CurrPage.Update();
                        end;

                    end;

                }
                action("Transfer To Store")
                {
                    ApplicationArea = All;
                    Image = TransferReceipt;
                    trigger OnAction()
                    var
                        TempItemJnlLine1: Record "Item Journal Line";
                        TempItemJnlLine: Record "Item Journal Line";

                        TempItemJnlLineDel: Record "Item Journal Line";
                        TempItem: Record Item;
                        CodeunittransferInOut: Codeunit TransferInOut;

                        //Dimension
                        DefaultDim: Record "Default Dimension";
                        GLSetup: Record "General Ledger Setup";
                        Ilerec: Record "Item Ledger Entry";
                        LineNo: Integer;
                        TransferReciptHeader: Record "Transfer Receipt Header";
                        Ilerec1: Record "Item Ledger Entry";
                        TempJournalBatchName: Record "Item Journal Batch";
                        NoSeriesMgmt: Codeunit NoSeriesManagement;
                        Item1: Record Item;
                        InventorySetup: Record "Inventory Setup";
                    begin
                        //SetSelectionFilter(Rec);
                        InventorySetup.Get();

                        InventorySetup.TestField("Qurantine location Sr.");
                        //InventorySetup.TestField("Quarantine-Discard Temp");
                        //InventorySetup.TestField("Transfer Batch Name");

                        //TempJournalBatchName.Get(InventorySetup."Quarantine-Discard Temp", InventorySetup."Transfer Batch Name"); //Setup Bas
                        TempJournalBatchName.Get('TRANSFER', 'DEFAULT'); //Change
                        Ilerec1.SetRange(Select, true);
                        //Ilerec1.SetRange(Open, true);
                        Ilerec1.SetRange(Completed, false);
                        if Ilerec1.FindSet() then begin
                            repeat
                                TransferReciptHeader.SetRange("Transfer Order No.", Ilerec1."Order No.");
                                if TransferReciptHeader.FindFirst() then;



                                TempItemJnlLineDel.SetRange("Journal Template Name", 'TRANSFER'); //Change
                                TempItemJnlLineDel.SetRange("Journal Batch Name", 'DEFAULT'); //Change
                                TempItemJnlLineDel.SetRange("ILE Entry No", Ilerec1."Entry No.");
                                if TempItemJnlLineDel.FindFirst() then begin
                                    TempItemJnlLineDel.Delete();
                                end;

                                LineNo := 0;

                                TempItemJnlLine1.SetRange("Journal Template Name", 'TRANSFER'); //Change
                                TempItemJnlLine1.SetRange("Journal Batch Name", 'DEFAULT'); //Change
                                if TempItemJnlLine1.FindLast() then begin
                                    LineNo := 10000 + TempItemJnlLine1."Line No.";
                                end else begin
                                    LineNo := 10000;
                                end;

                                TempItemJnlLine.Init();
                                TempItemJnlLine."Journal Template Name" := 'TRANSFER'; //Change
                                TempItemJnlLine."Journal Batch Name" := 'DEFAULT'; //Change
                                TempItemJnlLine.Validate("Document No.", Ilerec1."Document No.");
                                //TempItemJnlLine.Validate("Document No.", NoSeriesMgmt.GetNextNo(TempJournalBatchName."No. Series", Rec."Posting date", false));
                                TempItemJnlLine."Line No." := LineNo;
                                TempItemJnlLine.Insert();
                                TempItemJnlLine."Quarantine Location Boolean" := true;//AJ_ALLE_07022024
                                TempItemJnlLine."ILE Entry No" := Ilerec1."Entry No.";
                                TempItemJnlLine."Order No." := Ilerec1."Order No.";
                                TempItemJnlLine."Order Line No." := Ilerec1."Order Line No.";
                                TempItemJnlLine.Validate("Posting Date", Ilerec1."Posting date");
                                TempItemJnlLine.Validate(TempItemJnlLine."Entry Type", TempItemJnlLine."Entry Type"::Transfer);
                                TempItemJnlLine.Validate("Item No.", Ilerec1."Item No.");

                                // IF TempItem.Get(TempItemJnlLine."Item No.") then
                                //     TempItemJnlLine.Validate("Gen. Prod. Posting Group", TempItem."Gen. Prod. Posting Group");

                                // TempItemJnlLine.Validate("Document Date", Ilerec1."Posting date");

                                TempItemJnlLine.Validate("Location Code", TransferReciptHeader."Transfer-to Code");
                                TempItemJnlLine.Validate("New Location Code", TransferReciptHeader."Transfer-from Code");

                                TempItemJnlLine.Validate(Quantity, Ilerec1.Quantity);
                                // Ilerec1.CalcFields("Cost Amount (Actual)");
                                // TempItemJnlLine.Validate(Amount, Ilerec1."Cost Amount (Actual)");
                                // TempItemJnlLine.Validate(TempItemJnlLine."Unit Cost", Ilerec1."Cost Amount (Actual)" / Ilerec1.Quantity);
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

                                if Item1.get(Ilerec1."Item No.") then begin
                                    if Item1."Lot Nos." = '' then begin
                                        TempItemJnlLine."Applies-to Entry" := Ilerec1."Entry No.";
                                    end else begin
                                        "Assign Lot NO1"(TempItemJnlLine, Ilerec1."Entry No.");
                                    end;
                                end;

                                TempItemJnlLine.Approver := Ilerec1.Approver;
                                TempItemJnlLine.Remarks := Ilerec1.Remarks;
                                TempItemJnlLine.LotNo := Ilerec1."Lot No.";
                                // TempItemJnlLine."New Lot No." := Ilerec1."Lot No.";
                                TempItemJnlLine.Modify();

                                // CODEUNIT.Run(CODEUNIT::"Item Jnl.-Post", TempItemJnlLine);
                                Ilerec1.Select := false;
                                Ilerec1.Completed := true;
                                Ilerec1.Modify();
                            // CurrPage.Update();
                            //End;
                            until Ilerec1.Next() = 0;
                            //CODEUNIT.Run(CODEUNIT::"Item Jnl.-Post", TempItemJnlLine);
                            CurrPage.Update();
                        end;

                    end;
                }

            }

        }

    }

    trigger OnOpenPage()
    begin
        OnBeforeOpenPage();

        if (Rec.GetFilters() <> '') and not Rec.Find() then
            if Rec.FindFirst() then;

        //  SetPackageTrackingVisibility();
        SetDimVisibility();
    end;

    var
        Navigate: Page Navigate;
        DimensionSetIDFilter: Page "Dimension Set ID Filter";
        [InDataSet]

        PackageTrackingVisible: Boolean;

    protected var
        Dim1Visible: Boolean;
        Dim2Visible: Boolean;
        Dim3Visible: Boolean;
        Dim4Visible: Boolean;
        Dim5Visible: Boolean;
        Dim6Visible: Boolean;
        Dim7Visible: Boolean;
        Dim8Visible: Boolean;

    local procedure SetDimVisibility()
    var
        DimensionManagement: Codeunit DimensionManagement;
    begin
        DimensionManagement.UseShortcutDims(Dim1Visible, Dim2Visible, Dim3Visible, Dim4Visible, Dim5Visible, Dim6Visible, Dim7Visible, Dim8Visible);
    end;



    [IntegrationEvent(true, false)]
    local procedure OnBeforeOpenPage()
    begin
    end;




    local procedure "Assign Lot NO1"(ItemJounLine_1: Record "Item Journal Line"; EntryNo: Integer)
    var
        myInt: Integer;
    begin
        QtyToAllocate := 0;

        QtyToAllocate := ItemJounLine_1.Quantity;
        itemledentry.Reset();
        // itemledentry.SetFilter("Remaining Quantity", '>%1', 0);
        // ItemLedEntry.SetRange("Item No.", ItemJounLine_1."Item No.");
        // ItemLedEntry.SetFilter(Open, '=%1', true);
        // ItemLedEntry.SetRange("Location Code", ItemJounLine_1."Location Code");
        ItemLedEntry.SetRange("Entry No.", EntryNo);
        if itemledentry.FindFirst() then begin
            //repeat
            if QtyToAllocate = 0 then
                exit;
            Clear(QtyToAllocate2);
            Clear(QtyToReservation);
            Clear(lotno);
            lotno := itemledentry."Lot No.";
            ReservationEntry.Reset();
            ReservationEntry.SetRange(ReservationEntry."Item No.", ItemJounLine_1."Item No.");
            ReservationEntry.SetRange(ReservationEntry."Location Code", ItemJounLine_1."Location Code");
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
                ReservationEntry2.SETRANGE("Source ID", ItemJounLine_1."Document No.");
                ReservationEntry2.SETRANGE("Source Ref. No.", ItemJounLine_1."Line No.");
                ReservationEntry2.SETRANGE("Item No.", ItemJounLine_1."Item No.");
                ReservationEntry2.CalcSums("Quantity (Base)");
                TotalremQtyILE2 := ReservationEntry2."Quantity (Base)";
                if ItemJounLine_1.Quantity = TotalremQtyILE2 then
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
                ReservationEntry."Source Type" := 83;
                ReservationEntry."Source Subtype" := 4;
                ReservationEntry."Source ID" := 'TRANSFER';
                ReservationEntry."Source Batch Name" := 'DEFAULT';
                ReservationEntry."Source Ref. No." := ItemJounLine_1."Line No.";
                ReservationEntry."Source Prod. Order Line" := 0;
                ReservationEntry."Item No." := ItemJounLine_1."Item No.";
                ReservationEntry."Location Code" := ItemJounLine_1."Location Code";
                ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot No.";
                ReservationEntry.Validate("Lot No.", Lotno);
                ReservationEntry.Validate("New Lot No.", Lotno);
                ReservationEntry.Validate(Quantity, -1 * (ReservationEntry.Quantity + QtyToReservation));
                ReservationEntry."Quantity (Base)" := -1 * (ReservationEntry."Quantity (Base)" + QtyToReservation);
                ReservationEntry."Qty. to Handle (Base)" := -1 * (ReservationEntry."Qty. to Handle (Base)" + QtyToReservation);
                ReservationEntry."Qty. to Invoice (Base)" := -1 * (ReservationEntry."Qty. to Invoice (Base)" + QtyToReservation);
                ReservationEntry."Qty. per Unit of Measure" := 1;
                ReservationEntry.Positive := false;
                ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Prospect;
                ReservationEntry."Expected Receipt Date" := ItemJounLine_1."Posting Date";
                ReservationEntry."Creation Date" := ItemJounLine_1."Document Date";
                ReservationEntry."Created By" := UserId;
                ReservationEntry."ILE No." := itemledentry."Entry No.";
                ReservationEntry.Insert();
                ReservationEntry."New Expiration Date" := itemledentry."Expiration Date";
                ReservationEntry."New Package No." := itemledentry."Package No.";
                ReservationEntry.Modify();
            end
            // until itemledentry.Next() = 0;
        end;

    end;

    //Assign lot
    local procedure "Assign Lot NO"(ItemJounLine_1: Record "Item Journal Line"; LotNo_: Code[20]; EntryNo: Integer)//New
    // local procedure "Assign Lot NO"(ItemJounLine_1: Record "Item Journal Line")//Old
    var
        myInt: Integer;
    begin
        QtyToAllocate := 0;

        QtyToAllocate := ItemJounLine_1.Quantity;
        itemledentry.Reset();
        // itemledentry.SetFilter("Remaining Quantity", '>%1', 0);
        // ItemLedEntry.SetRange("Item No.", ItemJounLine_1."Item No.");
        // ItemLedEntry.SetFilter(Open, '=%1', true);
        // ItemLedEntry.SetRange("Location Code", ItemJounLine_1."Location Code");
        // if itemledentry.FindSet() then begin
        ItemLedEntry.SetRange("Entry No.", EntryNo);
        // if itemledentry.FindSet() then begin
        if itemledentry.FindFirst() then begin
            //  repeat
            if QtyToAllocate = 0 then
                exit;
            Clear(QtyToAllocate2);
            Clear(QtyToReservation);
            Clear(lotno);
            lotno := itemledentry."Lot No.";
            ReservationEntry.Reset();
            ReservationEntry.SetRange(ReservationEntry."Item No.", ItemJounLine_1."Item No.");
            ReservationEntry.SetRange(ReservationEntry."Location Code", ItemJounLine_1."Location Code");
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
                ReservationEntry2.SETRANGE("Source ID", ItemJounLine_1."Document No.");
                ReservationEntry2.SETRANGE("Source Ref. No.", ItemJounLine_1."Line No.");
                ReservationEntry2.SETRANGE("Item No.", ItemJounLine_1."Item No.");
                ReservationEntry2.CalcSums("Quantity (Base)");
                TotalremQtyILE2 := ReservationEntry2."Quantity (Base)";
                if ItemJounLine_1.Quantity = TotalremQtyILE2 then
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
                ReservationEntry."Source Type" := 83;
                ReservationEntry."Source Subtype" := 3;
                ReservationEntry."Source ID" := 'ITEM';
                ReservationEntry."Source Batch Name" := 'QUARANTINE';
                ReservationEntry."Source Ref. No." := ItemJounLine_1."Line No.";
                ReservationEntry."Source Prod. Order Line" := 0;
                ReservationEntry."Item No." := ItemJounLine_1."Item No.";
                ReservationEntry."Location Code" := ItemJounLine_1."Location Code";
                ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot No.";
                ReservationEntry.Validate("Lot No.", Lotno);
                //ReservationEntry."New Lot No." := Lotno;
                ReservationEntry.Validate(Quantity, -1 * (ReservationEntry.Quantity + QtyToReservation));
                ReservationEntry."Quantity (Base)" := -1 * (ReservationEntry."Quantity (Base)" + QtyToReservation);
                ReservationEntry."Qty. to Handle (Base)" := -1 * (ReservationEntry."Qty. to Handle (Base)" + QtyToReservation);
                ReservationEntry."Qty. to Invoice (Base)" := -1 * (ReservationEntry."Qty. to Invoice (Base)" + QtyToReservation);
                ReservationEntry."Qty. per Unit of Measure" := 1;
                ReservationEntry.Positive := false;
                ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Prospect;
                ReservationEntry."Expected Receipt Date" := ItemJounLine_1."Posting Date";
                ReservationEntry."Creation Date" := ItemJounLine_1."Document Date";
                ReservationEntry."Created By" := UserId;
                ReservationEntry."ILE No." := itemledentry."Entry No.";
                ReservationEntry.Insert();
            end
            //until itemledentry.Next() = 0;
        end;

    end;





    var

        Item: Record Item;
        ReservationEntry: Record "Reservation Entry"; // "Reservation Entry"
        ReservationEntry2: Record "Reservation Entry";
        //Item: Record Item;

        NoSeriesMgt: Codeunit NoSeriesManagement;
        Entry: Integer;
        Start: Integer;
        Close: Integer;
        Lotno: Code[50];
        itemledentry: Record "Item Ledger Entry";
        QtyToAllocate: Decimal;
        QtyToReservation: Decimal;

        Reservationqty: Decimal;
        itemledentryqty: Decimal;
        QtyToAllocate2: Decimal;
        TotalremQtyILE: Decimal;
        TotalremQtyILE2: Decimal;
        QuarantineDiscardILE: page "Quarantine Discard ILE";
    //AJ_ALLE_08022024

    procedure GETMAP(EntyNo: Integer): Decimal
    var
        ILERec: Record "Item Ledger Entry";
        MAPValue: Decimal;
    begin
        if ILERec.Get(EntyNo) then begin
            ILERec.CalcFields("Cost Amount (Actual)");
            MAPValue := ILERec."Cost Amount (Actual)" / ILERec.Quantity;
            exit(MAPValue);
        end else
            exit(0);
    end;
    //AJ_ALLE_08022024
}

