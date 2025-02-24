// codeunit 50007 "SalesInvoiceCreditMemo"
// {
//     Permissions = tabledata "Sales Invoice Header" = rm,
//                   tabledata "Sales Cr.Memo Header" = rm;


//     procedure CreateSalesInvoiceEwayBill()
//     var
//         sasa: report 795;
//     begin
//         Initialize();


//         //RunSalesInvoiceEwayBill();
//         PayloadEwayBillFromIRN();
//         if DocumentNo <> '' then
//             GenerateEwayBillFromIRN(DocumentNo)
//         else
//             Error(DocumentNoBlankErr);
//     end;

//     procedure CreateSalesEInvoice()
//     var

//     begin

//         Initialize();

//         if IsInvoice then
//             RunSalesInvoice()
//         else
//             RunSalesCrMemo();

//         if DocumentNo <> '' then begin
//             if IsInvoice then
//                 ExportAsJsonInvoice(DocumentNo)
//             else
//                 ExportAsJsonCreditMemo(DocumentNo);
//         end
//         else
//             Error(DocumentNoBlankErr);
//     end;

//     var
//         SalesCrMemoHeader: Record "Sales Cr.Memo Header";
//         //TempTransferReceipt : Record "Transfer Receipt Header";

//         JObject: JsonObject;
//         JsonArrayData: JsonArray;
//         JsonTDSArrayGlobal: JsonArray;
//         JsonTCSArrayGlobal: JsonArray;

//         JShippingBillArray: JsonArray;
//         JewayBillArray: JsonArray;
//         JOriginaldocArray: JsonArray;
//         JECommOprMerchantArray: JsonArray;

//         IsInvoice: Boolean;

//         JsonText: Text;
//         DocumentNo: Text[20];
//         RndOffAmt: Decimal;
//         IsTransfer: Boolean;
//         eInvoiceNotApplicableCustErr: Label 'E-Invoicing is not applicable for Unregistered Customer.';
//         eInvoiceNonGSTTransactionErr: Label 'E-Invoicing is not applicable for Non-GST Transactions.';
//         DocumentNoBlankErr: Label 'E-Invoicing is not supported if document number is blank in the current document.';
//         SalesLinesMaxCountLimitErr: Label 'E-Invoice allowes only 100 lines per Invoice. Current transaction is having %1 lines.', Comment = '%1 = Sales Lines count';
//         IRNTxt: Label 'Irn', Locked = true;
//         AcknowledgementNoTxt: Label 'AckNo', Locked = true;
//         AcknowledgementDateTxt: Label 'AckDt', Locked = true;
//         IRNHashErr: Label 'No matched IRN Hash %1 found to update.', Comment = '%1 = IRN Hash';
//         SignedQRCodeTxt: Label 'SignedQRCode', Locked = true;
//         CGSTLbl: Label 'CGST', Locked = true;
//         SGSTLbl: label 'SGST', Locked = true;
//         IGSTLbl: Label 'IGST', Locked = true;
//         CESSLbl: Label 'CESS', Locked = true;
//         GenerateQRCodeErr: Label 'Dynamic QR Code generation is allowed for Unregistered customers only.';
//         B2CUPIPaymentErr: Label 'UPI ID must have a value in bank account %1. It cannot be empty', comment = '%1 BankAccount';

//         SalesInvoiceHeader: Record "Sales Invoice Header";
//     //TempTransferReceipt : Record "Transfer Receipt Header";

//     procedure SetSalesInvHeader(SalesInvoiceHeaderBuff: Record "Sales Invoice Header")
//     begin
//         SalesInvoiceHeader := SalesInvoiceHeaderBuff;
//         IsInvoice := true;
//     end;

//     procedure SetCrMemoHeader(SalesCrMemoHeaderBuff: Record "Sales Cr.Memo Header")
//     begin
//         SalesCrMemoHeader := SalesCrMemoHeaderBuff;
//         IsInvoice := false;
//     end;



//     procedure GenerateCanceledInvoice()
//     begin
//         Initialize();

//         if IsInvoice then begin
//             DocumentNo := SalesInvoiceHeader."No.";
//             WriteCancellationJSON(
//               SalesInvoiceHeader."IRN Hash", SalesInvoiceHeader."Cancel Reason", Format(SalesInvoiceHeader."Cancel Reason"))
//         end else begin
//             DocumentNo := SalesCrMemoHeader."No.";
//             WriteCancellationJSON(
//               SalesCrMemoHeader."IRN Hash", SalesCrMemoHeader."Cancel Reason", Format(SalesCrMemoHeader."Cancel Reason"));
//         end;
//         // if DocumentNo <> '' then
//         //ExportAsJson(DocumentNo);
//     end;



//     local procedure GetSalesInvoiceLineForB2CCustomer(DocumentNo: Text[20]; Var CGSTRate: Decimal; Var SGSTRate: Decimal; Var IGSTRate: Decimal; Var TotalGstAmount: Decimal)
//     Var
//         SalesInvoiceLine: Record "Sales Invoice Line";
//         CGSTValue: Decimal;
//         SGSTValue: Decimal;
//         IGSTValue: Decimal;
//     begin
//         SalesInvoiceLine.SetRange("Document No.", DocumentNo);
//         SalesInvoiceLine.LoadFields("Line No.");
//         if SalesInvoiceLine.FindSet() then
//             repeat
//                 GetGSTValueForLine(SalesInvoiceLine."Line No.", CGSTValue, SGSTValue, IGSTValue);
//                 CGSTRate += CGSTValue;
//                 SGSTRate += SGSTValue;
//                 IGSTRate += IGSTValue;
//                 TotalGstAmount += (CGSTValue + SGSTValue + IGSTValue);
//             Until SalesInvoiceLine.Next() = 0;
//     end;

//     local procedure GetBankAcUPIDetails(BankCode: Code[20]; Var BankAccNumber: Text[30]; Var IFSCCode: Text[20])
//     var
//         BankAccount: Record "Bank Account";
//     begin
//         BankAccount.Get(BankCode);
//         BankAccNumber := BankAccount."Bank Account No.";
//         IFSCCode := BankAccount."IFSC Code";
//     end;

//     local procedure GetLocationBankDetails(LocCode: Code[20]) BankCode: Code[20]
//     var
//         TaxBaseLibrary: Codeunit "Tax Base Library";
//         AccountNo: Code[20];
//         ForUPIPayments: Boolean;
//     begin
//         TaxBaseLibrary.GetVoucherAccNo(LocCode, AccountNo, ForUPIPayments);

//         if ForUPIPayments then
//             BankCode := AccountNo
//         else
//             Error(B2CUPIPaymentErr);

//         exit(BankCode);
//     end;

//     local procedure GetResponseText() ResponseText: Text
//     var
//         TempBlob: Codeunit "Temp Blob";
//         InStream: InStream;
//         FileText: Text;
//     begin
//         TempBlob.CreateInStream(InStream);
//         UploadIntoStream('', '', '', FileText, InStream);

//         if FileText = '' then
//             exit;

//         InStream.ReadText(ResponseText);
//     end;


//     local procedure WriteCancelJsonFileHeader()
//     begin

//         JObject.Add('Version', '1.1');
//         JsonArrayData.Add(JObject);
//     end;

//     local procedure WriteCancellationJSON(IRNHash: Text[64]; CancelReason: Enum "e-Invoice Cancel Reason"; CancelRemark: Text[100])
//     var
//         CancelJsonObject: JsonObject;
//     begin
//         WriteCancelJsonFileHeader();
//         CancelJsonObject.Add('Canceldtls', '');
//         CancelJsonObject.Add('IRN', IRNHash);
//         CancelJsonObject.Add('CnlRsn', Format(CancelReason));
//         CancelJsonObject.Add('CnlRem', CancelRemark);

//         JsonArrayData.Add(CancelJsonObject);
//         JObject.Add('ExpDtls', JsonArrayData);
//     end;

//     local procedure RunSalesInvoice()
//     begin
//         if not IsInvoice then
//             exit;

//         if SalesInvoiceHeader."GST Customer Type" in [
//             SalesInvoiceHeader."GST Customer Type"::Unregistered,
//             SalesInvoiceHeader."GST Customer Type"::" "]
//         then
//             Error(eInvoiceNotApplicableCustErr);

//         DocumentNo := SalesInvoiceHeader."No.";
//         WriteJsonFileHeader();
//         ReadTransactionDetails(SalesInvoiceHeader."GST Customer Type", SalesInvoiceHeader."Ship-to Code");
//         ReadDocumentHeaderDetails();
//         ReadDocumentSellerDetails();
//         ReadDocumentBuyerDetails();
//         ReadDocumentShippingDetails();
//         ReadDocumentItemList();
//         ReadDocumentTotalDetails();
//         ReadEwbDtls();
//         ReadExportDetails();
//     end;

//     local procedure RunSalesCrMemo()
//     begin
//         if IsInvoice then
//             exit;

//         if SalesCrMemoHeader."GST Customer Type" in [
//             SalesCrMemoHeader."GST Customer Type"::Unregistered,
//             SalesCrMemoHeader."GST Customer Type"::" "]
//         then
//             Error(eInvoiceNotApplicableCustErr);

//         DocumentNo := SalesCrMemoHeader."No.";
//         WriteJsonFileHeader();
//         ReadTransactionDetails(SalesCrMemoHeader."GST Customer Type", SalesCrMemoHeader."Ship-to Code");
//         ReadDocumentHeaderDetails();
//         ReadDocumentSellerDetails();
//         ReadDocumentBuyerDetails();
//         ReadDocumentShippingDetails();
//         ReadDocumentItemList();
//         ReadDocumentTotalDetails();
//         ReadExportDetails();
//     end;

//     local procedure Initialize()
//     begin
//         Clear(JObject);
//         Clear(JsonArrayData);
//         Clear(JsonText);
//     end;

//     local procedure WriteJsonFileHeader()
//     begin
//         JObject.Add('Generate', true);
//         JObject.Add('Version', '1.1');
//         JsonArrayData.Add(JObject);
//     end;

//     local procedure ReadTransactionDetails(GSTCustType: Enum "GST Customer Type"; ShipToCode: Code[12])
//     begin
//         Clear(JsonArrayData);
//         if IsInvoice then
//             ReadInvoiceTransactionDetails(GSTCustType, ShipToCode)
//         else
//             ReadCreditMemoTransactionDetails(GSTCustType, ShipToCode);
//     end;

//     local procedure ReadCreditMemoTransactionDetails(GSTCustType: Enum "GST Customer Type"; ShipToCode: Code[12])
//     var
//         SalesCrMemoLine: Record "Sales Cr.Memo Line";
//         NatureOfSupply: Text[7];
//         SupplyType: Text[3];
//         IgstOnIntra: Text[3];
//     begin
//         if IsInvoice then
//             exit;

//         case GSTCustType of
//             SalesInvoiceHeader."GST Customer Type"::Registered, SalesInvoiceHeader."GST Customer Type"::Exempted:
//                 NatureOfSupply := 'B2B';

//             SalesInvoiceHeader."GST Customer Type"::Export:
//                 if SalesInvoiceHeader."GST Without Payment of Duty" then
//                     NatureOfSupply := 'EXPWOP'
//                 else
//                     NatureOfSupply := 'EXPWP';

//             SalesInvoiceHeader."GST Customer Type"::"Deemed Export":
//                 NatureOfSupply := 'DEXP';

