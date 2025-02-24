codeunit 50035 "PurchaseCrMemoEwayBill"
{
    Permissions = tabledata "Purch. Cr. Memo Hdr." = rm;



    procedure CreatePurchCrMemoEwayBill()
    var

    begin
        Initialize();


        //RunSalesInvoiceEwayBill();
        PayloadEwayBillFromIRN();
        if DocumentNo <> '' then
            GenerateEwayBillFromIRN(DocumentNo)
        else
            Error(DocumentNoBlankErr);
    end;

    procedure CreatePurchCrMemoEInvoice()
    var

    begin

        Initialize();


        RunPurchCrMemo();

        if DocumentNo <> '' then begin
            ExportAsJsonCreditMemo(DocumentNo);
        end
        else
            Error(DocumentNoBlankErr);
    end;

    var
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
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

        SalesInvoiceHeader: Record "Sales Invoice Header";
    //TempTransferReceipt : Record "Transfer Receipt Header";

    procedure SetPurchCrMemoHeader(PurchMemoHeaderBuff: Record "Purch. Cr. Memo Hdr.")
    begin
        PurchCrMemoHeader := PurchMemoHeaderBuff;
    end;






    local procedure GetSalesInvoiceLineForB2CCustomer(DocumentNo: Text[20]; Var CGSTRate: Decimal; Var SGSTRate: Decimal; Var IGSTRate: Decimal; Var TotalGstAmount: Decimal)
    Var
        SalesInvoiceLine: Record "Sales Invoice Line";
        CGSTValue: Decimal;
        SGSTValue: Decimal;
        IGSTValue: Decimal;
    begin
        SalesInvoiceLine.SetRange("Document No.", DocumentNo);
        SalesInvoiceLine.LoadFields("Line No.");
        if SalesInvoiceLine.FindSet() then
            repeat
                GetGSTValueForLine(SalesInvoiceLine."Line No.", CGSTValue, SGSTValue, IGSTValue);
                CGSTRate += CGSTValue;
                SGSTRate += SGSTValue;
                IGSTRate += IGSTValue;
                TotalGstAmount += (CGSTValue + SGSTValue + IGSTValue);
            Until SalesInvoiceLine.Next() = 0;
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

    local procedure RunPurchCrMemo()
    begin

        if PurchCrMemoHeader."GST Vendor Type" in [
            PurchCrMemoHeader."GST Vendor Type"::Unregistered,
            PurchCrMemoHeader."GST Vendor Type"::" "]
        then
            Error(eInvoiceNotApplicableCustErr);

        DocumentNo := PurchCrMemoHeader."No.";
        WriteJsonFileHeader();
        ReadTransactionDetails(PurchCrMemoHeader."GST Vendor Type", PurchCrMemoHeader."Ship-to Code");
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

    local procedure ReadTransactionDetails(GSTVendType: Enum "GST Vendor Type"; ShipToCode: Code[12])
    begin
        Clear(JsonArrayData);

        ReadInvoiceTransactionDetails(GSTVendType, ShipToCode)

    end;

    local procedure ReadInvoiceTransactionDetails(GSTVendType: Enum "GST Vendor Type"; ShipToCode: Code[12])
    var
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        NatureOfSupply: Text[7];
        SupplyType: Text[3];
        IgstOnIntra: Text[3];
    begin

        IF PurchCrMemoHeader."GST Vendor Type" = PurchCrMemoHeader."GST Vendor Type"::Registered Then
            NatureOfSupply := 'B2B';

        /*
                case GSTVendType of
                    PurchCrMemoHeader."GST Vendor Type"::Registered, PurchCrMemoHeader."GST Vendor Type"::Exempted:
                        NatureOfSupply := 'B2B';
                        */
        /*
       PurchCrMemoHeader."GST Vendor Type"::Export:
           if SalesInvoiceHeader."GST Without Payment of Duty" then
               NatureOfSupply := 'EXPWOP'
           else
               NatureOfSupply := 'EXPWP';


       PurchCrMemoHeader."GST Vendor Type"::"Deemed Export":
           NatureOfSupply := 'DEXP';

       SalesInvoiceHeader."GST Customer Type"::"SEZ Development", SalesInvoiceHeader."GST Customer Type"::"SEZ Unit":
           if SalesInvoiceHeader."GST Without Payment of Duty" then
               NatureOfSupply := 'SEZWOP'
           else
               NatureOfSupply := 'SEZWP';
                
        end;
        */

        if ShipToCode <> '' then begin
            /*
            PurchCrMemoLine.SetRange("Document No.", DocumentNo);
            if PurchCrMemoLine.FindSet() then
                repeat
                    if PurchCrMemoLine."GST Place of Supply" = PurchCrMemoLine."GST Place of Supply"::"Ship-to Address" then
                        SupplyType := 'REG'
                    else
                        SupplyType := 'SHP';
                until SalesCrMemoLine.Next() = 0;
        end else
        */
            SupplyType := 'REG';

            if PurchCrMemoHeader."POS Out Of India" then
                IgstOnIntra := 'Y'
            else
                IgstOnIntra := 'N';

            WriteTransactionDetails(NatureOfSupply, 'N', '', IgstOnIntra);
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
            if (SalesInvoiceHeader."Invoice Type" = SalesInvoiceHeader."Invoice Type"::"Debit Note") or
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
        */
        InvoiceType := 'DBN';
        PostingDate := Format(PurchCrMemoHeader."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>');
        OriginalInvoiceNo := CopyStr(GetReferenceInvoiceNo(DocumentNo), 1, 16);
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

        ReadCrMemoExportDetails();
    end;

    local procedure ReadCrMemoExportDetails()
    var
        SalesCrMemoLine: Record "Purch. Cr. Memo Line";
        ExportCategory: Text[3];
        WithPayOfDuty: Text[1];
        ShipmentBillNo: Text[16];
        ShipmentBillDate: Text[10];
        ExitPort: Text[10];
        DocumentAmount: Decimal;
        CurrencyCode: Text[3];
        CountryCode: Text[2];
    begin
        /*

         if not (SalesCrMemoHeader."GST Customer Type" in [
             SalesCrMemoHeader."GST Customer Type"::Export,
             SalesCrMemoHeader."GST Customer Type"::"Deemed Export",
             SalesCrMemoHeader."GST Customer Type"::"SEZ Unit",
             SalesCrMemoHeader."GST Customer Type"::"SEZ Development"])
         then
             exit;

         case SalesCrMemoHeader."GST Customer Type" of
             SalesCrMemoHeader."GST Customer Type"::Export:
                 ExportCategory := 'DIR';
             SalesCrMemoHeader."GST Customer Type"::"Deemed Export":
                 ExportCategory := 'DEM';
             SalesCrMemoHeader."GST Customer Type"::"SEZ Unit":
                 ExportCategory := 'SEZ';
             "GST Customer Type"::"SEZ Development":
                 ExportCategory := 'SED';
         end;

         if SalesCrMemoHeader."GST Without Payment of Duty" then
             WithPayOfDuty := 'N'
         else
             WithPayOfDuty := 'Y';

         ShipmentBillNo := CopyStr(SalesCrMemoHeader."Bill Of Export No.", 1, 16);
         ShipmentBillDate := Format(SalesCrMemoHeader."Bill Of Export Date", 0, '<Day,2>/<Month,2>/<Year4>');
         ExitPort := SalesCrMemoHeader."Exit Point";

         SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
         if SalesCrMemoLine.FindSet() then
             repeat
                 DocumentAmount := DocumentAmount + SalesCrMemoLine.Amount;
             until SalesCrMemoLine.Next() = 0;

         CurrencyCode := CopyStr(SalesCrMemoHeader."Currency Code", 1, 3);
         CountryCode := CopyStr(SalesCrMemoHeader."Bill-to Country/Region Code", 1, 2);
         */

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
    begin
        Clear(JsonArrayData);

        GSTRegistrationNo := PurchCrMemoHeader."Location GST Reg. No.";
        LocationBuff.Get(PurchCrMemoHeader."Location Code");


        CompanyInformationBuff.Get();
        CompanyName := CompanyInformationBuff.Name;
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

        ReadCrMemoBuyerDetails();
    end;

    local procedure ReadCrMemoBuyerDetails()
    var
        Contact: Record Contact;
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        ShiptoAddress: Record "Ship-to Address";
        StateBuff: Record State;
        GSTRegistrationNumber: Text[20];
        CompanyName: Text[100];
        Address: Text[100];
        Address2: Text[100];
        Floor: Text[60];
        AddressLocation: Text[60];
        City: Text[60];
        Pin: Integer;
        StateCode: Text[10];
        PhoneNumber: Text[10];
        Email: Text[50];
        PhoneNoValidation: Text[30];
    begin
        if PurchCrMemoHeader."Vendor GST Reg. No." <> '' then
            GSTRegistrationNumber := PurchCrMemoHeader."Vendor GST Reg. No."
        else
            GSTRegistrationNumber := 'URP';
        CompanyName := PurchCrMemoHeader."Buy-from Vendor Name";
        Address := PurchCrMemoHeader."Buy-from Address";
        Address2 := PurchCrMemoHeader."Buy-from Address 2";
        Floor := '';
        AddressLocation := '';
        City := PurchCrMemoHeader."Buy-from City";
        if PurchCrMemoHeader."Buy-from Post Code" <> '' then
            Evaluate(Pin, (CopyStr(PurchCrMemoHeader."Buy-from Post Code", 1, 6)))
        else
            Pin := 000000;

        StateCode := '';
        PhoneNumber := '';
        Email := '';
        /*
        PurchCrMemoLine.Reset();
        PurchCrMemoLine.SetRange("Document No.", PurchCrMemoHeader."No.");
        PurchCrMemoLine.SetFilter("No.", '<>%1', '');
        if PurchCrMemoLine.FindFirst() then
            case PurchCrMemoLine."GST Place of Supply" of

                SalesCrMemoLine."GST Place of Supply"::"Bill-to Address":
                    begin
                        if not (SalesCrMemoHeader."GST Customer Type" = SalesCrMemoHeader."GST Customer Type"::Export) then begin
                            StateBuff.Get(SalesCrMemoHeader."GST Bill-to State Code");
                            StateCode := StateBuff."State Code (GST Reg. No.)";
                        end;

                        if Contact.Get(SalesCrMemoHeader."Bill-to Contact No.") then begin
                            PhoneNumber := CopyStr(Contact."Phone No.", 1, 10);
                            Email := CopyStr(Contact."E-Mail", 1, 50);
                        end;
                    end;

                SalesCrMemoLine."GST Place of Supply"::"Ship-to Address":
                    begin
                        if not (SalesCrMemoHeader."GST Customer Type" = SalesCrMemoHeader."GST Customer Type"::Export) then begin
                            StateBuff.Get(SalesCrMemoHeader."GST Ship-to State Code");
                            StateCode := StateBuff."State Code (GST Reg. No.)";
                        end;

                        if ShiptoAddress.Get(SalesCrMemoHeader."Sell-to Customer No.", SalesCrMemoHeader."Ship-to Code") then begin
                            PhoneNumber := CopyStr(ShiptoAddress."Phone No.", 1, 10);
                            Email := CopyStr(ShiptoAddress."E-Mail", 1, 50);
                        end;
                    end;
            end;
            */

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
    begin
        Clear(JsonArrayData);
        //nned to check
        /*
              if PurchCrMemoHeader."Ship-to Code" <> '' then begin
                  ShiptoAddress.Get(PurchCrMemoHeader."Sell-to Customer No.", PurchCrMemoHeader."Ship-to Code");
                  StateBuff.Get(PurchCrMemoHeader.GSt);
                  CompanyName := PurchCrMemoHeader."Ship-to Name";
                  Address := PurchCrMemoHeader."Ship-to Address";
                  Address2 := PurchCrMemoHeader."Ship-to Address 2";
                  City := SalesCrMemoHeader."Ship-to City";
                  PostCode := CopyStr(SalesCrMemoHeader."Ship-to Post Code", 1, 6);
              end;
          if ShiptoAddress."GST Registration No." <> '' then
              GSTRegistrationNumber := ShiptoAddress."GST Registration No."
          else
              GSTRegistrationNumber := SalesInvoiceHeader."Location GST Reg. No.";
          Floor := '';
          AddressLocation := '';
          StateCode := StateBuff."State Code for eTDS/TCS";
          PhoneNumber := CopyStr(ShiptoAddress."Phone No.", 1, 10);
          EmailID := CopyStr(ShiptoAddress."E-Mail", 1, 50);
          */
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
        SalesInvHeader: Record "Sales Invoice Header";
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
    begin
        /*
        TransDocNo := '';
        if IsInvoice then
            if SalesInvHeader.Get(DocumentNo) then begin
                if ShippingAgent.Get(SalesInvHeader."Shipping Agent Code") then begin
                    TransID := ShippingAgent."GST Registration No.";
                    TransName := ShippingAgent.Name;
                end;

                TransMode := SalesInvHeader."Mode of Transport";
                TransDocNo := SalesInvHeader."No.";
                TransDocDt := Format(SalesInvoiceHeader."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>');
                Distance := SalesInvHeader."Distance (Km)";
                VehNo := SalesInvHeader."Vehicle No.";
                if SalesInvHeader."Vehicle Type" <> SalesInvHeader."Vehicle Type"::" " then
                    if SalesInvHeader."Vehicle Type" = SalesInvHeader."Vehicle Type"::ODC then
                        VehType := 'O'
                    else
                        VehType := 'R'
                else
                    VehType := '';
            end;


        if TransportDocDt <> '' then
            TransDocDt := TransportDocDt;

        if (Distance = 0) and (VehNo = '') and (VehType = '') and (TransMode = '') then
            exit;
           */
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

        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
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

        PurchCrMemoLine.SetRange("Document No.", DocumentNo);
        PurchCrMemoLine.SetFilter(Type, '<>%1', PurchCrMemoLine.Type::" ");
        if PurchCrMemoLine.FindSet() then begin
            if PurchCrMemoLine.Count > 100 then
                Error(SalesLinesMaxCountLimitErr, PurchCrMemoLine.Count);

            repeat
                /*
                  if PurchCrMemoLine."GST Assessable Value (LCY)" <> 0 then
                      AssessableAmount := PurchCrMemoLine."GST Assessable Value (LCY)"
                  else
                  */
                AssessableAmount := PurchCrMemoLine.Amount;

                if PurchCrMemoLine."GST Group Type" = PurchCrMemoLine."GST Group Type"::Goods then
                    IsServc := 'N'
                else
                    IsServc := 'Y';

                GetGSTComponentRate(
                    PurchCrMemoLine."Document No.",
                    PurchCrMemoLine."Line No.",
                    CGSTRate,
                    SGSTRate,
                    IGSTRate,
                    CessRate,
                    CesNonAdval,
                    StateCess);

                if PurchCrMemoLine."GST Jurisdiction Type" = PurchCrMemoLine."GST Jurisdiction Type"::Intrastate then
                    GstRate := CGSTRate + SGSTRate
                else
                    GstRate := IGSTRate;

                UnitofMeasure.Reset();
                UnitofMeasure.SetRange(Code, PurchCrMemoLine."Unit of Measure Code");
                IF UnitofMeasure.FindFirst() then;
                UCQ := UnitofMeasure.Code;


                GetGSTValueForLine(PurchCrMemoLine."Line No.", CGSTValue, SGSTValue, IGSTValue);
                if PurchCrMemoLine."No." <> GetInvoiceRoundingAccountForCreditMemo() then
                    WriteItem(
                      Format(Count),
                      PurchCrMemoLine.Description + PurchCrMemoLine."Description 2",
                      PurchCrMemoLine."HSN/SAC Code", GstRate,
                      PurchCrMemoLine.Quantity,
                      UCQ,
                      PurchCrMemoLine."Direct Unit Cost",
                      PurchCrMemoLine."Line Amount" + PurchCrMemoLine."Line Discount Amount",
                      PurchCrMemoLine."Line Discount Amount", 0,
                      AssessableAmount, CGSTValue, SGSTValue, IGSTValue, CessRate, CesNonAdval,
                      AssessableAmount + CGSTValue + SGSTValue + IGSTValue,
                      IsServc)
                else
                    RndOffAmt := PurchCrMemoLine.Amount;

                Count += 1;
            until PurchCrMemoLine.Next() = 0;
        end;

        JObject.Add('ItemList', JsonArrayData);

    end;

    local procedure GetInvoiceRoundingAccountForInvoice(): Code[20]
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        VendorPostingGroup: Record "Vendor Posting Group";
    begin
        if not PurchInvHeader.Get(DocumentNo) then
            exit;

        if not VendorPostingGroup.Get(PurchInvHeader."Vendor Posting Group") then
            exit;

        exit(VendorPostingGroup."Invoice Rounding Account");
    end;

    local procedure GetInvoiceRoundingAccountForCreditMemo(): Code[20]
    var
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        VendorPostingGroup: Record "Vendor Posting Group";
    begin
        if not PurchCrMemoHeader.Get(DocumentNo) then
            exit;

        if not VendorPostingGroup.Get(PurchCrMemoHeader."Vendor Posting Group") then
            exit;

        exit(VendorPostingGroup."Invoice Rounding Account");
    end;

    local procedure WriteItem(
        SlNo: Text[3];
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


    local procedure ExportAsJsonCreditMemo(FileName: Text[20])
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

        //end

        JsonArrayData.Add(JObject);
        JsonArrayData.WriteTo(JsonText);
        TempBlob.CreateOutStream(OutStream);
        OutStream.WriteText(JsonText);
        ToFile := FileName + '.json';
        TempBlob.CreateInStream(InStream);
        DownloadFromStream(InStream, 'e-Credit Memo', '', '', ToFile);
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
        //https://www.sandbox-gstapi.trustfilegst.in/einvoice/api/v1/EInvoice/27AAAPI3182M002/GenerateEinvoiceGSTNFormat
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
                        PurchCrMemoHeader."Acknowledgement No." := JobjToken.AsValue().AsText();


                        JobjectResponse.Get('irn', JobjToken);
                        PurchCrMemoHeader."IRN Hash" := JobjToken.AsValue().AsText();

                        JobjectResponse.Get('ackDt', JobjToken);
                        ackdatetimetext := JobjToken.AsValue().AsText();
                        Evaluate(AcknowledgementDate, CopyStr(ackdatetimetext, 1, 10));
                        Evaluate(AcknowledgementTime, CopyStr(ackdatetimetext, 12, 8));
                        TempDateTime := CreateDateTime(AcknowledgementDate, AcknowledgementTime);
                        PurchCrMemoHeader."Acknowledgement Date" := TempDateTime;

                        PurchCrMemoHeader.IsJSONImported := true;
                        PurchCrMemoHeader.Modify();
                        Clear(RecRef);

                        RecRef.GetTable(PurchCrMemoHeader);
                        JobjectResponse.Get('encodedSignedQRCode', JobjToken);
                        SignedQRCodeTxt1 := JobjToken.AsValue().AsText();

                        QRGenerator.GenerateQRCodeImage(SignedQRCodeTxt1, TempBlob2);
                        FieldRef := RecRef.Field(PurchCrMemoHeader.FieldNo("QR Code"));
                        TempBlob2.ToRecordRef(RecRef, PurchCrMemoHeader.FieldNo("QR Code"));
                        RecRef.Modify();
                        Commit();

                        Message('Ack no and IRN number generated successfully');
                    end;

                end;
            end;


        end
        Else
            Error('Bad request / No response from Avalara , please check with IT team');

    end;



    local procedure GetReferenceInvoiceNo(DocNo: Code[20]) RefInvNo: Code[20]
    var
        ReferenceInvoiceNo: Record "Reference Invoice No.";
    begin
        ReferenceInvoiceNo.SetRange("Document No.", DocNo);
        if ReferenceInvoiceNo.FindFirst() then
            RefInvNo := ReferenceInvoiceNo."Reference Invoice Nos."
        else
            RefInvNo := '';
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

        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        GSTLedgerEntry: Record "GST Ledger Entry";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        VendLedgerEntry: Record "Vendor Ledger Entry";
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


        PurchCrMemoLine.SetRange("Document No.", DocumentNo);
        if PurchCrMemoLine.FindSet() then begin
            repeat
                AssessableAmount += PurchCrMemoLine.Amount;
                DiscountAmount += PurchCrMemoLine."Inv. Discount Amount";
            until PurchCrMemoLine.Next() = 0;
            TotGSTAmt := CGSTAmount + SGSTAmount + IGSTAmount + CessAmount + CessNonAdvanceAmount + StateCessValue;
        end;

        AssessableAmount := Round(
            CurrencyExchangeRate.ExchangeAmtFCYToLCY(
                WorkDate(),
                PurchCrMemoHeader."Currency Code",
                AssessableAmount,
                PurchCrMemoHeader."Currency Factor"),
                0.01,
                '=');

        TotGSTAmt := Round(
            CurrencyExchangeRate.ExchangeAmtFCYToLCY(
                WorkDate(),
                PurchCrMemoHeader."Currency Code",
                TotGSTAmt,
                PurchCrMemoHeader."Currency Factor"),
                0.01,
                '=');

        DiscountAmount := Round(
            CurrencyExchangeRate.ExchangeAmtFCYToLCY(
                WorkDate(),
                PurchCrMemoHeader."Currency Code",
                DiscountAmount,
                PurchCrMemoHeader."Currency Factor"),
                0.01,
                '=');


        VendLedgerEntry.SetCurrentKey("Document No.");
        VendLedgerEntry.SetRange("Document No.", DocumentNo);
        VendLedgerEntry.SetRange("Document Type", VendLedgerEntry."Document Type"::"Credit Memo");
        VendLedgerEntry.SetRange("Vendor No.", PurchCrMemoHeader."Buy-from Vendor No.");

        if VendLedgerEntry.FindFirst() then begin
            VendLedgerEntry.CalcFields("Amount (LCY)");
            TotalInvoiceValue := Abs(VendLedgerEntry."Amount (LCY)");
        end;

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


    ///sales invoice Eway bill start
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
        tempPurchCrInvhdr: Record "Purch. Cr. Memo Hdr.";
    begin

        tempPurchCrInvhdr.Reset();
        tempPurchCrInvhdr.SetRange("No.", PurchCrMemoHeader."No.");
        IF tempPurchCrInvhdr.FindFirst() then;
        tempPurchCrInvhdr.TestField("IRN Hash");
        tempPurchCrInvhdr.TestField("Shipping Agent Code");



        DocumentNo := tempPurchCrInvhdr."No.";

        if ShippingAgent.Get(tempPurchCrInvhdr."Shipping Agent Code") then;

        JObject.Add('Irn', tempPurchCrInvhdr."IRN Hash");

        IF tempPurchCrInvhdr."Distance (Km)" <> 0 then begin
            dist1 := tempPurchCrInvhdr."Distance (Km)";
            Evaluate(dist3, format(dist1));
            JObject.Add('Distance', dist3);
        end
        else
            JObject.Add('Distance', 0);

        // JObject.Add('TransMode', tempPurchCrInvhdr."Mode of Transport");
        JObject.Add('TransMode', '');

        JObject.Add('TransId', ShippingAgent."GST Registration No.");

        JObject.Add('TransName', ShippingAgent.Name);

        JObject.Add('TrnDocNo', tempPurchCrInvhdr."No.");
        JObject.Add('TrnDocDt', tempPurchCrInvhdr."Posting Date");

        JObject.Add('VehNo', tempPurchCrInvhdr."Vehicle No.");

        if tempPurchCrInvhdr."Vehicle Type" <> tempPurchCrInvhdr."Vehicle Type"::" " then
            if tempPurchCrInvhdr."Vehicle Type" = tempPurchCrInvhdr."Vehicle Type"::ODC then
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
        tempSIV: Record "Sales Invoice Header";
        TempMsg: Text;
        TempGstSetup: Record "GST Setup";

    begin
        // JsonArrayData.Add(JObject);
        // JsonArrayData.WriteTo(JsonText);

        //to check avala Api
        TempGstSetup.Get();

        TempGstSetup.TestField(TempGstSetup.IRNtoEwayBillApi);
        TempGstSetup.TestField(TempGstSetup.IRNtoEwayBillSecurityToken);
        //end
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
                        tempSIV.Reset();
                        tempSIV.SetRange("No.", SalesInvoiceHeader."No.");
                        IF tempSIV.FindFirst() then;
                        // EwayJsonObject := EwayJsonToken.AsObject();                       
                        tempSIV."E-Way Bill No." := JobjToken.AsValue().AsText();
                        tempSIV.Modify(true);

                    End;
                    Message('Eway Bill Updated successfully');
                end;
            end;
        end
        Else
            Error('Bad resposnse or no resposne from Avalara, Please check with your IT team');
    end;










}
