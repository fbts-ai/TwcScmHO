// codeunit 50128 "POS Layout Change"
// {
//     //local procedure copied
//     local procedure GetDesignString(var POSText: Record "LSC POS Terminal Receipt Text"): Text;
//     var
//         g: Codeunit 22;
//         R: report 795;
//         T: Record 27;
//         retVal: Text;

//     begin
//         case POSText.Align of
//             POSText.Align::Left:
//                 retVal := '#L######################################'; //40 (will be resized by FormatStr)
//             POSText.Align::Center:
//                 retVal := '#C######################################';
//             POSText.Align::Right:
//                 retVal := '#R######################################';
//         end;

//         if POSText.Wide then
//             retVal := CopyStr(retVal, 1, 20);

//         exit(retVal);
//     end;

//     //main events
//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforePrintHeader', '', false, false)]
//     local procedure OnBeforePrintHeader(var IsHandled: Boolean; PreReceipt: Boolean; sender: Codeunit "LSC POS Print Utility"; Tray: Integer; var LinesPrinted: Integer; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer; var Transaction: Record "LSC Transaction Header")
//     var
//         POSText: Record "LSC POS Terminal Receipt Text";
//         Terminal: Record "LSC POS Terminal";
//         ReceiptHeader: Record "LSC POS Terminal Receipt Head";
//         PosTrGuestInfo: Record "LSC POS Trans. Guest Info";
//         RetailUtil: Codeunit "LSC Retail Price Utils";
//         DSTR1: Text[100];
//         ReceiptNo: Code[20];
//         SeatNo: Integer;

//         FieldValue: array[10] of Text[100];
//         NodeName: array[32] of Text[50];
//     begin
//         Terminal.Get(Transaction."POS Terminal No.");

//         Clear(ReceiptNo);
//         ReceiptHeader.Reset;
//         ReceiptHeader.SetCurrentKey(Priority);

//         ReceiptHeader.SetRange("Receipt Setup Location", Terminal."Receipt Setup Location");

//         if ReceiptHeader.FindLast then begin
//             repeat
//                 if RetailUtil.DiscValPerValid(ReceiptHeader."Validation Period ID", Transaction.Date, Transaction.Time) then begin
//                     ReceiptNo := ReceiptHeader."No.";
//                 end;
//             until (ReceiptHeader.Next(-1) = 0) or (ReceiptNo <> '');
//         end;

//         Clear(POSText);

//         if (ReceiptNo <> '') then
//             POSText.SetRange("No.", ReceiptNo)
//         else
//             POSText.SetRange("No.", '');

//         if Terminal."Receipt Setup Location" = Terminal."Receipt Setup Location"::Terminal then begin
//             POSText.SetRange(Relation, POSText.Relation::Terminal);
//             POSText.SetRange(Number, Terminal."No.");
//         end
//         else begin
//             POSText.SetRange(Relation, POSText.Relation::Store);
//             POSText.SetRange(Number, Transaction."Store No.");
//         end;
//         POSText.SetRange(Type, POSText.Type::Top);

//         if not POSText.FindFirst then
//             POSText.SetRange("No.", '');

//         if POSText.FindSet then begin
//             repeat
//                 POSText.Align := POSText.Align::Right;
//                 POSText.Bold := true;
//                 POSText.Wide := true;
//                 POSText.High := true;
//                 DSTR1 := GetDesignString(POSText);
//                 FieldValue[1] := 'Third Wave Coffee';
//                 NodeName[1] := 'Header Line';

//             // sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), POSText.Wide, POSText.Bold, POSText.High, POSText.Italic));
//             // sender.AddPrintLine(100, 1, NodeName, FieldValue, DSTR1, POSText.Wide, POSText.Bold, POSText.High, POSText.Italic, Tray)
//             until POSText.Next = 0;
//             // sender.PrintSeperator(Tray);
//         end;

//         if PreReceipt then
//             sender.PrintProvisionalReceiptHeaderInfo(POSText, DSTR1, Tray, 0);
//         IsHandled := true;
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforePrintSubHeader', '', false, false)]
//     local procedure OnBeforePrintSubHeader(sender: Codeunit "LSC POS Print Utility"; var TransactionHeader: Record "LSC Transaction Header"; Tray: Integer; var IsHandled: Boolean; var LinesPrinted: Integer; var POSPrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer)
//     var
//         TransSaleEntry: Record "LSC Trans. Sales Entry";
//         DSTR1: Text[100];

//         FieldValue: array[10] of Text[100];
//         NodeName: array[32] of Text[50];
//         RecRef: RecordRef;
//         Store: Record "LSC Store";
//         KotHeader: Record "LSC KOT Header";
//         UpHeader: Record "UP Header";
//         TransInfoEntry: Record "LSC Trans. Infocode Entry";

//         CopyText: Text;
//         TableNo: Integer;
//         SalesType: Text;
//         Alignment: Option Left,Center,Right;
//         lText002: Label '%1 %2';
//     begin
//         //Invoice Text Config
//         TransSaleEntry.Reset();
//         TransSaleEntry.SetRange("Receipt No.", TransactionHeader."Receipt No.");
//         TransSaleEntry.SetRange("Transaction No.", TransactionHeader."Transaction No.");
//         IF TransSaleEntry.FindFirst() Then;

//         IF TransSaleEntry."Item No." = '1' Then
//             InvoiceTxt := 'Advance Receipt'
//         Else begin
//             IF TransactionHeader."Sale Is Return Sale" then
//                 InvoiceTxt := 'Return Tax Invoice'
//             Else
//                 InvoiceTxt := 'Tax Invoice';

//             IF TransactionHeader."Sales Type" <> 'POS' Then
//                 InvoiceTxt := 'Order Information';
//             IF (TransactionHeader.GetPrintedCounter(1) > 0) THEN
//                 CopyText := ' - Copy';
//         end;

//         //Printing
//         Store.Reset();
//         IF Store.Get(TransactionHeader."Store No.") THEN;

//         CompanyInfo.Reset();
//         IF CompanyInfo.Get() Then;
//         CompanyInfo.CalcFields(Picture);

//         RecRef.Open(Database::"Company Information");
//         RecRef.Copy(CompanyInfo);
//         IF sender.PrintBitmapBlob(Tray, RecRef, 29, 'QR_Code', Alignment::Center) Then;

//         Clear(FieldValue);
//         DSTR1 := '#C######################################';
//         FieldValue[1] := CompanyInfo.Name;
//         NodeName[1] := 'x';
//         sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//         sender.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);

//         //Store Addr1
//         FieldValue[1] := Store.Address;
//         NodeName[1] := 'x';
//         sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, false, false, false));
//         sender.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);

//         FieldValue[1] := Store."Address 2";
//         NodeName[1] := 'x';
//         sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, false, false, false));
//         sender.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);

//         FieldValue[1] := StrSubstNo(lText002, Store.City, Store."Post Code");
//         NodeName[1] := 'x';
//         sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, false, false, false));
//         sender.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);

//         FieldValue[1] := StrSubstNo(lText002, 'Mobile:', Store."Phone No.");
//         NodeName[1] := 'x';
//         sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, false, false, false));
//         sender.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);

//         FieldValue[1] := StrSubstNo(lText002, 'GSTIN:', Store."LSCIN GST Registration No");
//         NodeName[1] := 'x';
//         sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//         sender.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);

