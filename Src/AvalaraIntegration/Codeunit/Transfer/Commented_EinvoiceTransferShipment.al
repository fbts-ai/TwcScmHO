/// <summary>
/// Codeunit EinvoiceTransferShipment (ID 50146).
/// </summary>
/*
codeunit 50002 "EinvoiceTransferShipment"
{
    Permissions = tabledata "Transfer Shipment Header" = rm;


    trigger OnRun()
    begin
        Initialize();

        RunTransferEinvoice();

        if DocumentNo <> '' then begin

            ExportAsJsonInvoice(DocumentNo)

        end
        else
            Error(DocumentNoBlankErr);
    end;

    var
        TransferShipmentHeader: Record "Transfer Shipment Header";
        JObject: JsonObject;
        JsonArrayData: JsonArray;
        JsonText: Text;

        DocumentNo: Text[20];
        RndOffAmt: Decimal;
        IsInvoice: Boolean;
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

    procedure SetTransferShipmentHeader(TransferShipmentHeaderBuff: Record "Transfer Shipment Header")
    begin
        TransferShipmentHeader := TransferShipmentHeaderBuff;
    end;



    procedure GenerateCanceledInvoice()
    begin
        Initialize();


        DocumentNo := TransferShipmentHeader."No.";

    end;



    local procedure GetSalesInvoiceLineForB2CCustomer(DocumentNo: Text[20]; Var CGSTRate: Decimal; Var SGSTRate: Decimal; Var IGSTRate: Decimal; Var TotalGstAmount: Decimal)
    Var
        TransferShipmentLine: Record "Transfer Shipment Line";
        CGSTValue: Decimal;
        SGSTValue: Decimal;
        IGSTValue: Decimal;
    begin
        TransferShipmentLine.SetRange("Document No.", DocumentNo);
        TransferShipmentLine.LoadFields("Line No.");
        if TransferShipmentLine.FindSet() then
            repeat
                GetGSTValueForLine(TransferShipmentLine."Line No.", CGSTValue, SGSTValue, IGSTValue);
                CGSTRate += CGSTValue;
                SGSTRate += SGSTValue;
                IGSTRate += IGSTValue;
                TotalGstAmount += (CGSTValue + SGSTValue + IGSTValue);
            Until TransferShipmentLine.Next() = 0;
    end;

    local procedure GetBankAcUPIDetails(BankCode: Code[20]; Var BankAccNumber: Text[30]; Var IFSCCode: Text[20])
    var
        BankAccount: Record "Bank Account";
    begin
        BankAccount.Get(BankCode);
        BankAccNumber := BankAccount."Bank Account No.";
        IFSCCode := BankAccount."IFSC Code";
    end;

    local procedure GetLocationBankDetails(LocCode: Code[20]) BankCode: Code[20]
    var
        TaxBaseLibrary: Codeunit "Tax Base Library";
        AccountNo: Code[20];
        ForUPIPayments: Boolean;
    begin
        TaxBaseLibrary.GetVoucherAccNo(LocCode, AccountNo, ForUPIPayments);

        if ForUPIPayments then
            BankCode := AccountNo
        else
            Error(B2CUPIPaymentErr);

        exit(BankCode);
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


    local procedure WriteCancelJsonFileHeader()
    begin

        JObject.Add('Version', '1.1');
        JsonArrayData.Add(JObject);
    end;

    local procedure WriteCancellationJSON(IRNHash: Text[64]; CancelReason: Enum "e-Invoice Cancel Reason"; CancelRemark: Text[100])
    var
        CancelJsonObject: JsonObject;
    begin
        WriteCancelJsonFileHeader();
        CancelJsonObject.Add('Canceldtls', '');
        CancelJsonObject.Add('IRN', IRNHash);
        CancelJsonObject.Add('CnlRsn', Format(CancelReason));
        CancelJsonObject.Add('CnlRem', CancelRemark);

        JsonArrayData.Add(CancelJsonObject);
        JObject.Add('ExpDtls', JsonArrayData);
    end;

    local procedure RunTransferEinvoice()
    begin

        /*
                if SalesInvoiceHeader."GST Customer Type" in [
                    SalesInvoiceHeader."GST Customer Type"::Unregistered,
                    SalesInvoiceHeader."GST Customer Type"::" "]
                then
                    Error(eInvoiceNotApplicableCustErr);
        

        DocumentNo := TransferShipmentHeader."No.";
        WriteJsonFileHeader();
        ReadTransactionDetails(TransferShipmentHeader."Transfer-to Code");
        ReadDocumentHeaderDetails();
        ReadDocumentSellerDetails();
        ReadDocumentBuyerDetails();
        ReadDocumentShippingDetails();
        ReadDocumentItemList();
        ReadDocumentTotalDetails();
        ReadEwbDtls();
        ReadExportDetails();
    end;



    local procedure Initialize()
    begin
        Clear(JObject);
        Clear(JsonArrayData);
        Clear(JsonText);
    end;

    local procedure WriteJsonFileHeader()
    begin
        JObject.Add('Generate', true);
        JObject.Add('Version', '1.1');
        JsonArrayData.Add(JObject);
    end;

    local procedure ReadTransactionDetails(ShipToCode: Code[12])
    begin
        Clear(JsonArrayData);

        ReadInvoiceTransactionDetails(ShipToCode)

    end;



    local procedure ReadInvoiceTransactionDetails(ShipToCode: Code[12])
    var
        TransfreShipmentLine: Record "Transfer Shipment Line";
        NatureOfSupplyCategory: Text[7];
        SupplyType: Text[3];
        IgstOnIntra: Text[3];
    begin

        ///Need to check
        //  SalesInvoiceHeader."GST Customer Type"::Registered, SalesInvoiceHeader."GST Customer Type"::Exempted:
        NatureOfSupplyCategory := 'B2B';//need to check




        if ShipToCode <> '' then begin
            /*
            TransfreShipmentLine.SetRange("Document No.", DocumentNo);
            if TransfreShipmentLine.FindSet() then
                repeat
                    if TransfreShipmentLine."GST Place of Supply" <> SalesInvoiceLine."GST Place of Supply"::"Ship-to Address" then
                        SupplyType := 'SHP'
                    else
                        SupplyType := 'REG';
                until SalesInvoiceLine.Next() = 0;
        end else
       
            SupplyType := 'REG';
            /*
              if SalesInvoiceHeader."POS Out Of India" then
                  IgstOnIntra := 'Y'
              else
             
            IgstOnIntra := 'N';

            WriteTransactionDetails(NatureOfSupplyCategory, 'N', '', IgstOnIntra);
        end;
    End;

    local procedure WriteTransactionDetails(
        SupplyCategory: Text[7];
        RegRev: Text[2];
        EcmGstin: Text[15];
        IgstOnIntra: Text[3])
    var
        JTranDetails: JsonObject;
    begin
        JTranDetails.Add('TaxSch', 'GST');
        JTranDetails.Add('SupTyp', SupplyCategory);
        JTranDetails.Add('RegRev', RegRev);

        if EcmGstin <> '' then
            JTranDetails.Add('EcmGstin', EcmGstin);

        JTranDetails.Add('IgstOnIntra', IgstOnIntra);

        JObject.Add('TranDtls', JTranDetails);
    end;

    local procedure ReadDocumentHeaderDetails()
    var
        InvoiceType: Text[3];
        PostingDate: Text[10];
        OriginalInvoiceNo: Text[16];
    begin
        Clear(JsonArrayData);
        /*
        if IsInvoice then begin
            if (TransferShipmentHeader."Invoice Type" = SalesInvoiceHeader."Invoice Type"::"Debit Note") or
               (SalesInvoiceHeader."Invoice Type" = SalesInvoiceHeader."Invoice Type"::Supplementary)
            then
                InvoiceType := 'DBN'
            else
                InvoiceType := 'INV';
            PostingDate := Format(SalesInvoiceHeader."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>');
        end else begin
            InvoiceType := 'CRN';
            PostingDate := Format(SalesCrMemoHeader."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>');
        end;
        

        InvoiceType := 'INV'; //Need to check
        PostingDate := Format(TransferShipmentHeader."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>');


        // OriginalInvoiceNo := CopyStr(GetReferenceInvoiceNo(DocumentNo), 1, 16);
        WriteDocumentHeaderDetails(InvoiceType, CopyStr(DocumentNo, 1, 16), PostingDate, OriginalInvoiceNo);
    end;

    local procedure WriteDocumentHeaderDetails(InvoiceType: Text[3]; DocumentNo: Text[16]; PostingDate: Text[10]; OriginalInvoiceNo: Text[16])
    var
        JDocumentHeaderDetails: JsonObject;
    begin
        JDocumentHeaderDetails.Add('Typ', InvoiceType);
        JDocumentHeaderDetails.Add('No', DocumentNo);
        JDocumentHeaderDetails.Add('Dt', PostingDate);
        JDocumentHeaderDetails.Add('OrgInvNo', OriginalInvoiceNo);

        JObject.Add('DocDtls', JDocumentHeaderDetails);
    end;

    local procedure ReadExportDetails()
    begin
        Clear(JsonArrayData);

        ReadInvoiceExportDetails()

    end;



    local procedure ReadInvoiceExportDetails()
    var
        TransferShipmentLine: Record "Transfer Shipment Line";
        ExportCategory: Text[3];
        WithPayOfDuty: Text[1];
        ShipmentBillNo: Text[16];
        ShipmentBillDate: Text[10];
        ExitPort: Text[10];
        DocumentAmount: Decimal;
        CurrencyCode: Text[3];
        CountryCode: Text[2];
    begin
        //need to check for export details in transfer
        /*

         if not (SalesInvoiceHeader."GST Customer Type" in [
             SalesInvoiceHeader."GST Customer Type"::Export,
             SalesInvoiceHeader."GST Customer Type"::"Deemed Export",
             SalesInvoiceHeader."GST Customer Type"::"SEZ Unit",
             SalesInvoiceHeader."GST Customer Type"::"SEZ Development"])
         then
             exit;

         case SalesInvoiceHeader."GST Customer Type" of
             SalesInvoiceHeader."GST Customer Type"::Export:
                 ExportCategory := 'DIR';
             SalesInvoiceHeader."GST Customer Type"::"Deemed Export":
                 ExportCategory := 'DEM';
             SalesInvoiceHeader."GST Customer Type"::"SEZ Unit":
                 ExportCategory := 'SEZ';
             SalesInvoiceHeader."GST Customer Type"::"SEZ Development":
                 ExportCategory := 'SED';
         end;

         if SalesInvoiceHeader."GST Without Payment of Duty" then
             WithPayOfDuty := 'N'
         else
             WithPayOfDuty := 'Y';

         ShipmentBillNo := CopyStr(SalesInvoiceHeader."Bill Of Export No.", 1, 16);
         ShipmentBillDate := Format(SalesInvoiceHeader."Bill Of Export Date", 0, '<Day,2>/<Month,2>/<Year4>');
         ExitPort := SalesInvoiceHeader."Exit Point";

         SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
         if SalesInvoiceLine.FindSet() then
             repeat
                 DocumentAmount := DocumentAmount + SalesInvoiceLine.Amount;
             until SalesInvoiceLine.Next() = 0;

         CurrencyCode := CopyStr(SalesInvoiceHeader."Currency Code", 1, 3);
         CountryCode := CopyStr(SalesInvoiceHeader."Bill-to Country/Region Code", 1, 2);

         WriteExportDetails(WithPayOfDuty, ShipmentBillNo, ShipmentBillDate, ExitPort, CurrencyCode, CountryCode);
         
    end;

    local procedure WriteExportDetails(
        WithPayOfDuty: Text[1];
        ShipmentBillNo: Text[16];
        ShipmentBillDate: Text[10];
        ExitPort: Text[10];
        CurrencyCode: Text[3];
        CountryCode: Text[2])
    var
        JExpDetails: JsonObject;
    begin
        JExpDetails.Add('ShipBNo', ShipmentBillNo);
        JExpDetails.Add('ShipBDt', ShipmentBillDate);
        JExpDetails.Add('Port', ExitPort);
        JExpDetails.Add('RefClm', WithPayOfDuty);
        JExpDetails.Add('ForCur', CurrencyCode);
        JExpDetails.Add('CntCode', CountryCode);

        JObject.Add('ExpDtls', JExpDetails);
    end;

    local procedure ReadDocumentSellerDetails()
    var
        CompanyInformationBuff: Record "Company Information";
        LocationBuff: Record "Location";
        StateBuff: Record "State";
        GSTRegistrationNo: Text[20];
        CompanyName: Text[100];
        Address: Text[100];
        Address2: Text[100];
        Flno: Text[60];
        Loc: Text[60];
        City: Text[60];
        StateCode: Text[10];
        PhoneNumber: Text[10];
        Email: Text[50];
        Pin: Integer;
        PhoneNoValidation: Text[30];

        TempLocation: Record "Location";
    begin

        Clear(JsonArrayData);
        LocationBuff.Get(TransferShipmentHeader."Transfer-from Code");

        GSTRegistrationNo := LocationBuff."GST Registration No.";


        CompanyInformationBuff.Get();
        CompanyName := LocationBuff.Name;
        Address := LocationBuff.Address;
        Address2 := LocationBuff."Address 2";
        Flno := '';
        Loc := '';
        City := LocationBuff.City;
        if LocationBuff."Post Code" <> '' then
            Evaluate(Pin, (CopyStr(LocationBuff."Post Code", 1, 6)))
        else
            Pin := 000000;

        StateBuff.Get(LocationBuff."State Code");
        StateCode := StateBuff."State Code (GST Reg. No.)";

        if LocationBuff."Phone No." <> '' then
            PhoneNumber := CopyStr(LocationBuff."Phone No.", 1, 10)
        else
            PhoneNumber := '000000';

        if LocationBuff."E-Mail" <> '' then
            Email := CopyStr(LocationBuff."E-Mail", 1, 50)
        else
            Email := '0000@00';

        PhoneNoValidation := '!@*()+=-[]\\\;,./{}|\":<>?';
        PhoneNumber := DelChr(PhoneNumber, '=', PhoneNoValidation);
        WriteSellerDetails(GSTRegistrationNo, CompanyName, Address, Address2, City, Pin, StateCode, PhoneNumber, Email);
    end;

    local procedure WriteSellerDetails(
        GSTRegistrationNo: Text[20];
        CompanyName: Text[100];
        Address: Text[100];
        Address2: Text[100];
        City: Text[60];
        PostCode: Integer;
        StateCode: Text[10];
        PhoneNumber: Text[10];
        Email: Text[50])
    var
        JSellerDetails: JsonObject;
    begin
        JSellerDetails.Add('Gstin', '27AAAPI3182M002');//GSTRegistrationNo);//hardcoded need to change
        JSellerDetails.Add('LglNm', CompanyName);
        JSellerDetails.Add('Addr1', Address);

        if Address2 <> '' then
            JSellerDetails.Add('Addr2', Address2);

        JSellerDetails.Add('Loc', City);
        JSellerDetails.Add('Pin', 411027);//Hard coded need to change later PostCode
        JSellerDetails.Add('Stcd', '27');///Hard coded need to change later

        if PhoneNumber <> '' then
            JSellerDetails.Add('Ph', PhoneNumber)
        else
            JSellerDetails.Add('Ph', '000000');

        if Email <> '' then
            JSellerDetails.Add('Em', Email)
        else
            JSellerDetails.Add('Em', '0000@00');

        JObject.Add('SellerDtls', JSellerDetails);
    end;

    local procedure ReadDocumentBuyerDetails()
    begin
        Clear(JsonArrayData);

        ReadInvoiceBuyerDetails()

    end;

    local procedure ReadInvoiceBuyerDetails()
    var
        Contact: Record Contact;
        SalesInvoiceLine: Record "Sales Invoice Line";
        ShiptoAddress: Record "Ship-to Address";
        StateBuff: Record State;
        GSTRegistrationNumber: Text[20];
        CompanyName: Text[100];
        Address: Text[100];
        Address2: Text[100];
        Floor: Text[60];
        AddressLocation: Text[60];
        City: Text[60];
        StateCode: Text[10];
        PhoneNumber: Text[10];
        Email: Text[50];
        Pin: Integer;
        PhoneNoValidation: Text[30];

        TempLocation: Record Location;
    begin
        IF TempLocation.get(TransferShipmentHeader."Transfer-to Code") then;
        //  if SalesInvoiceHeader."Customer GST Reg. No." <> '' then
        //     GSTRegistrationNumber := SalesInvoiceHeader."Customer GST Reg. No."
        //   else
        GSTRegistrationNumber := TempLocation."GST Registration No.";

        CompanyName := TempLocation.Name;// SalesInvoiceHeader."Bill-to Name";
        Address := TempLocation.Address; //SalesInvoiceHeader."Bill-to Address";
        Address2 := TempLocation."Address 2";//."Bill-to Address 2";
        Floor := '';
        AddressLocation := '';
        City := TempLocation.City;// SalesInvoiceHeader."Bill-to City";

        if TempLocation."Post Code" <> '' then
            Evaluate(Pin, (CopyStr(TempLocation."Post Code", 1, 6)))
        else
            Pin := 000000;

        /*      SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
              SalesInvoiceLine.SetFilter(Type, '<>%1', SalesInvoiceLine.Type::" ");
              if SalesInvoiceLine.FindFirst() then
                  case SalesInvoiceLine."GST Place of Supply" of
                      SalesInvoiceLine."GST Place of Supply"::"Bill-to Address":
                          begin
                              if not (SalesInvoiceHeader."GST Customer Type" = SalesInvoiceHeader."GST Customer Type"::Export) then begin
                                  StateBuff.Get(SalesInvoiceHeader."GST Bill-to State Code");
                                  StateCode := StateBuff."State Code (GST Reg. No.)";
                              end else
                                  StateCode := '';

                              if Contact.Get(SalesInvoiceHeader."Bill-to Contact No.") then begin
                                  PhoneNumber := CopyStr(Contact."Phone No.", 1, 10);
                                  Email := CopyStr(Contact."E-Mail", 1, 50);
                              end else begin
                                  PhoneNumber := '';
                                  Email := '';
                              end;
                          end;

                      SalesInvoiceLine."GST Place of Supply"::"Ship-to Address":
                          begin
                              if not (SalesInvoiceHeader."GST Customer Type" = SalesInvoiceHeader."GST Customer Type"::Export) then begin
                                  StateBuff.Get(SalesInvoiceHeader."GST Ship-to State Code");
                                  StateCode := StateBuff."State Code (GST Reg. No.)";
                              end else
                                  StateCode := '';

                              if ShiptoAddress.Get(SalesInvoiceHeader."Sell-to Customer No.", SalesInvoiceHeader."Ship-to Code") then begin
                                  PhoneNumber := CopyStr(ShiptoAddress."Phone No.", 1, 10);
                                  Email := CopyStr(ShiptoAddress."E-Mail", 1, 50);
                              end else begin
                                  PhoneNumber := '';
                                  Email := '';
                              end;
                          end;
                      else begin
                          StateCode := '';
                          PhoneNumber := '';
                          Email := '';
                      end;
                  end;
      
        StateBuff.Get(TempLocation."State Code");
        StateCode := StateBuff."State Code (GST Reg. No.)";

        PhoneNumber := TempLocation."Phone No.";
        Email := TempLocation."E-Mail";

        PhoneNoValidation := '!@*()+=-[]\\\;,./{}|\":<>?';
        PhoneNumber := DelChr(PhoneNumber, '=', PhoneNoValidation);
        WriteBuyerDetails(GSTRegistrationNumber, CompanyName, Address, Address2, City, Pin, StateCode, PhoneNumber, Email);

    end;



    local procedure WriteBuyerDetails(
        GSTRegistrationNumber: Text[20];
        CompanyName: Text[100];
        Address: Text[100];
        Address2: Text[100];
        City: Text[60];
        Pin: Integer;
        StateCode: Text[10];
        PhoneNumber: Text[10];
        EmailID: Text[50])
    var
        JBuyerDetails: JsonObject;
    begin
        JBuyerDetails.Add('Gstin', GSTRegistrationNumber);//29AAECH1917Q1Z2 harded need to change later
        JBuyerDetails.Add('LglNm', CompanyName);

        if StateCode <> '' then
            JBuyerDetails.Add('POS', StateCode) //29 harded coded need to chane later
        else
            JBuyerDetails.Add('POS', '29');

        JBuyerDetails.Add('Addr1', Address);

        if Address2 <> '' then
            JBuyerDetails.Add('Addr2', Address2);

        JBuyerDetails.Add('Loc', City);
        JBuyerDetails.Add('Stcd', StateCode);//'29' harded coded
        JBuyerDetails.Add('Pin', Pin);//'560001'

        if PhoneNumber <> '' then
            JBuyerDetails.Add('Ph', PhoneNumber)
        else
            JBuyerDetails.Add('Ph', '000000');

        if EmailID <> '' then
            JBuyerDetails.Add('Em', EmailID)
        else
            JBuyerDetails.Add('Em', '0000@00');

        JObject.Add('BuyerDtls', JBuyerDetails);
    end;

    local procedure ReadDocumentShippingDetails()
    var
        ShiptoAddress: Record "Ship-to Address";
        StateBuff: Record State;
        GSTRegistrationNumber: Text[20];
        CompanyName: Text[100];
        Address: Text[100];
        Address2: Text[100];
        Floor: Text[60];
        AddressLocation: Text[60];
        City: Text[60];
        PostCode: Text[6];
        StateCode: Text[10];
        PhoneNumber: Text[10];
        EmailID: Text[50];

        TempLocation1: Record "Location";

    begin
        Clear(JsonArrayData);
        if (TransferShipmentHeader."Transfer-to Code" <> '') then begin
            if TempLocation1.Get(TransferShipmentHeader."Transfer-to Code") then;
            //  ShiptoAddress.Get(SalesInvoiceHeader."Sell-to Customer No.", SalesInvoiceHeader."Ship-to Code");
            //   StateBuff.Get(SalesInvoiceHeader."GST Ship-to State Code");
            CompanyName := TransferShipmentHeader."Transfer-to Code";
            Address := TransferShipmentHeader."Transfer-to Address";
            Address2 := TransferShipmentHeader."Transfer-to Address 2";
            City := TransferShipmentHeader."Transfer-to City";
            PostCode := CopyStr(TransferShipmentHeader."Transfer-to Post Code", 1, 6);
        end;


        GSTRegistrationNumber := TempLocation1."GST Registration No.";

        Floor := '';
        AddressLocation := TempLocation1.City;
        //StateCode := TempLocation1."State Code";//StateBuff."State Code for eTDS/TCS";
        StateBuff.Get(TempLocation1."State Code");
        StateCode := StateBuff."State Code (GST Reg. No.)";
        PhoneNumber := CopyStr(TempLocation1."Phone No.", 1, 10);
        EmailID := CopyStr(TempLocation1."E-Mail", 1, 50);
        WriteShippingDetails(GSTRegistrationNumber, CompanyName, Address, Address2, AddressLocation, PostCode, StateCode);
    end;

    local procedure WriteShippingDetails(
        GSTRegistrationNumber: Text[20];
        CompanyName: Text[100];
        Address: Text[100];
        Address2: Text[100];
        AddressLocation: Text[60];
        PostCode: Text[6];
        StateCode: Text[10])
    var
        Pin: Integer;
        JShippingDetails: JsonObject;
    begin
        Pin := 000000;
        JShippingDetails.Add('Gstin', GSTRegistrationNumber);
        JShippingDetails.Add('LglNm', CompanyName);
        JShippingDetails.Add('TrdNm', CompanyName);
        JShippingDetails.Add('Addr1', Address);

        if Address2 <> '' then
            JShippingDetails.Add('Addr2', Address2);

        JShippingDetails.Add('Loc', AddressLocation);

        if PostCode <> '' then
            JShippingDetails.Add('Pin', PostCode)
        else
            JShippingDetails.Add('Pin', Pin);

        JShippingDetails.Add('Stcd', StateCode);

        if CompanyName <> '' then
            JObject.Add('ShipDtls', JShippingDetails);
    end;

    local procedure ReadDocumentTotalDetails()
    var
        AssessableAmount: Decimal;
        CGSTAmount: Decimal;
        SGSTAmount: Decimal;
        IGSTAmount: Decimal;
        CessAmount: Decimal;
        StateCessAmount: Decimal;
        CESSNonAvailmentAmount: Decimal;
        DiscountAmount: Decimal;
        OtherCharges: Decimal;
        TotalInvoiceValue: Decimal;
    begin
        Clear(JsonArrayData);
        GetGSTValue(AssessableAmount, CGSTAmount, SGSTAmount, IGSTAmount, CessAmount, StateCessAmount, CESSNonAvailmentAmount, DiscountAmount, OtherCharges, TotalInvoiceValue);
        WriteDocumentTotalDetails(AssessableAmount, CGSTAmount, SGSTAmount, IGSTAmount, CessAmount, CESSNonAvailmentAmount, DiscountAmount, OtherCharges, TotalInvoiceValue);
    end;

    local procedure WriteDocumentTotalDetails(
        AssessableAmount: Decimal;
        CGSTAmount: Decimal;
        SGSTAmount: Decimal;
        IGSTAmount: Decimal;
        CessAmount: Decimal;
        CessNonAdvanceVal: Decimal;
        DiscountAmount: Decimal;
        OtherCharges: Decimal;
        TotalInvoiceAmount: Decimal)
    var
        JDocTotalDetails: JsonObject;
        RoundOffAmt: Integer;
    begin
        RoundOffAmt := 0;
        JDocTotalDetails.Add('Assval', AssessableAmount);
        JDocTotalDetails.Add('CgstVal', CGSTAmount);
        JDocTotalDetails.Add('SgstVAl', SGSTAmount);
        JDocTotalDetails.Add('IgstVal', IGSTAmount);
        JDocTotalDetails.Add('CesVal', CessAmount);
        JDocTotalDetails.Add('CesNonAdVal', CessNonAdvanceVal);
        JDocTotalDetails.Add('Disc', DiscountAmount);
        JDocTotalDetails.Add('OthChrg', OtherCharges);

        if RndOffAmt = 0 then
            JDocTotalDetails.Add('RndOffAmt', RoundOffAmt)
        else
            JDocTotalDetails.Add('RndOffAmt', RndOffAmt);

        JDocTotalDetails.Add('TotInvVal', TotalInvoiceAmount);

        JObject.Add('ValDtls', JDocTotalDetails);
    end;

    local procedure ReadEwbDtls()
    var
        transfershipmentheader: Record "Transfer Shipment Header";
        ShippingAgent: Record "Shipping Agent";
        TransID: Text[15];
        TransName: Text[100];
        TransMode: Text[20];
        Distance: Integer;
        TransDocNo: Text[15];
        TransDocDt: Text[10];
        TransportDocDt: Text[10];
        VehNo: Text[20];
        VehType: Text[1];
        dist3: Integer;
        dist1: Decimal;
    begin
        TransDocNo := '';

        if transfershipmentheader.Get(DocumentNo) then begin
            if ShippingAgent.Get(transfershipmentheader."Shipping Agent Code") then begin
                TransID := ShippingAgent."GST Registration No.";
                TransName := ShippingAgent.Name;
            end;

            TransMode := transfershipmentheader."Mode of Transport";
            TransDocNo := transfershipmentheader."No.";
            TransDocDt := Format(transfershipmentheader."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>');
            //     Distance := transfershipmentheader."Distance (Km)";
            IF TransferShipmentHeader."Distance (Km)" <> 0 then begin
                dist1 := TransferShipmentHeader."Distance (Km)";
                Evaluate(dist3, format(dist1));
                Distance := dist3;
                //  JObject.Add('Distance', dist3);
            end
            else
                Distance := 0;
            // JObject.Add('Distance', 0);
            VehNo := transfershipmentheader."Vehicle No.";
            if transfershipmentheader."Vehicle Type" <> transfershipmentheader."Vehicle Type"::" " then
                if transfershipmentheader."Vehicle Type" = transfershipmentheader."Vehicle Type"::ODC then
                    VehType := 'O'
                else
                    VehType := 'R'
            else
                VehType := '';
        end;

        //  OnAfterGetLRNoAndLrDate(SalesInvHeader, TransDocNo, TransportDocDt);
        if TransportDocDt <> '' then
            TransDocDt := TransportDocDt;

        if (Distance = 0) and (VehNo = '') and (VehType = '') and (TransMode = '') then
            exit;

        WriteEWayBillTotalDetails(TransID, TransName, TransMode, Distance, TransDocNo, TransDocDt, VehNo, VehType);
    end;

    local procedure WriteEWayBillTotalDetails(
        TransId: Text[15];
        TransName: Text[100];
        TransMode: Text[1];
        Distance: Integer;
        TransDocNo: Text[15];
        TransDocDt: Text[10];
        VehNo: Text[20];
        VehType: Text[1])
    var
        JDocEwayDetails: JsonObject;
    begin
        if TransId = '' then
            JDocEwayDetails.Add('TransId', 'null')
        else
            JDocEwayDetails.Add('TransId', TransId);

        if TransName = '' then
            JDocEwayDetails.Add('TransName', 'null')
        else
            JDocEwayDetails.Add('TransName', TransName);

        JDocEwayDetails.Add('TransMode', TransMode);
        JDocEwayDetails.Add('Distance', Distance);

        if TransDocNo = '' then
            JDocEwayDetails.Add('TransDocNo', 'null')
        else
            JDocEwayDetails.Add('TransDocNo', TransDocNo);

        JDocEwayDetails.Add('TransDocDt', TransDocDt);
        JDocEwayDetails.Add('VehNo', VehNo);
        JDocEwayDetails.Add('VehType', VehType);

        JObject.Add('EwbDtls', JDocEwayDetails);
    end;

    local procedure ReadDocumentItemList()
    var
        TransferShipmentLine: Record "Transfer Shipment Line";
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
        UnitofMeasure: Record "Unit of Measure";
        UCQ: Code[10];
    begin
        Count := 1;
        Clear(JsonArrayData);

        TransferShipmentLine.SetRange("Document No.", DocumentNo);
        // TransferShipmentLine.SetFilter(Type, '<>%1', TransferShipmentLine.Type::" ");
        if TransferShipmentLine.FindSet() then begin
            if TransferShipmentLine.Count > 100 then
                Error(SalesLinesMaxCountLimitErr, TransferShipmentLine.Count);
            repeat
                /*
                    if TransferShipmentLine."GST Assessable Value (LCY)" <> 0 then
                        AssessableAmount := TransferShipmentLine."GST Assessable Value (LCY)"
                    else
                    
                AssessableAmount := TransferShipmentLine.Amount;
                /*
                                    if TransferShipmentLine."GST Group Type" = TransferShipmentLine."GST Group Type"::Goods then
                                        IsServc := 'N'
                                    else
                                        IsServc := 'Y';
                                        
                IsServc := 'N';
                GetGSTComponentRate(
                    TransferShipmentLine."Document No.",
                    TransferShipmentLine."Line No.",
                    CGSTRate,
                    SGSTRate,
                    IGSTRate,
                    CessRate,
                    CesNonAdval,
                    StateCess);
                /*
            if TransferShipmentLine.gst = TransferShipmentLine."GST Jurisdiction Type"::Intrastate then
                GstRate := CGSTRate + SGSTRate
            else
                GstRate := IGSTRate;
             
                GstRate := IGSTRate;


                UnitofMeasure.Reset();
                UnitofMeasure.SetRange(Code, TransferShipmentLine."Unit of Measure Code");
                IF UnitofMeasure.FindFirst() then;
                UCQ := UnitofMeasure.Code;

                GetGSTValueForLine(TransferShipmentLine."Line No.", CGSTValue, SGSTValue, IGSTValue);
                //if TransferShipmentLine."No." <> GetInvoiceRoundingAccountForInvoice() then
                WriteItem(
                  Format(Count),
                  TransferShipmentLine.Description + TransferShipmentLine."Description 2",
                  TransferShipmentLine."HSN/SAC Code",
                  GstRate, TransferShipmentLine.Quantity,
                  UCQ,
                  Round(TransferShipmentLine."Unit Price", 0.01, '='),
                  TransferShipmentLine.Amount,
                  0, 0,
                  AssessableAmount, CGSTValue, SGSTValue, IGSTValue, CessRate, CesNonAdval,
                  AssessableAmount + CGSTValue + SGSTValue + IGSTValue,
                  IsServc);

                Count += 1;
            until TransferShipmentLine.Next() = 0;
        end;

        JObject.Add('ItemList', JsonArrayData);

    end;


    local procedure WriteItem(
      SlNo: Text[1];
      ProductName: Text;
      HSNCode: Text[10];
      GstRate: Integer;
      Quantity: Decimal;
      Unit: Text[3];
      UnitPrice: Decimal;
      TotAmount: Decimal;
      Discount: Decimal;
      OtherCharges: Decimal;
      AssessableAmount: Decimal;
      CGSTRate: Decimal;
      SGSTRate: Decimal;
      IGSTRate: Decimal;
      CESSRate: Decimal;
      CessNonAdvanceAmount: Decimal;
      TotalItemValue: Decimal;
      IsServc: Text[1])
    var
        JItem: JsonObject;
    begin
        JItem.Add('SlNo', SlNo);
        JItem.Add('PrdDesc', ProductName);
        JItem.Add('IsServc', IsServc);
        JItem.Add('HsnCd', HSNCode);//hardcoded Need to change
        JItem.Add('Qty', Quantity);
        JItem.Add('Unit', Unit);//hardcoded Need to change
        JItem.Add('UnitPrice', UnitPrice);
        JItem.Add('TotAmt', TotAmount);
        JItem.Add('Discount', Discount);
        JItem.Add('OthChrg', OtherCharges);
        JItem.Add('AssAmt', AssessableAmount);
        JItem.Add('GstRt', GstRate);
        JItem.Add('CgstAmt', CGSTRate);
        JItem.Add('SgstAmt', SGSTRate);
        JItem.Add('IgstAmt', IGSTRate);
        JItem.Add('CesRt', CESSRate);
        JItem.Add('CesAmt', 0);

        JItem.Add('CesNonAdval', CessNonAdvanceAmount);
        JItem.Add('TotItemVal', TotalItemValue);

        JsonArrayData.Add(JItem);
    end;

    local procedure ExportAsJsonInvoice(FileName: Text[20])
    var
        TempBlob: Codeunit "Temp Blob";
        ToFile: Variant;
        InStream: InStream;
        OutStream: OutStream;
        RecRef: RecordRef;

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
        errorDetailsJsonToken: JsonToken;
        errorDetailsJsonObject: JsonObject;
        JobjErrorarr: JsonArray;
        j: integer;
        TempGstSetup: Record "GST Setup";

    begin
        //to check avala Api
        TempGstSetup.Get();
        TempGstSetup.TestField(TempGstSetup.AvalaraEinvoiceApi);
        TempGstSetup.TestField(TempGstSetup.EinvoiceSecurityToken);
        JsonArrayData.Add(JObject);
        JsonArrayData.WriteTo(JsonText);
        TempBlob.CreateOutStream(OutStream);
        OutStream.WriteText(JsonText);
        ToFile := FileName + '.json';
        TempBlob.CreateInStream(InStream);
        DownloadFromStream(InStream, 'e-Invoice', '', '', ToFile);
        Sleep(1000);

        AccessToken := TempGstSetup.EinvoiceSecurityToken;//'fe28e9b25dfe9390fb23a5dca981bf6a9f629950da954aa322f490a7dcf244e5';
        //'fe28e9b25dfe9390fb23a5dca981bf6a9f629950da954aa322f490a7dcf244e5';
        content.WriteFrom(JsonText);

        // Retrieve the contentHeaders associated with the content
        content.GetHeaders(contentHeaders);
        contentHeaders.Clear();
        contentHeaders.Add('Content-Type', 'application/json');
        //contentHeaders.Add('gstin', '29AAECH1917Q1Z2');
        //  contentHeaders.Add('Authorization', 'Bearer fe28e9b25dfe9390fb23a5dca981bf6a9f629950da954aa322f490a7dcf244e5');

        client.DefaultRequestHeaders.Add('Authorization', 'Bearer ' + AccessToken);

        // Assigning content to request.Content will actually create a copy of the content and assign it.
        // After this line, modifying the content variable or its associated headers will not reflect in 
        // the content associated with the request message
        request.Content := content;
        //'https://www.sandbox-gstapi.trustfilegst.in/einvoice/api/v1/EInvoice/27AAAPI3182M002/GenerateEinvoiceGSTNFormat'
        request.SetRequestUri(TempGstSetup.AvalaraEinvoiceApi);
        request.Method := 'POST';

        client.Send(request, response);
        if response.IsSuccessStatusCode then begin
            response.Content().ReadAs(responseText);
            // Message(responseText);
            // JobjectResponse.ReadFrom(responseText);
            //  Message(format(JobjectResponse));

            if JobjToken.ReadFrom(responseText) then begin
                if JobjToken.IsArray then   // json_Token.IsArray; json_Token.IsObject; json_Token.IsValue;
                    Jobjarr := JobjToken.AsArray();
                for i := 0 to Jobjarr.Count() - 1 do begin
                    // Get First Array Result
                    Jobjarr.Get(i, JobjToken);
                    // Convert JsonToken to JsonObject
                    if JobjToken.IsObject then begin
                        JobjectResponse := JobjToken.AsObject();

                        //for error
                        if JobjectResponse.Get('errorDetails', errorDetailsJsonToken) then begin
                            if errorDetailsJsonToken.IsArray then   // json_Token.IsArray; json_Token.IsObject; json_Token.IsValue;
                                JobjErrorarr := errorDetailsJsonToken.AsArray();
                            for j := 0 to JobjErrorarr.Count() - 1 do begin

                                // Get First Array Result
                                JobjErrorarr.Get(i, errorDetailsJsonToken);
                                if errorDetailsJsonToken.IsObject then begin
                                    errorDetailsJsonObject := errorDetailsJsonToken.AsObject();
                                    errorDetailsJsonObject.Get('errorCode', errorDetailsJsonToken);
                                    IF (errorDetailsJsonToken.AsValue().AsText() <> '') then begin
                                        errorDetailsJsonObject.Get('errorMessage', errorDetailsJsonToken);
                                        Error(errorDetailsJsonToken.AsValue().AsText());
                                    end;
                                end;

                            end;
                        end;

                        JobjectResponse.Get('ackNo', JobjToken);
                        TransferShipmentHeader."Acknowledgement No." := JobjToken.AsValue().AsText();
                        // Message(ackno);

                        JobjectResponse.Get('irn', JobjToken);
                        TransferShipmentHeader."IRN Hash" := JobjToken.AsValue().AsText();

                        JobjectResponse.Get('ackDt', JobjToken);
                        ackdatetimetext := JobjToken.AsValue().AsText();
                        Evaluate(AcknowledgementDate, CopyStr(ackdatetimetext, 1, 10));
                        Evaluate(AcknowledgementTime, CopyStr(ackdatetimetext, 12, 8));
                        TempDateTime := CreateDateTime(AcknowledgementDate, AcknowledgementTime);
                        TransferShipmentHeader."Acknowledgement Date" := TempDateTime;

                        TransferShipmentHeader.IsJSONImported := true;
                        TransferShipmentHeader.Modify();
                        Clear(RecRef);

                        RecRef.GetTable(TransferShipmentHeader);
                        JobjectResponse.Get('encodedSignedQRCode', JobjToken);
                        SignedQRCodeTxt1 := JobjToken.AsValue().AsText();

                        QRGenerator.GenerateQRCodeImage(SignedQRCodeTxt1, TempBlob2);
                        FieldRef := RecRef.Field(TransferShipmentHeader.FieldNo("QR Code"));
                        TempBlob2.ToRecordRef(RecRef, TransferShipmentHeader.FieldNo("QR Code"));
                        RecRef.Modify();
                        Commit();

                        Message('Ack no and IRN number generated successfully');
                    end;

                end;
            end;


        end;


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
        TransferShipmentLine: Record "Transfer Shipment Line";

        GSTLedgerEntry: Record "GST Ledger Entry";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        CustLedgerEntry: Record "Cust. Ledger Entry";
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
        /*

                SalesInvoiceLine.SetRange("Document No.", DocumentNo);
                if SalesInvoiceLine.FindSet() then
                    repeat
                        AssessableAmount += SalesInvoiceLine.Amount;
                        DiscountAmount += SalesInvoiceLine."Inv. Discount Amount";
                    until SalesInvoiceLine.Next() = 0;
                TotGSTAmt := CGSTAmount + SGSTAmount + IGSTAmount + CessAmount + CessNonAdvanceAmount + StateCessValue;

                AssessableAmount := Round(
                    CurrencyExchangeRate.ExchangeAmtFCYToLCY(
                      WorkDate(), SalesInvoiceHeader."Currency Code", AssessableAmount, SalesInvoiceHeader."Currency Factor"), 0.01, '=');
                TotGSTAmt := Round(
                    CurrencyExchangeRate.ExchangeAmtFCYToLCY(
                      WorkDate(), SalesInvoiceHeader."Currency Code", TotGSTAmt, SalesInvoiceHeader."Currency Factor"), 0.01, '=');
                DiscountAmount := Round(
                    CurrencyExchangeRate.ExchangeAmtFCYToLCY(
                      WorkDate(), SalesInvoiceHeader."Currency Code", DiscountAmount, SalesInvoiceHeader."Currency Factor"), 0.01, '=');


                        CustLedgerEntry.SetCurrentKey("Document No.");
                        CustLedgerEntry.SetRange("Document No.", DocumentNo);
                        if IsInvoice then begin
                            CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
                            CustLedgerEntry.SetRange("Customer No.", SalesInvoiceHeader."Bill-to Customer No.");
                        end else begin
                            CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
                            CustLedgerEntry.SetRange("Customer No.", SalesCrMemoHeader."Bill-to Customer No.");
                        end;

                        if CustLedgerEntry.FindFirst() then begin
                            CustLedgerEntry.CalcFields("Amount (LCY)");
                            TotalInvoiceValue := Abs(CustLedgerEntry."Amount (LCY)");
                        end;
                
        TransferShipmentLine.Reset();
        TransferShipmentLine.SetRange("Document No.", TransferShipmentHeader."No.");
        IF TransferShipmentLine.FindFirst() then
            repeat
                TotalInvoiceValue := TotalInvoiceValue + TransferShipmentLine.Amount;
            Until TransferShipmentLine.Next() = 0;
        AssessableAmount := TotalInvoiceValue;
        TotalInvoiceValue := TotalInvoiceValue + IGSTAmount + CGSTAmount + SGSTAmount;
        OtherCharges := 0;
    end;

    local procedure GetGSTValueForLine(
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

    procedure GenerateIRN(input: Text): Text
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512;
    begin
        exit(CryptographyManagement.GenerateHash(input, HashAlgorithmType::SHA256));
    end;



    [IntegrationEvent(false, false)]
    local procedure OnBeforeGenerateQRCodeForB2C(BankCode: Code[20]; var QRCodeInput: Text; var SalesInvHeader: Record "Sales Invoice Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetLRNoAndLrDate(SalesInvHeader: Record "Sales Invoice Header"; var TransDocNo: Text[15]; var TransDocDt: Text[10])
    begin
    end;

}
*/