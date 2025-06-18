codeunit 50040 "Global Codeunit"
{
    trigger OnRun()
    begin

    end;

    procedure GetApiDetails(StartDate: Date; EndDate: Date)
    var
        URL: text;
        JSONReq: Text;
        gResponseMsg: Text;
        gContentHeaders: HttpHeaders;
        gContent: HttpContent;
        gHttpResponseMsg: HttpResponseMessage;
        gHttpClient: HttpClient;
        ResMessage: Text;
        Resp: Text;
        TempHeader: Record LogHeader;
        TempLine: Record LogLine;
        StartDateText: Text;
        EndDateText: Text;
        Result: Action;
        DateDialog: Page "Date Range Dialog";
        Dates: Dictionary of [Text, Date];

    begin
        StartDateText := Format(StartDate, 0, '<Year4>-<Month,2>-<Day,2>');
        EndDateText := Format(EndDate, 0, '<Year4>-<Month,2>-<Day,2>');

        Clear(gResponseMsg);
        gContent.WriteFrom(JSONReq);
        gContent.GetHeaders(gContentHeaders);
        gContentHeaders.Clear();
        gContentHeaders.Add('Content-Type', 'application/json');
        if gHttpClient.Get('https://twc.forklyft.in/api/vendor-bills' + '?start_date=' + StartDateText + '&end_date=' + EndDateText, gHttpResponseMsg) then begin
            gHttpResponseMsg.Content.ReadAs(gResponseMsg);
            if not gHttpResponseMsg.IsSuccessStatusCode then begin
                Error(gResponseMsg);
                Message(JSONReq);
            end else begin
                Resp := gResponseMsg;
                ResMessage := GetResponsesValue(Resp, '"success":', ',', 1);
                ParseAndStoreJson(Resp);
                Message(Resp);
            end;
        End;
        // End;
    End;

    procedure GetResponsesValue(resp3: Text; Lstr: Text; Strng: Text; Cnt: Integer): Text
    var
        mstr: Text;
        IntPos: Integer;
        i: Integer;
        Resp1: Text;
    begin
        IF STRPOS(resp3, Lstr) = 0 THEN
            EXIT('');

        FOR i := 1 TO Cnt DO BEGIN
            IntPos := STRPOS(resp3, Lstr) + STRLEN(Lstr);
            Resp1 := DELSTR(resp3, 1, IntPos);
            resp3 := Resp1;
        END;

        IF Lstr <> 'error' THEN BEGIN
            IF STRPOS(Resp1, Strng) <> 0 THEN
                Resp1 := COPYSTR(Resp1, 1, STRPOS(Resp1, Strng) - 1)
            ELSE
                Resp1 := COPYSTR(Resp1, 1, STRLEN(Resp1) - 1);

            Resp1 := SELECTSTR(1, Resp1);
        END;

        IF NOT (Lstr = 'StatusDate') THEN
            Resp1 := DELCHR(Resp1, '=', ' ');

        Resp1 := DELCHR(Resp1, '=', '"');
        Resp1 := DELCHR(Resp1, '<', ':');

        EXIT(Resp1);
    end;



    procedure ParseAndStoreJson(JsonText: Text)
    var
        JsonArr: JsonArray;
        HeaderToken, LineToken, Token : JsonToken;
        TaxObj, TDSLineObj, TdsObj, HeaderObj, LineObj, VendorObj : JsonObject;
        LinesArray, TdsArray, TaxArray : JsonArray;
        LogHeader: Record LogHeader;
        LogLine: Record LogLine;
        i, j, LineNo, HeaderId : Integer;
        HeaderBillRef: Code[20];

    begin
        if not JsonArr.ReadFrom(JsonText) then
            Error('Invalid JSON');


        for i := 0 to JsonArr.Count() - 1 do begin
            JsonArr.Get(i, HeaderToken);
            HeaderObj := HeaderToken.AsObject();

            // --- Parse Header ---
            if HeaderObj.Get('id', Token) then
                HeaderId := Token.AsValue().AsInteger();

            if HeaderObj.Get('bill_reference', Token) then
                LogHeader.bill_reference := Token.AsValue().AsText();

            if HeaderObj.Get('vendor_details', Token) then begin
                VendorObj := Token.AsObject();
                if VendorObj.Get('vendor_id', Token) then
                    LogHeader."Vendor_ID" := Format(Token.AsValue().AsInteger());
                if VendorObj.Get('name', Token) then
                    LogHeader."Vendor Name" := Token.AsValue().AsText();
                if VendorObj.Get('address', Token) then
                    LogHeader."Vendor Address" := Token.AsValue().AsText();
                if VendorObj.Get('pin', Token) then
                    LogHeader.PIN := Token.AsValue().AsText();
                if VendorObj.Get('gst', Token) then
                    LogHeader."GST" := Token.AsValue().AsText();
                if VendorObj.Get('ref', Token) then
                    LogHeader."REF" := Token.AsValue().AsText();
            end;

            if HeaderObj.Get('period_from', Token) then
                Evaluate(LogHeader."Period From", Token.AsValue().AsText());
            if HeaderObj.Get('period_to', Token) then
                Evaluate(LogHeader."Period To", Token.AsValue().AsText());
            if HeaderObj.Get('bill_date', Token) then
                Evaluate(LogHeader."Bill Date", Token.AsValue().AsText());
            if HeaderObj.Get('due_date', Token) then
                Evaluate(LogHeader."Due Date", Token.AsValue().AsText());
            if HeaderObj.Get('place_of_supply', Token) then
                LogHeader."Place of Supply" := Token.AsValue().AsText();
            if HeaderObj.Get('store_code', Token) then
                LogHeader."Store Code" := Token.AsValue().AsText();
            if HeaderObj.Get('untaxed_amount', Token) then
                LogHeader."Untaxed Amont" := Token.AsValue().AsDecimal();
            if HeaderObj.Get('gst_amount', Token) then
                LogHeader."GST Amount" := Token.AsValue().AsDecimal();

            if HeaderObj.Get('tds_bill_level', Token) then begin
                TdsArray := Token.AsArray();
                if TdsArray.Count() > 0 then begin
                    TdsArray.Get(0, Token);
                    TdsObj := Token.AsObject();
                    if TdsObj.Get('name', Token) then
                        LogHeader.tds_bill_level_Name := Token.AsValue().AsText();
                    if TdsObj.Get('description', Token) then
                        LogHeader.tds_bill_level_Description := Token.AsValue().AsText();
                end;
            end;

            if HeaderObj.Get('invoice_total', Token) then
                LogHeader."Invoice Total" := Token.AsValue().AsDecimal();
            if HeaderObj.Get('currency', Token) then
                LogHeader."Currency" := Token.AsValue().AsText();
            if HeaderObj.Get('payment_state', Token) then
                LogHeader."Payment State" := Token.AsValue().AsText();
            if HeaderObj.Get('status', Token) then
                LogHeader."Status" := Token.AsValue().AsText();

            LogHeader.ID := HeaderId;
            LogHeader.Insert();


            // Read lines
            if HeaderObj.Get('order_lines', Token) then begin
                LinesArray := Token.AsArray();
                LineNo := 10000;

                for j := 0 to LinesArray.Count() - 1 do begin
                    LinesArray.Get(j, LineToken);
                    LineObj := LineToken.AsObject();

                    LogLine.Init();
                    LogLine."ID" := HeaderId;
                    LogLine.bill_reference := HeaderBillRef;
                    LogLine."Line No." := LineNo;

                    if LineObj.Get('product_id', Token) then
                        LogLine."Product_ID" := Format(Token.AsValue().AsInteger());
                    if LineObj.Get('internal_reference', Token) then
                        LogLine.internal_reference := Format(Token.AsValue().AsInteger());
                    if LineObj.Get('product_description', Token) then
                        LogLine."Product_Description" := Token.AsValue().AsText();
                    if LineObj.Get('price_unit', Token) then
                        LogLine."price_unit" := Token.AsValue().AsDecimal();
                    if LineObj.Get('quantity', Token) then
                        LogLine."Quantity" := Token.AsValue().AsDecimal();

                    if LineObj.Get('tax', Token) then begin
                        TaxArray := Token.AsArray();
                        if TaxArray.Count() > 0 then begin
                            TaxArray.Get(0, Token); // Only taking the first tax line
                            TaxObj := Token.AsObject();

                            if TaxObj.Get('name', Token) then
                                LogLine."Tax name" := Token.AsValue().AsText();
                            if TaxObj.Get('amount', Token) then
                                LogLine."Tax Amount" := Token.AsValue().AsDecimal();
                            if TaxObj.Get('type', Token) then
                                LogLine."TAx Type" := Token.AsValue().AsText();
                        end;
                    end;

                    if LineObj.Get('tds_line', Token) then begin
                        TDSArray := Token.AsArray();
                        if TDSArray.Count() > 0 then begin
                            TDSArray.Get(0, Token); // Only taking the first TDS line
                            TDSLineObj := Token.AsObject();

                            if TDSLineObj.Get('name', Token) then
                                LogLine.TDS_Name := Token.AsValue().AsText();
                            if TDSLineObj.Get('description', Token) then
                                LogLine.TDS_Description := Token.AsValue().AsText();
                        end;
                    end;
                    if LineObj.Get('product_hsn', Token) then
                        LogLine.product_hsn := Token.AsValue().AsText();
                    if LineObj.Get('price_subtotal', Token) then
                        LogLine.Price_Subtotal := Token.AsValue().AsDecimal();
                    if LineObj.Get('price_total', Token) then
                        LogLine."Price_Total" := Token.AsValue().AsDecimal();

                    LogLine.Insert();
                    LineNo += 10000;
                end;
            end;


        end;
    end;





    var
        myInt: Integer;
        NoSeriesCode: code[20];
}