//         FieldValue[1] := StrSubstNo(lText002, 'FSSAI:', Store."FSSAI Number");
//         NodeName[1] := 'x';
//         sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//         sender.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);

//         sender.PrintSeperator();
//         //Tax Invoice
//         FieldValue[1] := StrSubstNo(lText002, InvoiceTxt, CopyText);
//         NodeName[1] := 'x';
//         sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//         sender.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);

//         sender.PrintSeperator();
//         //Cust Receipt No
//         FieldValue[1] := StrSubstNo(lText002, 'Inv. No. #', TransactionHeader."Cust Receipt No");
//         NodeName[1] := 'x';
//         sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//         sender.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);

//         //Table No Code
//         TransInfoEntry.Reset();
//         TransInfoEntry.SetRange("Transaction No.", TransactionHeader."Transaction No.");
//         TransInfoEntry.SetRange("Store No.", TransactionHeader."Store No.");
//         TransInfoEntry.SetRange("POS Terminal No.", TransactionHeader."POS Terminal No.");
//         TransInfoEntry.SetRange(Infocode, 'SELECTTABLE');
//         IF TransInfoEntry.FindFirst() then
//             Evaluate(TableNo, TransInfoEntry.Information)
//         Else begin
//             TransInfoEntry.SetRange(Infocode, 'TABLE NO.');
//             IF TransInfoEntry.FindFirst() then
//                 Evaluate(TableNo, TransInfoEntry.Information);
//         end;

//         DSTR1 := '#L################# #L##################';

//         //Store Name & Table
//         FieldValue[1] := Store.Name;
//         IF Not TransactionHeader."Sale Is Return Sale" Then
//             FieldValue[2] := StrSubstNo(lText002, 'Table', TableNo)
//         Else
//             FieldValue[2] := '';
//         sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//         NodeName[1] := 'x';
//         NodeName[2] := 'x';
//         FieldValue[3] := StrSubstNo(lText002, FieldValue[1], FieldValue[2]);
//         NodeName[3] := 'Print Info';
//         sender.AddPrintLine(200, 3, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);

//         //Store No & Date Time
//         FieldValue[1] := TransactionHeader."Store No.";
//         FieldValue[2] := StrSubstNo(lText002, TransactionHeader.Date, TransactionHeader."Time when Trans. Closed");
//         sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//         NodeName[1] := 'x';
//         NodeName[2] := 'x';
//         FieldValue[3] := StrSubstNo(lText002, FieldValue[1], FieldValue[2]);
//         NodeName[3] := 'Print Info';
//         sender.AddPrintLine(200, 3, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);

//         //Getting Values Pos Transaction
//         UpHeader.Reset();
//         UpHeader.SetRange(receiptNo, TransactionHeader."Receipt No.");
//         IF UpHeader.FindFirst() Then;

//         IF TransactionHeader."Sales Type" = 'POS' Then begin
//             TransInfoEntry.SetRange(Infocode, '#SALESTYPE');
//             IF TransInfoEntry.FindSet() Then
//                 SalesType := TransInfoEntry.Information;
//         end
//         Else
//             SalesType := UpHeader.order_details_order_type;

//         //Channel & SalesType
//         FieldValue[1] := StrSubstNo(lText002, 'Channel', UpHeader.order_details_channel);
//         FieldValue[2] := SalesType;
//         sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//         NodeName[1] := 'x';
//         NodeName[2] := 'x';
//         FieldValue[3] := StrSubstNo(lText002, FieldValue[1], FieldValue[2]);
//         NodeName[3] := 'Print Info';
//         sender.AddPrintLine(200, 3, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);

//         //Channel Ord Id
//         IF UpHeader.order_details_id <> 0 Then begin
//             DSTR1 := '#L######################################';
//             FieldValue[1] := StrSubstNo(lText002, 'Channel Ord ID:', UpHeader.order_details_id);
//             sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//             NodeName[1] := 'x';
//             sender.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);
//         end;

//         //Get Kot Order ID
//         KotHeader.Reset();
//         KotHeader.SetRange("Receipt No.", TransactionHeader."Receipt No.");
//         IF KotHeader.FindFirst() then
//             IF KotHeader."Order ID" = '' then
//                 KotHeader."Order ID" := Format(KotHeader.ID);

//         //Staff & Ord Id
//         FieldValue[1] := StrSubstNo(lText002, 'Staff ID:', TransactionHeader."Staff ID");
//         FieldValue[2] := StrSubstNo(lText002, 'Store Ord ID:', KotHeader."Order ID");
//         sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//         NodeName[1] := 'x';
//         NodeName[2] := 'x';
//         FieldValue[3] := StrSubstNo(lText002, FieldValue[1], FieldValue[2]);
//         NodeName[3] := 'Print Info';
//         sender.AddPrintLine(200, 3, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);

//         sender.PrintSeperator(Tray);
//         IsHandled := true;
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforePrintSalesInfo', '', false, false)]
//     local procedure OnBeforePrintSalesInfo(sender: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; Tray: Integer; bSecondPrintActive: Boolean; var IsHandled: Boolean; var LinesPrinted: Integer; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer)
//     var
//         SalesEntry: Record "LSC Trans. Sales Entry";
//         PaymentEntry: Record "LSC Trans. Payment Entry";
//         DSTR1: Text[100];

//         FieldValue: array[10] of Text[100];
//         NodeName: array[32] of Text[50];
//         GstCodeList: List of [Decimal];
//         GstValList: List of [Decimal];
//         Item: Record Item;
//         TenderType: Record "LSC Tender Type";
//         PosDataEntry: Record "LSC POS Data Entry";

//         lText001: Label '%1 %2 %3';
//         lText002: Label '%1 %2';
//         RemText: Text;
//         SrNo: Integer;
//         len: Integer;
//         GstCode: Decimal;
//         CodeIdx: Integer;
//         GstVal: Decimal;
//         TempGstVal: Decimal;
//         CreditNoteNo: Code[20];
//         WalletBal: Decimal;
//     begin
//         //Print Table Headers
//         sender.PrintSeperator();
//         DSTR1 := '#L #L########## #C#### #C# #C#### #C####';

//         FieldValue[1] := '#';
//         FieldValue[2] := 'Item';
//         FieldValue[3] := 'HSN';
//         FieldValue[4] := 'Qty';
//         IF Transaction."Sales Type" <> 'TAKEAWAY' Then begin
//             FieldValue[5] := 'Rate';
//             FieldValue[6] := 'Total';
//         end
//         Else begin
//             FieldValue[5] := '';
//             FieldValue[6] := '';
//         end;
//         sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//         NodeName[1] := 'x';
//         NodeName[2] := 'x';
//         NodeName[3] := 'x';
//         NodeName[4] := 'x';
//         NodeName[5] := 'x';
//         NodeName[6] := 'x';
//         FieldValue[7] := StrSubstNo('%1%2%3%4%5%6', FieldValue[1], FieldValue[2], FieldValue[3], FieldValue[4], FieldValue[5], FieldValue[6]);
//         NodeName[7] := 'Print Info';
//         sender.AddPrintLine(200, 7, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);

//         sender.PrintSeperator();

//         Clear(GstCodeList);
//         Clear(GstValList);
//         //Print Table Lines
//         SalesEntry.Reset();
//         SalesEntry.SetRange("Receipt No.", Transaction."Receipt No.");
//         SalesEntry.SetRange("Transaction No.", Transaction."Transaction No.");
//         IF SalesEntry.FindSet() Then begin

