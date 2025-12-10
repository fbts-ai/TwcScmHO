codeunit 50131 ICT_processed_GST
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Table, Database::"GST Ledger Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure MyProcedure(var Rec: Record "GST Ledger Entry"; RunTrigger: Boolean)
    var
        ICTProcessCustom: Codeunit "ICT Processes_Custom";
        ICTHeader: Record "LSC Retail ICT Header";
        f: Codeunit 10001416;
    // g: Record 480
    begin
        // Rec.Reset();
        // Rec.SetRange("Document No.", GlobalDoc);
        // // rec.SetRange("Posting Date", GenJnlLine."Posting Date");
        //Rec.SetRange("Create ICT", false);
        // if rec.FindFirst() then Begin
        IF NOT Rec."Create ICT" THEN BEGIN
            //     repeat
            rec."Create ICT" := true;
            rec.Modify();
            ICTProcessCustom.GSTLedgEntryMirror(rec);
            //rec."Create ICT" := true;
            //rec.Modify();
            // until rec.next = 0;
        END;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Detailed GST Ledger Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure MyProcedure1(var Rec: Record "Detailed GST Ledger Entry"; RunTrigger: Boolean)
    var
        DetailedGST: Record "Detailed GST Ledger Entry";
        ICTProcessCustom: Codeunit "ICT Processes_Custom";
        GstLedgerEntry: Record "GST Ledger Entry";
        GstLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        g: Codeunit "GST Transfer Order Shipment";
        ICTHeader: Record "LSC Retail ICT Header";
        ICTHeaderDoc: Code[20];
        ICTLine: Record "LSC Retail ICT Lines";
    begin
        // Rec.Reset();
        // Rec.SetRange("Document No.", GlobalDoc);
        // // rec.SetRange("Posting Date", GenJnlLine."Posting Date");
        //Rec.SetRange("Create ICT", false);
        //if Rec.FindFirst() then BEGIN
        IF NOT Rec."Create ICT" THEN BEGIN
            //     repeat
            Rec."Create ICT" := true;
            Rec.Modify();
            ICTProcessCustom.DtldGSTLedgEntryMirror(rec);
            //rec."Create ICT" := true;
            //rec.Modify();
        END;
        // until rec.next = 0;
    end;
    /*
        [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInitGLRegister', '', false, false)]
        local procedure "Gen. Jnl.-Post Line_OnAfterInitGLRegister"(
            var GLRegister: Record "G/L Register";
            var GenJournalLine: Record "Gen. Journal Line")
        var
            DetailedGST: Record "Detailed GST Ledger Entry";
            ICTProcessCustom: Codeunit "ICT Processes_Custom";
            GstLedgerEntry: Record "GST Ledger Entry";
            GstLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
            g: Codeunit "GST Transfer Order Shipment";
            ICTHeader: Record "LSC Retail ICT Header";
            ICTHeaderDoc: Code[20];
            ICTLine: Record "LSC Retail ICT Lines";
        begin

            DetailedGST.Reset();
            DetailedGST.SetRange("Document No.", GenJournalLine."Document No.");
            DetailedGST.SetRange("Posting Date", GenJournalLine."Posting Date");
            DetailedGST.SetRange("Create ICT", false);
            if DetailedGST.FindFirst() then
                repeat
                    ICTProcessCustom.DtldGSTLedgEntryMirror(DetailedGST);
                    DetailedGST."Create ICT" := true;
                    DetailedGST.Modify();
                until DetailedGST.next = 0;

            GlobalDoc := GenJournalLine."Document No.";


            // GstLedgerEntryInfo.Reset();
            // GstLedgerEntryInfo.SetCurrentKey("Original Doc. No.");
            // GstLedgerEntryInfo.SetRange("Original Doc. No.", GenJournalLine."External Document No.");
            // GstLedgerEntryInfo.SetRange("Create ICT", false);
            // if GstLedgerEntryInfo.FindFirst() then
            //     repeat
            //         ICTProcessCustom.GSTLedgEntryInfoMirror(GstLedgerEntryInfo);
            //         GstLedgerEntryInfo."Create ICT" := true;
            //         GstLedgerEntryInfo.Modify();

            //     until GstLedgerEntryInfo.next = 0;
        end;
    */
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeContinuePosting', '', false, false)]
    local procedure "Gen. Jnl.-Post Line_OnBeforeContinuePosting"(
        var GenJournalLine: Record "Gen. Journal Line";
        var GLRegister: Record "G/L Register"; var NextEntryNo: Integer;
        var NextTransactionNo: Integer)
    var
        ICTHeader: Record "LSC Retail ICT Header";
        ICTHeaderDoc: Code[20];
        ICTLine: Record "LSC Retail ICT Lines";
        SalesHeader: Record "Sales Invoice Header";
        DetailedCustLed: Record "Detailed Cust. Ledg. Entry";
        DetailedGstEntry: Record "Detailed GST Ledger Entry";
        GSTAmount: Decimal;
        GSTBaseAmt: Decimal;
        SalesCrMemo: Record "Sales Cr.Memo Header";
        PurchaseHeader: Record "Purch. Inv. Header";
        PurchaseCrHeader: Record "Purch. Cr. Memo Hdr.";
        TDSEntry: Record "Tax Transaction Value";
        TDSAmount: Decimal;
        PurchLine: Record "Purch. Inv. Line";
        LineAmt: Decimal;
    begin
        if GenJournalLine."LSC InStore-Created Entry" then
            exit;

        GSTBaseAmt := 0;
        TDSAmount := 0;
        LineAmt := 0;
        if (GenJournalLine."Source Code" = 'SALES')
        and (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer) then begin
            ICTHeaderDoc := '';
            ICTHeader.Reset();
            ICTHeader.SetRange("Document No", GenJournalLine."Document No.");
            ICTHeader.SetRange("Source TableNo", 81);
            ICTHeader.SetRange(Status, ICTHeader.Status::Open);
            if ICTHeader.FindFirst() then
                repeat
                    if ICTHeaderDoc <> ICTHeader."ICT BatchNo" then begin
                        //Message(GetICTLineFieldNoValue(ICTHeader, 29));
                        if GetICTLineFieldNovalidate(ICTHeader, 0) then begin
                            SalesHeader.Reset();
                            SalesHeader.SetRange("No.", GenJournalLine."Document No.");
                            if SalesHeader.FindFirst() then begin
                                SalesHeader.CalcFields("Remaining Amount");
                                GSTBaseAmt := 0;
                                GSTAmount := 0;
                                DetailedGstEntry.Reset();
                                DetailedGstEntry.SetCurrentKey("Document No.");
                                DetailedGstEntry.SetRange("Document No.", SalesHeader."No.");
                                if DetailedGstEntry.FindFirst() then Begin
                                    repeat
                                        if DetailedGstEntry."GST Component Code" = 'IGST' then
                                            GSTBaseAmt += DetailedGstEntry."GST Base Amount";
                                        if DetailedGstEntry."GST Component Code" = 'CGST' then
                                            GSTBaseAmt += DetailedGstEntry."GST Base Amount";

                                        GSTAmount += DetailedGstEntry."GST Amount";
                                    until DetailedGstEntry.next = 0;

                                END;

                                // DetailedGstEntry.CalcSums("GST Amount", "GST Base Amount");
                                GetICTLineFieldNo(ICTHeader, (abs(GSTBaseAmt) + abs(GSTAmount)));

                            end;

                            SalesCrMemo.Reset();
                            SalesCrMemo.SetRange("No.", GenJournalLine."Document No.");
                            if SalesCrMemo.FindFirst() then begin
                                SalesCrMemo.CalcFields("Remaining Amount");
                                GSTBaseAmt := 0;
                                GSTAmount := 0;

                                DetailedGstEntry.Reset();
                                DetailedGstEntry.SetCurrentKey("Document No.");
                                DetailedGstEntry.SetRange("Document No.", SalesCrMemo."No.");
                                if DetailedGstEntry.FindFirst() then BEGIN
                                    repeat
                                        if DetailedGstEntry."GST Component Code" = 'IGST' then
                                            GSTBaseAmt += DetailedGstEntry."GST Base Amount";
                                        if DetailedGstEntry."GST Component Code" = 'CGST' then
                                            GSTBaseAmt += DetailedGstEntry."GST Base Amount";

                                        GSTAmount += DetailedGstEntry."GST Amount";
                                    until DetailedGstEntry.next = 0;
                                END;
                                // DetailedGstEntry.CalcSums("GST Amount", "GST Base Amount");

                                GetICTLineFieldNo(ICTHeader, -1 * (abs(GSTBaseAmt) + abs(GSTAmount)));

                            end;
                        end;
                    end;
                    ICTHeaderDoc := ICTHeader."ICT BatchNo";
                until ICTHeader.next = 0;
        end;

        //For Purchase Invoice & Credit Memo
        GSTBaseAmt := 0;
        if (GenJournalLine."Source Code" = 'PURCHASES')
        and (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor) then begin
            ICTHeaderDoc := '';
            ICTHeader.Reset();
            ICTHeader.SetRange("Document No", GenJournalLine."Document No.");
            ICTHeader.SetRange("Source TableNo", 81);
            ICTHeader.SetRange(Status, ICTHeader.Status::Open);
            if ICTHeader.FindFirst() then
                repeat
                    if ICTHeaderDoc <> ICTHeader."ICT BatchNo" then begin
                        //Message(GetICTLineFieldNoValue(ICTHeader, 29));
                        if GetICTLineFieldNovalidate(ICTHeader, 0) then begin
                            PurchaseHeader.Reset();
                            PurchaseHeader.SetRange("No.", GenJournalLine."Document No.");
                            if PurchaseHeader.FindFirst() then begin
                                PurchaseHeader.CalcFields("Remaining Amount");
                                GSTBaseAmt := 0;
                                GSTAmount := 0;
                                // DetailedGstEntry.Reset();
                                // DetailedGstEntry.SetRange("Document No.", PurchaseHeader."No.");
                                // if DetailedGstEntry.FindFirst() then Begin
                                //     repeat
                                //         if DetailedGstEntry."GST Component Code" = 'IGST' then
                                //             GSTBaseAmt += DetailedGstEntry."GST Base Amount";
                                //         if DetailedGstEntry."GST Component Code" = 'CGST' then
                                //             GSTBaseAmt += DetailedGstEntry."GST Base Amount";

                                //         GSTAmount += DetailedGstEntry."GST Amount";
                                //     until DetailedGstEntry.next = 0;

                                // END;

                                // // DetailedGstEntry.CalcSums("GST Amount", "GST Base Amount");
                                // GetICTLineFieldNo(ICTHeader, -1 * (abs(GSTBaseAmt) + abs(GSTAmount)));

                                DetailedGstEntry.Reset();//Key need to define
                                DetailedGstEntry.SetCurrentKey("Document No.");
                                DetailedGstEntry.SetRange("Document No.", PurchaseHeader."No.");
                                if DetailedGstEntry.FindFirst() then Begin
                                    repeat
                                        if DetailedGstEntry."GST Component Code" = 'IGST' then
                                            GSTBaseAmt += DetailedGstEntry."GST Base Amount";
                                        if DetailedGstEntry."GST Component Code" = 'CGST' then
                                            GSTBaseAmt += DetailedGstEntry."GST Base Amount";

                                        GSTAmount += DetailedGstEntry."GST Amount";
                                    until DetailedGstEntry.next = 0;

                                END;

                                PurchLine.Reset();
                                PurchLine.SetRange("Document No.", PurchaseHeader."No.");
                                if PurchLine.FindFirst() then
                                    repeat
                                        LineAmt += PurchLine.Amount;
                                        TDSEntry.Reset();
                                        TDSEntry.SetRange("Tax Record ID", PurchLine.RecordId);
                                        TDSEntry.SetRange("Value ID", 1);
                                        TDSEntry.SetFilter(Percent, '<>0');
                                        TDSEntry.SetFilter(Amount, '<>0');
                                        if TDSEntry.FindFirst() then
                                            TDSAmount += TDSEntry.Amount;

                                    until PurchLine.next = 0;
                                if GSTBaseAmt = 0 then
                                    GetICTLineFieldNo(ICTHeader, -1 * (abs(LineAmt - TDSAmount)))
                                else
                                    GetICTLineFieldNo(ICTHeader, -1 * (abs(GSTBaseAmt) + abs(GSTAmount) - abs(TDSAmount)));

                            end;

                            PurchaseCrHeader.Reset();
                            PurchaseCrHeader.SetRange("No.", GenJournalLine."Document No.");
                            if PurchaseCrHeader.FindFirst() then begin
                                PurchaseCrHeader.CalcFields("Remaining Amount");
                                GSTBaseAmt := 0;
                                GSTAmount := 0;

                                DetailedGstEntry.Reset();
                                DetailedGstEntry.SetCurrentKey("Document No.");
                                DetailedGstEntry.SetRange("Document No.", PurchaseCrHeader."No.");
                                if DetailedGstEntry.FindFirst() then BEGIN
                                    repeat
                                        if DetailedGstEntry."GST Component Code" = 'IGST' then
                                            GSTBaseAmt += DetailedGstEntry."GST Base Amount";
                                        if DetailedGstEntry."GST Component Code" = 'CGST' then
                                            GSTBaseAmt += DetailedGstEntry."GST Base Amount";

                                        GSTAmount += DetailedGstEntry."GST Amount";
                                    until DetailedGstEntry.next = 0;
                                END;
                                // DetailedGstEntry.CalcSums("GST Amount", "GST Base Amount");

                                if GSTBaseAmt = 0 then
                                    GetICTLineFieldNo(ICTHeader, (abs(PurchaseCrHeader.Amount)))
                                else
                                    GetICTLineFieldNo(ICTHeader, (abs(GSTBaseAmt) + abs(GSTAmount)));

                            end;
                        end;
                    end;
                    ICTHeaderDoc := ICTHeader."ICT BatchNo";
                until ICTHeader.next = 0;
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assembly-Post", 'OnBeforeDeleteAssemblyDocument', '', false, false)]
    local procedure "Assembly-Post_OnBeforeDeleteAssemblyDocument"(
        AssemblyHeader: Record "Assembly Header"; var IsHandled: Boolean)
    begin
        IsHandled := true;
        AssemblyHeader."Order Posted" := true;
        AssemblyHeader.Modify(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Assembly Document", 'OnBeforeReopenAssemblyDoc', '', false, false)]
    local procedure "Release Assembly Document_OnBeforeReopenAssemblyDoc"(var AssemblyHeader: Record "Assembly Header")
    begin
        if AssemblyHeader."Order Posted" then
            Error('User cannot Open this Order in Posted state');
    end;
    //ICT
    [EventSubscriber(ObjectType::Table, Database::"Transfer Header", OnBeforeDeleteOneTransferOrder, '', false, false)]
    local procedure "Transfer Header_OnBeforeDeleteOneTransferOrder"(
        var TransHeader2: Record "Transfer Header";
        var TransLine2: Record "Transfer Line"; var IsHandled: Boolean)
    begin
        if TransHeader2."Direct Transfer" then begin
            IsHandled := true;
            TransHeader2."Direct Transfer Posted" := true;
            TransHeader2.Modify();
        end;
    end;
    //ICT

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforePostGenJnlLine', '', false, false)]
    // local procedure "Gen. Jnl.-Post Line_OnBeforePostGenJnlLine"(
    //     var Sender: Codeunit "Gen. Jnl.-Post Line";
    //     var GenJournalLine: Record "Gen. Journal Line"; Balancing: Boolean)
    // var
    //     ICTHeader: Record "LSC Retail ICT Header";
    //     ICTHeaderDoc: Code[20];
    //     ICTLine: Record "LSC Retail ICT Lines";
    // begin
    //     if GenJournalLine."Source Code" = 'SALES' then begin
    //         ICTHeaderDoc := '';
    //         ICTHeader.Reset();
    //         ICTHeader.SetRange("Document No", GenJournalLine."Document No.");
    //         ICTHeader.SetRange("Source TableNo", 81);
    //         ICTHeader.SetRange(Status, ICTHeader.Status::Open);
    //         if ICTHeader.FindFirst() then
    //             repeat
    //                 if ICTHeaderDoc <> ICTHeader."ICT BatchNo" then begin
    //                     Message(GetICTLineFieldNoValue(ICTHeader, 29));
    //                 end;
    //                 ICTHeaderDoc := ICTHeader."ICT BatchNo";
    //             until ICTHeader.next = 0;
    //     end;
    // end;

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

    local procedure GetICTLineFieldNovalidate(var pICTHeader: Record "LSC Retail ICT Header"; FieldNo: Integer): Boolean
    var
        xICTLines: Record "LSC Retail ICT Lines";
        xLine: Text[250];
        xFieldNo: Integer;
        xField: Record "Field";
        xValue: Variant;
        xAnswer: Text[250];
        xRecField: FieldRef;
        ICTFunctions: Codeunit "ICT Functions_Custom";
        SalesHeaderTemp: Record "Sales Header" temporary;
        SaveSetofFields: array[10] of Text;
        I: Integer;
        SaveValueSet: array[10] of Text;
        FlagOk1: Boolean;
        FlagOk2: Boolean;
        FlagOk3: Boolean;
        FlagOk4: Boolean;
    begin
        //Get record data from ICT Lines
        if not SalesHeaderTemp.IsTemporary then
            Exit;

        SalesHeaderTemp.DeleteAll();
        FlagOk1 := false;
        xICTLines.Reset;
        xICTLines.SetRange(xICTLines."ICT BatchNo", pICTHeader."ICT BatchNo");
        xICTLines.SetRange(xICTLines.TableNo, 81);
        // xICTLines.SetRange(xICTLines.PrimRecNo, pPrimRecNo);
        // xICTLines.SetRange(xICTLines.SecRecNo, pSecRecNo);
        if xICTLines.FindSet then
            repeat
                xLine := xICTLines.DataLine;
                SalesHeaderTemp.DeleteAll();
                while (xLine <> '') do begin
                    xFieldNo := FindFieldNo(xLine);
                    if xField.Get(81, xFieldNo) then begin
                        xValue := ICTFunctions.Txt2Txt(xLine, xAnswer);
                    end;
                    //For Sales Invoice & Credit Memo
                    if xFieldNo in [3] then
                        if Format(xValue) in ['1'] then begin
                            FlagOk1 := true;
                        End;
                    //For Purchase Invoice & Credit Memo , using SalesHeaderTemp temp table to just store the value
                    if xFieldNo in [3] then
                        if Format(xValue) in ['2'] then begin
                            FlagOk1 := true;
                        End;
                End;
            // FlagOk1 := false;
            // FlagOk2 := false;
            // FlagOk3 := false;
            // FlagOk4 := false;
            // for i := 1 to 4 do begin
            //     if (SaveSetofFields[i] = '3') and (Format(SaveValueSet[i]) = '1') then
            //         FlagOk1 := true;

            //     if (SaveSetofFields[i] = '4') and (Format(SaveValueSet[i]) <> '') then
            //         FlagOk2 := true;

            //     if (SaveSetofFields[i] = '29') and (Format(SaveValueSet[i]) = 'SALES') then
            //         FlagOk3 := true;

            //     if (SaveSetofFields[i] = '30') and (Format(SaveValueSet[i]) = '1') then
            //         FlagOk4 := true;

            // end;
            until xICTLines.Next = 0;

        if FlagOk1 then begin
            FlagOk1 := false;
            xICTLines.Reset;
            xICTLines.SetRange(xICTLines."ICT BatchNo", pICTHeader."ICT BatchNo");
            xICTLines.SetRange(xICTLines.TableNo, 81);
            // xICTLines.SetRange(xICTLines.PrimRecNo, pPrimRecNo);
            // xICTLines.SetRange(xICTLines.SecRecNo, pSecRecNo);
            if xICTLines.FindSet then
                repeat
                    xLine := xICTLines.DataLine;
                    while (xLine <> '') do begin
                        xFieldNo := FindFieldNo(xLine);
                        if xField.Get(81, xFieldNo) then begin
                            xValue := ICTFunctions.Txt2Txt(xLine, xAnswer);
                        end;
                        SalesHeaderTemp.init;
                        SalesHeaderTemp."No." := Format(xFieldNo);
                        SalesHeaderTemp."Bill-to Name" := xValue;
                        SalesHeaderTemp.Insert();

                    End;
                until xICTLines.next = 0;

            SalesHeaderTemp.Reset();
            // SalesHeaderTemp.SetFilter("No.", '%1|%2|%3|%4', '3', '4', '29', '30');
            if SalesHeaderTemp.FindFirst() then
                repeat
                    if (SalesHeaderTemp."No." = '3') and (SalesHeaderTemp."Bill-to Name" = '1') then
                        FlagOk1 := true;

                    if (SalesHeaderTemp."No." = '4') and (SalesHeaderTemp."Bill-to Name" <> '') then
                        FlagOk2 := true;

                    if (SalesHeaderTemp."No." = '29') and (SalesHeaderTemp."Bill-to Name" = 'SALES') then
                        FlagOk3 := true;

                    if (SalesHeaderTemp."No." = '30') and (SalesHeaderTemp."Bill-to Name" = '1') then
                        FlagOk4 := true;

                until (SalesHeaderTemp.next = 0) or (FlagOk1 and FlagOk2 and FlagOk3 and FlagOk4);

            //For Purchase Invoice & Credit Memo, Checking ICT Line condition
            SalesHeaderTemp.Reset();
            // SalesHeaderTemp.SetFilter("No.", '%1|%2|%3|%4', '3', '4', '29', '30');
            if SalesHeaderTemp.FindFirst() then
                repeat
                    if (SalesHeaderTemp."No." = '3') and (SalesHeaderTemp."Bill-to Name" = '2') then
                        FlagOk1 := true;

                    if (SalesHeaderTemp."No." = '4') and (SalesHeaderTemp."Bill-to Name" <> '') then
                        FlagOk2 := true;

                    if (SalesHeaderTemp."No." = '29') and (SalesHeaderTemp."Bill-to Name" = 'PURCHASES') then
                        FlagOk3 := true;

                    if (SalesHeaderTemp."No." = '30') and (SalesHeaderTemp."Bill-to Name" = '1') then
                        FlagOk4 := true;

                until (SalesHeaderTemp.next = 0) or (FlagOk1 and FlagOk2 and FlagOk3 and FlagOk4);
        End;

        if FlagOk1 and FlagOk2 and FlagOk3 and FlagOk4 then begin
            SalesHeaderTemp.DeleteAll();
            exit(true);
        end
        else
            exit(false);
    end;

    local procedure GetICTLineFieldNo(var
                                          pICTHeader: Record "LSC Retail ICT Header";
                                          Amount: Decimal): Boolean
    var
        xICTLines: Record "LSC Retail ICT Lines";
        xLine: Text[250];
        xFieldNo: Integer;
        xField: Record "Field";
        xValue: Variant;
        xAnswer: Text[250];
        xRecField: FieldRef;
        ICTFunctions: Codeunit "ICT Functions_Custom";
        NewLine: Text[250];
        SaleshHeaderTemp: Record "Sales Invoice Header" temporary;
        DecAmt: Decimal;
        I: Integer;
        K: Integer;
        xLineNo: Integer;
        xRecRef: RecordRef;
        xICTLines_Insert: Record "LSC Retail ICT Lines";
        IctProcess: Codeunit "ICT Processes_Custom";
    // ICTheader: Record "LSC Retail ICT Header";
    begin
        if not SaleshHeaderTemp.IsTemporary then
            Exit;

        SaleshHeaderTemp.DeleteAll();
        K := 0;
        //Get record data from ICT Lines
        xICTLines.Reset;
        xICTLines.SetRange(xICTLines."ICT BatchNo", pICTHeader."ICT BatchNo");
        xICTLines.SetRange(xICTLines.TableNo, 81);
        if xICTLines.FindSet then
            repeat
                xICTLines.ICTReprocess := true;
                xICTLines.Modify();
            until xICTLines.next = 0;

        xICTLines.Reset;
        xICTLines.SetRange(xICTLines."ICT BatchNo", pICTHeader."ICT BatchNo");
        xICTLines.SetRange(ICTReprocess, true);
        xICTLines.SetRange(xICTLines.TableNo, 81);
        if xICTLines.FindSet then
            repeat
                ProcessGLJMirrorTemp(pICTHeader, Amount);
            // xLine := xICTLines.DataLine;
            // SaleshHeaderTemp.DeleteAll();
            // while (xLine <> '') do begin
            //     xFieldNo := FindFieldNo(xLine);
            //     if xField.Get(81, xFieldNo) then begin
            //         xValue := ICTFunctions.Txt2Txt(xLine, xAnswer);
            //     end;
            //     SaleshHeaderTemp.init;
            //     K += 1;
            //     SaleshHeaderTemp."No." := Format(xFieldNo);
            //     // SaleshHeaderTemp."No." := Format(K);
            //     SaleshHeaderTemp."FieldNo_ICT" := k;
            //     SaleshHeaderTemp.DataLine_ICT := xValue;
            //     SaleshHeaderTemp.Insert();
            // End;
            // SaleshHeaderTemp.Reset();
            // SaleshHeaderTemp.SetFilter("no.", '%1|%2|%3|%4', '13', '16', '19', '100');
            // if SaleshHeaderTemp.FindFirst() then
            //     repeat
            //         SaleshHeaderTemp.DataLine_ICT := DELCHR(Format(Amount * 100000), '<=>', ',');
            //         SaleshHeaderTemp.Modify();
            //     until SaleshHeaderTemp.next = 0;

            // SaleshHeaderTemp.Reset();
            // SaleshHeaderTemp.SetCurrentKey(FieldNo_ICT);
            // if SaleshHeaderTemp.FindFirst() then
            //     repeat
            //         i += 1;
            //         if i = 1 then
            //             NewLine := '{' + FORMAT(SaleshHeaderTemp."No.") + '}' + SaleshHeaderTemp.DataLine_ICT + ';'
            //         else
            //             NewLine := NewLine + '{' + FORMAT(SaleshHeaderTemp."No.") + '}' + SaleshHeaderTemp.DataLine_ICT + ';';
            //     unmtil SaleshHeaderTemp.next = 0;
            // if StrLen(NewLine) <= 170 then begin
            //     xICTLines.DataLine := NewLine;
            //     xICTLines.Modify();
            // end else begin
            //     xRecRef.GetTable(SaleshHeaderTemp);
            //     IctProcess.CreateICTLines(pICTHeader, xRecRef, 0, 0);
            // end;
            // NewLine := '';
            until xICTLines.Next = 0;

        // xICTLines.Reset;
        // xICTLines.SetRange(xICTLines."ICT BatchNo", pICTHeader."ICT BatchNo");
        // xICTLines.SetRange(xICTLines.TableNo, 81);
        // xICTLines.DeleteAll();


        // SaleshHeaderTemp.Reset();
        // SaleshHeaderTemp.SetCurrentKey(FieldNo_ICT);
        // if SaleshHeaderTemp.FindFirst() then
        //     repeat
        //         xRecRef.GetTable(SaleshHeaderTemp);
        //         IctProcess.CreateICTLines(pICTHeader, xRecRef, 0, 0);

        //     until SaleshHeaderTemp.next = 0;
        // DeleteandInserNewICTLines(pICTHeader);
        SaleshHeaderTemp.DeleteAll();

        exit(false);
    end;

    local procedure ProcessGLJMirrorTemp(var pICTHeader: Record "LSC Retail ICT Header"; Amount: Decimal)
    var
        xICTSetup: Record "LSC Retail ICT Setup";
        xGenJournalTemplate: Record "Gen. Journal Template";
        xGenJournalBatch: Record "Gen. Journal Batch";
        xGenJournalLine: Record "Gen. Journal Line" temporary;
        xLineNo: Integer;
        ictProcess: Codeunit "ICT Processes_Custom";
        xRecRef: RecordRef;
        xAmount: Decimal;
    begin
        //Process Gen Journal Mirror Req.
        xGenJournalLine.DeleteAll();

        xICTSetup.Get(pICTHeader."Dist. Location To");

        xGenJournalTemplate.Get(xICTSetup."General Journal");
        xGenJournalBatch.Get(xGenJournalTemplate.Name, 'DEFAULT');

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
        ictProcess.GetICTLines(pICTHeader, xRecRef, 0, 0);
        xRecRef.SetTable(xGenJournalLine);
        xGenJournalLine."Journal Template Name" := xGenJournalTemplate.Name;
        xGenJournalLine."Journal Batch Name" := xGenJournalBatch.Name;
        xLineNo := xLineNo + 10000;
        xGenJournalLine."Line No." := xLineNo;
        if xICTSetup."Source Code" <> '' then
            xGenJournalLine."Source Code" := xICTSetup."Source Code";
        xGenJournalLine."LSC InStore-Created Entry" := true;

        // SaleshHeaderTemp.SetFilter("no.", '%1|%2|%3|%4', '13', '16', '19', '100');

        if (xGenJournalLine."Account Type" = xGenJournalLine."Account Type"::Customer) and
        (xGenJournalLine."Account No." <> '') and (xGenJournalLine."Source Code" = 'SALES') then begin
            Evaluate(xAmount, DELCHR(Format(Amount), '<=>', ','));
            xGenJournalLine.Amount := xAmount;
            xGenJournalLine."Amount (LCY)" := xAmount;
            xGenJournalLine."Sales/Purch. (LCY)" := xAmount;
            xGenJournalLine."Source Currency Amount" := xAmount;
        end;

        //For Purchase Invoice & Credit Memo
        if (xGenJournalLine."Account Type" = xGenJournalLine."Account Type"::Vendor) and
(xGenJournalLine."Account No." <> '') and (xGenJournalLine."Source Code" = 'PURCHASES') then begin
            Evaluate(xAmount, DELCHR(Format(Amount), '<=>', ','));
            xGenJournalLine.Amount := xAmount;
            xGenJournalLine."Amount (LCY)" := xAmount;
            xGenJournalLine."Sales/Purch. (LCY)" := xAmount;
            xGenJournalLine."Source Currency Amount" := xAmount;
        end;

        xGenJournalLine.Insert;
        DeleteandInserNewICTLines(pICTHeader);

        Clear(xRecRef);
        xRecRef.GetTable(xGenJournalLine);
        IctProcess.CreateICTLines(pICTHeader, xRecRef, 0, 0);

    End;

    local procedure DeleteandInserNewICTLines(var pICTHeader: Record "LSC Retail ICT Header")
    var
        xICTLines: Record "LSC Retail ICT Lines";
    begin
        xICTLines.Reset;
        xICTLines.SetRange(xICTLines."ICT BatchNo", pICTHeader."ICT BatchNo");
        xICTLines.SetRange(xICTLines.TableNo, 81);
        xICTLines.SetRange(ICTReprocess, true);
        xICTLines.DeleteAll();

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeRunWithCheck', '', false, false)]
    local procedure "Gen. Jnl.-Post Line_OnBeforeRunWithCheck"(
        var Sender: Codeunit "Gen. Jnl.-Post Line";
        var GenJournalLine: Record "Gen. Journal Line"; var GenJournalLine2: Record "Gen. Journal Line")
    begin
        if GenJournalLine2."Source Code" = 'TRANSFER' then begin
            if GenJournalLine2."Account No." in ['2013003', '2013001', '2013002'] then begin
                // GenJournalLine2."Gen. Posting Type" := GenJournalLine2."Gen. Posting Type"::Sale;
                GenJournalLine2."Gen. Prod. Posting Group" := '';
            end;
        end;
    end;


    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Tracking Management", OnBeforeFindTempHandlingSpecification, '', false, false)]
    // local procedure "Item Tracking Management_OnBeforeFindTempHandlingSpecification"(
    //     var TempTrackingSpecification: Record "Tracking Specification" temporary;
    //     ReservEntry: Record "Reservation Entry")
    // begin
    //     if (ReservEntry."Source Subtype" = 6) and not (ReservEntry.Positive) and (ReservEntry."Source Type" = 83) then begin
    //         ReservEntry.Positive := true;
    //         ReservEntry.Quantity := abs(ReservEntry.Quantity);
    //         ReservEntry."Qty. to Handle (Base)" := Abs(ReservEntry."Qty. to Handle (Base)");
    //         ReservEntry."Quantity (Base)" := abs(ReservEntry."Quantity (Base)");
    //         ReservEntry."Qty. to Invoice (Base)" := abs(ReservEntry."Qty. to Invoice (Base)");
    //         // ReservEntry.Modify();
    //     end;
    // end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Tracking Management", OnBeforeTempHandlingSpecificationInsert, '', false, false)]
    local procedure "Item Tracking Management_OnBeforeTempHandlingSpecificationInsert"(var TempTrackingSpecification: Record "Tracking Specification" temporary; ReservationEntry: Record "Reservation Entry"; var ItemTrackingCode: Record "Item Tracking Code"; var EntriesExist: Boolean)
    begin
        if (TempTrackingSpecification."Source Subtype" = 6) and not (TempTrackingSpecification.Positive)
        and (TempTrackingSpecification."Source Type" = 83) then begin
            TempTrackingSpecification.Positive := true;
            TempTrackingSpecification."Qty. to Handle" := abs(TempTrackingSpecification."Qty. to Handle");
            TempTrackingSpecification."Qty. to Invoice" := abs(TempTrackingSpecification."Qty. to Invoice");
            TempTrackingSpecification."Qty. to Handle (Base)" := Abs(TempTrackingSpecification."Qty. to Handle (Base)");
            TempTrackingSpecification."Quantity (Base)" := abs(TempTrackingSpecification."Quantity (Base)");
            TempTrackingSpecification."Buffer Value1" := abs(TempTrackingSpecification."Buffer Value1");
            TempTrackingSpecification."Qty. to Invoice (Base)" := abs(TempTrackingSpecification."Qty. to Invoice (Base)");
            // ReservEntry.Modify();
        end;
    end;

    var
        f: Record 81;
        GlobalDoc: Code[20];
}