//             SalesInvoiceHeader."GST Customer Type"::"SEZ Development", SalesInvoiceHeader."GST Customer Type"::"SEZ Unit":
//                 if SalesInvoiceHeader."GST Without Payment of Duty" then
//                     NatureOfSupply := 'SEZWOP'
//                 else
//                     NatureOfSupply := 'SEZWP';
//         end;

//         if ShipToCode <> '' then begin
//             SalesCrMemoLine.SetRange("Document No.", DocumentNo);
//             if SalesCrMemoLine.FindSet() then
//                 repeat
//                     if SalesCrMemoLine."GST Place of Supply" = SalesCrMemoLine."GST Place of Supply"::"Ship-to Address" then
//                         SupplyType := 'REG'
//                     else
//                         SupplyType := 'SHP';
//                 until SalesCrMemoLine.Next() = 0;
//         end else
//             SupplyType := 'REG';

//         if SalesCrMemoHeader."POS Out Of India" then
//             IgstOnIntra := 'Y'
//         else
//             IgstOnIntra := 'N';

//         WriteTransactionDetails(NatureOfSupply, 'N', '', IgstOnIntra);
//     end;

//     local procedure ReadInvoiceTransactionDetails(GSTCustType: Enum "GST Customer Type"; ShipToCode: Code[12])
//     var
//         SalesInvoiceLine: Record "Sales Invoice Line";
//         NatureOfSupplyCategory: Text[7];
//         SupplyType: Text[3];
//         IgstOnIntra: Text[3];
//     begin
//         if not IsInvoice then
//             exit;

//         case GSTCustType of
//             SalesInvoiceHeader."GST Customer Type"::Registered, SalesInvoiceHeader."GST Customer Type"::Exempted:
//                 NatureOfSupplyCategory := 'B2B';

//             SalesInvoiceHeader."GST Customer Type"::Export:
//                 if SalesInvoiceHeader."GST Without Payment of Duty" then
//                     NatureOfSupplyCategory := 'EXPWOP'
//                 else
//                     NatureOfSupplyCategory := 'EXPWP';

//             SalesInvoiceHeader."GST Customer Type"::"Deemed Export":
//                 NatureOfSupplyCategory := 'DEXP';

//             SalesInvoiceHeader."GST Customer Type"::"SEZ Development", SalesInvoiceHeader."GST Customer Type"::"SEZ Unit":
//                 IF SalesInvoiceHeader."GST Without Payment of Duty" THEN
//                     NatureOfSupplyCategory := 'SEZWOP'
//                 ELSE
//                     NatureOfSupplyCategory := 'SEZWP';
//         end;

//         if ShipToCode <> '' then begin
//             SalesInvoiceLine.SetRange("Document No.", DocumentNo);
//             if SalesInvoiceLine.FindSet() then
//                 repeat
//                     if SalesInvoiceLine."GST Place of Supply" <> SalesInvoiceLine."GST Place of Supply"::"Ship-to Address" then
//                         SupplyType := 'SHP'
//                     else
//                         SupplyType := 'REG';
//                 until SalesInvoiceLine.Next() = 0;
//         end else
//             SupplyType := 'REG';

//         if SalesInvoiceHeader."POS Out Of India" then
//             IgstOnIntra := 'Y'
//         else
//             IgstOnIntra := 'N';

//         WriteTransactionDetails(NatureOfSupplyCategory, 'N', '', IgstOnIntra);
//     end;

//     local procedure WriteTransactionDetails(
//         SupplyCategory: Text[7];
//         RegRev: Text[2];
//         EcmGstin: Text[15];
//         IgstOnIntra: Text[3])
//     var
//         JTranDetails: JsonObject;
//     begin
//         JTranDetails.Add('TaxSch', 'GST');
//         JTranDetails.Add('SupTyp', SupplyCategory);
//         JTranDetails.Add('RegRev', RegRev);

//         if EcmGstin <> '' then
//             JTranDetails.Add('EcmGstin', EcmGstin);

//         JTranDetails.Add('IgstOnIntra', IgstOnIntra);

//         JObject.Add('TranDtls', JTranDetails);
//     end;

//     local procedure ReadDocumentHeaderDetails()
//     var
//         InvoiceType: Text[3];
//         PostingDate: Text[10];
//         OriginalInvoiceNo: Text[16];
//     begin
//         Clear(JsonArrayData);
//         if IsInvoice then begin
//             if (SalesInvoiceHeader."Invoice Type" = SalesInvoiceHeader."Invoice Type"::"Debit Note") or
//                (SalesInvoiceHeader."Invoice Type" = SalesInvoiceHeader."Invoice Type"::Supplementary)
//             then
//                 InvoiceType := 'DBN'
//             else
//                 InvoiceType := 'INV';
//             PostingDate := Format(SalesInvoiceHeader."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>');
//         end else begin
//             InvoiceType := 'CRN';
//             PostingDate := Format(SalesCrMemoHeader."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>');
//         end;

//         OriginalInvoiceNo := CopyStr(GetReferenceInvoiceNo(DocumentNo), 1, 16);
//         WriteDocumentHeaderDetails(InvoiceType, CopyStr(DocumentNo, 1, 16), PostingDate, OriginalInvoiceNo);
//     end;

//     local procedure WriteDocumentHeaderDetails(InvoiceType: Text[3]; DocumentNo: Text[16]; PostingDate: Text[10]; OriginalInvoiceNo: Text[16])
//     var
//         JDocumentHeaderDetails: JsonObject;
//     begin
//         JDocumentHeaderDetails.Add('Typ', InvoiceType);
//         JDocumentHeaderDetails.Add('No', DocumentNo);
//         JDocumentHeaderDetails.Add('Dt', PostingDate);
//         JDocumentHeaderDetails.Add('OrgInvNo', OriginalInvoiceNo);

//         JObject.Add('DocDtls', JDocumentHeaderDetails);
//     end;

//     local procedure ReadExportDetails()
//     begin
//         Clear(JsonArrayData);
//         if IsInvoice then
//             ReadInvoiceExportDetails()
//         else
//             ReadCrMemoExportDetails();
//     end;

//     local procedure ReadCrMemoExportDetails()
//     var
//         SalesCrMemoLine: Record "Sales Cr.Memo Line";
//         ExportCategory: Text[3];
//         WithPayOfDuty: Text[1];
//         ShipmentBillNo: Text[16];
//         ShipmentBillDate: Text[10];
//         ExitPort: Text[10];
//         DocumentAmount: Decimal;
//         CurrencyCode: Text[3];
//         CountryCode: Text[2];
//     begin
//         if IsInvoice then
//             exit;

//         if not (SalesCrMemoHeader."GST Customer Type" in [
//             SalesCrMemoHeader."GST Customer Type"::Export,
//             SalesCrMemoHeader."GST Customer Type"::"Deemed Export",
//             SalesCrMemoHeader."GST Customer Type"::"SEZ Unit",
//             SalesCrMemoHeader."GST Customer Type"::"SEZ Development"])
//         then
//             exit;

//         case SalesCrMemoHeader."GST Customer Type" of
//             SalesCrMemoHeader."GST Customer Type"::Export:
//                 ExportCategory := 'DIR';
//             SalesCrMemoHeader."GST Customer Type"::"Deemed Export":
//                 ExportCategory := 'DEM';
//             SalesCrMemoHeader."GST Customer Type"::"SEZ Unit":
//                 ExportCategory := 'SEZ';
//             "GST Customer Type"::"SEZ Development":
//                 ExportCategory := 'SED';
//         end;

//         if SalesCrMemoHeader."GST Without Payment of Duty" then
//             WithPayOfDuty := 'N'
//         else
//             WithPayOfDuty := 'Y';

//         ShipmentBillNo := CopyStr(SalesCrMemoHeader."Bill Of Export No.", 1, 16);
//         ShipmentBillDate := Format(SalesCrMemoHeader."Bill Of Export Date", 0, '<Day,2>/<Month,2>/<Year4>');
//         ExitPort := SalesCrMemoHeader."Exit Point";

//         SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
//         if SalesCrMemoLine.FindSet() then
//             repeat
//                 DocumentAmount := DocumentAmount + SalesCrMemoLine.Amount;
//             until SalesCrMemoLine.Next() = 0;

//         CurrencyCode := CopyStr(SalesCrMemoHeader."Currency Code", 1, 3);
//         CountryCode := CopyStr(SalesCrMemoHeader."Bill-to Country/Region Code", 1, 2);

//         WriteExportDetails(WithPayOfDuty, ShipmentBillNo, ShipmentBillDate, ExitPort, CurrencyCode, CountryCode);
//     end;

//     local procedure ReadInvoiceExportDetails()
//     var
//         SalesInvoiceLine: Record "Sales Invoice Line";
//         ExportCategory: Text[3];
//         WithPayOfDuty: Text[1];
//         ShipmentBillNo: Text[16];
//         ShipmentBillDate: Text[10];
//         ExitPort: Text[10];
//         DocumentAmount: Decimal;
//         CurrencyCode: Text[3];
//         CountryCode: Text[2];
//     begin
//         if not IsInvoice then
//             exit;

//         if not (SalesInvoiceHeader."GST Customer Type" in [
//             SalesInvoiceHeader."GST Customer Type"::Export,
//             SalesInvoiceHeader."GST Customer Type"::"Deemed Export",
//             SalesInvoiceHeader."GST Customer Type"::"SEZ Unit",
//             SalesInvoiceHeader."GST Customer Type"::"SEZ Development"])
//         then
//             exit;

//         case SalesInvoiceHeader."GST Customer Type" of
//             SalesInvoiceHeader."GST Customer Type"::Export:
//                 ExportCategory := 'DIR';
//             SalesInvoiceHeader."GST Customer Type"::"Deemed Export":
//                 ExportCategory := 'DEM';
//             SalesInvoiceHeader."GST Customer Type"::"SEZ Unit":
//                 ExportCategory := 'SEZ';
//             SalesInvoiceHeader."GST Customer Type"::"SEZ Development":
//                 ExportCategory := 'SED';
//         end;

//         if SalesInvoiceHeader."GST Without Payment of Duty" then
//             WithPayOfDuty := 'N'
//         else
//             WithPayOfDuty := 'Y';

//         ShipmentBillNo := CopyStr(SalesInvoiceHeader."Bill Of Export No.", 1, 16);
//         ShipmentBillDate := Format(SalesInvoiceHeader."Bill Of Export Date", 0, '<Day,2>/<Month,2>/<Year4>');
//         ExitPort := SalesInvoiceHeader."Exit Point";

//         SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
//         if SalesInvoiceLine.FindSet() then
//             repeat
//                 DocumentAmount := DocumentAmount + SalesInvoiceLine.Amount;
//             until SalesInvoiceLine.Next() = 0;

//         CurrencyCode := CopyStr(SalesInvoiceHeader."Currency Code", 1, 3);
//         CountryCode := CopyStr(SalesInvoiceHeader."Bill-to Country/Region Code", 1, 2);

//         WriteExportDetails(WithPayOfDuty, ShipmentBillNo, ShipmentBillDate, ExitPort, CurrencyCode, CountryCode);
//     end;

//     local procedure WriteExportDetails(
//         WithPayOfDuty: Text[1];
//         ShipmentBillNo: Text[16];
//         ShipmentBillDate: Text[10];
//         ExitPort: Text[10];
//         CurrencyCode: Text[3];
//         CountryCode: Text[2])
//     var
//         JExpDetails: JsonObject;
//     begin
//         JExpDetails.Add('ShipBNo', ShipmentBillNo);
//         JExpDetails.Add('ShipBDt', ShipmentBillDate);
//         JExpDetails.Add('Port', ExitPort);
//         JExpDetails.Add('RefClm', WithPayOfDuty);
//         JExpDetails.Add('ForCur', CurrencyCode);
//         JExpDetails.Add('CntCode', CountryCode);

