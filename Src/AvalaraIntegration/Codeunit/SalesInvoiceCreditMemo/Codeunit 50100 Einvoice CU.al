codeunit 50107 "Einvoice CU"
{
    SingleInstance = true;
    trigger OnRun()
    begin
    end;

    var
        hbToken: Text;
        hbKey: Text;
        JObject1: JsonObject;
        josntext: Text[20];
        DocType: Option " ","E-invoice","Credit","Transfer";

    local procedure "-------------EWay Bill Only-------------"()
    begin
    end;

    procedure EwayHostbookLogin(var Store: Record Location; TH: Record "Transfer Shipment Header"; SI: Record "Sales Invoice Header"; DocType: Option Transfer,SaleInvoice)
    var
        JSONReq: Text;
        MyFile: File;
        FileName: Text;
        "XmlPort": HttpClient;//HttpClient Ashish
        Resp: Text;
        UserAccNo: Text;
        Connectorid: Text;
        RStore: Record Location;
        Token: Text;
        Userid: Text;
        Buid: Text;
        gstinid: Text;
        RetailSetup: Record "LSC Retail Setup";
        gResponseMsg: Text;
        gRequestMsg: Text;
        WinHttpService: HttpClient;
        gHttpClient: HttpClient;
        gContent: HttpContent;
        gHttpResponseMsg: HttpResponseMessage;
        gHttpRequestMsg: HttpRequestMessage;
        gContentHeaders: HttpHeaders;
        URL: Text;
    begin
        URL := 'https://eway.hostbooks.com/ewbapp/api/ewb/logintally';
        //   URL := 'https://sandboxgst.hostbooks.in/ewbapi/api/ewb/logintally';
        ClearLastError();
        Clear(gResponseMsg);
        gContent.WriteFrom(gRequestMsg);
        gContent.GetHeaders(gContentHeaders);
        gContentHeaders.Clear();
        gContentHeaders.Add('Content-Type', 'application/json');
        gContentHeaders.Add('Secret-Key', 'ns4LxrMhWncg1W1ajKKJhRJFQIqzmgGEzXSGsWtVImjOww1BLztUZJyYW5e/WE6iKCZwL4wvPE/g6vxlrFvZ1sLdzfknJmQe5ByYQ2+Uge8iJ4j1LcWT6ZamL+OFquOEJvSm6vWoeLKJ9c+noizErkQwJhO2OUAj5n1F+uCSOBU=');
        if gHttpClient.Post(URL, gContent, gHttpResponseMsg) then begin
            gHttpResponseMsg.Content.ReadAs(gResponseMsg);
            if gHttpResponseMsg.IsSuccessStatusCode then begin
                //   //Message('Response %1', gResponseMsg);
                Resp := gResponseMsg;
            end;
        end;

        //  MESSAGE(Resp);
        // APILog(JSONReq, Resp, 'LoginAPI');
        IF STRPOS(Resp, '"hbOutcome":"Login successfully"') <> 0 THEN BEGIN
            Token := COPYSTR(Resp, STRPOS(Resp, '"token":') + 9, STRPOS(Resp, '"buid":') - 63);
            IF (Store."E-Way Bill Business GSTIN" = '') OR (Store."E-Way Bill Business ID" = '') OR
              (Store."HB Account user ID number" = '') THEN BEGIN
                Store."E-Way Bill Business GSTIN" := COPYSTR(Resp, STRPOS(Resp, '"gstinid":') + 11, 3);
                Store."E-Way Bill Business ID" := COPYSTR(Resp, STRPOS(Resp, '"buid":') + 8, 3);
                Store."HB Account user ID number" := COPYSTR(Resp, STRPOS(Resp, '"userid":') + 10, 3);
                Store.MODIFY;
                COMMIT;
            END;
            EwayHostBooksAuthenticate(Store, Token, TH, SI, DocType)
        END ELSE
            ERROR(Resp);
    end;

    procedure EwayHostBooksAuthenticate(Store: Record Location; token: Text; TH: Record "Transfer Shipment Header"; SI: Record "Sales Invoice Header"; DocType: Option Transfer,SaleInvoice): Text
    var
        JSONReq: Text;
        MyFile: File;
        FileName: Text;
        "XmlPort": HttpClient;
        Resp: Text;
        Connectorid: Text;
        RStore: Record "LSC STORE";
        TokentrimFrom: Integer;
        TokentrimTo: Integer;
        Ostream: OutStream;
        KeytrimFrom: Integer;
        KeytrimTo: Integer;
        gResponseMsg: Text;
        gRequestMsg: Text;
        WinHttpService: HttpClient;
        gHttpClient: HttpClient;
        gContent: HttpContent;
        gHttpResponseMsg: HttpResponseMessage;
        gHttpRequestMsg: HttpRequestMessage;
        gContentHeaders: HttpHeaders;
        URL: Text;
    begin
        Store.TESTFIELD("Eway bill API password");
        Store.TESTFIELD("Eway Bill API User-ID");
        CLEAR(JSONReq);
        IF JSONReq = '' THEN
            JSONReq := '{"userid": "' + Store."HB Account user ID number" +
                     '","buid": "' + Store."E-Way Bill Business ID" +
                     '","gstinid": "' + Store."E-Way Bill Business GSTIN" +
                     '","ewbUserID":"' + Store."Eway Bill API User-ID" +
                     '","ewbPassword":"' + Store."Eway bill API password" + '"}';


        URL := 'https://eway.hostbooks.com/ewbapp/api/ewb/generate-token';
        //        URL := 'https://sandboxgst.hostbooks.in/ewbapi/api/ewb/generate-token';
        ClearLastError();
        Clear(gResponseMsg);
        gContent.WriteFrom(JSONReq);
        gContent.GetHeaders(gContentHeaders);
        gContentHeaders.Clear();
        gContentHeaders.Add('Content-Type', 'application/json');
        gContentHeaders.Add('Secret-Key', 'ns4LxrMhWncg1W1ajKKJhRJFQIqzmgGEzXSGsWtVImjOww1BLztUZJyYW5e/WE6iKCZwL4wvPE/g6vxlrFvZ1sLdzfknJmQe5ByYQ2+Uge8iJ4j1LcWT6ZamL+OFquOEJvSm6vWoeLKJ9c+noizErkQwJhO2OUAj5n1F+uCSOBU=');
        gContentHeaders.Add('Authorization', 'Bearer' + ' ' + token);
        if gHttpClient.Post(URL, gContent, gHttpResponseMsg) then begin
            gHttpResponseMsg.Content.ReadAs(gResponseMsg);
            if gHttpResponseMsg.IsSuccessStatusCode then begin
                //Message('Response %1', gResponseMsg);
                Resp := gResponseMsg;
            end;
        end;


        // IF ISCLEAR(XmlPort) THEN
        //     CREATE(XmlPort, TRUE, TRUE);
        // //Production: https://eway.hostbooks.com/ewbapp/api/ewb/generate-token
        // //Sandbox: https://sandboxgst.hostbooks.in/ewbapi/api/ewb/generate-token
        // XmlPort.open('POST', 'https://eway.hostbooks.com/ewbapp/api/ewb/generate-token', 0);
        // XmlPort.setRequestHeader('Content-Type', 'application/json');
        // XmlPort.setRequestHeader('Secret-Key', 'ns4LxrMhWncg1W1ajKKJhRJFQIqzmgGEzXSGsWtVImjOww1BLztUZJyYW5e/WE6iKCZwL4wvPE/g6vxlrFvZ1sLdzfknJmQe5ByYQ2+Uge8iJ4j1LcWT6ZamL+OFquOEJvSm6vWoeLKJ9c+noizErkQwJhO2OUAj5n1F+uCSOBU=');
        // XmlPort.setRequestHeader('Authorization', 'Bearer' + ' ' + token);
        // XmlPort.send(JSONReq);
        // Resp := XmlPort.responseText;
        //MESSAGE(Resp);
        // APILog(JSONReq, Resp, 'EwayAuth');
        IF STRPOS(Resp, '"isSuccess":true') <> 0 THEN BEGIN
            IF DocType = DocType::Transfer THEN
                EwayGenerateIRNNumber(TH, token)
            ELSE
                EwaySINVGenerateIRNNumber(SI, token);
        END ELSE
            ERROR(Resp);
    end;

    procedure EwayGenerateIRNNumber(TH: Record "Transfer Shipment Header"; Token: Text)
    var
        TL: Record "Transfer Shipment Line";
        TH1: Record "Transfer Shipment Header";
        SellerStore: Record Location;
        BuyerStore: Record Location;
        CompanyInformation: Record "CompanY Information";
        State: Record State;
        JSON1: Text;
        ItemDetails: Text;
        CustomerStateCode: Text;
        StoreStateCode: Text;
        MyFile: File;
        FileName: Text;
        "XmlPort": HttpClient;
        Resp: Text;
        Customer: Record Customer;
        BuyerGSTIN: Code[20];
        QRData: Text;
        DateTrimFrom: Integer;
        DateTrimto: Integer;
        CalculationType: Option "Item Wise",Total;
        BillToPINCODE: Code[10];
        ShipToPINCODE: Code[10];
        BuyerAddress: Text;
        ShipingAddress: Text;
        Store: Record Location;
        AmountReq: Option Amount,AmountIncGST;
        TrFromPIN: Code[10];
        TrTOPIN: Code[10];
        JKey: Text;
        JToken: Text;
        CessTotalAmt: Text;
        gResponseMsg: Text;
        gRequestMsg: Text;
        WinHttpService: HttpClient;
        gHttpClient: HttpClient;
        gContent: HttpContent;
        gHttpResponseMsg: HttpResponseMessage;
        gHttpRequestMsg: HttpRequestMessage;
        gContentHeaders: HttpHeaders;
        URL: Text;
    begin
        CLEAR(JSON1);
        CLEAR(BuyerGSTIN);
        CLEAR(CustomerStateCode);
        CLEAR(StoreStateCode);
        CLEAR(QRData);
        CLEAR(BillToPINCODE);
        CLEAR(ShipToPINCODE);
        CLEAR(CessTotalAmt);
        CheckInvoiceStatus(TH);
        CompanyInformation.GET;
        ItemDetails := EwayGetItemDetails(TH);
        SellerStore.GET(TH."Transfer-from Code");
        State.RESET;
        State.SETRANGE(Code, SellerStore."State Code"); //State-IN 
        IF State.FINDFIRST THEN
            StoreStateCode := State."State Code (Einvoice)";
        BuyerStore.GET(TH."Transfer-to Code");
        State.RESET;
        State.SETRANGE(Code, BuyerStore."State Code");
        IF State.FINDFIRST THEN
            CustomerStateCode := State."State Code (Einvoice)";
        CLEAR(TrTOPIN);
        CLEAR(TrFromPIN);

        IF STRLEN(SellerStore."Post Code") > 6 THEN
            TrFromPIN := COPYSTR(SellerStore."Post Code", 4, 10)
        ELSE
            TrFromPIN := SellerStore."Post Code";

        IF STRLEN(BuyerStore."Post Code") > 6 THEN
            TrTOPIN := COPYSTR(BuyerStore."Post Code", 4, 10)
        ELSE
            TrTOPIN := BuyerStore."Post Code";

        IF GetTotalGSTDetails(TH, '', 'CESS%') <> '0' THEN
            CessTotalAmt := GetTotalGSTDetails(TH, '', 'CESS%')
        ELSE
            CessTotalAmt := GetTotalGSTDetails(TH, '', 'CESS');
        IF JSON1 = '' THEN
            JSON1 := '{"userGstin": "' + SellerStore."GST Registration No." +
                   '","supplyType": "O","subSupplyType": "5","subSupplyDesc":""' +
                   ',"docType": "CHL","docNo": "' + TH."No." +
                   '","docDate": "' + FORMAT(TH."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>') +
                   '","fromGstin": "' + SellerStore."GST Registration No." +
                   '","fromTrdName": "' + SellerStore.Name +
                   '","fromAddr1": "' + SellerStore.Address +
                   '","fromAddr2": "' + SellerStore."Address 2" +
                   '","fromPlace": "' + SellerStore.City +
                   '","fromPincode": "' + SellerStore."Post Code" +
                   '","fromStateCode": "' + StoreStateCode +
                   '","actFromStateCode": "' + StoreStateCode +
                   '","toGstin": "' + BuyerStore."GST Registration No." + '","toTrdName": "' + BuyerStore.Name +
                   '","toAddr1": "' + BuyerStore.Address +
                   '","toAddr2": null,"toPlace": "' + BuyerStore.City +
                   '","toPincode": "' + BuyerStore."Post Code" +
                   '","toStateCode": "' + CustomerStateCode +
                   '","actToStateCode": "' + CustomerStateCode +
                   '","totalValue": "' + DELCHR(FORMAT(GetLineAmount(TH, AmountReq::Amount)), '=', ',') +
                   //'","cgstValue": "'+GetTotalGSTDetails(TH,'','CGST')+
                   //'","sgstValue": "'+ GetTotalGSTDetails(TH,'','SGST')+
                   '","igstValue": "' + GetTotalGSTDetails(TH, '', 'IGST') +
                   '","cessValue": "' + CessTotalAmt +
                   '","transMode": "1"' +
                   // ',"transDistance": "' + FORMAT(ROUND(TH."Distance (In KM)", 1)) +
                   '","transporterName": ""' +
                   ',"transporterId": "' +
                   '","transDocNo": "' + TH."LR/RR No." +
                   '","transDocDate": "' + FORMAT(TH."LR/RR Date", 0, '<Day,2>/<Month,2>/<Year4>') +
                   '","vehicleNo": "' + TH."Vehicle No." +
                   '","vehicleType": "R"' +
                   ',"transactionType": "1"' +
                   ',"totInvValue": "' + DELCHR(FORMAT(GetLineAmount(TH, AmountReq::AmountIncGST)), '=', ',') + '"' +
                  // '","mainHsnCode": "8528"'+
                  //',"otherValue": "0.00","cessNonAdvolValue": "0.00","transactionType": "1",'+
                  ',"itemList": [' + ItemDetails + ']}';
        // XmlPort.open('POST', 'https://eway.hostbooks.com/ewbapp/api/ewb/generate-bill', 0);
        // XmlPort.setRequestHeader('Content-Type', 'application/json');
        // XmlPort.setRequestHeader('Secret-Key', 'ns4LxrMhWncg1W1ajKKJhRJFQIqzmgGEzXSGsWtVImjOww1BLztUZJyYW5e/WE6iKCZwL4wvPE/g6vxlrFvZ1sLdzfknJmQe5ByYQ2+Uge8iJ4j1LcWT6ZamL+OFquOEJvSm6vWoeLKJ9c+noizErkQwJhO2OUAj5n1F+uCSOBU=');
        // XmlPort.setRequestHeader('Authorization', 'Bearer' + ' ' + Token);
        // XmlPort.send(JSON1);
        // Resp := XmlPort.responseText;
        URL := 'https://eway.hostbooks.com/ewbapp/api/ewb/generate-token';
        ClearLastError();
        Clear(gResponseMsg);
        gContent.WriteFrom(JSON1);
        gContent.GetHeaders(gContentHeaders);
        gContentHeaders.Clear();
        gContentHeaders.Add('Content-Type', 'application/json');
        gContentHeaders.Add('Secret-Key', 'ns4LxrMhWncg1W1ajKKJhRJFQIqzmgGEzXSGsWtVImjOww1BLztUZJyYW5e/WE6iKCZwL4wvPE/g6vxlrFvZ1sLdzfknJmQe5ByYQ2+Uge8iJ4j1LcWT6ZamL+OFquOEJvSm6vWoeLKJ9c+noizErkQwJhO2OUAj5n1F+uCSOBU=');
        gContentHeaders.Add('Authorization', 'Bearer' + ' ' + token);
        if gHttpClient.Post(URL, gContent, gHttpResponseMsg) then begin
            gHttpResponseMsg.Content.ReadAs(gResponseMsg);
            if gHttpResponseMsg.IsSuccessStatusCode then begin
                //  //Message('Response %1', gResponseMsg);
                Resp := gResponseMsg;
            end;
        end;
        //MESSAGE(Resp);
        // APILog(JSON1, Resp, 'EwayGenerate');
        IF STRPOS(Resp, '"isSuccess":true') <> 0 THEN BEGIN
            //TH."Eway Bill No." := COPYSTR(Resp, STRPOS(Resp, '"ewayBillNo":"') + 14, 12);
            TH.MODIFY;
        END ELSE
            ERROR(Resp);
    end;

    procedure EwayGetItemDetails(TransferHeader: Record "Transfer Shipment Header"): Text
    var
        TransferLine: Record "Transfer Shipment Line";
        ItemJson: Text;
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        UnitofMeasure: Record "Unit of Measure";
        GSTRate: Text;
        HSN: Code[10];
        CalculationType: Option "Item Wise",Total;
        IsService: Text;
        RItem: Record Item;
        GSTRatePer: Text;
        CessRate: Text;
        CessAmt: Text;
        SLNo: Integer;
        IgstAmt: Text;
    begin
        CLEAR(ItemJson);
        CLEAR(GSTRate);
        CLEAR(HSN);
        CLEAR(CessRate);
        CLEAR(CessAmt);
        TransferLine.RESET;
        TransferLine.SETRANGE("Document No.", TransferHeader."No.");
        TransferLine.SETRANGE("Transfer-from Code", TransferHeader."Transfer-from Code");
        IF TransferLine.FINDSET THEN
            REPEAT
                //GSTRate:=ROUND(TransferLine."GST %",1);
                IF UnitofMeasure.GET(TransferLine."Unit of Measure Code") THEN;
                //IF TransferHeader."Sales Type"='SHOWROOM' THEN
                IsService := 'N';
                // ELSE
                // IsService:='Y';
                IF TransferLine."HSN/SAC Code" = '996331' THEN
                    IsService := 'Y';
                RItem.GET(TransferLine."Item No.");

                //IF STRLEN(TransferLine."HSN/SAC Code") < 4 THEN //Temp Comment
                HSN := RItem."HSN/SAC Code"; //Temp to clear pending invoices
                                             //HSN:='11021000';
                                             //ELSE //Temp Comment
                                             // HSN:=TransferLine."HSN/SAC Code";

                IF STRLEN(FORMAT(TransferLine."Line No.")) > 6 THEN
                    SLNo := TransferLine."Line No." / 1000
                ELSE
                    SLNo := TransferLine."Line No.";

                IF ItemJson = '' THEN
                    ItemJson := '{"itemNo":"' + TransferLine."Item No." +
                              '","productName":"' + TransferLine.Description +
                              '","productDesc":"' + TransferLine.Description +
                              '","hsnCode":"' + HSN +
                              '","quantity":"' + DELCHR(FORMAT(TransferLine.Quantity), '=', ',') +
                              '","qtyUnit": "' + FORMAT(UnitofMeasure."E UOM") +
                              '","taxableAmount":"' + DELCHR(FORMAT(''), '=', ',') +//Ashish TransferLine."GST Base Amount"
                                                                                    //'","sgstRate":"'+GSTDetails(TransferLine,TransferLine."Item No.",'SGST',TransferLine."Line No.",TransferHeader)+
                                                                                    //'","cgstRate":"'+GSTDetails(TransferLine,TransferLine."Item No.",'CGST',TransferLine."Line No.",TransferHeader)+
                              '","igstRate":"' + GSTDetails(TransferLine, TransferLine."Item No.", 'IGST', TransferLine."Line No.", TransferHeader) +
                              //'","cessRate":"'+CessRate+'","cessNonAdvol": "0.00"'+
                              '"}'
                ELSE
                    ItemJson += ',{"itemNo":"' + TransferLine."Item No." +
                              '","productName":"' + TransferLine.Description +
                              '","productDesc":"' + TransferLine.Description +
                              '","hsnCode":"' + HSN +
                              '","quantity":"' + DELCHR(FORMAT(TransferLine.Quantity), '=', ',') +
                              '","qtyUnit": "' + FORMAT(UnitofMeasure."E UOM") +
                              '","taxableAmount":"' + DELCHR(FORMAT(''), '=', ',') +//TransferLine."GST Base Amount"  Ashish
                                                                                    //'","sgstRate":"'+GSTDetails(TransferLine,TransferLine."Item No.",'SGST',TransferLine."Line No.",TransferHeader)+
                                                                                    //'","cgstRate":"'+GSTDetails(TransferLine,TransferLine."Item No.",'CGST',TransferLine."Line No.",TransferHeader)+
                               '","igstRate":"' + GSTDetails(TransferLine, TransferLine."Item No.", 'IGST', TransferLine."Line No.", TransferHeader) +

                              //'","igstRate":"'+GSTDetails(TransferLine,TransferLine."Item No.",'IGST',TransferLine."Line No.",TransferHeader)+
                              //'","cessRate":"'+CessRate+'","cessNonAdvol": "0.00"'+
                              '"}';

            UNTIL TransferLine.NEXT = 0;

        EXIT(ItemJson);
    end;

    procedure EwaySINVGenerateIRNNumber(SH: Record "Sales Invoice Header"; Token: Text)
    var
        SL: Record "Sales Invoice Line";
        SH1: Record "Sales Invoice Header";
        Store: Record Location;
        CompanyInformation: Record "Company Information";
        State: Record "State";
        JSON1: Text;
        ItemDetails: Text;
        CustomerStateCode: Text;
        StoreStateCode: Text;
        MyFile: File;
        FileName: Text;
        "XmlPort": HttpClient;
        Resp: Text;
        Customer: Record Customer;
        BuyerGSTIN: Code[20];
        QRData: Text;
        DateTrimFrom: Integer;
        DateTrimto: Integer;
        CalculationType: Option "Item Wise",Total;
        BillToPINCODE: Code[10];
        ShipToPINCODE: Code[10];
        BuyerAddress: Text;
        ShipingAddress: Text;
        JKey: Text;
        JToken: Text;
        City: Text;
        gResponseMsg: Text;
        gRequestMsg: Text;
        WinHttpService: HttpClient;
        gHttpClient: HttpClient;
        gContent: HttpContent;
        gHttpResponseMsg: HttpResponseMessage;
        gHttpRequestMsg: HttpRequestMessage;
        gContentHeaders: HttpHeaders;
        URL: Text;
    begin
        CLEAR(JSON1);
        CLEAR(BuyerGSTIN);
        CLEAR(CustomerStateCode);
        CLEAR(StoreStateCode);
        CLEAR(QRData);
        CLEAR(BillToPINCODE);
        CLEAR(ShipToPINCODE);

        //SaleInvoice_CheckInvoiceStatus(SH);

        Store.GET(SH."Location Code");
        CompanyInformation.GET;
        ItemDetails := EwaySINVGetItemDetails(SH);
        State.RESET;
        State.SETRANGE(Code, Store."State Code");
        IF State.FINDFIRST THEN
            StoreStateCode := State."State Code (Einvoice)";

        State.RESET;
        State.SETRANGE(Code, SH."Bill to Customer State");
        IF State.FINDFIRST THEN
            CustomerStateCode := State."State Code (Einvoice)";

        SH.CALCFIELDS(Amount);//Ashish---//, "Amount to Customer"
        Customer.GET(SH."Sell-to Customer No.");
        BuyerGSTIN := Customer."GST Registration No.";

        BuyerAddress := '';
        IF SH."Bill-to Address 2" = '' THEN
            BuyerAddress := SH."Bill-to City";

        IF SH."Bill-to Address 2" = '' THEN
            ShipingAddress := SH."Ship-to City";

        IF STRLEN(SH."Bill-to Post Code") = 6 THEN BEGIN
            BillToPINCODE := SH."Bill-to Post Code";
        END ELSE BEGIN
            BillToPINCODE := COPYSTR(SH."Bill-to Post Code", 4, 9);
        END;

        IF STRLEN(SH."Ship-to Post Code") = 6 THEN BEGIN
            ShipToPINCODE := SH."Ship-to Post Code";
        END ELSE BEGIN
            ShipToPINCODE := COPYSTR(SH."Ship-to Post Code", 4, 9);
        END;
        //Temp to clear pending invoices


        IF SH."Bill-to City" = '' THEN
            City := Customer.City
        ELSE
            City := SH."Bill-to City";
        //Temp to clear pending invoices

        IF JSON1 = '' THEN
            JSON1 := '{"userGstin": "' + Store."GST Registration No." +
                   '","supplyType": "O","subSupplyType": "1","subSupplyDesc":""' +
                   ',"docType": "INV","docNo": "' + SH."No." +
                   '","docDate": "' + FORMAT(SH."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>') +
                   '","fromGstin": "' + Store."GST Registration No." +
                   '","fromTrdName": "' + Store.Name +
                   '","fromAddr1": "' + Store.Address +
                   '","fromAddr2": "' + Store."Address 2" +
                   '","fromPlace": "' + Store.City +
                   '","fromPincode": "' + Store."Post Code" +
                   '","fromStateCode": "' + StoreStateCode +
                   '","actFromStateCode": "' + StoreStateCode +
                   '","toGstin": "' + BuyerGSTIN + '","toTrdName": "' + SH."Sell-to Customer Name" +
                   '","toAddr1": "' + SH."Bill-to Address" +
                   '","toAddr2": null,"toPlace": "' + City +
                   '","toPincode": "' + BillToPINCODE +
                   '","toStateCode": "' + CustomerStateCode +
                   '","actToStateCode": "' + CustomerStateCode +
                   '","transMode": "1"' +
                   ',"transDistance": "' + FORMAT(Store."Distance in KM") +
                   '","transporterName": ""' +
                   ',"transporterId": "' +
                   '","transDocNo": "' + '1234567' +
                   '","transDocDate": "' + FORMAT(SH."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>') +
                   '","vehicleNo": "' + 'DL03BB1234' +
                   '","vehicleType": "R"' +
                   ',"transactionType": "1"' +
                  ',"itemList": [' + ItemDetails + ']}';


        //Production: https://eway.hostbooks.com/ewbapp/api/ewb/generate-bill
        // //Sandbox: https://sandboxgst.hostbooks.in/ewbapi/api/ewb/generate-bill
        // XmlPort.open('POST', 'https://sandboxgst.hostbooks.in/ewbapi/api/ewb/generate-bill', 0);
        // XmlPort.setRequestHeader('Content-Type', 'application/json');
        // XmlPort.setRequestHeader('Secret-Key', 'ns4LxrMhWncg1W1ajKKJhRJFQIqzmgGEzXSGsWtVImjOww1BLztUZJyYW5e/WE6iKCZwL4wvPE/g6vxlrFvZ1sLdzfknJmQe5ByYQ2+Uge8iJ4j1LcWT6ZamL+OFquOEJvSm6vWoeLKJ9c+noizErkQwJhO2OUAj5n1F+uCSOBU=');
        // XmlPort.setRequestHeader('Authorization', 'Bearer' + ' ' + Token);
        // XmlPort.send(JSON1);
        // Resp := XmlPort.responseText;

        URL := 'https://eway.hostbooks.com/ewbapp/api/ewb/generate-bill';
        ClearLastError();
        Clear(gResponseMsg);
        gContent.WriteFrom(JSON1);
        gContent.GetHeaders(gContentHeaders);
        gContentHeaders.Clear();
        gContentHeaders.Add('Content-Type', 'application/json');
        gContentHeaders.Add('Secret-Key', 'ns4LxrMhWncg1W1ajKKJhRJFQIqzmgGEzXSGsWtVImjOww1BLztUZJyYW5e/WE6iKCZwL4wvPE/g6vxlrFvZ1sLdzfknJmQe5ByYQ2+Uge8iJ4j1LcWT6ZamL+OFquOEJvSm6vWoeLKJ9c+noizErkQwJhO2OUAj5n1F+uCSOBU=');
        gContentHeaders.Add('Authorization', 'Bearer' + ' ' + token);
        if gHttpClient.Post(URL, gContent, gHttpResponseMsg) then begin
            gHttpResponseMsg.Content.ReadAs(gResponseMsg);
            if gHttpResponseMsg.IsSuccessStatusCode then begin
                //Message('Response %1', gResponseMsg);
                Resp := gResponseMsg;
            end;
        end;




        //  MESSAGE(Resp);
        IF STRPOS(Resp, '"isSuccess":true') <> 0 THEN BEGIN
            //  SH."Eway Bill No.":=COPYSTR(Resp,STRPOS(Resp,'"ewayBillNo":"')+14,12);
            // SH.MODIFY;
        END ELSE
            ERROR(Resp);
    end;

    procedure EwaySINVGetItemDetails(SalesHeader: Record "Sales Invoice Header"): Text
    var
        SalesLine: Record "Sales Invoice Line";
        ItemJson: Text;
        DetailedGSTEntryBuffer: Record "Detailed GST Ledger Entry";
        UnitofMeasure: Record "Unit of Measure";
        GSTRate: Decimal;
        HSN: Code[10];
        CalculationType: Option "Item Wise",Total;
        IsService: Text;
        RItem: Record Item;
        GlAcc: Record "G/L Account";
    begin
        CLEAR(ItemJson);
        CLEAR(GSTRate);
        CLEAR(HSN);
        SalesLine.RESET;
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.SetFilter("HSN/SAC Code", '<>%1', '');
        SalesLine.SetFilter(SalesLine.Description, '<>%1', 'ROUNDED OFF');
        SalesLine.SetFilter(Type, '%1|%2', SalesLine.Type::Item, SalesLine.Type::"G/L Account");
        IF SalesLine.FINDSET THEN
            REPEAT
                //Ashish GSTRate := ROUND(SalesLine."GST %", 1);
                IF UnitofMeasure.GET(SalesLine."Unit of Measure Code") THEN;
                Clear(RItem);
                IF RItem.GET(SalesLine."No.") then;
                HSN := RItem."HSN/SAC Code"; //Temp to clear pending invoices
                Clear(GlAcc);
                IF GlAcc.Get(SalesLine."No.") then
                    HSN := GlAcc."HSN/SAC Code";


                IF SalesLine."HSN/SAC Code" = '996331' THEN
                    IsService := 'Y'
                ELSE
                    IsService := 'N';



                IF ItemJson = '' THEN
                    ItemJson := '{"itemNo":"' + SalesLine."No." +
                              '","productName":"' + SalesLine.Description +
                              '","productDesc":"' + SalesLine.Description +
                              '","hsnCode":"' + HSN +
                              '","quantity":"' + DELCHR(FORMAT(SalesLine.Quantity), '=', ',') +
                              '","qtyUnit": "' + FORMAT(UnitofMeasure."E UOM") + '"}'
                ELSE
                    ItemJson += ',{"itemNo":"' + SalesLine."No." +
                              '","productName":"' + SalesLine.Description +
                              '","productDesc":"' + SalesLine.Description +
                              '","hsnCode":"' + HSN +
                              '","quantity":"' + DELCHR(FORMAT(SalesLine.Quantity), '=', ',') +
                              '","qtyUnit": "' + FORMAT(UnitofMeasure."E UOM") + '"}';
            //
            //
            //
            UNTIL SalesLine.NEXT = 0;

        EXIT(ItemJson);
    end;

    local procedure "----------------------EInvoice---------------"()
    begin
    end;

    procedure HostbookLogin(var Store: Record Location)
    var
        JSONReq: Text;
        MyFile: File;
        FileName: Text;
        "XmlPort": HttpClient;
        Resp: Text;
        UserAccNo: Text;
        Connectorid: Text;
        RStore: Record Location;
        gResponseMsg: Text;
        gRequestMsg: Text;
        WinHttpService: HttpClient;
        gHttpClient: HttpClient;
        gContent: HttpContent;
        gHttpResponseMsg: HttpResponseMessage;
        gHttpRequestMsg: HttpRequestMessage;
        gContentHeaders: HttpHeaders;
        URL: Text;
        token: Text;
    begin
        IF Store."Hostbook UserAccNo" = '' THEN BEGIN
            Store.TESTFIELD("Hostbook Login ID");
            Store.TESTFIELD("Hostbook ConnectorID");
            Store.TESTFIELD("Hostbook Password");
            CLEAR(JSONReq);
            RStore.GET(Store.Code);
            IF JSONReq = '' THEN
                JSONReq := '{"loginId": "' + Store."Hostbook Login ID" +
                         '","password": "' + Store."Hostbook Password" +
                         '","conneectorId": "' + Store."Hostbook ConnectorID" + '"}';
            MESSAGE(JSONReq);

            URL := 'https://gstapihb.hostbooks.com/dec/api/Login/signin';
            // URL := 'https://hbapi.hostbooks.in/GSTTALLY/api/Login/signin';
            ClearLastError();
            Clear(gResponseMsg);
            gContent.WriteFrom(JSONReq);
            gContent.GetHeaders(gContentHeaders);
            gContentHeaders.Clear();
            gContentHeaders.Add('Content-Type', 'application/json');
            gContentHeaders.Add('Secret-Key', 'ns4LxrMhWncg1W1ajKKJhRJFQIqzmgGEzXSGsWtVImj Oww1BLztUZJyYW5e/WE6iKCZwL4wvPE/g6vxlrFvZ1sL dzfknJmQe5ByYQ2+Uge8iJ4j1LcWT6ZamL+OFquOEJvS m6vWoeLKJ9c+noizErkQwJhO2OUAj5n1F+uCSOBU=');
            //    gContentHeaders.Add('Authorization', 'Bearer' + ' ' + token);
            if gHttpClient.Post(URL, gContent, gHttpResponseMsg) then begin
                gHttpResponseMsg.Content.ReadAs(gResponseMsg);
                if gHttpResponseMsg.IsSuccessStatusCode then begin
                    //Message('Response %1', gResponseMsg);
                    Resp := gResponseMsg;
                end;
            end;
            IF STRPOS(Resp, '"hbOutcome":"Login Success"') <> 0 THEN BEGIN
                RStore."Hostbook UserAccNo" := COPYSTR(Resp, STRPOS(Resp, '"user_account_no":') + 19, 16);
                UserAccNo := COPYSTR(Resp, STRPOS(Resp, '"user_account_no":') + 19, 16);
                RStore.MODIFY;
                COMMIT;
                HostBooksAuthenticate(Store, RStore."Hostbook UserAccNo", UserAccNo, '');
            END ELSE
                ERROR(Resp);
        END ELSE
            HostBooksAuthenticate(Store, RStore."Hostbook UserAccNo", Connectorid, '');
    end;

    procedure HostBooksAuthenticate(Store: Record Location; UserAccNo: Text; CtrlID: Text; ReqType: Text): Text
    var
        JSONReq: Text;
        MyFile: File;
        FileName: Text;
        "XmlPort": HttpClient;
        Resp: Text;
        Connectorid: Text;
        RStore: Record Location;
        TokentrimFrom: Integer;
        TokentrimTo: Integer;
        Ostream: OutStream;
        KeytrimFrom: Integer;
        KeytrimTo: Integer;
        gResponseMsg: Text;
        gRequestMsg: Text;
        WinHttpService: HttpClient;
        gHttpClient: HttpClient;
        gContent: HttpContent;
        gHttpResponseMsg: HttpResponseMessage;
        gHttpRequestMsg: HttpRequestMessage;
        gContentHeaders: HttpHeaders;
        URL: Text;
        token: Text;
    begin
        // Store.TESTFIELD("Hostbook UserAccNo");
        CLEAR(JSONReq);
        RStore.GET(Store.Code);
        IF JSONReq = '' THEN
            JSONReq := '{"user_account_no":"' + Store."Hostbook UserAccNo" +
                     '","connectorid":"' + Store."Hostbook ConnectorID" + '"}';

        URL := 'https://gstapihb.hostbooks.com/dec/api/Login/authenticate';
        //URL := 'https://hbapi.hostbooks.in/GSTTALLY/api/Login/authenticate';
        ClearLastError();
        Clear(gResponseMsg);
        gContent.WriteFrom(JSONReq);
        gContent.GetHeaders(gContentHeaders);
        gContentHeaders.Clear();
        gContentHeaders.Add('Content-Type', 'application/json');
        gContentHeaders.Add('Secret-Key', 'ns4LxrMhWncg1W1ajKKJhRJFQIqzmgGEzXSGsWtVImjOww1BLztUZJyYW5e/WE6iKCZwL4wvPE/g6vxlrFvZ1sLdzfknJmQe5ByYQ2+Uge8iJ4j1LcWT6ZamL+OFquOEJvSm6vWoeLKJ9c+noizErkQwJhO2OUAj5n1F+uCSOBU=');
        //   gContentHeaders.Add('Authorization', 'Bearer' + ' ' + token);
        if gHttpClient.Post(URL, gContent, gHttpResponseMsg) then begin
            gHttpResponseMsg.Content.ReadAs(gResponseMsg);
            if gHttpResponseMsg.IsSuccessStatusCode then begin
                //Message('Response %1', gResponseMsg);
                Resp := gResponseMsg;
            end;
        end;
        IF STRPOS(Resp, '"hbOutcome":"Token Success"') <> 0 THEN BEGIN
            // MESSAGE(Resp);
            TokentrimTo := STRPOS(Resp, '"hbsecretkey"') - 60;
            TokentrimFrom := STRPOS(Resp, '"hbToken":') + 11;
            hbToken := COPYSTR(Resp, TokentrimFrom, TokentrimTo);
            KeytrimTo := STRPOS(Resp, '"expires"');
            KeytrimFrom := STRPOS(Resp, '"hbsecretkey"') + 15;
            hbKey := COPYSTR(Resp, STRPOS(Resp, '"hbsecretkey"') + 15, KeytrimTo - KeytrimFrom - 2);

            IF ReqType = '' THEN
                GetAuthToken(Store, hbKey, hbToken)
            ELSE
                IF GetAuthToken(Store, hbKey, hbToken) THEN BEGIN
                    IF ReqType = 'Key' THEN
                        EXIT(hbKey)
                    ELSE
                        IF ReqType = 'Token' THEN
                            EXIT(hbToken)
                        ELSE
                            IF ReqType = 'KeyToken' THEN
                                EXIT(Resp);
                END;
        END ELSE
            ERROR(Resp);

        //END;
    end;

    procedure GetAuthToken(Store: Record Location; "Key": Text; Token: Text): Boolean
    var
        JSONReq: Text;
        MyFile: File;
        FileName: Text;
        "XmlPort": HttpClient;
        Resp: Text;
        Connectorid: Text;
        RStore: Record Location;
        hbToken: BigText;
        hbKey: BigText;
        TokentrimFrom: Integer;
        TokentrimTo: Integer;
        Ostream: OutStream;
        KeytrimFrom: Integer;
        KeytrimTo: Integer;
        Key1: Text;
        Key2: Text;
        Key3: Text;
        Key4: Text;
        Key5: Text;
        Key6: Text;
        Key7: Text;
        Token1: Text;
        Token2: Text;
        gResponseMsg: Text;
        gRequestMsg: Text;
        WinHttpService: HttpClient;
        gHttpClient: HttpClient;
        gContent: HttpContent;
        gHttpResponseMsg: HttpResponseMessage;
        gHttpRequestMsg: HttpRequestMessage;
        gContentHeaders: HttpHeaders;
        URL: Text;
        http_Client: HttpClient;
        http_Headers: HttpHeaders;
        http_content: HttpContent;
        http_Response: HttpResponseMessage;
        http_request: HttpRequestMessage;
        api_url: text;
        BodyText: Text;
        Responsetext: Text;
    begin
        RStore.GET(Store.Code);
        // http_request.Method('GET');
        // api_url := StrSubstNo('https://gstapihb.hostbooks.com/dec/api/Einvoice/GetAuthToken?gstin=' + RStore."LSCIN GST Registration No");
        api_url := 'https://gstapihb.hostbooks.com/dec/api/Einvoice/GetAuthToken?gstin=' + RStore."GST Registration No.";
        // // //Message(api_url);
        http_Client.DefaultRequestHeaders.add('Secret-Key', Key);
        http_Client.DefaultRequestHeaders.Add('Authorization', 'Bearer ' + token);
        http_Client.get(api_url, http_Response);//Pranshus
        IF http_Response.IsSuccessStatusCode then;
        http_Response.Content.ReadAs(Resp);
        // APILog('', Resp, 'Einvoicelog');
        MESSAGE('Token Auth Res :' + Resp);
        IF STRPOS(Resp, '"txnOutcome":" Success"') <> 0 THEN BEGIN
            EXIT(TRUE);
        END ELSE
            ERROR('Token Auth Res : ' + Resp);
        EXIT(FALSE);
        //END;
    end;


    procedure GenerateIRNNumber(InvoiceNo: Code[20]; TH: Record "Transfer Shipment Header")
    var
        TL: Record "Transfer Shipment Line";
        TH1: Record "Transfer Shipment Header";
        SellerStore: Record Location;
        BuyerStore: Record Location;
        CompanyInformation: Record "Company Information";
        State: Record "State";
        jsonmangment: Codeunit "JSON Management";
        SUCCESS: TEXT[1000];
        ELogEntry: Record EINV_LogEntry;
        GSTAmt: Text;
        gstAmount: Decimal;
        JSON1: Text;
        ItemDetails: Text;
        CustomerStateCode: Text;
        StoreStateCode: Text;
        MyFile: File;
        FileName: Text;
        "XmlPort": HttpClient;
        Resp: Text;
        Customer: Record Customer;
        BuyerGSTIN: Code[20];
        QRData: Text;
        DateTrimFrom: Integer;
        DateTrimto: Integer;
        CalculationType: Option "Item Wise",Total;
        BillToPINCODE: Code[10];
        ShipToPINCODE: Code[10];
        BuyerAddress: Text;
        ShipingAddress: Text;
        Store: Record Location;
        AmountReq: Option Amount,AmountIncGST;
        TrFromPIN: Code[10];
        TrTOPIN: Code[10];
        JKey: Text;
        JToken: Text;
        CessTotalAmt: Text;
        TokentrimFrom: Integer;
        TokentrimTo: Integer;
        Ostream: OutStream;
        KeytrimFrom: Integer;
        KeytrimTo: Integer;
        RespKeyToken: Text;

        gResponseMsg: Text;
        gRequestMsg: Text;
        WinHttpService: HttpClient;
        gHttpClient: HttpClient;
        gContent: HttpContent;
        gHttpResponseMsg: HttpResponseMessage;
        gHttpRequestMsg: HttpRequestMessage;
        gContentHeaders: HttpHeaders;
        URL: Text;
    begin
        CLEAR(JSON1);
        CLEAR(BuyerGSTIN);
        CLEAR(CustomerStateCode);
        CLEAR(StoreStateCode);
        CLEAR(QRData);
        CLEAR(BillToPINCODE);
        CLEAR(ShipToPINCODE);
        CLEAR(CessTotalAmt);
        CheckInvoiceStatus(TH);
        CompanyInformation.GET;
        ItemDetails := GetItemDetails(TH);
        SellerStore.GET(TH."Transfer-from Code");
        State.RESET;
        State.SETRANGE(Code, SellerStore."State Code");
        IF State.FINDFIRST THEN
            StoreStateCode := State."State Code (Einvoice)";
        BuyerStore.GET(TH."Transfer-to Code");
        State.RESET;
        State.SETRANGE(Code, BuyerStore."State Code");
        IF State.FINDFIRST THEN
            CustomerStateCode := State."State Code (Einvoice)";
        CLEAR(TrTOPIN);
        CLEAR(TrFromPIN);
        IF STRLEN(SellerStore."Post Code") > 6 THEN
            TrFromPIN := COPYSTR(SellerStore."Post Code", 4, 10)
        ELSE
            TrFromPIN := SellerStore."Post Code";

        IF STRLEN(BuyerStore."Post Code") > 6 THEN
            TrTOPIN := COPYSTR(BuyerStore."Post Code", 4, 10)
        ELSE
            TrTOPIN := BuyerStore."Post Code";
        GSTAmt := GetTotalGSTDetails(TH, '', 'IGST');
        if GSTAmt <> '0' then
            Evaluate(gstAmount, GSTAmt);
        IF GetTotalGSTDetails(TH, '', 'CESS%') <> '0' THEN
            CessTotalAmt := GetTotalGSTDetails(TH, '', 'CESS%')
        ELSE
            CessTotalAmt := GetTotalGSTDetails(TH, '', 'CESS');
        //IF TransactionType=TransactionType::Sale THEN BEGIN
        IF JSON1 = '' THEN
            JSON1 := '{"Version": "1.1"' + ',"SourceSystem": "NAV"' + ',"is_irn": "Y","is_ewb": "N"' +
          ',"TranDtls": {"TaxSch": "GST","SupTyp": "B2B","RegRev": "N"}' +
          ',"DocDtls": {"Typ": "INV","No": "' + TH."No." + '","Dt": "' + FORMAT(TH."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>') + '"}' +
          ',"SellerDtls": {"Gstin": "' + SellerStore."GST Registration No." + '","LglNm": "' + CompanyInformation.Name +
              '","Addr1": "' + TH."Transfer-from Address" + '","Addr2": "' + TH."Transfer-from Address" + '","Loc": "' + SellerStore.City + '","Pin":' + TrFromPIN + ',"Stcd": "' + StoreStateCode + '"}' +
          ',"BuyerDtls": {"Gstin": "' + BuyerStore."GST Registration No." + '","LglNm": "' + TH."Transfer-to Name" + '","Addr1": "' + TH."Transfer-to Address" +
              '","Addr2": "' + TH."Transfer-to Address" + '","Loc": "' + BuyerStore.City + '","Pin":' + TrTOPIN + ',"Stcd": "' + COPYSTR(BuyerStore."GST Registration No.", 1, 2) +
              '","Pos": "' + COPYSTR(BuyerStore."GST Registration No.", 1, 2) + '"}' +
          ',"DispDtls": {"Nm": "' + CompanyInformation.Name + '","Addr1": "' + SellerStore.Address + '","Addr2": "' + SellerStore.Address +
              '","Loc": "' + SellerStore.City + '","Pin":' + SellerStore."Post Code" + ',"Stcd": "' + StoreStateCode + '"}' +
          ',"ShipDtls": {"LglNm": "' + TH."Transfer-to Name" + '","Addr1": "' + TH."Transfer-to Address" + '","Addr2": "' + TH."Transfer-to Address" +
             '","Loc": "' + BuyerStore.City + '","Pin": ' + TrTOPIN + ',"Stcd": "' + COPYSTR(BuyerStore."GST Registration No.", 1, 2) + '"}' +
          ',"ItemList": [' + ItemDetails + ']' +
          ',"ValDtls": {"AssVal": ' + DELCHR(FORMAT(GetLineAmount(TH, AmountReq::Amount)), '=', ',') +
          ',"CgstVal":' + GetTotalGSTDetails(TH, '', 'CGST') +
          ',"SgstVal":' + GetTotalGSTDetails(TH, '', 'SGST') +
          ',"IgstVal":' + GetTotalGSTDetails(TH, '', 'IGST') +
          ',"CesVal":' + CessTotalAmt +
          ',"TotInvVal": ' + DELCHR(FORMAT(GetLineAmount(TH, AmountReq::AmountIncGST)), '=', ',') + '}' + '}';
        //  MESSAGE(JSON1)

        CLEAR(RespKeyToken);
        RespKeyToken := HostBooksAuthenticate(SellerStore, SellerStore."Hostbook UserAccNo", SellerStore."Hostbook ConnectorID", 'KeyToken');
        TokentrimTo := STRPOS(RespKeyToken, '"hbsecretkey"') - 60;
        TokentrimFrom := STRPOS(RespKeyToken, '"hbToken":') + 11;
        JToken := COPYSTR(RespKeyToken, TokentrimFrom, TokentrimTo);
        Commit();
        KeytrimTo := STRPOS(RespKeyToken, '"expires"');
        KeytrimFrom := STRPOS(RespKeyToken, '"hbsecretkey"') + 15;
        JKey := COPYSTR(RespKeyToken, STRPOS(RespKeyToken, '"hbsecretkey"') + 15, KeytrimTo - KeytrimFrom - 2);
        //    Message('reQ irn' + JSON1);
        URL := 'https://gstapihb.hostbooks.com/dec/api/Einvoice/GenerateIRN';
        ClearLastError();
        Clear(gResponseMsg);
        gContent.GetHeaders(gContentHeaders);
        gContent.WriteFrom(JSON1);
        Message(JSON1);
        gContentHeaders.Remove('Content-Type');
        gContentHeaders.Add('Content-Type', 'application/json');
        gContentHeaders.Add('Secret-Key', JKey);
        gHttpClient.DefaultRequestHeaders.add('Authorization', 'Bearer ' + JToken);
        //message(format(gContentHeaders.Add('Authorization', 'Bearer ' + JToken)));
        gHttpRequestMsg.Content := gContent;
        //  Message('Lateest %1', gContent);
        gHttpRequestMsg.Method('POST');
        if gHttpClient.Post(URL, gContent, gHttpResponseMsg) then begin
            gHttpResponseMsg.Content.ReadAs(gResponseMsg);
            //if gHttpResponseMsg.IsSuccessStatusCode then begin
            //   //Message('Response %1', gResponseMsg);
            Resp := gResponseMsg;
            //end;
            jsonmangment.InitializeFromString(Resp);
            SUCCESS := jsonmangment.GetValue('txnOutcome');
            //Message('%1', SUCCESS);
            APILog(TH, SUCCESS);//PT-FBTS


        end;
        //   MESSAGE('FinalRes '+Resp);
        IF STRPOS(Resp, '"txnOutcome":" Success."') <> 0 THEN BEGIN
            EInvoiceLog(TH, Resp);
            // MESSAGE('Response :'+Resp);
            DateTrimFrom := STRPOS(Resp, '"signedQRCode"') + 17;
            DateTrimto := STRPOS(Resp, '"status":"ACT"') - 3;
            QRData := COPYSTR(Resp, STRPOS(Resp, '"signedQRCode"') + 16, DateTrimto - DateTrimFrom + 2);
            //MESSAGE('QR DATA :' +QRData);
            GenerateQR(QRData, TH);
            MESSAGE('E-Invoice Successfully generated // Print Customer Invoice to get Einvoice Details by Scaning Printed QR Code');
        END ELSE
            //For Duplicate IRN Request
            IF STRPOS(Resp, '"infCd":"DUPIRN"') <> 0 THEN BEGIN
                TH."IRN Hash" := COPYSTR(Resp, STRPOS(Resp, '"Irn"') + 7, (STRPOS(Resp, '"respObj"') - 5) - (STRPOS(Resp, '"Irn"') + 7));
                TH.MODIFY;
                COMMIT;
            END ELSE BEGIN
                //APILog(JSON1, Resp, 'E_InvoiceLog_Req_RES');
                ERROR(Resp);
            END;
        // APILog(JSON1, Resp, 'E_InvoiceLog_Req_RES');
        /////////////////////////////////////////////////////

        ///////////////////////////////////////

    end;

    procedure Cancel_EinvoiceTranfer(TransactionType: Option Sale,"Sale Retrun"; InvoiceNo: Code[20]; SH: Record "Transfer Shipment Header")
    var
        JSON2: Text;
        ///////////////////////
        SL: Record "Transfer Shipment Line";
        SH1: Record "Transfer Shipment Header";
        Store: Record Location;
        CompanyInformation: Record "Company Information";
        State: Record "State";
        JSON1: Text;
        ItemDetails: Text;
        CustomerStateCode: Text;
        StoreStateCode: Text;
        MyFile: File;
        FileName: Text;
        "XmlPort": HttpClient;
        Resp: Text;
        Customer: Record Customer;
        BuyerGSTIN: Code[20];
        QRData: Text;
        DateTrimFrom: Integer;
        RemAmt: Decimal;
        DateTrimto: Integer;
        CalculationType: Option "Item Wise",Total;
        BillToPINCODE: Code[10];
        ShipToPINCODE: Code[10];
        BuyerAddress: Text;
        ShipingAddress: Text;
        JKey: Text;
        JToken: Text;
        City: Text;
        TokentrimFrom: Integer;
        TokentrimTo: Integer;
        Ostream: OutStream;
        KeytrimFrom: Integer;
        KeytrimTo: Integer;
        RespKeyToken: Text;

        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        Response: Text;
        ResponseMessage: HttpResponseMessage;
        RequestHeaders: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        JsonObject: JsonObject;
        JSONManagement: Codeunit "JSON Management";
        ArrayJSONManagement: Codeunit "JSON Management";
        ObjectJSONManagement: Codeunit "JSON Management";
        Index: Integer;
        Value: text;
        ItemJsonobject: text;
        JsonObject1: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        JsonToken1: JsonToken;
        TransferLine: Record "Transfer Line";
        ItemNo: Code[20];
        VariantCode: Code[20];
        RetailSetup: Record "LSC Retail Setup";
        gResponseMsg: Text;
        gRequestMsg: Text;
        WinHttpService: HttpClient;
        SalesLine: Record "Sales Invoice Line";
        gHttpClient: HttpClient;
        gContent: HttpContent;
        gHttpResponseMsg: HttpResponseMessage;
        gHttpRequestMsg: HttpRequestMessage;
        gContentHeaders: HttpHeaders;
        GSTAmount: Decimal;
        URL: Text;
        CustomerRec: Record Customer;
        States_lRec: Record State;
        Crt: Text;
        State_lRec2: Record state;
        State_lRec1: Record State;
        GstgroupCode: Code[20];
        Location_lrec: Record "LSC Store";
        State_lrec: Record State;
        ShipPinCode: Code[20];
        BilltoCity: COde[20];
        StateCode_L: COde[20];
        Tmode: Integer;
        TransId: Text;
        TransName: Text;
        TransDocDt: Text;
        TransDocNo: Text;
        vehtype: Text;
        ewano1: text;
        Ewano: Text[50];
        ACKNo: Code[20];
        Response22: Text;
    begin
        IF JSON2 = '' THEN
            JSON2 := '{"Irn":"' + SH."IRN Hash" + '"' +
               ',"CnlRsn":"' + '2' + '"' +
                ',"CnlRem":"' + Format('Cancelled the order') + '"}';
        Message(JSON2);
        ////////////////////////////
        Clear(Store);
        IF Store.Get(Sh."Transfer-to Code") then;
        CLEAR(RespKeyToken);
        RespKeyToken := HostBooksAuthenticate(Store, Store."Hostbook UserAccNo", Store."Hostbook ConnectorID", 'KeyToken');
        TokentrimTo := STRPOS(RespKeyToken, '"hbsecretkey"') - 60;
        TokentrimFrom := STRPOS(RespKeyToken, '"hbToken":') + 11;
        JToken := COPYSTR(RespKeyToken, TokentrimFrom, TokentrimTo);
        Commit();
        KeytrimTo := STRPOS(RespKeyToken, '"expires"');
        KeytrimFrom := STRPOS(RespKeyToken, '"hbsecretkey"') + 15;
        JKey := COPYSTR(RespKeyToken, STRPOS(RespKeyToken, '"hbsecretkey"') + 15, KeytrimTo - KeytrimFrom - 2);
        // URL := 'https://gstapihb.hostbooks.com/dec/api/Einvoice/GenerateEwayBill';
        URL := 'http://gstapihb.hostbooks.com/dec/api/Einvoice/CancelIRN';
        ClearLastError();
        Clear(gResponseMsg);
        gContent.GetHeaders(gContentHeaders);
        gContent.WriteFrom(JSON2);
        gContentHeaders.Remove('Content-Type');
        gContentHeaders.Add('Content-Type', 'application/json');
        gContentHeaders.Add('Secret-Key', JKey);
        gHttpClient.DefaultRequestHeaders.add('Authorization', 'Bearer ' + JToken);
        gHttpRequestMsg.Content := gContent;
        gHttpRequestMsg.Method('POST');
        if gHttpClient.Post(URL, gContent, gHttpResponseMsg) then begin
            gHttpResponseMsg.Content.ReadAs(gResponseMsg);
            Resp := gResponseMsg;
            Message('%1', Resp);
        end;
        IF STRPOS(Resp, '"txnOutcome":" Success."') <> 0 THEN BEGIN
            Response22 := Resp;
            // SH."CancelIrn" := COPYSTR(Response, STRPOS(Response, '"irn"') + 7, 64);
            // SH."E-Inv. Cancelled Date" := CurrentDateTime;
            SH.Modify();
            MESSAGE('E-Invoice Successfully Cencel');
        End;
    end;

    procedure Cancel_EwaybillTranSfer(TransactionType: Option Sale,"Sale Retrun"; InvoiceNo: Code[20]; SH: Record "Transfer Shipment Header")
    var
        JSON3: Text;
        ///////////////////////
        SL: Record "Transfer Shipment Line";
        SH1: Record "Transfer Shipment Header";
        Store: Record Location;
        CompanyInformation: Record "Company Information";
        State: Record "State";
        JSON1: Text;
        ItemDetails: Text;
        CustomerStateCode: Text;
        StoreStateCode: Text;
        MyFile: File;
        FileName: Text;
        "XmlPort": HttpClient;
        Resp: Text;
        Customer: Record Customer;
        BuyerGSTIN: Code[20];
        QRData: Text;
        DateTrimFrom: Integer;
        RemAmt: Decimal;
        DateTrimto: Integer;
        CalculationType: Option "Item Wise",Total;
        BillToPINCODE: Code[10];
        ShipToPINCODE: Code[10];
        BuyerAddress: Text;
        ShipingAddress: Text;
        JKey: Text;
        JToken: Text;
        City: Text;
        TokentrimFrom: Integer;
        TokentrimTo: Integer;
        Ostream: OutStream;
        KeytrimFrom: Integer;
        KeytrimTo: Integer;
        RespKeyToken: Text;

        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        Response: Text;
        ResponseMessage: HttpResponseMessage;
        RequestHeaders: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        JsonObject: JsonObject;
        JSONManagement: Codeunit "JSON Management";
        ArrayJSONManagement: Codeunit "JSON Management";
        ObjectJSONManagement: Codeunit "JSON Management";
        Index: Integer;
        Value: text;
        ItemJsonobject: text;
        JsonObject1: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        JsonToken1: JsonToken;
        TransferLine: Record "Transfer Line";
        ItemNo: Code[20];
        VariantCode: Code[20];
        RetailSetup: Record "LSC Retail Setup";
        gResponseMsg: Text;
        gRequestMsg: Text;
        WinHttpService: HttpClient;
        SalesLine: Record "Sales Invoice Line";
        gHttpClient: HttpClient;
        gContent: HttpContent;
        gHttpResponseMsg: HttpResponseMessage;
        gHttpRequestMsg: HttpRequestMessage;
        gContentHeaders: HttpHeaders;
        GSTAmount: Decimal;
        URL: Text;
        CustomerRec: Record Customer;
        States_lRec: Record State;
        Crt: Text;
        State_lRec2: Record state;
        State_lRec1: Record State;
        GstgroupCode: Code[20];
        Location_lrec: Record "LSC Store";
        State_lrec: Record State;
        ShipPinCode: Code[20];
        BilltoCity: COde[20];
        StateCode_L: COde[20];
        Tmode: Integer;
        TransId: Text;
        TransName: Text;
        TransDocDt: Text;
        TransDocNo: Text;
        vehtype: Text;
        ewano1: text;
        Ewano: Text[50];
        ACKNo: Code[20];
        Response22: Text;

    begin
        IF JSON3 = '' THEN
            JSON3 := '{"ewbNo":"' + SH."E-Way Bill No." + '"' +
               ',"cancelRsnCode":"' + '2' + '"' +
                ',"cancelRmrk":"' + Format('Cancelled the order') + '"}';
        Message(JSON3);
        ////////////////////////////
        Clear(Store);
        IF Store.Get(Sh."Transfer-to Code") then;
        CLEAR(RespKeyToken);
        RespKeyToken := HostBooksAuthenticate(Store, Store."Hostbook UserAccNo", Store."Hostbook ConnectorID", 'KeyToken');
        TokentrimTo := STRPOS(RespKeyToken, '"hbsecretkey"') - 60;
        TokentrimFrom := STRPOS(RespKeyToken, '"hbToken":') + 11;
        JToken := COPYSTR(RespKeyToken, TokentrimFrom, TokentrimTo);
        Commit();
        KeytrimTo := STRPOS(RespKeyToken, '"expires"');
        KeytrimFrom := STRPOS(RespKeyToken, '"hbsecretkey"') + 15;
        JKey := COPYSTR(RespKeyToken, STRPOS(RespKeyToken, '"hbsecretkey"') + 15, KeytrimTo - KeytrimFrom - 2);
        // URL := 'https://gstapihb.hostbooks.com/dec/api/Einvoice/GenerateEwayBill';
        URL := 'http://gstapihb.hostbooks.com/dec/api/Einvoice/CancelEwayBill';
        ClearLastError();
        Clear(gResponseMsg);
        gContent.GetHeaders(gContentHeaders);
        gContent.WriteFrom(JSON3);
        gContentHeaders.Remove('Content-Type');
        gContentHeaders.Add('Content-Type', 'application/json');
        gContentHeaders.Add('Secret-Key', JKey);
        gHttpClient.DefaultRequestHeaders.add('Authorization', 'Bearer ' + JToken);
        gHttpRequestMsg.Content := gContent;
        gHttpRequestMsg.Method('POST');
        if gHttpClient.Post(URL, gContent, gHttpResponseMsg) then begin
            gHttpResponseMsg.Content.ReadAs(gResponseMsg);
            Resp := gResponseMsg;
            Message('%1', Resp);
        end;
        IF STRPOS(Resp, '"txnOutcome":" Success."') <> 0 THEN BEGIN
            Response22 := Resp;
            ewano := COPYSTR(Response22, STRPOS(Response22, '"ewbNo"') + 8, 12);
            MESSAGE('E-waybill Successfully Cencel');
        End;
        //SH.Validate("CancelE-Way Bill No.", ewano);
        SH.Modify();
    end;

    procedure GetItemDetails(TransferHeader: Record "Transfer Shipment Header"): Text
    var
        TransferLine: Record "Transfer Shipment Line";
        ItemJson: Text;
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        UnitofMeasure: Record "Unit of Measure";
        GSTRate: Text;
        gstGROUP: Record "GST Group";
        HSN: Code[10];
        IGST_lDecPer: Decimal;
        CalculationType: Option "Item Wise",Total;
        IsService: Text;
        RItem: Record Item;
        GSTRatePer: Text;
        CessRate: Text;
        CessAmt: Text;
        Cessamount: Decimal;
        SLNo: Integer;
        HSNASC: Record "HSN/SAC";

    begin
        CLEAR(ItemJson);
        CLEAR(GSTRate);
        CLEAR(HSN);
        CLEAR(CessRate);
        CLEAR(CessAmt);
        Clear(Cessamount);
        Clear(IGST_lDecPer);
        TransferLine.RESET;
        TransferLine.SETRANGE("Document No.", TransferHeader."No.");
        //  TransferLine.SETRANGE("Transfer-from Code", TransferHeader."Transfer-from Code");
        TransferLine.SetFilter("HSN/SAC Code", '<>%1', '00000000');
        TransferLine.SetFilter(Quantity, '<>%1', 0);
        IF TransferLine.FINDSET THEN
            REPEAT
                IF UnitofMeasure.GET(TransferLine."Unit of Measure Code") THEN;
                // IsService := 'N';
                // IF RItem."HSN/SAC Code" = '996331' THEN //996331
                //     IsService := 'Y';

                HSNASC.Reset();
                HSNASC.SetRange(code, TransferLine."HSN/SAC Code");
                if HSNASC.FindFirst() then begin
                    if HSNASC.Type = HSNASC.Type::SAC then
                        IsService := 'Y';
                    if HSNASC.Type = HSNASC.Type::HSN then
                        IsService := 'N';
                end;

                RItem.GET(TransferLine."Item No.");
                HSN := RItem."HSN/SAC Code"; //Temp to clear pending invoices
                                             //ELSE //Temp Comment
                                             //HSN:=TransferLine."HSN/SAC Code"; //Temp Comment
                if gstGROUP.Get(TransferLine."GST Group Code") then
                    GSTRate := Format(gstGROUP."GST Rate");

                GSTRatePer := GSTDetails(TransferLine, TransferLine."Item No.", 'IGST', TransferLine."Line No.", TransferHeader);
                CessAmt := GSTDetails(TransferLine, TransferLine."Item No.", 'CESS', TransferLine."Line No.", TransferHeader);
                Clear(IGST_lDecPer);
                Clear(Cessamount);
                IF GSTRatePer <> '0' then
                    Evaluate(IGST_lDecPer, GSTRatePer);
                if CessAmt <> '0' then
                    Evaluate(Cessamount, CessAmt);
                IF TransferLine."GST Group Code" = 'G28+12CESS' THEN BEGIN
                    // GSTRate := '28';
                    CessRate := '12';
                    IF GSTDetails(TransferLine, TransferLine."Item No.", 'CESS%', TransferLine."Line No.", TransferHeader) <> '0' THEN
                        CessRate := GSTDetails(TransferLine, TransferLine."Item No.", 'CESS%', TransferLine."Line No.", TransferHeader)


                END ELSE BEGIN
                    //Ashish  GSTRate := FORMAT(ROUND(TransferLine."GST %", 1));
                    CessRate := '0';
                    CessAmt := '0';
                END;

                IF STRLEN(FORMAT(TransferLine."Line No.")) > 6 THEN
                    SLNo := TransferLine."Line No." / 1000
                ELSE
                    SLNo := TransferLine."Line No.";
                IF ItemJson = '' THEN
                    ItemJson := '{"SlNo":"' + FORMAT(SLNo) + '","HsnCd":"' + TransferLine."HSN/SAC Code" + '","IsServc":"' + IsService + '"' +
                  ',"Qty":' + DELCHR(FORMAT(TransferLine.Quantity), '=', ',') + ',"Unit": "' + FORMAT(UnitofMeasure."E UOM") +
                  '","UnitPrice":' + DELCHR(FORMAT(ROUND(TransferLine."Unit Price", 0.01)), '=', ',') +
                  //Ashish  ',"TotAmt":' + DELCHR(FORMAT(TransferLine."GST Base Amount"), '=', ',') + ',"AssAmt":' + DELCHR(FORMAT(TransferLine."GST Base Amount"), '=', ',') +
                  ',"TotAmt":' + DELCHR(FORMAT(Round(TransferLine.Amount, 0.01)), '=', ',') + ',"AssAmt":' + DELCHR(FORMAT(Round(TransferLine.Amount, 0.01)), '=', ',') +
                 ',"GstRt":' + GSTRate +
                  ',"IgstAmt":' + GSTDetails(TransferLine, TransferLine."Item No.", 'IGST', TransferLine."Line No.", TransferHeader) +
                  ',"CgstAmt":' + GSTDetails(TransferLine, TransferLine."Item No.", 'CGST', TransferLine."Line No.", TransferHeader) +
                  ',"SgstAmt":' + GSTDetails(TransferLine, TransferLine."Item No.", 'SGST', TransferLine."Line No.", TransferHeader) +
                  ',"CesRt":' + CessRate +
                  ',"CesAmt":' + GSTDetails(TransferLine, TransferLine."Item No.", 'CESS', TransferLine."Line No.", TransferHeader) +
                  // Ashish  //',"TotItemVal":' + DELCHR(FORMAT(ROUND(TransferLine."GST Base Amount", 0.01)), '=', ',') + '}'//+ TransferLine."Total GST Amount"Ashish 
                  ',"TotItemVal":' + DELCHR(FORMAT(ROUND(TransferLine.Amount + IGST_lDecPer + Cessamount, 0.01)), '=', ',') + '}'
                ELSE
                    ItemJson += ',{"SlNo":"' + FORMAT(SLNo) + '","HsnCd":"' + TransferLine."HSN/SAC Code" + '","IsServc":"' + IsService + '"' +
                  ',"Qty":' + DELCHR(FORMAT(TransferLine.Quantity), '=', ',') + ',"Unit": "' + FORMAT(UnitofMeasure."E UOM") +
                  '","UnitPrice":' + DELCHR(FORMAT(ROUND(TransferLine."Unit Price", 0.01)), '=', ',') +
                  //Ashish  ',"TotAmt":' + DELCHR(FORMAT(TransferLine."GST Base Amount"), '=', ',') + ',"AssAmt":' + DELCHR(FORMAT(TransferLine."GST Base Amount"), '=', ',') +
                  ',"TotAmt":' + DELCHR(FORMAT(Round(TransferLine.Amount, 0.01)), '=', ',') + ',"AssAmt":' + DELCHR(FORMAT(Round(TransferLine.Amount, 0.01)), '=', ', ') +
                  ',"GstRt":' + GSTRate +
                  ',"IgstAmt":' + GSTDetails(TransferLine, TransferLine."Item No.", 'IGST', TransferLine."Line No.", TransferHeader) +
                  ',"CgstAmt":' + GSTDetails(TransferLine, TransferLine."Item No.", 'CGST', TransferLine."Line No.", TransferHeader) +
                  ',"SgstAmt":' + GSTDetails(TransferLine, TransferLine."Item No.", 'SGST', TransferLine."Line No.", TransferHeader) +
                  ',"CesRt":' + CessRate +
                  ',"CesAmt":' + GSTDetails(TransferLine, TransferLine."Item No.", 'CESS', TransferLine."Line No.", TransferHeader) +
                  //Ashishs ',"TotItemVal":' + DELCHR(FORMAT(ROUND(TransferLine."GST Base Amount", 0.01)), '=', ',') + '}'// + TransferLine."Total GST Amount" Ashish
                  ',"TotItemVal":' + DELCHR(FORMAT(ROUND(TransferLine.Amount + IGST_lDecPer + Cessamount, 0.01)), '=', ',') + '}'// + TransferLine."Total GST Amount" Ashish

            //  end;
            UNTIL TransferLine.NEXT = 0;

        EXIT(ItemJson);
    end;

    local procedure GSTDetails(TransferLine: Record "Transfer Shipment Line"; ItemCode: Code[20]; GSTComponent: Code[10]; RecLineNo: Integer; TransferHeader: Record "Transfer Shipment Header") ReturnValue: Text
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
    begin
        CLEAR(ReturnValue);
        DetailedGSTLedgerEntry.RESET;
        DetailedGSTLedgerEntry.SETCURRENTKEY("Entry No.");
        //DetailedGSTLedgerEntry.SETRANGE("Document Type",SLine."Document Type");
        DetailedGSTLedgerEntry.SETRANGE("Document No.", TransferHeader."No.");
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", GSTComponent);
        DetailedGSTLedgerEntry.SETRANGE("No.", TransferLine."Item No.");
        DetailedGSTLedgerEntry.SETRANGE("Document Line No.", RecLineNo);
        IF DetailedGSTLedgerEntry.FINDFIRST THEN
            ReturnValue := DELCHR(FORMAT(DetailedGSTLedgerEntry."GST Amount" * -1), '=', ',')
        ELSE
            ReturnValue := '0';

        EXIT(ReturnValue);
    end;

    local procedure GetTotalGSTDetails(THdr: Record "Transfer Shipment Header"; ItemCode: Code[20]; GSTComponent: Code[10]) ReturnValue: Text
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        TotalGST: Decimal;
    begin
        CLEAR(ReturnValue);
        CLEAR(TotalGST);
        DetailedGSTLedgerEntry.RESET;
        DetailedGSTLedgerEntry.SETCURRENTKEY("Transaction Type", "Document Type", "Document No.", "Document Line No.");
        //DetailedGSTEntryBuffer.SETRANGE("Document Type",SHdr."Document Type");
        DetailedGSTLedgerEntry.SETRANGE("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Sales);
        DetailedGSTLedgerEntry.SETRANGE("Document Type", DetailedGSTLedgerEntry."Document Type"::Invoice);
        DetailedGSTLedgerEntry.SETRANGE("Document No.", THdr."No.");
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", GSTComponent);
        IF DetailedGSTLedgerEntry.FINDSET THEN BEGIN
            REPEAT
                TotalGST += DetailedGSTLedgerEntry."GST Amount" * -1;
            UNTIL DetailedGSTLedgerEntry.NEXT = 0;

            ReturnValue := DELCHR(FORMAT(TotalGST), '=', ',');
            EXIT(ReturnValue);
        END ELSE
            ReturnValue := '0';
    end;

    local procedure EinvoiceCancelReq(TransactionType: Option Sale,"Sale Retrun"; CustomerNo: Code[20]; InvoiceNo: Code[20]; SH: Record "Sales Header"; SGSTIN: Code[20])
    var
        ReturnJSON: Text;
        MyFile: File;
        FileName: Text;
        "XmlPort": HttpClient;
        Resp: Text;
    begin


    end;

    local procedure GenerateQR(QRData: Text; TransferHeader: Record "Transfer Shipment Header")
    var
        QRPath: Text[250];
        FileMgt: Codeunit "File Management";
        BOUTIL: Codeunit "LSC BO Utils";
        // TempBlob: Record "TempBlob";
        TempBlob: Codeunit "Temp Blob";
        EinvoiceETransLog: Record "E-Invoice Log Entry";
        ClientFile: Text;
        ServerFile: Text;
        RecordRef: RecordRef;
        OutStream: OutStream;
        QRGenerator: Codeunit "QR Generator";
        FieldRef: FieldRef;

    begin
        Clear(TempBlob);
        Clear(RecordRef);
        Clear(FieldRef);
        EinvoiceETransLog.RESET;
        EinvoiceETransLog.SETRANGE("Invoice No.", TransferHeader."No.");
        IF EinvoiceETransLog.FINDFIRST THEN BEGIN
            RecordRef.Get(EinvoiceETransLog.RecordId);
            QRGenerator.GenerateQRCodeImage(QRData, TempBlob);
            FieldRef := RecordRef.Field(EinvoiceETransLog.FieldNo("Einvoice QR Code"));
            TempBlob.ToRecordRef(RecordRef, EinvoiceETransLog.FieldNo("Einvoice QR Code"));
            FieldRef := RecordRef.Field(EinvoiceETransLog.FieldNo("Einvoice QR Code"));
            EinvoiceETransLog."Einvoice QR Code" := FieldRef.Value;
            EinvoiceETransLog.MODIFY;
            //  Message('%1', EinvoiceETransLog."Invoice No.");
        end;
    end;

    local procedure EInvoiceLog(TransferHeader: Record "Transfer Shipment Header"; Response: Text)
    var
        EinvoiceETransLog: Record "E-Invoice Log Entry";
        jsonmangment: Codeunit "JSON Management";
        respobj: Text;
        irp_no: Code[10];
        AckNo: Code[20];
    begin
        EinvoiceETransLog.RESET;
        EinvoiceETransLog.SETRANGE("Invoice No.", TransferHeader."No.");
        EinvoiceETransLog.SETRANGE("Request Validated", TRUE);
        IF NOT EinvoiceETransLog.FINDFIRST THEN BEGIN
            EinvoiceETransLog.INIT;
            EinvoiceETransLog."Request Type" := EinvoiceETransLog."Request Type"::"E-Invoice";
            EinvoiceETransLog."Order No." := TransferHeader."Transfer Order No.";
            EinvoiceETransLog."Invoice No." := TransferHeader."No.";
            EinvoiceETransLog."IRN No." := COPYSTR(Response, STRPOS(Response, '"irn"') + 7, 64);
            EinvoiceETransLog.AckNo := COPYSTR(Response, STRPOS(Response, '"AckNo"') + 9, 15);
            EinvoiceETransLog."Ack DateTime" := FORMAT(CURRENTDATETIME);
            EinvoiceETransLog."Einvoice Res Message" := COPYSTR(Response, 1, 250);
            EinvoiceETransLog."Request Validated" := TRUE;
            EinvoiceETransLog.INSERT;
            COMMIT;
        END;
        TransferHeader."IRN Hash" := COPYSTR(Response, STRPOS(Response, '"irn"') + 7, 64);
        TransferHeader."Acknowledgement No." := COPYSTR(Response, STRPOS(Response, '"AckNo"') + 9, 15);
        TransferHeader."Acknowledgement Date" := (CURRENTDATETIME);

        // jsonmangment.InitializeFromString(Response); New PT-FBTS
        // respobj := jsonmangment.GetValue('respObj');
        // jsonmangment.InitializeFromString(respobj);
        // irp_no := jsonmangment.GetValue('irp');
        //jsonmangment.InitializeFromString(respobj);
        //AckNo := jsonmangment.GetValue('AckNo');
        // TransferHeader.IRNvALUE := irp_no; New PT-FBTS
        //TransferHeader."Acknowledgement No." := AckNo;
        // jsonmangment.InitializeFromString(Response);
        // irp_no := jsonmangment.GetValue('irp');
        // TransferHeader.IRNvALUE := irp_no;
        //TransferHeader.tra := TRUE;
        TransferHeader.MODIFY;
    end;

    local procedure GetResponse()
    begin
    end;

    local procedure CheckInvoiceStatus(TransferHeader: Record "Transfer Shipment Header")
    var
        EinvoiceETransLog: Record "E-Invoice Log Entry";
        Customer: Record Customer;
    begin
        //Customer.GET(SalesHeader."Sell-to Customer No.");
        //IF (Customer."GST Customer Type"<>Customer."GST Customer Type"::Registered) OR ((Customer."No."='CASH') AND (SalesHeader."GSTIN No."='')) THEN
        //ERROR('This customer not aplicable for Einvoice');

        EinvoiceETransLog.RESET;
        EinvoiceETransLog.SETRANGE("Order No.", TransferHeader."No.");
        EinvoiceETransLog.SETRANGE("Invoice No.", TransferHeader."No.");
        EinvoiceETransLog.SETRANGE("Request Validated", TRUE);
        IF EinvoiceETransLog.FINDFIRST THEN
            ERROR('Einvoice already generated for this invoice,Please Take Invoice Print \\ IRN : %1 \\Invoice No. : %2', EinvoiceETransLog."IRN No.", TransferHeader."No.")
        ELSE
            EXIT;
    end;

    procedure APILog(TH: Record "Transfer Shipment Header"; ResponseJSON: Text)
    var
        FileManagement: Codeunit "File Management";
        FileName: Text;
        EntryNo: Integer;
        MyFile: File;
        RetailSetup: Record "LSC Retail Setup";
        EinvLogEntry: Record EINV_LogEntry;
        EinvLogEntry1: Record EINV_LogEntry;
    begin
        EinvLogEntry1.RESET;
        IF EinvLogEntry1.FINDLAST THEN
            EntryNo := EinvLogEntry1."Entry No." + 1
        ELSE
            EntryNo := 1;
        EinvLogEntry.init;
        EinvLogEntry."Entry No." := EntryNo;
        EinvLogEntry."Document No." := TH."No.";
        EinvLogEntry."Document Type" := EinvLogEntry."Document Type"::Transfer;
        EinvLogEntry."Creation DateTime" := CurrentDateTime;
        //EinvLogEntry.Message := ResponseJSON;
        EinvLogEntry.Message := COPYSTR(ResponseJSON, 1, 250);
        IF STRLEN(ResponseJSON) > 250 THEN
            EinvLogEntry.Message1 := COPYSTR(ResponseJSON, 251, 250)
        ELSE
            EinvLogEntry.Message1 := '';
        IF STRLEN(ResponseJSON) > 500 THEN
            EinvLogEntry.Message2 := COPYSTR(ResponseJSON, 501, 250)
        ELSE
            EinvLogEntry.Message2 := '';
        IF STRLEN(ResponseJSON) > 750 THEN
            EinvLogEntry.Message3 := COPYSTR(ResponseJSON, 751, 250)
        ELSE
            EinvLogEntry.Message3 := '';
        EinvLogEntry.Insert();
        Commit();
        // EinvLogEntry.Modify();
        //  Message('et%1', EinvLogEntry.Message);
        // IF NOT FileManagement.IsServerDirectoryEmpty('C:\APILogs\Logs') THEN
        //     FileManagement.IsServerDirectoryEmpty('C:\APILogs\Logs\');
        // FileName := 'C:\APILogs\Logs\' + LogFileName + FORMAT(TODAY, 0, 6) + '.txt';
        // IF EXISTS(FileName) THEN BEGIN
        //     MyFile.CREATE(FileName);
        //     MyFile.CLOSE;
        // END;
        // MyFile.TEXTMODE(TRUE);
        // MyFile.WRITEMODE(TRUE);
        // MyFile.OPEN(FileName);
        // REPEAT
        //     MyFile.READ(FileName);
        // UNTIL MyFile.POS = MyFile.LEN;
        // MyFile.WRITE('Request');
        // MyFile.WRITE(CURRENTDATETIME);
        // MyFile.WRITE(RequestJSON);
        // MyFile.WRITE('Response');
        // MyFile.WRITE(ResponseJSON);
        // MyFile.CLOSE;
        // COMMIT;
    end;

    procedure APILogSalesInv(SIH: Record "Sales Invoice Header"; ResponseJSON: Text)
    var
        FileManagement: Codeunit "File Management";
        FileName: Text;
        EntryNo: Integer;
        MyFile: File;
        RetailSetup: Record "LSC Retail Setup";
        EinvLogEntry: Record EINV_LogEntry;
        EinvLogEntry1: Record EINV_LogEntry;
    begin
        EinvLogEntry1.RESET;
        IF EinvLogEntry1.FINDLAST THEN
            EntryNo := EinvLogEntry1."Entry No." + 1
        ELSE
            EntryNo := 1;
        EinvLogEntry.init;
        EinvLogEntry."Entry No." := EntryNo;
        EinvLogEntry."Document No." := SIH."No.";
        EinvLogEntry."Document Type" := EinvLogEntry."Document Type"::Invoice;
        EinvLogEntry."Creation DateTime" := CurrentDateTime;
        //EinvLogEntry.Message := ResponseJSON;
        EinvLogEntry.Message := COPYSTR(ResponseJSON, 1, 250);
        IF STRLEN(ResponseJSON) > 250 THEN
            EinvLogEntry.Message1 := COPYSTR(ResponseJSON, 251, 250)
        ELSE
            EinvLogEntry.Message1 := '';
        IF STRLEN(ResponseJSON) > 500 THEN
            EinvLogEntry.Message2 := COPYSTR(ResponseJSON, 501, 250)
        ELSE
            EinvLogEntry.Message2 := '';
        IF STRLEN(ResponseJSON) > 750 THEN
            EinvLogEntry.Message3 := COPYSTR(ResponseJSON, 751, 250)
        ELSE
            EinvLogEntry.Message3 := '';
        EinvLogEntry.Insert();
        Commit();
    end;


    local procedure GetLineAmount(TransferHeader: Record "Transfer Shipment Header"; AmountReq: Option Amount,AmountIncGST): Decimal
    var
        TransferLine: Record "Transfer Shipment Line";
        TotalAmt: Decimal;
        TotalGSTAmt: Decimal;
        CessTotalAmount: Text;
        CessAmt: Decimal;
        GSTtotAMT: Decimal;
        GstAmt: Text;
        GSTAmount: Decimal;
        TotalAmounttoCustomer: Decimal;
    begin
        Clear(GSTtotAMT);
        CLEAR(TotalAmt);
        CLEAR(TotalAmounttoCustomer);
        Clear(GSTAmount);
        Clear(CessAmt);

        GSTAmount := 0;
        TransferLine.RESET;
        TransferLine.SETRANGE("Document No.", TransferHeader."No.");
        TransferLine.SETRANGE("Transfer-from Code", TransferHeader."Transfer-from Code");
        IF TransferLine.FINDSET THEN
            REPEAT

                GstAmt := GetTotalGSTDetails(TransferHeader, '', 'IGST');
                CessTotalAmount := GetTotalGSTDetails(TransferHeader, '', 'CESS');
                // GstAmt := GSTDetails(TransferLine, TransferLine."Item No.", 'IGST', TransferLine."Line No.", TransferHeader);
                if GstAmt <> '0' then
                    Evaluate(GSTAmount, GstAmt);
                if CessTotalAmount <> '0' then
                    Evaluate(CessAmt, CessTotalAmount);
                //GSTtotAMT += GSTAmount;
                TotalAmt += Round(TransferLine.Amount, 0.01);//Ashish TransferLine."GST Base Amount";
                TotalAmounttoCustomer := Round(TotalAmt + GSTAmount + CessAmt, 0.01)//Ashish TransferLine."GST Base Amount" + TransferLine."Total GST Amount";
            UNTIL TransferLine.NEXT = 0;

        IF AmountReq = AmountReq::Amount THEN
            EXIT(TotalAmt)
        ELSE
            IF AmountReq = AmountReq::AmountIncGST THEN
                EXIT(TotalAmounttoCustomer);
    end;

    procedure SaleInvoice_GenerateInvoiceTransfer(TransactionType: Option Sale,"Sale Retrun"; InvoiceNo: Code[20]; SH: Record "Transfer Shipment Header")
    var
        SL: Record "Transfer Shipment Line";
        SH1: Record "Transfer Shipment Header";
        Store: Record Location;
        CompanyInformation: Record "Company Information";
        State: Record "State";
        JSON1: Text;
        ItemDetails: Text;
        CustomerStateCode: Text;
        StoreStateCode: Text;
        MyFile: File;
        FileName: Text;
        "XmlPort": HttpClient;
        Resp: Text;
        Customer: Record Customer;
        BuyerGSTIN: Code[20];
        QRData: Text;
        DateTrimFrom: Integer;
        RemAmt: Decimal;
        DateTrimto: Integer;
        CalculationType: Option "Item Wise",Total;
        BillToPINCODE: Code[10];
        ShipToPINCODE: Code[10];
        BuyerAddress: Text;
        ShipingAddress: Text;
        JKey: Text;
        JToken: Text;
        City: Text;
        TokentrimFrom: Integer;
        TokentrimTo: Integer;
        Ostream: OutStream;
        KeytrimFrom: Integer;
        KeytrimTo: Integer;
        RespKeyToken: Text;

        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        Response: Text;
        ResponseMessage: HttpResponseMessage;
        RequestHeaders: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        JsonObject: JsonObject;
        JSONManagement: Codeunit "JSON Management";
        ArrayJSONManagement: Codeunit "JSON Management";
        ObjectJSONManagement: Codeunit "JSON Management";
        Index: Integer;
        Value: text;
        ItemJsonobject: text;
        JsonObject1: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        JsonToken1: JsonToken;
        TransferLine: Record "Transfer Line";
        ItemNo: Code[20];
        VariantCode: Code[20];
        RetailSetup: Record "LSC Retail Setup";
        gResponseMsg: Text;
        gRequestMsg: Text;
        WinHttpService: HttpClient;
        SalesLine: Record "Sales Invoice Line";
        gHttpClient: HttpClient;
        gContent: HttpContent;
        gHttpResponseMsg: HttpResponseMessage;
        gHttpRequestMsg: HttpRequestMessage;
        gContentHeaders: HttpHeaders;
        GSTAmount: Decimal;
        URL: Text;
        CustomerRec: Record Customer;
        States_lRec: Record State;
        Crt: Text;
        State_lRec2: Record state;
        State_lRec1: Record State;
        GstgroupCode: Code[20];
        Location_lrec: Record Location;
        Location_lrec1: Record Location;
        State_lrec: Record State;
        ShipPinCode: Code[20];
        BilltoCity: COde[20];
        StateCode_L: COde[20];
        StateCode: COde[20];

        Tmode: Integer;
        TransId: Text;
        TransName: Text;
        TransDocDt: Text;
        TransDocNo: Text;
        vehtype: Text;
        ewano1: text;
        Ewano: Text[50];
        ACKNo: Code[20];
        Response22: Text;
    begin

        //PRANSHU
        if sh."Vehicle Type" = sh."Vehicle Type"::Regular then
            vehtype := 'R'
        else
            if sh."Vehicle Type" = sh."Vehicle Type"::ODC then
                vehtype := 'O'
            else
                vehtype := '';
        Clear(Location_lrec);
        IF Location_lrec.get(Sh."Transfer-TO Code") then
            Clear(State_lrec);
        // Clear(StateCode_L);
        IF State_lrec.Get(Location_lrec."State Code") then
            StateCode_L := State_lrec."State Code (GST Reg. No.)";
        IF Location_lrec1.get(Sh."Transfer-from Code") then
            IF State_lrec2.Get(Location_lrec1."State Code") then
                StateCode := State_lrec2."State Code (GST Reg. No.)"
            else
                Error('State code Not Available');

        //IF State_lRec2."State Code (GST Reg. No.)" <> '' then
        //    StateCode_L := State_lRec2."State Code (GST Reg. No.)"
        //Else
        //    StateCode_L := State_lRec."State Code (GST Reg. No.)";


        If Sh."Transfer-from Code" <> '' Then
            ShipPinCode := Sh."Transfer-from Post Code"
        Else
            ShipPinCode := Sh."Transfer-from Post Code";
        Tmode := 1; //SH."Trans Mode";

        //   ',"TransId":"' + SH."Trans Id" + '"' +
        //        ',"TransName":"' + SH."Trans Name" + '"' +
        //        ',"TransDocDt":"' + Format(SH."LR/RR Date") + '"' +
        //  ',"TransDocNo":"' + Sh."LR/RR No." + '"' +

        //    // IF SH."Trans Id" <> '' Then
        //         TransId := ',"TransId":"' + SH."Trans Id" + '"'
        //     else
        TransId := '';

        // IF SH."Trans Name" <> '' then
        //     TransName := ',"TransName":"' + SH."Trans Name" + '"'
        // else
        TransName := ',"TransName":"' + ',' + '"';
        // + FORMAT(SH."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>')

        IF (SH."LR/RR Date") <> 0D then
            TransDocDt := ',"TransDocDt":"' + Format(SH."LR/RR Date", 0, '<Day,2>/<Month,2>/<Year4>') + '"'
        else
            TransDocDt := ',"TransDocDt":"' + ',' + '"';

        IF Sh."LR/RR No." <> '' Then
            TransDocNo := ',"TransDocNo":"' + Sh."LR/RR No." + '"'
        else
            TransDocNo := ',"TransDocNo":"' + ',' + '"';
        IF TransId <> '' Then begin

            IF JSON1 = '' THEN
                JSON1 := '{"Irn":"' + Sh."IRN Hash" + '"' +
                   ',"Distance":"' + DELCHR(Format(SH."Distance (Km)"), '=', ',') + '"' +

                    ',"TransMode":"' + Format(Tmode) + '"' +
                    TransId +
                  TransName +
                  TransDocDt +
          TransDocNo +
            //',"VehNo:" "583" , "ExpShipDtls": {' +
            ',"VehNo":"' + SH."Vehicle No." + '"' +
            ',"VehType":"' + Format(vehtype) + '",' +
            ' "ExpShipDtls": {' +
             '"Addr1":"' + SH."Transfer-from Address" + '"' + ',"Addr2":"' + SH."Transfer-from Address 2" + '"' + ',"Loc":"' + SH."Transfer-from City" + '"'
             + ',"Pin":"' + ShipPinCode + '"' + ',"Stcd":"' + StateCode + '"},' + '"DispDtls": {' +
             '"Nm":"' + SH."Transfer-to Name" + '"'
             + ',"Addr2":"' + SH."Transfer-to Address 2" + '"' +
             ',"Loc":"' + SH."Transfer-TO City" + '"' +
            ',"Pin":"' + sh."Transfer-to Post Code" + '"' + ',"Stcd":"' + StateCode_L + '"}}';
        End Else begin

            IF JSON1 = '' THEN
                JSON1 := '{"Irn":"' + SH."IRN Hash" + '"' +
                  ',"Distance":"' + DELCHR(Format(SH."Distance (Km)"), '=', ',') + '"' +
                    ',"TransMode":"' + Format(Tmode) + '"' +
                  TransDocDt +
          TransDocNo +
            //',"VehNo:" "583" , "ExpShipDtls": {' +
            ',"VehNo":"' + SH."Vehicle No." + '"' +
            ',"VehType":"' + Format(vehtype) + '",' +
            ' "ExpShipDtls": {' +
             '"Addr1":"' + SH."Transfer-from Address" + '"' + ',"Addr2":"' + SH."Transfer-from Address 2" + '"' + ',"Loc":"' + SH."Transfer-from City" + '"'
             + ',"Pin":"' + ShipPinCode + '"' + ',"Stcd":"' + StateCode + '"},' + '"DispDtls": {' +
             '"Nm":"' + SH."Transfer-to Name" + '"'
             + ',"Addr2":"' + SH."Transfer-to Address 2" + '"' +
             ',"Loc":"' + SH."Transfer-from City" + '"' +
            ',"Pin":"' + ShipPinCode + '"' + ',"Stcd":"' + StateCode_L + '"}}';
        end;
        Message(JSON1);
        Clear(Store);
        IF Store.Get(Sh."Transfer-from Code") then;
        CLEAR(RespKeyToken);
        RespKeyToken := HostBooksAuthenticate(Store, Store."Hostbook UserAccNo", Store."Hostbook ConnectorID", 'KeyToken');
        TokentrimTo := STRPOS(RespKeyToken, '"hbsecretkey"') - 60;
        TokentrimFrom := STRPOS(RespKeyToken, '"hbToken":') + 11;
        JToken := COPYSTR(RespKeyToken, TokentrimFrom, TokentrimTo);
        Commit();
        KeytrimTo := STRPOS(RespKeyToken, '"expires"');
        KeytrimFrom := STRPOS(RespKeyToken, '"hbsecretkey"') + 15;
        JKey := COPYSTR(RespKeyToken, STRPOS(RespKeyToken, '"hbsecretkey"') + 15, KeytrimTo - KeytrimFrom - 2);
        URL := 'https://gstapihb.hostbooks.com/dec/api/Einvoice/GenerateEwayBill';
        // URL := 'https://hbapi.hostbooks.in/GSTTALLY/api/Einvoice/GenerateEwayBill';
        ClearLastError();
        Clear(gResponseMsg);
        gContent.GetHeaders(gContentHeaders);
        gContent.WriteFrom(JSON1);
        gContentHeaders.Remove('Content-Type');
        gContentHeaders.Add('Content-Type', 'application/json');
        gContentHeaders.Add('Secret-Key', JKey);
        // gContentHeaders.Add('IRP', SH.IRNvALUE); //PT-FBTS
        gHttpClient.DefaultRequestHeaders.add('Authorization', 'Bearer ' + JToken);

        gHttpRequestMsg.Content := gContent;
        gHttpRequestMsg.Method('POST');
        if gHttpClient.Post(URL, gContent, gHttpResponseMsg) then begin
            gHttpResponseMsg.Content.ReadAs(gResponseMsg);
            Resp := gResponseMsg;
            Message('%1', Resp);
        end;
        IF STRPOS(Resp, '"txnOutcome":" Success."') <> 0 THEN BEGIN
            Response22 := Resp;
            ewano := COPYSTR(Response22, STRPOS(Response22, '"ewbNo"') + 8, 12);
            ACKNo := COPYSTR(Response, STRPOS(Response, '"AckNo"') + 9, 15);
            Message('%1', ewano);
        End
        ELSE
            Error('Error messages');
        Sh."E-Way Bill No." := Ewano;
        // SH.Validate("Acknowledgement No.", ACKNo);
        SH.Validate("Acknowledgement Date", CurrentDateTime);
        Sh.Modify();
        Message('E-Waybill %1', Sh."E-Way Bill No.");
        MESSAGE('E-Waybill Successfully generated // Print Customer Invoice to get Einvoice Details by Scaning Printed QR Code');
    end;

    local procedure "--------------SalesInvoice_Einvoice---------"()
    begin
    end;

    procedure SaleInvoice_GenerateIRNNumber(TransactionType: Option Sale,"Sale Retrun"; CustomerNo: Code[20]; InvoiceNo: Code[20]; SH: Record "Sales Invoice Header")
    var
        SL: Record "Sales Invoice Line";
        SH1: Record "Sales Invoice Header";
        Store: Record Location;
        CompanyInformation: Record "Company Information";
        State: Record "State";
        JSON1: Text;
        ItemDetails: Text;
        CustomerStateCode: Text;
        StoreStateCode: Text;
        MyFile: File;
        FileName: Text;
        "XmlPort": HttpClient;
        Resp: Text;
        Customer: Record Customer;
        BuyerGSTIN: Code[20];
        QRData: Text;
        DateTrimFrom: Integer;
        RemAmt: Decimal;
        DateTrimto: Integer;
        CalculationType: Option "Item Wise",Total;
        BillToPINCODE: Code[10];
        ShipToPINCODE: Code[10];
        BuyerAddress: Text;
        ShipingAddress: Text;
        JKey: Text;
        JToken: Text;
        City: Text;
        TokentrimFrom: Integer;
        TokentrimTo: Integer;
        Ostream: OutStream;
        KeytrimFrom: Integer;
        KeytrimTo: Integer;
        RespKeyToken: Text;
        jsonmangment: Codeunit "JSON Management";
        SUCCESS: Text[2000];
        RetailSetup: Record "LSC Retail Setup";
        gResponseMsg: Text;
        gRequestMsg: Text;
        WinHttpService: HttpClient;
        SalesLine: Record "Sales Invoice Line";
        gHttpClient: HttpClient;
        gContent: HttpContent;
        gHttpResponseMsg: HttpResponseMessage;
        gHttpRequestMsg: HttpRequestMessage;
        gContentHeaders: HttpHeaders;
        GSTAmount: Decimal;
        URL: Text;
        CustomerRec: Record Customer;
        States_lRec: Record State;
        Crt: Text;
        State_lRec2: Record state;
        State_lRec1: Record State;
        GstgroupCode: Code[20];
        Location_lrec: Record Location;
        State_lrec: Record State;
        ShipPinCode: Code[20];
        BilltoCity: COde[20];
        StateCode_L: COde[20];
        suptyp: Text;

    begin
        CLEAR(JSON1);
        CLEAR(BuyerGSTIN);
        CLEAR(CustomerStateCode);
        CLEAR(StoreStateCode);
        CLEAR(QRData);
        CLEAR(BillToPINCODE);
        CLEAR(ShipToPINCODE);
        Clear(State_lRec1);
        If State_lRec1.Get(sh."GST Bill-to State Code") then;


        Clear(State_lRec2);
        If State_lRec2.Get(sh."GST Ship-to State Code") then;

        Clear(Location_lrec);
        IF Location_lrec.get(Sh."Location Code") then
            Clear(State_lrec);
        IF State_lrec.Get(Location_lrec."State Code") then;

        IF State_lRec2."State Code (GST Reg. No.)" <> '' then
            StateCode_L := State_lRec2."State Code (GST Reg. No.)"
        Else
            StateCode_L := State_lRec1."State Code (GST Reg. No.)";


        If Sh."Ship-to Post Code" <> '' Then
            ShipPinCode := Sh."Ship-to Post Code"
        Else
            ShipPinCode := Sh."Bill-to Post Code";


        If Sh."Ship-to City" <> '' Then
            BilltoCity := Sh."Ship-to City"
        Else
            BilltoCity := Sh."Bill-to City";
        //SaleInvoice_CheckInvoiceStatus(SH);

        Store.GET(SH."Location Code");
        CompanyInformation.GET;
        ItemDetails := SaleInvoice_GetItemDetails(SH);
        Clear(StoreStateCode);
        State.RESET;
        State.SETRANGE(Code, Store."State Code");
        IF State.FINDFIRST THEN begin
            if State."State Code (Einvoice)" = 'CRT' then
                StoreStateCode := 'NOS'
            else
                StoreStateCode := State."State Code (Einvoice)";
        End;
        State.RESET;
        State.SETRANGE(Code, SH."Bill to Customer State");
        IF State.FINDFIRST THEN
            CustomerStateCode := State."State Code (Einvoice)";

        SH.CALCFIELDS(Amount);//Ashish , "Amount to Customer"
        Customer.GET(CustomerNo);
        BuyerGSTIN := Customer."GST Registration No.";

        BuyerAddress := '';
        IF SH."Bill-to Address 2" = '' THEN
            BuyerAddress := SH."Bill-to City";

        IF SH."Bill-to Address 2" = '' THEN
            ShipingAddress := SH."Ship-to City";

        IF STRLEN(SH."Bill-to Post Code") = 6 THEN BEGIN
            BillToPINCODE := SH."Bill-to Post Code";
        END ELSE BEGIN
            BillToPINCODE := COPYSTR(SH."Bill-to Post Code", 4, 9);
        END;

        IF STRLEN(SH."Ship-to Post Code") = 6 THEN BEGIN
            ShipToPINCODE := SH."Ship-to Post Code";
        END ELSE BEGIN
            ShipToPINCODE := COPYSTR(SH."Ship-to Post Code", 4, 9);
        END;
        //Temp to clear pending invoices


        IF SH."Bill-to City" = '' THEN
            City := Customer.City
        ELSE
            City := SH."Bill-to City";
        //Temp to clear pending invoices
        //Pranshu
        //BillToPINCODE
        //ShipToPINCODE
        Clear(CustomerRec);
        IF CustomerRec.get(SH."Sell-to Customer No.") then
            Clear(States_lRec);
        IF States_lRec.get(CustomerRec."State Code") then;
        StoreStateCode := States_lRec."State Code (GST Reg. No.)";
        IF TransactionType = TransactionType::Sale THEN BEGIN

            SH.CalcFields("Amount Including VAT", Amount, SH."Remaining Amount");

            Clear(GSTAmount);
            GstgroupCode := '';
            SalesLine.Reset();
            SalesLine.SetRange("Document no.", SH."No.");
            if SalesLine.FindSet() then
                // Message('%1', GSTAmount);
                repeat
                    GstgroupCode := SalesLine."GST Group Code";
                    GSTAmount += GetGSTAmount(SalesLine.RecordId());
                //   Message('%1..%2', SalesLine."Line No.", GSTAmount);
                // GSTAmount += Round(GetGSTAmount(SalesLine.RecordId()));
                until SalesLine.Next() = 0;



            Clear(RemAmt);
            IF SH."Remaining Amount" <> 0 then
                RemAmt := SH."Remaining Amount" - GSTAmount
            else
                RemAmt := SH."Amount Including VAT";

            If sh."GST Customer Type" = sh."GST Customer Type"::"SEZ Unit" then
                suptyp := '"SEZWP"'
            else
                suptyp := '"B2B"';

            IF JSON1 = '' THEN
                JSON1 := '{"Version": "1.1"' + ',"SourceSystem": "NAV"' + ',"is_irn": "Y","is_ewb": "Y"' +
              ',"TranDtls": {"TaxSch": "GST","SupTyp":' + suptyp + ',"RegRev": "N"}' +
              ',"DocDtls": {"Typ": "INV","No": "' + SH."No." + '","Dt": "' + FORMAT(SH."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>') + '"}' +
              ',"SellerDtls": {"Gstin": "' + Store."GST Registration No." + '","LglNm": "' + CompanyInformation.Name +
              '","Addr1": "' + Store.Address + '","Addr2": "' + Store.Address + '","Loc": "' + Store.City + '","Pin":' + Location_lrec."Post Code" + ',"Stcd": "' + State_lrec."State Code (GST Reg. No.)" + '"}' +//StoreStateCode

              ',"BuyerDtls": {"Gstin": "' + BuyerGSTIN + '","LglNm": "' + SH."Sell-to Customer Name" + '","Addr1": "' + SH."Bill-to Address" +
                  '","Addr2": "' + SH."Bill-to Address" + '","Loc": "' + SH."Bill-to City" + '","Pin":' + SH."Bill-to Post Code" + ',"Stcd": "' + State_lRec1."State Code (GST Reg. No.)" +// + CustomerStateCode +
                  '","Pos": "' + COPYSTR(BuyerGSTIN, 1, 2) + '"}' +

              ',"DispDtls": {"Nm": "' + CompanyInformation.Name + '","Addr1": "' + Store.Address + '","Addr2": "' + Store.Address +
                  '","Loc": "' + Store.City + '","Pin":' + Location_lrec."Post Code" + ',"Stcd": "' + State_lrec."State Code (GST Reg. No.)" + '"}' +//StoreStateCode



              ',"ShipDtls": {"LglNm": "' + SH."Ship-to Name" + '","Addr1": "' + SH."Ship-to Address" + '","Addr2": "' + SH."Ship-to Address" +
                 '","Loc": "' + BilltoCity + '","Pin": ' + ShipPinCode + ',"Stcd": "' + StateCode_L + '"}' +//CustomerStateCode


              ',"ItemList": [' + ItemDetails + ']' +
              ',"ValDtls": {"AssVal": ' + DELCHR(FORMAT(SH.Amount), '=', ',') +//
              ',"CgstVal":' + SaleInvoice_GetTotalGSTDetails(SH, '', 'CGST') +
              ',"SgstVal":' + SaleInvoice_GetTotalGSTDetails(SH, '', 'SGST') +
              ',"IgstVal":' + SaleInvoice_GetTotalGSTDetails(SH, '', 'IGST') +
              ',"otherValue":' + Format(GSTAmount) +
              ',"TotInvVal": ' + DELCHR(FORMAT(RemAmt), '=', ',') + '}' + '}';//Ashish SH."Amount to Customer"



            // Message(JSON1);
            /*
              JKey:=HostBooksAuthenticate(Store,Store."Hostbook UserAccNo",Store."Hostbook ConnectorID",'Key');
              JToken:=HostBooksAuthenticate(Store,Store."Hostbook UserAccNo",Store."Hostbook ConnectorID",'Token');
            */
            CLEAR(RespKeyToken);
            RespKeyToken := HostBooksAuthenticate(Store, Store."Hostbook UserAccNo", Store."Hostbook ConnectorID", 'KeyToken');
            TokentrimTo := STRPOS(RespKeyToken, '"hbsecretkey"') - 60;
            TokentrimFrom := STRPOS(RespKeyToken, '"hbToken":') + 11;
            JToken := COPYSTR(RespKeyToken, TokentrimFrom, TokentrimTo);
            Commit();
            KeytrimTo := STRPOS(RespKeyToken, '"expires"');
            KeytrimFrom := STRPOS(RespKeyToken, '"hbsecretkey"') + 15;
            JKey := COPYSTR(RespKeyToken, STRPOS(RespKeyToken, '"hbsecretkey"') + 15, KeytrimTo - KeytrimFrom - 2);

            //    Message('reQ irn' + JSON1);
            URL := 'https://gstapihb.hostbooks.com/dec/api/Einvoice/GenerateIRN';
            ClearLastError();
            Clear(gResponseMsg);
            gContent.GetHeaders(gContentHeaders);
            gContent.WriteFrom(JSON1);
            Message(JSON1);

            gContentHeaders.Remove('Content-Type');
            gContentHeaders.Add('Content-Type', 'application/json');
            gContentHeaders.Add('Secret-Key', JKey);
            gHttpClient.DefaultRequestHeaders.add('Authorization', 'Bearer ' + JToken);
            //message(format(gContentHeaders.Add('Authorization', 'Bearer ' + JToken)));
            gHttpRequestMsg.Content := gContent;
            //  Message('Lateest %1', gContent);
            gHttpRequestMsg.Method('POST');

            // //Message(Format(gHttpClient.Post(URL, gContent, gHttpResponseMsg)));
            // clear(gHttpClient);
            // gHttpClient.SetBaseAddress(URL);
            // //Message(format(gHttpClient.Send(gHttpRequestMsg, gHttpResponseMsg)));
            //if gHttpClient.Send(gHttpRequestMsg, gHttpResponseMsg) then begin
            if gHttpClient.Post(URL, gContent, gHttpResponseMsg) then begin
                gHttpResponseMsg.Content.ReadAs(gResponseMsg);
                //if gHttpResponseMsg.IsSuccessStatusCode then begin
                //   //Message('Response %1', gResponseMsg);
                Resp := gResponseMsg;
                //end;
                jsonmangment.InitializeFromString(Resp);
                SUCCESS := jsonmangment.GetValue('txnOutcome');
                Message('%1', SUCCESS);
                APILogSalesInv(SH, SUCCESS);//PT-FBTS
            end;

            //IF TransactionType=TransactionType::"Sale Retrun" THEN
            //   MESSAGE('FinalRes '+Resp);
            IF STRPOS(Resp, '"txnOutcome":" Success."') <> 0 THEN BEGIN
                SaleInvoice_EInvoiceLog(SH, Resp);
                // MESSAGE('SResponse :'+Resp);
                DateTrimFrom := STRPOS(Resp, '"signedQRCode"') + 17;
                DateTrimto := STRPOS(Resp, '"status":"ACT"') - 3;
                QRData := COPYSTR(Resp, STRPOS(Resp, '"signedQRCode"') + 16, DateTrimto - DateTrimFrom + 2);
                //  MESSAGE('QR DATA :' +QRData);
                SaleInvoice_GenerateQR(QRData, SH);
                MESSAGE('E-Invoice Successfully generated // Print Customer Invoice to get Einvoice Details by Scaning Printed QR Code');
            END ELSE
                //For Duplicate IRN Request
                IF STRPOS(Resp, '"infCd":"DUPIRN"') <> 0 THEN BEGIN
                    SH."IRN Hash" := COPYSTR(Resp, STRPOS(Resp, '"Irn"') + 7, (STRPOS(Resp, '"respObj"') - 5) - (STRPOS(Resp, '"Irn"') + 7));
                    SH.MODIFY;
                    COMMIT;
                    //Message('%1', TH."IRN Hash");
                    //APILog(JSON1, Resp, 'E_InvoiceLog_Req_RES');
                    ERROR(Resp);
                END;
            // APILog(JSON1, Resp, 'E_InvoiceLog_Req_RES');

            //ELSE
            // ELSE

            //IF TransactionType=TransactionType::"Sale Retrun" THEN
        end;

    end;

    procedure Cancel_Einvoice(TransactionType: Option Sale,"Sale Retrun"; CustomerNo: Code[20]; InvoiceNo: Code[20]; SH: Record "Sales Invoice Header")
    var
        JSON2: Text;
        ///////////////////////
        SL: Record "Transfer Shipment Line";
        SH1: Record "Transfer Shipment Header";
        Store: Record Location;
        CompanyInformation: Record "Company Information";
        State: Record "State";
        JSON1: Text;
        ItemDetails: Text;
        CustomerStateCode: Text;
        StoreStateCode: Text;
        MyFile: File;
        FileName: Text;
        "XmlPort": HttpClient;
        Resp: Text;
        Customer: Record Customer;
        BuyerGSTIN: Code[20];
        QRData: Text;
        DateTrimFrom: Integer;
        RemAmt: Decimal;
        DateTrimto: Integer;
        CalculationType: Option "Item Wise",Total;
        BillToPINCODE: Code[10];
        ShipToPINCODE: Code[10];
        BuyerAddress: Text;
        ShipingAddress: Text;
        JKey: Text;
        JToken: Text;
        City: Text;
        TokentrimFrom: Integer;
        TokentrimTo: Integer;
        Ostream: OutStream;
        KeytrimFrom: Integer;
        KeytrimTo: Integer;
        RespKeyToken: Text;

        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        Response: Text;
        ResponseMessage: HttpResponseMessage;
        RequestHeaders: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        JsonObject: JsonObject;
        JSONManagement: Codeunit "JSON Management";
        ArrayJSONManagement: Codeunit "JSON Management";
        ObjectJSONManagement: Codeunit "JSON Management";
        Index: Integer;
        Value: text;
        ItemJsonobject: text;
        JsonObject1: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        JsonToken1: JsonToken;
        TransferLine: Record "Transfer Line";
        ItemNo: Code[20];
        VariantCode: Code[20];
        RetailSetup: Record "LSC Retail Setup";
        gResponseMsg: Text;
        gRequestMsg: Text;
        WinHttpService: HttpClient;
        SalesLine: Record "Sales Invoice Line";
        gHttpClient: HttpClient;
        gContent: HttpContent;
        gHttpResponseMsg: HttpResponseMessage;
        gHttpRequestMsg: HttpRequestMessage;
        gContentHeaders: HttpHeaders;
        GSTAmount: Decimal;
        URL: Text;
        CustomerRec: Record Customer;
        States_lRec: Record State;
        Crt: Text;
        State_lRec2: Record state;
        State_lRec1: Record State;
        GstgroupCode: Code[20];
        Location_lrec: Record "LSC Store";
        State_lrec: Record State;
        ShipPinCode: Code[20];
        BilltoCity: COde[20];
        StateCode_L: COde[20];
        Tmode: Integer;
        TransId: Text;
        TransName: Text;
        TransDocDt: Text;
        TransDocNo: Text;
        vehtype: Text;
        ewano1: text;
        Ewano: Text[50];
        ACKNo: Code[20];
        Response22: Text;

    begin
        IF JSON2 = '' THEN
            JSON2 := '{"Irn":"' + SH."IRN Hash" + '"' +
               ',"CnlRsn":"' + '2' + '"' +
                ',"CnlRem":"' + Format(SH."Cancel Reason") + '"}';
        Message(JSON2);
        ////////////////////////////
        Clear(Store);
        IF Store.Get(Sh."Location Code") then;
        CLEAR(RespKeyToken);
        RespKeyToken := HostBooksAuthenticate(Store, Store."Hostbook UserAccNo", Store."Hostbook ConnectorID", 'KeyToken');
        TokentrimTo := STRPOS(RespKeyToken, '"hbsecretkey"') - 60;
        TokentrimFrom := STRPOS(RespKeyToken, '"hbToken":') + 11;
        JToken := COPYSTR(RespKeyToken, TokentrimFrom, TokentrimTo);
        Commit();
        KeytrimTo := STRPOS(RespKeyToken, '"expires"');
        KeytrimFrom := STRPOS(RespKeyToken, '"hbsecretkey"') + 15;
        JKey := COPYSTR(RespKeyToken, STRPOS(RespKeyToken, '"hbsecretkey"') + 15, KeytrimTo - KeytrimFrom - 2);
        // URL := 'https://gstapihb.hostbooks.com/dec/api/Einvoice/GenerateEwayBill';
        URL := 'http://gstapihb.hostbooks.com/dec/api/Einvoice/CancelIRN';
        ClearLastError();
        Clear(gResponseMsg);
        gContent.GetHeaders(gContentHeaders);
        gContent.WriteFrom(JSON2);
        gContentHeaders.Remove('Content-Type');
        gContentHeaders.Add('Content-Type', 'application/json');
        gContentHeaders.Add('Secret-Key', JKey);
        gHttpClient.DefaultRequestHeaders.add('Authorization', 'Bearer ' + JToken);
        gHttpRequestMsg.Content := gContent;
        gHttpRequestMsg.Method('POST');
        if gHttpClient.Post(URL, gContent, gHttpResponseMsg) then begin
            gHttpResponseMsg.Content.ReadAs(gResponseMsg);
            Resp := gResponseMsg;
            Message('%1', Resp);
        end;
        IF STRPOS(Resp, '"txnOutcome":" Success."') <> 0 THEN BEGIN
            Response22 := Resp;
            SH."CancelIrn" := COPYSTR(Response, STRPOS(Response, '"irn"') + 7, 64);
            SH."E-Inv. Cancelled Date" := CurrentDateTime;
            SH.Modify();
            MESSAGE('E-Invoice Successfully Cencel');
        End;
    end;

    procedure Cancel_Ewaybill(TransactionType: Option Sale,"Sale Retrun"; CustomerNo: Code[20]; InvoiceNo: Code[20]; SH: Record "Sales Invoice Header")
    var
        JSON3: Text;
        ///////////////////////
        SL: Record "Transfer Shipment Line";
        SH1: Record "Transfer Shipment Header";
        Store: Record Location;
        CompanyInformation: Record "Company Information";
        State: Record "State";
        JSON1: Text;
        ItemDetails: Text;
        CustomerStateCode: Text;
        StoreStateCode: Text;
        MyFile: File;
        FileName: Text;
        "XmlPort": HttpClient;
        Resp: Text;
        Customer: Record Customer;
        BuyerGSTIN: Code[20];
        QRData: Text;
        DateTrimFrom: Integer;
        RemAmt: Decimal;
        DateTrimto: Integer;
        CalculationType: Option "Item Wise",Total;
        BillToPINCODE: Code[10];
        ShipToPINCODE: Code[10];
        BuyerAddress: Text;
        ShipingAddress: Text;
        JKey: Text;
        JToken: Text;
        City: Text;
        TokentrimFrom: Integer;
        TokentrimTo: Integer;
        Ostream: OutStream;
        KeytrimFrom: Integer;
        KeytrimTo: Integer;
        RespKeyToken: Text;

        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        Response: Text;
        ResponseMessage: HttpResponseMessage;
        RequestHeaders: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        JsonObject: JsonObject;
        JSONManagement: Codeunit "JSON Management";
        ArrayJSONManagement: Codeunit "JSON Management";
        ObjectJSONManagement: Codeunit "JSON Management";
        Index: Integer;
        Value: text;
        ItemJsonobject: text;
        JsonObject1: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        JsonToken1: JsonToken;
        TransferLine: Record "Transfer Line";
        ItemNo: Code[20];
        VariantCode: Code[20];
        RetailSetup: Record "LSC Retail Setup";
        gResponseMsg: Text;
        gRequestMsg: Text;
        WinHttpService: HttpClient;
        SalesLine: Record "Sales Invoice Line";
        gHttpClient: HttpClient;
        gContent: HttpContent;
        gHttpResponseMsg: HttpResponseMessage;
        gHttpRequestMsg: HttpRequestMessage;
        gContentHeaders: HttpHeaders;
        GSTAmount: Decimal;
        URL: Text;
        CustomerRec: Record Customer;
        States_lRec: Record State;
        Crt: Text;
        State_lRec2: Record state;
        State_lRec1: Record State;
        GstgroupCode: Code[20];
        Location_lrec: Record "LSC Store";
        State_lrec: Record State;
        ShipPinCode: Code[20];
        BilltoCity: COde[20];
        StateCode_L: COde[20];
        Tmode: Integer;
        TransId: Text;
        TransName: Text;
        TransDocDt: Text;
        TransDocNo: Text;
        vehtype: Text;
        ewano1: text;
        Ewano: Text[50];
        ACKNo: Code[20];
        Response22: Text;

    begin
        IF JSON3 = '' THEN
            JSON3 := '{"ewbNo":"' + SH."E-Way Bill No." + '"' +
               ',"cancelRsnCode":"' + '2' + '"' +
                ',"cancelRmrk":"' + Format(SH."Cancel Reason") + '"}';
        Message(JSON3);
        ////////////////////////////
        Clear(Store);
        IF Store.Get(Sh."Location Code") then;
        CLEAR(RespKeyToken);
        RespKeyToken := HostBooksAuthenticate(Store, Store."Hostbook UserAccNo", Store."Hostbook ConnectorID", 'KeyToken');
        TokentrimTo := STRPOS(RespKeyToken, '"hbsecretkey"') - 60;
        TokentrimFrom := STRPOS(RespKeyToken, '"hbToken":') + 11;
        JToken := COPYSTR(RespKeyToken, TokentrimFrom, TokentrimTo);
        Commit();
        KeytrimTo := STRPOS(RespKeyToken, '"expires"');
        KeytrimFrom := STRPOS(RespKeyToken, '"hbsecretkey"') + 15;
        JKey := COPYSTR(RespKeyToken, STRPOS(RespKeyToken, '"hbsecretkey"') + 15, KeytrimTo - KeytrimFrom - 2);
        // URL := 'https://gstapihb.hostbooks.com/dec/api/Einvoice/GenerateEwayBill';
        URL := 'http://gstapihb.hostbooks.com/dec/api/Einvoice/CancelEwayBill';
        ClearLastError();
        Clear(gResponseMsg);
        gContent.GetHeaders(gContentHeaders);
        gContent.WriteFrom(JSON3);
        gContentHeaders.Remove('Content-Type');
        gContentHeaders.Add('Content-Type', 'application/json');
        gContentHeaders.Add('Secret-Key', JKey);
        gHttpClient.DefaultRequestHeaders.add('Authorization', 'Bearer ' + JToken);
        gHttpRequestMsg.Content := gContent;
        gHttpRequestMsg.Method('POST');
        if gHttpClient.Post(URL, gContent, gHttpResponseMsg) then begin
            gHttpResponseMsg.Content.ReadAs(gResponseMsg);
            Resp := gResponseMsg;
            Message('%1', Resp);
        end;
        IF STRPOS(Resp, '"txnOutcome":" Success."') <> 0 THEN BEGIN
            Response22 := Resp;
            ewano := COPYSTR(Response22, STRPOS(Response22, '"ewbNo"') + 8, 12);
            MESSAGE('E-waybill Successfully Cencel');
        End;
        SH.Validate("CancelE-Way Bill No.", ewano);
        SH.Modify();
    end;

    procedure GetGSTAmount(RecID: RecordID): Decimal
    var
        TaxTransactionValue: Record "Tax Transaction Value";
        DecimalToRound: Decimal;
        Direction: Text;
        Precision: Decimal;
        Result: Decimal;
        Text000: Label 'ROUND(%1, %2, %3) returns %4';
        IntAmount: Decimal;
        DecAmount: Decimal;
        TotalAmt: Decimal;
    begin
        Clear(DecimalToRound);
        Clear(Result);

        TaxTransactionValue.SetRange("Tax Record ID", RecID);
        TaxTransactionValue.SetRange("Value Type", TaxTransactionValue."Value Type"::COMPONENT);
        TaxTransactionValue.SetRange("Tax Type", 'TCS');
        TaxTransactionValue.SetFilter(Amount, '<>%1', 0);
        TaxTransactionValue.SetFilter(TaxTransactionValue.Percent, '<>%1', 0);
        if not TaxTransactionValue.IsEmpty() then
            TaxTransactionValue.CalcSums(Amount);
        DecimalToRound := TaxTransactionValue.Amount;
        Direction := '>';
        Precision := 1;
        Result := ROUND(DecimalToRound, Precision, Direction);

        IntAmount := DecimalToRound div 1;
        DecAmount := DecimalToRound * 100 mod 100;
        // Message('%1..%2', IntAmount, DecAmount);
        IF (DecAmount < 50) then
            TotalAmt := IntAmount
        else
            TotalAmt := Result;

        exit(TotalAmt);
    end;

    procedure SaleInvoice_GetItemDetails(SalesHeader: Record "Sales Invoice Header"): Text
    var
        SalesLine: Record "Sales Invoice Line";
        LineNo: Integer;
        HSNASC: Record "HSN/SAC";
        ItemJson: Text;
        DetailedGSTEntryBuffer: Record "Detailed GST Ledger Entry";
        UnitofMeasure: Record "Unit of Measure";
        GSTRate: Decimal;
        HSN: Code[10];
        CalculationType: Option "Item Wise",Total;
        IsService: Text;
        RItem: Record Item;
        CGST_l: Text;
        IGST_l: Text;
        SGST_l: Text;
        CGST_lDec: Decimal;
        IGST_lDec: Decimal;
        SGST_lDec: Decimal;
        CGST_lPer: Text;
        SLNo: Integer;
        IGST_lPer: Text;
        SGST_lPer: Text;
        CGST_lDecPer: Decimal;
        IGST_lDecPer: Decimal;
        SGST_lDecPer: Decimal;
        DetailedGST: Record "Detailed GST Ledger Entry";
        UOM: Code[20];
        GstGroup: Record "GST Group";
        GlAcc: Record 15;
    begin
        CLEAR(ItemJson);
        CLEAR(GSTRate);
        CLEAR(HSN);
        Clear(IGST_l);
        Clear(CGST_l);
        Clear(SGST_l);

        Clear(IGST_lPer);
        Clear(CGST_lPer);
        Clear(SGST_lPer);
        SLNo := 0;
        SalesLine.RESET;
        //SalesLine.SETRANGE("Document Type",SalesHeader."Document Type");
        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
        SalesLine.SetFilter(SalesLine.Description, '<>%1', 'ROUNDED OFF');
        SalesLine.SetFilter("HSN/SAC Code", '<>%1', '');
        SalesLine.SetFilter(Type, '%1|%2|%3', SalesLine.Type::Item, SalesLine.Type::"G/L Account", SalesLine.Type::"Fixed Asset");
        IF SalesLine.FINDSET THEN
            REPEAT
                // GSTRate := SaleInvoice_GSTDetailsPer;//Ashish ROUND(SalesLine."GST %", 1);

                IGST_lPer := SaleInvoice_GSTDetailsPer(SalesLine, SalesLine."No.", 'IGST', SalesLine."Line No.");
                CGST_lPer := SaleInvoice_GSTDetailsPer(SalesLine, SalesLine."No.", 'CGST', SalesLine."Line No.");
                SGST_lPer := SaleInvoice_GSTDetailsPer(SalesLine, SalesLine."No.", 'SGST', SalesLine."Line No.");
                Clear(IGST_lDecPer);
                Clear(CGST_lDecPer);
                Clear(SGST_lDecPer);
                IF IGST_lPer <> '0' then
                    Evaluate(IGST_lDecPer, IGST_lPer);
                IF CGST_lPer <> '0' then
                    Evaluate(CGST_lDecPer, CGST_lPer);
                IF SGST_lPer <> '0' then
                    Evaluate(SGST_lDecPer, SGST_lPer);
                if GstGroup.Get(SalesLine."GST Group Code") then

                    //GSTRate := IGST_lDecPer + SGST_lDecPer + CGST_lDecPer;
                    GSTRate := GstGroup."GST Rate";
                // Message('%1', GSTRate);

                IF UnitofMeasure.GET(SalesLine."Unit of Measure Code") THEN;
                Clear(UOM);
                IF UnitofMeasure."E UOM" = 'CRT' then
                    UOM := 'NOS'
                else
                    UOM := UnitofMeasure."E UOM";

                Clear(RItem);
                // IF RItem.GET(SalesLine."No.") then;
                // HSN := RItem."HSN/SAC Code"; //Temp to clear pending invoices
                Clear(GlAcc);
                IF GlAcc.Get(SalesLine."No.") then
                    HSN := GlAcc."HSN/SAC Code";

                // IF SalesLine."HSN/SAC Code" = '998816' THEN
                //     IsService := 'Y'
                // ELSE
                //     IsService := 'N';
                HSNASC.Reset();
                HSNASC.SetRange(code, SalesLine."HSN/SAC Code");
                if HSNASC.FindFirst() then begin
                    if HSNASC.Type = HSNASC.Type::SAC then
                        IsService := 'Y';
                    if HSNASC.Type = HSNASC.Type::HSN then
                        IsService := 'N';
                end;

                IGST_l := SaleInvoice_GSTDetails(SalesLine, SalesLine."No.", 'IGST', SalesLine."Line No.");
                CGST_l := SaleInvoice_GSTDetails(SalesLine, SalesLine."No.", 'CGST', SalesLine."Line No.");
                SGST_l := SaleInvoice_GSTDetails(SalesLine, SalesLine."No.", 'SGST', SalesLine."Line No.");


                Clear(IGST_lDec);
                Clear(CGST_lDec);
                Clear(SGST_lDec);

                IF IGST_l <> '0' then
                    Evaluate(IGST_lDec, IGST_l);
                IF SGST_l <> '0' then
                    Evaluate(SGST_lDec, SGST_l);
                IF CGST_l <> '0' then
                    Evaluate(CGST_lDec, CGST_l);
                // IF STRLEN(FORMAT(SalesLine."Line No.")) > 5 THEN
                //     SLNo := SalesLine."Line No." / 10000
                // ELSE
                //     SLNo := SalesLine."Line No.";

                SLNo += 1;

                IF ItemJson = '' THEN
                    ItemJson := '{"SlNo":"' + FORMAT(SLNo) + '","HsnCd":"' + SalesLine."HSN/SAC Code" + '","IsServc":"' + IsService + '"' +
                  ',"Qty":' + DELCHR(FORMAT(SalesLine.Quantity), '=', ',') + ',"Unit": "' + FORMAT(UnitofMeasure."E UOM") +
                  '","UnitPrice":' + DELCHR(FORMAT(SalesLine."Unit Price"), '=', ',') +
                  ',"TotAmt":' + DELCHR(FORMAT(SalesLine.Amount), '=', ',') + ',"AssAmt":' + DELCHR(FORMAT(SalesLine.Amount), '=', ',') +
                  ',"GstRt":' + FORMAT(GSTRate) +
                 ',"IgstAmt":' + (DELCHR(FORMAT(IGST_lDec), '=', ',')) + ',"CgstAmt":' + (DELCHR(FORMAT(CGST_lDec), '=', ',')) +
                  ',"SgstAmt":' + (DELCHR(FORMAT(SGST_lDec), '=', ',')) +
                   ',"TotItemVal":' + DELCHR(FORMAT(SalesLine.Amount + IGST_lDec + CGST_lDec + SGST_lDec), '=', ',') + '}'
                ELSE
                    ItemJson += ',{"SlNo":"' + FORMAT(SLNo) + '","HsnCd":"' + SalesLine."HSN/SAC Code" + '","IsServc":"' + IsService + '"' +
                  ',"Qty":' + DELCHR(FORMAT(SalesLine.Quantity), '=', ',') + ',"Unit": "' + FORMAT(UnitofMeasure."E UOM") +
                  '","UnitPrice":' + DELCHR(FORMAT(SalesLine."Unit Price"), '=', ',') +
                  ',"TotAmt":' + DELCHR(FORMAT(SalesLine.Amount), '=', ',') + ',"AssAmt":' + DELCHR(FORMAT(SalesLine.Amount), '=', ',') +
                  ',"GstRt":' + FORMAT(GSTRate) +
                  ',"IgstAmt":' + (DELCHR(FORMAT(IGST_lDec), '=', ',')) + ',"CgstAmt":' + (DELCHR(FORMAT(CGST_lDec), '=', ',')) +
                  ',"SgstAmt":' + (DELCHR(FORMAT(SGST_lDec), '=', ',')) +
                   ',"TotItemVal":' + DELCHR(FORMAT(SalesLine.Amount + IGST_lDec + CGST_lDec + SGST_lDec), '=', ',') + '}';
            UNTIL SalesLine.NEXT = 0;

        EXIT(ItemJson);
    end;

    local procedure SaleInvoice_GSTDetails(SLine: Record "Sales Invoice Line";
ItemCode: Code[20];
GSTComponent: Code[10];
RecLineNo: Integer) ReturnValue: Text
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
    begin
        CLEAR(ReturnValue);

        DetailedGSTLedgerEntry.RESET;
        DetailedGSTLedgerEntry.SETCURRENTKEY("Entry No.");
        //DetailedGSTLedgerEntry.SETRANGE("Document Type",SLine."Document Type");
        DetailedGSTLedgerEntry.SETRANGE("Document No.", SLine."Document No.");
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", GSTComponent);
        DetailedGSTLedgerEntry.SETRANGE("No.", SLine."No.");
        DetailedGSTLedgerEntry.SETRANGE("Document Line No.", SLine."Line No.");
        //DetailedGSTLedgerEntry.SETRANGE("Line No.",RecLineNo);
        IF DetailedGSTLedgerEntry.FINDFIRST THEN
            ReturnValue := DELCHR(FORMAT(DetailedGSTLedgerEntry."GST Amount" * -1), '=', ',')
        ELSE
            ReturnValue := '0';

        EXIT(ReturnValue);
    end;

    local procedure SaleInvoice_GSTDetailsPer(SLine: Record "Sales Invoice Line"; ItemCode: Code[20]; GSTComponent: Code[10]; RecLineNo: Integer) ReturnValue: Text
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
    begin
        CLEAR(ReturnValue);
        DetailedGSTLedgerEntry.RESET;
        DetailedGSTLedgerEntry.SETCURRENTKEY("Entry No.");
        DetailedGSTLedgerEntry.SETRANGE("Document No.", SLine."Document No.");
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", GSTComponent);
        DetailedGSTLedgerEntry.SETRANGE("No.", SLine."No.");
        IF DetailedGSTLedgerEntry.FINDFIRST THEN
            ReturnValue := (FORMAT(DetailedGSTLedgerEntry."GST %"))//*)// -1), '=', ',')
        ELSE
            ReturnValue := '0';
        EXIT(ReturnValue);
    end;

    local procedure SaleInvoice_GetTotalGSTDetails(SHdr: Record "Sales Invoice Header"; ItemCode: Code[20]; GSTComponent: Code[10]) ReturnValue: Text
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        TotalGST: Decimal;
    begin
        CLEAR(ReturnValue);
        CLEAR(TotalGST);
        DetailedGSTLedgerEntry.RESET;
        DetailedGSTLedgerEntry.SETCURRENTKEY("Document No.", "Document Line No.", "GST Component Code");
        DetailedGSTLedgerEntry.SETRANGE("Document No.", SHdr."No.");
        DetailedGSTLedgerEntry.SETRANGE("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Sales);
        DetailedGSTLedgerEntry.SETRANGE("Document Type", DetailedGSTLedgerEntry."Document Type"::Invoice);
        //Ashish  DetailedGSTLedgerEntry.SETRANGE("Original Doc. Type", DetailedGSTLedgerEntry."Original Doc. Type"::Invoice);
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", GSTComponent);
        IF DetailedGSTLedgerEntry.FINDSET THEN BEGIN
            REPEAT
                TotalGST += DetailedGSTLedgerEntry."GST Amount";
            UNTIL DetailedGSTLedgerEntry.NEXT = 0;
            ReturnValue := DELCHR(FORMAT(TotalGST * -1), '=', ',');
            EXIT(ReturnValue);
        END ELSE
            ReturnValue := '0';
    end;

    local procedure SaleInvoice_GenerateQR(QRData: Text; SalesHeader: Record "Sales Invoice Header")
    var
        QRPath: Text[250];
        FileMgt: Codeunit "File Management";
        BOUTIL: Codeunit "LSC BO Utils";
        // TempBlob: Record "TempBlob";
        TempBlob: Codeunit "Temp Blob";
        EinvoiceETransLog: Record "E-Invoice Log Entry";
        ClientFile: Text;
        ServerFile: Text;
        RecordRef: RecordRef;
        OutStream: OutStream;
        QRGenerator: Codeunit "QR Generator";
        FieldRef: FieldRef;

    begin
        Clear(TempBlob);
        Clear(RecordRef);
        Clear(FieldRef);
        EinvoiceETransLog.RESET;
        EinvoiceETransLog.SETRANGE("Invoice No.", SalesHeader."No.");
        IF EinvoiceETransLog.FINDFIRST THEN BEGIN
            RecordRef.Get(EinvoiceETransLog.RecordId);
            QRGenerator.GenerateQRCodeImage(QRData, TempBlob);
            FieldRef := RecordRef.Field(EinvoiceETransLog.FieldNo("Einvoice QR Code"));
            TempBlob.ToRecordRef(RecordRef, EinvoiceETransLog.FieldNo("Einvoice QR Code"));
            FieldRef := RecordRef.Field(EinvoiceETransLog.FieldNo("Einvoice QR Code"));
            EinvoiceETransLog."Einvoice QR Code" := FieldRef.Value;
            EinvoiceETransLog.MODIFY;
            //  Message('%1', EinvoiceETransLog."Invoice No.");
        end;
        // SalesHeader."QR Code" := EinvoiceETransLog."Einvoice QR Code";
        // SalesHeader.Modify();
    end;

    local procedure SaleInvoice_EInvoiceLog(SalesHeader: Record "Sales Invoice Header"; Response: Text)
    var
        EinvoiceETransLog: Record "E-Invoice Log Entry";
        jsonmangment: Codeunit "JSON Management";
        respobj: Text;

        irpNo: Code[10];
    begin
        EinvoiceETransLog.RESET;
        EinvoiceETransLog.SETRANGE("Invoice No.", SalesHeader."No.");
        EinvoiceETransLog.SETRANGE("Request Validated", TRUE);
        IF NOT EinvoiceETransLog.FINDFIRST THEN BEGIN
            EinvoiceETransLog.INIT;
            EinvoiceETransLog."Request Type" := EinvoiceETransLog."Request Type"::"E-Invoice";
            EinvoiceETransLog."Order No." := SalesHeader."Order No.";
            EinvoiceETransLog."Invoice No." := SalesHeader."No.";
            EinvoiceETransLog."IRN No." := COPYSTR(Response, STRPOS(Response, '"irn"') + 7, 64);
            EinvoiceETransLog.AckNo := COPYSTR(Response, STRPOS(Response, '"AckNo"') + 9, 15);
            EinvoiceETransLog."Ack DateTime" := FORMAT(CURRENTDATETIME);
            EinvoiceETransLog."Einvoice Res Message" := COPYSTR(Response, 1, 250);
            EinvoiceETransLog."Request Validated" := TRUE;
            EinvoiceETransLog.INSERT;
            COMMIT;
        END;
        // jsonmangment.InitializeFromString(Response);
        // respobj := jsonmangment.GetValue('respObj');
        // jsonmangment.InitializeFromString(respobj);
        // irpNo := jsonmangment.GetValue('irp');
        // SalesHeader.IRNvALUE := irpNo;
        SalesHeader."IRN Number" := COPYSTR(Response, STRPOS(Response, '"irn"') + 7, 64);
        SalesHeader."IRN Hash" := COPYSTR(Response, STRPOS(Response, '"irn"') + 7, 64);
        SalesHeader."Einvoice Generated" := TRUE;
        SalesHeader.MODIFY;
    end;

    local procedure SaleInvoice_CheckInvoiceStatus(SalesHeader: Record "Sales Invoice Header")
    var
        EinvoiceETransLog: Record "E-Invoice Log Entry";
        Customer: Record Customer;
    begin
        Customer.GET(SalesHeader."Sell-to Customer No.");

        EinvoiceETransLog.RESET;
        EinvoiceETransLog.SETRANGE("Order No.", SalesHeader."Order No.");
        EinvoiceETransLog.SETRANGE("Invoice No.", SalesHeader."No.");
        EinvoiceETransLog.SETRANGE("Request Validated", TRUE);
        IF EinvoiceETransLog.FINDFIRST THEN
            ERROR('Einvoice already generated for this invoice,Please Take Invoice Print \\ IRN : %1 \\Invoice No. : %2', EinvoiceETransLog."IRN No.", SalesHeader."No.")
        ELSE
            EXIT;
    end;

    procedure SaleInvoice_GenerateInvoice(TransactionType: Option Sale,"Sale Retrun"; CustomerNo: Code[20]; InvoiceNo: Code[20]; SH: Record "Sales Invoice Header")
    var
        SL: Record "Sales Invoice Line";
        SH1: Record "Sales Invoice Header";
        Store: Record Location;
        CompanyInformation: Record "Company Information";
        State: Record "State";
        JSON1: Text;
        ItemDetails: Text;
        CustomerStateCode: Text;
        StoreStateCode: Text;
        MyFile: File;
        FileName: Text;
        "XmlPort": HttpClient;
        Resp: Text;
        Customer: Record Customer;
        BuyerGSTIN: Code[20];
        QRData: Text;
        DateTrimFrom: Integer;
        RemAmt: Decimal;
        DateTrimto: Integer;
        CalculationType: Option "Item Wise",Total;
        BillToPINCODE: Code[10];
        ShipToPINCODE: Code[10];
        BuyerAddress: Text;
        ShipingAddress: Text;
        JKey: Text;
        JToken: Text;
        City: Text;
        TokentrimFrom: Integer;
        TokentrimTo: Integer;
        Ostream: OutStream;
        KeytrimFrom: Integer;
        KeytrimTo: Integer;
        RespKeyToken: Text;

        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        Response: Text;
        ResponseMessage: HttpResponseMessage;
        RequestHeaders: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        JsonObject: JsonObject;
        JSONManagement: Codeunit "JSON Management";
        ArrayJSONManagement: Codeunit "JSON Management";
        ObjectJSONManagement: Codeunit "JSON Management";
        Index: Integer;
        Value: text;
        ItemJsonobject: text;
        JsonObject1: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        JsonToken1: JsonToken;
        TransferLine: Record "Transfer Line";
        ItemNo: Code[20];
        VariantCode: Code[20];

        RetailSetup: Record "LSC Retail Setup";
        gResponseMsg: Text;
        gRequestMsg: Text;
        WinHttpService: HttpClient;
        SalesLine: Record "Sales Invoice Line";
        gHttpClient: HttpClient;
        gContent: HttpContent;
        gHttpResponseMsg: HttpResponseMessage;
        gHttpRequestMsg: HttpRequestMessage;
        gContentHeaders: HttpHeaders;
        GSTAmount: Decimal;
        URL: Text;
        CustomerRec: Record Customer;
        States_lRec: Record State;
        Crt: Text;
        State_lRec2: Record state;
        State_lRec1: Record State;
        GstgroupCode: Code[20];
        Location_lrec: Record Location;
        State_lrec: Record State;
        ShipPinCode: Code[20];
        BilltoCity: COde[20];
        StateCode_L: COde[20];
        Tmode: Integer;
        TransId: Text;
        TransName: Text;
        TransDocDt: Text;
        TransDocNo: Text;
        vehtype: Text;
        ewano1: text;
        Ewano: Text;
        Response22: Text;
    begin

        //PRANSHU
        if sh."Vehicle Type" = sh."Vehicle Type"::Regular then
            vehtype := 'R'
        else
            if sh."Vehicle Type" = sh."Vehicle Type"::ODC then
                vehtype := 'O'
            else
                vehtype := '';

        Clear(Location_lrec);
        IF Location_lrec.get(Sh."Location Code") then
            Clear(State_lrec);
        // Clear(StateCode_L);
        IF State_lrec.Get(Location_lrec."State Code") then;

        clear(State_lRec2);
        if State_lRec2.Get(sh."GST Bill-to State Code") then
            StateCode_L := State_lRec2."State Code (GST Reg. No.)"
        else
            Error('State code Not Available');

        If Sh."Ship-to Post Code" <> '' Then
            ShipPinCode := Sh."Ship-to Post Code"
        Else
            ShipPinCode := Sh."Bill-to Post Code";
        Tmode := 1; //SH."Trans Mode";

        IF SH."Trans Id" <> '' Then
            TransId := ',"TransId":"' + SH."Trans Id" + '"'
        else
            TransId := '';

        IF SH."Trans Name" <> '' then
            TransName := ',"TransName":"' + SH."Trans Name" + '"'
        else
            TransName := ',"TransName":"' + ',' + '"';
        // + FORMAT(SH."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>')

        IF (SH."LR/RR Date") <> 0D then
            TransDocDt := ',"TransDocDt":"' + Format(SH."LR/RR Date", 0, '<Day,2>/<Month,2>/<Year4>') + '"'
        else
            TransDocDt := ',"TransDocDt":"' + ',' + '"';

        IF Sh."LR/RR No." <> '' Then
            TransDocNo := ',"TransDocNo":"' + Sh."LR/RR No." + '"'
        else
            TransDocNo := ',"TransDocNo":"' + ',' + '"';
        IF TransId <> '' Then begin

            IF JSON1 = '' THEN
                JSON1 := '{"Irn":"' + SH."IRN Number" + '"' +
                   ',"Distance":"' + Format(SH."Distance (Km)") + '"' +
                    ',"TransMode":"' + Format(Tmode) + '"' +
                    TransId +
                  TransName +
                  TransDocDt +
          TransDocNo +
            //',"VehNo:" "583" , "ExpShipDtls": {' +
            ',"VehNo":"' + SH."Vehicle No." + '"' +
            ',"VehType":"' + Format(vehtype) + '",' +
            ' "ExpShipDtls": {' +
             '"Addr1":"' + SH."Ship-to Address" + '"' + ',"Addr2":"' + SH."Ship-to Address 2" + '"' + ',"Loc":"' + SH."Ship-to City" + '"'
             + ',"Pin":"' + ShipPinCode + '"' + ',"Stcd":"' + StateCode_L + '"},' + '"DispDtls": {' +
             '"Nm":"' + SH."Bill-to Name" + '"'
             + ',"Addr2":"' + SH."Bill-to Address 2" + '"' +
             ',"Loc":"' + SH."Ship-to City" + '"' +
            ',"Pin":"' + ShipPinCode + '"' + ',"Stcd":"' + StateCode_L + '"}}';
        End Else begin

            IF JSON1 = '' THEN
                JSON1 := '{"Irn":"' + SH."IRN Number" + '"' +
                   ',"Distance":"' + Format(SH."Distance (Km)") + '"' +
                    ',"TransMode":"' + Format(Tmode) + '"' +
                  TransDocDt +
          TransDocNo +
            //',"VehNo:" "583" , "ExpShipDtls": {' +
            ',"VehNo":"' + SH."Vehicle No." + '"' +
            ',"VehType":"' + Format(vehtype) + '",' +
            ' "ExpShipDtls": {' +
             '"Addr1":"' + SH."Ship-to Address" + '"' + ',"Addr2":"' + SH."Ship-to Address 2" + '"' + ',"Loc":"' + SH."Ship-to City" + '"'
             + ',"Pin":"' + ShipPinCode + '"' + ',"Stcd":"' + StateCode_L + '"},' + '"DispDtls": {' +
             '"Nm":"' + SH."Bill-to Name" + '"'
             + ',"Addr2":"' + SH."Bill-to Address 2" + '"' +
             ',"Loc":"' + SH."Ship-to City" + '"' +
            ',"Pin":"' + ShipPinCode + '"' + ',"Stcd":"' + StateCode_L + '"}}';

        end;
        Message(JSON1);
        Clear(Store);
        IF Store.Get(Sh."Location Code") then;
        CLEAR(RespKeyToken);
        RespKeyToken := HostBooksAuthenticate(Store, Store."Hostbook UserAccNo", Store."Hostbook ConnectorID", 'KeyToken');
        TokentrimTo := STRPOS(RespKeyToken, '"hbsecretkey"') - 60;
        TokentrimFrom := STRPOS(RespKeyToken, '"hbToken":') + 11;
        JToken := COPYSTR(RespKeyToken, TokentrimFrom, TokentrimTo);
        Commit();
        KeytrimTo := STRPOS(RespKeyToken, '"expires"');
        KeytrimFrom := STRPOS(RespKeyToken, '"hbsecretkey"') + 15;
        JKey := COPYSTR(RespKeyToken, STRPOS(RespKeyToken, '"hbsecretkey"') + 15, KeytrimTo - KeytrimFrom - 2);

        // URL := 'https://gstapihb.hostbooks.com/dec/api/Einvoice/GenerateEwayBill';
        URL := 'https://gstapihb.hostbooks.com/dec/api/Einvoice/GenerateEwayBill';
        // URL := 'https://hbapi.hostbooks.in/GSTTALLY/api/Einvoice/GenerateEwayBill';

        ClearLastError();
        Clear(gResponseMsg);
        gContent.GetHeaders(gContentHeaders);
        gContent.WriteFrom(JSON1);
        gContentHeaders.Remove('Content-Type');
        gContentHeaders.Add('Content-Type', 'application/json');
        gContentHeaders.Add('Secret-Key', JKey);
        gContentHeaders.Add('IRP', SH.IRNvALUE);
        gHttpClient.DefaultRequestHeaders.add('Authorization', 'Bearer ' + JToken);
        gHttpRequestMsg.Content := gContent;
        gHttpRequestMsg.Method('POST');

        if gHttpClient.Post(URL, gContent, gHttpResponseMsg) then begin
            gHttpResponseMsg.Content.ReadAs(gResponseMsg);
            Resp := gResponseMsg;
            Message('%1', Resp);
        end;
        IF STRPOS(Resp, '"txnOutcome":" Success."') <> 0 THEN BEGIN
            Response22 := Resp;
            ewano := COPYSTR(Response22, STRPOS(Response22, '"ewbNo"') + 8, 12);
        End;
        Message('%1', ewano);
        Sh."E-Way Bill No." := ewano;
        Sh.Modify();
        MESSAGE('E-Invoice Successfully generated // Print Customer Invoice to get Einvoice Details by Scaning Printed QR Code');

    end;


    ////////////////////////////
    procedure InsertDate(Sch: Boolean)
    var
        myInt: Integer;
    begin
        Clear(dateCHeckCas);
        dateCHeckCas := Sch;

    end;

    procedure ReturnDate(): Boolean
    var
        myInt: Integer;
    begin
        exit(dateCHeckCas)
    end;


    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidatePaymentDiscountPercent, '', false, false)]
    local procedure "Purchase Header_OnBeforeValidatePaymentDiscountPercent"(var PurchaseHeader: Record "Purchase Header"; xPurchaseHeader: Record "Purchase Header"; CurrentFieldNo: Integer; var IsHandled: Boolean)
    begin
        IF ReturnDate Then
            IsHandled := true;
    end;

    var
        dateCHeckCas: Boolean;
}

