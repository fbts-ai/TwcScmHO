/*
codeunit 50145 "EwayBillSalesCreditMemo"
{
    Permissions = tabledata "Sales Cr.Memo Header" = rm;

    trigger OnRun()
    begin
        Initialize();

        //RunSalesInvoiceEwayBill();
        PayloadEwayBillFromIRN();
        if DocumentNo <> '' then
            GenerateEwayBillFromIRN(DocumentNo)
        else
            Error(DocumentNoBlankErr);


        //RunSalesCreditMemoEwayBill();
        /*
        if DocumentNo <> '' then
            ExportAsJson(DocumentNo)
        else
            Error(DocumentNoBlankErr);
        
    end;

    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        //TempTransferReceipt : Record "Transfer Receipt Header";

        JObject: JsonObject;
        JsonArrayData: JsonArray;
        JsonTDSArrayGlobal: JsonArray;
        JsonTCSArrayGlobal: JsonArray;

        JShippingBillArray: JsonArray;
        JewayBillArray: JsonArray;
        JOriginaldocArray: JsonArray;
        JECommOprMerchantArray: JsonArray;

        IsInvoice: Boolean;

        JsonText: Text;
        DocumentNo: Text[20];
        RndOffAmt: Decimal;
        IsTransfer: Boolean;
        eInvoiceNotApplicableCustErr: Label 'E-Invoicing is not applicable for Unregistered Customer.';
        eInvoiceNonGSTTransactionErr: Label 'E-Invoicing is not applicable for Non-GST Transactions.';
        DocumentNoBlankErr: Label 'E-Invoicing is not supported if document number is blank in the current document.';
        SalesLinesMaxCountLimitErr: Label 'E-Invoice allowes only 100 lines per Invoice. Current transaction is having %1 lines.', Comment = '%1 = Sales Lines count';
        IRNTxt: Label 'Irn', Locked = true;
        AcknowledgementNoTxt: Label 'AckNo', Locked = true;
        AcknowledgementDateTxt: Label 'AckDt', Locked = true;
        IRNHashErr: Label 'No matched IRN Hash %1 found to update.', Comment = '%1 = IRN Hash';
        SignedQRCodeTxt: Label 'SignedQRCode', Locked = true;
        CGSTLbl: Label 'CGST', Locked = true;
        SGSTLbl: label 'SGST', Locked = true;
        IGSTLbl: Label 'IGST', Locked = true;
        CESSLbl: Label 'CESS', Locked = true;
        GenerateQRCodeErr: Label 'Dynamic QR Code generation is allowed for Unregistered customers only.';
        B2CUPIPaymentErr: Label 'UPI ID must have a value in bank account %1. It cannot be empty', comment = '%1 BankAccount';


    /// <summary>
    /// SetTransferHeader.
    /// </summary>
    /// <param name="TransferHeaderBuff">Record "Transfer Header".</param>
    procedure SetSalesCreditMemo(SalesCrHeaderBuff: Record "Sales Cr.Memo Header")
    begin
        SalesCrMemoHeader := SalesCrHeaderBuff;
        IsInvoice := false;
    end;

    local procedure Initialize()
    begin
        Clear(JObject);
        Clear(JsonArrayData);
        Clear(JsonText);
    end;

    local procedure PayloadEwayBillFromIRN()
    var
        transporterId: Text[20];
        modeOfTransport: Text[10];
        documentNumber: Text[20];
        distance: Text;
        documentDate: Text;
        vehicleNo: Text;
        vehicleType: text;
        ShippingAgent: Record "Shipping Agent";
        dist3: Integer;
        dist1: Decimal;
        VehType: Text[30];
        tempSalesCrMemo: Record "Sales Cr.Memo Header";

    begin

        tempSalesCrMemo.Reset();
        tempSalesCrMemo.SetRange("No.", SalesCrMemoHeader."No.");
        IF tempSalesCrMemo.FindFirst() then;
        tempSalesCrMemo.TestField("IRN Hash");
        tempSalesCrMemo.TestField("Shipping Agent Code");



        DocumentNo := tempSalesCrMemo."No.";

        if ShippingAgent.Get(tempSalesCrMemo."Shipping Agent Code") then;

        JObject.Add('Irn', tempSalesCrMemo."IRN Hash");

        IF tempSalesCrMemo."Distance (Km)" <> 0 then begin
            dist1 := tempSalesCrMemo."Distance (Km)";
            Evaluate(dist3, format(dist1));
            JObject.Add('Distance', dist3);
        end
        else
            JObject.Add('Distance', 0);

        //JObject.Add('TransMode', '');
        IF tempSalesCrMemo."Transport Method" = 'ROAD' then
            JObject.Add('TransMode', '1');

        JObject.Add('TransId', ShippingAgent."GST Registration No.");

        JObject.Add('TransName', ShippingAgent.Name);

        JObject.Add('TrnDocNo', tempSalesCrMemo."No.");
        JObject.Add('TrnDocDt', tempSalesCrMemo."Posting Date");

        JObject.Add('VehNo', tempSalesCrMemo."Vehicle No.");

        if tempSalesCrMemo."Vehicle Type" <> tempSalesCrMemo."Vehicle Type"::" " then
            if tempSalesCrMemo."Vehicle Type" = tempSalesCrMemo."Vehicle Type"::ODC then
                VehType := 'Over Dimensional Cargo'
            else
                VehType := 'Regular'
        else
            VehType := '';

        JObject.Add('VehType', VehType);

    End;

    local procedure GenerateEwayBillFromIRN(FileName: Text[20])
    var
        TempBlob: Codeunit "Temp Blob";
        ToFile: Variant;
        InStream: InStream;
        OutStream: OutStream;
        client: HttpClient;
        request: HttpRequestMessage;
        response: HttpResponseMessage;
        contentHeaders: HttpHeaders;
        content: HttpContent;
        responseText: Text;

        AccessToken: Text;
        JobjectResponse: JsonObject;
        JobjToken: JsonToken;
        Jobjarr: JsonArray;
        ackno: Text;
        i: Integer;
        ackdatetimetext: text;
        AcknowledgementDate: Date;
        Acknowledgementtime: Time;
        TempDateTime: DateTime;
        SignedQRCodeTxt1: Text;
        QRGenerator: Codeunit "QR Generator";
        TempBlob2: Codeunit "Temp Blob";
        FieldRef: FieldRef;
        EwayJsonToken: JsonToken;
        EwayJsonObject: JsonObject;
        errorDetailsJsonToken: JsonToken;
        j: Integer;
        JobjErrorarr: JsonArray;
        errorDetailsJsonObject: JsonObject;
        tempSalesCrMemo: Record "Sales Cr.Memo Header";
        TempMsg: Text;

    begin
        // JsonArrayData.Add(JObject);
        // JsonArrayData.WriteTo(JsonText);
        JObject.WriteTo(JsonText);

        TempBlob.CreateOutStream(OutStream);
        OutStream.WriteText(JsonText);
        ToFile := FileName + '11.json';
        TempBlob.CreateInStream(InStream);
        DownloadFromStream(InStream, 'e-Way', '', '', ToFile);
        Sleep(1000);


        AccessToken := 'fe28e9b25dfe9390fb23a5dca981bf6a9f629950da954aa322f490a7dcf244e5';
        //'fe28e9b25dfe9390fb23a5dca981bf6a9f629950da954aa322f490a7dcf244e5';
        content.WriteFrom(JsonText);

        // Retrieve the contentHeaders associated with the content
        content.GetHeaders(contentHeaders);
        contentHeaders.Clear();
        contentHeaders.Add('Content-Type', 'application/json');


        client.DefaultRequestHeaders.Add('Authorization', 'Bearer ' + AccessToken);

        // Assigning content to request.Content will actually create a copy of the content and assign it.
        // After this line, modifying the content variable or its associated headers will not reflect in 
        // the content associated with the request message
        request.Content := content;

        request.SetRequestUri('https://www.sandbox-gstapi.trustfilegst.in/einvoice/api/v1/EInvoice/27AAAPI3182M002/GenerateEwaybillUsingIRN');
        request.Method := 'POST';

        client.Send(request, response);
        if response.IsSuccessStatusCode then begin
            response.Content().ReadAs(responseText);
            // Message(responseText);
            // JobjectResponse.ReadFrom(responseText);
            // Message(format(JobjectResponse));


            if JobjToken.ReadFrom(responseText) then begin

                // Convert JsonToken to JsonObject
                if JobjToken.IsObject then begin
                    JobjectResponse := JobjToken.AsObject();
                    Message(format(JobjectResponse));


                    //for saving Eway Bill
                    if JobjectResponse.Get('ewayBillNo', JobjToken) then begin
                        // Get First Array Result
                        tempSalesCrMemo.Reset();
                        tempSalesCrMemo.SetRange("No.", SalesCrMemoHeader."No.");
                        IF tempSalesCrMemo.FindFirst() then;

                        IF JobjToken.AsValue().AsText() <> '' Then begin
                            // EwayJsonObject := EwayJsonToken.AsObject();                       
                            tempSalesCrMemo."E-Way Bill No." := JobjToken.AsValue().AsText();
                            tempSalesCrMemo.Modify(true);
                        end;

                    End;
                    Message('Eway Bill Updated sussfully');
                end;
            end;
        end
        Else
            Error('Bad resposnse or no resposne from Avalara, Please check with your IT team');
    end;




    /*
        local procedure RunSalesCreditMemoEwayBill()
        begin

            /*
                 if TempTransferHeader."GST Customer Type" in [
                     SalesInvoiceHeader."GST Customer Type"::Unregistered,
                     SalesInvoiceHeader."GST Customer Type"::" "]
                 then
                     Error(eInvoiceNotApplicableCustErr);

            DocumentNo := SalesCrMemoHeader."No.";
            WriteJsonFileHeader();
            ReadTransfersEwayBill();
            ReadwriteGSTNumber();
            ReadCounterParty();
            ReadTransferOrderDetails();
            ReadShipFormDetails();
            ReadShipToDetails();

            ReadDocumentItemList();



        end;

        local procedure WriteJsonFileHeader()
        begin
            // JObject.Add('Version', '1.1');
            JsonArrayData.Add(JObject);
        end;



        local procedure ReadTransfersEwayBill()
        var
            subType: Text[30];
            documentType1: Text[30];
            subTypeDesc: Text[100];
            transactionType1: Text[20];
            generate: Text[5];
            name: Text[50];
            transporterId: Text[20];
            modeOfTransport: Text[10];
            documentNumber: Text[20];
            distance: Text;
            documentDate: Text;
            vehicleNo: Text;
            vehicleType: text;
            JsonTransporterArray: JsonArray;

        begin
            Clear(JsonTransporterArray);
            subType := 'Others';
            documentType1 := 'Creditnote';
            subTypeDesc := 'goods Transfer';
            transactionType1 := 'BillToShipTo';


            "name" := '';
            "transporterId" := '';
            "modeOfTransport" := '';
            "documentNumber" := '';
            "documentDate" := '';
            "distance" := '';
            "vehicleNo" := '';
            "vehicleType" := '';
            //AddTransporterDetails(name, transporterId);

            generate := 'true';
            WriteEwayBillDetails(subType, documentType1, subTypeDesc, transactionType1, JsonTransporterArray, generate);





        end;

        local procedure WriteEwayBillDetails(
            subType: Text[30];
            documentType1: Text[30];
            subTypeDesc: Text[100];
            transactionType1: Text[20];
            JsonTransporterArray: JsonArray;
            generate: text[5]
            )
        var
            JTranDetails: JsonObject;
            JTransporter: JsonObject;
        begin
            JTranDetails.Add('subType', subType);
            JTranDetails.Add('documentType', documentType1);
            JTranDetails.Add('subTypeDesc', subTypeDesc);
            JTranDetails.Add('transactionType', transactionType1);

            AddTransporterDetails(JTransporter);
            JTranDetails.Add('transportDetail', JTransporter);
            JTranDetails.Add('generate', true);


            JObject.Add('ewayBill', JTranDetails);
        end;

        local procedure AddTransporterDetails(
            JTransporter: JsonObject
        )
        var
            dist3: Integer;
            dist1: Decimal;
        begin
            JTransporter.Add('name', '');
            JTransporter.Add('transporterId', '');
            JTransporter.add('modeOfTransport', '');
            JTransporter.add('documentNumber', SalesCrMemoHeader."No.");// SalesCrMemoHeader."No." need to check not accepting doc no
            JTransporter.add('documentDate', SalesCrMemoHeader."Posting Date");
            dist1 := SalesCrMemoHeader."Distance (Km)";
            Evaluate(dist3, format(dist1));
            JTransporter.add('distance', dist3);
            JTransporter.add('distance', SalesCrMemoHeader."Distance (Km)");
            JTransporter.add('vehicleNo', SalesCrMemoHeader."Vehicle No.");
            JTransporter.add('vehicleType', Format(SalesCrMemoHeader."Vehicle Type"));
            //JObject.Add('transportDetail', JTransporter);

        end;

        local procedure ReadwriteGSTNumber()
        var
            GSTNumber: Code[50];
            JgstNoObj: JsonObject;
            companyinfo: Record "Company Information";
        begin
            //need to replace before go live
            GSTNumber := '29AAACW4202F1ZM'; //companyinfo."GST Registration No.";

            JObject.Add('GSTIN', GSTNumber)

        end;

        local procedure ReadCounterParty()
        var
            GSTNumber1: Code[50];
            name1: Text[50];
            UIN: text[50];
            TempCustomer: Record Location;

        begin
            if TempCustomer.get(SalesCrMemoHeader."Sell-to Customer No.") then;


            GSTNumber1 := TempCustomer."GST Registration No.";//'03EHFPS5910D3A1';//'03EHFPS5910D3Z0';
            name1 := TempCustomer.Name;//'test customer hardcoded';//
            UIN := '';
            WriteCounterParty(GSTNumber1, name1, UIN);

        end;

        local procedure WriteCounterParty(
            GSTNumber1: Code[50];
            name1: Text[50];
            UIN: text[50])
        var
            JCounterPartyObj: JsonObject;
        begin
            JCounterPartyObj.Add('GSTIN', GSTNumber1);
            JCounterPartyObj.Add('name', name1);
            JCounterPartyObj.Add('UIN', UIN);
            JObject.Add('CounterParty', JCounterPartyObj)

        end;


        local procedure ReadTransferOrderDetails()
        var
            SalesCreditMemoNumber: code[20];
            type1: text;
            Transferdate: Text;
            Pos: text;
            OtherAmount: Decimal;
            TotalInvoiceAmount: Decimal;
            tempsalesinvoiceLine: Record "Sales Invoice Line";
        begin
            SalesCreditMemoNumber := SalesCrMemoHeader."No.";
            type1 := 'AR-IN';
            Transferdate := Format(SalesCrMemoHeader."Posting Date");
            Pos := ''; //place of supply
            OtherAmount := 0;
            TotalInvoiceAmount := 0;

            clear(JShippingBillArray);
            Clear(JewayBillArray);
            Clear(JOriginaldocArray);
            clear(JECommOprMerchantArray);

            tempsalesinvoiceLine.Reset();
            tempsalesinvoiceLine.SetRange("Document No.", tempsalesinvoiceLine."No.");
            if tempsalesinvoiceLine.FindSet() then
                repeat
                    TotalInvoiceAmount := TotalInvoiceAmount + tempsalesinvoiceLine.Amount;
                until tempsalesinvoiceLine.Next() = 0;

            JObject.Add('Number', SalesCreditMemoNumber);
            JObject.Add('Type', type1);
            JObject.Add('Date', Transferdate);
            JObject.Add('POS', pos);
            JObject.Add('OtherAmount', OtherAmount);
            JObject.Add('TotalInvoiceAmount', TotalInvoiceAmount);
            //JObject.Add('ShippingBill', JShippingBillArray);
            AddShippingBillArray();

            JObject.add('ExportType', '');
            AddewaybillArray();
            AddOriginalDocArray();
            // JObject.Add('EwayBill', JewayBillArray);
            //  JObject.add('OriginalDocument', JOriginaldocArray);
            JObject.add('CDNReason', '');
            AddECommOprMerchantArray();
            // JObject.Add('ECommOprMerchant', JECommOprMerchantArray);

            JObject.Add('PGST', false);

        end;

        local procedure AddShippingBillArray()
        var
            JShippingBill: JsonObject;

        begin
            JShippingBill.Add('PortCode', '');
            JShippingBill.Add('value', '');
            JObject.Add('ShippingBill', JShippingBill);

        end;

        local procedure AddewaybillArray()
        var
            JewayBill: JsonObject;
        begin
            JewayBill.Add('id', '');

            JObject.Add('EwayBill', JewayBill);

        end;

        local procedure AddOriginalDocArray()
        var
            JOriginaldoc: JsonObject;
        begin
            JOriginaldoc.Add('Number', '');

            JObject.Add('OriginalDocument', JOriginaldoc);

        end;

        local procedure AddECommOprMerchantArray()
        var
            JECommOprMerchant: JsonObject;
        begin
            JECommOprMerchant.Add('id', '');
            JECommOprMerchant.Add('GSTIN', '');

            JObject.Add('ECommOprMerchant', JECommOprMerchant);

        end;


        local procedure ReadShipFormDetails()
        var
            city1: Text;
            state1: text;
            Line1: Text;
            Country1: text;
            Postcode1: text;
            tempState: record State;
            TempLocation: Record Location;
            temppostcode: Record "Post Code";
        begin
            if TempLocation.get(SalesCrMemoHeader."Location Code") then;
            // if tempState.Get(TempLocation."State Code") then;


            city1 := TempLocation.City;
            IF tempState.Get(SalesCrMemoHeader."Location State Code") then;
            state1 := tempState."State Code (GST Reg. No.)";
            Line1 := TempLocation.Address;
            Country1 := TempLocation."Country/Region Code";
            Postcode1 := TempLocation."Post Code";

            WriteShipFromDetails(city1, state1, Line1, Country1, Postcode1);



        end;

        local procedure WriteShipFromDetails(
             city1: Text;
            state1: text;
            Line1: Text;
            Country1: text;
            Postcode1: text
        )
        var
            JTransferShipFrom: JsonObject;

        begin
            JTransferShipFrom.Add('city', city1);
            JTransferShipFrom.Add('State', state1);
            JTransferShipFrom.Add('Line1', Line1);
            JTransferShipFrom.Add('Country', Country1);
            JTransferShipFrom.Add('PostalCode', Postcode1);


            JObject.add('ShipFrom', JTransferShipFrom)

        end;

        local procedure ReadShipToDetails()
        var
            city2: Text;
            state2: text;
            Line2: Text;
            Country2: text;
            Postcode2: text;
            tempState: record State;
            TempLocation: Record Location;
            temppostcode: Record "Post Code";
        begin
            if SalesCrMemoHeader."Ship-to Code" <> '' then begin
                city2 := SalesCrMemoHeader."Ship-to City"; //'test';//
                state2 := SalesCrMemoHeader."GST Ship-to State Code";//'03';//
                Line2 := SalesCrMemoHeader."Ship-to Address"; //'teststes test';//

                Country2 := SalesCrMemoHeader."Ship-to County";//'IN';//
                Postcode2 := SalesCrMemoHeader."Ship-to Post Code"; //'143001';// 

            end;

            WriteShiptoDetails(city2, state2, Line2, Country2, Postcode2);


        end;

        local procedure WriteShiptoDetails(
            city2: Text;
            state2: text;
            Line2: Text;
            Country2: text;
            Postcode2: text
        )
        var
            JTransferShipTo: JsonObject;
        begin
            JTransferShipTo.Add('city', city2);
            JTransferShipTo.Add('State', state2);
            JTransferShipTo.Add('Line1', Line2);
            JTransferShipTo.Add('Country', Country2);
            JTransferShipTo.Add('PostalCode', Postcode2);


            JObject.add('ShipTo', JTransferShipTo)

        end;



        local procedure ReadDocumentItemList()
        var
            TempSalesLine: Record "Sales Cr.Memo Line";
            AssessableAmount: Decimal;
            GstRate: Integer;
            CGSTRate: Decimal;
            SGSTRate: Decimal;
            IGSTRate: Decimal;
            CessRate: Decimal;
            CesNonAdval: Decimal;
            StateCess: Decimal;
            CGSTValue: Decimal;
            SGSTValue: Decimal;
            IGSTValue: Decimal;
            IsServc: Text[1];
            Count: Integer;
            Number: Text;
            desc: Text;
            ReverseCharge: Boolean;
            ProvisionallyPaid: Boolean;
            ITCSpecialHandling: Text;
            CessValue: Decimal;
            CesNonAdrate: Decimal;
            gstamount: Decimal;
            JTDSItemLine: JsonObject;
            JTCSItemLine: JsonObject;
            UnitofMeasure: Record "Unit of Measure";
            UCQ: Code[10];


        begin
            Count := 1;
            Clear(JsonArrayData);

            TempSalesLine.Reset();
            TempSalesLine.SetRange("Document No.", DocumentNo);
            // TempTransferLine.SetFilter(Type, '<>%1', SalesInvoiceLine.Type::" ");
            if TempSalesLine.FindSet() then begin
                if TempSalesLine.Count > 100 then
                    Error(SalesLinesMaxCountLimitErr, TempSalesLine.Count);
                repeat

                    GetGSTComponentRate(
                         TempSalesLine."Document No.",
                        TempSalesLine."Line No.",
                        CGSTRate,
                        SGSTRate,
                        IGSTRate,
                        CessRate,
                        CesNonAdval,
                        StateCess);


                    GetGSTValueForLine(TempSalesLine."Document No.", TempSalesLine."Line No.", CGSTValue, SGSTValue, IGSTValue);

                    desc := 'Goods';
                    Clear(JTDSItemLine);
                    Clear(JTCSItemLine);
                    addTDSTCSdetails(JTDSItemLine, JTCSItemLine);

                    UnitofMeasure.Reset();
                    UnitofMeasure.SetRange(Code, TempSalesLine."Unit of Measure Code");
                    IF UnitofMeasure.FindFirst() then;
                    UCQ := UnitofMeasure.UCQ;

                    WriteItem(
                      TempSalesLine.Description,
                      TempSalesLine."HSN/SAC Code", UCQ,
                      TempSalesLine."Line No.", Desc, TempSalesLine.Quantity, TempSalesLine.Amount, gstamount,
                      GstRate, JTDSItemLine, JTCSItemLine, ReverseCharge, ProvisionallyPaid, ITCSpecialHandling, IGSTValue, IGSTRate, CGSTRate,
                      CGSTValue, SGSTRate, SGSTValue, CessValue, CessRate, CesNonAdval, CesNonAdrate
                     );

                    Count += 1;
                until TempSalesLine.Next() = 0;
            end;

            JObject.Add('Lines', JsonArrayData);
            Clear(JsonArrayData);
        end;


        local procedure addTDSTCSdetails(
            JTDSItemLine: JsonObject;
            JTCSItemLine: JsonObject

        )
        var


        begin
            //   Clear(JTDSItemLine);
            JTDSItemLine.Add('IGST', 0.00);
            JTDSItemLine.Add('IGSTRate', 0.00);
            JTDSItemLine.Add('CGST', 0.00);
            JTDSItemLine.Add('CGSTRate', 0.00);
            JTDSItemLine.Add('SGST', 0.00);
            JTDSItemLine.Add('SGSTRate', 0.00);
            JTDSItemLine.Add('CESS', 0.00);
            JTDSItemLine.Add('CESSRate', 0.00);
            // JObject.Add('TDS', JTDSItemLine);
            //JsonTDSArrayGlobal.Add(JTDSItemLine);

            //Clear(JTCSItemLine);
            JTCSItemLine.Add('IGST', 0.00);
            JTCSItemLine.Add('IGSTRate', 0.00);
            JTCSItemLine.Add('CGST', 0.00);
            JTCSItemLine.Add('CGSTRate', 0.00);
            JTCSItemLine.Add('SGST', 0.00);
            JTCSItemLine.Add('SGSTRate', 0.00);
            JTCSItemLine.Add('CESS', 0.00);
            JTCSItemLine.Add('CESSRate', 0.00);
            // JObject.Add('TCS', JTCSItemLine);
            // JsonTCSArrayGlobal.Add(JTCSItemLine);


        end;

        local procedure WriteItem(
           ProductName: Text;
           HSNCode: Text[10];
           Unit: Text[3];
           number: Integer;
           desc: Text;
           Quantity: Decimal;
           TotAmount: Decimal;
           gstamount: Decimal;
           GstRate: Integer;
            JTDSItemLine: JsonObject;
            JTCSItemLine: JsonObject;
           ReverseCharge: Boolean;
           ProvisionallyPaid: Boolean;
           ITCSpecialHandling: Text;
           IGSTValue: Decimal;
           IGSTRate: Decimal;
           CGSTValue: Decimal;
           CGSTRate: Decimal;
           SGSTValue: Decimal;
           SGSTRate: Decimal;
           CessValue: Decimal;
           CessRate: Decimal;
           CesNonAdval: Decimal;
           CesNonAdrate: Decimal)
        var
            JItem: JsonObject;
        begin
            JItem.Add('productName', ProductName);
            JItem.Add('HSNCode', HSNCode); //HSNCode
            JItem.Add('UnitQuantityCode', Unit);//Unit
            JItem.Add('Number', number);
            JItem.Add('Description', desc);
            JItem.Add('Quantity', Quantity);
            JItem.Add('TaxableAmount', TotAmount);
            JItem.Add('TaxAmount', gstamount);
            JItem.Add('TaxRate', GstRate);
            JItem.Add('TDS', JTDSItemLine);
            JItem.add('TCS', JTCSItemLine);
            JItem.Add('ReverseCharge', false);
            JItem.Add('ProvisionallyPaid', false);
            JItem.Add('ITCSpecialHandling', ITCSpecialHandling);
            JItem.Add('IGST', IGSTValue);
            JItem.Add('IGSTRate', IGSTRate);
            JItem.Add('CGST', CGSTValue);
            JItem.Add('CGSTRate', CGSTRate);
            JItem.Add('SGST', SGSTValue);
            JItem.Add('SGSTRate', SGSTRate);
            JItem.Add('CESS', CessValue);
            JItem.Add('CESSRate', CessRate);
            JItem.Add('CESSNonAdvol', CesNonAdval);
            JItem.Add('CESSNonAdvolRate', CesNonAdrate);

            JsonArrayData.Add(JItem);
        end;

        local procedure ExportAsJson(FileName: Text[20])
        var
            TempBlob: Codeunit "Temp Blob";
            ToFile: Variant;
            InStream: InStream;
            OutStream: OutStream;
            client: HttpClient;
            request: HttpRequestMessage;
            response: HttpResponseMessage;
            contentHeaders: HttpHeaders;
            content: HttpContent;
            responseText: Text;

            AccessToken: Text;
            JobjectResponse: JsonObject;
            JobjToken: JsonToken;
            Jobjarr: JsonArray;
            ackno: Text;
            i: Integer;
            ackdatetimetext: text;
            AcknowledgementDate: Date;
            Acknowledgementtime: Time;
            TempDateTime: DateTime;
            SignedQRCodeTxt1: Text;
            QRGenerator: Codeunit "QR Generator";
            TempBlob2: Codeunit "Temp Blob";
            FieldRef: FieldRef;
            EwayJsonToken: JsonToken;
            EwayJsonObject: JsonObject;
            errorDetailsJsonToken: JsonToken;
            j: Integer;
            JobjErrorarr: JsonArray;
            errorDetailsJsonObject: JsonObject;
            tempSalesCrMemo: Record "Sales Cr.Memo Header";

        begin
            JsonArrayData.Add(JObject);
            JsonArrayData.WriteTo(JsonText);

            TempBlob.CreateOutStream(OutStream);
            OutStream.WriteText(JsonText);
            ToFile := FileName + '11.json';
            TempBlob.CreateInStream(InStream);
            DownloadFromStream(InStream, 'e-Way', '', '', ToFile);
            Sleep(1000);


            AccessToken := '4ed40b313c14f70627df0958150b616b7d1291fcae6dd1d47e9134235568ad79';
            //'fe28e9b25dfe9390fb23a5dca981bf6a9f629950da954aa322f490a7dcf244e5';
            content.WriteFrom(JsonText);

            // Retrieve the contentHeaders associated with the content
            content.GetHeaders(contentHeaders);
            contentHeaders.Clear();
            contentHeaders.Add('Content-Type', 'application/json');


            client.DefaultRequestHeaders.Add('Authorization', 'Bearer ' + AccessToken);

            // Assigning content to request.Content will actually create a copy of the content and assign it.
            // After this line, modifying the content variable or its associated headers will not reflect in 
            // the content associated with the request message
            request.Content := content;

            request.SetRequestUri('https://sandbox-gstapi.trustfilegst.in/api/v1/taxpayers/29AAACW4202F1ZM/ewayTransactions');
            request.Method := 'POST';

            client.Send(request, response);
            if response.IsSuccessStatusCode then begin
                response.Content().ReadAs(responseText);
                // Message(responseText);
                // JobjectResponse.ReadFrom(responseText);
                //Message(format(JobjectResponse));


                if JobjToken.ReadFrom(responseText) then begin
                    if JobjToken.IsArray then   // json_Token.IsArray; json_Token.IsObject; json_Token.IsValue;
                        Jobjarr := JobjToken.AsArray();
                    for i := 0 to Jobjarr.Count() - 1 do begin
                        // Get First Array Result
                        Jobjarr.Get(i, JobjToken);
                        // Convert JsonToken to JsonObject
                        if JobjToken.IsObject then begin
                            JobjectResponse := JobjToken.AsObject();

                            //For error response

                            //for error
                            if JobjectResponse.Get('Errors', errorDetailsJsonToken) then begin
                                if errorDetailsJsonToken.IsArray then   // json_Token.IsArray; json_Token.IsObject; json_Token.IsValue;
                                    JobjErrorarr := errorDetailsJsonToken.AsArray();
                                for j := 0 to JobjErrorarr.Count() - 1 do begin

                                    // Get First Array Result
                                    JobjErrorarr.Get(i, errorDetailsJsonToken);
                                    if errorDetailsJsonToken.IsObject then begin
                                        errorDetailsJsonObject := errorDetailsJsonToken.AsObject();
                                        errorDetailsJsonObject.Get('Message', errorDetailsJsonToken);
                                        IF (errorDetailsJsonToken.AsValue().AsText() <> '') then begin
                                            Error(errorDetailsJsonToken.AsValue().AsText());
                                        end;
                                    end;

                                end;
                            end;

                            //for saving Eway Bill
                            if JobjectResponse.Get('EwayBillOutput', EwayJsonToken) then begin
                                // Get First Array Result
                                if EwayJsonToken.IsObject then begin

                                    tempSalesCrMemo.Reset();
                                    tempSalesCrMemo.SetRange("No.", SalesCrMemoHeader."No.");
                                    IF tempSalesCrMemo.FindFirst() then;

                                    EwayJsonObject := EwayJsonToken.AsObject();
                                    EwayJsonObject.Get('Eway_bill_id', EwayJsonToken);
                                    tempSalesCrMemo."E-Way Bill No." := EwayJsonToken.AsValue().AsText();
                                    tempSalesCrMemo.Modify(true);

                                end;
                            End;


                            Message('Eway Bill Updated sussfully');
                        end;

                    end;
                end;


            end
            Else begin
                Error('there is error , please check a download request file again for details');
                /*
                response.Content().ReadAs(responseText);

                if JobjToken.ReadFrom(responseText) then begin
                    if JobjToken.IsArray then   // json_Token.IsArray; json_Token.IsObject; json_Token.IsValue;
                        Jobjarr := JobjToken.AsArray();
                    for i := 0 to Jobjarr.Count() - 1 do begin
                        // Get First Array Result
                        Jobjarr.Get(i, JobjToken);
                        // Convert JsonToken to JsonObject
                        if JobjToken.IsObject then begin
                            JobjectResponse := JobjToken.AsObject();

                            //For error response

                            //for error
                            if JobjectResponse.Get('Errors', errorDetailsJsonToken) then begin
                                if errorDetailsJsonToken.IsArray then   // json_Token.IsArray; json_Token.IsObject; json_Token.IsValue;
                                    JobjErrorarr := errorDetailsJsonToken.AsArray();
                                for j := 0 to JobjErrorarr.Count() - 1 do begin

                                    // Get First Array Result
                                    JobjErrorarr.Get(i, errorDetailsJsonToken);
                                    if errorDetailsJsonToken.IsObject then begin
                                        errorDetailsJsonObject := errorDetailsJsonToken.AsObject();
                                        errorDetailsJsonObject.Get('message', errorDetailsJsonToken);
                                        IF (errorDetailsJsonToken.AsValue().AsText() <> '') then begin
                                            Error(errorDetailsJsonToken.AsValue().AsText());
                                        end;
                                    end;
                                end;
                            end;
                        End;
                    end;

                    Error('%1', responseText)
                End;

            end;
        end;
        

    procedure GetEInvoiceResponse(var RecRef: RecordRef; var responseText: Text)
    var
        JSONManagement: Codeunit "JSON Management";
        //  QRGenerator: Codeunit "QR Generator";
        TempBlob: Codeunit "Temp Blob";
        FieldRef: FieldRef;
        JsonString: Text;
        TempIRNTxt: Text;
        TempDateTime: DateTime;
        AcknowledgementDateTimeText: Text;
        AcknowledgementDate: Date;
        AcknowledgementTime: Time;
    begin
        JsonString := GetResponseText();
        if (JsonString = '') or (JsonString = '[]') then
            exit;

        JSONManagement.InitializeObject(JsonString);
        if JSONManagement.GetValue(IRNTxt) <> '' then begin
            /*
            FieldRef := RecRef.Field(SalesInvoiceHeader.FieldNo("IRN Hash"));
            FieldRef.Value := JSONManagement.GetValue(IRNTxt);
            FieldRef := RecRef.Field(SalesInvoiceHeader.FieldNo("Acknowledgement No."));
            FieldRef.Value := JSONManagement.GetValue(AcknowledgementNoTxt);

            AcknowledgementDateTimeText := JSONManagement.GetValue(AcknowledgementDateTxt);
            Evaluate(AcknowledgementDate, CopyStr(AcknowledgementDateTimeText, 1, 10));
            Evaluate(AcknowledgementTime, CopyStr(AcknowledgementDateTimeText, 11, 8));
            TempDateTime := CreateDateTime(AcknowledgementDate, AcknowledgementTime);
            FieldRef := RecRef.Field(SalesInvoiceHeader.FieldNo("Acknowledgement Date"));

            FieldRef.Value := TempDateTime;
            FieldRef := RecRef.Field(SalesInvoiceHeader.FieldNo(IsJSONImported));
            FieldRef.Value := true;
            // QRGenerator.GenerateQRCodeImage(JSONManagement.GetValue(SignedQRCodeTxt), TempBlob);
            FieldRef := RecRef.Field(SalesInvoiceHeader.FieldNo("QR Code"));
            TempBlob.ToRecordRef(RecRef, SalesInvoiceHeader.FieldNo("QR Code"));
            RecRef.Modify(); 
        end else
            Error(IRNHashErr, TempIRNTxt);

    end;

    local procedure GetResponseText() ResponseText: Text
    var
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        FileText: Text;
    begin
        TempBlob.CreateInStream(InStream);
        UploadIntoStream('', '', '', FileText, InStream);

        if FileText = '' then
            exit;

        InStream.ReadText(ResponseText);
    end;
    /*
        local procedure GetGSTValue(
            var AssessableAmount: Decimal;
            var CGSTAmount: Decimal;
            var SGSTAmount: Decimal;
            var IGSTAmount: Decimal;
            var CessAmount: Decimal;
            var StateCessValue: Decimal;
            var CessNonAdvanceAmount: Decimal;
            var DiscountAmount: Decimal;
            var OtherCharges: Decimal;
            var TotalInvoiceValue: Decimal)
        var
            SalesInvoiceLine: Record "Sales Invoice Line";
            //  SalesCrMemoLine: Record "Sales Cr.Memo Line";
            GSTLedgerEntry: Record "GST Ledger Entry";
            DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
            CurrencyExchangeRate: Record "Currency Exchange Rate";
            //  CustLedgerEntry: Record "Cust. Ledger Entry";
            TotGSTAmt: Decimal;
        begin
            GSTLedgerEntry.SetRange("Document No.", DocumentNo);

            GSTLedgerEntry.SetRange("GST Component Code", CGSTLbl);
            if GSTLedgerEntry.FindSet() then
                repeat
                    CGSTAmount += Abs(GSTLedgerEntry."GST Amount");
                until GSTLedgerEntry.Next() = 0
            else
                CGSTAmount := 0;

            GSTLedgerEntry.SetRange("GST Component Code", SGSTLbl);
            if GSTLedgerEntry.FindSet() then
                repeat
                    SGSTAmount += Abs(GSTLedgerEntry."GST Amount")
                until GSTLedgerEntry.Next() = 0
            else
                SGSTAmount := 0;

            GSTLedgerEntry.SetRange("GST Component Code", IGSTLbl);
            if GSTLedgerEntry.FindSet() then
                repeat
                    IGSTAmount += Abs(GSTLedgerEntry."GST Amount")
                until GSTLedgerEntry.Next() = 0
            else
                IGSTAmount := 0;

            CessAmount := 0;
            CessNonAdvanceAmount := 0;

            DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
            DetailedGSTLedgerEntry.SetRange("GST Component Code", CESSLbl);
            if DetailedGSTLedgerEntry.FindFirst() then
                repeat
                    if DetailedGSTLedgerEntry."GST %" > 0 then
                        CessAmount += Abs(DetailedGSTLedgerEntry."GST Amount")
                    else
                        CessNonAdvanceAmount += Abs(DetailedGSTLedgerEntry."GST Amount");
                until GSTLedgerEntry.Next() = 0;

            GSTLedgerEntry.SetFilter("GST Component Code", '<>CGST|<>SGST|<>IGST|<>CESS');
            if GSTLedgerEntry.FindSet() then
                repeat
                    StateCessValue += Abs(GSTLedgerEntry."GST Amount");
                until GSTLedgerEntry.Next() = 0;



        end;

        local procedure GetGSTComponentRate(
           DocumentNo: Code[20];
           LineNo: Integer;
           var CGSTRate: Decimal;
           var SGSTRate: Decimal;
           var IGSTRate: Decimal;
           var CessRate: Decimal;
           var CessNonAdvanceAmount: Decimal;
           var StateCess: Decimal)
        var
            DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        begin
            DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
            DetailedGSTLedgerEntry.SetRange("Document Line No.", LineNo);

            DetailedGSTLedgerEntry.SetRange("GST Component Code", CGSTLbl);
            if DetailedGSTLedgerEntry.FindFirst() then
                CGSTRate := DetailedGSTLedgerEntry."GST %"
            else
                CGSTRate := 0;

            DetailedGSTLedgerEntry.SetRange("GST Component Code", SGSTLbl);
            if DetailedGSTLedgerEntry.FindFirst() then
                SGSTRate := DetailedGSTLedgerEntry."GST %"
            else
                SGSTRate := 0;

            DetailedGSTLedgerEntry.SetRange("GST Component Code", IGSTLbl);
            if DetailedGSTLedgerEntry.FindFirst() then
                IGSTRate := DetailedGSTLedgerEntry."GST %"
            else
                IGSTRate := 0;

            CessRate := 0;
            CessNonAdvanceAmount := 0;
            DetailedGSTLedgerEntry.SetRange("GST Component Code", CESSLbl);
            if DetailedGSTLedgerEntry.FindFirst() then
                if DetailedGSTLedgerEntry."GST %" > 0 then
                    CessRate := DetailedGSTLedgerEntry."GST %"
                else
                    CessNonAdvanceAmount := Abs(DetailedGSTLedgerEntry."GST Amount");

            StateCess := 0;
            DetailedGSTLedgerEntry.SetRange("GST Component Code");
            if DetailedGSTLedgerEntry.FindSet() then
                repeat
                    if not (DetailedGSTLedgerEntry."GST Component Code" in [CGSTLbl, SGSTLbl, IGSTLbl, CESSLbl])
                    then
                        StateCess := DetailedGSTLedgerEntry."GST %";
                until DetailedGSTLedgerEntry.Next() = 0;
        end;


        local procedure GetGSTValueForLine(
             DocumentNo: Code[20];
            DocumentLineNo: Integer;
            var CGSTLineAmount: Decimal;
            var SGSTLineAmount: Decimal;
            var IGSTLineAmount: Decimal)
        var
            DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        begin
            CGSTLineAmount := 0;
            SGSTLineAmount := 0;
            IGSTLineAmount := 0;

            DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
            DetailedGSTLedgerEntry.SetRange("Document Line No.", DocumentLineNo);
            DetailedGSTLedgerEntry.SetRange("GST Component Code", CGSTLbl);
            if DetailedGSTLedgerEntry.FindSet() then
                repeat
                    CGSTLineAmount += Abs(DetailedGSTLedgerEntry."GST Amount");
                until DetailedGSTLedgerEntry.Next() = 0;

            DetailedGSTLedgerEntry.SetRange("GST Component Code", SGSTLbl);
            if DetailedGSTLedgerEntry.FindSet() then
                repeat
                    SGSTLineAmount += Abs(DetailedGSTLedgerEntry."GST Amount")
                until DetailedGSTLedgerEntry.Next() = 0;

            DetailedGSTLedgerEntry.SetRange("GST Component Code", IGSTLbl);
            if DetailedGSTLedgerEntry.FindSet() then
                repeat
                    IGSTLineAmount += Abs(DetailedGSTLedgerEntry."GST Amount")
                until DetailedGSTLedgerEntry.Next() = 0;
        end;
       










}
*/