//         JObject.Add('ExpDtls', JExpDetails);
//     end;

//     local procedure ReadDocumentSellerDetails()
//     var
//         CompanyInformationBuff: Record "Company Information";
//         LocationBuff: Record "Location";
//         StateBuff: Record "State";
//         GSTRegistrationNo: Text[20];
//         CompanyName: Text[100];
//         Address: Text[100];
//         Address2: Text[100];
//         Flno: Text[60];
//         Loc: Text[60];
//         City: Text[60];
//         StateCode: Text[10];
//         PhoneNumber: Text[10];
//         Email: Text[50];
//         Pin: Integer;
//         PhoneNoValidation: Text[30];
//     begin
//         Clear(JsonArrayData);
//         if IsInvoice then begin
//             GSTRegistrationNo := SalesInvoiceHeader."Location GST Reg. No.";
//             LocationBuff.Get(SalesInvoiceHeader."Location Code");
//         end else begin
//             GSTRegistrationNo := SalesCrMemoHeader."Location GST Reg. No.";
//             LocationBuff.Get(SalesCrMemoHeader."Location Code");
//         end;

//         CompanyInformationBuff.Get();
//         CompanyName := CompanyInformationBuff.Name;
//         Address := LocationBuff.Address;
//         Address2 := LocationBuff."Address 2";
//         Flno := '';
//         Loc := '';
//         City := LocationBuff.City;
//         if LocationBuff."Post Code" <> '' then
//             Evaluate(Pin, (CopyStr(LocationBuff."Post Code", 1, 6)))
//         else
//             Pin := 000000;

//         StateBuff.Get(LocationBuff."State Code");
//         StateCode := StateBuff."State Code (GST Reg. No.)";

//         if LocationBuff."Phone No." <> '' then
//             PhoneNumber := CopyStr(LocationBuff."Phone No.", 1, 10)
//         else
//             PhoneNumber := '000000';

//         if LocationBuff."E-Mail" <> '' then
//             Email := CopyStr(LocationBuff."E-Mail", 1, 50)
//         else
//             Email := '0000@00';

//         PhoneNoValidation := '!@*()+=-[]\\\;,./{}|\":<>?';
//         PhoneNumber := DelChr(PhoneNumber, '=', PhoneNoValidation);
//         WriteSellerDetails(GSTRegistrationNo, CompanyName, Address, Address2, City, Pin, StateCode, PhoneNumber, Email);
//     end;

//     local procedure WriteSellerDetails(
//         GSTRegistrationNo: Text[20];
//         CompanyName: Text[100];
//         Address: Text[100];
//         Address2: Text[100];
//         City: Text[60];
//         PostCode: Integer;
//         StateCode: Text[10];
//         PhoneNumber: Text[10];
//         Email: Text[50])
//     var
//         JSellerDetails: JsonObject;
//     begin
//         JSellerDetails.Add('Gstin', GSTRegistrationNo);//GSTRegistrationNo);//hardcoded need to change
//         JSellerDetails.Add('LglNm', CompanyName);
//         JSellerDetails.Add('Addr1', Address);

//         if Address2 <> '' then
//             JSellerDetails.Add('Addr2', Address2);

//         JSellerDetails.Add('Loc', City);
//         JSellerDetails.Add('Pin', PostCode);//Hard coded need to change later PostCode
//         JSellerDetails.Add('Stcd', StateCode);///Hard coded need to change later

//         if PhoneNumber <> '' then
//             JSellerDetails.Add('Ph', PhoneNumber)
//         else
//             JSellerDetails.Add('Ph', '000000');

//         if Email <> '' then
//             JSellerDetails.Add('Em', Email)
//         else
//             JSellerDetails.Add('Em', '0000@00');

//         JObject.Add('SellerDtls', JSellerDetails);
//     end;

//     local procedure ReadDocumentBuyerDetails()
//     begin
//         Clear(JsonArrayData);
//         if IsInvoice then
//             ReadInvoiceBuyerDetails()
//         else
//             ReadCrMemoBuyerDetails();
//     end;

//     local procedure ReadInvoiceBuyerDetails()
//     var
//         Contact: Record Contact;
//         SalesInvoiceLine: Record "Sales Invoice Line";
//         ShiptoAddress: Record "Ship-to Address";
//         StateBuff: Record State;
//         GSTRegistrationNumber: Text[20];
//         CompanyName: Text[100];
//         Address: Text[100];
//         Address2: Text[100];
//         Floor: Text[60];
//         AddressLocation: Text[60];
//         City: Text[60];
//         StateCode: Text[10];
//         PhoneNumber: Text[10];
//         Email: Text[50];
//         Pin: Integer;
//         PhoneNoValidation: Text[30];
//     begin
//         if SalesInvoiceHeader."Customer GST Reg. No." <> '' then
//             GSTRegistrationNumber := SalesInvoiceHeader."Customer GST Reg. No."
//         else
//             GSTRegistrationNumber := 'URP';

//         CompanyName := SalesInvoiceHeader."Bill-to Name";
//         Address := SalesInvoiceHeader."Bill-to Address";
//         Address2 := SalesInvoiceHeader."Bill-to Address 2";
//         Floor := '';
//         AddressLocation := '';
//         City := SalesInvoiceHeader."Bill-to City";

//         if SalesInvoiceHeader."Bill-to Post Code" <> '' then
//             Evaluate(Pin, (CopyStr(SalesInvoiceHeader."Bill-to Post Code", 1, 6)))
//         else
//             Pin := 000000;

//         SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
//         SalesInvoiceLine.SetFilter(Type, '<>%1', SalesInvoiceLine.Type::" ");
//         if SalesInvoiceLine.FindFirst() then
//             case SalesInvoiceLine."GST Place of Supply" of
//                 SalesInvoiceLine."GST Place of Supply"::"Bill-to Address":
//                     begin
//                         if not (SalesInvoiceHeader."GST Customer Type" = SalesInvoiceHeader."GST Customer Type"::Export) then begin
//                             StateBuff.Get(SalesInvoiceHeader."GST Bill-to State Code");
//                             StateCode := StateBuff."State Code (GST Reg. No.)";
//                         end else
//                             StateCode := '';

//                         if Contact.Get(SalesInvoiceHeader."Bill-to Contact No.") then begin
//                             PhoneNumber := CopyStr(Contact."Phone No.", 1, 10);
//                             Email := CopyStr(Contact."E-Mail", 1, 50);
//                         end else begin
//                             PhoneNumber := '';
//                             Email := '';
//                         end;
//                     end;

//                 SalesInvoiceLine."GST Place of Supply"::"Ship-to Address":
//                     begin
//                         if not (SalesInvoiceHeader."GST Customer Type" = SalesInvoiceHeader."GST Customer Type"::Export) then begin
//                             StateBuff.Get(SalesInvoiceHeader."GST Ship-to State Code");
//                             StateCode := StateBuff."State Code (GST Reg. No.)";
//                         end else
//                             StateCode := '';

//                         if ShiptoAddress.Get(SalesInvoiceHeader."Sell-to Customer No.", SalesInvoiceHeader."Ship-to Code") then begin
//                             PhoneNumber := CopyStr(ShiptoAddress."Phone No.", 1, 10);
//                             Email := CopyStr(ShiptoAddress."E-Mail", 1, 50);
//                         end else begin
//                             PhoneNumber := '';
//                             Email := '';
//                         end;
//                     end;
//                 else begin
//                     StateCode := '';
//                     PhoneNumber := '';
//                     Email := '';
//                 end;
//             end;

//         PhoneNoValidation := '!@*()+=-[]\\\;,./{}|\":<>?';
//         PhoneNumber := DelChr(PhoneNumber, '=', PhoneNoValidation);
//         WriteBuyerDetails(GSTRegistrationNumber, CompanyName, Address, Address2, City, Pin, StateCode, PhoneNumber, Email);
//     end;

//     local procedure ReadCrMemoBuyerDetails()
//     var
//         Contact: Record Contact;
//         SalesCrMemoLine: Record "Sales Cr.Memo Line";
//         ShiptoAddress: Record "Ship-to Address";
//         StateBuff: Record State;
//         GSTRegistrationNumber: Text[20];
//         CompanyName: Text[100];
//         Address: Text[100];
//         Address2: Text[100];
//         Floor: Text[60];
//         AddressLocation: Text[60];
//         City: Text[60];
//         Pin: Integer;
//         StateCode: Text[10];
//         PhoneNumber: Text[10];
//         Email: Text[50];
//         PhoneNoValidation: Text[30];
//     begin
//         if SalesCrMemoHeader."Customer GST Reg. No." <> '' then
//             GSTRegistrationNumber := SalesCrMemoHeader."Customer GST Reg. No."
//         else
//             GSTRegistrationNumber := 'URP';
//         CompanyName := SalesCrMemoHeader."Bill-to Name";
//         Address := SalesCrMemoHeader."Bill-to Address";
//         Address2 := SalesCrMemoHeader."Bill-to Address 2";
//         Floor := '';
//         AddressLocation := '';
//         City := SalesCrMemoHeader."Bill-to City";
//         if SalesCrMemoHeader."Bill-to Post Code" <> '' then
//             Evaluate(Pin, (CopyStr(SalesCrMemoHeader."Bill-to Post Code", 1, 6)))
//         else
//             Pin := 000000;

//         StateCode := '';
//         PhoneNumber := '';
//         Email := '';
//         SalesCrMemoLine.Reset();
//         SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
//         SalesCrMemoLine.SetFilter("No.", '<>%1', '');
//         if SalesCrMemoLine.FindFirst() then
//             case SalesCrMemoLine."GST Place of Supply" of

//                 SalesCrMemoLine."GST Place of Supply"::"Bill-to Address":
//                     begin
//                         if not (SalesCrMemoHeader."GST Customer Type" = SalesCrMemoHeader."GST Customer Type"::Export) then begin
//                             StateBuff.Get(SalesCrMemoHeader."GST Bill-to State Code");
//                             StateCode := StateBuff."State Code (GST Reg. No.)";
//                         end;

//                         if Contact.Get(SalesCrMemoHeader."Bill-to Contact No.") then begin
//                             PhoneNumber := CopyStr(Contact."Phone No.", 1, 10);
//                             Email := CopyStr(Contact."E-Mail", 1, 50);
//                         end;
//                     end;

//                 SalesCrMemoLine."GST Place of Supply"::"Ship-to Address":
//                     begin
//                         if not (SalesCrMemoHeader."GST Customer Type" = SalesCrMemoHeader."GST Customer Type"::Export) then begin
//                             StateBuff.Get(SalesCrMemoHeader."GST Ship-to State Code");
//                             StateCode := StateBuff."State Code (GST Reg. No.)";
//                         end;

//                         if ShiptoAddress.Get(SalesCrMemoHeader."Sell-to Customer No.", SalesCrMemoHeader."Ship-to Code") then begin
//                             PhoneNumber := CopyStr(ShiptoAddress."Phone No.", 1, 10);
//                             Email := CopyStr(ShiptoAddress."E-Mail", 1, 50);
//                         end;
//                     end;
//             end;

