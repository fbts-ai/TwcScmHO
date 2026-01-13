codeunit 50129 "ICT Processes_Custom"
{

    trigger OnRun()
    begin
        //UpdateTransfer();//031225
        ProcessICTDocSplit('');
    end;

    var
        GRN: Page 5709;
        Har: Codeunit "LSC Retail ICT Processes";
        ICTFunctions: Codeunit "ICT Functions_custom";
        StatWin: Dialog;
        Text001: Label 'DEFAULT';
        GLSetup: Record "General Ledger Setup";
        GLSetupRead: Boolean;
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        Text003: Label 'Key to long-';
        Text004: Label 'Field to long-';
        Text006: Label 'Select ICT Header  #1####################\';
        Text007: Label 'Process ICT Header #2####################\';
        DimMgt: Codeunit DimensionManagement;
    //031225
    local procedure UpdateTransfer()
    var
        xInfoStoreSetup: Record "LSC Retail Setup";
        xICTHeader: Record "LSC Retail ICT Header";
        xTransferRcpt: Record "Transfer Receipt Header";
        xTransferHeader: Record "Transfer Header";
        TransferBuffer: Record DPTransfer;
        BatchRun: Report TransferDPBatch;
        xIctHeader2: Record "LSC Retail ICT Header";
        xDocNo: Code[20];
        ICTDocUpdated: Boolean;
        transac: Record "LSC Transaction Header";
    begin
        xDocNo := '';
        ICTDocUpdated := false;
        if not xInfoStoreSetup.Get then
            Clear(xInfoStoreSetup);

        TransferBuffer.Reset();
        TransferBuffer.SetFilter(DocNo, '<>%1', '');
        if TransferBuffer.FindFirst() then
            repeat
                TransferBuffer.Delete(true);
            until TransferBuffer.next = 0;

        xICTHeader.Reset;
        xICTHeader.SetCurrentKey("Source TableNo");
        xICTHeader.SetRange("Source TableNo", 83);
        xICTHeader.SetRange(xICTHeader."Dist. Location To", xInfoStoreSetup."Distribution Location");
        xICTHeader.SetRange(xICTHeader.Status, xICTHeader.Status::Open);
        xICTHeader.SetRange("Source Code", 'TRANSFER');
        xICTHeader.SetRange(TransferCreated, false);
        if xICTHeader.FindSet then begin
            repeat
                if xDocNo <> xIctHeader."Document No" then begin
                    if xTransferRcpt.Get(xICTHeader."Document No") then begin
                        if not xTransferHeader.Get(xTransferRcpt."Transfer Order No.") then begin
                            TransferBuffer.Init();
                            TransferBuffer.DocNo := xTransferRcpt."No.";
                            if TransferBuffer.Insert() then
                                ICTDocUpdated := true;
                        end;
                    end;
                    xDocNo := xICTHeader."Document No";
                end;
                if ICTDocUpdated then begin
                    xIctHeader2.Get(xICTHeader."ICT BatchNo");
                    xIctHeader2.TransferCreated := true;
                    xIctHeader2.Modify();
                end;
            until xICTHeader.next = 0;
        end;
        BatchRun.Run();
    end;
    //031225

    internal procedure ProcessICTDocSplit(pProcessDistLocation: Code[20])
    var
        xInfoStoreSetup: Record "LSC Retail Setup";
        xICTHeader: Record "LSC Retail ICT Header";
        xICTHeaderTemp: Record "LSC Retail ICT Header" temporary;
        xICTLines: Record "LSC Retail ICT Lines";
        lText001: Label 'Data is missing for ICT BatchNo %1';
    begin
        // Process wating ICT Req. split by Document No.
        if not xInfoStoreSetup.Get then
            Clear(xInfoStoreSetup);

        if GuiAllowed then
            StatWin.Open(Text006 + Text007);

        GetGLSetup;

        xICTHeaderTemp.Reset;
        xICTHeaderTemp.DeleteAll;

        xICTHeader.Reset;
        // xICTHeader.SetCurrentKey(xICTHeader."Dist. Location To");
        // xICTHeader.SetCurrentKey("Source TableNo", "Date Of Status", "Time Of Status", "Dist. Location From");//020126
        xICTHeader.SetCurrentKey("Source TableNo", "Dist. Location From");//020126
        xICTHeader.SetFilter("Source TableNo", '%1|%2|%3', 81, 18001, 18005); //FBTS AA 040126

        xICTHeader.SetRange(xICTHeader."Dist. Location To", xInfoStoreSetup."Distribution Location");
        if pProcessDistLocation <> '' then
            xICTHeader.SetRange(xICTHeader."Dist. Location From", pProcessDistLocation);
        xICTHeader.SetRange(xICTHeader.Status, xICTHeader.Status::Open);
        if xICTHeader.FindSet then begin
            xICTHeaderTemp := xICTHeader;
            repeat
                if GuiAllowed then
                    StatWin.Update(1, xICTHeader."ICT BatchNo");

                if xICTHeader."Number Of Data Lines" <> 0 then begin
                    xICTLines.Reset;
                    xICTLines.SetRange("ICT BatchNo", xICTHeader."ICT BatchNo");
                    if xICTLines.Count <> xICTHeader."Number Of Data Lines" then
                        Error(lText001, xICTHeader."ICT BatchNo");
                end;

                if SameICTDocSet(xICTHeaderTemp, xICTHeader) then begin
                    xICTHeaderTemp := xICTHeader;
                    IF xICTHeader."Source TableNo" = 81 then
                        if xICTHeader."Source Code" = 'TRANSFER' then
                            xICTHeaderTemp."Source code" := '';
                    xICTHeaderTemp.Insert;
                end else begin
                    // if ProcessICTDocSplitSet(xICTHeaderTemp) then begin
                    ProcessICTDocSplitSet(xICTHeaderTemp);
                    xICTHeaderTemp.Reset;
                    xICTHeaderTemp.DeleteAll;
                    xICTHeaderTemp := xICTHeader;
                    xICTHeaderTemp.Insert;
                    //   end;
                end;
            until xICTHeader.Next = 0;
            // if ProcessICTDocSplitSet(xICTHeaderTemp) then;
            ProcessICTDocSplitSet(xICTHeaderTemp);
        end;

        //FBTS AA 040126
        xICTHeaderTemp.Reset;
        xICTHeaderTemp.DeleteAll;

        xICTHeader.Reset;
        // xICTHeader.SetCurrentKey(xICTHeader."Dist. Location To");
        xICTHeader.SetCurrentKey("Source TableNo", "Date Of Status", "Dist. Location From", "Time Of Status");//020126
        xICTHeader.SetRange(xICTHeader."Dist. Location To", xInfoStoreSetup."Distribution Location");
        xICTHeader.SetRange("Source Code", 'POSITIVE');
        if pProcessDistLocation <> '' then
            xICTHeader.SetRange(xICTHeader."Dist. Location From", pProcessDistLocation);
        xICTHeader.SetRange(xICTHeader.Status, xICTHeader.Status::Open);
        if xICTHeader.FindSet then begin
            xICTHeaderTemp := xICTHeader;
            repeat
                if GuiAllowed then
                    StatWin.Update(1, xICTHeader."ICT BatchNo");

                if xICTHeader."Number Of Data Lines" <> 0 then begin
                    xICTLines.Reset;
                    xICTLines.SetRange("ICT BatchNo", xICTHeader."ICT BatchNo");
                    if xICTLines.Count <> xICTHeader."Number Of Data Lines" then
                        Error(lText001, xICTHeader."ICT BatchNo");
                end;

                if SameICTDocSet(xICTHeaderTemp, xICTHeader) then begin
                    xICTHeaderTemp := xICTHeader;
                    xICTHeaderTemp.Insert;
                end else begin
                    // if ProcessICTDocSplitSet(xICTHeaderTemp) then begin
                    ProcessICTDocSplitSet(xICTHeaderTemp);
                    xICTHeaderTemp.Reset;
                    xICTHeaderTemp.DeleteAll;
                    xICTHeaderTemp := xICTHeader;
                    xICTHeaderTemp.Insert;
                    //   end;
                end;
            until xICTHeader.Next = 0;
            // if ProcessICTDocSplitSet(xICTHeaderTemp) then;
            ProcessICTDocSplitSet(xICTHeaderTemp);
        end;


        xICTHeaderTemp.Reset;
        xICTHeaderTemp.DeleteAll;

        xICTHeader.Reset;
        // xICTHeader.SetCurrentKey(xICTHeader."Dist. Location To");
        xICTHeader.SetCurrentKey("Source TableNo", "Date Of Status", "Dist. Location From", "Time Of Status");//020126
        xICTHeader.SetRange(xICTHeader."Dist. Location To", xInfoStoreSetup."Distribution Location");
        if pProcessDistLocation <> '' then
            xICTHeader.SetRange(xICTHeader."Dist. Location From", pProcessDistLocation);
        xICTHeader.SetRange(xICTHeader.Status, xICTHeader.Status::Open);
        if xICTHeader.FindSet then begin
            xICTHeaderTemp := xICTHeader;
            repeat
                if GuiAllowed then
                    StatWin.Update(1, xICTHeader."ICT BatchNo");

                if xICTHeader."Number Of Data Lines" <> 0 then begin
                    xICTLines.Reset;
                    xICTLines.SetRange("ICT BatchNo", xICTHeader."ICT BatchNo");
                    if xICTLines.Count <> xICTHeader."Number Of Data Lines" then
                        Error(lText001, xICTHeader."ICT BatchNo");
                end;

                if SameICTDocSet(xICTHeaderTemp, xICTHeader) then begin
                    xICTHeaderTemp := xICTHeader;
                    IF xICTHeader."Source TableNo" = 81 then
                        if xICTHeader."Source Code" = 'TRANSFER' then
                            xICTHeaderTemp."Source code" := '';
                    xICTHeaderTemp.Insert;
                end else begin
                    // if ProcessICTDocSplitSet(xICTHeaderTemp) then begin
                    ProcessICTDocSplitSet(xICTHeaderTemp);
                    xICTHeaderTemp.Reset;
                    xICTHeaderTemp.DeleteAll;
                    xICTHeaderTemp := xICTHeader;
                    xICTHeaderTemp.Insert;
                    //   end;
                end;
            until xICTHeader.Next = 0;
            // if ProcessICTDocSplitSet(xICTHeaderTemp) then;
            ProcessICTDocSplitSet(xICTHeaderTemp);
        end;
        //FBTS AA 040126

        if GuiAllowed then
            StatWin.Close;
    end;

    // [TryFunction]
    local procedure ProcessICTDocSplitSet(var pICTHeader: Record "LSC Retail ICT Header")
    var
        xICTHeader: Record "LSC Retail ICT Header";
        xICTHeader2: Record "LSC Retail ICT Header";
        xGenJournalLine: Record "Gen. Journal Line";
        xGenJournalTemplate: Record "Gen. Journal Template";
        xGenJournalBatch: Record "Gen. Journal Batch";
        xICTSetup: Record "LSC Retail ICT Setup";
        xDocNo: Code[20];
    begin
        // Process wating ICT Req. split by Document No.
        Clear(GenJnlPostLine);
        xICTHeader.LockTable;

        // pICTHeader.Reset;
        // pICTHeader.SetRange(Status, pICTHeader.Status::Open);
        // if pICTHeader.FindSet then
        //     repeat
        //         if (pICTHeader."Source TableNo" in [18001, 18005]) then begin
        //             if GuiAllowed then
        //                 StatWin.Update(2, pICTHeader."ICT BatchNo");

        //             xICTHeader.Get(pICTHeader."ICT BatchNo");
        //             xICTHeader.TestField(Status, xICTHeader.Status::Open);

        //             if xICTHeader."Source Type" = xICTHeader."Source Type"::GL then begin
        //                 if xICTHeader."Source TableNo" = 18001 then
        //                     ProcessDtldGSTLedgEntryMirror(xICTHeader);
        //                 // ProcessGSTLedgEntryInfoMirror(xICTHeader);
        //                 if xICTHeader."Source TableNo" = 18005 then
        //                     ProcessGSTLedgEntryMirror(xICTHeader);
        //             end;

        //             xICTHeader2.Get(xICTHeader."ICT BatchNo");
        //             xICTHeader2.TestField(Status, xICTHeader2.Status::Open);
        //             xICTHeader2.Status := xICTHeader2.Status::Closed;
        //             xICTHeader2."Date Of Status" := Today;
        //             xICTHeader2."Time Of Status" := Time;
        //             xICTHeader2."Destination ItemLedgerEntryNo" := xICTHeader."Destination ItemLedgerEntryNo";
        //             xICTHeader2.Modify;
        //         end;
        //     until pICTHeader.Next = 0;


        pICTHeader.Reset;
        pICTHeader.SetRange(Status, pICTHeader.Status::Open);
        if pICTHeader.FindSet then begin
            repeat
                // if (pICTHeader."Source TableNo" <> 18001) or (pICTHeader."Source TableNo" <> 18005) then begin
                if GuiAllowed then
                    StatWin.Update(2, pICTHeader."ICT BatchNo");

                xICTHeader.Get(pICTHeader."ICT BatchNo");
                xICTHeader.TestField(Status, xICTHeader.Status::Open);

                OpenFinishedProdOrder(xICTHeader."Document No");

                if xICTHeader."Source Type" = xICTHeader."Source Type"::GL then begin
                    if xICTHeader."Source TableNo" = 18001 then
                        ProcessDtldGSTLedgEntryMirror(xICTHeader);
                    if xICTHeader."Source TableNo" = 18005 then
                        ProcessGSTLedgEntryMirror(xICTHeader);
                    if xICTHeader."Source TableNo" = 81 then
                        ProcessGLJMirror(xICTHeader);
                end
                else
                    ProcessIJMirror(xICTHeader);

                xICTHeader2.Get(xICTHeader."ICT BatchNo");
                xICTHeader2.TestField(Status, xICTHeader2.Status::Open);
                xICTHeader2.Status := xICTHeader2.Status::Closed;
                xICTHeader2."Date Of Status" := Today;
                xICTHeader2."Time Of Status" := Time;
                xICTHeader2."Destination ItemLedgerEntryNo" := xICTHeader."Destination ItemLedgerEntryNo";
                //031225
                //   IF xICTHeader."Source TableNo" = 81 then
                //    if xICTHeader."Source Code" = 'TRANSFER' then
                // xICTHeader2."Source code" := '';
                //031225
                xICTHeader2.Modify;
            // end;
            until pICTHeader.Next = 0;
            CloseReleasedProdOrder;
            Commit;

            Clear(GenJnlPostLine);

        end;
    end;

    internal procedure SameICTDocSet(var pICTHeader1: Record "LSC Retail ICT Header"; var pICTHeader2: Record "LSC Retail ICT Header"): Boolean
    var
        SameSet: Boolean;
    begin
        //SameICTDocSet
        if pICTHeader1."Source TableNo" = 81 then begin
            if (pICTHeader1."Source Type" = pICTHeader2."Source Type") and
              (pICTHeader1."Dist. Location From" = pICTHeader2."Dist. Location From") and
              (pICTHeader1."Source TableNo" = pICTHeader2."Source TableNo") and
              (pICTHeader1."Source Code" = pICTHeader2."Source Code") and
              (pICTHeader1."Register No." = pICTHeader2."Register No.")
            then
                SameSet := true
            else
                SameSet := false;
        end else begin
            if (pICTHeader1."Source Type" = pICTHeader2."Source Type") and
              (pICTHeader1."Dist. Location From" = pICTHeader2."Dist. Location From") and
              (pICTHeader1."Document No" = pICTHeader2."Document No") and
              (pICTHeader1."Source TableNo" = pICTHeader2."Source TableNo") and
              (pICTHeader1."Source Code" = pICTHeader2."Source Code")
            then
                SameSet := true
            else
                SameSet := false;
        end;

        exit(SameSet);
    end;

    local procedure ProcessGLJMirror(var pICTHeader: Record "LSC Retail ICT Header")
    var
        xICTSetup: Record "LSC Retail ICT Setup";
        xGenJournalTemplate: Record "Gen. Journal Template";
        xGenJournalBatch: Record "Gen. Journal Batch";
        xGenJournalLine: Record "Gen. Journal Line";
        xLineNo: Integer;
        xRecRef: RecordRef;
    // g: page "General Journal Batches"
    begin
        //Process Gen Journal Mirror Req.
        xICTSetup.Get(pICTHeader."Dist. Location To");

        xGenJournalTemplate.Get(xICTSetup."General Journal");
        xGenJournalBatch.Get(xGenJournalTemplate.Name, Text001);

        xGenJournalLine.LockTable;
        xGenJournalLine.Reset;
        xGenJournalLine.SetRange(xGenJournalLine."Journal Template Name", xGenJournalTemplate.Name);
        xGenJournalLine.SetRange(xGenJournalLine."Journal Batch Name", xGenJournalBatch.Name);
        if xGenJournalLine.FindLast() then
            xLineNo := xGenJournalLine."Line No."
        else
            xLineNo := 0;

        xGenJournalLine.Init;
        xRecRef.GetTable(xGenJournalLine);
        GetICTLines(pICTHeader, xRecRef, 0, 0);
        xRecRef.SetTable(xGenJournalLine);
        xGenJournalLine."Journal Template Name" := xGenJournalTemplate.Name;
        xGenJournalLine."Journal Batch Name" := xGenJournalBatch.Name;
        xLineNo := xLineNo + 10000;
        xGenJournalLine."Line No." := xLineNo;
        if xICTSetup."Source Code" <> '' then
            xGenJournalLine."Source Code" := xICTSetup."Source Code";
        xGenJournalLine."LSC InStore-Created Entry" := true;
        xGenJournalLine."Dimension Set ID" := GetAndUpdateDimSetID(pICTHeader, 0);
        if xICTSetup.Debug then
            xGenJournalLine.Insert
        else
            GenJnlPostLine.RunWithCheck(xGenJournalLine);

    end;

    local procedure ProcessIJMirror(var pICTHeader: Record "LSC Retail ICT Header")
    var
        xICTSetup: Record "LSC Retail ICT Setup";
        xItemJournalTemplate: Record "Item Journal Template";
        xItemJournalBatch: Record "Item Journal Batch";
        xItemJournalLine: Record "Item Journal Line";
        xLineNo: Integer;
        xRecRef: RecordRef;
        xDiscLedgerEntry: Record "LSC Discount Ledger Entry";
        xICTRecNo: Record "LSC Retail ICT Lines" temporary;
        xItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        xItemJournalLineTemp: Record "Item Journal Line";
        xDiscLedgerEntryTemp: Record "LSC Discount Ledger Entry" temporary;
        xItem: Record Item;
        lText001: Label 'Debug not supported for transaction %1 with discount ledger entries';
        RetailItemJnlExt: Codeunit "LSC Retail Item Jnl. Ext.";
    begin
        //Process Item Journal Mirror Req.
        xICTSetup.Get(pICTHeader."Dist. Location To");

        xItemJournalTemplate.Get(xICTSetup."Item Journal");
        xItemJournalBatch.Get(xItemJournalTemplate.Name, Text001);

        xItemJournalLine.LockTable;
        xItemJournalLine.Reset;
        xItemJournalLine.SetRange(xItemJournalLine."Journal Template Name", xItemJournalTemplate.Name);
        xItemJournalLine.SetRange(xItemJournalLine."Journal Batch Name", xItemJournalBatch.Name);
        if xItemJournalLine.FindLast then
            xLineNo := xItemJournalLine."Line No."
        else
            xLineNo := 0;

        xItemJournalLine.Init;
        xRecRef.GetTable(xItemJournalLine);
        GetICTLines(pICTHeader, xRecRef, 0, 0);
        xRecRef.SetTable(xItemJournalLine);
        xItemJournalLine."Journal Template Name" := xItemJournalTemplate.Name;
        xItemJournalLine."Journal Batch Name" := xItemJournalBatch.Name;
        xLineNo := xLineNo + 10000;
        xItemJournalLine."Line No." := xLineNo;
        if xICTSetup."Source Code" <> '' then
            xItemJournalLine."Source Code" := xICTSetup."Source Code";
        xItemJournalLine."LSC InStore-Created Entry" := true;

        if xICTSetup."Item Journal Dest. Unit Cost" then begin
            xItemJournalLineTemp := xItemJournalLine;
            xItemJournalLine."Line No." := 0;
            xItemJournalLine."Phys. Inventory" := false;
            xItemJournalLine.Validate(xItemJournalLine."Item No.");
            xItemJournalLine.Validate("Unit of Measure Code", xItemJournalLineTemp."Unit of Measure Code");
            xItemJournalLine."Unit Amount" := xItemJournalLineTemp."Unit Amount";
            xItemJournalLine.Validate(xItemJournalLine.Quantity);
            xItemJournalLine."Phys. Inventory" := xItemJournalLineTemp."Phys. Inventory";
            xItemJournalLine."Shortcut Dimension 1 Code" := xItemJournalLineTemp."Shortcut Dimension 1 Code";
            xItemJournalLine."Shortcut Dimension 2 Code" := xItemJournalLineTemp."Shortcut Dimension 2 Code";
            xItemJournalLine."Line No." := xItemJournalLineTemp."Line No.";
        end;

        if pICTHeader."Standalone Store Action" = pICTHeader."Standalone Store Action"::"Stock Count" then begin
            xItem.Get(xItemJournalLine."Item No.");
            xItem.SetRange("Date Filter", 0D, xItemJournalLine."Posting Date");
            xItem.SetFilter("Location Filter", xItemJournalLine."Location Code");
            xItem.SetFilter("Variant Filter", xItemJournalLine."Variant Code");
            xItem.CalcFields("Net Change");
            xItemJournalLine."Qty. (Calculated)" := xItem."Net Change";
            xItemJournalLine.Validate("Qty. (Phys. Inventory)");
        end;

        if (xItemJournalLine."Serial No." <> '') or (xItemJournalLine."Lot No." <> '') then
            AddItemTracking(xItemJournalLine);
        xItemJournalLine."Lot No." := '';
        xItemJournalLine."New Lot No." := '';
        xItemJournalLine."Serial No." := '';
        xItemJournalLine."New Serial No." := '';
        xItemJournalLine."Dimension Set ID" := GetAndUpdateDimSetID(pICTHeader, 0);
        xDiscLedgerEntryTemp.Reset;
        xDiscLedgerEntryTemp.DeleteAll;
        GetICTRecNo(pICTHeader, 99001659, 0, true, xICTRecNo);
        if xICTRecNo.FindSet then
            repeat
                xDiscLedgerEntry.Init;
                xRecRef.GetTable(xDiscLedgerEntry);
                GetICTLines(pICTHeader, xRecRef, xICTRecNo.PrimRecNo, xICTRecNo.SecRecNo);
                xRecRef.SetTable(xDiscLedgerEntry);
                if xICTSetup.Debug then
                    Error(lText001, pICTHeader."ICT BatchNo");
                xDiscLedgerEntryTemp.TransferFields(xDiscLedgerEntry);
                xDiscLedgerEntryTemp.Insert;
            until xICTRecNo.Next = 0;
        if xICTSetup.Debug then
            xItemJournalLine.Insert
        else begin
            RetailItemJnlExt.SetDiscLedgerBuffer(xItemJournalLine, xDiscLedgerEntryTemp);
            xItemJnlPostLine.RunWithCheck(xItemJournalLine);
            RetailItemJnlExt.ClearDiscLedgerBuffer(xItemJournalLine);
            pICTHeader."Destination ItemLedgerEntryNo" := xItemJournalLine."Item Shpt. Entry No.";
        end;
    end;

    procedure GetICTLines(var pICTHeader: Record "LSC Retail ICT Header"; var pRecRef: RecordRef; pPrimRecNo: Integer; pSecRecNo: Integer)
    var
        xICTLines: Record "LSC Retail ICT Lines";
        xLine: Text[250];
        xFieldNo: Integer;
        xField: Record "Field";
        xValue: Variant;
        xAnswer: Text[250];
        xRecField: FieldRef;
    begin
        //Get record data from ICT Lines
        xICTLines.Reset;
        xICTLines.SetRange(xICTLines."ICT BatchNo", pICTHeader."ICT BatchNo");
        xICTLines.SetRange(xICTLines.TableNo, pRecRef.Number);
        xICTLines.SetRange(xICTLines.PrimRecNo, pPrimRecNo);
        xICTLines.SetRange(xICTLines.SecRecNo, pSecRecNo);
        if xICTLines.FindSet then
            repeat
                xLine := xICTLines.DataLine;
                while (xLine <> '') do begin
                    xFieldNo := FindFieldNo(xLine);
                    if not xField.Get(pRecRef.Number, xFieldNo) then begin
                        xValue := ICTFunctions.Txt2Txt(xLine, xAnswer);
                    end
                    else begin
                        xRecField := pRecRef.Field(xFieldNo);
                        xAnswer := ICTFunctions.GetFieldValue(pRecRef.Number, xRecField, xLine, xValue);
                        xRecField.Value := xValue;
                    end;
                    if xAnswer <> '' then
                        Error(xAnswer);
                end;
            until xICTLines.Next = 0;
    end;

    procedure GLJnlLineMirror(var pGenJournalLine: Record "Gen. Journal Line"; var pGLRegister: Record "G/L Register")
    var
        xInfoStoreSetup: Record "LSC Retail Setup";
        xICTSetup: Record "LSC Retail ICT Setup";
        xICTHeader: Record "LSC Retail ICT Header";
        xRecRef: RecordRef;
        xGenJournalLine: Record "Gen. Journal Line";
        xICTSetupTemp: Record "LSC Retail ICT Setup" temporary;
    // f: Codeunit 10001416
    begin
        //Create Gen Journal Mirror Req.
        if not xInfoStoreSetup.Get then
            Clear(xInfoStoreSetup);
        if not xICTSetup.Get(xInfoStoreSetup."Distribution Location") then
            exit;
        if pGenJournalLine."LSC InStore-Created Entry" then
            exit;

        xICTSetupTemp.Reset;
        xICTSetupTemp.DeleteAll;
        GetGLJDestDatabaseID(pGenJournalLine, xICTSetupTemp, xInfoStoreSetup."Distribution Location");

        xICTSetupTemp.Reset;
        if xICTSetupTemp.FindSet then
            repeat
                GetGLSetup;
                xICTSetup.LockTable;
                xICTSetup.Get(xInfoStoreSetup."Distribution Location");
                xICTSetup."ICT BatchNo" := IncStr(xICTSetup."ICT BatchNo");
                xICTSetup.Modify;

                xICTHeader.Init;
                xICTHeader."ICT BatchNo" := xICTSetup."ICT BatchNo";
                xICTHeader."Dist. Location From" := xInfoStoreSetup."Distribution Location";
                xICTHeader."Dist. Location To" := xICTSetupTemp."Dist. Location";
                xICTHeader."Source Type" := xICTHeader."Source Type"::GL;
                xICTHeader."Source ID" := pGenJournalLine."Shortcut Dimension 1 Code";
                xICTHeader."Source Code" := pGenJournalLine."Source Code";
                xICTHeader."Register No." := pGLRegister."No.";
                xICTHeader."Document No" := pGenJournalLine."Document No.";
                xICTHeader."Source TableNo" := 81;
                xICTHeader."Destination Type" := xICTHeader."Destination Type"::"GL Account";
                xICTHeader."Date Of Status" := Today;
                xICTHeader."Time Of Status" := Time;

                xGenJournalLine.TransferFields(pGenJournalLine);
                xGenJournalLine."Posting No. Series" := '';
                xRecRef.GetTable(xGenJournalLine);
                CreateICTLines(xICTHeader, xRecRef, 0, 0);

                CreateICTDimSet(xICTHeader, pGenJournalLine."Dimension Set ID", 0);

                xICTHeader.Insert(true);
            until xICTSetupTemp.Next = 0;
    end;

    internal procedure IJnlLineMirror(var pItemJournalLine: Record "Item Journal Line"; var pDiscLedgerEntry: Record "LSC Discount Ledger Entry")
    var
        xInfoStoreSetup: Record "LSC Retail Setup";
        xICTSetup: Record "LSC Retail ICT Setup";
        xICTHeader: Record "LSC Retail ICT Header";
        xRecRef: RecordRef;
        xSecRecNo: Integer;
        xItemJournalLine: Record "Item Journal Line";
        xDiscLedgerEntry: Record "LSC Discount Ledger Entry";
        xICTSetupTemp: Record "LSC Retail ICT Setup" temporary;
    begin
        //Create Item Journal Mirror Req.
        if not xInfoStoreSetup.Get then
            Clear(xInfoStoreSetup);
        if not xICTSetup.Get(xInfoStoreSetup."Distribution Location") then
            exit;
        if pItemJournalLine."LSC InStore-Created Entry" then
            exit;
        if not IsIJnlLineQtyPosting(pItemJournalLine) then
            exit;

        xICTSetupTemp.Reset;
        xICTSetupTemp.DeleteAll;
        GetIJDestDatabaseID(pItemJournalLine, xICTSetupTemp, xInfoStoreSetup."Distribution Location");

        xICTSetupTemp.Reset;
        if xICTSetupTemp.FindSet then
            repeat
                GetGLSetup;
                xICTSetup.LockTable;
                xICTSetup.Get(xInfoStoreSetup."Distribution Location");
                xICTSetup."ICT BatchNo" := IncStr(xICTSetup."ICT BatchNo");
                xICTSetup.Modify;

                xICTHeader.Init;
                xICTHeader."ICT BatchNo" := xICTSetup."ICT BatchNo";
                xICTHeader."Dist. Location From" := xInfoStoreSetup."Distribution Location";
                xICTHeader."Dist. Location To" := xICTSetupTemp."Dist. Location";
                xICTHeader."Source Type" := xICTHeader."Source Type"::Stock;
                xICTHeader."Source ID" := pItemJournalLine."Location Code";
                xICTHeader."Source Code" := pItemJournalLine."Source Code";
                xICTHeader."Document No" := pItemJournalLine."Document No.";
                xICTHeader."Source TableNo" := 83;
                xICTHeader."Destination Type" := xICTHeader."Destination Type"::"Stock Location";
                xICTHeader."Date Of Status" := Today;
                xICTHeader."Time Of Status" := Time;
                xICTHeader."Standalone Store Action" := pItemJournalLine."LSC Standalone Store Action";
                if xICTHeader."Standalone Store Action" = pItemJournalLine."LSC Standalone Store Action"::"No Mirroring" then begin
                    xICTHeader.Status := xICTHeader.Status::Closed;
                    xICTHeader."Date Of Status" := Today;
                    xICTHeader."Time Of Status" := Time;
                end;

                xItemJournalLine.TransferFields(pItemJournalLine);
                xItemJournalLine."Posting No. Series" := '';
                xItemJournalLine."Applies-to Entry" := 0;
                xItemJournalLine."Item Shpt. Entry No." := 0;
                xItemJournalLine."Applies-from Entry" := 0;
                xItemJournalLine."Applies-to Value Entry" := 0;

                xRecRef.GetTable(xItemJournalLine);
                CreateICTLines(xICTHeader, xRecRef, 0, 0);

                CreateICTDimSet(xICTHeader, pItemJournalLine."Dimension Set ID", 0);
                xSecRecNo := 0;
                if pDiscLedgerEntry.FindSet then
                    repeat
                        xSecRecNo := xSecRecNo + 1;
                        xDiscLedgerEntry.TransferFields(pDiscLedgerEntry);
                        xRecRef.GetTable(xDiscLedgerEntry);
                        CreateICTLines(xICTHeader, xRecRef, 0, xSecRecNo);
                    until pDiscLedgerEntry.Next = 0;
                xICTHeader.Insert(true);
            until xICTSetupTemp.Next = 0;
    end;

    procedure CreateICTLines(var pICTHeader: Record "LSC Retail ICT Header"; var pRecRef: RecordRef; pPrimRecNo: Integer; pSecRecNo: Integer)
    var
        xICTLines: Record "LSC Retail ICT Lines";
        xRecField: FieldRef;
        xRecKey: KeyRef;
        xRecKeyField: FieldRef;
        TempField: Record "Field" temporary;
        i: Integer;
        xDataline: Text[250];
        xFieldDataline: Text[250];
        xLineNo: Integer;
        xFieldData: Text[250];
        xField: Record "Field";
        xStringType: Boolean;
    begin
        //Create ICT Line From Record Data
        xLineNo := 0;

        TempField.Reset;
        TempField.DeleteAll;

        xRecKey := pRecRef.KeyIndex(1);
        for i := 1 to xRecKey.FieldCount do begin
            xRecKeyField := xRecKey.FieldIndex(i);
            xRecField := xRecKeyField;
            xDataline := xDataline + '{' + Format(xRecField.Number) + '}' + ICTFunctions.FormatFieldValue(pRecRef.Number, xRecField);
            TempField.Init;
            TempField.TableNo := pRecRef.Number;
            TempField."No." := xRecField.Number;
            TempField.Insert;
        end;

        if StrLen(xDataline) > 170 then
            Error(Text003 + ICTFunctions.CleanUpString(xDataline));

        for i := 1 to pRecRef.FieldCount do begin
            xRecField := pRecRef.FieldIndex(i);
            xField.Get(pRecRef.Number, xRecField.Number);
            xFieldDataline := '';
            if (xField.Class = xField.Class::Normal) and (xField.Type <> xField.Type::BLOB) and (xField.Enabled) then begin
                if not TempField.Get(pRecRef.Number, xRecField.Number) then begin
                    xFieldData := ICTFunctions.FormatFieldValue(pRecRef.Number, xRecField);
                    if (xField.Type = xField.Type::Code) or (xField.Type = xField.Type::Text) then
                        xStringType := true
                    else
                        xStringType := false;
                    if (xFieldData = ';') or ((xFieldData = '0;') and (not xStringType)) then
                        xFieldDataline := ''
                    else
                        xFieldDataline := '{' + Format(xRecField.Number) + '}' + ICTFunctions.FormatFieldValue(pRecRef.Number, xRecField);
                end;
            end;
            if StrLen(xDataline) + StrLen(xFieldDataline) > 170 then begin
                xLineNo := xLineNo + 1;
                xICTLines.Init;
                xICTLines."ICT BatchNo" := pICTHeader."ICT BatchNo";
                xICTLines.TableNo := pRecRef.Number;
                xICTLines.PrimRecNo := pPrimRecNo;
                xICTLines.SecRecNo := pSecRecNo;
                xICTLines.DataLineNo := xLineNo;
                xICTLines.DataLine := xDataline;
                xICTLines.Insert;
                xDataline := '';
            end;
            if StrLen(xFieldDataline) > 170 then
                Error(Text004 + ICTFunctions.CleanUpString(xFieldDataline))
            else
                xDataline := xDataline + xFieldDataline;
        end;
        if xDataline <> '' then begin
            xLineNo := xLineNo + 1;
            xICTLines.Init;
            xICTLines."ICT BatchNo" := pICTHeader."ICT BatchNo";
            xICTLines.TableNo := pRecRef.Number;
            xICTLines.PrimRecNo := pPrimRecNo;
            xICTLines.SecRecNo := pSecRecNo;
            xICTLines.DataLineNo := xLineNo;
            xICTLines.DataLine := xDataline;
            xICTLines.Insert;
            xDataline := '';
        end;
    end;

    local procedure FindFieldNo(var pLine: Text[260]): Integer
    var
        lAnswer: Integer;
        lTxt: Text[260];
        lPos: Integer;
    begin
        lTxt := '';
        lPos := StrPos(pLine, '}');
        if lPos > 0 then begin
            lTxt := CopyStr(CopyStr(pLine, 1, lPos - 1), 2);
            pLine := CopyStr(pLine, lPos + 1, 260);
        end;

        if not Evaluate(lAnswer, lTxt) then begin
            lAnswer := 0;
        end;
        exit(lAnswer);
    end;

    local procedure GetICTRecNo(var pICTHeader: Record "LSC Retail ICT Header"; pTableNo: Integer; pPrimRecNo: Integer; UsePrimRecFilter: Boolean; var pICTLines: Record "LSC Retail ICT Lines")
    var
        xICTLines: Record "LSC Retail ICT Lines";
        xSecRecNo: Integer;
    begin
        pICTLines.Reset;
        pICTLines.DeleteAll;

        xICTLines.Reset;
        xICTLines.SetRange(xICTLines."ICT BatchNo", pICTHeader."ICT BatchNo");
        xICTLines.SetRange(xICTLines.TableNo, pTableNo);
        if UsePrimRecFilter then
            xICTLines.SetRange(xICTLines.PrimRecNo, pPrimRecNo);
        if xICTLines.FindSet then
            repeat
                if UsePrimRecFilter then
                    xSecRecNo := xICTLines.SecRecNo
                else
                    xSecRecNo := 0;
                if not pICTLines.Get(pICTHeader."ICT BatchNo", pTableNo, xICTLines.PrimRecNo, xSecRecNo) then begin
                    pICTLines.Init;
                    pICTLines."ICT BatchNo" := pICTHeader."ICT BatchNo";
                    pICTLines.TableNo := pTableNo;
                    pICTLines.PrimRecNo := xICTLines.PrimRecNo;
                    pICTLines.SecRecNo := xSecRecNo;
                    pICTLines.Insert;
                end;
            until xICTLines.Next = 0;
    end;

    local procedure GetGLSetup()
    begin
        if not GLSetupRead then begin
            GLSetup.Get;
            GLSetupRead := true;
        end;
    end;

    local procedure GetGLJDestDatabaseID(var pGenJournalLine: Record "Gen. Journal Line"; var pICTSetupTemp: Record "LSC Retail ICT Setup"; pDatabaseID: Code[20])
    var
        xICTSourceLinks: Record "LSC Retail ICT Source Links";
    begin
        xICTSourceLinks.Reset;
        xICTSourceLinks.SetRange(xICTSourceLinks."Dist. Location From", pDatabaseID);
        xICTSourceLinks.SetRange(xICTSourceLinks."Source Type", xICTSourceLinks."Source Type"::"General Ledger");
        xICTSourceLinks.SetFilter(xICTSourceLinks."Source Code", '%1|%2', '', pGenJournalLine."Source Code");
        xICTSourceLinks.SetFilter(xICTSourceLinks."Source ID", '%1|%2', '', pGenJournalLine."Shortcut Dimension 1 Code");
        if xICTSourceLinks.FindSet then
            repeat
                if not pICTSetupTemp.Get(xICTSourceLinks."Dist. Location To") then begin
                    pICTSetupTemp.Init;
                    pICTSetupTemp."Dist. Location" := xICTSourceLinks."Dist. Location To";
                    pICTSetupTemp.Insert;
                end;
            until xICTSourceLinks.Next = 0;
    end;


    local procedure GetIJDestDatabaseID(var pItemJournalLine: Record "Item Journal Line"; var pICTSetupTemp: Record "LSC Retail ICT Setup"; pDatabaseID: Code[20])
    var
        xICTSourceLinks: Record "LSC Retail ICT Source Links";
    begin
        xICTSourceLinks.Reset;
        xICTSourceLinks.SetRange(xICTSourceLinks."Dist. Location From", pDatabaseID);
        xICTSourceLinks.SetRange(xICTSourceLinks."Source Type", xICTSourceLinks."Source Type"::Stock);
        xICTSourceLinks.SetFilter(xICTSourceLinks."Source Code", '%1|%2', '', pItemJournalLine."Source Code");
        xICTSourceLinks.SetFilter(xICTSourceLinks."Source ID", '%1|%2', '', pItemJournalLine."Location Code");
        if xICTSourceLinks.FindSet then
            repeat
                if not pICTSetupTemp.Get(xICTSourceLinks."Dist. Location To") then begin
                    pICTSetupTemp.Init;
                    pICTSetupTemp."Dist. Location" := xICTSourceLinks."Dist. Location To";
                    pICTSetupTemp.Insert;
                end;
            until xICTSourceLinks.Next = 0;
        if pItemJournalLine."Entry Type" = pItemJournalLine."Entry Type"::Transfer then begin
            xICTSourceLinks.SetFilter(xICTSourceLinks."Source ID", '%1|%2', '', pItemJournalLine."New Location Code");
            if xICTSourceLinks.FindSet then
                repeat
                    if not pICTSetupTemp.Get(xICTSourceLinks."Dist. Location To") then begin
                        pICTSetupTemp.Init;
                        pICTSetupTemp."Dist. Location" := xICTSourceLinks."Dist. Location To";
                        pICTSetupTemp.Insert;
                    end;
                until xICTSourceLinks.Next = 0;
        end;
    end;

    internal procedure IsIJnlLineQtyPosting(var pIJnlLine: Record "Item Journal Line"): Boolean
    begin
        if (pIJnlLine.Quantity <> 0) and (pIJnlLine."Item Charge No." = '') and
          not (pIJnlLine."Value Entry Type" in [pIJnlLine."Value Entry Type"::Revaluation, pIJnlLine."Value Entry Type"::Rounding]) and
          not pIJnlLine.Adjustment
        then
            exit(true)
        else
            exit(false);
    end;

    internal procedure AddItemTracking(var pItemJournalLine: Record "Item Journal Line")
    var
        ReservationEntry: Record "Reservation Entry";
        LastEntry: Integer;
    begin
        ReservationEntry.LockTable;
        ReservationEntry.Reset;
        if ReservationEntry.FindLast then
            LastEntry := ReservationEntry."Entry No."
        else
            LastEntry := 0;
        ReservationEntry.Init;
        ReservationEntry."Entry No." := LastEntry + 1;
        if (pItemJournalLine."Entry Type" = pItemJournalLine."Entry Type"::"Positive Adjmt.") or
           (pItemJournalLine."Entry Type" = pItemJournalLine."Entry Type"::Purchase) then
            ReservationEntry.Positive := true
        else
            ReservationEntry.Positive := false;
        ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Prospect;
        ReservationEntry."Source Type" := Database::"Item Journal Line";
        ReservationEntry."Source ID" := pItemJournalLine."Journal Template Name";
        ReservationEntry."Source Batch Name" := pItemJournalLine."Journal Batch Name";
        ReservationEntry."Source Ref. No." := pItemJournalLine."Line No.";
        ReservationEntry."Source Subtype" := pItemJournalLine."Entry Type".AsInteger();
        ReservationEntry."Creation Date" := pItemJournalLine."Posting Date";
        ReservationEntry."Item No." := pItemJournalLine."Item No.";
        ReservationEntry."Variant Code" := pItemJournalLine."Variant Code";
        ReservationEntry.Description := pItemJournalLine.Description;
        ReservationEntry."Lot No." := pItemJournalLine."Lot No.";
        ReservationEntry."Serial No." := pItemJournalLine."Serial No.";
        ReservationEntry."Warranty Date" := pItemJournalLine."Warranty Date";
        ReservationEntry."Expiration Date" := pItemJournalLine."Expiration Date";
        ReservationEntry."Qty. per Unit of Measure" := pItemJournalLine."Qty. per Unit of Measure";
        ReservationEntry."Location Code" := pItemJournalLine."Location Code";
        ReservationEntry."Created By" := pItemJournalLine."LSC Create UserID";
        if pItemJournalLine."Entry Type" = pItemJournalLine."Entry Type"::Transfer then begin
            ReservationEntry."New Lot No." := pItemJournalLine."New Lot No.";
            ReservationEntry."New Serial No." := pItemJournalLine."New Serial No.";
            ReservationEntry."New Expiration Date" := pItemJournalLine."New Item Expiration Date"
        end;
        if ReservationEntry.Positive then begin
            ReservationEntry.Quantity := pItemJournalLine.Quantity;
            ReservationEntry."Quantity (Base)" := pItemJournalLine."Quantity (Base)";
        end else begin
            ReservationEntry.Quantity := -pItemJournalLine.Quantity;
            ReservationEntry."Quantity (Base)" := -pItemJournalLine."Quantity (Base)";
        end;
        ReservationEntry."Qty. to Handle (Base)" := ReservationEntry."Quantity (Base)";
        ReservationEntry."Qty. to Invoice (Base)" := ReservationEntry."Quantity (Base)";
        ReservationEntry.Insert;
    end;

    internal procedure GetLastReplCounter(): Integer
    var
        xICTHeader: Record "LSC Retail ICT Header";
    begin
        xICTHeader.Reset;
        xICTHeader.SetCurrentKey(xICTHeader."Replication Counter");
        if not xICTHeader.FindLast then
            Clear(xICTHeader);
        exit(xICTHeader."Replication Counter");
    end;

    internal procedure ShowJnlData(var pICTHeader: Record "LSC Retail ICT Header")
    var
        xTableNo: Integer;
        xGenJournalLine: Record "Gen. Journal Line";
        xLineNo: Integer;
        xRecRef: RecordRef;
        xGenJournalLineTemp: Record "Gen. Journal Line" temporary;
        xItemJournalLine: Record "Item Journal Line";
        xItemJournalLineTemp: Record "Item Journal Line" temporary;
        lText001: Label 'You can only view records from the same table.';
    begin
        if pICTHeader.FindSet then begin
            xTableNo := pICTHeader."Source TableNo";
            repeat
                if pICTHeader."Source TableNo" <> xTableNo then
                    Error(lText001);

                if xTableNo = 81 then begin
                    xGenJournalLine.Init;
                    xRecRef.GetTable(xGenJournalLine);
                    GetICTLines(pICTHeader, xRecRef, 0, 0);
                    xRecRef.SetTable(xGenJournalLine);
                    xLineNo := xLineNo + 10000;
                    xGenJournalLine."Line No." := xLineNo;
                    xGenJournalLineTemp.Init;
                    xGenJournalLineTemp := xGenJournalLine;
                    xGenJournalLineTemp.Insert;
                end else
                    if xTableNo = 83 then begin
                        xItemJournalLine.Init;
                        xRecRef.GetTable(xItemJournalLine);
                        GetICTLines(pICTHeader, xRecRef, 0, 0);
                        xRecRef.SetTable(xItemJournalLine);
                        xLineNo := xLineNo + 10000;
                        xItemJournalLine."Line No." := xLineNo;
                        xItemJournalLineTemp.Init;
                        xItemJournalLineTemp := xItemJournalLine;
                        xItemJournalLineTemp.Insert;
                    end;
            until pICTHeader.Next = 0;

            if xTableNo = 81 then begin
                PAGE.RunModal(10001376, xGenJournalLineTemp);
            end else
                if xTableNo = 83 then begin
                    PAGE.RunModal(10001377, xItemJournalLineTemp);
                end;
        end;
    end;

    internal procedure CloseAndMoveToJnl(var pICTHeader: Record "LSC Retail ICT Header")
    var
        xRetailSetup: Record "LSC Retail Setup";
        xICTSetup: Record "LSC Retail ICT Setup";
        xGenJournalTemplate: Record "Gen. Journal Template";
        xGenJournalBatch: Record "Gen. Journal Batch";
        xGenJournalLine: Record "Gen. Journal Line";
        xGenLineNo: Integer;
        xItemLineNo: Integer;
        xRecRef: RecordRef;
        xItemJournalTemplate: Record "Item Journal Template";
        xItemJournalBatch: Record "Item Journal Batch";
        xItemJournalLine: Record "Item Journal Line";
        xItemJournalLineTemp: Record "Item Journal Line";
        xICTRecNo: Record "LSC Retail ICT Lines" temporary;
        xICTHeader: Record "LSC Retail ICT Header";
        lText002: Label 'You can only move records to be processed at current location (%1).';
        lText003: Label 'You can not move transactions with discount ledger entries';
    begin
        xRetailSetup.Get;

        if pICTHeader.FindSet then begin
            if pICTHeader."Dist. Location To" <> xRetailSetup."Distribution Location" then
                Error(lText002, xRetailSetup."Distribution Location");
            xICTSetup.Get(pICTHeader."Dist. Location To");

            if xICTSetup."General Journal" <> '' then begin
                xGenJournalTemplate.Get(xICTSetup."General Journal");
                xGenJournalBatch.Get(xGenJournalTemplate.Name, Text001);
                xGenJournalLine.LockTable;
                xGenJournalLine.Reset;
                xGenJournalLine.SetRange(xGenJournalLine."Journal Template Name", xGenJournalTemplate.Name);
                xGenJournalLine.SetRange(xGenJournalLine."Journal Batch Name", xGenJournalBatch.Name);
                if xGenJournalLine.FindLast then
                    xGenLineNo := xGenJournalLine."Line No."
                else
                    xGenLineNo := 0;
            end;
            if xICTSetup."Item Journal" <> '' then begin
                xItemJournalTemplate.Get(xICTSetup."Item Journal");
                xItemJournalBatch.Get(xItemJournalTemplate.Name, Text001);
                xItemJournalLine.LockTable;
                xItemJournalLine.Reset;
                xItemJournalLine.SetRange(xItemJournalLine."Journal Template Name", xItemJournalTemplate.Name);
                xItemJournalLine.SetRange(xItemJournalLine."Journal Batch Name", xItemJournalBatch.Name);
                if xItemJournalLine.FindLast then
                    xItemLineNo := xItemJournalLine."Line No."
                else
                    xItemLineNo := 0;
            end;

            repeat
                pICTHeader.TestField(Status, pICTHeader.Status::Open);
                if pICTHeader."Dist. Location To" <> xRetailSetup."Distribution Location" then
                    Error(lText002, xRetailSetup."Distribution Location");

                if pICTHeader."Source TableNo" = 81 then begin
                    xGenJournalTemplate.Get(xICTSetup."General Journal");
                    xGenJournalLine.Init;
                    xRecRef.GetTable(xGenJournalLine);
                    GetICTLines(pICTHeader, xRecRef, 0, 0);
                    xRecRef.SetTable(xGenJournalLine);
                    xGenJournalLine."Journal Template Name" := xGenJournalTemplate.Name;
                    xGenJournalLine."Journal Batch Name" := xGenJournalBatch.Name;
                    xGenLineNo := xGenLineNo + 10000;
                    xGenJournalLine."Line No." := xGenLineNo;
                    if xICTSetup."Source Code" <> '' then
                        xGenJournalLine."Source Code" := xICTSetup."Source Code";
                    xGenJournalLine."LSC InStore-Created Entry" := true;
                    xGenJournalLine."Dimension Set ID" := GetAndUpdateDimSetID(pICTHeader, 0);
                    xGenJournalLine.Insert;
                end else
                    if pICTHeader."Source TableNo" = 83 then begin
                        xItemJournalTemplate.Get(xICTSetup."Item Journal");
                        xItemJournalLine.Init;
                        xRecRef.GetTable(xItemJournalLine);
                        GetICTLines(pICTHeader, xRecRef, 0, 0);
                        xRecRef.SetTable(xItemJournalLine);
                        xItemLineNo := xItemLineNo + 10000;
                        xItemJournalLine."Line No." := xItemLineNo;
                        xItemJournalLine."Journal Template Name" := xItemJournalTemplate.Name;
                        xItemJournalLine."Journal Batch Name" := xItemJournalBatch.Name;
                        if xICTSetup."Source Code" <> '' then
                            xItemJournalLine."Source Code" := xICTSetup."Source Code";
                        xItemJournalLine."LSC InStore-Created Entry" := true;
                        xItemJournalLine.Insert;
                        if xICTSetup."Item Journal Dest. Unit Cost" then begin
                            xItemJournalLineTemp := xItemJournalLine;
                            xItemJournalLine."Line No." := 0;
                            xItemJournalLine."Phys. Inventory" := false;
                            xItemJournalLine.Validate(xItemJournalLine."Item No.");
                            xItemJournalLine.Validate("Unit of Measure Code", xItemJournalLineTemp."Unit of Measure Code");
                            xItemJournalLine."Unit Amount" := xItemJournalLineTemp."Unit Amount";
                            xItemJournalLine.Validate(xItemJournalLine.Quantity);
                            xItemJournalLine."Phys. Inventory" := xItemJournalLineTemp."Phys. Inventory";
                            xItemJournalLine."Shortcut Dimension 1 Code" := xItemJournalLineTemp."Shortcut Dimension 1 Code";
                            xItemJournalLine."Shortcut Dimension 2 Code" := xItemJournalLineTemp."Shortcut Dimension 2 Code";
                            xItemJournalLine."Line No." := xItemJournalLineTemp."Line No.";
                        end;
                        if (xItemJournalLine."Serial No." <> '') or (xItemJournalLine."Lot No." <> '') then
                            AddItemTracking(xItemJournalLine);
                        xItemJournalLine."Lot No." := '';
                        xItemJournalLine."New Lot No." := '';
                        xItemJournalLine."Serial No." := '';
                        xItemJournalLine."New Serial No." := '';
                        xGenJournalLine."Dimension Set ID" := GetAndUpdateDimSetID(pICTHeader, 0);
                        xItemJournalLine.Modify;
                        GetICTRecNo(pICTHeader, 99001659, 0, true, xICTRecNo);
                        if not xICTRecNo.IsEmpty then
                            Error(lText003);
                    end;
                xICTHeader.Get(pICTHeader."ICT BatchNo");
                xICTHeader.Status := xICTHeader.Status::Closed;
                xICTHeader."Date Of Status" := Today;
                xICTHeader."Time Of Status" := Time;
                xICTHeader.Modify;
            until pICTHeader.Next = 0;
        end;
    end;

    internal procedure GetAndUpdateDimSetID(var pICTHeader: Record "LSC Retail ICT Header"; pPrimRecNo: Integer): Integer
    var
        xRecRef: RecordRef;
        xICTRecNo: Record "LSC Retail ICT Lines" temporary;
        xDimSet: Record "Dimension Set Entry";
        xDimSetTemp: Record "Dimension Set Entry" temporary;
    begin
        //GetAndUpdateDimSetID
        xDimSetTemp.Reset;
        xDimSetTemp.DeleteAll;

        GetICTRecNo(pICTHeader, 480, pPrimRecNo, true, xICTRecNo);
        if xICTRecNo.FindSet then
            repeat
                xDimSet.Init;
                xRecRef.GetTable(xDimSet);
                GetICTLines(pICTHeader, xRecRef, xICTRecNo.PrimRecNo, xICTRecNo.SecRecNo);
                xRecRef.SetTable(xDimSet);
                xDimSetTemp.Init;
                xDimSetTemp := xDimSet;
                xDimSetTemp."Dimension Set ID" := 0;
                xDimSetTemp.Insert(true);
            until xICTRecNo.Next = 0;

        exit(DimMgt.GetDimensionSetID(xDimSetTemp));
    end;

    internal procedure CreateICTDimSet(var pICTHeader: Record "LSC Retail ICT Header"; pDimSetID: Integer; pPrimRecNo: Integer)
    var
        xRecRef: RecordRef;
        xSecRecNo: Integer;
        xDimSet: Record "Dimension Set Entry";
    begin
        //CreateICTDimSet
        xSecRecNo := 0;
        xDimSet.Reset;
        xDimSet.SetRange("Dimension Set ID", pDimSetID);
        if xDimSet.FindSet then
            repeat
                xSecRecNo := xSecRecNo + 1;
                xRecRef.GetTable(xDimSet);
                CreateICTLines(pICTHeader, xRecRef, pPrimRecNo, xSecRecNo);
            until xDimSet.Next = 0;
    end;

    local procedure GetStoreDimension(pTransHeader: Record "Transfer Header"; pFieldNo: Integer; var DimensionCode: Code[20])
    var
        SourceCodeSetup: Record "Source Code Setup";
        Store: Record "LSC Store";
        DimMgt: Codeunit DimensionManagement;
        CodeDictionary: Dictionary of [Integer, Code[20]];
        DimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        SourceCodeSetup.Get;
        case pFieldNo of
            pTransHeader.FieldNo("LSC Store-from"):
                begin
                    Store.Get(pTransHeader."LSC Store-from");
                    CodeDictionary.Add(Database::"LSC Store", Store."No.");
                    DimSource.Add(CodeDictionary);
                    pTransHeader."Dimension Set ID" :=
                        DimMgt.GetDefaultDimID(DimSource, SourceCodeSetup.Transfer, Store."Global Dimension 1 Code", Store."Global Dimension 2 Code", 0, 0);
                end;
            pTransHeader.FieldNo("LSC Store-to"):
                begin
                    Store.Get(pTransHeader."LSC Store-to");
                    CodeDictionary.Add(Database::"LSC Store", Store."No.");
                    DimSource.Add(CodeDictionary);
                    pTransHeader."LSC New Dimension Set ID" :=
                        DimMgt.GetDefaultDimID(DimSource, SourceCodeSetup.Transfer, Store."Global Dimension 1 Code", Store."Global Dimension 2 Code", 0, 0);
                end;
            else
                exit;
        end;

        DimensionCode := Store."Global Dimension 1 Code";
    end;

    //FBTS YM 131025
    local procedure GetDtldGSTLedgEntryDestDbID(var pGenJournalLine: Record "Detailed GST Ledger Entry"; var pICTSetupTemp: Record "LSC Retail ICT Setup"; pDatabaseID: Code[20])
    var
        xICTSourceLinks: Record "LSC Retail ICT Source Links";
    begin
        xICTSourceLinks.Reset;
        xICTSourceLinks.SetRange(xICTSourceLinks."Dist. Location From", pDatabaseID);
        xICTSourceLinks.SetRange(xICTSourceLinks."Source Type", xICTSourceLinks."Source Type"::"General Ledger");
        // xICTSourceLinks.SetFilter(xICTSourceLinks."Source Code", '%1|%2', '', pGenJournalLine."Source Code");
        // xICTSourceLinks.SetFilter(xICTSourceLinks."Source ID", '%1|%2', '', pGenJournalLine."Shortcut Dimension 1 Code");
        if xICTSourceLinks.FindSet then
            repeat
                if not pICTSetupTemp.Get(xICTSourceLinks."Dist. Location To") then begin
                    pICTSetupTemp.Init;
                    pICTSetupTemp."Dist. Location" := xICTSourceLinks."Dist. Location To";
                    pICTSetupTemp.Insert;
                end;
            until xICTSourceLinks.Next = 0;
    end;

    procedure DtldGSTLedgEntryMirror(VAR pDtldGSTLedgEntry: Record "Detailed GST Ledger Entry")
    var
        xInfoStoreSetup: Record "LSC Retail Setup";
        xICTSetup: Record "LSC Retail ICT Setup";
        xICTSourceLinks: Record "LSC Retail ICT Source Links";
        xICTHeader: Record "LSC Retail ICT Header";
        xRecRef: RecordRef;
        xDtldGSTLedgEntry: Record "Detailed GST Ledger Entry";
        xICTSetupTemp: Record "LSC Retail ICT Setup" temporary;
        xAmount: XmlDeclaration;
        gst: Codeunit "GST Transfer Order Shipment";
    begin
        //Create Detailed GST Ledger Entry Mirror Req.
        xInfoStoreSetup.GET;
        IF NOT xICTSetup.GET(xInfoStoreSetup."Distribution Location") THEN
            EXIT;

        xICTSetupTemp.RESET;
        xICTSetupTemp.DELETEALL;
        GetDtldGSTLedgEntryDestDbID(pDtldGSTLedgEntry, xICTSetupTemp, xInfoStoreSetup."Distribution Location");
        xICTSetupTemp.RESET;
        IF xICTSetupTemp.FIND('-') THEN
            REPEAT
                GetGLSetup;
                xICTSetup.LOCKTABLE;
                xICTSetup.GET(xInfoStoreSetup."Distribution Location");
                xICTSetup."ICT BatchNo" := INCSTR(xICTSetup."ICT BatchNo");
                xICTSetup.MODIFY;

                xICTHeader.INIT;
                xICTHeader."ICT BatchNo" := xICTSetup."ICT BatchNo";
                // xICTHeader."ICT Type" := xICTHeader."ICT Type"::Mirror;
                xICTHeader."Dist. Location From" := xInfoStoreSetup."Distribution Location";
                xICTHeader."Dist. Location To" := xICTSetupTemp."Dist. Location";
                xICTHeader."Source Type" := xICTHeader."Source Type"::GL;
                xICTHeader."Document No" := pDtldGSTLedgEntry."Document No.";
                xICTHeader."Source TableNo" := 18001;
                // xICTHeader."Link Type" := xICTHeader."Link Type"::"GL Account";
                xICTHeader."Destination Type" := xICTHeader."Destination Type"::"GL Account";
                xICTHeader."Date Of Status" := TODAY;
                xICTHeader."Time Of Status" := TIME;

                xDtldGSTLedgEntry.TRANSFERFIELDS(pDtldGSTLedgEntry);
                xRecRef.GETTABLE(xDtldGSTLedgEntry);
                CreateICTLines(xICTHeader, xRecRef, 0, 0);

                xICTHeader.INSERT(TRUE);
            UNTIL xICTSetupTemp.NEXT = 0;
    end;

    LOCAL procedure ProcessDtldGSTLedgEntryMirror(VAR pICTHeader: Record "LSC Retail ICT Header")
    var
        xICTSetup: Record "LSC Retail ICT Setup";
        xDtldGSTLedgEntry: Record "Detailed GST Ledger Entry";
        xEntryNo: Integer;
        xRecRef: RecordRef;
    begin
        //Process Detailed GST Ledger Entry Mirror Req.
        xICTSetup.GET(pICTHeader."Dist. Location To");

        xDtldGSTLedgEntry.LOCKTABLE;
        xDtldGSTLedgEntry.RESET;
        IF xDtldGSTLedgEntry.FINDLAST THEN
            xEntryNo := xDtldGSTLedgEntry."Entry No."
        ELSE
            xEntryNo := 0;

        xDtldGSTLedgEntry.INIT;
        xRecRef.GETTABLE(xDtldGSTLedgEntry);
        GetICTLines(pICTHeader, xRecRef, 0, 0);
        xRecRef.SETTABLE(xDtldGSTLedgEntry);

        xEntryNo += 1;
        xDtldGSTLedgEntry."Entry No." := xEntryNo;
        xDtldGSTLedgEntry.INSERT
    End;

    procedure GSTLedgEntryMirror(VAR pDtldGSTLedgEntry: Record "GST Ledger Entry")
    var
        xInfoStoreSetup: Record "LSC Retail Setup";
        xICTSetup: Record "LSC Retail ICT Setup";
        xICTSourceLinks: Record "LSC Retail ICT Source Links";
        xICTHeader: Record "LSC Retail ICT Header";
        xRecRef: RecordRef;
        xDtldGSTLedgEntry: Record "GST Ledger Entry";
        xICTSetupTemp: Record "LSC Retail ICT Setup" temporary;
        xAmount: XmlDeclaration;
    begin
        //Create GST Ledger Entry Mirror Req.
        xInfoStoreSetup.GET;
        IF NOT xICTSetup.GET(xInfoStoreSetup."Distribution Location") THEN
            EXIT;

        xICTSetupTemp.RESET;
        xICTSetupTemp.DELETEALL;
        GetGSTLedgEntryDestDbID(pDtldGSTLedgEntry, xICTSetupTemp, xInfoStoreSetup."Distribution Location");
        xICTSetupTemp.RESET;
        IF xICTSetupTemp.FIND('-') THEN
            REPEAT
                GetGLSetup;
                xICTSetup.LOCKTABLE;
                xICTSetup.GET(xInfoStoreSetup."Distribution Location");
                xICTSetup."ICT BatchNo" := INCSTR(xICTSetup."ICT BatchNo");
                xICTSetup.MODIFY;

                xICTHeader.INIT;
                xICTHeader."ICT BatchNo" := xICTSetup."ICT BatchNo";
                // xICTHeader."ICT Type" := xICTHeader."ICT Type"::Mirror;
                xICTHeader."Dist. Location From" := xInfoStoreSetup."Distribution Location";
                xICTHeader."Dist. Location To" := xICTSetupTemp."Dist. Location";
                xICTHeader."Source Type" := xICTHeader."Source Type"::GL;
                xICTHeader."Document No" := pDtldGSTLedgEntry."Document No.";
                xICTHeader."Source TableNo" := 18005;
                // xICTHeader."Link Type" := xICTHeader."Link Type"::"GL Account";
                xICTHeader."Destination Type" := xICTHeader."Destination Type"::"GL Account";
                xICTHeader."Date Of Status" := TODAY;
                xICTHeader."Time Of Status" := TIME;

                xDtldGSTLedgEntry.TRANSFERFIELDS(pDtldGSTLedgEntry);
                xRecRef.GETTABLE(xDtldGSTLedgEntry);
                CreateICTLines(xICTHeader, xRecRef, 0, 0);

                xICTHeader.INSERT(TRUE);
            UNTIL xICTSetupTemp.NEXT = 0;
    end;

    local procedure GetGSTLedgEntryDestDbID(var pGenJournalLine: Record "GST Ledger Entry"; var pICTSetupTemp: Record "LSC Retail ICT Setup"; pDatabaseID: Code[20])
    var
        xICTSourceLinks: Record "LSC Retail ICT Source Links";
    begin
        xICTSourceLinks.Reset;
        xICTSourceLinks.SetRange(xICTSourceLinks."Dist. Location From", pDatabaseID);
        xICTSourceLinks.SetRange(xICTSourceLinks."Source Type", xICTSourceLinks."Source Type"::"General Ledger");
        // xICTSourceLinks.SetFilter(xICTSourceLinks."Source Code", '%1|%2', '', pGenJournalLine."Source Code");
        // xICTSourceLinks.SetFilter(xICTSourceLinks."Source ID", '%1|%2', '', pGenJournalLine."Shortcut Dimension 1 Code");
        if xICTSourceLinks.FindSet then
            repeat
                if not pICTSetupTemp.Get(xICTSourceLinks."Dist. Location To") then begin
                    pICTSetupTemp.Init;
                    pICTSetupTemp."Dist. Location" := xICTSourceLinks."Dist. Location To";
                    pICTSetupTemp.Insert;
                end;
            until xICTSourceLinks.Next = 0;
    end;

    LOCAL procedure ProcessGSTLedgEntryMirror(VAR pICTHeader: Record "LSC Retail ICT Header")
    var
        xICTSetup: Record "LSC Retail ICT Setup";
        xGSTLedgEntry: Record "GST Ledger Entry";
        xEntryNo: Integer;
        xRecRef: RecordRef;
    begin
        //Process GST Ledger Entry Mirror Req.
        xICTSetup.GET(pICTHeader."Dist. Location To");

        xGSTLedgEntry.LOCKTABLE;
        xGSTLedgEntry.RESET;
        IF xGSTLedgEntry.FINDLAST THEN
            xEntryNo := xGSTLedgEntry."Entry No."
        ELSE
            xEntryNo := 0;

        xGSTLedgEntry.INIT;
        xRecRef.GETTABLE(xGSTLedgEntry);
        GetICTLines(pICTHeader, xRecRef, 0, 0);
        xRecRef.SETTABLE(xGSTLedgEntry);

        xEntryNo += 1;
        xGSTLedgEntry."Entry No." := xEntryNo;
        xGSTLedgEntry.INSERT
    End;


    procedure GSTLedgEntryInfoMirror(VAR pDtldGSTLedgEntry: Record "Detailed GST Ledger Entry Info")
    var
        xInfoStoreSetup: Record "LSC Retail Setup";
        xICTSetup: Record "LSC Retail ICT Setup";
        xICTSourceLinks: Record "LSC Retail ICT Source Links";
        xICTHeader: Record "LSC Retail ICT Header";
        xRecRef: RecordRef;
        xDtldGSTLedgEntry: Record "Detailed GST Ledger Entry Info";
        xICTSetupTemp: Record "LSC Retail ICT Setup" temporary;
        xAmount: XmlDeclaration;
    begin
        //Create GST Ledger Entry Mirror Req.
        xInfoStoreSetup.GET;
        IF NOT xICTSetup.GET(xInfoStoreSetup."Distribution Location") THEN
            EXIT;

        xICTSetupTemp.RESET;
        xICTSetupTemp.DELETEALL;
        GetGSTLedgEntryInfoDestDbID(pDtldGSTLedgEntry, xICTSetupTemp, xInfoStoreSetup."Distribution Location");
        xICTSetupTemp.RESET;
        IF xICTSetupTemp.FIND('-') THEN
            REPEAT
                GetGLSetup;
                xICTSetup.LOCKTABLE;
                xICTSetup.GET(xInfoStoreSetup."Distribution Location");
                xICTSetup."ICT BatchNo" := INCSTR(xICTSetup."ICT BatchNo");
                xICTSetup.MODIFY;

                xICTHeader.INIT;
                xICTHeader."ICT BatchNo" := xICTSetup."ICT BatchNo";
                // xICTHeader."ICT Type" := xICTHeader."ICT Type"::Mirror;
                xICTHeader."Dist. Location From" := xInfoStoreSetup."Distribution Location";
                xICTHeader."Dist. Location To" := xICTSetupTemp."Dist. Location";
                xICTHeader."Source Type" := xICTHeader."Source Type"::GL;
                xICTHeader."Document No" := pDtldGSTLedgEntry."Original Doc. No.";
                xICTHeader."Source TableNo" := 18016;
                // xICTHeader."Link Type" := xICTHeader."Link Type"::"GL Account";
                xICTHeader."Destination Type" := xICTHeader."Destination Type"::"GL Account";
                xICTHeader."Date Of Status" := TODAY;
                xICTHeader."Time Of Status" := TIME;

                xDtldGSTLedgEntry.TRANSFERFIELDS(pDtldGSTLedgEntry);
                xRecRef.GETTABLE(xDtldGSTLedgEntry);
                CreateICTLines(xICTHeader, xRecRef, 0, 0);

                xICTHeader.INSERT(TRUE);
            UNTIL xICTSetupTemp.NEXT = 0;
    end;

    local procedure GetGSTLedgEntryInfoDestDbID(var pGenJournalLine: Record "Detailed GST Ledger Entry Info"; var pICTSetupTemp: Record "LSC Retail ICT Setup"; pDatabaseID: Code[20])
    var
        xICTSourceLinks: Record "LSC Retail ICT Source Links";
    begin
        xICTSourceLinks.Reset;
        xICTSourceLinks.SetRange(xICTSourceLinks."Dist. Location From", pDatabaseID);
        xICTSourceLinks.SetRange(xICTSourceLinks."Source Type", xICTSourceLinks."Source Type"::"General Ledger");
        // xICTSourceLinks.SetFilter(xICTSourceLinks."Source Code", '%1|%2', '', pGenJournalLine."Source Code");
        // xICTSourceLinks.SetFilter(xICTSourceLinks."Source ID", '%1|%2', '', pGenJournalLine."Shortcut Dimension 1 Code");
        if xICTSourceLinks.FindSet then
            repeat
                if not pICTSetupTemp.Get(xICTSourceLinks."Dist. Location To") then begin
                    pICTSetupTemp.Init;
                    pICTSetupTemp."Dist. Location" := xICTSourceLinks."Dist. Location To";
                    pICTSetupTemp.Insert;
                end;
            until xICTSourceLinks.Next = 0;
    end;

    LOCAL procedure ProcessGSTLedgEntryInfoMirror(VAR pICTHeader: Record "LSC Retail ICT Header")
    var
        xICTSetup: Record "LSC Retail ICT Setup";
        xGSTLedgEntry: Record "Detailed GST Ledger Entry Info";
        xEntryNo: Integer;
        xRecRef: RecordRef;
    begin
        //Process GST Ledger Entry Mirror Req.
        xICTSetup.GET(pICTHeader."Dist. Location To");

        xGSTLedgEntry.LOCKTABLE;
        xGSTLedgEntry.RESET;
        IF xGSTLedgEntry.FINDLAST THEN
            xEntryNo := xGSTLedgEntry."Entry No."
        ELSE
            xEntryNo := 0;

        xGSTLedgEntry.INIT;
        xRecRef.GETTABLE(xGSTLedgEntry);
        GetICTLines(pICTHeader, xRecRef, 0, 0);
        xRecRef.SETTABLE(xGSTLedgEntry);

        xEntryNo += 1;
        xGSTLedgEntry."Entry No." := xEntryNo;
        xGSTLedgEntry.INSERT
    End;

    LOCAL procedure OpenFinishedProdOrder(ICTDocNo: Code[20])
    var
        DocNo: Code[20];
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        RetailICTHeader: Record "LSC Retail ICT Header";
        PreDocNo: Text;
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        ProdOrderComponent: Record "Prod. Order Component";
        ProdOrder2: Record "Production Order";
        ProdOrderLine2: Record "Prod. Order Line";
        ProdOrderRoutingLine2: Record "Prod. Order Routing Line";
        ProdOrderComponent2: Record "Prod. Order Component";
        ProdOrderLine3: Record "Prod. Order Line";
    begin
        RetailICTHeader.RESET;
        RetailICTHeader.SETCURRENTKEY("Document No");
        RetailICTHeader.SETRANGE("Document No", ICTDocNo);
        RetailICTHeader.SETRANGE("Source Type", RetailICTHeader."Source Type"::Stock);
        RetailICTHeader.SETRANGE("Source TableNo", 83);
        RetailICTHeader.SETRANGE("Source Code", 'PRODORDER');
        RetailICTHeader.SETRANGE(Status, RetailICTHeader.Status::Open);
        IF RetailICTHeader.FINDFIRST THEN
            REPEAT
                IF PreDocNo <> RetailICTHeader."Document No" THEN BEGIN
                    DocNo := RetailICTHeader."Document No";
                    IF ProdOrder.GET(ProdOrder.Status::Released, DocNo) THEN
                        EXIT;
                    ProdOrder.RESET;
                    ProdOrder.SETRANGE(Status, ProdOrder.Status::Finished);
                    ProdOrder.SETRANGE("No.", DocNo);
                    IF ProdOrder.FINDFIRST THEN BEGIN
                        ProdOrder2.INIT;
                        ProdOrder2.TRANSFERFIELDS(ProdOrder);
                        ProdOrder2.Status := ProdOrder2.Status::Released;
                        ProdOrder2."Automatically Finished" := TRUE;
                        ProdOrder2.INSERT;
                        ProdOrder2.VALIDATE("Shortcut Dimension 1 Code", ProdOrder."Shortcut Dimension 1 Code");
                        ProdOrder2.VALIDATE("Shortcut Dimension 2 Code", ProdOrder."Shortcut Dimension 2 Code");
                        ProdOrder2.MODIFY;

                        ProdOrderLine.RESET;
                        ProdOrderLine.SETRANGE("Prod. Order No.", DocNo);
                        ProdOrderLine.SETRANGE(Status, ProdOrderLine.Status::Finished);
                        IF ProdOrderLine.FINDFIRST THEN
                            REPEAT
                                ProdOrderLine2.INIT;
                                ProdOrderLine2.TRANSFERFIELDS(ProdOrderLine);
                                ProdOrderLine2.Status := ProdOrderLine2.Status::Released;
                                ProdOrderLine2."Finished Quantity" := 0;
                                ProdOrderLine2."Finished Qty. (Base)" := 0;
                                ProdOrderLine2."Remaining Quantity" := ProdOrderLine.Quantity;
                                ProdOrderLine2."Remaining Quantity" := ProdOrderLine."Quantity (Base)";
                                ProdOrderLine2.INSERT;
                                ProdOrderLine2.VALIDATE("Shortcut Dimension 1 Code", ProdOrderLine."Shortcut Dimension 1 Code");
                                ProdOrderLine2.VALIDATE("Shortcut Dimension 2 Code", ProdOrderLine."Shortcut Dimension 2 Code");
                                ProdOrderLine2.MODIFY;
                                ProdOrderLine.DELETE;
                            UNTIL ProdOrderLine.NEXT = 0;

                        ProdOrderRoutingLine.RESET;
                        ProdOrderRoutingLine.SETRANGE("Prod. Order No.", DocNo);
                        ProdOrderRoutingLine.SETRANGE(Status, ProdOrderRoutingLine.Status::Finished);
                        IF ProdOrderRoutingLine.FINDFIRST THEN
                            REPEAT
                                ProdOrderRoutingLine2.INIT;
                                ProdOrderRoutingLine2.TRANSFERFIELDS(ProdOrderRoutingLine);
                                ProdOrderRoutingLine2.Status := ProdOrderRoutingLine2.Status::Released;
                                ProdOrderRoutingLine2."Flushing Method" := ProdOrderRoutingLine2."Flushing Method"::Manual;
                                ProdOrderRoutingLine2.INSERT;
                                ProdOrderRoutingLine.DELETE;
                            UNTIL ProdOrderRoutingLine.NEXT = 0;

                        ProdOrderComponent.RESET;
                        ProdOrderComponent.SETRANGE("Prod. Order No.", DocNo);
                        ProdOrderComponent.SETRANGE(Status, ProdOrderComponent.Status::Finished);
                        IF ProdOrderComponent.FINDFIRST THEN
                            REPEAT
                                ProdOrderLine3.RESET;
                                ProdOrderLine3.SETRANGE("Prod. Order No.", ProdOrderComponent."Prod. Order No.");
                                ProdOrderLine3.SETRANGE("Line No.", ProdOrderComponent."Prod. Order Line No.");
                                IF ProdOrderLine3.FINDFIRST THEN;
                                ProdOrderComponent2.INIT;
                                ProdOrderComponent2.TRANSFERFIELDS(ProdOrderComponent);
                                ProdOrderComponent2.Status := ProdOrderComponent2.Status::Released;
                                ProdOrderComponent2."Remaining Quantity" := ProdOrderComponent."Expected Quantity";//Quantity * ProdOrderLine3.Quantity;
                                ProdOrderComponent2."Remaining Qty. (Base)" := ProdOrderComponent."Expected Qty. (Base)";// * ProdOrderLine3."Quantity (Base)";
                                ProdOrderComponent2."Flushing Method" := ProdOrderComponent2."Flushing Method"::Manual;
                                ProdOrderComponent2.INSERT;
                                ProdOrderComponent2.VALIDATE("Shortcut Dimension 1 Code", ProdOrderComponent."Shortcut Dimension 1 Code");
                                ProdOrderComponent2.VALIDATE("Shortcut Dimension 2 Code", ProdOrderComponent."Shortcut Dimension 2 Code");
                                ProdOrderComponent2.MODIFY;
                                ProdOrderComponent.DELETE;
                            UNTIL ProdOrderComponent.NEXT = 0;
                        ProdOrder.DELETE;
                    END ELSE
                        ERROR('Production Order %1 can not be found in System. Please Contact your System Administrator.', RetailICTHeader."Document No");
                    PreDocNo := ProdOrder."No.";
                END;
            UNTIL RetailICTHeader.NEXT = 0;
    end;

    LOCAL procedure CloseReleasedProdOrder()
    var
        ProdOrderStatusManagement: Codeunit "Prod. Order Status Management";
        ProductionOrder: Record "Production Order";
        NewStatus: Option Quote,Planned,"Firm Planned",Released,Finished;
        ProdOrderCommentLine: Record "Prod. Order Comment Line";
        RetailICTHeader: Record "LSC Retail ICT Header";
        f: Report 99001025;
    begin
        NewStatus := NewStatus::Finished;
        ProductionOrder.RESET;
        ProductionOrder.SETRANGE(Status, ProductionOrder.Status::Released);
        ProductionOrder.SETRANGE("Automatically Finished", TRUE);
        IF ProductionOrder.FINDFIRST THEN
            REPEAT
                ProdOrderStatusManagement.ChangeProdOrderStatus(ProductionOrder, NewStatus::Finished, ProductionOrder."Due Date", FALSE);
            UNTIL ProductionOrder.NEXT = 0;
    end;

    //FBTS YM 131025

}

