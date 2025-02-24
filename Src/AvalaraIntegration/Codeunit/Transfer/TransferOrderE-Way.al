
// Using for Posted Transfer Shippemt E - Way bill
codeunit 50008 TransferOrderEway
{
    trigger OnRun()
    begin

    end;

    procedure HostbookLoginEWAYBill(var Store: Record Location) TokenKey: Text;
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
        //  URL: Text;
        //  token: Text;

        URL, token, buid, userid, gstin : Text;
    begin
        IF Store."Hostbook UserAccNo" <> '' THEN BEGIN

            // Store.TESTFIELD("Hostbook Login ID");

            // Store.TESTFIELD("Hostbook ConnectorID");

            // Store.TESTFIELD("Hostbook Password");

            // Store.TestField("GST Registration No.");

            // Store.TestField("Hostbook UserAccNo");

            // CLEAR(JSONReq);

            RStore.GET(Store.Code);

            IF JSONReq = '' THEN
                JSONReq := '{"loginId": "' + Store."Hostbook Login ID" +// Store."Hostbook Login ID" +

                          '","password": "' + Store."Hostbook Password" +// Store."Hostbook Password" +

                          '","compid": "' + Store."Company ID" + //Store."Hostbook ConnectorID" +

                          '","gstin": "' + Store."GST Registration No." +

                           '","useraccno": "' + '' + '"}';

            MESSAGE(JSONReq);
            //  URL := 'https://gstapihb.hostbooks.com/dec/api/Login/signin';
            URL := 'https://eway.hostbooks.com/ewbapp/api/ewb/logintally';
            ////////////////////////
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
                    JSONManagement.InitializeFromString(Resp);
                    userid := JSONManagement.GetValue('userid');
                    buid := JSONManagement.GetValue('buid');
                    gstin := JSONManagement.GetValue('gstinid');
                    token := JSONManagement.GetValue('token');
                    // Message('U%1..B%2..G%3', userid, buid, gstin);
                end;

            end;
            //////////////////////////
            Message('%1.%2', 'gResponseMsg', Resp);

            HostBooksAuthenticateeway(Store, RStore."Hostbook UserAccNo", UserAccNo, 'CtrlID', userid, buid, token, gstin);

            //          END ELSE

            //            ERROR(Resp);

            TokenKey := token;

        END ELSE
            TokenKey := 'Invalid';

        // HostBooksAuthenticateeway(Store, RStore."Hostbook UserAccNo", UserAccNo, 'CtrlID', userid, buid, token, gstin);

    end;

    procedure HostBooksAuthenticateeway(Store: Record Location; UserAccNo: Text; CtrlID: Text; ReqType: Text; userid: Text; buid: Text; token: Text; gstin: Text): Text
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
    ///token: Text;

    begin
        Store.TESTFIELD("Hostbook UserAccNo");
        CLEAR(JSONReq);
        RStore.GET(Store.Code);
        IF JSONReq = '' THEN
            JSONReq := '{"userid":"' + store."HB Account user ID number" +  //'972'
                         '","buid":"' + store."E-Way Bill Business ID" +
                         '","gstinid":"' + store."E-Way Bill Business GSTIN" +
                         '","ewbUserID":"' + Store."Eway Bill API User-ID" +// +
                         '","ewbPassword":"' + Store."Eway bill API password" +// Store."Hostbook Password" +
                           '"}';

        /*
    {

"userid": "4609",

"buid": "8347",

"gstinid": "8678",

"ewbUserID": "API_vijaydairy_HB",

"ewbPassword": "Hostbooks@123"

}

        */
        // Message('%1.%2', 'JOSNREQ', JSONReq);
        //URL := 'https://gstapihb.hostbooks.com/dec/api/Login/authenticate';
        URL := 'https://eway.hostbooks.com/ewbapp/api/ewb/generate-token';
        ClearLastError();
        Clear(gResponseMsg);
        gContent.WriteFrom(JSONReq);
        gContent.GetHeaders(gContentHeaders);
        gContentHeaders.Clear();
        gContentHeaders.Add('Content-Type', 'application/json');
        gContentHeaders.Add('Secret-Key', 'ns4LxrMhWncg1W1ajKKJhRJFQIqzmgGEzXSGsWtVImjO ww1BLztUZJyYW5e/WE6iKCZwL4wvPE/g6vxlrFvZ1sLdzf knJmQe5ByYQ2+Uge8iJ4j1LcWT6ZamL+OFquOEJvSm6v WoeLKJ9c+noizErkQwJhO2OUAj5n1F+uCSOBU=');
        gHttpClient.DefaultRequestHeaders.add('Authorization', 'Bearer ' + token);
        //  gHttpRequestMsg.Content := gContent;
        //   gHttpRequestMsg.Method('POST');
        if gHttpClient.Post(URL, gContent, gHttpResponseMsg) then begin
            gHttpResponseMsg.Content.ReadAs(gResponseMsg);
            if gHttpResponseMsg.IsSuccessStatusCode then begin
                Resp := gResponseMsg;
            end;
        end;
        Message('%1Login :', Resp);
    end;

    procedure GetAuthTokenEWAY(Store: Record Location; "Key": Text; Token: Text): Boolean

    var

        JSONReq: Text;
        MyFile: File;
        Resp: Text;
        RStore: Record Location;
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
        api_url := StrSubstNo('https://gst.hostbooks.in/ewbapi/api/ewb/generate-bill');

        // api_url := StrSubstNo('https://gstapihb.hostbooks.com/dec/api/Einvoice/GetAuthToken?gstin=' + RStore."LSCIN GST Registration No");

        http_Client.DefaultRequestHeaders.add('Secret-Key', Key);
        http_Client.DefaultRequestHeaders.Add('Authorization', 'Bearer ' + token);
        http_Client.get(api_url, http_Response);
        IF http_Response.IsSuccessStatusCode then;
        http_Response.Content.ReadAs(Resp);
        //   MESSAGE('Token Auth Res :' + Resp);
        IF STRPOS(Resp, '"txnOutcome":" Success"') <> 0 THEN BEGIN
            EXIT(TRUE);
        END ELSE
            ERROR('Token Auth Res : ' + Resp);
        EXIT(FALSE);
    end;

    local procedure CheckInvoiceStatus(TransferHeader: Record "Transfer Shipment Header")
    var
        EinvoiceETransLog: Record "E-Invoice Log Entry";
        Customer: Record Customer;
    begin
        EinvoiceETransLog.RESET;
        EinvoiceETransLog.SETRANGE("Order No.", TransferHeader."No.");
        EinvoiceETransLog.SETRANGE("Invoice No.", TransferHeader."No.");
        EinvoiceETransLog.SETRANGE("Request Validated", TRUE);
        IF EinvoiceETransLog.FINDFIRST THEN
            ERROR('Einvoice already generated for this invoice,Please Take Invoice Print \\ IRN : %1 \\Invoice No. : %2', EinvoiceETransLog."IRN No.", TransferHeader."No.")
        ELSE
            EXIT;

    end;

    local procedure GSTDetails(TransferLine: Record "Transfer Shipment Line"; ItemCode: Code[20]; GSTComponent: Code[10]; RecLineNo: Integer; TransferHeader: Record "Transfer Shipment Header") ReturnValue: Text
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
    begin
        CLEAR(ReturnValue);
        DetailedGSTLedgerEntry.RESET;
        DetailedGSTLedgerEntry.SETCURRENTKEY("Entry No.");
        DetailedGSTLedgerEntry.SETRANGE("Document No.", TransferHeader."No.");
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", GSTComponent);
        DetailedGSTLedgerEntry.SETRANGE("No.", TransferLine."Item No.");
        DetailedGSTLedgerEntry.SETRANGE("Document Line No.", RecLineNo);
        IF DetailedGSTLedgerEntry.FINDFIRST THEN
            ReturnValue := DELCHR(FORMAT(DetailedGSTLedgerEntry."GST %"), '=', ',')
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
        DetailedGSTLedgerEntry.SETRANGE("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Sales);
        DetailedGSTLedgerEntry.SETRANGE("Document Type", DetailedGSTLedgerEntry."Document Type"::Invoice);
        DetailedGSTLedgerEntry.SETRANGE("Document No.", THdr."No.");
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", GSTComponent);
        IF DetailedGSTLedgerEntry.FINDSET THEN BEGIN
            REPEAT
                TotalGST += DetailedGSTLedgerEntry."GST Amount";
            UNTIL DetailedGSTLedgerEntry.NEXT = 0;
            ReturnValue := DELCHR(FORMAT(Round(TotalGST * -1)), '=', ',');
            EXIT(ReturnValue);
        END ELSE
            ReturnValue := '0';

    end;
    /////////////////////////////////////////////////////////////////////////

    procedure EwayGetItemDetails(TransferHeader: Record "Transfer Shipment Header"): Text

    var

        TransferLine: Record "Transfer Shipment Line";
        ItemJson: Text;
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        UnitofMeasure: Record "Unit of Measure";
        GSTRate: Text;
        GSTGroupCode: Record "GST Group";//PT-FBTs
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
        // TransferLine.SETRANGE("Transfer-from Code", TransferHeader."Transfer-from Code");
        //  TransferLine.SetFilter("Unit Price", '<>%1|<>%2', 0.001, 0);
        TransferLine.SetFilter("HSN/SAC Code", '<>%1', '');
        TransferLine.SetFilter("Item No.", '<>%1', '');
        IF TransferLine.FINDSET THEN
            REPEAT
                IF UnitofMeasure.GET(TransferLine."Unit of Measure Code") THEN;
                IsService := 'Y';
                // ELSE
                // IsService:='Y';
                IF TransferLine."HSN/SAC Code" = '996331' THEN
                    IsService := 'Y';
                RItem.GET(TransferLine."Item No.");
                //IF STRLEN(TransferLine."HSN/SAC Code") < 4 THEN //Temp Comment
                HSN := RItem."HSN/SAC Code";
                if GSTGroupCode.Get(TransferLine."GST Group Code") then
                    GSTRate := Format(GSTGroupCode."GST Rate");
                //Temp to clear pending invoices
                //HSN:='11021000';
                //ELSE //Temp Comment
                // HSN:=TransferLine."HSN/SAC Code";
                IF STRLEN(FORMAT(TransferLine."Line No.")) > 6 THEN
                    SLNo := TransferLine."Line No." / 1000
                ELSE
                    SLNo := TransferLine."Line No.";
                CessRate := '0';

                IF ItemJson = '' THEN
                    ItemJson := '{"itemNo":"' + TransferLine."Item No." +

                              '","productName":"' + TransferLine.Description +

                              '","productDesc":"' + TransferLine.Description +

                              '","hsnCode":"' + HSN +

                              '","quantity":"' + DELCHR(FORMAT(Round(TransferLine.Quantity)), '=', ',') +

                              '","qtyUnit": "' + FORMAT(UnitofMeasure."E UOM") +

                              '","taxableAmount":"' + DELCHR(FORMAT(Round(TransferLine."Amount")), '=', ',') +

                              '","GstRt":"' + FORMAT(GSTRate) +

                              '","sgstRate":"' + GSTDetails(TransferLine, TransferLine."Item No.", 'SGST', TransferLine."Line No.", TransferHeader) +

                              '","cgstRate":"' + GSTDetails(TransferLine, TransferLine."Item No.", 'CGST', TransferLine."Line No.", TransferHeader) +

                              '","igstRate":"' + GSTDetails(TransferLine, TransferLine."Item No.", 'IGST', TransferLine."Line No.", TransferHeader) +

                               '","cessRate":"' + CessRate + '","cessNonAdvol": "0.00"}'

                ELSE
                    ItemJson += ',{"itemNo":"' + TransferLine."Item No." +

                              '","productName":"' + TransferLine.Description +

                              '","productDesc":"' + TransferLine.Description +

                              '","hsnCode":"' + HSN +

                              '","quantity":"' + DELCHR(FORMAT(Round(TransferLine.Quantity)), '=', ',') +

                              '","qtyUnit": "' + FORMAT(UnitofMeasure."E UOM") +

                              '","taxableAmount":"' + DELCHR(FORMAT(Round(TransferLine."Amount")), '=', ',') +
                                   //TransferLine."GST Base Amount"  Ashish
                                   '","GstRt":"' + FORMAT(GSTRate) +
                              '","sgstRate":"' + GSTDetails(TransferLine, TransferLine."Item No.", 'SGST', TransferLine."Line No.", TransferHeader) +

                               '","cgstRate":"' + GSTDetails(TransferLine, TransferLine."Item No.", 'CGST', TransferLine."Line No.", TransferHeader) +

                               '","igstRate":"' + GSTDetails(TransferLine, TransferLine."Item No.", 'IGST', TransferLine."Line No.", TransferHeader) +

                                '","cessRate":"' + CessRate + '","cessNonAdvol": "0.00"}';
            UNTIL TransferLine.NEXT = 0;
        EXIT(ItemJson);
    end;

    local procedure GetLineAmount(TransferHeader: Record "Transfer Shipment Header"; AmountReq: Option Amount,AmountIncGST): Decimal
    var
        TransferLine: Record "Transfer Shipment Line";
        TotalAmt: Decimal;
        TotalGSTAmt: Decimal;
        TotalAmounttoCustomer: Decimal;
    begin
        CLEAR(TotalAmt);
        CLEAR(TotalAmounttoCustomer);
        TransferLine.RESET;
        TransferLine.SETRANGE("Document No.", TransferHeader."No.");
        TransferLine.SETRANGE("Transfer-from Code", TransferHeader."Transfer-from Code");
        IF TransferLine.FINDSET THEN
            REPEAT
                TotalAmt += 0; //Ashish TransferLine."GST Base Amount";
                TotalAmounttoCustomer += 0; //Ashish TransferLine."GST Base Amount" + TransferLine."Total GST Amount";
            UNTIL TransferLine.NEXT = 0;
        IF AmountReq = AmountReq::Amount THEN
            EXIT(ROUND(TotalAmt, 0.01))
        ELSE
            EXIT(ROUND(TotalAmounttoCustomer, 0.01));
    end;

    procedure APILog(RequestJSON: Text; ResponseJSON: Text; LogFileName: Text)

    var

        FileManagement: Codeunit "File Management";
        FileName: Text;
        MyFile: File;
        RetailSetup: Record "LSC Retail Setup";
    begin
    end;

    procedure EwayGenerateIRNNumber(TH: Record "Transfer Shipment Header");// Token: Text)
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
        ewayno: Code[40];
        subType: Code[10];
        docType: Text;
    begin
        CLEAR(JSON1);
        Clear(subType);
        Clear(docType);
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
        State.SETRANGE(Code, SellerStore."State Code");
        IF State.FINDFIRST THEN
            // StoreStateCode := State."State Code for eTDS/TCS";
            StoreStateCode := State."State Code (GST Reg. No.)";
        BuyerStore.GET(TH."Transfer-to Code");
        State.RESET;
        State.SETRANGE(Code, BuyerStore."State Code");
        IF State.FINDFIRST THEN
            CustomerStateCode := State."State Code (GST Reg. No.)";
        ///////////////////////////////////////
        if CustomerStateCode = StoreStateCode then begin
            subType := '5';
            docType := 'CHL'
        end
        else begin
            subType := '1';
            docType := 'INV';
        end;
        /////////////////////////////////////
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
                              '","supplyType": "' + 'O' +
                              '","subSupplyType": "' + subType +
                              '","subSupplyDesc":"' +
                              '","docType": "' + docType +
                            '","docNo": "' + TH."No." +
                          //    '","supplyType": "O","subSupplyType": "5","subSupplyDesc":""' +

                          //     ',"docType": "CHL","docNo": "' + TH."No." +
                          '","docDate": "' + FORMAT(TH."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>') +
                          '","fromGstin": "' + SellerStore."GST Registration No." +
                          '","fromTrdName": "' + SellerStore.Name +
                          '","fromAddr1": "' + SellerStore.Address +
                          '","fromAddr2": "' + SellerStore."Address 2" +
                          '","fromPlace": "' + SellerStore.City +
                          '","fromPincode": "' + SellerStore."Post Code" +
                          '","fromStateCode": "' + StoreStateCode +
                          '","actFromStateCode": "' + StoreStateCode +
                          '","toGstin": "' + BuyerStore."GST Registration No." +
                           '","toTrdName": "' + BuyerStore.Name +
                          '","toAddr1": "' + BuyerStore.Address +
                          '","toAddr2": "' + BuyerStore."Address 2" +
                          '", "toPlace": "' + BuyerStore.City +
                          '","toPincode": "' + BuyerStore."Post Code" +
                          '","toStateCode": "' + CustomerStateCode +
                          '","actToStateCode": "' + CustomerStateCode +
                          '","totalValue": "' + DELCHR(FORMAT(Round(GetLineAmount(TH, AmountReq::Amount))), '=', ',') +
                          '","cgstValue": "' + GetTotalGSTDetails(TH, '', 'CGST') +
                          '","sgstValue": "' + GetTotalGSTDetails(TH, '', 'SGST') +
                          '","igstValue": "' + GetTotalGSTDetails(TH, '', 'IGST') +
                          '","cessValue": "' + CessTotalAmt +
                          '","transMode": "1"' +
                          ',"transDistance": "' + FORMAT(ROUND(TH."Distance (Km)", 1)) +
                          '","transporterName": ""' +
                          ',"transporterId": "' +
                          '","transDocNo": "' + TH."LR/RR No." +
                          '","transDocDate": "' + FORMAT(TH."LR/RR Date", 0, '<Day,2>/<Month,2>/<Year4>') +
                          '","vehicleNo": "' + TH."Vehicle No." +
                          '","vehicleType": "R"' +
                          ',"transactionType": "1"' +
                          ',"totInvValue": "' + DELCHR(FORMAT(Round(GetLineAmount(TH, AmountReq::AmountIncGST))), '=', ',') + '"' +
                         // '","mainHsnCode": "8528"'+
                         //',"otherValue": "0.00","cessNonAdvolValue": "0.00","transactionType": "1",'+
                         ',"itemList": [' + ItemDetails + ']}';
        Message('%1', JSON1);
        Clear(Store);
        IF Store.Get(TH."Transfer-from Code") then;
        CLEAR(RespKeyToken);
        RespKeyToken := HostbookLoginEWAYBill(Store);
        // URL := 'https://gstapihb.hostbooks.com/dec/api/Einvoice/GenerateEwayBill';
        URL := 'https://eway.hostbooks.com/ewbapp/api/ewb/generate-bill';
        ClearLastError();
        Clear(gResponseMsg);
        gContent.GetHeaders(gContentHeaders);
        gContent.WriteFrom(JSON1);
        //Message(JSON1);
        gContentHeaders.Remove('Content-Type');
        gContentHeaders.Add('Content-Type', 'application/json');
        //gContentHeaders.Add('Secret-Key', JKey);
        gContentHeaders.Add('Secret-Key', 'ns4LxrMhWncg1W1ajKKJhRJFQIqzmgGEzXSGsWtVImjOww1BLztUZJyYW5e/WE6iKCZwL4wvPE/g6vxlrFvZ1sLdzfknJmQe5ByYQ2+Uge8iJ4j1LcWT6ZamL+OFquOEJvSm6vWoeLKJ9c+noizErkQwJhO2OUAj5n1F+uCSOBU=');
        gHttpClient.DefaultRequestHeaders.add('Authorization', 'Bearer ' + RespKeyToken);
        gHttpRequestMsg.Content := gContent;
        gHttpRequestMsg.Method('POST');
        if gHttpClient.Post(URL, gContent, gHttpResponseMsg) then begin
            gHttpResponseMsg.Content.ReadAs(gResponseMsg);
            Resp := gResponseMsg;
        end;

        MESSAGE(Resp);
        JSONManagement.InitializeFromString(Resp);

        ewayno := JSONManagement.GetValue('ewayBillNo');
        Message('%1 %2', 'EWAYBILL NO', ewayno);

        if (ewayno <> '') then begin
            TH."E-Way Bill No." := ewayno;
            // COPYSTR(Resp, STRPOS(Resp, '"ewayBillNo":"') + 14, 12);
            TH.MODIFY;
            EInvoiceLog(TH, Resp);
        end;
        // END ELSE
        //  ERROR(Resp);

    end;

    procedure EwayGenerateCancel(TH: Record "Transfer Shipment Header");// Token: Text)
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
        Response22: Text;
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
        ewayno: Code[40];
        subType: Code[10];
        docType: Text;
    begin

        // JSON1 := '{"buid": "' + '1148' +//SellerStore."GST Registration No." +
        //                   '","userid": "' + '972' +
        //                   '",""gstinid": "' + '1427' +
        //                   '","invNumber":"' + TH."No." +
        //                   '",""ewbNo": "' + TH."E-Way Bill No." +
        //                 '","cancelRsnCode": "' + '3' +
        //                  '","cancelRsnCode": "' + 'invalid input' +
        //             //    '","supplyType": "O","subSupplyType": "5","subSupplyDesc":""' +
        //             //     ',"docType": "CHL","docNo": "' + TH."No." +
        //             '"}';
        JSON1 := '{"buid":"' + '1148' + '"' +
       ',"userid":"' + '972' + '"' +
       ',"gstinid":"' + '1427' + '"' +
       ',"invNumber":"' + TH."No." + '"' +
        ',"ewbNo":"' + TH."E-Way Bill No." + '"' +
       ',"cancelRsnCode":"' + '3' + '"' +
        ',"cancelRmrk":"' + Format('Cancelled the order') + '"}';
        Message('%1', JSON1);
        Clear(Store);
        IF Store.Get(TH."Transfer-from Code") then;
        CLEAR(RespKeyToken);
        RespKeyToken := HostbookLoginEWAYBill(Store);
        // URL := 'https://gstapihb.hostbooks.com/dec/api/Einvoice/GenerateEwayBill';
        URL := 'https://eway.hostbooks.com/ewbapp/api/ewb/cancel-ewb-tally';
        ClearLastError();
        Clear(gResponseMsg);
        gContent.GetHeaders(gContentHeaders);
        gContent.WriteFrom(JSON1);
        //Message(JSON1);
        gContentHeaders.Remove('Content-Type');
        gContentHeaders.Add('Content-Type', 'application/json');
        //gContentHeaders.Add('Secret-Key', JKey);
        gContentHeaders.Add('Secret-Key', 'ns4LxrMhWncg1W1ajKKJhRJFQIqzmgGEzXSGsWtVImjOww1BLztUZJyYW5e/WE6iKCZwL4wvPE/g6vxlrFvZ1sLdzfknJmQe5ByYQ2+Uge8iJ4j1LcWT6ZamL+OFquOEJvSm6vWoeLKJ9c+noizErkQwJhO2OUAj5n1F+uCSOBU=');
        gHttpClient.DefaultRequestHeaders.add('Authorization', 'Bearer ' + RespKeyToken);
        gHttpRequestMsg.Content := gContent;
        gHttpRequestMsg.Method('POST');
        if gHttpClient.Post(URL, gContent, gHttpResponseMsg) then begin
            gHttpResponseMsg.Content.ReadAs(gResponseMsg);
            Resp := gResponseMsg;
        end;
        MESSAGE(Resp);
        IF STRPOS(Resp, '"txnOutcome":" Success."') <> 0 THEN BEGIN
            EInvoiceLogCancel(TH, Resp);
            JSONManagement.InitializeFromString(Resp);
            ewayno := JSONManagement.GetValue('ewayBillNo');
            MESSAGE('E-waybill Successfully Cencel');
        End;
        //TH.Validate("CancelE-Way Bill No.", ewayno);
        TH.Modify();
        // JSONManagement.InitializeFromString(Resp);
        // ewayno := JSONManagement.GetValue('ewayBillNo');
        // MESSAGE('E-waybill Successfully Cencel');
        // if (ewayno <> '') then begin
        //     TH."E-Way Bill No." := ewayno;
        // COPYSTR(Resp, STRPOS(Resp, '"ewayBillNo":"') + 14, 12);
        //TH.MODIFY;
        //  end;
        // END ELSE
        //  ERROR(Resp);

    end;

    local procedure ClearVariable()

    begin

        Clear(HttpHeaders);

        Clear(HttpClient);

        Clear(Httpcontent);

        Clear(HttpResponseMessage);

        Clear(ResponseText);

        Clear(JSONManagement);

    end;

    local procedure EInvoiceLog(TransferHeader: Record "Transfer Shipment Header"; Response: Text)
    var
        EinvoiceETransLog: Record "E-Waybill Log Entry";
        jsonmangment: Codeunit "JSON Management";
        respobj: Text;
        irp_no: Code[10];
        AckNo: Code[20];
        ewayno: Code[20];
    begin
        // EinvoiceETransLog.RESET;
        // EinvoiceETransLog.SETRANGE("Invoice No.", TransferHeader."No.");
        // EinvoiceETransLog.SETRANGE("Request Validated", TRUE);
        // IF EinvoiceETransLog.FINDFIRST THEN BEGIN
        JSONManagement.InitializeFromString(Response);
        ewayno := JSONManagement.GetValue('ewayBillNo');
        EinvoiceETransLog.INIT;
        EinvoiceETransLog."Entry No." := EinvoiceETransLog."Entry No.";
        EinvoiceETransLog."Request Type" := EinvoiceETransLog."Request Type"::"E-Waybill";
        EinvoiceETransLog."Order No." := TransferHeader."Transfer Order No.";
        EinvoiceETransLog."Invoice No." := TransferHeader."No.";
        EinvoiceETransLog."E-waybillDate" := CURRENTDATETIME;
        EinvoiceETransLog."E-Waybill No." := TransferHeader."E-Way Bill No.";

        EinvoiceETransLog.INSERT;

        COMMIT;
        // END;
        // TransferHeader."IRN Hash" := COPYSTR(Response, STRPOS(Response, '"irn"') + 7, 64);
        // jsonmangment.InitializeFromString(Response);
        // respobj := jsonmangment.GetValue('respObj');
        // jsonmangment.InitializeFromString(respobj);
        // irp_no := jsonmangment.GetValue('irp');
        //jsonmangment.InitializeFromString(respobj);
        //AckNo := jsonmangment.GetValue('AckNo');
        //TransferHeader.IRNvALUE := irp_no;
        //TransferHeader."Acknowledgement No." := AckNo;
        // jsonmangment.InitializeFromString(Response);
        // irp_no := jsonmangment.GetValue('irp');
        // TransferHeader.IRNvALUE := irp_no;
        //TransferHeader.tra := TRUE;
        TransferHeader.MODIFY;
    end;

    local procedure EInvoiceLogCancel(TransferHeader: Record "Transfer Shipment Header"; Response: Text)
    var
        EinvoiceETransLog: Record "E-Waybill Log Entry";
        jsonmangment: Codeunit "JSON Management";
        respobj: Text;
        irp_no: Code[10];
        AckNo: Code[20];
    begin
        // EinvoiceETransLog.RESET;
        // EinvoiceETransLog.SETRANGE("Invoice No.", TransferHeader."No.");
        // EinvoiceETransLog.SETRANGE("Request Validated", TRUE);
        // IF EinvoiceETransLog.FINDFIRST THEN BEGIN
        EinvoiceETransLog.INIT;
        EinvoiceETransLog."Entry No." := EinvoiceETransLog."Entry No.";
        EinvoiceETransLog."Request Type" := EinvoiceETransLog."Request Type"::"CancelE-Waybill";
        EinvoiceETransLog."Cancel E-way" := true;
        EinvoiceETransLog."Order No." := TransferHeader."Transfer Order No.";
        EinvoiceETransLog."Invoice No." := TransferHeader."No.";
        EinvoiceETransLog."E-waybillDate" := CURRENTDATETIME;
        EinvoiceETransLog."E-Waybill No." := TransferHeader."E-Way Bill No.";
        EinvoiceETransLog.INSERT;
        // COMMIT;
        // END;
        // TransferHeader."IRN Hash" := COPYSTR(Response, STRPOS(Response, '"irn"') + 7, 64);
        // jsonmangment.InitializeFromString(Response);
        // respobj := jsonmangment.GetValue('respObj');
        // jsonmangment.InitializeFromString(respobj);
        // irp_no := jsonmangment.GetValue('irp');
        //jsonmangment.InitializeFromString(respobj);
        //AckNo := jsonmangment.GetValue('AckNo');
        //TransferHeader.IRNvALUE := irp_no;
        //TransferHeader."Acknowledgement No." := AckNo;
        // jsonmangment.InitializeFromString(Response);
        // irp_no := jsonmangment.GetValue('irp');
        // TransferHeader.IRNvALUE := irp_no;
        //TransferHeader.tra := TRUE;
        TransferHeader.MODIFY;
    end;

    var
        myInt: Integer;
        hbToken: Text;
        hbKey: Text;
        RespKeyToken: Text;
        TokentrimTo: Integer;
        TokentrimFrom: Integer;

        KeytrimFrom: Integer;

        KeytrimTo: Integer;

        HttpHeaders: HttpHeaders;

        HttpClient: HttpClient;

        Httpcontent: HttpContent;

        HttpResponseMessage: HttpResponseMessage;

        ResponseText: Text[30000];

        jsonerrors: text[2000];

        JSONManagement: Codeunit "JSON Management";
}