//             repeat
//                 len := 12;
//                 //Getting Item
//                 Item.Reset();
//                 IF Item.Get(SalesEntry."Item No.") Then;

//                 //Normal Items
//                 IF SalesEntry."Parent Line No." = 0 Then begin
//                     SrNo += 1;

//                     FieldValue[1] := Format(SrNo);
//                     FieldValue[2] := Item.Description;
//                     FieldValue[4] := Format(-SalesEntry.Quantity);
//                 end
//                 //Add-On Items
//                 Else begin
//                     FieldValue[1] := '';
//                     FieldValue[2] := StrSubstNo('+ %1', Item.Description);
//                     FieldValue[4] := Format(SalesEntry."Infocode Selected Qty.");
//                 end;

//                 IF StrLen(FieldValue[2]) > len Then begin
//                     RemText := CopyStr(FieldValue[2], 13, StrLen(FieldValue[2]));
//                     FieldValue[2] := CopyStr(FieldValue[2], 1, 12);
//                 end;

//                 FieldValue[3] := SalesEntry."LSCIN HSN/SAC Code";

//                 //Incase of TAKEAWAY no Prices
//                 IF Transaction."Sales Type" <> 'TAKEAWAY' Then begin
//                     FieldValue[5] := Format(SalesEntry.Price);
//                     FieldValue[6] := Format(-SalesEntry."Net Amount");
//                 end
//                 Else begin
//                     FieldValue[5] := '';
//                     FieldValue[6] := '';
//                 end;

//                 NodeName[1] := 'x';
//                 NodeName[2] := 'x';
//                 NodeName[3] := 'x';
//                 NodeName[4] := 'x';
//                 NodeName[5] := 'x';
//                 NodeName[6] := 'x';
//                 FieldValue[7] := StrSubstNo('%1%2%3%4%5%6', FieldValue[1], FieldValue[2], FieldValue[3], FieldValue[4], FieldValue[5], FieldValue[6]);
//                 NodeName[7] := 'Print Info';

//                 //Normal Items not Bold
//                 IF SalesEntry."Parent Line No." = 0 Then begin
//                     sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, false, false, false));
//                     sender.AddPrintLine(200, 7, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
//                 end
//                 //Add-On Items - BOLD
//                 Else begin
//                     sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//                     sender.AddPrintLine(200, 7, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);
//                 end;

//                 //Gst Calc Area
//                 Clear(GstCode);
//                 Clear(GstVal);
//                 IF SalesEntry."LSCIN GST Group Code" <> '' Then Begin
//                     Evaluate(GstCode, SalesEntry."LSCIN GST Group Code");
//                     GstCode /= 2;
//                     GstVal := -SalesEntry."LSCIN GST Amount";

//                     IF GstCodeList.Contains(GstCode) Then begin
//                         CodeIdx := GstCodeList.IndexOf(GstCode);
//                         // TempGstVal := ;
//                         GstVal := GstVal + GstValList.Get(CodeIdx);
//                         GstValList.Set(CodeIdx, GstVal);
//                     end
//                     Else begin
//                         GstCodeList.Add(GstCode);
//                         GstValList.Add(GstVal);
//                     end;
//                 End;

//                 while RemText <> '' Do begin
//                     DSTR1 := '   #L##########                         ';
//                     FieldValue[1] := CopyStr(RemText, 1, 12);
//                     NodeName[1] := 'x';

//                     //Rem Text for  Normal Items not Bold
//                     IF SalesEntry."Parent Line No." = 0 Then begin
//                         sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, false, false, false));
//                         sender.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
//                     end
//                     //Rem Text for Add-On Items - BOLD
//                     Else begin
//                         sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//                         sender.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);
//                     end;

//                     IF StrLen(RemText) > len Then
//                         RemText := CopyStr(RemText, 13, StrLen(RemText))
//                     Else
//                         RemText := '';
//                 end;
//             until SalesEntry.Next() = 0;
//         end;
//         sender.PrintSeperator();

//         //Line Total
//         IF Transaction.CalcSums("Discount Amount") Then;
//         DSTR1 := '#R############################### #R####';
//         IF Transaction."Sales Type" <> 'TAKEAWAY' Then begin
//             FieldValue[1] := 'Line Total:';
//             FieldValue[2] := Format(-(Transaction."Net Amount" - Transaction."Discount Amount"));
//             sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//             NodeName[1] := 'x';
//             NodeName[2] := 'x';
//             FieldValue[3] := StrSubstNo(lText002, FieldValue[1], FieldValue[2]);
//             NodeName[3] := 'Print Info';
//             sender.AddPrintLine(200, 3, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);
//         end;

//         //Discount Total
//         IF (Transaction."Sales Type" <> 'TAKEAWAY') AND (Transaction."Discount Amount" <> 0) Then begin
//             FieldValue[1] := 'Discount:';
//             FieldValue[2] := Format(Transaction."Discount Amount");
//             sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, false, false, false));
//             NodeName[1] := 'x';
//             NodeName[2] := 'x';
//             FieldValue[3] := StrSubstNo(lText002, FieldValue[1], FieldValue[2]);
//             NodeName[3] := 'Print Info';
//             sender.AddPrintLine(200, 3, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
//         end;

//         //GST Display Area
//         IF GstCodeList.Count > 0 Then begin
//             for SrNo := 1 to GstCodeList.Count do begin

//                 FieldValue[1] := StrSubstNo('SGST @ %1%:', GstCodeList.Get(SrNo));
//                 FieldValue[2] := Format(GstValList.Get(SrNo));
//                 sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, false, false, false));
//                 NodeName[1] := 'x';
//                 NodeName[2] := 'x';
//                 FieldValue[3] := StrSubstNo(lText002, FieldValue[1], FieldValue[2]);
//                 NodeName[3] := 'Print Info';
//                 sender.AddPrintLine(200, 3, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);

//                 FieldValue[1] := StrSubstNo('CGST @ %1%:', GstCodeList.Get(SrNo));
//                 FieldValue[2] := Format(GstValList.Get(SrNo));
//                 sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, false, false, false));
//                 NodeName[1] := 'x';
//                 NodeName[2] := 'x';
//                 FieldValue[3] := StrSubstNo(lText002, FieldValue[1], FieldValue[2]);
//                 NodeName[3] := 'Print Info';
//                 sender.AddPrintLine(200, 3, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
//             end;
//         end;

//         //Payment
//         PaymentEntry.Reset();
//         PaymentEntry.SetRange("Receipt No.", Transaction."Receipt No.");
//         PaymentEntry.SetRange("Transaction No.", Transaction."Transaction No.");
//         IF PaymentEntry.FindSet() Then begin

//             repeat
//                 TenderType.Reset();
//                 TenderType.SetRange(Code, PaymentEntry."Tender Type");
//                 IF TenderType.FindFirst() then;

//                 IF InvoiceTxt = 'Tax Invoice' Then
//                     IF PaymentEntry."Amount Tendered" < 0 then
//                         TenderType.Description := 'Change Due';

//                 FieldValue[1] := TenderType.Description;
//                 FieldValue[2] := Format(PaymentEntry."Amount Tendered");
//                 sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, false, false, false));
//                 NodeName[1] := 'x';
//                 NodeName[2] := 'x';
//                 FieldValue[3] := StrSubstNo(lText002, FieldValue[1], FieldValue[2]);
//                 NodeName[3] := 'Print Info';
//                 sender.AddPrintLine(200, 3, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);

