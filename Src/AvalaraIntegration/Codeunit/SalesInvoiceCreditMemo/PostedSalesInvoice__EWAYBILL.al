//This Codeunit Use for Eway Bill for Posted sales innoice 

codeunit 50117 PostdSalesEway
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
            Store.TESTFIELD("Hostbook Login ID");
            Store.TESTFIELD("Hostbook ConnectorID");
            Store.TESTFIELD("Hostbook Password");
            Store.TestField("GST Registration No.");
            // Store.TestField("Hostbook UserAccNo");
            CLEAR(JSONReq);
            RStore.GET(Store.Code);
            IF JSONReq = '' THEN
                JSONReq := '{"loginId": "' + Store."Hostbook Login ID" +
                          '","password": "' + Store."Hostbook Password" +
                          '","compid": "' + Store."Company ID" +
                          '","gstin": "' + Store."GST Registration No." +
                           '","useraccno": "' + Store."Hostbook UserAccNo" + '"}';
            MESSAGE('%1 Josn Req', JSONReq);

            //  URL := 'https://gstapihb.hostbooks.com/dec/api/Login/signin';
            URL := 'https://eway.hostbooks.com/ewbapp/api/ewb/logintally';
            //URL := 'https://gst.hostbooks.in/ewbapi/api/ewb/logintally';
            //URL := 'https://eway.hostbooks.com/ewbapp/api/ewb/logintally';
            ClearLastError();
            Clear(gResponseMsg);
            gContent.WriteFrom(JSONReq);
            gContent.GetHeaders(gContentHeaders);
            gContentHeaders.Clear();
            gContentHeaders.Add('Content-Type', 'application/json');
            gContentHeaders.Add('Secret-Key', 'ns4LxrMhWncg1W1ajKKJhRJFQIqzmgGEzXSGsWtVImjOww1BLztUZJyYW5e/WE6iKCZwL4wvPE/g6vxlrFvZ1sLdzfknJmQe5ByYQ2+Uge8iJ4j1LcWT6ZamL+OFquOEJvSm6vWoeLKJ9c+noizErkQwJhO2OUAj5n1F+uCSOBU=');
            if gHttpClient.Post(URL, gContent, gHttpResponseMsg) then begin
                gHttpResponseMsg.Content.ReadAs(gResponseMsg);
                if gHttpResponseMsg.IsSuccessStatusCode then begin
                    //Message('Response %1', gResponseMsg);
                    Resp := gResponseMsg;
                    Message('%1..Gresp', gResponseMsg);
                end;
            end;
            // Message('%1.%2', 'gResponseMsg', gResponseMsg);
            JSONManagement.InitializeFromString(gResponseMsg);
            userid := JSONManagement.GetValue('userid');
            buid := JSONManagement.GetValue('buid');
            gstin := JSONManagement.GetValue('gstinid');
            token := JSONManagement.GetValue('token');
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
            JSONReq := '{"userid":"' + '6992' +
                         '","buid":"' + '16538' +
                         '","gstinid":"' + '17912' +
                         '","ewbUserID":"' + Store."Eway Bill API User-ID" +//'hbtest@raJ' +
                         '","ewbPassword":"' + Store."Eway bill API password" + //'Irexx@123' +// 
                           '"}';


        Message('%1.%2', 'JOSNREQ', JSONReq);
        //URL := 'https://gstapihb.hostbooks.com/dec/api/Login/authenticate';
        // URL := 'https://gst.hostbooks.in/ewbapi/api/ewb/generate-token';
        URL := 'https://eway.hostbooks.com/ewbapp/api/ewb/generate-token';
        //  URL := 'https://eway.hostbooks.com/ewbapp/api/ewb/generate-token';
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
                Message('%1 REsp', gResponseMsg);
            end;

        end;
        // Message('%1Login :', gResponseMsg);

    end;

    local procedure CheckInvoiceStatus(SaleInvoiceHeaderRec: Record "Sales Invoice Header")
    var
        EinvoiceETransLog: Record "E-Invoice Log Entry";
        Customer: Record Customer;
    begin
        EinvoiceETransLog.RESET;
        EinvoiceETransLog.SETRANGE("Order No.", SaleInvoiceHeaderRec."No.");
        EinvoiceETransLog.SETRANGE("Invoice No.", SaleInvoiceHeaderRec."No.");
        EinvoiceETransLog.SETRANGE("Request Validated", TRUE);
        IF EinvoiceETransLog.FINDFIRST THEN
            ERROR('Einvoice already generated for this invoice,Please Take Invoice Print \\ IRN : %1 \\Invoice No. : %2', EinvoiceETransLog."IRN No.", SaleInvoiceHeaderRec."No.")
        ELSE
            EXIT;
    end;

    local procedure GSTDetails(SaleInvoiceLine_Rec: Record "Sales Invoice Line"; ItemCode: Code[20]; GSTComponent: Code[10]; RecLineNo: Integer; SaleInvoiceHeaderRec: Record "Sales Invoice Header") ReturnValue: Text
    var
        DetailedGSSalesInvLine_RecedgerEntry: Record "Detailed GST Ledger Entry";
    begin
        CLEAR(ReturnValue);
        DetailedGSSalesInvLine_RecedgerEntry.RESET;
        DetailedGSSalesInvLine_RecedgerEntry.SETCURRENTKEY("Entry No.");
        DetailedGSSalesInvLine_RecedgerEntry.SETRANGE("Document No.", SaleInvoiceHeaderRec."No.");
        DetailedGSSalesInvLine_RecedgerEntry.SETRANGE("GST Component Code", GSTComponent);
        DetailedGSSalesInvLine_RecedgerEntry.SETRANGE("No.", SaleInvoiceLine_Rec."No.");
        DetailedGSSalesInvLine_RecedgerEntry.SETRANGE("Document Line No.", RecLineNo);
        IF DetailedGSSalesInvLine_RecedgerEntry.FINDFIRST THEN
            ReturnValue := DELCHR(FORMAT(DetailedGSSalesInvLine_RecedgerEntry."GST Amount" * -1), '=', ',')
        ELSE
            ReturnValue := '0';

        EXIT(ReturnValue);
    end;

    local procedure GetTotalGSTDetails(SaleInvoiceHed_Rec: Record "Sales Invoice Header"; ItemCode: Code[20]; GSTComponent: Code[10]) ReturnValue: Text
    var
        DetailedGSSalesInvLine_RecedgerEntry: Record "Detailed GST Ledger Entry";
        TotalGST: Decimal;
    begin
        CLEAR(ReturnValue);
        CLEAR(TotalGST);
        DetailedGSSalesInvLine_RecedgerEntry.RESET;
        DetailedGSSalesInvLine_RecedgerEntry.SETCURRENTKEY("Transaction Type", "Document Type", "Document No.", "Document Line No.");
        DetailedGSSalesInvLine_RecedgerEntry.SETRANGE("Transaction Type", DetailedGSSalesInvLine_RecedgerEntry."Transaction Type"::Sales);
        DetailedGSSalesInvLine_RecedgerEntry.SETRANGE("Document Type", DetailedGSSalesInvLine_RecedgerEntry."Document Type"::Invoice);
        DetailedGSSalesInvLine_RecedgerEntry.SETRANGE("Document No.", SaleInvoiceHed_Rec."No.");
        DetailedGSSalesInvLine_RecedgerEntry.SETRANGE("GST Component Code", GSTComponent);
        IF DetailedGSSalesInvLine_RecedgerEntry.FINDSET THEN BEGIN
            REPEAT
                TotalGST += DetailedGSSalesInvLine_RecedgerEntry."GST Amount";
            UNTIL DetailedGSSalesInvLine_RecedgerEntry.NEXT = 0;

            ReturnValue := DELCHR(FORMAT(TotalGST * -1), '=', ',');
            EXIT(ReturnValue);
        END ELSE
            ReturnValue := '0';
    end;

    procedure EwayGetItemDetails(SaleInvoiceHeaderRec: Record "Sales Invoice Header"): Text
    var
        SaleInvoiceLine_Rec: Record "Sales Invoice Line";
        ItemJson: Text;
        DetailedGSSalesInvLine_RecedgerEntry: Record "Detailed GST Ledger Entry";
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
        Unitofmeasure1: Text;
    begin
        CLEAR(ItemJson);
        CLEAR(GSTRate);
        CLEAR(HSN);
        CLEAR(CessRate);
        CLEAR(CessAmt);
        SaleInvoiceLine_Rec.RESET;
        SaleInvoiceLine_Rec.SETRANGE("Document No.", SaleInvoiceHeaderRec."No.");
        SaleInvoiceLine_Rec.SetRange(Type, SaleInvoiceLine_Rec.Type::Item);
        // SaleInvoiceLine_Rec.SETRANGE("Transfer-from Code", SaleInvoiceHeaderRec."Transfer-from Code");
        IF SaleInvoiceLine_Rec.FINDSET THEN
            REPEAT
                IF UnitofMeasure.GET(SaleInvoiceLine_Rec."Unit of Measure Code") THEN;
                UnitofMeasure.SetRange(Code, SaleInvoiceLine_Rec."Unit of Measure");
                IF UnitofMeasure.FindFirst() then begin
                    Unitofmeasure1 := UnitofMeasure."E UOM";

                end;
                IsService := 'Y';
                // ELSE
                // IsService:='Y';
                IF SaleInvoiceLine_Rec."HSN/SAC Code" = '996331' THEN
                    IsService := 'Y';
                RItem.GET(SaleInvoiceLine_Rec."No.");

                //IF STRLEN(SaleInvoiceLine_Rec."HSN/SAC Code") < 4 THEN //Temp Comment
                HSN := RItem."HSN/SAC Code"; //Temp to clear pending invoices
                                             //HSN:='11021000';
                                             //ELSE //Temp Comment
                                             // HSN:=SaleInvoiceLine_Rec."HSN/SAC Code";

                IF STRLEN(FORMAT(SaleInvoiceLine_Rec."Line No.")) > 6 THEN
                    SLNo := SaleInvoiceLine_Rec."Line No." / 10000
                ELSE
                    SLNo := SaleInvoiceLine_Rec."Line No.";
                CessRate := '0';

                IF ItemJson = '' THEN
                    ItemJson := '{"itemNo":"' + SaleInvoiceLine_Rec."No." +
                              '","productName":"' + SaleInvoiceLine_Rec.Description +
                              '","productDesc":"' + SaleInvoiceLine_Rec.Description +
                              '","hsnCode":"' + HSN +
                              '","quantity":"' + DELCHR(FORMAT(SaleInvoiceLine_Rec.Quantity), '=', ',') +
                              '","qtyUnit": "' + FORMAT(Unitofmeasure1) +
                              '","taxableAmount":"' + DELCHR(FORMAT(SaleInvoiceLine_Rec."Amount"), '=', ',') +
                              '","sgstValue":"' + GSTDetails(SaleInvoiceLine_Rec, SaleInvoiceLine_Rec."No.", 'SGST', SaleInvoiceLine_Rec."Line No.", SaleInvoiceHeaderRec) +

                              '","cgstValue":"' + GSTDetails(SaleInvoiceLine_Rec, SaleInvoiceLine_Rec."No.", 'CGST', SaleInvoiceLine_Rec."Line No.", SaleInvoiceHeaderRec) +
                              '","igstValue":"' + GSTDetails(SaleInvoiceLine_Rec, SaleInvoiceLine_Rec."No.", 'IGST', SaleInvoiceLine_Rec."Line No.", SaleInvoiceHeaderRec) +
                               '","cessValue":"' + CessRate + '","cessNonAdvol": "0.00"}'
                ELSE
                    ItemJson += ',{"itemNo":"' + SaleInvoiceLine_Rec."No." +
                              '","productName":"' + SaleInvoiceLine_Rec.Description +
                              '","productDesc":"' + SaleInvoiceLine_Rec.Description +
                              '","hsnCode":"' + HSN +
                              '","quantity":"' + DELCHR(FORMAT(SaleInvoiceLine_Rec.Quantity), '=', ',') +
                              '","qtyUnit": "' + FORMAT(Unitofmeasure1) +
                              '","taxableAmount":"' + DELCHR(FORMAT(SaleInvoiceLine_Rec."Amount"), '=', ',') +//SaleInvoiceLine_Rec."GST Base Amount"  Ashish
                              '","sgstValue":"' + GSTDetails(SaleInvoiceLine_Rec, SaleInvoiceLine_Rec."No.", 'SGST', SaleInvoiceLine_Rec."Line No.", SaleInvoiceHeaderRec) +
                               '","cgstValue":"' + GSTDetails(SaleInvoiceLine_Rec, SaleInvoiceLine_Rec."No.", 'CGST', SaleInvoiceLine_Rec."Line No.", SaleInvoiceHeaderRec) +
                               '","igstValue":"' + GSTDetails(SaleInvoiceLine_Rec, SaleInvoiceLine_Rec."No.", 'IGST', SaleInvoiceLine_Rec."Line No.", SaleInvoiceHeaderRec) +
                                '","cessValue":"' + CessRate + '","cessNonAdvol": "0.00"}';
            UNTIL SaleInvoiceLine_Rec.NEXT = 0;
        EXIT(ItemJson);
    end;

    local procedure GeSalesInvLine_RecineAmount(SaleInvoiceHeaderRec: Record "Sales Invoice Header"; AmountReq: Option Amount,AmountIncGST): Decimal
    var
        SaleInvoiceLine_Rec: Record "Sales Invoice Line";
        TotalAmt: Decimal;
        TotalGSTAmt: Decimal;
        TotalAmounttoCustomer: Decimal;

    begin
        CLEAR(TotalAmt);
        CLEAR(TotalAmounttoCustomer);
        SaleInvoiceLine_Rec.RESET;
        SaleInvoiceLine_Rec.SETRANGE("Document No.", SaleInvoiceHeaderRec."No.");

        IF SaleInvoiceLine_Rec.FINDSET THEN
            REPEAT

                TotalAmt += SaleInvoiceLine_Rec.Amount;
                TotalAmounttoCustomer += SaleInvoiceLine_Rec."Amount Including VAT";

            UNTIL SaleInvoiceLine_Rec.NEXT = 0;

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

    procedure Generate__EWAY_BILL(SalesInvHeaderRec: Record "Sales Invoice Header");// Token: Text)
    var
        SalesInvLine_Rec: Record "Sales Invoice Line";
        SalesInvHed_Rec: Record "Sales Invoice Header";
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
        ewayDateTime: Text;


    begin
        CLEAR(JSON1);
        CLEAR(BuyerGSTIN);
        CLEAR(CustomerStateCode);
        CLEAR(StoreStateCode);
        CLEAR(QRData);
        CLEAR(BillToPINCODE);
        CLEAR(ShipToPINCODE);
        CLEAR(CessTotalAmt);


        CheckInvoiceStatus(SalesInvHeaderRec);

        CompanyInformation.GET;
        ItemDetails := EwayGetItemDetails(SalesInvHeaderRec);

        SellerStore.GET(SalesInvHeaderRec."Location Code");
        //  Message('%1', SellerStore."LSCIN GST Registration No");
        State.RESET;
        State.SETRANGE(Code, SellerStore."State Code");
        IF State.FINDFIRST THEN
            // StoreStateCode := State."State Code for eTDS/TCS";
            StoreStateCode := State."State Code (GST Reg. No.)";


        BuyerStore.GET(SalesInvHeaderRec."Location Code");
        State.RESET;
        State.SETRANGE(Code, BuyerStore."State Code");
        IF State.FINDFIRST THEN
            CustomerStateCode := State."State Code (GST Reg. No.)";
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

        IF GetTotalGSTDetails(SalesInvHeaderRec, '', 'CESS%') <> '0' THEN
            CessTotalAmt := GetTotalGSTDetails(SalesInvHeaderRec, '', 'CESS%')
        ELSE
            CessTotalAmt := GetTotalGSTDetails(SalesInvHeaderRec, '', 'CESS');

        IF JSON1 = '' THEN
            JSON1 := '{"userGstin": "' + SellerStore."GST Registration No." +
                          '","supplyType": "O","subSupplyType": "5","subSupplyDesc":""' +
                          ',"docType": "CHL","docNo": "' + SalesInvHeaderRec."No." +
                          '","docDate": "' + FORMAT(SalesInvHeaderRec."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>') +
                          '","fromGstin": "' + SellerStore."GST Registration No." +
                          '","fromTrdName": "' + SellerStore.Name +
                          '","fromAddr1": "' + SellerStore.Address +
                          '","fromAddr2": "' + SellerStore."Address 2" +
                          '","fromPlace": "' + SellerStore.City +
                          '","fromPincode": "' + SellerStore."Post Code" +
                          '","fromStateCode": "' + StoreStateCode +
                          '","actFromStateCode": "' + StoreStateCode +
                          '","toGstin": "' + BuyerStore."GST Registration No." + '","toTrdName": "' + SalesInvHeaderRec."Bill-to Name" +
                          '","toAddr1": "' + SalesInvHeaderRec."Bill-to Address" +
                          //   '","toAddr2": "' + BuyerStore."Address 2" +
                          '", "toPlace": "' + SalesInvHeaderRec."Bill-to City" +
                          '","toPincode": "' + SalesInvHeaderRec."Bill-to Post Code" +
                          '","toStateCode": "' + CustomerStateCode +
                          '","actToStateCode": "' + CustomerStateCode +
                          '","totalValue": "' + DELCHR(FORMAT(GeSalesInvLine_RecineAmount(SalesInvHeaderRec, AmountReq::Amount)), '=', ',') +
                          '","cgstValue": "' + GetTotalGSTDetails(SalesInvHeaderRec, '', 'CGST') +
                          '","sgstValue": "' + GetTotalGSTDetails(SalesInvHeaderRec, '', 'SGST') +
                          '","igstValue": "' + GetTotalGSTDetails(SalesInvHeaderRec, '', 'IGST') +
                          '","cessValue": "' + CessTotalAmt +
                          '","transMode": "1"' +
                          ',"transDistance": "' + FORMAT(ROUND(SalesInvHeaderRec."Distance (Km)", 1)) +
                          '","transporterName": ""' +
                          ',"transporterId": "' +
                          '","transDocNo": "' + SalesInvHeaderRec."LR/RR No." +
                          '","transDocDate": "' + FORMAT(SalesInvHeaderRec."LR/RR Date", 0, '<Day,2>/<Month,2>/<Year4>') +
                          '","vehicleNo": "' + SalesInvHeaderRec."Vehicle No." +
                          '","vehicleType": "R"' +
                          ',"transactionType": "1"' +
                          ',"totInvValue": "' + DELCHR(FORMAT(GeSalesInvLine_RecineAmount(SalesInvHeaderRec, AmountReq::AmountIncGST)), '=', ',') + '"' +
                         // '","mainHsnCode": "8528"'+
                         //',"otherValue": "0.00","cessNonAdvolValue": "0.00","transactionType": "1",'+
                         ',"itemList": [' + ItemDetails + ']}';
        Message('%1', JSON1);

        Clear(Store);
        IF Store.Get(SalesInvHeaderRec."Location Code") then;
        Message('%1', Store.Name);
        CLEAR(RespKeyToken);
        RespKeyToken := HostbookLoginEWAYBill(Store);

        // URL := 'https://gstapihb.hostbooks.com/dec/api/Einvoice/GenerateEwayBill';
        // URL := 'https://gst.hostbooks.in/ewbapi/api/ewb/generate-bill';
        // URL := 'https://gst.hostbooks.in/ewbapi/api/ewb/generate-bill';
        URL := 'https://eway.hostbooks.com/ewbapp/api/ewb/generate-bill';
        //  URL := 'https://eway.hostbooks.com/ewbapp/api/ewb/generate-bill';
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
        ewayDateTime := JSONManagement.GetValue('ewayBillDate');
        SalesInvHeaderRec."Eway Bill No." := ewayno;
        Evaluate(SalesInvHeaderRec."Acknowledgement Date", ewayDateTime);
        SalesInvHeaderRec.MODIFY;
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