//         PhoneNoValidation := '!@*()+=-[]\\\;,./{}|\":<>?';
//         PhoneNumber := DelChr(PhoneNumber, '=', PhoneNoValidation);
//         WriteBuyerDetails(GSTRegistrationNumber, CompanyName, Address, Address2, City, Pin, StateCode, PhoneNumber, Email);
//     end;

//     local procedure WriteBuyerDetails(
//         GSTRegistrationNumber: Text[20];
//         CompanyName: Text[100];
//         Address: Text[100];
//         Address2: Text[100];
//         City: Text[60];
//         Pin: Integer;
//         StateCode: Text[10];
//         PhoneNumber: Text[10];
//         EmailID: Text[50])
//     var
//         JBuyerDetails: JsonObject;
//     begin
//         JBuyerDetails.Add('Gstin', GSTRegistrationNumber);//29AAECH1917Q1Z2 harded need to change later
//         JBuyerDetails.Add('LglNm', CompanyName);

//         if StateCode <> '' then
//             JBuyerDetails.Add('POS', StateCode) //29 harded coded need to chane later
//         else
//             JBuyerDetails.Add('POS', '29');

//         JBuyerDetails.Add('Addr1', Address);

//         if Address2 <> '' then
//             JBuyerDetails.Add('Addr2', Address2);

//         JBuyerDetails.Add('Loc', City);
//         JBuyerDetails.Add('Stcd', StateCode);//'29' harded coded
//         JBuyerDetails.Add('Pin', Pin);//'560001'

//         if PhoneNumber <> '' then
//             JBuyerDetails.Add('Ph', PhoneNumber)
//         else
//             JBuyerDetails.Add('Ph', '000000');

//         if EmailID <> '' then
//             JBuyerDetails.Add('Em', EmailID)
//         else
//             JBuyerDetails.Add('Em', '0000@00');

//         JObject.Add('BuyerDtls', JBuyerDetails);
//     end;

//     local procedure ReadDocumentShippingDetails()
//     var
//         ShiptoAddress: Record "Ship-to Address";
//         StateBuff: Record State;
//         GSTRegistrationNumber: Text[20];
//         CompanyName: Text[100];
//         Address: Text[100];
//         Address2: Text[100];
//         Floor: Text[60];
//         AddressLocation: Text[60];
//         City: Text[60];
//         PostCode: Text[6];
//         StateCode: Text[10];
//         PhoneNumber: Text[10];
//         EmailID: Text[50];
//     begin
//         Clear(JsonArrayData);
//         if IsInvoice and (SalesInvoiceHeader."Ship-to Code" <> '') then begin
//             ShiptoAddress.Get(SalesInvoiceHeader."Sell-to Customer No.", SalesInvoiceHeader."Ship-to Code");
//             StateBuff.Get(SalesInvoiceHeader."GST Ship-to State Code");
//             CompanyName := SalesInvoiceHeader."Ship-to Name";
//             Address := SalesInvoiceHeader."Ship-to Address";
//             Address2 := SalesInvoiceHeader."Ship-to Address 2";
//             City := SalesInvoiceHeader."Ship-to City";
//             PostCode := CopyStr(SalesInvoiceHeader."Ship-to Post Code", 1, 6);
//         end else
//             if SalesCrMemoHeader."Ship-to Code" <> '' then begin
//                 ShiptoAddress.Get(SalesCrMemoHeader."Sell-to Customer No.", SalesCrMemoHeader."Ship-to Code");
//                 StateBuff.Get(SalesCrMemoHeader."GST Ship-to State Code");
//                 CompanyName := SalesCrMemoHeader."Ship-to Name";
//                 Address := SalesCrMemoHeader."Ship-to Address";
//                 Address2 := SalesCrMemoHeader."Ship-to Address 2";
//                 City := SalesCrMemoHeader."Ship-to City";
//                 PostCode := CopyStr(SalesCrMemoHeader."Ship-to Post Code", 1, 6);
//             end;
//         if ShiptoAddress."GST Registration No." <> '' then
//             GSTRegistrationNumber := ShiptoAddress."GST Registration No."
//         else
//             GSTRegistrationNumber := SalesInvoiceHeader."Location GST Reg. No.";
//         Floor := '';
//         AddressLocation := '';
//         StateCode := StateBuff."State Code for eTDS/TCS";
//         PhoneNumber := CopyStr(ShiptoAddress."Phone No.", 1, 10);
//         EmailID := CopyStr(ShiptoAddress."E-Mail", 1, 50);
//         WriteShippingDetails(GSTRegistrationNumber, CompanyName, Address, Address2, AddressLocation, PostCode, StateCode);
//     end;

//     local procedure WriteShippingDetails(
//         GSTRegistrationNumber: Text[20];
//         CompanyName: Text[100];
//         Address: Text[100];
//         Address2: Text[100];
//         AddressLocation: Text[60];
//         PostCode: Text[6];
//         StateCode: Text[10])
//     var
//         Pin: Integer;
//         JShippingDetails: JsonObject;
//     begin
//         Pin := 000000;
//         JShippingDetails.Add('Gstin', GSTRegistrationNumber);
//         JShippingDetails.Add('LglNm', CompanyName);
//         JShippingDetails.Add('TrdNm', CompanyName);
//         JShippingDetails.Add('Addr1', Address);

//         if Address2 <> '' then
//             JShippingDetails.Add('Addr2', Address2);

//         JShippingDetails.Add('Loc', AddressLocation);

//         if PostCode <> '' then
//             JShippingDetails.Add('Pin', PostCode)
//         else
//             JShippingDetails.Add('Pin', Pin);

//         JShippingDetails.Add('Stcd', StateCode);

//         if CompanyName <> '' then
//             JObject.Add('ShipDtls', JShippingDetails);
//     end;

//     local procedure ReadDocumentTotalDetails()
//     var
//         AssessableAmount: Decimal;
//         CGSTAmount: Decimal;
//         SGSTAmount: Decimal;
//         IGSTAmount: Decimal;
//         CessAmount: Decimal;
//         StateCessAmount: Decimal;
//         CESSNonAvailmentAmount: Decimal;
//         DiscountAmount: Decimal;
//         OtherCharges: Decimal;
//         TotalInvoiceValue: Decimal;
//     begin
//         Clear(JsonArrayData);
//         GetGSTValue(AssessableAmount, CGSTAmount, SGSTAmount, IGSTAmount, CessAmount, StateCessAmount, CESSNonAvailmentAmount, DiscountAmount, OtherCharges, TotalInvoiceValue);
//         WriteDocumentTotalDetails(AssessableAmount, CGSTAmount, SGSTAmount, IGSTAmount, CessAmount, CESSNonAvailmentAmount, DiscountAmount, OtherCharges, TotalInvoiceValue);
//     end;

//     local procedure WriteDocumentTotalDetails(
//         AssessableAmount: Decimal;
//         CGSTAmount: Decimal;
//         SGSTAmount: Decimal;
//         IGSTAmount: Decimal;
//         CessAmount: Decimal;
//         CessNonAdvanceVal: Decimal;
//         DiscountAmount: Decimal;
//         OtherCharges: Decimal;
//         TotalInvoiceAmount: Decimal)
//     var
//         JDocTotalDetails: JsonObject;
//         RoundOffAmt: Integer;
//     begin
//         RoundOffAmt := 0;
//         JDocTotalDetails.Add('Assval', AssessableAmount);
//         JDocTotalDetails.Add('CgstVal', CGSTAmount);
//         JDocTotalDetails.Add('SgstVAl', SGSTAmount);
//         JDocTotalDetails.Add('IgstVal', IGSTAmount);
//         JDocTotalDetails.Add('CesVal', CessAmount);
//         JDocTotalDetails.Add('CesNonAdVal', CessNonAdvanceVal);
//         JDocTotalDetails.Add('Disc', DiscountAmount);
//         JDocTotalDetails.Add('OthChrg', OtherCharges);

//         if RndOffAmt = 0 then
//             JDocTotalDetails.Add('RndOffAmt', RoundOffAmt)
//         else
//             JDocTotalDetails.Add('RndOffAmt', RndOffAmt);

//         JDocTotalDetails.Add('TotInvVal', TotalInvoiceAmount);

//         JObject.Add('ValDtls', JDocTotalDetails);
//     end;

//     local procedure ReadEwbDtls()
//     var
//         SalesInvHeader: Record "Sales Invoice Header";
//         ShippingAgent: Record "Shipping Agent";
//         TransID: Text[15];
//         TransName: Text[100];
//         TransMode: Text[20];
//         Distance: Integer;
//         TransDocNo: Text[20];
//         TransDocDt: Text[10];
//         TransportDocDt: Text[10];
//         VehNo: Text[20];
//         VehType: Text[1];
//     begin
//         TransDocNo := '';
//         if IsInvoice then
//             if SalesInvHeader.Get(DocumentNo) then begin
//                 if ShippingAgent.Get(SalesInvHeader."Shipping Agent Code") then begin
//                     TransID := ShippingAgent."GST Registration No.";
//                     TransName := ShippingAgent.Name;
//                 end;

//                 TransMode := SalesInvHeader."Mode of Transport";
//                 TransDocNo := SalesInvHeader."No.";
//                 TransDocDt := Format(SalesInvoiceHeader."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>');
//                 Distance := SalesInvHeader."Distance (Km)";
//                 VehNo := SalesInvHeader."Vehicle No.";
//                 if SalesInvHeader."Vehicle Type" <> SalesInvHeader."Vehicle Type"::" " then
//                     if SalesInvHeader."Vehicle Type" = SalesInvHeader."Vehicle Type"::ODC then
//                         VehType := 'O'
//                     else
//                         VehType := 'R'
//                 else
//                     VehType := '';
//             end;


//         if TransportDocDt <> '' then
//             TransDocDt := TransportDocDt;

//         if (Distance = 0) and (VehNo = '') and (VehType = '') and (TransMode = '') then
//             exit;

//         WriteEWayBillTotalDetails(TransID, TransName, TransMode, Distance, TransDocNo, TransDocDt, VehNo, VehType);
//     end;

//     local procedure WriteEWayBillTotalDetails(
//         TransId: Text[15];
//         TransName: Text[100];
//         TransMode: Text[1];
//         Distance: Integer;
//         TransDocNo: Text[20];
//         TransDocDt: Text[10];
//         VehNo: Text[20];
//         VehType: Text[1])
//     var
//         JDocEwayDetails: JsonObject;
//     begin
//         if TransId = '' then
//             JDocEwayDetails.Add('TransId', 'null')
//         else
//             JDocEwayDetails.Add('TransId', TransId);

//         if TransName = '' then
//             JDocEwayDetails.Add('TransName', 'null')
//         else
//             JDocEwayDetails.Add('TransName', TransName);

//         JDocEwayDetails.Add('TransMode', TransMode);
//         JDocEwayDetails.Add('Distance', Distance);

//         if TransDocNo = '' then
//             JDocEwayDetails.Add('TransDocNo', 'null')
//         else
//             JDocEwayDetails.Add('TransDocNo', TransDocNo);

//         JDocEwayDetails.Add('TransDocDt', TransDocDt);
//         JDocEwayDetails.Add('VehNo', VehNo);
//         JDocEwayDetails.Add('VehType', VehType);

//         JObject.Add('EwbDtls', JDocEwayDetails);
//     end;