//             until PaymentEntry.Next() = 0;
//         end;

//         //Credit Note
//         PosDataEntry.Reset();
//         PosDataEntry.SetRange("Created by Receipt No.", Transaction."Receipt No.");
//         IF PosDataEntry.FindFirst() then
//             CreditNoteNo := PosDataEntry."Entry Code";

//         IF CreditNoteNo <> '' Then begin
//             DSTR1 := '#R######################################';

//             FieldValue[1] := StrSubstNo(lText002, 'Credit Note No:', CreditNoteNo);
//             sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, false, false, false));
//             NodeName[1] := 'x';
//             sender.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
//         end;

//         //Wallet Balance Calculation
//         IF InvoiceTxt = 'Advance Receipt' Then begin
//             IF Transaction."Wallet Balance" <> '' Then
//                 IF Evaluate(WalletBal, Transaction."Wallet Balance") Then;
//             WalletBal += ABS(Transaction."Net Amount");
//             Transaction.Rounded := 0;
//         end;

//         //Rounded
//         IF Transaction.Rounded > 0 Then begin
//             DSTR1 := '#R######################################';
//             FieldValue[1] := StrSubstNo('(round off %1)', Transaction.Rounded);
//             NodeName[1] := 'x';
//             sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, false, false, false));
//             sender.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
//         end;

//         //Grand Total
//         FieldValue[1] := StrSubstNo('Grand Total: Rs. %1', -Transaction."Gross Amount" + Transaction.Rounded);
//         NodeName[1] := 'x';
//         sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//         sender.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);

//         //Wallet Balance
//         IF WalletBal > 0 Then begin
//             DSTR1 := '#L######################################';

//             FieldValue[1] := StrSubstNo('Wallet Balance: %1', WalletBal);
//             NodeName[1] := 'x';
//             sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//             sender.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);
//         end;

//         IsHandled := true;
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforePrintFooter', '', false, false)]
//     local procedure OnBeforePrintFooter(sender: Codeunit "LSC POS Print Utility"; var Transaction: Record "LSC Transaction Header"; var DSTR1: Text[100]; var IsHandled: Boolean; var LinesPrinted: Integer; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer)
//     var
//         FieldValue: array[10] of Text[100];
//         NodeName: array[32] of Text[50];

//         lText001: Label '%1 %2 %3';
//         lText002: Label '%1 %2';
//     begin
//         DSTR1 := CopyStr('#C################################################', 1, 40);

//         FieldValue[1] := 'Thank You!';
//         NodeName[1] := 'x';
//         sender.PrintLine(2, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//         sender.AddPrintLine(250, 1, NodeName, FieldValue, DSTR1, false, true, false, false, 2);

//         FieldValue[1] := 'Visit again!!';
//         NodeName[1] := 'x';
//         sender.PrintLine(2, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//         sender.AddPrintLine(250, 1, NodeName, FieldValue, DSTR1, false, true, false, false, 2);

//         FieldValue[1] := 'HOW DID WE DO? .. your honesty only';
//         sender.PrintLine(2, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, false, false, false));
//         NodeName[1] := 'Feedback Message';
//         sender.AddPrintLine(250, 1, NodeName, FieldValue, DSTR1, false, false, false, false, 2);

//         FieldValue[1] := 'makes us better';
//         sender.PrintLine(2, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, false, false, false));
//         NodeName[1] := 'Feedback Message';
//         sender.AddPrintLine(250, 1, NodeName, FieldValue, DSTR1, false, false, false, false, 2);

//         FieldValue[1] := 'Scan this QR code to give feedback';
//         sender.PrintLine(2, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, false, false, false));
//         NodeName[1] := 'Feedback Message';
//         sender.AddPrintLine(250, 1, NodeName, FieldValue, DSTR1, false, false, false, false, 2);

//         FieldValue[1] := 'For any further queries or feedback,';
//         sender.PrintLine(2, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, false, false, false));
//         NodeName[1] := 'Feedback Message';
//         sender.AddPrintLine(250, 1, NodeName, FieldValue, DSTR1, false, false, false, false, 2);

//         FieldValue[1] := 'contact : Customer Contact Centre at';
//         sender.PrintLine(2, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, false, false, false));
//         NodeName[1] := 'Feedback Message';
//         sender.AddPrintLine(250, 1, NodeName, FieldValue, DSTR1, false, false, false, false, 2);

//         FieldValue[1] := '080-47108111/';
//         sender.PrintLine(2, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, false, false, false));
//         NodeName[1] := 'Feedback Message';
//         sender.AddPrintLine(250, 1, NodeName, FieldValue, DSTR1, false, false, false, false, 2);

//         FieldValue[1] := 'CARE@THIRDWAVECOFFEE.IN';
//         sender.PrintLine(2, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, false, false, false));
//         NodeName[1] := 'Feedback Message';
//         sender.AddPrintLine(250, 1, NodeName, FieldValue, DSTR1, false, false, false, false, 2);

//         IsHandled := true;
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforePrintKDSHeader', '', false, false)]
//     local procedure OnBeforePrintKDSHeader(sender: Codeunit "LSC POS Print Utility"; var IsHandled: Boolean; Tray: Integer; var DSTR1: Text[100]; var KOTHeaderRouting: Record "LSC KOT Header Routing"; var DisplayStation: Text; ReprintedCount: Integer; var LineLength: Integer; var LinesPrinted: Integer; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer)
//     var
//         Text331: Label 'Third Wave Coffee';
//         lText001: Label '%1 %2 %3';
//         lText002: Label '%1 %2';
//         OrderCompletedText: Label 'Order completed';
//         RePrintKDSChit: Label 'Reprint no. %1 - %2';

//         FieldValue: array[10] of Text[100];
//         NodeName: array[32] of Text[50];
//         CommentLength: Integer;
//         CommentParts: Integer;
//         CommentPart: array[50] of Text;
//         i: integer;

//         KOTHeader: Record "LSC KOT Header";
//         KOTLineModifier: Record "LSC KOT Line Modifier/Message";
//         StoreInfo: Record "LSC Store";
//         POSFunctions: Codeunit "LSC POS Functions";
//     begin
//         DSTR1 := CopyStr('#C################################################', 1, LineLength);
//         FieldValue[1] := 'Third Wave Coffee';
//         sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//         NodeName[1] := 'Store Name';
//         sender.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);

//         IF KOTHeader.Get(KOTHeaderRouting."KOT No.") Then;

//         StoreInfo.Reset();
//         IF StoreInfo.Get(KOTHeaderRouting."Restaurant No.") THEN;
//         FieldValue[1] := StrSubstNo(lText001, '(', StoreInfo.Name, ')');
//         sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, false, false, false));
//         NodeName[1] := 'Store Name';
//         sender.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);

//         FieldValue[1] := StrSubstNo('%1 - %2', DisplayStation, KOTHeaderRouting."KOT No.");
//         sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//         if ReprintedCount > 0 then begin
//             DSTR1 := CopyStr('#C################################################', 1, LineLength);
//             IF KOTHeader.Voided then
//                 FieldValue[1] := 'Voided KOT'
//             Else
//                 FieldValue[1] := StrSubstNo(RePrintKDSChit, ReprintedCount, KOTHeaderRouting."KOT No.");
//             sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//         end;
//         NodeName[1] := 'Description';
//         sender.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);

