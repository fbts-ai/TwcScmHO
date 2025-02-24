page 50109 OfflineSalesHeader
{
    PageType = Document;

    SourceTable = StockAuditHeader;
    Caption = 'Agave Inventory Counting Card';
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
                    /*
                     trigger OnAssistEdit()
                     begin
                         if AssistEdit(xRec) then
                             CurrPage.Update();
                     end;
                     */

                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = ALL;

                }
                field("Posting Date"; Rec."Posting date")
                {
                    ApplicationArea = all;

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
                }
                field(RejectionRemark; Rec.RejectionRemark)
                {
                    ApplicationArea = All;
                    Caption = 'Rejection Remark';
                    Editable = false;
                }


            }


            part(StockLine; OfflineSalesLine)
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

                begin
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
                    TempStockAuditLine5.SetFilter(TempStockAuditLine5."Entry Type", '=%1', TempStockAuditLine5."Entry Type"::"Positive Adjmt.");
                    TempStockAuditLine5.SetFilter(Quantity, '>%1', 0);
                    IF TempStockAuditLine5.FindFirst() then
                        error('You can not pass postive adjusment from offline sales process form for article No. %1', TempStockAuditLine5."Item Code");

                    /*
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
                    */

                    IF Confirm('Are you sure to submit the offline Sales Process Entry? You will not be able to modify after submitting.', true) then begin
                        //IF Rec.Status = Rec.Status::Approved then begin
                        Invetsetup.get;
                        ItemJournalName := Invetsetup.StockAuditTemplateName;
                        ItemJournalBatchName := Invetsetup.OfflineSalesBatchName;
                        Invetsetup.TestField(Invetsetup.StockAuditTemplateName);
                        Invetsetup.TestField(Invetsetup.OfflineSalesBatchName);


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

                        ///delete item jounal line
                        TempItemJnlLine1.Reset();
                        TempItemJnlLine1.SetRange("Journal Template Name", ItemJournalName);
                        TempItemJnlLine1.SetRange("Journal Batch Name", ItemJournalBatchName);
                        TempItemJnlLine1.SetRange("Document No.", Rec."No."); //added document number
                        IF TempItemJnlLine1.FindSet() then
                            TempItemJnlLine1.DeleteAll(true);

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

                                IF TempStockAuditLine."Entry Type" = TempStockAuditLine."Entry Type"::"Negative Adjmt." then begin
                                    TempItemJnlLine."Entry Type" := TempStockAuditLine."Entry Type"::Sale;
                                    TempItemJnlLine.Validate(TempItemJnlLine."Entry Type");
                                end;


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

                                //TempItemJnlLine.Amount := TempStockAuditLine.Amount;
                                TempItemJnlLine.Validate(TempItemJnlLine."Unit Cost");
                                //TempItemJnlLine.Validate(TempItemJnlLine.Amount);
                                TempItemJnlLine."Reason Code" := TempStockAuditLine."Reason Code";
                                //Validation for insuffient qty 
                                IF TempItem."Item Tracking Code" <> '' then begin
                                    IF TempItemJnlLine."Entry Type" = TempItemJnlLine."Entry Type"::Sale then begin
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
                                                qtyCount := qtyCount + ILE1."Remaining Quantity";
                                            Until ILE1.Next() = 0;
                                        If qtyCount < TempItemJnlLine.Quantity then
                                            Error('Qty available in Lot for item No. %1 , please reduce a qty available', TempItem."No.");
                                    end;
                                End;

                                TempItemJnlLine.Insert(true);

                                //  Message('inseted');
                                Commit();

                                //For AutoLotAssignmemnt
                                IF TempItem."Item Tracking Code" <> '' then begin
                                    IF TempItemJnlLine."Entry Type" = TempItemJnlLine."Entry Type"::Sale then begin
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
                                                        StockAuditCodeunit.OfflineSalesReservationEntry(TempItemJnlLine, ILE."Lot No.",
                                                        TotalQty, qty_qtyBase, TotalQtytoShipBase, TotalQtytoReceiveBase, ILE."Expiration Date");
                                                        TotalQty := 0;
                                                        TotalQtytoReceiveBase := 0;
                                                        TotalQtytoReceiveBase := 0;
                                                    end else
                                                        if (ILE."Remaining Quantity" < TotalQty) then begin
                                                            qty_qtyBase := ILE."Remaining Quantity" * TempItemJnlLine."Qty. per Unit of Measure";
                                                            StockAuditCodeunit.OfflineSalesReservationEntry(TempItemJnlLine, ILE."Lot No.", ILE."Remaining Quantity",
                                                           qty_qtyBase, qty_qtyBase, qty_qtyBase, ILE."Expiration Date");
                                                            TotalQty := TotalQty - ILE."Remaining Quantity";
                                                            TotalQtytoShipBase := TotalQtytoShipBase - qty_qtyBase;
                                                            TotalQtytoReceiveBase := TotalQtytoReceiveBase - qty_qtyBase
                                                        end;
                                                End;
                                            Until ILE.Next() = 0;
                                    End;



                                end;
                            Until TempStockAuditLine.Next() = 0;
                        End Else Begin
                            Rec.Status := Rec.Status::Posted;
                            Rec.Modify();
                            CurrPage.Update();
                            Message('Offline Sales Journal Posted successfully');
                        End;

                        TempItemJnlLine1.Reset();
                        TempItemJnlLine1.SetRange("Journal Template Name", ItemJournalName);
                        TempItemJnlLine1.SetRange("Journal Batch Name", ItemJournalBatchName);
                        TempItemJnlLine1.SetRange("Document No.", Rec."No."); //added for document no.
                        IF TempItemJnlLine1.FindSet() then;
                        IF TempItemJnlLine1.Count() > 0 Then
                            CODEUNIT.Run(CODEUNIT::"Item Jnl.-Post", TempItemJnlLine1);
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
                            Message('Offline Sales Journal Posted successfully');

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
                begin
                    IF Confirm(' Transfer IN/OUT, Wastage Entry are not allowed after closing Entry. Please make sure you have completed these activities .   Closing Value cant be more than the current Stock Quantity for Raw Items. Please check if you have any pending Transfer Ins') then Begin
                        CalcQtyOnHand.SetStockAuditHeader(Rec);
                        CalcQtyOnHand.RunModal();
                        Clear(CalcQtyOnHand);
                    End;
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
        if Rec.Status = Rec.Status::Open then Begin
        End
        Else
            CurrPage.Editable(False);
    end;

    trigger OnAfterGetRecord()
    begin
        if Rec.Status = Rec.Status::Open then Begin
        End
        Else
            CurrPage.Editable(False);
    end;

    trigger OnAfterGetCurrRecord()
    begin
        if Rec.Status = Rec.Status::Open then Begin
        End
        Else
            CurrPage.Editable(False);

    end;

    trigger OnModifyRecord(): Boolean
    begin
        if Rec.Status = Rec.Status::Open then Begin
        End
        Else
            CurrPage.Editable(False);

        //  Message('onmodify');
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        Invsetup: Record "Inventory Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;

    begin
        IF "No." = '' THEN BEGIN
            Invsetup.Get();
            Invsetup.TESTFIELD(StockAuditNo);
            NoSeriesMgt.InitSeries(Invsetup.OfflineSalesNoSeries, '', 0D, "No.", Invsetup.OfflineSalesNoSeries);
        END;
    end;



    trigger OnNewRecord(BelowxRec: Boolean)
    var
        tempStockAuditHeader: Record StockAuditHeader;
        tempusersetup: Record "User Setup";
    begin

        Rec.OfflineSales := True;
        /*
        if tempusersetup.get(UserId) then;
        tempStockAuditHeader.Reset();
        tempStockAuditHeader.SetRange("Posting date", Today);
        tempStockAuditHeader.SetRange("Location Code", 'BLUE');
        if tempStockAuditHeader.FindFirst() then begin
            error('You can only craete one watage entry record per day per location')
        end;
        */



    end;

    local procedure ActivateFields()
    begin
        IsStockLinesEditable := Rec.StockAuditLineEditable();

    end;









}