//     local procedure ReadDocumentItemList()
//     var
//         SalesInvoiceLine: Record "Sales Invoice Line";
//         SalesCrMemoLine: Record "Sales Cr.Memo Line";
//         AssessableAmount: Decimal;
//         GstRate: Integer;
//         HSNHAC: Record "HSN/SAC";//PT-FBTS
//         CGSTRate: Decimal;
//         SGSTRate: Decimal;
//         IGSTRate: Decimal;
//         CessRate: Decimal;
//         CesNonAdval: Decimal;
//         StateCess: Decimal;
//         CGSTValue: Decimal;
//         SGSTValue: Decimal;
//         IGSTValue: Decimal;
//         IsServc: Text[1];
//         Count: Integer;
//         UnitofMeasure: Record "Unit of Measure";
//         UCQ: Code[10];
//     begin
//         Count := 1;
//         Clear(JsonArrayData);
//         if IsInvoice then begin
//             SalesInvoiceLine.SetRange("Document No.", DocumentNo);
//             SalesInvoiceLine.SetFilter(Type, '<>%1', SalesInvoiceLine.Type::" ");
//             if SalesInvoiceLine.FindSet() then begin
//                 if SalesInvoiceLine.Count > 100 then
//                     Error(SalesLinesMaxCountLimitErr, SalesInvoiceLine.Count);
//                 repeat
//                     if SalesInvoiceLine."GST Assessable Value (LCY)" <> 0 then
//                         AssessableAmount := SalesInvoiceLine."GST Assessable Value (LCY)"
//                     else
//                         AssessableAmount := SalesInvoiceLine.Amount;
//                     //PT-FBTS 25-07-24
//                     HSNHAC.Reset();
//                     HSNHAC.SetRange(Code, SalesInvoiceLine."HSN/SAC Code");
//                     if HSNHAC.FindFirst() then
//                         if HSNHAC.Type = HSNHAC.type::HSN then begin
//                             IsServc := 'N'
//                         end
//                         else
//                             IsServc := 'Y';
//                     //PT-FBTS 25-07-24
//                     // if SalesInvoiceLine."GST Group Type" = SalesInvoiceLine."GST Group Type"::Goods then PT-FBTS 25-07-24 OLDCode
//                     //     IsServc := 'N'
//                     // else
//                     //     IsServc := 'Y';

//                     GetGSTComponentRate(SalesInvoiceLine."Document No.", SalesInvoiceLine."Line No."
//                     , CGSTRate, SGSTRate, IGSTRate, CessRate, CesNonAdval, StateCess);

//                     if SalesInvoiceLine."GST Jurisdiction Type" = SalesInvoiceLine."GST Jurisdiction Type"::Intrastate then
//                         GstRate := CGSTRate + SGSTRate
//                     else
//                         GstRate := IGSTRate;

//                     UnitofMeasure.Reset();
//                     UnitofMeasure.SetRange(Code, SalesInvoiceLine."Unit of Measure Code");
//                     IF UnitofMeasure.FindFirst() then;
//                     UCQ := UnitofMeasure.UCQ;

//                     GetGSTValueForLine(SalesInvoiceLine."Line No.", CGSTValue, SGSTValue, IGSTValue);
//                     if SalesInvoiceLine."No." <> GetInvoiceRoundingAccountForInvoice() then
//                         WriteItem(
//                           Format(Count),
//                           SalesInvoiceLine.Description + SalesInvoiceLine."Description 2",
//                           SalesInvoiceLine."HSN/SAC Code",
//                           GstRate, SalesInvoiceLine.Quantity,
//                           UCQ,
//                           SalesInvoiceLine."Unit Price",
//                           SalesInvoiceLine."Line Amount" + SalesInvoiceLine."Line Discount Amount",
//                           SalesInvoiceLine."Line Discount Amount", 0,
//                           AssessableAmount, CGSTValue, SGSTValue, IGSTValue, CessRate, CesNonAdval,
//                           AssessableAmount + CGSTValue + SGSTValue + IGSTValue,
//                           IsServc)
//                     else
//                         RndOffAmt := SalesInvoiceLine.Amount;
//                     Count += 1;
//                 until SalesInvoiceLine.Next() = 0;
//             end;

//             JObject.Add('ItemList', JsonArrayData);
//         end else begin
//             SalesCrMemoLine.SetRange("Document No.", DocumentNo);
//             SalesCrMemoLine.SetFilter(Type, '<>%1', SalesCrMemoLine.Type::" ");
//             if SalesCrMemoLine.FindSet() then begin
//                 if SalesCrMemoLine.Count > 100 then
//                     Error(SalesLinesMaxCountLimitErr, SalesCrMemoLine.Count);

//                 repeat
//                     if SalesCrMemoLine."GST Assessable Value (LCY)" <> 0 then
//                         AssessableAmount := SalesCrMemoLine."GST Assessable Value (LCY)"
//                     else
//                         AssessableAmount := SalesCrMemoLine.Amount;

//                     if SalesCrMemoLine."GST Group Type" = SalesCrMemoLine."GST Group Type"::Goods then
//                         IsServc := 'N'
//                     else
//                         IsServc := 'Y';

//                     GetGSTComponentRate(
//                         SalesCrMemoLine."Document No.",
//                         SalesCrMemoLine."Line No.",
//                         CGSTRate,
//                         SGSTRate,
//                         IGSTRate,
//                         CessRate,
//                         CesNonAdval,
//                         StateCess);

//                     if SalesCrMemoLine."GST Jurisdiction Type" = SalesCrMemoLine."GST Jurisdiction Type"::Intrastate then
//                         GstRate := CGSTRate + SGSTRate
//                     else
//                         GstRate := IGSTRate;

//                     UnitofMeasure.Reset();
//                     UnitofMeasure.SetRange(Code, SalesCrMemoLine."Unit of Measure Code");
//                     IF UnitofMeasure.FindFirst() then;
//                     UCQ := UnitofMeasure.UCQ;


//                     GetGSTValueForLine(SalesCrMemoLine."Line No.", CGSTValue, SGSTValue, IGSTValue);
//                     if SalesCrMemoLine."No." <> GetInvoiceRoundingAccountForCreditMemo() then
//                         WriteItem(
//                           Format(Count),
//                           SalesCrMemoLine.Description + SalesCrMemoLine."Description 2",
//                           SalesCrMemoLine."HSN/SAC Code", GstRate,
//                           SalesCrMemoLine.Quantity,
//                           UCQ,
//                           SalesCrMemoLine."Unit Price",
//                           SalesCrMemoLine."Line Amount" + SalesCrMemoLine."Line Discount Amount",
//                           SalesCrMemoLine."Line Discount Amount", 0,
//                           AssessableAmount, CGSTValue, SGSTValue, IGSTValue, CessRate, CesNonAdval,
//                           AssessableAmount + CGSTValue + SGSTValue + IGSTValue,
//                           IsServc)
//                     else
//                         RndOffAmt := SalesCrMemoLine.Amount;

//                     Count += 1;
//                 until SalesCrMemoLine.Next() = 0;
//             end;

//             JObject.Add('ItemList', JsonArrayData);
//         end;
//     end;

//     local procedure GetInvoiceRoundingAccountForInvoice(): Code[20]
//     var
//         SalesInvoiceHeader: Record "Sales Invoice Header";
//         CustomerPostingGroup: Record "Customer Posting Group";
//     begin
//         if not SalesInvoiceHeader.Get(DocumentNo) then
//             exit;

//         if not CustomerPostingGroup.Get(SalesInvoiceHeader."Customer Posting Group") then
//             exit;

//         exit(CustomerPostingGroup."Invoice Rounding Account");
//     end;

//     local procedure GetInvoiceRoundingAccountForCreditMemo(): Code[20]
//     var
//         SalesCrMemoHeader: Record "Sales Cr.Memo Header";
//         CustomerPostingGroup: Record "Customer Posting Group";
//     begin
//         if not SalesCrMemoHeader.Get(DocumentNo) then
//             exit;

//         if not CustomerPostingGroup.Get(SalesCrMemoHeader."Customer Posting Group") then
//             exit;

//         exit(CustomerPostingGroup."Invoice Rounding Account");
//     end;

//     local procedure WriteItem(
//         SlNo: Text[3];
//         ProductName: Text;
//         HSNCode: Text[10];
//         GstRate: Integer;
//         Quantity: Decimal;
//         Unit: Text[3];
//         UnitPrice: Decimal;
//         TotAmount: Decimal;
//         Discount: Decimal;
//         OtherCharges: Decimal;
//         AssessableAmount: Decimal;
//         CGSTRate: Decimal;
//         SGSTRate: Decimal;
//         IGSTRate: Decimal;
//         CESSRate: Decimal;
//         CessNonAdvanceAmount: Decimal;
//         TotalItemValue: Decimal;
//         IsServc: Text[1])
//     var
//         JItem: JsonObject;
//     begin
//         JItem.Add('SlNo', SlNo);
//         JItem.Add('PrdDesc', ProductName);
//         JItem.Add('IsServc', IsServc);
//         JItem.Add('HsnCd', HSNCode);//hardcoded Need to change
//         JItem.Add('Qty', Quantity);
//         JItem.Add('Unit', Unit);//hardcoded Need to change
//         JItem.Add('UnitPrice', UnitPrice);
//         JItem.Add('TotAmt', TotAmount);
//         JItem.Add('Discount', Discount);
//         JItem.Add('OthChrg', OtherCharges);
//         JItem.Add('AssAmt', AssessableAmount);
//         JItem.Add('GstRt', GstRate);
//         JItem.Add('CgstAmt', CGSTRate);
//         JItem.Add('SgstAmt', SGSTRate);
//         JItem.Add('IgstAmt', IGSTRate);
//         JItem.Add('CesRt', CESSRate);
//         JItem.Add('CesAmt', 0);

//         JItem.Add('CesNonAdval', CessNonAdvanceAmount);
//         JItem.Add('TotItemVal', TotalItemValue);

//         JsonArrayData.Add(JItem);
//     end;

//     local procedure ExportAsJsonInvoice(FileName: Text[20])
//     var
//         TempBlob: Codeunit "Temp Blob";
//         ToFile: Variant;
//         InStream: InStream;
//         OutStream: OutStream;
//         RecRef: RecordRef;

//         client: HttpClient;
//         request: HttpRequestMessage;
//         response: HttpResponseMessage;
//         contentHeaders: HttpHeaders;
//         content: HttpContent;
//         responseText: Text;
//         AccessToken: Text;
//         JobjectResponse: JsonObject;
//         JobjToken: JsonToken;
//         Jobjarr: JsonArray;
//         ackno: Text;
//         i: Integer;
//         ackdatetimetext: text;
//         AcknowledgementDate: Date;
//         Acknowledgementtime: Time;
//         TempDateTime: DateTime;
//         SignedQRCodeTxt1: Text;
//         QRGenerator: Codeunit "QR Generator";
//         TempBlob2: Codeunit "Temp Blob";
//         FieldRef: FieldRef;
//         errorDetailsJsonToken: JsonToken;
//         errorDetailsJsonObject: JsonObject;
//         JobjErrorarr: JsonArray;
//         j: integer;
//         TempGstSetup: Record "GST Setup";

//     begin
//         //to check avala Api
//         TempGstSetup.Get();
//         //TempGstSetup.TestField(TempGstSetup.AvalaraEinvoiceApi);//PT-FBTS 25-07-24
//         TempGstSetup.TestField(TempGstSetup.EinvoiceSecurityToken);