//         if KOTHeaderRouting."Expeditor Bump Printing" then begin
//             DSTR1 := CopyStr('#C################################################', 1, LineLength);
//             FieldValue[1] := OrderCompletedText;
//             sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//             NodeName[1] := 'Print Info';
//             sender.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);
//         end;

//         KOTLineModifier.SetRange("KOT No.", KOTHeaderRouting."KOT No.");
//         KOTLineModifier.SetRange("Line Type", KOTLineModifier."Line Type"::KOTComment);
//         if (KOTLineModifier.FindSet()) then begin
//             sender.PrintSeperator(Tray);
//             CommentLength := LineLength;
//             repeat
//                 DSTR1 := CopyStr('#C################################################', 1, LineLength);
//                 POSFunctions.Text_DivideTextIntoEvenLengthParts(KOTLineModifier.Description, CommentLength, CommentPart, CommentParts);
//                 FieldValue[1] := CommentPart[1];
//                 sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//                 NodeName[1] := 'KOT Comment';
//                 sender.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);
//                 if CommentParts > 1 then
//                     for i := 2 to CommentParts do begin
//                         FieldValue[1] := CommentPart[i];
//                         sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//                         NodeName[1] := 'Print Info';
//                         sender.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);
//                     end;
//             until KOTLineModifier.Next() = 0;
//         end;
//         sender.PrintSeperator(Tray);

//         IsHandled := true;
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforePrintKOTHeader', '', false, false)]
//     local procedure OnBeforePrintKOTHeader(sender: Codeunit "LSC POS Print Utility"; var KOTHeader: Record "LSC KOT Header"; var DSTR1: Text[100]; var IsHandled: Boolean; TableTransfer: Boolean; Tray: Integer; var LineLength: Integer; var LinesPrinted: Integer; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer)
//     var
//         lText001: Label '%1 %2 %3';
//         lText002: Label '%1 %2';
//         Text201: Label 'until';
//         Text231: Label 'TABLE TRANSFER';
//         Text233: Label 'TODAY';
//         Text331: Label 'Table';
//         Text332: Label 'Covers';
//         Text333: Label 'Channel';
//         Text334: Label 'Inv. No. #';
//         Text335: Label 'KOT Voided';
//         Text336: Label 'Sales/Order Type:';
//         SalesType: Text;
//         RushOrderText: Label '** RUSH ORDER **';
//         OnHoldForXMinText: Label 'On Hold for %1 minutes';
//         ProdStartTimeText: Label 'Prod. Start Time:  %1';
//         Text047: Label '** TRAINING **';

//         TableNo: Integer;
//         TransNo: Integer;
//         FieldValue: array[10] of Text[100];
//         NodeName: array[32] of Text[50];

//         HospitalityPOSGui: Codeunit "LSC Hospitality POS GUI";
//         KOTTransactionMapping: Record "LSC KOT Transaction Mapping";

//         Store: Record "LSC Store";
//         HospType: Record "LSC Hospitality Type";
//         PosTrans: Record "LSC POS Transaction";
//         PosTransInfoEntry: Record "LSC POS Trans. Infocode Entry";
//     begin
//         if KOTHeader."Training Mode" then begin
//             DSTR1 := CopyStr('#C################################################', 1, LineLength);
//             FieldValue[1] := Text047;
//             sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//             NodeName[1] := 'Print Info';
//             sender.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);
//         end;
//         if KOTTransactionMapping.Get(KOTHeader."KOT No.") then
//             if TableTransfer then begin
//                 DSTR1 := '#C######################################';
//                 FieldValue[1] := Text231;
//                 sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//                 NodeName[1] := 'Print Info';
//                 sender.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);
//                 FieldValue[1] := KOTHeader."Trans. Comment";
//                 sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//                 NodeName[1] := 'Print Info';
//                 sender.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);
//             end;
//         if KOTHeader.Voided then begin
//             DSTR1 := CopyStr('#C################################################', 1, LineLength);
//             FieldValue[1] := Text335;
//             sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//             NodeName[1] := 'Print Info';
//             sender.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);
//         end;
//         if KOTHeader.RushOrder then begin
//             DSTR1 := CopyStr('#C################################################', 1, LineLength);
//             FieldValue[1] := RushOrderText;
//             sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//             NodeName[1] := 'Print Info';
//             sender.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);
//         end;


//         if KOTHeader."On Hold Status" = KOTHeader."On Hold Status"::"On Hold" then begin
//             DSTR1 := CopyStr('#C################################################', 1, LineLength);
//             FieldValue[1] := Format(KOTHeader."On Hold Status");
//             if DT2Date(KOTHeader."Date Time Due") = Today then
//                 FieldValue[2] := StrSubstNo(Text201, Text233)
//             else
//                 FieldValue[2] := StrSubstNo(Text201, Format(DT2Date(KOTHeader."Date Time Due")));
//             sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//             FieldValue[3] := StrSubstNo(lText002, FieldValue[1], FieldValue[2]);
//             NodeName[3] := 'Print Info';
//             sender.AddPrintLine(200, 3, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);
//             sender.PrintSeperator(Tray);
//         end else begin

//             if KOTHeader."On Hold Offset (Min.)" <> 0 then begin
//                 DSTR1 := CopyStr('#C################################################', 1, LineLength);
//                 FieldValue[1] := StrSubstNo(OnHoldForXMinText, format(KOTHeader."On Hold Offset (Min.)"));
//                 sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//                 NodeName[1] := 'Print Info';
//                 sender.AddPrintLine(200, 3, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);

//                 if KOTHeader."Prod. Start Date Time" <> 0DT then begin
//                     FieldValue[1] := StrSubstNo(ProdStartTimeText, HospitalityPOSGui.FormatTime(KOTHeader."Prod. Start Date Time"));
//                     NodeName[1] := 'Print Info';
//                     sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//                     NodeName[1] := 'Print Info';
//                     sender.AddPrintLine(200, 3, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);
//                 end;
//                 sender.PrintSeperator(Tray);
//             end;
//         end;

//         KOTHeader.CalcFields("Table No.", "Order ID", "Receipt No.", "Staff ID");

//         PosTrans.Reset();
//         PosTrans.SetRange("Receipt No.", KOTHeader."Receipt No.");
//         IF PosTrans.FindFirst() Then;

//         IF KOTHeader."Sales Type" = 'POS' Then begin
//             PosTransInfoEntry.Reset();
//             PosTransInfoEntry.SetRange("Receipt No.", KOTHeader."Receipt No.");
//             PosTransInfoEntry.SetRange("Store No.", KOTHeader."Restaurant No.");
//             PosTransInfoEntry.SetRange("POS Terminal No.", KOTHeader."POS ID");
//             PosTransInfoEntry.SetRange(Infocode, 'SELECTTABLE');
//             IF PosTransInfoEntry.FindFirst() then
//                 Evaluate(TableNo, PosTransInfoEntry.Information)
//             Else begin
//                 PosTransInfoEntry.SetRange(Infocode, 'TABLE NO.');
//                 IF PosTransInfoEntry.FindFirst() then
//                     Evaluate(TableNo, PosTransInfoEntry.Information)
//             end;
//         end
//         Else
//             IF Evaluate(TableNo, PosTrans.Table_No) Then;

