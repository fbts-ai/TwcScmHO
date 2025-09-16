page 50073 WastageEntryCard
{
    PageType = Document;

    SourceTable = WastageEntryHeader;
    Caption = 'Wastage Entry Card';
    CardPageId = WastageEntryCard;
    PromotedActionCategories = 'New," "," ",Process,Approval';




    layout
    {

        area(Content)
        {

            group(General)
            {

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Promoted;

                    trigger OnAssistEdit()
                    begin
                        if AssistEdit(xRec) then
                            CurrPage.Update();
                    end;

                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = ALL;
                    Editable = false;

                }
                field("Posting Date"; Rec."Posting date")
                {
                    ApplicationArea = all;

                }



                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                    // trigger OnValidate()//ALLE_NICK_100124
                    // begin
                    //     if Rec.Status = Rec.Status::Open then
                    //         CurrPage.Editable(true);
                    // end;

                }

                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = All;
                    Caption = 'Created Date';
                    Editable = false;
                }
                field("CreatedBy"; Rec."CreatedBy")
                {
                    ApplicationArea = All;
                    Caption = 'Created By';
                    Editable = false;
                }
                field(Totalvalue; Rec.TotalWastageValue)
                {
                    ApplicationArea = All;
                    Caption = 'Total value';
                    Editable = false;
                }
                field(RejectionRemark; Rec.RejectionRemark)
                {
                    ApplicationArea = All;
                    Caption = 'Rejection Remarks';
                    Editable = false;
                }


            }


            part(WastageLine; WastageEntrySubform)
            {
                ApplicationArea = all;
                SubPageLink = "DocumentNo." = field("No.");
                UpdatePropagation = Both;
                Editable = IsWastageLinesEditable;
                Enabled = IsWastageLinesEditable;
            }
        }
    }
    actions
    {

        area(Processing)
        {
            action(Post)
            {
                ApplicationArea = all;

                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = Process;
                trigger OnAction()
                var
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

                    TempItemJnlLine6: Record "Item Journal Line";
                    LineNo: Integer;

                    //Dimension
                    DefaultDim: Record "Default Dimension";
                    GLSetup: Record "General Ledger Setup";

                    ScmCodeunit: Codeunit AllSCMCustomization;
                    ItmJounNew: Record 83;
                    ItmJounNew1: Record 83;
                    Reserveration: Record "Reservation Entry";
                    TempWastageEntryLineForlot: Record WastageEntryLine;

                begin
                    begin
                        CheckPostingDateAllowed(Rec);//PT-FBTS
                        TestField(Status, Status::Open);//PT-FBTS 16-09-2025
                                                        //PT-FBTs 16-09-2025
                        TempWastageEntryLine.Reset();
                        TempWastageEntryLine.SetRange("DocumentNo.", "No.");
                        if not TempWastageEntryLine.FindFirst() then
                            Error('Please Create Wastage line');
                    end;

                    /*
                    if (Rec."Posting date" < Rec."Created Date") then
                        Error('Posting Date should be grater than or equal to Created Date');
                    */
                    //Send PRD
                    ItmJounNew.SetFilter("Journal Template Name", 'ITEM');
                    //ItmJounNew.SetFilter("Journal Batch Name", '<>%1', 'SALE'); OldCode //PT-FBTS //ALLE-AS-19012024_Changed to sale
                    ItmJounNew.SetFilter("Journal Batch Name", '%1', 'WTENTRY');  //PT-FBTS   12-02-24
                    ItmJounNew.Setrange("Entry Type", ItmJounNew."Entry Type"::"Negative Adjmt."); //ALLE-AS-19012024
                    //ItmJounNew.SetRange("Location Code", rec."Location Code");
                    IF ItmJounNew.FindSet() then begin
                        repeat
                            if ItmJounNew."Journal Batch Name" <> 'DEFAULT' then
                                ItmJounNew.DeleteAll();
                        until ItmJounNew.Next() = 0;
                        Commit();
                    end;
                    //Send PRD
                    //Reserveration.SetRange("Location Code", rec."Location Code");
                    Reserveration.SetRange("Source Type", 83);
                    //Reserveration.SetFilter("Source Batch Name", '<>%1', 'SALE'); //OLDcode-//PT-FBTS //ALLE-AS-20012024_var diff
                    Reserveration.SetFilter("Source Batch Name", '%1', 'WTENTRY'); //PT-FBTS                                                               //Reserveration.SetRange(Positive, false);
                                                                                   //Reserveration.SetRange("Location Code", rec."Location Code");
                    if Reserveration.FindSet() then begin  //AJ_ALLE_23012024 +
                        repeat
                            Reserveration.DeleteAll();
                        until Reserveration.Next() = 0;
                        Commit();
                    end;  //AJ_ALLE_23012024 -



                    //ALLE_NICK_11/1/23_LotFix
                    // TempWastageEntryLineForlot.Reset();
                    // TempWastageEntryLineForlot.SetRange("DocumentNo.", Rec."No.");
                    // IF TempWastageEntryLineForlot.FindSet() then begin
                    //     repeat
                    //         QTYvalidate(TempWastageEntryLineForlot, rec."Posting date")
                    //     until TempWastageEntryLineForlot.Next() = 0

                    // end;

                    TempWastageEntryLine.Reset();
                    TempWastageEntryLine.SetRange("DocumentNo.", Rec."No.");
                    TempWastageEntryLine.SetFilter("Reason Code", '=%1', '');
                    IF TempWastageEntryLine.FindFirst() then begin
                        Error('Reason code must have value in Line No. %1', TempWastageEntryLine."LineNo.");
                    end;

                    TempWastageEntryLine.Reset();
                    TempWastageEntryLine.SetRange("DocumentNo.", Rec."No.");
                    TempWastageEntryLine.SetFilter(Quantity, '%1', 0);
                    IF TempWastageEntryLine.FindFirst() then begin
                        Error('Please enter Quantity for. %1..%2', TempWastageEntryLine."Item Code", TempWastageEntryLine.Description);
                    end;

                    IF Confirm('Are you sure to submit the Wastage Entry? You will not be able to modify after submitting.', true) then begin
                        IF Rec.Status = Rec.Status::Approved then begin
                            TempWastageEntryLineForlot.Reset();
                            TempWastageEntryLineForlot.SetRange("DocumentNo.", Rec."No.");
                            IF TempWastageEntryLineForlot.FindSet() then begin
                                repeat
                                    QTYvalidate(TempWastageEntryLineForlot, rec."Posting date")
                                until TempWastageEntryLineForlot.Next() = 0

                            end;
                            InventSetup.Get();
                            ItemJournalTemplate := InventSetup.WastageEntryTemplateName;
                            ItemJournalBatchName := InventSetup.WastageEntryBatchName;
                            InventSetup.TestField(InventSetup.WastageEntryTemplateName);
                            InventSetup.TestField(InventSetup.WastageEntryBatchName);
                            if TempJournalBatchName.Get(ItemJournalTemplate, ItemJournalBatchName) Then;

                            //delete resveration entry
                            // TempItemJnlLine1.Reset();
                            // TempItemJnlLine1.SetRange("Journal Template Name", ItemJournalTemplate);
                            // TempItemJnlLine1.SetRange("Journal Batch Name", ItemJournalBatchName);
                            // TempItemJnlLine1.SetRange("Document No.", Rec."No."); //added document number
                            // IF TempItemJnlLine1.FindSet() then
                            //     Repeat
                            //         ScmCodeunit.DeleteReserverationLine(TempItemJnlLine1);
                            //     Until TempItemJnlLine1.Next() = 0;
                            // ///delete item jounal line
                            // TempItemJnlLine1.Reset();
                            // TempItemJnlLine1.SetRange("Journal Template Name", ItemJournalTemplate);
                            // TempItemJnlLine1.SetRange("Journal Batch Name", ItemJournalBatchName);
                            // TempItemJnlLine1.SetRange("Document No.", Rec."No."); //document No.
                            // IF TempItemJnlLine1.FindSet() then
                            //     TempItemJnlLine1.DeleteAll(true);

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
                                        ILE.SetCurrentKey("Entry No.");
                                        ILE1.SetRange("Item No.", TempItem."No.");
                                        ILE1.SetRange("Location Code", TempItemJnlLine."Location Code");
                                        ILE1.SetRange(Open, true);
                                        ILE1.SetFilter("Remaining Quantity", '>%1', 0);
                                        ILE1.SetFilter("Lot No.", '<>%1', '');
                                        IF ILE1.FindFirst() then
                                            repeat
                                                //qtyCount := qtyCount + (ILE1."Remaining Quantity" * ILE1."Qty. per Unit of Measure");
                                                qtyCount := qtyCount + (ILE1."Remaining Quantity");//ALLE-06092023
                                            Until ILE1.Next() = 0;
                                        If qtyCount < qty then
                                            Error('Qty available in Lot and Qty enter online is less , please reduce a qty available for item %1', TempItem."No.");

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
                                            IF ILE.FindFirst() then
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
                            //ALLE_NICK_130124
                            // TempILE.Reset();
                            // TempILE.SetRange(TempILE."Document No.", Rec."No.");
                            // if TempILE.FindFirst() then begin
                            Rec.Status := Rec.Status::Posted;
                            Rec.Modify();
                            //  CurrPage.Update();
                            Message('Wastage Entry Posted successfully');

                            //end;
                            /*
                                                      TempItemJnlLine1.Reset();
                                                      TempItemJnlLine1.SetRange("Journal Template Name", ItemJournalTemplate);
                                                      TempItemJnlLine1.SetRange("Journal Batch Name", ItemJournalBatchName);
                                                      TempItemJnlLine1.SetRange("Document No.", Rec."No."); //document No.
                                                      IF TempItemJnlLine1.FindSet() then;
                                                      IF TempItemJnlLine1.FindSet() then
                                                          TempItemJnlLine1.DeleteAll(true);
                             */
                            /*
                            TempWastageEntryLine.Reset();
                            TempWastageEntryLine.SetRange("DocumentNo.", Rec."No.");
                            IF TempWastageEntryLine.FindSet() then
                                repeat
                                    TempILE.Reset();
                                    TempILE.SetRange(TempILE."Item No.", TempWastageEntryLine."Item Code");
                                    TempILE.SetRange(TempILE."Document No.", TempWastageEntryLine."DocumentNo.");
                                    if TempILE.FindFirst() then begin
                                        TempWastageEntryLine.Status := TempWastageEntryLine.Status::Posted;
                                        TempWastageEntryLine.Modify();
                                    end;
                                Until TempWastageEntryLine.Next() = 0;
                            CurrPage.Update();

                            TempWastageEntryLine.Reset();
                            TempWastageEntryLine.SetRange("DocumentNo.", Rec."No.");
                            TempWastageEntryLine.SetFilter(TempWastageEntryLine.Status, '<>%1', TempWastageEntryLine.Status::Posted);
                            IF Not TempWastageEntryLine.FindFirst() then begin
                                Rec.Status := Rec.Status::Posted;
                                rec.Modify();
                            end;
                            CurrPage.Update();
                            Message('Wastge Entry Posted successfully');
                            */
                            // codeunit.Run(Codeunit::"Item Jnl.-Post Batch", TempItemJnlLine);
                            // codeunit.Run(Codeunit::"Item Jnl.-Post Batch",ItemJrnl) for Multiple Line
                            //codeunit.Run(Codeunit::"Item Jnl.-Post Line", ItemJrnl) single Line
                        end
                        Else
                            Error('status must be Approve before posting');
                    end;
                end;



            }

            action(SendForApproval)
            {
                ApplicationArea = all;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Enabled = IsSendforApprovalEnabled;
                Image = Process;
                trigger OnAction()
                var
                    tempusersetup: Record "User Setup";
                    totalWastageLine: Record WastageEntryLine;
                    TotalAmount: Decimal;
                    // tempitem: Record Item;
                    TempTransactionHeader: Record "LSC Transaction Header";
                    TempWastageEntryLine: Record WastageEntryLine;

                    TempItemJnlLine: Record "Item Journal Line";
                    TempItemJnlLine1: Record "Item Journal Line";
                    // TempWastageEntryLine: Record WastageEntryLine;
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
                    // TempTransactionHeader: Record "LSC Transaction Header";
                    TempUnitofUOM: Record "Item Unit of Measure";
                    qty: Decimal;
                    TodaysSales: Decimal;
                    TransHead: Record "LSC Transaction Header";
                    totalPercentageValue: Decimal;

                    EmailCodeunit: Codeunit Email;
                    Tempblob: Codeunit "Temp Blob";
                    IsStream: InStream;
                    OStream: OutStream;
                    UserSetup: Record "User Setup";
                    EmailMessage: Codeunit "Email Message";
                    currentuser: Record "User Setup";
                    MessageBody: Text;
                    MailList: List of [text];
                    RequestRunPage: text;

                    RecRef: RecordRef;
                    Subject: Text;

                    parma: Text;

                    //Dimension
                    DefaultDim: Record "Default Dimension";
                    GLSetup: Record "General Ledger Setup";

                    TempItemJnlLine6: Record "Item Journal Line";
                    LineNo: Integer;

                    ScmCodeunit: Codeunit AllSCMCustomization;
                    TempWastageEntryLineForlot: Record WastageEntryLine;
                    ItmJounNew: Record 83;
                    ItmJounNew1: Record 83;
                    Reserveration: Record "Reservation Entry";
                begin
                    CheckPostingDateAllowed(Rec);//PT-FBTS-16-09-2025
                    TestField(Status, Status::Open);//PT-FBTs 16-09-2025

                    TempWastageEntryLine.Reset();
                    TempWastageEntryLine.SetRange("DocumentNo.", "No.");
                    if not TempWastageEntryLine.FindFirst() then
                        Error('Please Create Wastage line');
                    /*
                    if (Rec."Posting date" < Rec."Created Date") then
                        Error('Posting Date should be grater than or equal to Created Date');
                    */
                    //Send PRD
                    ItmJounNew.SetFilter("Journal Template Name", 'ITEM');
                    // ItmJounNew.SetFilter("Journal Batch Name", '<>%1', 'SALE'); //ALLE-AS-19012024-Changed to sale
                    ItmJounNew.SetFilter("Journal Batch Name", '%1', 'WTENTRY');  //PT-FBTS   12-02-24
                    //ItmJounNew.SetRange("Location Code", rec."Location Code");
                    IF ItmJounNew.FindSet() then begin
                        repeat
                            if ItmJounNew."Journal Batch Name" <> 'DEFAULT' then
                                ItmJounNew.DeleteAll();
                        until ItmJounNew.Next() = 0;
                        Commit();
                    end;
                    //Send PRD
                    //Reserveration.SetRange("Location Code", rec."Location Code");
                    Reserveration.SetRange("Source Type", 83);
                    //Reserveration.SetFilter("Source Batch Name", '<>%1', 'SALE'); //ALLE-AS-20012024_var diff
                    Reserveration.SetFilter("Source Batch Name", '%1', 'WTENTRY'); //PT-FBTS                                                                 //Reserveration.SetRange(Positive, false);
                                                                                   //  Reserveration.SetRange("Location Code", rec."Location Code");
                    if Reserveration.FindSet() then begin //AJ_ALLE_23012024 +
                        repeat
                            Reserveration.DeleteAll();
                        until Reserveration.Next() = 0;
                        Commit();
                    end; //AJ_ALLE_23012024 -
                    if tempusersetup.get(UserId) then;
                    /*
                    if (Rec."Posting date" < Rec."Created Date") then
                        Error('Posting Date should be grater than or equal to Created Date');
                        */
                    TempWastageEntryLine.Reset();
                    TempWastageEntryLine.SetRange("DocumentNo.", Rec."No.");
                    TempWastageEntryLine.SetFilter("Reason Code", '=%1', '');
                    IF TempWastageEntryLine.FindFirst() then begin
                        Error('Reason code must have value in Line No. %1', TempWastageEntryLine."LineNo.");
                    end;


                    TempWastageEntryLine.Reset();
                    TempWastageEntryLine.SetRange("DocumentNo.", Rec."No.");
                    TempWastageEntryLine.SetFilter(Quantity, '%1', 0);
                    IF TempWastageEntryLine.FindFirst() then begin
                        Error('Please enter Quantity for. %1..%2', TempWastageEntryLine."Item Code", TempWastageEntryLine.Description);
                    end;
                    //ALLE_NICK_11/1/23_LotFix
                    // TempWastageEntryLineForlot.Reset();//Old Code comment //16-09-26
                    // TempWastageEntryLineForlot.SetRange("DocumentNo.", Rec."No.");
                    // IF TempWastageEntryLineForlot.FindSet() then begin
                    //     repeat
                    //         QTYvalidate(TempWastageEntryLineForlot, rec."Posting date")
                    //     until TempWastageEntryLineForlot.Next() = 0
                    // end;//Old Code comment //16-09-26
                    IF NOT tempusersetup.SkipEODValidation then begin
                        TempTransactionHeader.Reset();
                        TempTransactionHeader.SetRange(TempTransactionHeader.Date, Rec."Posting date");
                        TempTransactionHeader.SetRange(TempTransactionHeader."Store No.", Rec."Location Code");
                        TempTransactionHeader.SetFilter(TempTransactionHeader."Transaction Type", '=%1', TempTransactionHeader."Transaction Type"::Sales);
                        TempTransactionHeader.SetFilter(TempTransactionHeader."Posted Statement No.", '=%1', '');
                        TempTransactionHeader.SetFilter(TempTransactionHeader."Entry Status", '<>%1&<>%2', TempTransactionHeader."Entry Status"::Voided, TempTransactionHeader."Entry Status"::Training);
                        IF TempTransactionHeader.FindFirst() then
                            Error('Statement posting has not finsihed for this date %1. Please post statement first', Format(Rec."Posting date"));
                    end;
                    TotalAmount := 0;
                    TodaysSales := 0;
                    totalPercentageValue := 0;
                    IF Confirm('Do you want to submit this order for approval?', true) then begin
                        IF Rec.Status = Rec.Status::Open then begin
                            TempWastageEntryLineForlot.Reset(); //adding hear//PT-FBTS-16-9-25
                            TempWastageEntryLineForlot.SetRange("DocumentNo.", Rec."No.");
                            IF TempWastageEntryLineForlot.FindSet() then begin
                                repeat
                                    QTYvalidate(TempWastageEntryLineForlot, rec."Posting date")
                                until TempWastageEntryLineForlot.Next() = 0
                            end;//adding hear//PT-FBTS-16-9-25
                            totalWastageLine.Reset();
                            totalWastageLine.SetRange(totalWastageLine."DocumentNo.", rec."No.");
                            IF totalWastageLine.FindSet() then
                                repeat
                                    if tempitem.get(totalWastageLine."Item Code") then;
                                    TotalAmount := TotalAmount + (totalWastageLine.Amount);

                                until totalWastageLine.Next() = 0;

                            TransHead.Reset();
                            TransHead.SetRange(TransHead.Date, Rec."Posting date");
                            TransHead.SetRange("Store No.", Rec."Location Code");
                            TransHead.SetRange("Transaction Type", TransHead."Transaction Type"::Sales);
                            TransHead.SetRange("Sale Is Return Sale", false);
                            IF TransHead.FindSet() then Begin
                                repeat
                                    TodaysSales := TodaysSales + ABS(TransHead."Gross Amount");
                                until TransHead.next() = 0;
                            End;


                            totalPercentageValue := Round(((tempusersetup.WastageEntryLimit * TodaysSales) / 100), 1, '=');
                            if ((TotalAmount > totalPercentageValue) and (tempusersetup.WastageEntryApprover <> UserId)) then begin
                                Rec.Status := Rec.Status::PendingApproval;
                                Rec.Modify();

                                //to send a mail for wastageEntry approval
                                //MailList.Add('mahendra.patil@in.ey.com');
                                Subject := 'Wastage Entry ' + Rec."No." + 'Pending approval';
                                MessageBody := 'Dear Approver, ' + '<br><br> This Document No. ' + Rec."No." + ' is pending for approval. The reason for approval is amount ' + Format(TotalAmount) + ' exceeded allowed Limit of ' + Format(totalPercentageValue) + '<br><br>' + 'https://erptwc.thirdwavecoffee.in/BC220/?company=HBPL&page=50076&dc=0' +
                                '<br><br>' + 'Regards' + '<br><br>' + 'IT - Team.';
                                EmailMessage.Create(tempusersetup.WastageEntryNotification, Subject, MessageBody, true);
                                EmailCodeunit.Send(EmailMessage);
                                //end
                            end
                            else begin

                                Rec.Status := Rec.Status::Approved;
                                Rec.Modify();

                                // CurrPage.Update();
                                //code for auto post if auto approved
                                //start
                                IF Confirm('Order is auto approved Are you sure to submit the Wastage Entry? You will not be able to modify after submitting.', true) then begin
                                    IF Rec.Status = Rec.Status::Approved then begin
                                        InventSetup.Get();
                                        ItemJournalTemplate := InventSetup.WastageEntryTemplateName;
                                        ItemJournalBatchName := InventSetup.WastageEntryBatchName;
                                        InventSetup.TestField(InventSetup.WastageEntryTemplateName);
                                        InventSetup.TestField(InventSetup.WastageEntryBatchName);
                                        if TempJournalBatchName.Get(ItemJournalTemplate, ItemJournalBatchName) Then;
                                        //delete resveration entry
                                        // TempItemJnlLine1.Reset();
                                        // TempItemJnlLine1.SetRange("Journal Template Name", ItemJournalTemplate);
                                        // TempItemJnlLine1.SetRange("Journal Batch Name", ItemJournalBatchName);
                                        // TempItemJnlLine1.SetRange("Document No.", Rec."No."); //added document number
                                        // IF TempItemJnlLine1.FindSet() then
                                        //     Repeat
                                        //         ScmCodeunit.DeleteReserverationLine(TempItemJnlLine1);
                                        //     Until TempItemJnlLine1.Next() = 0;

                                        // TempItemJnlLine1.Reset();
                                        // TempItemJnlLine1.SetRange("Journal Template Name", ItemJournalTemplate);
                                        // TempItemJnlLine1.SetRange("Journal Batch Name", ItemJournalBatchName);
                                        // TempItemJnlLine1.SetRange("Document No.", Rec."No."); //document No.
                                        // IF TempItemJnlLine1.FindFirst() then
                                        //     TempItemJnlLine1.DeleteAll(true);

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

                                               //dimesion 3
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
                                                //ALLE_NICK_11/1/23_LotFix
                                                //  IF TempItem."Item Tracking Code" <> '' then begin
                                                //     qtyCount := 0;

                                                //     ILE1.Reset();
                                                //     ILE1.SetCurrentKey("Entry No.");
                                                //     ILE1.SetRange("Item No.", TempItem."No.");
                                                //     ILE1.SetRange("Location Code", TempItemJnlLine."Location Code");
                                                //     ILE1.SetRange(Open, true);
                                                //     ILE1.SetFilter("Remaining Quantity", '>%1', 0); //Code optimisation need to be check
                                                //    ILE1.SetFilter("Lot No.", '<>%1', '');
                                                //    IF ILE1.FindFirst() then
                                                //        repeat
                                                //          //qtyCount := qtyCount + (ILE1."Remaining Quantity" * ILE1."Qty. per Unit of Measure");
                                                //       qtyCount := qtyCount + (ILE1."Remaining Quantity"); //ALLE-06092023
                                                //      Until ILE1.Next() = 0;
                                                //   If qtyCount < qty then
                                                //        Error('Qty avaliable in Lot and Qty enter online is less , please redure a qty available for Item No %1', TempItem."No.");

                                                //   End;

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
                                        //ALLE_NICK_130123
                                        // TempILE.Reset();
                                        // TempILE.SetRange(TempILE."Document No.", Rec."No.");
                                        // if TempILE.FindFirst() then begin

                                        Rec.Status := Rec.Status::Posted;
                                        Rec.Modify();
                                        // CurrPage.Update();
                                        Message('Wastage Entry Posted successfully');

                                        // end;
                                        /*
                                                                            TempItemJnlLine1.Reset();
                                                                                TempItemJnlLine1.SetRange("Journal Template Name", ItemJournalTemplate);
                                                                                TempItemJnlLine1.SetRange("Journal Batch Name", ItemJournalBatchName);
                                                                                TempItemJnlLine1.SetRange("Document No.", Rec."No."); //document No.
                                                                                IF TempItemJnlLine1.FindSet() then
                                                                                    TempItemJnlLine1.DeleteAll(true);
                                         */
                                        /*
                                        TempWastageEntryLine.Reset();
                                        TempWastageEntryLine.SetRange("DocumentNo.", Rec."No.");
                                        IF TempWastageEntryLine.FindSet() then
                                            repeat
                                                TempILE.Reset();
                                                TempILE.SetRange(TempILE."Item No.", TempWastageEntryLine."Item Code");
                                                TempILE.SetRange(TempILE."Document No.", TempWastageEntryLine."DocumentNo.");
                                                if TempILE.FindFirst() then begin
                                                    TempWastageEntryLine.Status := TempWastageEntryLine.Status::Posted;
                                                    TempWastageEntryLine.Modify();
                                                end;
                                            Until TempWastageEntryLine.Next() = 0;
                                        CurrPage.Update();

                                        TempWastageEntryLine.Reset();
                                        TempWastageEntryLine.SetRange("DocumentNo.", Rec."No.");
                                        TempWastageEntryLine.SetFilter(TempWastageEntryLine.Status, '<>%1', TempWastageEntryLine.Status::Posted);
                                        IF Not TempWastageEntryLine.FindFirst() then begin
                                            Rec.Status := Rec.Status::Posted;
                                            rec.Modify();
                                        end;
                                        CurrPage.Update();
                                        Message('Wastge Entry Posted successfully');
                                        */
                                        // codeunit.Run(Codeunit::"Item Jnl.-Post Batch", TempItemJnlLine);
                                        // codeunit.Run(Codeunit::"Item Jnl.-Post Batch",ItemJrnl) for Multiple Line
                                        //codeunit.Run(Codeunit::"Item Jnl.-Post Line", ItemJrnl) single Line
                                    end
                                    Else
                                        Error('status must be Approve before posting');
                                end;




                                //end



                            end;
                            IsSendforApprovalEnabled := False;
                            /*
                              if UserId = tempusersetup.WastageEntryApprover then
                                  Rec.Status := Rec.Status::Approved
                              Else
                                  Rec.Status := Rec.Status::PendingApproval;
                             */
                            //     CurrPage.Editable(false);

                            //  Message();
                            CurrPage.Close();

                        end else
                            Error('Order Status must be open');
                    end;
                end;



            }

            action(Reopen)
            {
                ApplicationArea = all;

                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                // Enabled = IsSendforApprovalEnabled;
                Image = Process;
                trigger OnAction()
                var
                    tempusersetup: Record "User Setup";
                    totalWastageLine: Record WastageEntryLine;
                    TotalAmount: Decimal;
                    tempitem: Record Item;

                begin

                    IF Confirm('Do you want to Re-open this document for changes', true) then begin

                        IF Rec.RejectionRemark <> '' Then
                            Error('It is not allowd top reopen rejected document');
                        Rec.Status := rec.Status::Open;
                        Rec.Validate(Rec.Status);
                        Rec.Modify();
                        IsWastageLinesEditable := true;
                        IsSendforApprovalEnabled := true;
                        CurrPage.Update(true);
                        Message('Changes done successfully, you can proceed with reopening of document');
                        CurrPage.Close();





                    end;
                end;

            }

        }
    }
    var
        [InDataSet]
        IsWastageLinesEditable: Boolean;

        [InDataSet]
        IsSendforApprovalEnabled: Boolean;


        IsWastageHeaderEditable: Boolean;

    trigger OnOpenPage()
    begin
        ActivateFields();
        if Rec.Status = Rec.Status::Open then Begin
            CurrPage.Editable(true);
        End
        Else
            CurrPage.Editable(False);
    end;

    trigger OnAfterGetRecord()
    begin
        if Rec.Status = Rec.Status::Open then Begin
            CurrPage.Editable(true);
        End
        Else
            CurrPage.Editable(False);
    end;

    trigger OnAfterGetCurrRecord()
    begin
        if Rec.Status = Rec.Status::Open then Begin
            CurrPage.Editable(true);
        End
        Else
            CurrPage.Editable(False);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        if Rec.Status = Rec.Status::Open then Begin
            CurrPage.Editable(true);
        End
        Else
            CurrPage.Editable(False);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        tempWastageHeader: Record WastageEntryHeader;
        tempusersetup: Record "User Setup";
    begin
        /*
        if tempusersetup.get(UserId) then;
        tempWastageHeader.Reset();
        tempWastageHeader.SetRange("Posting date", Today);
        tempWastageHeader.SetRange("Location Code", 'BLUE');
        if tempWastageHeader.FindFirst() then begin
            error('You can only craete one watage entry record per day per location')
        end;
       */


    end;

    local procedure ActivateFields()
    begin
        IsWastageLinesEditable := Rec.WastageEntryLineEditable();



        if Rec.Status = Rec.Status::open then begin
            IsWastageHeaderEditable := true;
        end
        else
            IsWastageHeaderEditable := False;

        if Rec.Status = Rec.Status::open then begin
            IsSendforApprovalEnabled := true;
        end
        else
            IsSendforApprovalEnabled := False;

    end;
    //ALLE_NICK_11/1/23_LotFix
    //start
    local procedure QTYvalidate(WastageLine: Record WastageEntryLine; DATE: Date)
    var
        TempItem: Record Item;

        ILE1: Record "Item Ledger Entry";
        Postingdate: text;
        InvSetUp: Record "Inventory Setup";
        resecU: Codeunit 99000845;
        AssingQty: Decimal;
    begin
        WastageLine.CalcFields("Stock in hand");
        If WastageLine."Stock in hand" < WastageLine.Quantity then begin
            AssingQty := WastageLine."Stock in hand" - WastageLine.Quantity;
            if InvSetUp.Get() then
                if InvSetUp."Wastage Post. Allow" then begin
                    Evaluate(Postingdate, Format(date));
                    CreateIJL(WastageLine, Postingdate, AssingQty);
                end
                else
                    Error('You have insufficient inventory of %1', WastageLine."Item Code");//PT-FBTS-16-0925
                                                                                            //Error('Inventory is not avaliable for this Item, please reduce a qty for Item No %1', WastageLine."Item Code");
        end;


    end;

    procedure CheckPostingDateAllowed(WastageHeader: Record WastageEntryHeader)
    var
        UserSetup: Record "User Setup";
        LocationRec: Record Location;
    begin
        // Step 1: Get User Setup
        if UserSetup.Get(UserId) then;

        if (UserSetup."Allow Posting From" <> 0D) and
           (WastageHeader."Posting date" < UserSetup."Allow Posting From") then
            Error(
              'Posting Date %1 is before the allowed posting date %2',
              WastageHeader."Posting date", UserSetup."Allow Posting From");


        if (UserSetup."Allow Posting To" <> 0D) and
           (WastageHeader."Posting date" > UserSetup."Allow Posting To") then
            Error(
              'Posting Date %1 is after the allowed posting date %2',
              WastageHeader."Posting date", UserSetup."Allow Posting To", UserSetup."Location Code");
    end;


    local procedure CreateIJL(WASTAGELINE: Record WastageEntryLine; DTLocal: Text; Qty: Decimal)
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
            IJLine.VALIDATE(Quantity, Abs(Qty));
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