//         //end
//         JsonArrayData.Add(JObject);
//         JsonArrayData.WriteTo(JsonText);
//         TempBlob.CreateOutStream(OutStream);
//         OutStream.WriteText(JsonText);
//         ToFile := FileName + '.json';
//         TempBlob.CreateInStream(InStream);
//         DownloadFromStream(InStream, 'e-Invoice', '', '', ToFile);
//         Sleep(1000);
//         //
//         //fe28e9b25dfe9390fb23a5dca981bf6a9f629950da954aa322f490a7dcf244e5
//         AccessToken := TempGstSetup.EinvoiceSecurityToken;
//         //'fe28e9b25dfe9390fb23a5dca981bf6a9f629950da954aa322f490a7dcf244e5';
//         content.WriteFrom(JsonText);

//         // Retrieve the contentHeaders associated with the content
//         content.GetHeaders(contentHeaders);
//         contentHeaders.Clear();
//         contentHeaders.Add('Content-Type', 'application/json');
//         //contentHeaders.Add('gstin', '29AAECH1917Q1Z2');
//         //  contentHeaders.Add('Authorization', 'Bearer fe28e9b25dfe9390fb23a5dca981bf6a9f629950da954aa322f490a7dcf244e5');

//         client.DefaultRequestHeaders.Add('Authorization', 'Bearer ' + AccessToken);

//         // Assigning content to request.Content will actually create a copy of the content and assign it.
//         // After this line, modifying the content variable or its associated headers will not reflect in 
//         // the content associated with the request message
//         request.Content := content;
//         //https://www.sandbox-gstapi.trustfilegst.in/einvoice/api/v1/EInvoice/27AAAPI3182M002/GenerateEinvoiceGSTNFormat
//         request.SetRequestUri(TempGstSetup.AvalaraEinvoiceApi);
//         request.SetRequestUri('https://www.gstapi.trustfilegst.in/einvoice/api/v1/EInvoice/' + SalesInvoiceHeader."Location GST Reg. No." + '/GenerateEinvoiceGSTNFormat');//PT-FBTS 25-07-24
//         request.Method := 'POST';

//         client.Send(request, response);
//         if response.IsSuccessStatusCode then begin
//             response.Content().ReadAs(responseText);
//             // Message(responseText);
//             // JobjectResponse.ReadFrom(responseText);
//             //  Message(format(JobjectResponse));

//             if JobjToken.ReadFrom(responseText) then begin
//                 if JobjToken.IsArray then   // json_Token.IsArray; json_Token.IsObject; json_Token.IsValue;
//                     Jobjarr := JobjToken.AsArray();
//                 for i := 0 to Jobjarr.Count() - 1 do begin
//                     // Get First Array Result
//                     Jobjarr.Get(i, JobjToken);
//                     // Convert JsonToken to JsonObject
//                     if JobjToken.IsObject then begin
//                         JobjectResponse := JobjToken.AsObject();

//                         //for error
//                         if JobjectResponse.Get('errorDetails', errorDetailsJsonToken) then begin
//                             if errorDetailsJsonToken.IsArray then   // json_Token.IsArray; json_Token.IsObject; json_Token.IsValue;
//                                 JobjErrorarr := errorDetailsJsonToken.AsArray();
//                             for j := 0 to JobjErrorarr.Count() - 1 do begin

//                                 // Get First Array Result
//                                 JobjErrorarr.Get(i, errorDetailsJsonToken);
//                                 if errorDetailsJsonToken.IsObject then begin
//                                     errorDetailsJsonObject := errorDetailsJsonToken.AsObject();
//                                     errorDetailsJsonObject.Get('errorCode', errorDetailsJsonToken);
//                                     IF (errorDetailsJsonToken.AsValue().AsText() <> '') then begin
//                                         errorDetailsJsonObject.Get('errorMessage', errorDetailsJsonToken);
//                                         Error(errorDetailsJsonToken.AsValue().AsText());
//                                     end;
//                                 end;

//                             end;
//                         end;

//                         JobjectResponse.Get('ackNo', JobjToken);
//                         SalesInvoiceHeader."Acknowledgement No." := JobjToken.AsValue().AsText();
//                         // Message(ackno);

//                         JobjectResponse.Get('irn', JobjToken);
//                         SalesInvoiceHeader."IRN Hash" := JobjToken.AsValue().AsText();

//                         JobjectResponse.Get('ackDt', JobjToken);
//                         ackdatetimetext := JobjToken.AsValue().AsText();
//                         Evaluate(AcknowledgementDate, CopyStr(ackdatetimetext, 1, 10));
//                         Evaluate(AcknowledgementTime, CopyStr(ackdatetimetext, 12, 8));
//                         TempDateTime := CreateDateTime(AcknowledgementDate, AcknowledgementTime);
//                         SalesInvoiceHeader."Acknowledgement Date" := TempDateTime;

//                         SalesInvoiceHeader.IsJSONImported := true;
//                         SalesInvoiceHeader.Modify();
//                         Clear(RecRef);

//                         RecRef.GetTable(SalesInvoiceHeader);
//                         JobjectResponse.Get('encodedSignedQRCode', JobjToken);
//                         SignedQRCodeTxt1 := JobjToken.AsValue().AsText();

//                         QRGenerator.GenerateQRCodeImage(SignedQRCodeTxt1, TempBlob2);
//                         FieldRef := RecRef.Field(SalesInvoiceHeader.FieldNo("QR Code"));
//                         TempBlob2.ToRecordRef(RecRef, SalesInvoiceHeader.FieldNo("QR Code"));
//                         RecRef.Modify();
//                         Commit();

//                         Message('Ack no and IRN number generated sussessfully');
//                     end;

//                 end;
//             end;


//         end
//         Else
//             Error('Bad request / No response from Avalara , please check with IT team');


//     end;

//     local procedure ExportAsJsonCreditMemo(FileName: Text[20])
//     var
//         TempBlob: Codeunit "Temp Blob";
//         ToFile: Variant;
//         InStream: InStream;
//         OutStream: OutStream;
//         RecRef: RecordRef;

//         client: HttpClient;
//         request: HttpRequestMessage;
//         response: HttpResponseMessage;
//         contentHeaders: HttpHeaders;
//         content: HttpContent;
//         responseText: Text;
//         AccessToken: Text;
//         JobjectResponse: JsonObject;
//         JobjToken: JsonToken;
//         Jobjarr: JsonArray;
//         ackno: Text;
//         i: Integer;
//         ackdatetimetext: text;
//         AcknowledgementDate: Date;
//         Acknowledgementtime: Time;
//         TempDateTime: DateTime;
//         SignedQRCodeTxt1: Text;
//         QRGenerator: Codeunit "QR Generator";
//         TempBlob2: Codeunit "Temp Blob";
//         FieldRef: FieldRef;
//         errorDetailsJsonToken: JsonToken;
//         errorDetailsJsonObject: JsonObject;
//         JobjErrorarr: JsonArray;
//         j: integer;
//         TempGstSetup: Record "GST Setup";


//     begin
//         //to check avala Api
//         TempGstSetup.Get();
//         TempGstSetup.TestField(TempGstSetup.AvalaraEinvoiceApi);
//         TempGstSetup.TestField(TempGstSetup.EinvoiceSecurityToken);

//         //end

//         JsonArrayData.Add(JObject);
//         JsonArrayData.WriteTo(JsonText);
//         TempBlob.CreateOutStream(OutStream);
//         OutStream.WriteText(JsonText);
//         ToFile := FileName + '.json';
//         TempBlob.CreateInStream(InStream);
//         DownloadFromStream(InStream, 'e-Credit Memo', '', '', ToFile);
//         Sleep(1000);

//         AccessToken := TempGstSetup.EinvoiceSecurityToken;//'fe28e9b25dfe9390fb23a5dca981bf6a9f629950da954aa322f490a7dcf244e5';
//         //'fe28e9b25dfe9390fb23a5dca981bf6a9f629950da954aa322f490a7dcf244e5';
//         content.WriteFrom(JsonText);

//         // Retrieve the contentHeaders associated with the content
//         content.GetHeaders(contentHeaders);
//         contentHeaders.Clear();
//         contentHeaders.Add('Content-Type', 'application/json');
//         //contentHeaders.Add('gstin', '29AAECH1917Q1Z2');
//         //  contentHeaders.Add('Authorization', 'Bearer fe28e9b25dfe9390fb23a5dca981bf6a9f629950da954aa322f490a7dcf244e5');

//         client.DefaultRequestHeaders.Add('Authorization', 'Bearer ' + AccessToken);

//         // Assigning content to request.Content will actually create a copy of the content and assign it.
//         // After this line, modifying the content variable or its associated headers will not reflect in 
//         // the content associated with the request message
//         request.Content := content;
//         //https://www.sandbox-gstapi.trustfilegst.in/einvoice/api/v1/EInvoice/27AAAPI3182M002/GenerateEinvoiceGSTNFormat
//         request.SetRequestUri(TempGstSetup.AvalaraEinvoiceApi);
//         request.Method := 'POST';

//         client.Send(request, response);
//         if response.IsSuccessStatusCode then begin
//             response.Content().ReadAs(responseText);
//             // Message(responseText);
//             // JobjectResponse.ReadFrom(responseText);
//             //  Message(format(JobjectResponse));

//             if JobjToken.ReadFrom(responseText) then begin
//                 if JobjToken.IsArray then   // json_Token.IsArray; json_Token.IsObject; json_Token.IsValue;
//                     Jobjarr := JobjToken.AsArray();
//                 for i := 0 to Jobjarr.Count() - 1 do begin
//                     // Get First Array Result
//                     Jobjarr.Get(i, JobjToken);
//                     // Convert JsonToken to JsonObject
//                     if JobjToken.IsObject then begin
//                         JobjectResponse := JobjToken.AsObject();

//                         //for error
//                         if JobjectResponse.Get('errorDetails', errorDetailsJsonToken) then begin
//                             if errorDetailsJsonToken.IsArray then   // json_Token.IsArray; json_Token.IsObject; json_Token.IsValue;
//                                 JobjErrorarr := errorDetailsJsonToken.AsArray();
//                             for j := 0 to JobjErrorarr.Count() - 1 do begin

//                                 // Get First Array Result
//                                 JobjErrorarr.Get(i, errorDetailsJsonToken);
//                                 if errorDetailsJsonToken.IsObject then begin
//                                     errorDetailsJsonObject := errorDetailsJsonToken.AsObject();
//                                     errorDetailsJsonObject.Get('errorCode', errorDetailsJsonToken);
//                                     IF (errorDetailsJsonToken.AsValue().AsText() <> '') then begin
//                                         errorDetailsJsonObject.Get('errorMessage', errorDetailsJsonToken);
//                                         Error(errorDetailsJsonToken.AsValue().AsText());
//                                     end;
//                                 end;

//                             end;
//                         end;

//                         JobjectResponse.Get('ackNo', JobjToken);
//                         SalesCrMemoHeader."Acknowledgement No." := JobjToken.AsValue().AsText();


//                         JobjectResponse.Get('irn', JobjToken);
//                         SalesCrMemoHeader."IRN Hash" := JobjToken.AsValue().AsText();

//                         JobjectResponse.Get('ackDt', JobjToken);
//                         ackdatetimetext := JobjToken.AsValue().AsText();
//                         Evaluate(AcknowledgementDate, CopyStr(ackdatetimetext, 1, 10));
//                         Evaluate(AcknowledgementTime, CopyStr(ackdatetimetext, 12, 8));
//                         TempDateTime := CreateDateTime(AcknowledgementDate, AcknowledgementTime);
//                         SalesCrMemoHeader."Acknowledgement Date" := TempDateTime;