//         DSTR1 := '#L##### #L######### #L######## #L#######';

//         //Table & Time
//         FieldValue[1] := Text331;
//         FieldValue[2] := Format(TableNo);
//         FieldValue[3] := Format(KOTHeader."Date KOT Created", 0, '<Day,2>-<Month Text,3>-<Year>');
//         FieldValue[4] := Format(KOTHeader."Time KOT Created", 0, '<Hours12>:<Minutes,2> <AM/PM>');
//         sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, false, false, false));
//         NodeName[1] := 'x';
//         NodeName[2] := 'x';
//         NodeName[3] := 'x';
//         NodeName[4] := 'x';
//         FieldValue[5] := StrSubstNo('%1 %2 %3 %4', FieldValue[1], FieldValue[2], FieldValue[3], FieldValue[4]);
//         NodeName[5] := 'Print Info';
//         sender.AddPrintLine(250, 5, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);

//         DSTR1 := '#L################# #L##################';

//         IF KOTHeader."Sales Type" = 'POS' Then begin
//             PosTransInfoEntry.SetRange(Infocode, '#SALESTYPE');
//             IF PosTransInfoEntry.FindSet() Then
//                 SalesType := PosTransInfoEntry.Information;
//         end
//         Else begin
//             IF PosTrans.OrderType = 'delivery' then
//                 PosTrans.OrderType := 'Home Delivery';

//             SalesType := PosTrans.OrderType;
//         end;

//         //Sales Type
//         FieldValue[1] := Text336;
//         FieldValue[2] := SalesType;
//         sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//         NodeName[1] := 'x';
//         NodeName[2] := 'x';
//         FieldValue[3] := StrSubstNo(lText002, FieldValue[1], FieldValue[2]);
//         NodeName[3] := 'Print Info';
//         sender.AddPrintLine(250, 3, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);

//         //Channel
//         FieldValue[1] := Text333;
//         FieldValue[2] := PosTrans.Channel;
//         sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//         NodeName[1] := 'x';
//         NodeName[2] := 'x';
//         FieldValue[3] := StrSubstNo(lText002, FieldValue[1], FieldValue[2]);
//         NodeName[3] := 'Print Info';
//         sender.AddPrintLine(250, 3, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);

//         DSTR1 := '#L######################################';
//         //Channel Ord ID
//         IF PosTrans.ExtOrderId <> '' Then
//             FieldValue[1] := StrSubstNo('%1 %2', 'Channel Ord ID', PosTrans.ExtOrderId)
//         Else
//             FieldValue[1] := StrSubstNo('%1 %2', 'Channel Ord ID', PosTrans.OrderId);

//         sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, false, false, false));
//         NodeName[1] := 'Print Info';
//         sender.AddPrintLine(250, 1, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);

//         IF KOTHeader."Order ID" = '' then
//             KOTHeader."Order ID" := Format(KOTHeader.ID);

//         DSTR1 := '#L################# #L##################';

//         IF Store.Get(KOTHeader."Restaurant No.") Then;

//         //Store No. & Name
//         FieldValue[1] := KOTHeader."Restaurant No.";
//         FieldValue[2] := Store.Name;
//         sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//         NodeName[1] := 'x';
//         NodeName[2] := 'x';
//         FieldValue[3] := StrSubstNo(lText002, FieldValue[1], FieldValue[2]);
//         NodeName[3] := 'Print Info';
//         sender.AddPrintLine(250, 3, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);

//         //Staff & Ord ID
//         FieldValue[1] := StrSubstNo(lText002, 'Staff ID -', KOTHeader."Staff ID");
//         FieldValue[2] := StrSubstNo(lText002, 'Store Ord #', KOTHeader."Order ID");
//         sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, false, false, false));
//         NodeName[1] := 'x';
//         NodeName[2] := 'x';
//         FieldValue[3] := StrSubstNo(lText002, FieldValue[1], FieldValue[2]);
//         NodeName[3] := 'Print Info';
//         sender.AddPrintLine(250, 3, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);

//         DSTR1 := CopyStr('#C################################################', 1, LineLength);
//         sender.PrintSeperator(Tray);

//         //Cust Receipt No.
//         FieldValue[1] := StrSubstNo('%1 %2', Text334, PosTrans."Cust Receipt No");
//         sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//         NodeName[1] := 'Print Info';
//         sender.AddPrintLine(250, 1, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);

//         DSTR1 := '#L################# #L##################';
//         if KOTHeader.Covers <> 0 then begin
//             FieldValue[1] := Text332;
//             FieldValue[2] := Format(KOTHeader.Covers);
//             sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, false, false, false));
//             NodeName[1] := 'x';
//             NodeName[2] := 'x';
//             FieldValue[3] := StrSubstNo(lText002, FieldValue[1], FieldValue[2]);
//             NodeName[3] := 'Print Info';
//             sender.AddPrintLine(250, 3, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
//         end;

//         sender.PrintSeperator(Tray);

//         IsHandled := true;
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforePrintKOTLine', '', false, false)]
//     local procedure OnBeforePrintKOTLine(sender: Codeunit "LSC POS Print Utility"; Tray: Integer; var DSTR1: Text[100]; var IsHandled: Boolean; var KOTHeader: Record "LSC KOT Header"; DisplayStationID: Code[20]; PrintAllLines: Boolean; var LineLength: Integer; var LinesPrinted: Integer; var PrintBuffer: Record "LSC POS Print Buffer"; var PrintBufferIndex: Integer)
//     var
//         KOTLineRouting: Record "LSC KOT Line Routing";
//         KOTLineModifier: Record "LSC KOT Line Modifier/Message";
//         TempKotModifier: Record "LSC KOT Line Modifier/Message";
//         KOTLineTEMP: Record "LSC KOT Line" temporary;
//         KOTLine: Record "LSC KOT Line";
//         UpHeader: Record "UP Header";
//         Item: Record Item;
//         Text322: Label 'Qty     ITEM                            ';
//         VoidedText: Label 'VOID';
//         lText001: Label '%1 %2';
//         lText002: Label '%1 %2 %3';

//         ModDescrChar: Integer;
//         ModDescrIndent: Integer;
//         ModDescr: text;
//         ModPrintDescr: array[50] of text;
//         ModPrintNo: Integer;
//         LastMenuTypeDescription: Text[30];
//         FieldValue: array[10] of Text[100];
//         NodeName: array[32] of Text[50];

//         i: Integer;
//         Total: Integer;
//         SubTotal: Integer;
//         Instruction: Text;
//         InstrHolder: Text;
//         len: Integer;
//         TempText: Text;
//         CommList: List of [Text];
//         QRCodeText: Text;
//         URL: Text;
//         EncodeStr: Text;
//         TempBlob: Codeunit "Temp Blob";
//         RecRef: RecordRef;

//         Alignment: Option Left,Center,Right;
//         PRINT: Boolean;
//         Reprinted: Boolean;
//         POSFunctions: Codeunit "LSC POS Functions";
//     begin
//         FieldValue[1] := Text322;
//         DSTR1 := '#L#######################################';
//         sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//         sender.PrintSeperator(Tray);
//         KOTLineRouting.Reset;
//         KOTLineRouting.SetCurrentKey("KOT No.", "Display Station ID", "Line Printed");
//         KOTLineRouting.SetRange("KOT No.", KOTHeader."KOT No.");
//         KOTLineRouting.SetRange("Display Station ID", DisplayStationID);
//         if not PrintAllLines then
//             KOTLineRouting.SetFilter("Line Printed", '<>%1', KOTLineRouting."Line Printed"::Yes);

