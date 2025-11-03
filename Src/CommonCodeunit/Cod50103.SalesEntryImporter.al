codeunit 50103 SalesEntryImporter
{
    Subtype = Normal;

    procedure GetAndStoreSalesEntryData(DateColumn: Date; StoreNo: Code[20])
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        RequestUri: Text;
        JsonResponse: Text;
        token: JsonToken;
        JsonArray: JsonArray;
        JsonObject: JsonObject;
        CustomTableRec: Record "Transaction Summary";
        SalesQty: Decimal;
        Count: Integer;
        FormattedDate: Text;
        CompanyInfo: Record "Company Information";
        Headers: HttpHeaders;
        Username: Text;
        Password: Text;
        AuthHeader: Text;
        jsonorder: JsonObject;
        tokenline: JsonToken;
        EntryNo: Integer;
        TransAllSummary: Codeunit "Transaction Sales Summary";
        FilterConditions: Text;
        Store: Record "LSC Store";
        ItemNo: Code[20];
        transSummary: Record "Transaction Summary";
    begin
        transSummary.DeleteAll();
        if store.Get(StoreNo) then;
        // Add Authorization header
        Headers := Client.DefaultRequestHeaders();
        Headers.Clear();
        Headers.Add('Authorization', Store."Authentication");
        Headers.Add('Accept', 'application/json');

        CompanyInfo.Get();

        // Build dynamic OData filter
        FilterConditions := '';
        FilterConditions += 'DateColumn eq ' + Format(Today, 0, '<Year4>-<Month,2>-<Day,2>');

        if StoreNo <> '' then begin
            if FilterConditions <> '' then
                FilterConditions += ' and ';
            FilterConditions += 'StoreNo eq ''' + StoreNo + '''';
        end;

        if FilterConditions <> '' then
            FilterConditions := '?$filter=' + FilterConditions;

        RequestUri :=
            Store."TransSalesEntry URL" + FilterConditions;

        // Make the request
        if not Client.Get(RequestUri, Response) then
            Error('Failed to send GET request to Store server.');

        if not Response.IsSuccessStatusCode() then begin
            Response.Content.ReadAs(JsonResponse);
            Error('GET failed. Status: %1, Response: %2', Response.HttpStatusCode(), JsonResponse);
        end;

        // Parse response
        Response.Content.ReadAs(JsonResponse);
        if not token.ReadFrom(JsonResponse) then
            Error('Failed to parse JSON.');


        JsonObject := token.AsObject();
        JsonObject.Get('value', tokenline);
        JsonArray := tokenline.AsArray();

        // Message('%1', JsonArray);


        foreach tokenline in JsonArray do begin
            JsonObject := tokenline.AsObject();

            if JsonObject.Get('DateColumn', tokenline) then
                DateColumn := tokenline.AsValue().AsDate();

            if JsonObject.Get('StoreNo', tokenline) then
                StoreNo := tokenline.AsValue().AsText();

            if JsonObject.Get('ItemNo', tokenline) then
                ItemNo := tokenline.AsValue().AsText();

            if JsonObject.Get('Quantity', tokenline) then
                SalesQty := tokenline.AsValue().AsDecimal();

            TransAllSummary.InsertOrUpdateTransactionSummary(DateColumn, StoreNo, ItemNo, SalesQty, 0);

        end;


    end;

    // procedure GetAndStoreSalesEntryHOData(DateColumn: Date; StoreNo: Code[20])
    // var
    //     Client: HttpClient;
    //     Response: HttpResponseMessage;
    //     RequestUri: Text;
    //     JsonResponse: Text;
    //     token: JsonToken;
    //     JsonArray: JsonArray;
    //     JsonObject: JsonObject;
    //     CustomTableRec: Record "Transaction Summary";
    //     SalesQtyHO: Decimal;
    //     Count: Integer;
    //     FormattedDate: Text;
    //     CompanyInfo: Record "Company Information";
    //     Headers: HttpHeaders;
    //     Username: Text;
    //     Password: Text;
    //     AuthHeader: Text;
    //     jsonorder: JsonObject;
    //     tokenline: JsonToken;
    //     EntryNo: Integer;
    //     TransAllSummary: Codeunit "Transaction Sales Summary";
    //     FilterConditions: Text;
    //     HoStore: Record "LSC Store";
    //     ItemNo: Code[20];
    // begin
    //     HoStore.Get('S014');//FIX for HO Store

    //     // Add Authorization header
    //     Headers := Client.DefaultRequestHeaders();
    //     Headers.Clear();
    //     Headers.Add('Authorization', HoStore.Authentication);
    //     Headers.Add('Accept', 'application/json');

    //     CompanyInfo.Get();

    //     // Build dynamic OData filter
    //     FilterConditions := '';
    //     FilterConditions += 'DateColumn eq ' + Format(DateColumn, 0, '<Year4>-<Month,2>-<Day,2>');

    //     if StoreNo <> '' then begin
    //         if FilterConditions <> '' then
    //             FilterConditions += ' and ';
    //         FilterConditions += 'StoreNo eq ''' + StoreNo + '''';
    //     end;

    //     if FilterConditions <> '' then
    //         FilterConditions := '?$filter=' + FilterConditions;

    //     // Final URI
    //     RequestUri := HoStore."TransSalesEntry URL" + FilterConditions;
    //     // 'http://192.168.0.188:7048/OmSweetsUAT/ODataV4/Company(''' + CompanyInfo.Name + ''')/TransSalesSummaryAPI' +
    //     // FilterConditions;



    //     // Make the request
    //     if not Client.Get(RequestUri, Response) then
    //         Error('Failed to send GET request to Store server.');

    //     if not Response.IsSuccessStatusCode() then begin
    //         Response.Content.ReadAs(JsonResponse);
    //         Error('GET failed. Status: %1, Response: %2', Response.HttpStatusCode(), JsonResponse);
    //     end;

    //     // Parse response
    //     Response.Content.ReadAs(JsonResponse);
    //     if not token.ReadFrom(JsonResponse) then
    //         Error('Failed to parse JSON.');


    //     JsonObject := token.AsObject();
    //     JsonObject.Get('value', tokenline);
    //     JsonArray := tokenline.AsArray();

    //     Message('%1', JsonArray);
    //     // if JsonObject.Get('value', JsonObject)

    //     //     if JsonObject.Get('value', token) then;
    //     // JsonArray := token.AsArray();


    //     foreach tokenline in JsonArray do begin
    //         JsonObject := tokenline.AsObject();

    //         if JsonObject.Get('StoreNo', tokenline) then
    //             StoreNo := tokenline.AsValue().AsText();

    //         if JsonObject.Get('DateColumn', tokenline) then
    //             DateColumn := tokenline.AsValue().AsDate();

    //         if JsonObject.Get('ItemNo', tokenline) then
    //             ItemNo := tokenline.AsValue().AsText();

    //         if JsonObject.Get('Quantity', tokenline) then
    //             SalesQtyHO := tokenline.AsValue().AsDecimal();


    //         TransAllSummary.InsertOrUpdateTransactionSummary(StoreNo, DateColumn, 0, ItemNo, SalesQtyHO);

    //     end;
    // end;

}
