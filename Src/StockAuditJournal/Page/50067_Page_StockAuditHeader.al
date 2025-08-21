page 50067 StockAuditHeader
{
    PageType = Document;

    SourceTable = StockAuditHeader;
    Caption = 'Inventory Counting Card';
    PromotedActionCategories = 'New," "," ",Process,Approval';
    RefreshOnActivate = true;



    layout
    {

        area(Content)
        {

            group(General)
            {

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    //Editable = false;//PT-FBTS
                    trigger OnAssistEdit()
                    begin
                        if AssistEdit(xRec) then
                            CurrPage.Update();
                    end;

                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = ALL;

                }
                field("Posting Date"; Rec."Posting date")
                {
                    ApplicationArea = all;
                    trigger OnValidate()  //PT-FBTS 30-07-2024
                    var
                        StockAuditLineRec: Record StockAuditLine;
                    begin
                        StockAuditLineRec.Reset();
                        StockAuditLineRec.SetRange("DocumentNo.", Rec."No.");
                        StockAuditLineRec.SetRange("Location Code", Rec."Location Code");
                        if StockAuditLineRec.FindFirst() then
                            repeat
                                StockAuditLineRec.Validate("Posting Date", Rec."Posting date");
                                StockAuditLineRec.Modify();
                            until StockAuditLineRec.Next() = 0;
                    end;

                }



                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Editable = false;

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
                field(TotalStockValue; Rec.TotalStockValue)
                {
                    ApplicationArea = All;
                    Caption = 'TotalStockValue';
                    Editable = false;
                    Visible = false;
                }
                field(RejectionRemark; Rec.RejectionRemark)
                {
                    ApplicationArea = All;

                    Caption = 'Rejection Remark';
                    Editable = false;
                }
                field("Inventory Type"; "Inventory Type")
                {
                    ApplicationArea = All;
                    Caption = 'Inventory Type';
                    Editable = false;
                }
                field("Sand Date&Time"; "Sand Date&Time")
                {
                    ApplicationArea = All;
                    Editable = false;

                }


            }


            part(StockLine; StockAuditSubform)
            {
                ApplicationArea = all;
                SubPageLink = "DocumentNo." = field("No.");
                UpdatePropagation = Both;
                Editable = IsStockLinesEditable;


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
                Visible = ViseblePost;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = Process;
                trigger OnAction()
                var
                    TempItemJnlLine: Record "Item Journal Line";
                    TempItemJnlLine1: Record "Item Journal Line";
                    TempStockAuditLine: Record StockAuditLine;
                    Cutofftime: DateTime;
                    TempJournalBatchName: Record "Item Journal Batch";
                    NoSeriesMgmt: Codeunit NoSeriesManagement;
                    TempItem: Record Item;
                    DocNo: Code[20];
                    TempILE: Record "Item Ledger Entry";
                    tempusersetup: Record "User Setup";
                    tempDate: Date;
                    //Auto lot assignment
                    StockAuditCodeunit: Codeunit AllSCMCustomization;
                    ILE: Record "Item Ledger Entry";
                    TotalQty: Decimal;
                    qty_qtyBase: Decimal;
                    TotalQtytoShipBase: Decimal;
                    TotalQtytoReceiveBase: Decimal;
                    ILE1: Record "Item Ledger Entry";
                    qtyCount: Decimal;
                    Invetsetup: Record "Inventory Setup";
                    ItemJournalName: Code[10];
                    ItemJournalBatchName: Code[10];
                    TempTransactionHeader: Record "LSC Transaction Header";
                    TempStockAuditLine5: Record StockAuditLine;
                    //Dimension
                    DefaultDim: Record "Default Dimension";
                    GLSetup: Record "General Ledger Setup";

                    TempItemJnlLine6: Record "Item Journal Line";
                    LineNo: Integer;

                    ScmCodeunit: Codeunit AllSCMCustomization;
                    Stockline2: Record StockAuditLine;
                    Recitem: Record Item;
                    TempUsersetup2: Record "User Setup";
                    NetchangeQty: Decimal;
                    Stockline3: Record StockAuditLine;
                    countline: Integer;
                    Stockline: Record StockAuditLine;
                    ItmJounNew: Record 83;
                    ItmJounNew1: Record 83;
                    Reserveration: Record "Reservation Entry";
                    StocklineQty: Record StockAuditLine;

                begin
                    //ALLE_NICK_160124
                    ItmJounNew.SetFilter("Journal Template Name", 'ITEM');
                    ItmJounNew.SetFilter("Journal Batch Name", '<>%1', 'SALE');
                    //STOCKAUDIT //ALLE-AS-19012024_Changed to sale
                    //    ItmJounNew.SetFilter("Journal Batch Name", '<>%1', 'STOCKAUDIT');//FBTS
                    // ItmJounNew.SetRange("Location Code", Rec."Location Code");
                    IF ItmJounNew.FindSet() then begin
                        repeat
                            if ItmJounNew."Journal Batch Name" <> 'DEFAULT' then
                                ItmJounNew.DeleteAll();
                        until ItmJounNew.Next() = 0;
                        Commit();
                    end;

                    Reserveration.SetRange("Source Type", 83);
                    Reserveration.SetFilter("Source Batch Name", '%1', 'STOCKAUDIT');
                    // Reserveration.SetRange("Location Code", Rec."Location Code");
                    //Reserveration.SetRange(Positive, false);
                    if Reserveration.FindSet() then begin //AJ_ALLE_23012024 +
                        repeat
                            Reserveration.DeleteAll();
                        until Reserveration.Next() = 0;
                        Commit();
                    end;  //AJ_ALLE_23012024 -
                    //ALLE_NICK_160124
                    Stockline3.SetRange("DocumentNo.", Rec."No.");
                    Stockline3.SetFilter(StockQty, '%1', 0);
                    if Stockline3.FindSet() then begin
                        Stockline3.Validate(StockQty);
                        countline := Stockline3.Count;
                    end;
                    if Confirm('%1 of items Physical Qty In-hand is Zero, do you want to continue', true, countline) then begin
                        //ALLE_NICK_120124
                        Stockline2.SetRange("DocumentNo.", rec."No.");
                        if Stockline2.FindSet() then begin
                            repeat
                                NetchangeQty := 0;
                                IF TempUsersetup2.get(UserId) then;
                                Recitem.SetRange("No.", Stockline2."Item Code");
                                Recitem.SetRange("Date Filter", 0D, rec."Posting date");
                                Recitem.SetFilter("Location Filter", rec."Location Code");
                                if Recitem.findfirst then
                                    Recitem.CalcFields("Net Change");
                                NetchangeQty := Recitem."Net Change";
                                Stockline2."Qty. (Calculated)" := NetchangeQty;
                                // Stockline2.Validate("Qty. (Calculated)", NetchangeQty);

                                //As Per Req + //AJ_ALLE_29012024
                                Stockline2.Quantity := 0;
                                if Stockline2."Qty. (Phys. Inventory)" >= Stockline2."Qty. (Calculated)" then begin
                                    Stockline2.Validate("Entry Type", Stockline2."Entry Type"::"Positive Adjmt.");
                                    Stockline2.Validate(Quantity, Stockline2."Qty. (Phys. Inventory)" - Stockline2."Qty. (Calculated)");
                                end else begin
                                    Stockline2.Validate("Entry Type", Stockline2."Entry Type"::"Negative Adjmt.");
                                    Stockline2.Validate(Quantity, Stockline2."Qty. (Calculated)" - Stockline2."Qty. (Phys. Inventory)");
                                end;
                                //As Per Req -//AJ_ALLE_29012024

                                Stockline2.Modify();
                            until Stockline2.Next() = 0;
                        end;
                        // Stockline.SetRange("DocumentNo.", rec."No.");
                        // if Stockline.FindSet() then begin
                        //     repeat
                        //         QTYvalidate(Stockline, Today);
                        //     until Stockline.Next() = 0;
                        // end;

                        if tempusersetup.get(UserId) then;

                        IF Rec."Posting date" > Today then
                            Error('Future posting not allowed');

                        IF Rec."Posting date" < Today then begin
                            IF tempusersetup.AearManger then begin
                                tempDate := CalcDate('<-' + tempusersetup.BackPostingAllowInDays + '>', Today);

                                IF Rec."Posting date" < tempDate then
                                    Error('Backdated posting not allowed');
                            end
                            Else
                                Error('Back dated posting not allowed');
                        end;

                        TempStockAuditLine5.Reset();
                        TempStockAuditLine5.SetRange("DocumentNo.", Rec."No.");
                        TempStockAuditLine5.SetFilter(TempStockAuditLine5."Entry Type", '=%1', TempStockAuditLine5."Entry Type"::"Negative Adjmt.");
                        IF TempStockAuditLine5.FindFirst() then begin

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
                        end;

                        IF Confirm('Are you sure to submit the stock Audit Entry? You will not be able to modify after submitting.', true) then begin
                            IF Rec.Status = Rec.Status::Approved then begin
                                Invetsetup.get;
                                ItemJournalName := Invetsetup.StockAuditTemplateName;
                                ItemJournalBatchName := Invetsetup.StockAuditBatchName;
                                Invetsetup.TestField(Invetsetup.StockAuditTemplateName);
                                Invetsetup.TestField(Invetsetup.StockAuditBatchName);


                                if TempJournalBatchName.Get(ItemJournalName, ItemJournalBatchName) Then;


                                //delete resveration entry
                                TempItemJnlLine1.Reset();
                                TempItemJnlLine1.SetRange("Journal Template Name", ItemJournalName);
                                TempItemJnlLine1.SetRange("Journal Batch Name", ItemJournalBatchName);
                                TempItemJnlLine1.SetRange("Document No.", Rec."No."); //added document number
                                IF TempItemJnlLine1.FindSet() then
                                    Repeat
                                        ScmCodeunit.DeleteReserverationLine(TempItemJnlLine1);
                                    Until TempItemJnlLine1.Next() = 0;

                                TempItemJnlLine1.Reset();
                                TempItemJnlLine1.SetRange("Journal Template Name", ItemJournalName);
                                TempItemJnlLine1.SetRange("Journal Batch Name", ItemJournalBatchName);
                                TempItemJnlLine1.SetRange("Document No.", Rec."No."); //added document number
                                IF TempItemJnlLine1.FindSet() then
                                    TempItemJnlLine1.DeleteAll(true);
                                ///delete item jounal line
                             //ALLE-AS-19012024
                                Stockline.SetRange("DocumentNo.", rec."No.");
                                if Stockline.FindSet() then begin
                                    repeat
                                        QTYvalidate(Stockline, Today);
                                    until Stockline.Next() = 0;
                                end;
                                ///////
                                //ALLE_NICK_210224........FORQUANTITY
                                StocklineQty.SetRange("DocumentNo.", rec."No.");
                                if StocklineQty.FindSet() then begin
                                    repeat
                                        CheckQty(StocklineQty)
                                    until StocklineQty.Next() = 0;
                                end;

                                //ALLE-AS-19012024
                                TempStockAuditLine.Reset();
                                TempStockAuditLine.SetRange("DocumentNo.", Rec."No.");
                                TempStockAuditLine.SetFilter(Quantity, '>%1', 0);

                                IF TempStockAuditLine.FindSet() then begin
                                    repeat
                                        TempItemJnlLine.Init();
                                        TempItemJnlLine."Journal Template Name" := ItemJournalName;
                                        TempItemJnlLine."Journal Batch Name" := ItemJournalBatchName;

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
                                        //TempItemJnlLine.Validate(TempItemJnlLine."Document No.");

                                        //Message(TempItemJnlLine."Document No.");

                                        TempItemJnlLine."Posting Date" := Rec."Posting date";
                                        TempItemJnlLine.Validate(TempItemJnlLine."Posting Date");

                                        TempItemJnlLine."Entry Type" := TempStockAuditLine."Entry Type";
                                        TempItemJnlLine.Validate(TempItemJnlLine."Entry Type");


                                        TempItemJnlLine."Item No." := TempStockAuditLine."Item Code";
                                        // Message(TempItemJnlLine."Item No.");
                                        TempItemJnlLine.Validate(TempItemJnlLine."Item No.");
                                        //  Message(TempItemJnlLine."Item No.");                                    

                                        IF TempItem.Get(TempItemJnlLine."Item No.") then;
                                        TempItemJnlLine."Gen. Prod. Posting Group" := TempItem."Gen. Prod. Posting Group";
                                        TempItemJnlLine.Validate(TempItemJnlLine."Gen. Prod. Posting Group");

                                        TempItemJnlLine."Document Date" := Rec."Posting date";
                                        TempItemJnlLine.Validate(TempItemJnlLine."Document Date");

                                        TempItemJnlLine."Location Code" := Rec."Location Code";
                                        TempItemJnlLine.Validate(TempItemJnlLine."Location Code");
                                        TempItemJnlLine."Source Code" := TempStockAuditLine."Source Code";
                                        TempItemJnlLine.Validate(TempItemJnlLine."Source Code");

                                        // TempItemJnlLine."Phys. Inventory" := TempStockAuditLine."Phys. Inventory";

                                        //   TempItemJnlLine."Qty. (Phys. Inventory)" := TempStockAuditLine."Qty. (Phys. Inventory)";
                                        // TempItemJnlLine.Validate(TempItemJnlLine."Qty. (Phys. Inventory)");

                                        //TempItemJnlLine."Qty. (Calculated)" := TempStockAuditLine."Qty. (Calculated)";
                                        // TempItemJnlLine.Validate(TempItemJnlLine."Qty. (Calculated)");
                                        TempItemJnlLine.Quantity := TempStockAuditLine.Quantity;
                                        TempItemJnlLine.Validate(TempItemJnlLine.Quantity);
                                        TempItemJnlLine."Unit Cost" := TempStockAuditLine.UnitPrice;

                                        TempItemJnlLine.Amount := TempStockAuditLine.Amount;
                                        TempItemJnlLine.Validate(TempItemJnlLine."Unit Cost");
                                        TempItemJnlLine.Validate(TempItemJnlLine.Amount);
                                        TempItemJnlLine."Reason Code" := TempStockAuditLine."Reason Code";
                                        //Validation for insuffient qty 
                                        IF TempItem."Item Tracking Code" <> '' then begin
                                            IF TempItemJnlLine."Entry Type" = TempItemJnlLine."Entry Type"::"Negative Adjmt." then begin
                                                qtyCount := 0;
                                                //AJ_ALLE_16102023

                                                ILE.Reset();
                                                ILE.SetCurrentKey("Item No.", "Location Code");
                                                ILE.SetRange("Item No.", TempItem."No.");
                                                ILE.SetRange("Location Code", TempItemJnlLine."Location Code");
                                                //IF ILE.FindSet() then begin
                                                ILE.CalcSums(Quantity);
                                                qtyCount := ILE.Quantity;

                                                // ILE.SetCurrentKey("Item No.", "Location Code");
                                                // ILE.SetRange("Item No.", TempItem."No.");
                                                // ILE.SetRange("Location Code", TempItemJnlLine."Location Code");
                                                // //IF ILE.FindSet() then begin
                                                // ILE.CalcSums(Quantity);
                                                // qtyCount := ILE.Quantity;
                                                //AJ_ALLE_16102023
                                                If qtyCount < TempItemJnlLine.Quantity then
                                                    Error('Qty available in Lot for item No. %1 , please reduce a qty available', TempItem."No.");
                                            end;
                                        End;
                                        //Validation end
                                        /*Commenting as validting dimesion on location code
                                           // Message(Format(TempItemJnlLine.Quantity));
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
                                           //Dimesion 3 Departmet code
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

                                        TempItemJnlLine.Insert(true);

                                        //  Message('inseted');
                                        Commit();

                                        //For AutoLotAssignmemnt
                                        IF TempItem."Item Tracking Code" <> '' then begin
                                            IF TempItemJnlLine."Entry Type" = TempItemJnlLine."Entry Type"::"Negative Adjmt." then begin
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
                                                                StockAuditCodeunit.stockauditReservationEntry(TempItemJnlLine, ILE."Lot No.",
                                                                TotalQty, qty_qtyBase, TotalQtytoShipBase, TotalQtytoReceiveBase, ILE."Expiration Date");
                                                                TotalQty := 0;
                                                                TotalQtytoReceiveBase := 0;
                                                                TotalQtytoReceiveBase := 0;
                                                            end else
                                                                if (ILE."Remaining Quantity" < TotalQty) then begin
                                                                    qty_qtyBase := ILE."Remaining Quantity" * TempItemJnlLine."Qty. per Unit of Measure";
                                                                    StockAuditCodeunit.stockauditReservationEntry(TempItemJnlLine, ILE."Lot No.", ILE."Remaining Quantity",
                                                                   qty_qtyBase, qty_qtyBase, qty_qtyBase, ILE."Expiration Date");
                                                                    TotalQty := TotalQty - ILE."Remaining Quantity";
                                                                    TotalQtytoShipBase := TotalQtytoShipBase - qty_qtyBase;
                                                                    TotalQtytoReceiveBase := TotalQtytoReceiveBase - qty_qtyBase
                                                                end;
                                                        End;
                                                    Until ILE.Next() = 0;
                                            End;

                                            IF TempItemJnlLine."Entry Type" = TempItemJnlLine."Entry Type"::"Positive Adjmt." then begin
                                                StockAuditCodeunit.StockAuditPostiveAdjreservationEntry(TempItemJnlLine);
                                            end;

                                        end;
                                    Until TempStockAuditLine.Next() = 0;
                                End Else Begin
                                    Rec.Status := Rec.Status::Posted;
                                    Rec.Modify();
                                    CurrPage.Update();
                                    Message('Stock Audit  Posted successfully');
                                End;

                                TempItemJnlLine1.Reset();
                                TempItemJnlLine1.SetRange("Journal Template Name", ItemJournalName);
                                TempItemJnlLine1.SetRange("Journal Batch Name", ItemJournalBatchName);
                                TempItemJnlLine1.SetRange("Document No.", Rec."No."); //added for document no.
                                IF TempItemJnlLine1.FindSet() then;
                                IF TempItemJnlLine1.Count() > 0 Then
                                    CODEUNIT.Run(CODEUNIT::"Item Jnl.-Post", TempItemJnlLine1); //for test


                                /*
                                 TempStockAuditLine.Reset();
                                 TempStockAuditLine.SetRange("DocumentNo.", Rec."No.");
                                 IF TempStockAuditLine.FindSet() then
                                     repeat
                                         TempILE.Reset();
                                         TempILE.SetRange(TempILE."Item No.", TempStockAuditLine."Item Code");
                                         TempILE.SetRange(TempILE."Document No.", TempStockAuditLine."DocumentNo.");
                                         if TempILE.FindFirst() then begin

                                             TempStockAuditLine.Status := TempStockAuditLine.Status::Posted;
                                             TempStockAuditLine.Modify();

                                         end;
                                     Until TempStockAuditLine.Next() = 0;

                                 CurrPage.Update();

                                 TempStockAuditLine.Reset();
                                 TempStockAuditLine.SetRange("DocumentNo.", Rec."No.");
                                 TempStockAuditLine.SetFilter(TempStockAuditLine.Status, '<>%1', TempStockAuditLine.Status::Posted);
                                 IF Not TempStockAuditLine.FindFirst() then begin
                                     Rec.Status := Rec.Status::Posted;
                                     rec.Modify();

                                 end;
                                 */

                                TempILE.Reset();
                                TempILE.SetRange(TempILE."Document No.", Rec."No.");
                                if TempILE.FindFirst() then begin

                                    Rec.Status := Rec.Status::Posted;
                                    Rec.Modify();
                                    CurrPage.Update();
                                    Message('Stock Audit  Posted successfully');

                                end;
                                /*
                                 TempItemJnlLine1.Reset();
                                 TempItemJnlLine1.SetRange("Journal Template Name", ItemJournalName);
                                 TempItemJnlLine1.SetRange("Journal Batch Name", ItemJournalBatchName);
                                 TempItemJnlLine1.SetRange("Document No.", Rec."No."); ///added for document no
                                 IF TempItemJnlLine1.FindSet() then
                                     TempItemJnlLine1.DeleteAll(true);
                                     */

                                // codeunit.Run(Codeunit::"Item Jnl.-Post Batch", TempItemJnlLine);
                                // codeunit.Run(Codeunit::"Item Jnl.-Post Batch",ItemJrnl) for Multiple Line
                                //codeunit.Run(Codeunit::"Item Jnl.-Post Line", ItemJrnl) single Line
                            end
                            Else
                                Error('status must be Approve before posting');
                        end;
                    end;
                End;



            }

            action(SendForApproval)
            {
                ApplicationArea = all;

                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = Process;
                trigger OnAction()
                var
                    tempusersetup: Record "User Setup";
                    totalStockLine: Record StockAuditLine;
                    TotalAmount: Decimal;
                    tempitem: Record Item;
                    TransSalesEntry: Record "LSC Trans. Sales Entry";
                    TodaysSales: Decimal;
                    //TransSalesEntry: Record "LSC Trans. Sales Entry";
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
                    TransHead: Record "LSC Transaction Header";
                    Stockline2: Record StockAuditLine;
                    Recitem: Record Item;
                    TempUsersetup2: Record "User Setup";
                    NetchangeQty: Decimal;
                    Stockline3: Record StockAuditLine;
                    countline: Integer;
                    Stockline: Record StockAuditLine;

                begin
                    TempUsersetup2.Get(UserId); //PT-FBTS
                    if TempUsersetup2."inventory Controller" = false then begin
                        if (Rec."Posting date" <> Today) and (Rec."Posting date" <> Today - 1) then
                            Error('Backdated Entry can not be Send for Approval');
                    end;
                    //PT-FBTS
                    Rec."Sand Date&Time" := CurrentDateTime;//PT-FBTS

                    //ALLE_NICK_160124
                    Stockline3.SetRange("DocumentNo.", Rec."No.");
                    Stockline3.SetFilter(StockQty, '%1', 0);
                    if Stockline3.FindSet() then begin
                        countline := Stockline3.Count;
                    end;
                    if Confirm('%1 of items Physical Qty In-hand is Zero, do you want to continue', true, countline) then begin
                        //ALLE_NICK_120124
                        Stockline2.SetRange("DocumentNo.", rec."No.");
                        if Stockline2.FindSet() then begin
                            repeat
                                NetchangeQty := 0;
                                IF TempUsersetup2.get(UserId) then;
                                Recitem.SetRange("No.", Stockline2."Item Code");
                                Recitem.SetRange("Date Filter", 0D, rec."Posting date");
                                Recitem.SetFilter("Location Filter", rec."Location Code");
                                if Recitem.findfirst then
                                    Recitem.CalcFields("Net Change");
                                NetchangeQty := Recitem."Net Change";
                                Stockline2."Qty. (Calculated)" := NetchangeQty;

                                //As Per Req + //AJ_ALLE_29012024
                                Stockline2.Quantity := 0;
                                if Stockline2."Qty. (Phys. Inventory)" >= Stockline2."Qty. (Calculated)" then begin
                                    Stockline2.Validate("Entry Type", Stockline2."Entry Type"::"Positive Adjmt.");
                                    Stockline2.Validate(Quantity, Stockline2."Qty. (Phys. Inventory)" - Stockline2."Qty. (Calculated)");
                                end else begin
                                    Stockline2.Validate("Entry Type", Stockline2."Entry Type"::"Negative Adjmt.");
                                    Stockline2.Validate(Quantity, Stockline2."Qty. (Calculated)" - Stockline2."Qty. (Phys. Inventory)");
                                end;
                                //As Per Req -//AJ_ALLE_29012024

                                Stockline2.Modify();
                            until Stockline2.Next() = 0;
                        end;
                        //ALLE_NICK_120124
                        //Commented because not reqd on approval
                        // Stockline.SetRange("DocumentNo.", rec."No.");
                        // if Stockline.FindSet() then begin
                        //     repeat
                        //         QTYvalidate(Stockline, Today);
                        //     until Stockline.Next() = 0;
                        // end;


                        //for check for zero amount
                        totalStockLine.Reset();
                        totalStockLine.SetRange(totalStockLine."DocumentNo.", rec."No.");
                        totalStockLine.SetFilter(totalStockLine.Quantity, '<>%1', 0);
                        IF totalStockLine.FindSet() then
                            repeat
                                IF (totalStockLine.Amount) = 0 then
                                    Error('Amount should not be zero in Line no %1 for Item %2', totalStockLine."LineNo.", totalStockLine."Item Code");

                            until totalStockLine.Next() = 0;
                        //end

                        if tempusersetup.get(UserId) then;
                        tempusersetup.TestField(tempusersetup.StockAuditApprover);
                        tempusersetup.TestField(tempusersetup.StockAuditLimit);
                        IF Confirm('Are want to send this order for approval?', true) then begin
                            IF Rec.Status = Rec.Status::Open then begin

                                /*
                                if UserId = tempusersetup.StockAuditApprover then
                                    Rec.Status := Rec.Status::Approved
                                Else
                                    Rec.Status := Rec.Status::PendingApproval;

                                Rec.Modify();
                                */
                                totalStockLine.Reset();
                                totalStockLine.SetRange(totalStockLine."DocumentNo.", rec."No.");
                                IF totalStockLine.FindSet() then
                                    repeat
                                        if tempitem.get(totalStockLine."Item Code") then;
                                        TotalAmount := TotalAmount + (totalStockLine.Amount);

                                    until totalStockLine.Next() = 0;

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
                                totalPercentageValue := Round(((tempusersetup.StockAuditLimit * TodaysSales) / 100), 1, '=');
                                if ((TotalAmount > totalPercentageValue) and (tempusersetup.StockAuditApprover <> UserId)) then begin
                                    Rec.Status := Rec.Status::PendingApproval;
                                    Rec.Modify();
                                    //to send a mail for wastageEntry approval
                                    //MailList.Add('mahendra.patil@in.ey.com');
                                    Subject := 'Inventory Count Entry ' + Rec."No." + 'Pending approval';
                                    MessageBody := 'Dear Approver, ' + '<br><br> This Document No. ' + Rec."No." + ' is pending for approval. The reason for approval is amount ' + Format(TotalAmount) + ' exceeded allowed Limit of ' + Format(totalPercentageValue) + '<br><br>' + 'https://erptwc.thirdwavecoffee.in/BC220/?company=HBPL&page=50064&dc=0'
                                    + '<br><br>' + 'Regards' + '<br><br>' + 'IT - Team.';
                                    EmailMessage.Create(tempusersetup.StockEntryNotification, Subject, MessageBody, true);
                                    EmailCodeunit.Send(EmailMessage);
                                    //end
                                end
                                else begin

                                    Rec.Status := Rec.Status::Approved;
                                    Rec.Modify();
                                end;
                                CurrPage.Close();
                                //  CurrPage.Editable(false);
                            end else
                                Error('Order Status must be open');
                        end;
                    end;
                end;



            }
            action(CalculateInventory)
            {

                ApplicationArea = All;

                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Caption = 'Calculate &Inventory';
                Ellipsis = true;
                Image = CalculateInventory;
                ToolTip = 'Start the process of counting inventory by filling the journal with known quantities.';

                trigger OnAction()
                var
                    CalcQtyOnHand: Report CalculateInventoryStockAudit;
                    Stockline: Record StockAuditLine;
                begin
                    Stockline.SetRange("DocumentNo.", rec."No.");
                    if not Stockline.FindFirst() then begin
                        IF Confirm(' Transfer IN/OUT, Wastage Entry are not allowed after closing Entry. Please make sure you have completed these activities .   Closing Value cant be more than the current Stock Quantity for Raw Items. Please check if you have any pending Transfer Ins') then Begin
                            CalcQtyOnHand.SetStockAuditHeader(Rec);
                            CalcQtyOnHand.RunModal();
                            Clear(CalcQtyOnHand);
                        End;
                    end
                    else
                        Error('Inventory is already Calculated');


                end;
            }
            //ALLENick091023_start
            // action("Reopen")
            // {
            //     ApplicationArea = All;
            //     Image = ReOpen;
            //     Promoted = true;
            //     PromotedIsBig = true;
            //     PromotedCategory = Process;
            //     Caption = 'Reopen';
            //     trigger OnAction()
            //     var
            //         Usersetup: Record "User Setup";
            //     begin
            //         if Usersetup.Get(UserId) then
            //             if Usersetup."Is Admin" = true then begin
            //                 rec.Validate(Status, rec.Status::Open);
            //                 CurrPage.Editable(true);
            //                 rec.Modify();
            //             end
            //             else
            //                 Message('You are not authorized to reopen the page');
            //         CurrPage.Close();
            //     end;
            // }
            //ALLENick091023_End 

            action(VarianceReport)//PTFBTS_11/05/24
            {
                ApplicationArea = all;
                Promoted = true;
                Visible = false;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Caption = 'Variance Report';
                Ellipsis = true;
                Image = Report;
                ToolTip = 'Start the process of counting inventory by filling the journal with known quantities.';
                trigger OnAction()
                var
                    stockHeader: Record StockAuditHeader;
                //vaiance: Report 60101;
                begin
                    stockHeader.Reset();
                    stockHeader.SetRange("No.", Rec."No.");
                    stockHeader.SetRange("Posting date", Rec."Posting date");
                    stockHeader.SetRange("Location Code", Rec."Location Code");
                    if stockHeader.FindFirst() then;
                    Report.RunModal(50009, true, false, stockHeader);
                end;
            }
            action("Update price")//PTFBTS_11/05/24
            {
                ApplicationArea = all;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Caption = 'Update price';
                Ellipsis = true;
                Image = Report;
                ToolTip = 'Start the process of counting inventory by filling the journal with known quantities.';
                trigger OnAction()
                var
                    stockHeader: Record StockAuditHeader;
                    stockLineRec: Record StockAuditLine;
                    stockkeepingunit: Record "Stockkeeping Unit";
                    UnitPrice: Decimal;
                //vaiance: Report 60101;
                begin
                    Clear(UnitPrice);
                    if Confirm('Do you want update unit cost') then
                        stockLineRec.Reset();
                    stockLineRec.SetRange("DocumentNo.", Rec."No.");
                    stockLineRec.SetRange(UnitPrice, 0);
                    if stockLineRec.FindSet() then begin

                        repeat
                            stockkeepingunit.Reset();
                            stockkeepingunit.SetRange("Item No.", stockLineRec."Item Code");
                            stockkeepingunit.SetRange("Location Code", stockLineRec."Location Code");
                            //stockkeepingunit.CalcFields("Unit Cost");
                            if stockkeepingunit.FindSet() then begin
                                repeat
                                    UnitPrice := stockkeepingunit."Unit Cost";
                                // Message('%1', UnitPrice);
                                until stockkeepingunit.Next() = 0;
                            end;
                            stockLineRec.Validate(UnitPrice, UnitPrice);//PT-FBTS- 22-07-25
                            stockLineRec.Modify();
                        until stockLineRec.Next() = 0;


                    end;
                end;
            }
        }
    }
    var
        [InDataSet]
        IsStockLinesEditable: Boolean;
        ispageEtitable: Boolean;

    trigger OnOpenPage()
    begin
        ActivateFields();
        // if Rec.Status = Rec.Status::Open then Begin
        // End
        // Else
        //     CurrPage.Editable(False);
        if (Rec.Status = Rec.Status::Open) or (Rec.Status = Rec.Status::PendingApproval) then Begin //PT-FBTS-150424
        End
        Else
            CurrPage.Editable(False);
    end;

    trigger OnDeleteRecord(): Boolean //PT-FBTS
    var
        StockLine: Record StockAuditLine;
    begin
        StockLine.Reset();
        StockLine.SetRange("DocumentNo.", Rec."No.");
        if StockLine.FindFirst() then begin
            StockLine.DeleteAll();
        end;
    end;

    trigger OnAfterGetRecord()
    begin
        if Rec.Status = Rec.Status::Open then Begin
        End
        Else
            CurrPage.Editable(False);
        usersetup.Get(UserId); //PT-FBTS 150524
        if usersetup."inventory Controller" = true then begin
            if Rec.Status = Rec.Status::Approved then
                ViseblePost := true;
        end;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        if Rec.Status = Rec.Status::Open then Begin
        End
        Else
            CurrPage.Editable(False);
        usersetup.Get(UserId); //PT-FBTS 150524
        if usersetup."inventory Controller" = true then begin
            if Rec.Status = Rec.Status::Approved then
                ViseblePost := true;
        end;

    end;

    trigger OnModifyRecord(): Boolean
    begin
        if Rec.Status = Rec.Status::Open then Begin
        End
        Else
            CurrPage.Editable(False);

        //  Message('onmodify');
    end;





    trigger OnNewRecord(BelowxRec: Boolean) //PT-FBTS 09-07-2024
    var
        tempStockAuditHeader: Record StockAuditHeader;
        tempusersetup: Record "User Setup";

    begin
        /*
        if tempusersetup.get(UserId) then;
        tempStockAuditHeader.Reset();
        tempStockAuditHeader.SetRange("Posting date", Today);
        tempStockAuditHeader.SetRange("Location Code", 'BLUE');
        if tempStockAuditHeader.FindFirst() then begin
            error('You can only craete one watage entry record per day per location')
        end;
        */
        tempStockAuditHeader.Reset();
        tempStockAuditHeader.SetRange("Location Code", Rec."Location Code");
        tempStockAuditHeader.SetRange("Posting date", rec."Posting date");
        if tempStockAuditHeader.FindLast() then begin
            if Rec."Posting date" = tempStockAuditHeader."Posting date" then
                Error('Physical Counting Already created');

        end;
    end;

    local procedure ActivateFields()
    begin
        IsStockLinesEditable := Rec.StockAuditLineEditable();

    end;

    local procedure QTYvalidate(Stockline: Record StockAuditLine; DATE: Date)
    var
        TempItem: Record Item;

        ILE1: Record "Item Ledger Entry";
        Postingdate: text;
        InvSetUp: Record "Inventory Setup";
        AssingQty: Decimal;

    begin
        Stockline.CalcFields("Stock in hand");
        If Stockline."Stock in hand" < Stockline.Quantity then begin
            AssingQty := Stockline."Stock in hand" - Stockline.Quantity;
            if Stockline."Entry Type" = Stockline."Entry Type"::"Negative Adjmt." then begin
                if InvSetUp.Get() then
                    if InvSetUp."Inventory Post. Allow" then begin
                        Evaluate(Postingdate, Format(date));
                        CreateIJL(Stockline, Postingdate, rec, AssingQty);
                    end
                    else
                        Error('Inventory is not avaliable for this Item, please reduce a qty for Item No %1', Stockline."Item Code");
            end;
        end;

    end;

    local procedure CreateIJL(Stockline: Record StockAuditLine; DTLocal: Text; stockhdr: Record StockAuditHeader; qty: Decimal)
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
        Item.Get(Stockline."Item Code");
        if Item.Type = Item.Type::Inventory then begin
            IJLine.INIT;
            IJLine.VALIDATE("Journal Template Name", 'ITEM');
            // IJLine.VALIDATE("Journal Batch Name", ItemJnlBatch.Name);
            IJLine.VALIDATE("Journal Batch Name", 'STOCKAUDIT');
            //ALLE-AS-20012024
            IJLine.VALIDATE("Document No.", Stockline."DocumentNo.");
            IJLineTmp.RESET;
            IJLineTmp.SETRANGE("Journal Template Name", 'ITEM');
            // IJLineTmp.SETRANGE("Journal Batch Name", ItemJnlBatch.Name);
            IJLineTmp.SETRANGE("Journal Batch Name", 'STOCKAUDIT');
            IF IJLineTmp.FINDLAST THEN
                IJLine."Line No." := IJLineTmp."Line No." + 10000
            ELSE
                IJLine."Line No." := 10000;
            IJLine.VALIDATE("Entry Type", IJLine."Entry Type"::"Positive Adjmt.");
            IJLine.VALIDATE("Item No.", (Stockline."Item Code"));
            EVALUATE(DTLoc, DTLocal);
            Evaluate(IJLine."Posting Date", DTLocal);
            IJLine.VALIDATE("Posting Date");
            IJLine.VALIDATE("Location Code", rec."Location Code");
            IJLine."Reason Code" := 'INVCOUT';
            //ALLE-AS-20012024
            IJLine.VALIDATE(Quantity, Abs(qty));
            IF Store.GET(Stockline."Location Code") THEN
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
                    ReservationEntry.Validate("Source Batch Name", 'STOCKAUDIT');
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

    local procedure CheckQty(Stockline: Record StockAuditLine)
    var
        myInt: Integer;
        Qtytotal: Decimal;
        ResQtytotal: Decimal;
        ReservationEntry: Record "Reservation Entry";
        ReservedEntry: Codeunit 99000831;
        Error: text;
    begin
        Clear(ResQtytotal);
        if Stockline."Entry Type" = Stockline."Entry Type"::"Negative Adjmt." then begin
            Stockline.CalcFields("Stock in hand", "Reserved Qty. on Inventory");
            ResQtytotal := Stockline."Stock in hand" - Stockline."Reserved Qty. on Inventory";
            if ResQtytotal < Stockline.Quantity then begin
                if Stockline.Quantity <> 0 then begin
                    ReservationEntry.Reset();
                    ReservationEntry.SetRange("Item No.", Stockline."Item Code");
                    ReservationEntry.SetFilter("Source Type", '%1', 32);
                    ReservationEntry.SetFilter("Reservation Status", '%1', ReservationEntry."Reservation Status"::Reservation);
                    ReservationEntry.SetRange("Location Code", Stockline."Location Code");
                    if ReservationEntry.FindFirst() then
                        Error := ReservedEntry.CreateForText(ReservationEntry);
                    Error('Quantity is Reserved for %1 and Item no %2', Error, Stockline."Item Code");
                end;

            end;
        end;

    end;

    //END
    var
        ViseblePost: Boolean;
        usersetup: Record "User Setup";
        IJLine: Record 83;
        ItemJnlLine: Record "Item Journal Line";
        Item: Record Item;
        NoSeries: Record "No. Series";
        ReservationEntry: Record "Reservation Entry";
        Entry: Integer;
        NoSeriesManagement: Codeunit NoSeriesManagement;








}