//         KOTLineTEMP.Reset;
//         KOTLineTEMP.DeleteAll;
//         if KOTLineRouting.FindSet then
//             repeat
//                 if KOTLine.Get(KOTLineRouting."KOT No.", KOTLineRouting."KOT Line No.") then begin
//                     KOTLineTEMP := KOTLine;
//                     KOTLineTEMP."Line Printed" := KOTLineRouting."Line Printed";
//                     if KOTLineTEMP.Insert then;
//                 end;
//             until KOTLineRouting.Next = 0;

//         KOTLineRouting.ModifyAll("Line Printed", KOTLineRouting."Line Printed"::Yes);

//         Commit;

//         KOTLineTEMP.Reset;
//         KOTLineTEMP.SetCurrentKey("KOT No.", "Menu Type");
//         LastMenuTypeDescription := '';
//         if KOTLineTEMP.FindSet then
//             repeat
//                 if KOTLineTEMP."Menu Type Description" <> LastMenuTypeDescription then begin
//                     sender.PrintLine(Tray, '');
//                     FieldValue[2] := KOTLineTEMP."Menu Type Description";
//                     DSTR1 := '#L#######################################';
//                     sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//                     LastMenuTypeDescription := KOTLineTEMP."Menu Type Description";
//                 end;
//                 // DSTR1 := '#L############################ #R#######';
//                 DSTR1 := '#L# #L##################################';
//                 FieldValue[2] := '';
//                 if Reprinted then
//                     if KOTLineTEMP."Line Printed" in [KOTLineTEMP."Line Printed"::No, KOTLineTEMP."Line Printed"::"Reprint-Modifier"] then
//                         FieldValue[2] := '*';
//                 if KOTLineTEMP.Voided then
//                     FieldValue[2] += VoidedText + ' ';

//                 IF Item.Get(KOTLineTEMP."No.") Then;
//                 FieldValue[1] := Format(KOTLineTEMP.Quantity);

//                 //Print Extra Char in multiple Lines
//                 Clear(len);
//                 Clear(CommList);
//                 Clear(TempText);
//                 len := 36 - StrLen(FieldValue[2]);
//                 IF StrLen(Item.Description) > len then begin
//                     CommList := Item.Description.Trim().Split(' ');
//                     Item.Description := '';

//                     foreach TempText in CommList do begin
//                         IF StrLen(TempText) > len Then begin
//                             FieldValue[2] := CopyStr(FieldValue[2] + Item.Description, 1, MaxStrLen(FieldValue[2]));
//                             sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, false, false, false));
//                             NodeName[1] := 'Quantity';
//                             NodeName[2] := 'Item Description';
//                             sender.AddPrintLine(300, 2, NodeName, FieldValue, DSTR1, false, false, false, false, 2);

//                             len := 36;
//                             Item.Description := '';
//                             Clear(FieldValue);
//                         end;

//                         Item.Description += TempText + ' ';
//                         len -= (StrLen(TempText) + 1);
//                     end;
//                 end;

//                 IF Item.Description <> '' Then begin
//                     FieldValue[2] := CopyStr(FieldValue[2] + Item.Description, 1, MaxStrLen(FieldValue[2]));
//                     sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, false, false, false));
//                     NodeName[1] := 'Quantity';
//                     NodeName[2] := 'Item Description';
//                     sender.AddPrintLine(300, 2, NodeName, FieldValue, DSTR1, false, false, false, false, 2);
//                     SubTotal += KOTLineTEMP.Quantity;
//                 end;

//                 KOTLineModifier.Reset;
//                 KOTLineModifier.SetRange("KOT No.", KOTLineTEMP."KOT No.");
//                 KOTLineModifier.SetRange("KOT Line No.", KOTLineTEMP."KOT Line No.");
//                 KOTLineModifier.SetFilter("Line Type", '<>%1&<>%2', KOTLineModifier."Line Type"::Ingredient, KOTLineModifier."Line Type"::KOTComment);
//                 KOTLineModifier.SetFilter("Line Info Type", '<>%1', KOTLineModifier."Line Info Type"::Text);
//                 if KOTLineModifier.FindSet(true, false) then
//                     repeat
//                         clear(ModDescrIndent);
//                         case KOTLineModifier."Line Info Type" of
//                             KOTLineModifier."Line Info Type"::Item:
//                                 ModDescrIndent := 2;
//                             KOTLineModifier."Line Info Type"::Text:
//                                 ModDescrIndent := 0;
//                         end;
//                         ModDescrChar := 31;
//                         // DSTR1 := ' #L############################# #R#####';
//                         DSTR1 := '#L# #L##################################';
//                         FieldValue[1] := '';
//                         FieldValue[2] := '';
//                         if reprinted then
//                             if KOTLineTEMP."Line Printed" in [KOTLineTEMP."Line Printed"::No, KOTLineTEMP."Line Printed"::"Reprint-Modifier"] then begin
//                                 FieldValue[2] := '*';
//                                 ModDescrIndent += StrLen(FieldValue[2]);
//                             end;
//                         if KOTLineModifier.Voided then begin
//                             FieldValue[2] += VoidedText + ' ';
//                             ModDescrIndent += StrLen(FieldValue[2]);
//                         end;

//                         // IF Item.Get(Item."No.") Then;
//                         ModDescrChar := ModDescrChar - ModDescrIndent;
//                         ModDescr := KOTLineModifier.Description;
//                         POSFunctions.Text_DivideTextIntoEvenLengthParts(ModDescr, ModDescrChar, ModPrintDescr, ModPrintNo);

//                         case KOTLineModifier."Line Info Type" of
//                             KOTLineModifier."Line Info Type"::Item:
//                                 begin
//                                     if (KOTLineModifier."Line Type" = KOTLineModifier."Line Type"::"Excluded Ingredient") then begin
//                                         FieldValue[1] := '';
//                                         FieldValue[2] := FieldValue[2] + '- ' + ModPrintDescr[1];
//                                     end else begin
//                                         if (KOTLineModifier.Quantity < 0) then
//                                             FieldValue[2] := FieldValue[2] + '- ' + ModPrintDescr[1]
//                                         else
//                                             FieldValue[2] := FieldValue[2] + '+ ' + ModPrintDescr[1];
//                                         FieldValue[1] := Format(KOTLineModifier."Modifier Quantity");
//                                     end;
//                                 end;
//                             KOTLineModifier."Line Info Type"::Text:
//                                 begin
//                                     FieldValue[1] := '';
//                                     FieldValue[2] := FieldValue[2] + ModPrintDescr[1];
//                                 end;
//                         end;
//                         sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//                         NodeName[1] := 'Quantity';
//                         NodeName[2] := 'Modifier Description';
//                         sender.AddPrintLine(350, 2, NodeName, FieldValue, DSTR1, false, true, false, false, 2);

