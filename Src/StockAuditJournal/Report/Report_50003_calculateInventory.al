report 50003 "CalculateInventoryStockAudit"
{
    Caption = 'Calculate Inventory';
    ProcessingOnly = true;


    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = SORTING("No.") WHERE(Type = CONST(Inventory), Blocked = CONST(false));
            RequestFilterFields = "No.", "Location Filter", "Bin Filter";
            dataitem("Item Ledger Entry"; "Item Ledger Entry")
            {
                DataItemLink = "Item No." = FIELD("No."), "Variant Code" = FIELD("Variant Filter"), "Location Code" = FIELD("Location Filter"), "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"), "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter");
                DataItemTableView = SORTING("Item No.", "Entry Type", "Variant Code", "Drop Shipment", "Location Code", "Posting Date");

                trigger OnAfterGetRecord()
                var
                    ItemVariant: Record "Item Variant";
                    ByBin: Boolean;
                    ExecuteLoop: Boolean;
                    InsertTempSKU: Boolean;
                    IsHandled: Boolean;
                    tempUserSetup: Record "User Setup";
                begin
                    if tempUserSetup.Get(UserId) then;
                    IF "Location Code" <> tempUserSetup."Location Code" then
                        Error('Location code mentioned on user setup and report options must be same');

                    if not GetLocation("Location Code") then
                        CurrReport.Skip();

                    if ("Location Code" <> '') and Location."Use As In-Transit" then
                        CurrReport.Skip();

                    if ColumnDim <> '' then
                        TransferDim("Dimension Set ID");




                    if not SkipCycleSKU("Location Code", "Item No.", "Variant Code") then
                        UpdateBuffer('', Quantity, true);
                end;

                trigger OnPreDataItem()
                begin
                    WhseEntry.SetCurrentKey("Item No.", "Bin Code", "Location Code", "Variant Code");
                    Item.CopyFilter("Bin Filter", WhseEntry."Bin Code");


                    if ColumnDim = '' then
                        TempDimBufIn.SetRange("Table ID", DATABASE::Item)
                    else
                        TempDimBufIn.SetRange("Table ID", DATABASE::"Item Ledger Entry");
                    TempDimBufIn.SetRange("Entry No.");
                    TempDimBufIn.DeleteAll();

                    if IncludeItemWithNoTransaction then
                        if not "Item Ledger Entry".Find('-') then begin
                            WhseEntry.SetRange("Item No.", Item."No.");
                            if (Item.GetFilter("Variant Filter") = '') and
                               (Item.GetFilter("Location Filter") = '') and
                               WhseEntry.IsEmpty
                            then begin
                                Clear(TempQuantityOnHandBuffer);
                                TempQuantityOnHandBuffer."Item No." := Item."No.";

                                TempQuantityOnHandBuffer.Insert();
                            end;
                        end;


                end;
            }
            dataitem(ItemWithNoTransaction; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));

                trigger OnAfterGetRecord()
                begin
                    if IncludeItemWithNoTransaction then
                        UpdateQuantityOnHandBuffer(Item."No.");
                end;
            }



            trigger OnAfterGetRecord()
            begin

                if not HideValidationDialog then
                    Window.Update();
                TempSKU.DeleteAll();
            end;

            trigger OnPostDataItem()
            begin
                CalcPhysInvQtyAndInsertItemJnlLine();
            end;

            trigger OnPreDataItem()
            var
                ItemJnlTemplate: Record "Item Journal Template";
                ItemJnlBatch: Record "Item Journal Batch";
                TempUsersetup: Record "User Setup";
            begin
                //ALLE_NICK_191223
                if "Phys Invt Counting Period Code1" = '' then
                    Error('Please entert the value in Phys Invt Counting Period Code');
                Item.SetFilter("Phys Invt Counting Period Code", "Phys Invt Counting Period Code1");
                Item.SetFilter("Location Filter", "LOcation Code");
                //AJ_Alle_09212023
                //UnComment
                /*
                if SelectPhyInvtCode = SelectPhyInvtCode::DAILY then
                    Item.SetFilter("Phys Invt Counting Period Code", '%1', 'DAILY');
                IF SelectPhyInvtCode = SelectPhyInvtCode::WEEKLY then
                    Item.SetFilter("Phys Invt Counting Period Code", '%1', 'DAILY|WEEKLY');
                IF SelectPhyInvtCode = SelectPhyInvtCode::MONTHLY then
                    Item.SetFilter("Phys Invt Counting Period Code", '%1', 'DAILY|WEEKLY|MONTHLY');
                   */
                //UnComment
                //AJ_Alle_09212023

                if PostingDate = 0D then
                    Error(Text000);



                // ItemJnlTemplate.Get('Item');
                //ItemJnlBatch.Get('Item', 'WTENTRY');
                if NextDocNo = '' then begin
                    NextDocNo := TempStockAuditHead."No.";
                    ItemJnlLine.Init();
                End;

                /*
                 if NextDocNo = '' then begin
                     if ItemJnlBatch."No. Series" <> '' then begin
                         ItemJnlLine.SetRange("Journal Template Name", 'ITEM');
                         ItemJnlLine.SetRange("Journal Batch Name", ItemJnlLine."Journal Batch Name");
                         if not ItemJnlLine.FindFirst() then
                             NextDocNo := NoSeriesMgt.GetNextNo(ItemJnlBatch."No. Series", PostingDate, false);
                         ItemJnlLine.Init();
                     end;
                     if NextDocNo = '' then
                         Error(Text001);
                 end;
                 */

                NextLineNo := 0;

                if not HideValidationDialog then
                    Window.Open(Text002, "No.");

                if not SkipDim then
                    SelectedDim.GetSelectedDim(UserId, 3, REPORT::"Calculate Inventory", '', TempSelectedDim);

                TempQuantityOnHandBuffer.Reset();
                TempQuantityOnHandBuffer.DeleteAll();


            end;
        }
    }

    requestpage
    {
        //SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(PostingDate; PostingDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posting Date';
                        Editable = False;
                        ToolTip = 'Specifies the date for the posting of this batch job. By default, the working date is entered, but you can change it.';

                        trigger OnValidate()
                        begin
                            ValidatePostingDate();
                        end;
                    }
                    field(DocumentNo; NextDocNo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Document No.';
                        Editable = False;
                        ToolTip = 'Specifies the number of the document that is processed by the report or batch job.';
                    }
                    //ALLE_NICK_191223_Start
                    field(Daily; Daily)
                    {
                        ApplicationArea = all;
                        Editable = Visible;
                        ShowMandatory = Visible;
                        trigger OnValidate()
                        var
                            myInt: Integer;
                            TempUsersetup: RECORD "User Setup";
                            physetup: Record "Physical Qty. Setup";
                            Location: Record Location;
                        begin
                            // if Daily = true then begin
                            //     "Phys Invt Counting Period Code" := 'DAILY';
                            //     Visible := FALSE;
                            // IF TempUsersetup.get(UserId) then;
                            // "LOcation Code" := TempUsersetup."Location Code";
                            // end
                            // else begin
                            //     "Phys Invt Counting Period Code" := '';
                            //     Visible := true;
                            // end;
                            //ALLE_NICK_120123
                            IF TempUsersetup.get(UserId) then;
                            "LOcation Code" := TempUsersetup."Location Code";
                            if Location.get(TempUsersetup."Location Code") then
                                physetup.SetRange("Location Group", Location."Physical Group");
                            physetup.SetFilter(DAILY, '%1', true);
                            if physetup.FindFirst() then begin
                                "Phys Invt Counting Period Code1" := physetup.Formula;
                                Visible := FALSE;

                            end
                            else begin
                                "Phys Invt Counting Period Code1" := '';
                                Visible := true;
                            end;
                            invCouuntingHeader.get(NextDocNo); //PT-FBTS- 16-10-24
                            if Daily = true then
                                invCouuntingHeader."Inventory Type" := invCouuntingHeader."Inventory Type"::Daily;// 'Daily';
                            invCouuntingHeader.Modify();
                            //Message('%1', invCouuntingHeader."Inventory Type");
                        end;
                    }
                    field(WEEKLEY; WEEKLEY)
                    {
                        ApplicationArea = all;
                        Editable = Visible;
                        ShowMandatory = Visible;
                        trigger OnValidate()
                        var
                            myInt: Integer;
                            TempUsersetup: RECORD "User Setup";
                            physetup: Record "Physical Qty. Setup";
                            Location: Record Location;
                        begin
                            // if WEEKLEY = true then begin
                            //     "Phys Invt Counting Period Code" := 'DAILY|WEEKLY';
                            //     Visible := FALSE;
                            //     IF TempUsersetup.get(UserId) then;
                            //     "LOcation Code" := TempUsersetup."Location Code";
                            // end
                            // else begin
                            //     // IF (WEEKLEY = FALSE) OR (DAILY = TRUE) THEN
                            //     "Phys Invt Counting Period Code" := '';
                            //     Visible := true;
                            // end;
                            //ALLE_NICK_120123
                            IF TempUsersetup.get(UserId) then;
                            "LOcation Code" := TempUsersetup."Location Code";
                            if Location.get(TempUsersetup."Location Code") then
                                physetup.SetRange("Location Group", Location."Physical Group");
                            physetup.SetFilter(WEEKLY, '%1', true);
                            if physetup.FindFirst() then begin
                                "Phys Invt Counting Period Code1" := physetup.Formula;
                                Visible := FALSE;

                            end
                            else begin
                                "Phys Invt Counting Period Code1" := '';
                                Visible := true;
                            end;
                            invCouuntingHeader.get(NextDocNo);
                            if WEEKLEY = true then //PT-FBTS-16-10-24
                                invCouuntingHeader."Inventory Type" := invCouuntingHeader."Inventory Type"::WEEKLEY;//'WEEKLEY';
                            invCouuntingHeader.Modify();

                        end;
                    }
                    field(MONTHLY; MONTHLY)
                    {
                        ApplicationArea = all;
                        Editable = Visible;
                        ShowMandatory = Visible;
                        trigger OnValidate()
                        var
                            myInt: Integer;
                            TempUsersetup: RECORD "User Setup";
                            physetup: Record "Physical Qty. Setup";
                            Location: Record Location;
                        begin
                            // if MONTHLY = true then begin
                            //     "Phys Invt Counting Period Code" := 'DAILY|WEEKLY|MONTHLY';
                            //     Visible := FALSE;
                            //     IF TempUsersetup.get(UserId) then;
                            //     "LOcation Code" := TempUsersetup."Location Code";
                            // end
                            // else begin
                            //     "Phys Invt Counting Period Code" := '';
                            //     Visible := true;
                            // end;
                            //ALLE_NICK_120123
                            IF TempUsersetup.get(UserId) then;
                            "LOcation Code" := TempUsersetup."Location Code";
                            if Location.get(TempUsersetup."Location Code") then
                                physetup.SetRange("Location Group", Location."Physical Group");
                            physetup.SetFilter(MONTHLY, '%1', true);
                            if physetup.FindFirst() then begin
                                "Phys Invt Counting Period Code1" := physetup.Formula;
                                Visible := FALSE;

                            end
                            else begin
                                "Phys Invt Counting Period Code1" := '';
                                Visible := true;
                            end;
                            invCouuntingHeader.get(NextDocNo);
                            if MONTHLY = true then //PT-FBTS-16-10-24
                                invCouuntingHeader."Inventory Type" := invCouuntingHeader."Inventory Type"::MONTHLY; //'MONTHLY';
                            invCouuntingHeader.Modify();
                        end;
                    }
                    field(QUARTERLY; QUARTERLY)
                    {
                        ApplicationArea = all;
                        Editable = Visible;
                        ShowMandatory = Visible;
                        trigger OnValidate()
                        var
                            myInt: Integer;
                            TempUsersetup: RECORD "User Setup";
                            physetup: Record "Physical Qty. Setup";
                            Location: Record Location;
                        begin
                            // if WEEKLEY = true then begin
                            //     "Phys Invt Counting Period Code" := 'DAILY|WEEKLY';
                            //     Visible := FALSE;
                            //     IF TempUsersetup.get(UserId) then;
                            //     "LOcation Code" := TempUsersetup."Location Code";
                            // end
                            // else begin
                            //     // IF (WEEKLEY = FALSE) OR (DAILY = TRUE) THEN
                            //     "Phys Invt Counting Period Code" := '';
                            //     Visible := true;
                            // end;
                            //ALLE_NICK_120123
                            IF TempUsersetup.get(UserId) then;
                            "LOcation Code" := TempUsersetup."Location Code";
                            if Location.get(TempUsersetup."Location Code") then
                                physetup.SetRange("Location Group", Location."Physical Group");
                            physetup.SetFilter(QUARTERLY, '%1', true);
                            if physetup.FindFirst() then begin
                                "Phys Invt Counting Period Code1" := physetup.Formula;
                                Visible := FALSE;

                            end
                            else begin
                                "Phys Invt Counting Period Code1" := '';
                                Visible := true;
                            end;
                            invCouuntingHeader.get(NextDocNo);
                            if QUARTERLY = true then //PT-FBTS 16-10-24 
                                invCouuntingHeader."Inventory Type" := invCouuntingHeader."Inventory Type"::QUARTERLY; //'QUARTERLY';
                            invCouuntingHeader.Modify();
                        end;

                    }
                    field("LOcation Code"; "LOcation Code")
                    {
                        ApplicationArea = all;
                        Editable = false;
                        Caption = 'Location Code';
                    }
                    field("Phys Invt Counting Period Code1"; "Phys Invt Counting Period Code1")
                    {
                        ShowMandatory = true;
                        NotBlank = true;
                        ApplicationArea = ALL;
                        caption = 'Phys Invt Counting Period Code';
                        Editable = false;

                    }
                    //ALLE_NICK_191223_END

                    field(ItemsNotOnInventory; ZeroQty)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Items Not on Inventory.';
                        ToolTip = 'Specifies if journal lines should be created for items that are not on inventory, that is, items where the value in the Qty. (Calculated) field is 0.';
                        Visible = false;
                        trigger OnValidate()
                        begin
                            if not ZeroQty then
                                IncludeItemWithNoTransaction := false;
                        end;
                    }


                    field(IncludeItemWithNoTransaction; IncludeItemWithNoTransaction)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Include Item without Transactions';
                        ToolTip = 'Specifies if journal lines should be created for items that are not on inventory and are not used in any transactions.';
                        Visible = false;
                        trigger OnValidate()
                        begin
                            if not IncludeItemWithNoTransaction then
                                exit;
                            if not ZeroQty then
                                Error(ItemNotOnInventoryErr);
                        end;
                    }

                    field(ByDimensions; ColumnDim)
                    {
                        ApplicationArea = Dimensions;
                        Caption = 'By Dimensions';
                        Editable = false;
                        ToolTip = 'Specifies the dimensions that you want the batch job to consider.';
                        Visible = false;
                        trigger OnAssistEdit()
                        begin
                            DimSelectionBuf.SetDimSelectionMultiple(3, REPORT::"Calculate Inventory", ColumnDim);
                        end;
                    }
                    field(SelectPhyInvtCode; SelectPhyInvtCode)
                    {
                        Caption = 'Select Phys. Invt. Counting Periods';
                        Visible = false;//Uncomment
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        var
            TempUsersetup: Record "User Setup";
        begin
            if PostingDate = 0D then
                PostingDate := WorkDate();
            ValidatePostingDate();
            ColumnDim := DimSelectionBuf.GetDimSelectionText(3, REPORT::"Calculate Inventory", '');
            //ALLE_NICK_191223
            IF TempUsersetup.get(UserId) then;
            Item.CopyFilter("Location Filter", TempUsersetup."Location Code");
            "LOcation Code" := TempUsersetup."Location Code"; //ALLE_NICK_120123
            IncludeItemWithNoTransaction := true;
            ZeroQty := true;
            Visible := true;
        end;
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        //AJ_Alle_09212023 
        //UnComment
        /*
        IF SelectPhyInvtCode = SelectPhyInvtCode::" " then
            Error('Please Select The Inventory Counting Period');
            */
        //UnComment
        //AJ_Alle_09212023

        if SkipDim then
            ColumnDim := ''
        else
            DimSelectionBuf.CompareDimText(3, REPORT::"Calculate Inventory", '', ColumnDim, Text003);
        ZeroQtySave := ZeroQty;
    end;

    var
        //AJ_Alle_19092023
        SelectPhyInvtCode: Enum SelectPhyInvtCode;
        //AJ_Alle_19092023
        ItemJnlBatch: Record "Item Journal Batch";
        ItemJnlLine: Record StockAuditLine;
        tempstockauditLine1: Record StockAuditLine;

        TempStockAuditHead: Record StockAuditHeader;
        WhseEntry: Record "Warehouse Entry";
        SourceCodeSetup: Record "Source Code Setup";
        DimSetEntry: Record "Dimension Set Entry";
        OldWhseEntry: Record "Warehouse Entry";
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        SelectedDim: Record "Selected Dimension";
        TempSelectedDim: Record "Selected Dimension" temporary;
        TempDimBufIn: Record "Dimension Buffer" temporary;
        TempDimBufOut: Record "Dimension Buffer" temporary;
        DimSelectionBuf: Record "Dimension Selection Buffer";
        Location: Record Location;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        DimBufMgt: Codeunit "Dimension Buffer Management";
        Window: Dialog;
        CycleSourceType: Option " ",Item,SKU;
        PhysInvtCountCode: Code[10];
        NextLineNo: Integer;
        ZeroQtySave: Boolean;
        AdjustPosQty: Boolean;
        ItemTrackingSplit: Boolean;
        SkipDim: Boolean;
        PosQty: Decimal;
        NegQty: Decimal;
        QUARTERLY: Boolean;

        "Phys Invt Counting Period Code1": Code[1000];
        Daily: Boolean;
        Visible: Boolean;
        WEEKLEY: Boolean;
        MONTHLY: Boolean;
        "LOcation Code": Code[20];
        invCouuntingHeader: Record StockAuditHeader;//PT-FBTS-16-10-24
        ItemNotOnInventoryErr: Label 'Items Not on Inventory.';

        Text000: Label 'Enter the posting date.';
        Text001: Label 'Enter the document no.';
        Text002: Label 'Processing items    #1##########';
        Text003: Label 'Retain Dimensions';

    protected var
        TempQuantityOnHandBuffer: Record "Inventory Buffer" temporary;
        TempSKU: Record "Stockkeeping Unit" temporary;
        HideValidationDialog: Boolean;
        PostingDate: Date;
        NextDocNo: Code[20];
        ZeroQty: Boolean;
        IncludeItemWithNoTransaction: Boolean;
        ColumnDim: Text[250];

    procedure SetItemJnlLine(var NewItemJnlLine: Record StockAuditLine)
    begin
        ItemJnlLine := NewItemJnlLine;
    end;

    procedure SetStockAuditHeader(var NewStockAuditheader: Record StockAuditHeader)
    begin
        TempStockAuditHead := NewStockAuditheader;
    end;

    local procedure ValidatePostingDate()
    begin
        //   if not ItemJnlBatch.Get('ITEM', 'STOCKAUDIT') then
        //   exit;
        /*
          if ItemJnlBatch."No. Series" = '' then
              NextDocNo := ''
          else begin
              NextDocNo := NoSeriesMgt.GetNextNo(ItemJnlBatch."No. Series", PostingDate, false);
              Clear(NoSeriesMgt);
          end;
          */
        NextDocNo := TempStockAuditHead."No.";
    end;

    procedure InsertItemJnlLine(ItemNo: Code[20]; VariantCode2: Code[10]; DimEntryNo2: Integer; BinCode2: Code[20]; Quantity2: Decimal; PhysInvQuantity: Decimal)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        Bin: Record Bin;
        DimValue: Record "Dimension Value";
        DimMgt: Codeunit DimensionManagement;
        NoBinExist: Boolean;
        ShouldInsertItemJnlLine: Boolean;
        IsHandled: Boolean;
        Recitem: Record Item;
        TempUsersetup: Record "User Setup";
        NetchangeQty: Decimal;
    begin
        IsHandled := false;

        if not IsHandled then
            with ItemJnlLine do begin
                if NextLineNo = 0 then begin
                    LockTable();
                    /*
                    SetRange("Journal Template Name", "Journal Template Name");
                    SetRange("Journal Batch Name", "Journal Batch Name");
                    if FindLast() then
                        NextLineNo := "Line No.";
                        */
                    tempstockauditLine1.Reset();
                    tempstockauditLine1.SetRange(tempstockauditLine1."DocumentNo.", TempStockAuditHead."No.");
                    if tempstockauditLine1.FindLast() then
                        NextLineNo := ItemJnlLine."LineNo.";

                    SourceCodeSetup.Get();
                end;
                if TempUsersetup.get(UserId) then
                    NextLineNo := NextLineNo + 10000;
                ShouldInsertItemJnlLine := (Quantity2 <> 0) or ZeroQty;

                if ShouldInsertItemJnlLine then begin

                    ItemJnlLine.Init();
                    ItemJnlLine."LineNo." := NextLineNo;
                    Validate(ItemJnlLine."Posting Date", TempStockAuditHead."Posting date");
                    if PhysInvQuantity >= Quantity2 then
                        Validate("Entry Type", "Entry Type"::"Positive Adjmt.")
                    else
                        Validate("Entry Type", "Entry Type"::"Negative Adjmt.");
                    Validate(ItemJnlLine."DocumentNo.", NextDocNo);


                    Validate(ItemJnlLine."Item Code", ItemNo);
                    Validate(ItemJnlLine.Variant, VariantCode2);
                    //Validate("Location Code", Location.Code);


                    Validate("Location Code", TempUsersetup."Location Code");//ALLE_NICK_120124
                    Validate("Source Code", SourceCodeSetup."Phys. Inventory Journal");
                    "Qty. (Phys. Inventory)" := PhysInvQuantity;
                    "Phys. Inventory" := true;
                    Validate("Qty. (Calculated)", Quantity2);
                    Validate(StockQty, 0);//ALLE_NICK_120124
                    //Validate("Qty. (Calculated)", NetchangeQty);
                    //"Posting No. Series" := ItemJnlBatch."Posting No. Series";
                    "Reason Code" := ItemJnlBatch."Reason Code";
                    /*
                     "Phys Invt Counting Period Code" := PhysInvtCountCode;
                     "Phys Invt Counting Period Type" := CycleSourceType;

                     if Location."Bin Mandatory" then
                         "Dimension Set ID" := 0;
                     "Shortcut Dimension 1 Code" := '';
                     "Shortcut Dimension 2 Code" := '';

                     ItemLedgEntry.Reset();
                     ItemLedgEntry.SetCurrentKey("Item No.");
                     ItemLedgEntry.SetRange("Item No.", ItemNo);
                     if ItemLedgEntry.FindLast() then
                         "Last Item Ledger Entry No." := ItemLedgEntry."Entry No."
                     else
                         "Last Item Ledger Entry No." := 0;
 */

                    Insert(true);

                    /*
                                        if Location.Code <> '' then
                                            // if Location."Directed Put-away and Pick" then
                                            //   ReserveWarehouse(ItemJnlLine);

                                            if ColumnDim = '' then
                                                DimEntryNo2 := CreateDimFromItemDefault();

                                        if DimBufMgt.GetDimensions(DimEntryNo2, TempDimBufOut) then begin
                                            TempDimSetEntry.Reset();
                                            TempDimSetEntry.DeleteAll();
                                            if TempDimBufOut.Find('-') then
                                                repeat
                                                    DimValue.Get(TempDimBufOut."Dimension Code", TempDimBufOut."Dimension Value Code");
                                                    TempDimSetEntry."Dimension Code" := TempDimBufOut."Dimension Code";
                                                    TempDimSetEntry."Dimension Value Code" := TempDimBufOut."Dimension Value Code";
                                                    TempDimSetEntry."Dimension Value ID" := DimValue."Dimension Value ID";
                                                    if TempDimSetEntry.Insert() then;
                                                    "Dimension Set ID" := DimMgt.GetDimensionSetID(TempDimSetEntry);
                                                    DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID",
                                                      "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");

                                                    Modify();
                                                until TempDimBufOut.Next() = 0;
                                            TempDimBufOut.DeleteAll();
                                        end;
                                        */
                end;
            end;


    end;

    local procedure InsertQuantityOnHandBuffer(ItemNo: Code[20]; LocationCode: Code[10]; VariantCode: Code[10])
    begin
        with TempQuantityOnHandBuffer do begin
            Reset();
            SetRange("Item No.", ItemNo);
            SetRange("Location Code", LocationCode);
            SetRange("Variant Code", VariantCode);
            if not FindFirst() then begin
                Reset();
                Init();
                "Item No." := ItemNo;
                "Location Code" := LocationCode;
                "Variant Code" := VariantCode;
                "Bin Code" := '';
                "Dimension Entry No." := 0;
                Insert(true);
            end;
        end;
    end;
    /*
        local procedure ReserveWarehouse(ItemJnlLine: Record "Item Journal Line")
        var
            ReservEntry: Record "Reservation Entry";
            WhseEntry: Record "Warehouse Entry";
            WhseEntry2: Record "Warehouse Entry";
            CreateReservEntry: Codeunit "Create Reserv. Entry";
            EntryType: Option "Negative Adjmt.","Positive Adjmt.";
            OrderLineNo: Integer;
        begin
            with ItemJnlLine do begin
                WhseEntry.SetCurrentKey(
                    "Item No.", "Bin Code", "Location Code", "Variant Code", "Unit of Measure Code",
                    "Lot No.", "Serial No.", "Entry Type");
                WhseEntry.SetRange("Item No.", "Item No.");
                WhseEntry.SetRange("Bin Code", Location."Adjustment Bin Code");
                WhseEntry.SetRange("Location Code", "Location Code");
                WhseEntry.SetRange("Variant Code", "Variant Code");
                if "Entry Type" = "Entry Type"::"Positive Adjmt." then
                    EntryType := EntryType::"Negative Adjmt.";
                if "Entry Type" = "Entry Type"::"Negative Adjmt." then
                    EntryType := EntryType::"Positive Adjmt.";

                WhseEntry.SetRange("Entry Type", EntryType);
                if WhseEntry.Find('-') then
                    repeat
                        WhseEntry.SetTrackingFilterFromWhseEntry(WhseEntry);
                        WhseEntry.CalcSums("Qty. (Base)");

                        WhseEntry2.SetCurrentKey(
                            "Item No.", "Bin Code", "Location Code", "Variant Code", "Unit of Measure Code",
                            "Lot No.", "Serial No.", "Entry Type");
                        WhseEntry2.CopyFilters(WhseEntry);
                        case EntryType of
                            EntryType::"Positive Adjmt.":
                                WhseEntry2.SetRange("Entry Type", WhseEntry2."Entry Type"::"Negative Adjmt.");
                            EntryType::"Negative Adjmt.":
                                WhseEntry2.SetRange("Entry Type", WhseEntry2."Entry Type"::"Positive Adjmt.");
                        end;

                        WhseEntry2.CalcSums("Qty. (Base)");
                        if Abs(WhseEntry2."Qty. (Base)") > Abs(WhseEntry."Qty. (Base)") then
                            WhseEntry."Qty. (Base)" := 0
                        else
                            WhseEntry."Qty. (Base)" := WhseEntry."Qty. (Base)" + WhseEntry2."Qty. (Base)";

                        if WhseEntry."Qty. (Base)" <> 0 then begin
                            if "Order Type" = "Order Type"::Production then
                                OrderLineNo := "Order Line No.";
                            ReservEntry.CopyTrackingFromWhseEntry(WhseEntry);
                            CreateReservEntry.CreateReservEntryFor(
                                DATABASE::"Item Journal Line", "Entry Type".AsInteger(), "Journal Template Name", "Journal Batch Name", OrderLineNo,
                                "Line No.", "Qty. per Unit of Measure",
                                Abs(WhseEntry.Quantity), Abs(WhseEntry."Qty. (Base)"), ReservEntry);
                            if WhseEntry."Qty. (Base)" < 0 then             // only Date on positive adjustments
                                CreateReservEntry.SetDates(WhseEntry."Warranty Date", WhseEntry."Expiration Date");
                            CreateReservEntry.CreateEntry(
                                "Item No.", "Variant Code", "Location Code", Description, 0D, 0D, 0, "Reservation Status"::Prospect);
                        end;
                        WhseEntry.Find('+');
                        WhseEntry.ClearTrackingFilter();
                    until WhseEntry.Next() = 0;
            end;
        end;
    */
    procedure InitializeRequest(NewPostingDate: Date; DocNo: Code[20]; ItemsNotOnInvt: Boolean; InclItemWithNoTrans: Boolean)
    begin
        PostingDate := NewPostingDate;
        NextDocNo := DocNo;
        ZeroQty := ItemsNotOnInvt;
        IncludeItemWithNoTransaction := InclItemWithNoTrans and ZeroQty;
        if not SkipDim then
            ColumnDim := DimSelectionBuf.GetDimSelectionText(3, REPORT::"Calculate Inventory", '');
    end;

    local procedure TransferDim(DimSetID: Integer)
    begin
        DimSetEntry.SetRange("Dimension Set ID", DimSetID);
        if DimSetEntry.Find('-') then
            repeat
                if TempSelectedDim.Get(
                     UserId, 3, REPORT::"Calculate Inventory", '', DimSetEntry."Dimension Code")
                then
                    InsertDim(DATABASE::"Item Ledger Entry", DimSetID, DimSetEntry."Dimension Code", DimSetEntry."Dimension Value Code");
            until DimSetEntry.Next() = 0;
    end;

    local procedure CalcWhseQty(AdjmtBin: Code[20]; var PosQuantity: Decimal; var NegQuantity: Decimal)
    var
        WhseEntry: Record "Warehouse Entry";
        WhseEntry2: Record "Warehouse Entry";
        WhseItemTrackingSetup: Record "Item Tracking Setup";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        WhseQuantity: Decimal;
        NoWhseEntry: Boolean;
        NoWhseEntry2: Boolean;
    begin
        AdjustPosQty := false;
        with TempQuantityOnHandBuffer do begin
            ItemTrackingMgt.GetWhseItemTrkgSetup("Item No.", WhseItemTrackingSetup);

            ItemTrackingSplit := WhseItemTrackingSetup.TrackingRequired();
            WhseEntry.SetCurrentKey(
              "Item No.", "Bin Code", "Location Code", "Variant Code", "Unit of Measure Code",
              "Lot No.", "Serial No.", "Entry Type");

            WhseEntry.SetRange("Item No.", "Item No.");
            WhseEntry.SetRange("Location Code", "Location Code");
            WhseEntry.SetRange("Variant Code", "Variant Code");

            WhseEntry.CalcSums("Qty. (Base)");
            WhseQuantity := WhseEntry."Qty. (Base)";
            WhseEntry.SetRange("Bin Code", AdjmtBin);

            if WhseItemTrackingSetup."Serial No. Required" then begin
                WhseEntry.SetRange("Entry Type", WhseEntry."Entry Type"::"Positive Adjmt.");
                WhseEntry.CalcSums("Qty. (Base)");
                PosQuantity := WhseQuantity - WhseEntry."Qty. (Base)";
                WhseEntry.SetRange("Entry Type", WhseEntry."Entry Type"::"Negative Adjmt.");
                WhseEntry.CalcSums("Qty. (Base)");
                NegQuantity := WhseQuantity - WhseEntry."Qty. (Base)";
                WhseEntry.SetRange("Entry Type", WhseEntry."Entry Type"::Movement);
                WhseEntry.CalcSums("Qty. (Base)");
                if WhseEntry."Qty. (Base)" <> 0 then
                    if WhseEntry."Qty. (Base)" > 0 then
                        PosQuantity := PosQuantity + WhseQuantity - WhseEntry."Qty. (Base)"
                    else
                        NegQuantity := NegQuantity - WhseQuantity - WhseEntry."Qty. (Base)";

                WhseEntry.SetRange("Entry Type", WhseEntry."Entry Type"::"Positive Adjmt.");
                if WhseEntry.Find('-') then
                    repeat
                        WhseEntry.SetRange("Serial No.", WhseEntry."Serial No.");

                        WhseEntry2.Reset();
                        WhseEntry2.SetCurrentKey(
                          "Item No.", "Bin Code", "Location Code", "Variant Code",
                          "Unit of Measure Code", "Lot No.", "Serial No.", "Entry Type");

                        WhseEntry2.CopyFilters(WhseEntry);
                        WhseEntry2.SetRange("Entry Type", WhseEntry2."Entry Type"::"Negative Adjmt.");
                        WhseEntry2.SetRange("Serial No.", WhseEntry."Serial No.");
                        if WhseEntry2.Find('-') then
                            repeat
                                PosQuantity := PosQuantity + 1;
                                NegQuantity := NegQuantity - 1;
                                NoWhseEntry := WhseEntry.Next() = 0;
                                NoWhseEntry2 := WhseEntry2.Next() = 0;
                            until NoWhseEntry2 or NoWhseEntry
                        else
                            AdjustPosQty := true;

                        if not NoWhseEntry and NoWhseEntry2 then
                            AdjustPosQty := true;

                        WhseEntry.Find('+');
                        WhseEntry.SetRange("Serial No.");
                    until WhseEntry.Next() = 0;
            end else begin
                if WhseEntry.Find('-') then
                    repeat
                        WhseEntry.SetRange("Lot No.", WhseEntry."Lot No.");

                        WhseEntry.CalcSums("Qty. (Base)");
                        if WhseEntry."Qty. (Base)" <> 0 then
                            if WhseEntry."Qty. (Base)" > 0 then
                                NegQuantity := NegQuantity - WhseEntry."Qty. (Base)"
                            else
                                PosQuantity := PosQuantity + WhseEntry."Qty. (Base)";
                        WhseEntry.Find('+');
                        WhseEntry.SetRange("Lot No.");

                    until WhseEntry.Next() = 0;
                if PosQuantity <> WhseQuantity then
                    PosQuantity := WhseQuantity - PosQuantity;
                if NegQuantity <> -WhseQuantity then
                    NegQuantity := WhseQuantity + NegQuantity;
            end;
        end;
    end;

    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    procedure InitializePhysInvtCount(PhysInvtCountCode2: Code[10]; CountSourceType2: Option " ",Item,SKU)
    begin
        PhysInvtCountCode := PhysInvtCountCode2;
        CycleSourceType := CountSourceType2;
    end;

    local procedure SkipCycleSKU(LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]): Boolean
    var
        SKU: Record "Stockkeeping Unit";
    begin
        if CycleSourceType = CycleSourceType::Item then
            if SKU.ReadPermission then
                if SKU.Get(LocationCode, ItemNo, VariantCode) then
                    exit(true);
        exit(false);
    end;

    procedure GetLocation(LocationCode: Code[10]): Boolean
    begin
        if LocationCode = '' then begin
            Clear(Location);
            exit(true);
        end;

        if Location.Code <> LocationCode then
            if not Location.Get(LocationCode) then
                exit(false);

        exit(true);
    end;

    local procedure UpdateBuffer(BinCode: Code[20]; NewQuantity: Decimal; CalledFromItemLedgerEntry: Boolean)
    var
        DimEntryNo: Integer;
    begin
        with TempQuantityOnHandBuffer do begin
            if not HasNewQuantity(NewQuantity) then
                exit;
            if BinCode = '' then begin
                if ColumnDim <> '' then
                    TempDimBufIn.SetRange("Entry No.", "Item Ledger Entry"."Dimension Set ID");
                DimEntryNo := DimBufMgt.FindDimensions(TempDimBufIn);
                if DimEntryNo = 0 then
                    DimEntryNo := DimBufMgt.InsertDimensions(TempDimBufIn);
            end;
            if RetrieveBuffer(BinCode, DimEntryNo) then begin
                Quantity := Quantity + NewQuantity;

                Modify();
            end else begin
                Quantity := NewQuantity;

                Insert();
            end;
        end;
    end;

    local procedure RetrieveBuffer(BinCode: Code[20]; DimEntryNo: Integer): Boolean
    begin
        with TempQuantityOnHandBuffer do begin
            Reset();
            "Item No." := "Item Ledger Entry"."Item No.";
            "Variant Code" := "Item Ledger Entry"."Variant Code";
            "Location Code" := "Item Ledger Entry"."Location Code";
            "Dimension Entry No." := DimEntryNo;
            "Bin Code" := BinCode;

            exit(Find());
        end;
    end;

    local procedure HasNewQuantity(NewQuantity: Decimal): Boolean
    begin
        exit((NewQuantity <> 0) or ZeroQty);
    end;

    local procedure ItemBinLocationIsCalculated(BinCode: Code[20]): Boolean
    begin
        with TempQuantityOnHandBuffer do begin
            Reset();
            SetRange("Item No.", "Item Ledger Entry"."Item No.");
            SetRange("Variant Code", "Item Ledger Entry"."Variant Code");
            SetRange("Location Code", "Item Ledger Entry"."Location Code");
            SetRange("Bin Code", BinCode);
            exit(Find('-'));
        end;
    end;

    procedure SetSkipDim(NewSkipDim: Boolean)
    begin
        SkipDim := NewSkipDim;
    end;

    [Scope('OnPrem')]
    procedure AddZeroQtySKU()
    var
        SKU: Record "Stockkeeping Unit";
        ShouldAddZeroQty: Boolean;
        IsHandled: Boolean;
    begin
        ShouldAddZeroQty := ZeroQty;

        if not ShouldAddZeroQty then
            exit;

        SKU.SetCurrentKey("Item No.");
        SKU.SetRange("Item No.", Item."No.");
        Item.CopyFilter("Variant Filter", SKU."Variant Code");
        //Message(SKU."Location Code");
        Item.CopyFilter("Location Filter", SKU."Location Code");

        if SKU.Find('-') then begin
            TempQuantityOnHandBuffer.Reset();
            TempQuantityOnHandBuffer.SetRange("Item No.", Item."No.");
            IsHandled := false;

            if not IsHandled then
                repeat
                    TempQuantityOnHandBuffer.SetRange("Variant Code", SKU."Variant Code");
                    TempQuantityOnHandBuffer.SetRange("Location Code", SKU."Location Code");
                    if not TempQuantityOnHandBuffer.Find('-') then begin
                        Clear(TempQuantityOnHandBuffer);
                        TempQuantityOnHandBuffer."Item No." := SKU."Item No.";
                        TempQuantityOnHandBuffer."Variant Code" := SKU."Variant Code";
                        TempQuantityOnHandBuffer."Location Code" := SKU."Location Code";

                        TempQuantityOnHandBuffer.Insert();
                    end;
                until SKU.Next() = 0;
        end;
    end;

    local procedure UpdateQuantityOnHandBuffer(ItemNo: Code[20])
    var
        Location: Record Location;
        ItemVariant: Record "Item Variant";
    begin
        ItemVariant.SetRange("Item No.", Item."No.");
        Item.CopyFilter("Variant Filter", ItemVariant.Code);
        Item.CopyFilter("Location Filter", Location.Code);
        Location.SetRange("Use As In-Transit", false);
        if (Item.GetFilter("Location Filter") <> '') and Location.FindSet() then
            repeat
                if (Item.GetFilter("Variant Filter") <> '') and ItemVariant.FindSet() then
                    repeat
                        InsertQuantityOnHandBuffer(ItemNo, Location.Code, ItemVariant.Code);
                    until ItemVariant.Next() = 0
                else
                    InsertQuantityOnHandBuffer(ItemNo, Location.Code, '');
            until Location.Next() = 0
        else
            if (Item.GetFilter("Variant Filter") <> '') and ItemVariant.FindSet() then
                repeat
                    InsertQuantityOnHandBuffer(ItemNo, '', ItemVariant.Code);
                until ItemVariant.Next() = 0
            else
                InsertQuantityOnHandBuffer(ItemNo, '', '');
    end;

    local procedure CalcPhysInvQtyAndInsertItemJnlLine()
    begin
        AddZeroQtySKU();

        with TempQuantityOnHandBuffer do begin
            Reset();

            if FindSet() then begin
                repeat
                    PosQty := 0;
                    NegQty := 0;

                    GetLocation("Location Code");
                    if Location."Directed Put-away and Pick" then
                        CalcWhseQty(Location."Adjustment Bin Code", PosQty, NegQty);

                    if (NegQty - Quantity <> Quantity - PosQty) or ItemTrackingSplit then begin
                        if PosQty = Quantity then
                            PosQty := 0;
                        if (PosQty <> 0) or AdjustPosQty then
                            InsertItemJnlLine(
                              "Item No.", "Variant Code", "Dimension Entry No.",
                              "Bin Code", Quantity, PosQty);

                        if NegQty = Quantity then
                            NegQty := 0;
                        if NegQty <> 0 then begin
                            if ((PosQty <> 0) or AdjustPosQty) and not ItemTrackingSplit then begin
                                NegQty := NegQty - Quantity;
                                Quantity := 0;
                                ZeroQty := true;
                            end;
                            if NegQty = -Quantity then begin
                                NegQty := 0;
                                AdjustPosQty := true;
                            end;
                            InsertItemJnlLine(
                              "Item No.", "Variant Code", "Dimension Entry No.",
                              "Bin Code", Quantity, NegQty);

                            ZeroQty := ZeroQtySave;
                        end;
                    end else begin
                        PosQty := 0;
                        NegQty := 0;
                    end;


                    if (PosQty = 0) and (NegQty = 0) and not AdjustPosQty then
                        InsertItemJnlLine(
                          "Item No.", "Variant Code", "Dimension Entry No.",
                          "Bin Code", Quantity, Quantity);
                until Next() = 0;
                DeleteAll();
            end;
        end;
    end;

    local procedure CreateDimFromItemDefault() DimEntryNo: Integer
    var
        DefaultDimension: Record "Default Dimension";
    begin
        with DefaultDimension do begin
            SetRange("No.", TempQuantityOnHandBuffer."Item No.");
            SetRange("Table ID", DATABASE::Item);
            SetFilter("Dimension Value Code", '<>%1', '');
            if FindSet() then
                repeat
                    InsertDim(DATABASE::Item, 0, "Dimension Code", "Dimension Value Code");
                until Next() = 0;
        end;

        DimEntryNo := DimBufMgt.InsertDimensions(TempDimBufIn);
        TempDimBufIn.SetRange("Table ID", DATABASE::Item);
        TempDimBufIn.DeleteAll();
    end;

    local procedure InsertDim(TableID: Integer; EntryNo: Integer; DimCode: Code[20]; DimValueCode: Code[20])
    begin
        with TempDimBufIn do begin
            Init();
            "Table ID" := TableID;
            "Entry No." := EntryNo;
            "Dimension Code" := DimCode;
            "Dimension Value Code" := DimValueCode;
            if Insert() then;
        end;
    end;


}

