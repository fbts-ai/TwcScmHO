/*
codeunit 50003 "TransferEwayBillFromIRN"
{
    Permissions = tabledata "Transfer Shipment Header" = rm;

    trigger OnRun()
    begin
        Initialize();


        //RunSalesInvoiceEwayBill();
        PayloadEwayBillFromIRN();
        if DocumentNo <> '' then
            GenerateEwayBillFromIRN(DocumentNo)
        else
            Error(DocumentNoBlankErr);

    end;

    var
        TransferShipmentHeader: Record "Transfer Shipment Header";
        //TempTransferReceipt : Record "Transfer Receipt Header";

        JObject: JsonObject;
        JsonArrayData: JsonArray;
        JsonTDSArrayGlobal: JsonArray;
        JsonTCSArrayGlobal: JsonArray;

        JShippingBillArray: JsonArray;
        JewayBillArray: JsonArray;
        JOriginaldocArray: JsonArray;
        JECommOprMerchantArray: JsonArray;

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
    procedure SetTransferHeader(TransferHeaderBuff: Record "Transfer Shipment Header")
    begin
        TransferShipmentHeader := TransferHeaderBuff;
        IsTransfer := true;
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
        tempTransShipHead: Record "Transfer Shipment Header";
    begin
        tempTransShipHead.Reset();
        tempTransShipHead.SetRange("No.", TransferShipmentHeader."No.");
        IF tempTransShipHead.FindFirst() then;

        tempTransShipHead.TestField("IRN Hash");
        tempTransShipHead.TestField("Shipping Agent Code");

        DocumentNo := TransferShipmentHeader."No.";

        if ShippingAgent.Get(TransferShipmentHeader."Shipping Agent Code") then;

        JObject.Add('Irn', tempTransShipHead."IRN Hash");

        IF tempTransShipHead."Distance (Km)" <> 0 then begin
            dist1 := tempTransShipHead."Distance (Km)";
            Evaluate(dist3, format(dist1));
            JObject.Add('Distance', dist3);
        end
        else
            JObject.Add('Distance', 0);

        JObject.Add('TransMode', tempTransShipHead."Mode of Transport");

        JObject.Add('TransId', ShippingAgent."GST Registration No.");

        JObject.Add('TransName', ShippingAgent.Name);

        JObject.Add('TrnDocNo', tempTransShipHead."No.");
        JObject.Add('TrnDocDt', tempTransShipHead."Posting Date");

        JObject.Add('VehNo', tempTransShipHead."Vehicle No.");

        if tempTransShipHead."Vehicle Type" <> tempTransShipHead."Vehicle Type"::" " then
            if tempTransShipHead."Vehicle Type" = tempTransShipHead."Vehicle Type"::ODC then
                VehType := 'Over Dimensional Cargo'
            else
                VehType := 'Regular'
        else
            VehType := '';

        JObject.Add('VehType', VehType);

    End;


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
        tempTransShipHead: Record "Transfer Shipment Header";
        TempMsg: Text;
        TempGstSetup: Record "GSt Setup";
    begin
        // JsonArrayData.Add(JObject);
        // JsonArrayData.WriteTo(JsonText);
        TempGstSetup.Get();
        TempGstSetup.TestField(TempGstSetup.IRNtoEwayBillApi);
        TempGstSetup.TestField(TempGstSetup.IRNtoEwayBillSecurityToken);
        JObject.WriteTo(JsonText);

        TempBlob.CreateOutStream(OutStream);
        OutStream.WriteText(JsonText);
        ToFile := FileName + '11.json';
        TempBlob.CreateInStream(InStream);
        DownloadFromStream(InStream, 'e-Way', '', '', ToFile);
        Sleep(1000);

        //fe28e9b25dfe9390fb23a5dca981bf6a9f629950da954aa322f490a7dcf244e5
        AccessToken := TempGstSetup.IRNtoEwayBillSecurityToken;
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
        //https://www.sandbox-gstapi.trustfilegst.in/einvoice/api/v1/EInvoice/27AAAPI3182M002/GenerateEwaybillUsingIRN
        request.SetRequestUri(TempGstSetup.IRNtoEwayBillApi);
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
                        tempTransShipHead.Reset();
                        tempTransShipHead.SetRange("No.", TransferShipmentHeader."No.");
                        IF tempTransShipHead.FindFirst() then;
                        // EwayJsonObject := EwayJsonToken.AsObject();                       
                        tempTransShipHead."E-Way Bill No." := JobjToken.AsValue().AsText();
                        tempTransShipHead.Modify(true);

                    End;
                    Message('Eway Bill Updated successfully');
                end;
            end;
        end;
    end;



}
*/