//                         SalesCrMemoHeader.IsJSONImported := true;
//                         SalesCrMemoHeader.Modify();
//                         Clear(RecRef);

//                         RecRef.GetTable(SalesCrMemoHeader);
//                         JobjectResponse.Get('encodedSignedQRCode', JobjToken);
//                         SignedQRCodeTxt1 := JobjToken.AsValue().AsText();

//                         QRGenerator.GenerateQRCodeImage(SignedQRCodeTxt1, TempBlob2);
//                         FieldRef := RecRef.Field(SalesCrMemoHeader.FieldNo("QR Code"));
//                         TempBlob2.ToRecordRef(RecRef, SalesCrMemoHeader.FieldNo("QR Code"));
//                         RecRef.Modify();
//                         Commit();

//                         Message('Ack no and IRN number generated successfully');
//                     end;

//                 end;
//             end;


//         end
//         Else
//             Error('Bad request / No response from Avalara , please check with IT team');

//     end;


//     /*
//         procedure GetInvoicePdf()
//         var

//             TempBlob1: Codeunit "Temp Blob";


//             ToFile1: Variant;
//             InStream: InStream;
//             OutStream: OutStream;
//             inFile: Codeunit "File Management";

//             client1: HttpClient;
//             request1: HttpRequestMessage;
//             response1: HttpResponseMessage;
//             contentHeaders1: HttpHeaders;
//             content1: HttpContent;
//             responseText1: Text;
//             responseText2: Byte;
//             json_Token: JsonToken;

//             AccessToken1: Text;
//             contentHeaders: HttpHeaders;
//             Base64Convert: Codeunit "Base64 Convert";

//             downloadpdfBlob: Record PdfBlob;

//             Base64Text: text;





//         begin
//             AccessToken1 := 'fe28e9b25dfe9390fb23a5dca981bf6a9f629950da954aa322f490a7dcf244e5';

//             client1.DefaultRequestHeaders.Add('Authorization', 'Bearer ' + AccessToken1);

//             request1.SetRequestUri('https://www.sandbox-gstapi.trustfilegst.in/einvoice/api/v2/EInvoiceV2/29AAAPI3182M000/pdf?irn=4c8e01aed33ef8f3b36d32e181798b135049acc6260796bc1233ac96392e50b0&invoiceNumber=DOC/D37QR/1667');
//             request1.Method := 'GET';

//             client1.Send(request1, response1);
//             response1.Content().ReadAs(responseText1);

//             responseText1 := Base64Convert.ToBase64(responseText1);

//             if CreateFile(responseText1) then
//                 Message('Thank you for downloading html content from: ');


//             /*
//                     ToFile1 := '123.pdf';
//                     downloadpdfBlob.DeleteAll();
//                     downloadpdfBlob.Init();

//                     downloadpdfBlob.ID := 1;
//                     downloadpdfBlob.MypdfBlob.CreateOutStream(OutStream, TextEncoding::Windows);
//                     OutStream.Write(responseText1);
//                     downloadpdfBlob.Insert();
//                     if downloadpdfBlob.Get('1') then;
//                     downloadpdfBlob.CalcFields(MypdfBlob);

//                     Message(Format(downloadpdfBlob.MypdfBlob));


//                     downloadpdfBlob.MypdfBlob.CreateInStream(InStream, TextEncoding::Windows);
//                     DownloadFromStream(InStream, 'e-Invoice', '', '', ToFile1);

//             */

//     // inFile.BLOBExport(InStream, '123.pdf', true);

//     /*

//             ToFile1 := '123.pdf';

//             //Download(responseText1, '', 'E:\', '', ToFile1);
//             TempBlob1.CreateOutStream(OutStream);

//             OutStream.Write(inFile.GetFileContents(responseText1));

//             TempBlob1.CreateInStream(InStream);

//             DownloadFromStream(InStream, 'e-Invoice', '', '', ToFile1);

//     */


//     // Read the response content as json.
//     //response1.Content().ReadAs(responseText1);




//     // Message(responseText1);
//     /*
//             TempBlob1.CreateOutStream(OutStream);
//             //tempconvertBinary.FromBase64(responseText1);
//             // tempconvertBinary.StreamToBase64String()

//             //  OutStream.Write();
//             ToFile1 := '123.pdf';
//             TempBlob1.CreateInStream(InStream);
//             DownloadFromStream(InStream, 'e-Invoice', '', '', ToFile1);
//             //inFile.BLOBExport()






// end;
// */
//     procedure CreateFile(content5: Text): Boolean
//     var
//         inStr: InStream;
//         outStr: OutStream;
//         tempBlob: Codeunit "Temp Blob";
//         fileName: Text;
//         Base64Convert: Codeunit "Base64 Convert";

//     begin
//         // Create the outstream
//         fileName := '123.pdf';

//         tempBlob.CreateOutStream(outStr);

//         Base64Convert.FromBase64(content5, outstr);

//         //FromBase64(base64, outstr);
//         // Wrtie to the text file
//         outStr.WriteText(content5);

//         // Create instream and download to the user
//         tempBlob.CreateInStream(inStr);
//         //DownloadFromStream(inStr, '', '', '', fileName);
//         exit(true);
//     end;



//     local procedure GetReferenceInvoiceNo(DocNo: Code[20]) RefInvNo: Code[20]
//     var
//         ReferenceInvoiceNo: Record "Reference Invoice No.";
//     begin
//         ReferenceInvoiceNo.SetRange("Document No.", DocNo);
//         if ReferenceInvoiceNo.FindFirst() then
//             RefInvNo := ReferenceInvoiceNo."Reference Invoice Nos."
//         else
//             RefInvNo := '';
//     end;

//     local procedure GetGSTComponentRate(
//         DocumentNo: Code[20];
//         LineNo: Integer;
//         var CGSTRate: Decimal;
//         var SGSTRate: Decimal;
//         var IGSTRate: Decimal;
//         var CessRate: Decimal;
//         var CessNonAdvanceAmount: Decimal;
//         var StateCess: Decimal)
//     var
//         DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
//     begin
//         DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
//         DetailedGSTLedgerEntry.SetRange("Document Line No.", LineNo);
//         DetailedGSTLedgerEntry.SetRange("GST Component Code", CGSTLbl);
//         if DetailedGSTLedgerEntry.FindFirst() then
//             CGSTRate := DetailedGSTLedgerEntry."GST %"
//         else
//             CGSTRate := 0;
//         DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);//PT-FBTS
//         DetailedGSTLedgerEntry.SetRange("Document Line No.", LineNo);////PT-FBTS
//         DetailedGSTLedgerEntry.SetRange("GST Component Code", SGSTLbl);
//         if DetailedGSTLedgerEntry.FindFirst() then
//             SGSTRate := DetailedGSTLedgerEntry."GST %"
//         else
//             SGSTRate := 0;

//         DetailedGSTLedgerEntry.SetRange("GST Component Code", IGSTLbl);
//         if DetailedGSTLedgerEntry.FindFirst() then
//             IGSTRate := DetailedGSTLedgerEntry."GST %"
//         else
//             IGSTRate := 0;

//         CessRate := 0;
//         CessNonAdvanceAmount := 0;
//         DetailedGSTLedgerEntry.SetRange("GST Component Code", CESSLbl);
//         if DetailedGSTLedgerEntry.FindFirst() then
//             if DetailedGSTLedgerEntry."GST %" > 0 then
//                 CessRate := DetailedGSTLedgerEntry."GST %"
//             else
//                 CessNonAdvanceAmount := Abs(DetailedGSTLedgerEntry."GST Amount");

//         StateCess := 0;
//         DetailedGSTLedgerEntry.SetRange("GST Component Code");
//         if DetailedGSTLedgerEntry.FindSet() then
//             repeat
//                 if not (DetailedGSTLedgerEntry."GST Component Code" in [CGSTLbl, SGSTLbl, IGSTLbl, CESSLbl])
//                 then
//                     StateCess := DetailedGSTLedgerEntry."GST %";
//             until DetailedGSTLedgerEntry.Next() = 0;
//     end;

//     local procedure GetGSTValue(
//         var AssessableAmount: Decimal;
//         var CGSTAmount: Decimal;
//         var SGSTAmount: Decimal;
//         var IGSTAmount: Decimal;
//         var CessAmount: Decimal;
//         var StateCessValue: Decimal;
//         var CessNonAdvanceAmount: Decimal;
//         var DiscountAmount: Decimal;
//         var OtherCharges: Decimal;
//         var TotalInvoiceValue: Decimal)
//     var
//         SalesInvoiceLine: Record "Sales Invoice Line";
//         SalesCrMemoLine: Record "Sales Cr.Memo Line";
//         GSTLedgerEntry: Record "GST Ledger Entry";
//         DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
//         CurrencyExchangeRate: Record "Currency Exchange Rate";
//         CustLedgerEntry: Record "Cust. Ledger Entry";
//         TotGSTAmt: Decimal;
//     begin
//         GSTLedgerEntry.SetRange("Document No.", DocumentNo);

//         GSTLedgerEntry.SetRange("GST Component Code", CGSTLbl);
//         if GSTLedgerEntry.FindSet() then
//             repeat
//                 CGSTAmount += Abs(GSTLedgerEntry."GST Amount");
//             until GSTLedgerEntry.Next() = 0
//         else
//             CGSTAmount := 0;

//         GSTLedgerEntry.SetRange("GST Component Code", SGSTLbl);
//         if GSTLedgerEntry.FindSet() then
//             repeat
//                 SGSTAmount += Abs(GSTLedgerEntry."GST Amount")
//             until GSTLedgerEntry.Next() = 0
//         else
//             SGSTAmount := 0;

//         GSTLedgerEntry.SetRange("GST Component Code", IGSTLbl);
//         if GSTLedgerEntry.FindSet() then
//             repeat
//                 IGSTAmount += Abs(GSTLedgerEntry."GST Amount")
//             until GSTLedgerEntry.Next() = 0
//         else
//             IGSTAmount := 0;

//         CessAmount := 0;
//         CessNonAdvanceAmount := 0;

//         DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
//         DetailedGSTLedgerEntry.SetRange("GST Component Code", CESSLbl);
//         if DetailedGSTLedgerEntry.FindFirst() then
//             repeat
//                 if DetailedGSTLedgerEntry."GST %" > 0 then
//                     CessAmount += Abs(DetailedGSTLedgerEntry."GST Amount")
//                 else
//                     CessNonAdvanceAmount += Abs(DetailedGSTLedgerEntry."GST Amount");
//             until GSTLedgerEntry.Next() = 0;

//         GSTLedgerEntry.SetFilter("GST Component Code", '<>CGST|<>SGST|<>IGST|<>CESS');
//         if GSTLedgerEntry.FindSet() then
//             repeat
//                 StateCessValue += Abs(GSTLedgerEntry."GST Amount");
//             until GSTLedgerEntry.Next() = 0;

//         if IsInvoice then begin
//             SalesInvoiceLine.SetRange("Document No.", DocumentNo);
//             if SalesInvoiceLine.FindSet() then
//                 repeat
//                     AssessableAmount += SalesInvoiceLine.Amount;
//                     DiscountAmount += SalesInvoiceLine."Inv. Discount Amount";
//                 until SalesInvoiceLine.Next() = 0;
//             TotGSTAmt := CGSTAmount + SGSTAmount + IGSTAmount + CessAmount + CessNonAdvanceAmount + StateCessValue;