//                         if ModPrintNo > 1 then
//                             for i := 2 to ModPrintNo do begin
//                                 if ModDescrIndent > 0 then
//                                     FieldValue[2] := copystr('               ', 1, ModDescrIndent) + ModPrintDescr[i]
//                                 else
//                                     FieldValue[2] := ModPrintDescr[i];
//                                 FieldValue[1] := '';
//                                 sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//                                 NodeName[1] := 'Quantity';
//                                 NodeName[2] := 'Modifier Description';
//                                 sender.AddPrintLine(350, 2, NodeName, FieldValue, DSTR1, false, true, false, false, 2);
//                             end;
//                     until KOTLineModifier.Next = 0;
//             until KOTLineTEMP.Next = 0;
//         Commit;

//         //Get MasterKOT Total
//         KOTLine.Reset();
//         KOTLine.SetRange("KOT No.", KOTHeader."KOT No.");
//         IF KOTLine.FindSet() THEN begin
//             repeat
//                 Total += KOTLine.Quantity;
//             until KOTLine.Next() = 0;
//         end;

//         If (KOTHeader."Sales Type" = 'TAKEAWAY') OR (KOTHeader."Sales Type" = 'PRE-ORDER') Then begin
//             sender.PrintBlankLine(Tray);

//             DSTR1 := CopyStr('#L################################################', 1, 40);
//             FieldValue[1] := 'Remarks:';
//             sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//             NodeName[1] := 'Remarks Msg';
//             sender.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);

//             FieldValue[1] := 'Online (Paid) Order ...';
//             sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//             NodeName[1] := 'Online-Order Msg';
//             sender.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);
//         end;

//         IF SubTotal = Total Then begin
//             DSTR1 := CopyStr('#L################################################', 1, 40);
//             Clear(len);
//             Clear(CommList);
//             Clear(TempText);

//             UpHeader.Reset();
//             UpHeader.SetRange(receiptNo, KOTHeader."Receipt No.");
//             IF UpHeader.FindFirst() Then;
//             Instruction := UpHeader.order_details_instructions;

//             TempKotModifier.Reset;
//             TempKotModifier.SetRange("KOT No.", KOTLineTEMP."KOT No.");
//             TempKotModifier.SetRange("Line Type", TempKotModifier."Line Type"::Modifier);
//             TempKotModifier.SetRange("Line Info Type", TempKotModifier."Line Info Type"::Text);
//             IF TempKotModifier.FindSet() Then begin
//                 repeat
//                     IF Instruction <> '' Then
//                         Instruction += ', ';
//                     Instruction += TempKotModifier.Description.Trim();
//                 until TempKotModifier.Next() = 0;
//             end;

//             InstrHolder := 'Instructions:: %1';
//             len := 40 - 15;
//             IF StrLen(Instruction) > len Then begin
//                 CommList := Instruction.Split(' ');
//                 Instruction := '';
//                 foreach TempText in CommList do begin

//                     IF StrLen(TempText) > len Then begin
//                         FieldValue[1] := StrSubstNo(InstrHolder, Instruction);
//                         sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//                         NodeName[1] := 'Instruction Message';
//                         sender.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);

//                         len := 40;
//                         InstrHolder := '%1';
//                         Instruction := '';
//                     end;

//                     Instruction += TempText + ' ';
//                     len -= (StrLen(TempText) + 1);
//                 end;
//             end;

//             IF Instruction <> '' Then Begin
//                 FieldValue[1] := StrSubstNo(InstrHolder, Instruction);
//                 sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//                 NodeName[1] := 'Instruction Message';
//                 sender.AddPrintLine(200, 1, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);
//             End;

//             sender.PrintBlankLine(Tray);
//         end;
//         DSTR1 := CopyStr('#C################################################', 1, 40);

//         If (KOTHeader."Sales Type" = 'TAKEAWAY') OR (KOTHeader."Sales Type" = 'PRE-ORDER') Then begin
//             //MasterKot - Delivery
//             IF SubTotal = Total Then begin
//                 FieldValue[1] := StrSubstNo(lText002, 'Total', SubTotal, 'Items');
//                 sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//                 NodeName[1] := 'Print Info';
//                 sender.AddPrintLine(250, 1, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);

//                 // FieldValue[1] := 'HOW DID WE DO? .. your honesty';
//                 // sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, false, false, false));
//                 // NodeName[1] := 'Feedback Message';
//                 // sender.AddPrintLine(250, 1, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);

//                 // FieldValue[1] := 'only makes us better';
//                 // sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, false, false, false));
//                 // NodeName[1] := 'Feedback Message';
//                 // sender.AddPrintLine(250, 1, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);

//                 // CompanyInfo.Reset();
//                 // IF CompanyInfo.Get() Then;
//                 // CompanyInfo.CalcFields(Picture);

//                 // RecRef.Open(Database::"Company Information");
//                 // RecRef.Copy(CompanyInfo);
//                 // IF sender.PrintBitmapBlob(Tray, RecRef, 29, 'QR_Code', Alignment::Center) Then;

//                 // FieldValue[1] := 'Scan this QR code to give us feedback';
//                 // sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, false, false, false));
//                 // NodeName[1] := 'Feedback Message';
//                 // sender.AddPrintLine(250, 1, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);

//                 // FieldValue[1] := 'feedback';
//                 // sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, false, false, false));
//                 // NodeName[1] := 'Feedback Message';
//                 // sender.AddPrintLine(250, 1, NodeName, FieldValue, DSTR1, false, false, false, false, Tray);
//             end;
//         end
//         Else begin
//             DSTR1 := '         #C####################         ';
//             //MasterKot
//             IF SubTotal = Total Then Begin
//                 FieldValue[1] := StrSubstNo(lText002, 'Total', SubTotal, 'Items');
//                 sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//                 NodeName[1] := 'Print Info';
//                 sender.AddPrintLine(250, 1, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);
//             End;
//         end;

//         IF SubTotal < Total Then begin
//             FieldValue[1] := StrSubstNo('%1 of %2 Items', SubTotal, Total);
//             sender.PrintLine(Tray, sender.FormatLine(sender.FormatStr(FieldValue, DSTR1), false, true, false, false));
//             NodeName[1] := 'Print Info';
//             sender.AddPrintLine(250, 1, NodeName, FieldValue, DSTR1, false, true, false, false, Tray);
//         end;

//         IsHandled := True;
//     end;

//     // local procedure getQR(SalesType: Code[20]; var URL: Text; var TempBlob: Codeunit "Temp Blob"; var EncodeStr: Text)
//     // var
//     //     Base64Convert: Codeunit "Base64 Convert";
//     //     Client: HttpClient;
//     //     Response: HttpResponseMessage;
//     //     Instr: InStream;
//     //     OutStr: OutStream;
//     //     TypeHelper: Codeunit "Type Helper";
//     // begin
//     //     URL := 'https://third-wavecoffee.typeform.com/to/y9REVGOg#ordernumber=xxxxx&couponcode=xxxxx&storeid=xxxxx';
//     //     Client.Get('https://barcode.tec-it.com/barcode.ashx?data=' + TypeHelper.UrlEncode(URL) + '&code=QRCode', Response);

//     //     TempBlob.CreateInStream(Instr);
//     //     Response.Content().ReadAs(Instr);
//     //     EncodeStr := Base64Convert.ToBase64(Instr);

//     //     TempBlob.CreateOutStream(OutStr);
//     //     Base64Convert.FromBase64(EncodeStr, OutStr);
//     // end;

//     var
//         CompanyInfo: Record "Company Information";
//         InvoiceTxt: Text;
//         Process: Dialog;
// }