//             AssessableAmount := Round(
//                 CurrencyExchangeRate.ExchangeAmtFCYToLCY(
//                   WorkDate(), SalesInvoiceHeader."Currency Code", AssessableAmount, SalesInvoiceHeader."Currency Factor"), 0.01, '=');
//             TotGSTAmt := Round(
//                 CurrencyExchangeRate.ExchangeAmtFCYToLCY(
//                   WorkDate(), SalesInvoiceHeader."Currency Code", TotGSTAmt, SalesInvoiceHeader."Currency Factor"), 0.01, '=');
//             DiscountAmount := Round(
//                 CurrencyExchangeRate.ExchangeAmtFCYToLCY(
//                   WorkDate(), SalesInvoiceHeader."Currency Code", DiscountAmount, SalesInvoiceHeader."Currency Factor"), 0.01, '=');
//         end else begin
//             SalesCrMemoLine.SetRange("Document No.", DocumentNo);
//             if SalesCrMemoLine.FindSet() then begin
//                 repeat
//                     AssessableAmount += SalesCrMemoLine.Amount;
//                     DiscountAmount += SalesCrMemoLine."Inv. Discount Amount";
//                 until SalesCrMemoLine.Next() = 0;
//                 TotGSTAmt := CGSTAmount + SGSTAmount + IGSTAmount + CessAmount + CessNonAdvanceAmount + StateCessValue;
//             end;

//             AssessableAmount := Round(
//                 CurrencyExchangeRate.ExchangeAmtFCYToLCY(
//                     WorkDate(),
//                     SalesCrMemoHeader."Currency Code",
//                     AssessableAmount,
//                     SalesCrMemoHeader."Currency Factor"),
//                     0.01,
//                     '=');

//             TotGSTAmt := Round(
//                 CurrencyExchangeRate.ExchangeAmtFCYToLCY(
//                     WorkDate(),
//                     SalesCrMemoHeader."Currency Code",
//                     TotGSTAmt,
//                     SalesCrMemoHeader."Currency Factor"),
//                     0.01,
//                     '=');

//             DiscountAmount := Round(
//                 CurrencyExchangeRate.ExchangeAmtFCYToLCY(
//                     WorkDate(),
//                     SalesCrMemoHeader."Currency Code",
//                     DiscountAmount,
//                     SalesCrMemoHeader."Currency Factor"),
//                     0.01,
//                     '=');
//         end;

//         CustLedgerEntry.SetCurrentKey("Document No.");
//         CustLedgerEntry.SetRange("Document No.", DocumentNo);
//         if IsInvoice then begin
//             CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
//             CustLedgerEntry.SetRange("Customer No.", SalesInvoiceHeader."Bill-to Customer No.");
//         end else begin
//             CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
//             CustLedgerEntry.SetRange("Customer No.", SalesCrMemoHeader."Bill-to Customer No.");
//         end;

//         if CustLedgerEntry.FindFirst() then begin
//             CustLedgerEntry.CalcFields("Amount (LCY)");
//             TotalInvoiceValue := Abs(CustLedgerEntry."Amount (LCY)");
//         end;

//         OtherCharges := 0;
//     end;

//     local procedure GetGSTValueForLine(
//         DocumentLineNo: Integer;
//         var CGSTLineAmount: Decimal;
//         var SGSTLineAmount: Decimal;
//         var IGSTLineAmount: Decimal)
//     var
//         DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
//     begin
//         CGSTLineAmount := 0;
//         SGSTLineAmount := 0;
//         IGSTLineAmount := 0;

//         DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
//         DetailedGSTLedgerEntry.SetRange("Document Line No.", DocumentLineNo);
//         DetailedGSTLedgerEntry.SetRange("GST Component Code", CGSTLbl);
//         if DetailedGSTLedgerEntry.FindSet() then
//             repeat
//                 CGSTLineAmount += Abs(DetailedGSTLedgerEntry."GST Amount");
//             until DetailedGSTLedgerEntry.Next() = 0;

//         DetailedGSTLedgerEntry.SetRange("GST Component Code", SGSTLbl);
//         if DetailedGSTLedgerEntry.FindSet() then
//             repeat
//                 SGSTLineAmount += Abs(DetailedGSTLedgerEntry."GST Amount")
//             until DetailedGSTLedgerEntry.Next() = 0;

//         DetailedGSTLedgerEntry.SetRange("GST Component Code", IGSTLbl);
//         if DetailedGSTLedgerEntry.FindSet() then
//             repeat
//                 IGSTLineAmount += Abs(DetailedGSTLedgerEntry."GST Amount")
//             until DetailedGSTLedgerEntry.Next() = 0;
//     end;

//     procedure GenerateIRN(input: Text): Text
//     var
//         CryptographyManagement: Codeunit "Cryptography Management";
//         HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512;
//     begin
//         exit(CryptographyManagement.GenerateHash(input, HashAlgorithmType::SHA256));
//     end;


//     ///sales invoice Eway bill start
//     local procedure PayloadEwayBillFromIRN()
//     var
//         transporterId: Text[20];
//         modeOfTransport: Text[10];
//         documentNumber: Text[20];
//         distance: Text;
//         documentDate: Text;
//         vehicleNo: Text;
//         vehicleType: text;
//         ShippingAgent: Record "Shipping Agent";
//         dist3: Integer;
//         dist1: Decimal;
//         VehType: Text[30];
//         tempSIV: Record "Sales Invoice Header";
//     begin

//         tempSIV.Reset();
//         tempSIV.SetRange("No.", SalesInvoiceHeader."No.");
//         IF tempSIV.FindFirst() then;
//         tempSIV.TestField("IRN Hash");
//         tempSIV.TestField("Shipping Agent Code");



//         DocumentNo := tempSIV."No.";

//         if ShippingAgent.Get(tempSIV."Shipping Agent Code") then;

//         JObject.Add('Irn', tempSIV."IRN Hash");

//         IF tempSIV."Distance (Km)" <> 0 then begin
//             dist1 := tempSIV."Distance (Km)";
//             Evaluate(dist3, format(dist1));
//             JObject.Add('Distance', dist3);
//         end
//         else
//             JObject.Add('Distance', 0);

//         JObject.Add('TransMode', tempSIV."Mode of Transport");

//         JObject.Add('TransId', ShippingAgent."GST Registration No.");

//         JObject.Add('TransName', ShippingAgent.Name);

//         JObject.Add('TrnDocNo', tempSIV."No.");
//         JObject.Add('TrnDocDt', tempSIV."Posting Date");

//         JObject.Add('VehNo', tempSIV."Vehicle No.");

//         if tempSIV."Vehicle Type" <> tempSIV."Vehicle Type"::" " then
//             if tempSIV."Vehicle Type" = tempSIV."Vehicle Type"::ODC then
//                 VehType := 'Over Dimensional Cargo'
//             else
//                 VehType := 'Regular'
//         else
//             VehType := '';

//         JObject.Add('VehType', VehType);








//     End;


//     local procedure GenerateEwayBillFromIRN(FileName: Text[20])
//     var
//         TempBlob: Codeunit "Temp Blob";
//         ToFile: Variant;
//         InStream: InStream;
//         OutStream: OutStream;
//         client: HttpClient;
//         request: HttpRequestMessage;
//         response: HttpResponseMessage;
//         contentHeaders: HttpHeaders;
//         content: HttpContent;
//         responseText: Text;

//         AccessToken: Text;
//         JobjectResponse: JsonObject;
//         JobjToken: JsonToken;
//         Jobjarr: JsonArray;
//         ackno: Text;
//         i: Integer;
//         ackdatetimetext: text;
//         AcknowledgementDate: Date;
//         Acknowledgementtime: Time;
//         TempDateTime: DateTime;
//         SignedQRCodeTxt1: Text;
//         QRGenerator: Codeunit "QR Generator";
//         TempBlob2: Codeunit "Temp Blob";
//         FieldRef: FieldRef;
//         EwayJsonToken: JsonToken;
//         EwayJsonObject: JsonObject;
//         errorDetailsJsonToken: JsonToken;
//         j: Integer;
//         JobjErrorarr: JsonArray;
//         errorDetailsJsonObject: JsonObject;
//         tempSIV: Record "Sales Invoice Header";
//         TempMsg: Text;
//         TempGstSetup: Record "GST Setup";

//     begin
//         // JsonArrayData.Add(JObject);
//         // JsonArrayData.WriteTo(JsonText);

//         //to check avala Api
//         TempGstSetup.Get();

//         TempGstSetup.TestField(TempGstSetup.IRNtoEwayBillApi);
//         TempGstSetup.TestField(TempGstSetup.IRNtoEwayBillSecurityToken);
//         //end
//         JObject.WriteTo(JsonText);

//         TempBlob.CreateOutStream(OutStream);
//         OutStream.WriteText(JsonText);
//         ToFile := FileName + '11.json';
//         TempBlob.CreateInStream(InStream);
//         DownloadFromStream(InStream, 'e-Way', '', '', ToFile);
//         Sleep(1000);

//         //fe28e9b25dfe9390fb23a5dca981bf6a9f629950da954aa322f490a7dcf244e5
//         AccessToken := TempGstSetup.IRNtoEwayBillSecurityToken;
//         //'fe28e9b25dfe9390fb23a5dca981bf6a9f629950da954aa322f490a7dcf244e5';
//         content.WriteFrom(JsonText);

//         // Retrieve the contentHeaders associated with the content
//         content.GetHeaders(contentHeaders);
//         contentHeaders.Clear();
//         contentHeaders.Add('Content-Type', 'application/json');


//         client.DefaultRequestHeaders.Add('Authorization', 'Bearer ' + AccessToken);

//         // Assigning content to request.Content will actually create a copy of the content and assign it.
//         // After this line, modifying the content variable or its associated headers will not reflect in 
//         // the content associated with the request message
//         request.Content := content;
//         //https://www.sandbox-gstapi.trustfilegst.in/einvoice/api/v1/EInvoice/27AAAPI3182M002/GenerateEwaybillUsingIRN
//         request.SetRequestUri(TempGstSetup.IRNtoEwayBillApi);
//         request.Method := 'POST';

//         client.Send(request, response);
//         if response.IsSuccessStatusCode then begin
//             response.Content().ReadAs(responseText);
//             // Message(responseText);
//             // JobjectResponse.ReadFrom(responseText);
//             // Message(format(JobjectResponse));


//             if JobjToken.ReadFrom(responseText) then begin

//                 // Convert JsonToken to JsonObject
//                 if JobjToken.IsObject then begin
//                     JobjectResponse := JobjToken.AsObject();
//                     Message(format(JobjectResponse));


//                     //for saving Eway Bill
//                     if JobjectResponse.Get('ewayBillNo', JobjToken) then begin
//                         // Get First Array Result
//                         tempSIV.Reset();
//                         tempSIV.SetRange("No.", SalesInvoiceHeader."No.");
//                         IF tempSIV.FindFirst() then;
//                         // EwayJsonObject := EwayJsonToken.AsObject();                       
//                         tempSIV."E-Way Bill No." := JobjToken.AsValue().AsText();
//                         tempSIV.Modify(true);

//                     End;
//                     Message('Eway Bill Updated successfully');
//                 end;
//             end;
//         end
//         Else
//             Error('Bad resposnse or no resposne from Avalara, Please check with your IT team');
//     end;










// }
