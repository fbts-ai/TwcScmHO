codeunit 50004 AllSCMCustomization
{
    EventSubscriberInstance = StaticAutomatic;

    ///Related to item band name flow from Lot tracking to item ledger entry
    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCopyTrackingFromSpec', '', true, true)]
    local procedure RunOnAfterCopyTrackingFromSpec(var ItemJournalLine: Record "Item Journal Line"; TrackingSpecification: Record "Tracking Specification")
    begin
        ItemJournalLine.BrandName := TrackingSpecification.BrandName;
        ItemJournalLine.ManufacturingDate := TrackingSpecification.ManufacturingDate;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInitItemLedgEntry', '', true, true)]
    local procedure RunOnAfterInitItemLedgEntry(var NewItemLedgEntry: Record "Item Ledger Entry"; var ItemJournalLine: Record "Item Journal Line"; var ItemLedgEntryNo: Integer)
    begin
        NewItemLedgEntry.BrandName := ItemJournalLine.BrandName;
        NewItemLedgEntry.ManufacturingDate := ItemJournalLine.ManufacturingDate;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnCreateReservEntryExtraFields', '', true, true)]
    local procedure RunOnCreateReservEntryExtraFields(var InsertReservEntry: Record "Reservation Entry"; OldTrackingSpecification: Record "Tracking Specification"; NewTrackingSpecification: Record "Tracking Specification")
    begin
        InsertReservEntry.BrandName := OldTrackingSpecification.BrandName;
        InsertReservEntry.ManufacturingDate := OldTrackingSpecification.ManufacturingDate;
    end;
    //End Band band name
    //OnAfterCalcByDateTime

    //added for counting of calculate statement for pinelab Count
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Statement-Calculate", 'OnAfterCalcByDateTime', '', true, true)]
    local procedure OnAfterCalcByDateTime(var Statement: Record "LSC Statement")
    var
        TempStatmentLine: Record "LSC Statement Line";
        tempTransPay: Record "LSC Trans. Payment Entry";
        TempTransactionStatus5: Record "LSC Transaction Status";
        paymentcount: Integer;

    begin

        TempStatmentLine.Reset();
        TempStatmentLine.SetRange("Statement No.", Statement."No.");
        IF TempStatmentLine.FindSet() then
            repeat
                paymentcount := 0;
                TempTransactionStatus5.Reset();
                //  TempTransactionStatus.SetCurrentKey("Statement No.");
                TempTransactionStatus5.SetRange(TempTransactionStatus5."Store No.", Statement."Store No.");
                //TempTransactionStatus5.SetRange(TempTransactionStatus5."POS Terminal No.", StatementLine."POS Terminal No.");
                TempTransactionStatus5.SetRange(TempTransactionStatus5."Statement No.", Statement."No.");
                if TempTransactionStatus5.FindFirst() then
                    repeat
                        tempTransPay.Reset();
                        tempTransPay.SetRange("Transaction No.", TempTransactionStatus5."Transaction No.");
                        tempTransPay.SetRange("Tender Type", TempStatmentLine."Tender Type");
                        IF TempStatmentLine."POS Terminal No." <> '' Then
                            tempTransPay.SetRange("POS Terminal No.", TempStatmentLine."POS Terminal No.");

                        IF TempStatmentLine."Staff ID" <> '' then
                            tempTransPay.SetRange(tempTransPay."Staff ID", TempStatmentLine."Staff ID");

                        // IF TransactionStatus.staff
                        IF tempTransPay.FindSet() then
                            repeat
                                paymentcount := paymentcount + 1;
                            until tempTransPay.Next() = 0;

                    until TempTransactionStatus5.Next() = 0;
                TempStatmentLine.CountedTransaction := paymentcount;
                TempStatmentLine.Modify();

            until TempStatmentLine.Next() = 0;
    end;
    //Pinelab count end

    //GRN Customization

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"User Setup Management", 'OnBeforeIsPostingDateValidWithSetup', '', true, true)]
    local procedure OnBeforeIsPostingDateValidWithSetup(var SetupRecordID: RecordId; PostingDate: Date; var IsHandled: Boolean; var Result: Boolean)
    var
        TempUserSetup: Record "User Setup";
        AllowPostingFrom: Date;
        AllowPostingTo: Date;
        GLSetup: Record "General Ledger Setup";

    begin
        IF TempUserSetup.GET(USERID) THEN;
        IF TempUserSetup."AutomaticPostingDateCheck" THEN BEGIN

            //ANSA   //AA0509 Start

            AllowPostingFrom := CALCDATE(TempUserSetup."BackDaysAllowed", TODAY);
            AllowPostingTo := CALCDATE(TempUserSetup.ForwardDaysAllowed, TODAY);


            IF (PostingDate < AllowPostingFrom) OR (PostingDate > AllowPostingTo) THEN
                Error('Posting date should be within allow from and allow to Range');

            IsHandled := true;

            Result := true;
        END;

    end;
    /*
        [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnValidateUnitOfMeasureCodeOnBeforeValidateQuantity', '', true, true)]
        local procedure OnValidateUnitOfMeasureCodeOnBeforeValidateQuantity(Item: Record Item; var PurchaseLine: Record "Purchase Line"; xPurchaseLine: Record "Purchase Line")
        var
        begin
            IF xPurchaseLine."Unit of Measure" <> '' then
                if xPurchaseLine."Unit of Measure" <> PurchaseLine."Unit of Measure" then
                    Error('It is not allow to changed unit of measure on line ');
        end;
        */

    ///for manadatory Purchase Order reurn Code .

    [EventSubscriber(ObjectType::Page, Page::"Purchase Return Order", 'OnPostDocumentBeforeNavigateAfterPosting', '', true, true)]
    local procedure OnPostDocumentBeforeNavigateAfterPosting(var PurchaseHeader: Record "Purchase Header"; DocumentIsPosted: Boolean;
     sender: Page "Purchase Return Order"; var IsHandled: Boolean; var PostingCodeunitID: Integer)
    var
        TempPurchaseLine: record "Purchase Line";
    begin
        if PostingCodeunitID = CODEUNIT::"Purch.-Post (Yes/No)" then begin
            TempPurchaseLine.Reset();
            TempPurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
            TempPurchaseLine.SetFilter("No.", '<>%1', '');
            TempPurchaseLine.SetFilter("Return Qty. to Ship", '>%1', 0);
            TempPurchaseLine.SetFilter("Return Reason Code", '=%1', '');
            IF TempPurchaseLine.FindFirst() then
                Error('Please enter reason code for purchase returen order');
        end;
    end;

    ///for purchase return order
    /// 

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post (Yes/No)", 'OnBeforeSelectPostReturnOrderOption', '', true, true)]
    // local procedure PurchaseReturnOnBeforeSelectPostOrderOption(var PurchaseHeader: Record "Purchase Header"; DefaultOption: Integer; var IsHandled: Boolean; var Result: Boolean)
    // var
    //     ShipQst: Label '&Ship';
    //     Selection: Integer;
    // begin
    //     IF PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::"Return Order" then begin
    //         Selection := StrMenu(ShipQst, DefaultOption);
    //         if Selection > 0 then Begin

    //             PurchaseHeader.Ship := Selection in [1, 1];
    //             // PurchaseHeader.Invoice := Selection in [2, 2];
    //             IsHandled := True;
    //             Result := true;
    //         End;
    //     end;
    // end;


    //AJ_ALLE_09272023

    // Need To Check
    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post (Yes/No)", 'OnBeforeConfirmPost', '', false, false)]
    // local procedure OnBeforeConfirmSalesPost(var PurchaseHeader: Record "Purchase Header"; var HideDialog: Boolean; var IsHandled: Boolean; var DefaultOption: Integer);
    // var
    //     UserSetup: Record "User Setup";
    // begin
    //     HideDialog := true;
    //     NewConfirmPost(PurchaseHeader);
    // end;

    // local procedure NewConfirmPost(var PurchaseHeader: Record "Purchase Header"): Boolean
    // var
    //     Selection: Integer;
    //     ConfirmManagement: Codeunit "Confirm Management";
    //     Default: Label 'None';
    //     PurchInvoiceQst: Label 'Receive &and Invoice';

    // begin
    //     case PurchaseHeader."Document Type" of
    //         PurchaseHeader."Document Type"::Order:
    //             begin
    //                 Selection := StrMenu(PurchInvoiceQst, 1);
    //                 PurchaseHeader.Receive := Selection in [1, 1];
    //                 PurchaseHeader.Receive := true;
    //                 PurchaseHeader.Invoice := true;
    //                 if Selection = 0 then
    //                     exit(true);
    //                 //     PurchaseHeader."Print Posted Documents" := false;
    //                 // exit(true);
    //             end;


    //     end;
    // end;

    // //For Post Print
    // //AJ_ALLE_23012023
    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post + Print", 'OnBeforeConfirmPost', '', false, false)]
    // local procedure OnBeforeConfirmPost(var PurchaseHeader: Record "Purchase Header"; var HideDialog: Boolean; var IsHandled: Boolean; var DefaultOption: Integer);
    // var
    //     UserSetup: Record "User Setup";
    // begin
    //     // if PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Order then begin
    //     //     DefaultOption := 1;
    //     HideDialog := true;
    //     if NewConfirmPost1(PurchaseHeader) = false then
    //         IsHandled := true;
    //     //end;

    // end;

    // local procedure NewConfirmPost1(var PurchaseHeader: Record "Purchase Header"): Boolean
    // var
    //     Selection: Integer;
    //     ConfirmManagement: Codeunit "Confirm Management";
    //     Default: Label 'None';
    //     PurchInvoiceQst: Label 'Receive &and Invoice';

    // begin
    //     case PurchaseHeader."Document Type" of
    //         PurchaseHeader."Document Type"::Order:
    //             begin
    //                 Selection := StrMenu(PurchInvoiceQst, 1);
    //                 PurchaseHeader.Receive := Selection in [1, 1];
    //                 PurchaseHeader.Receive := true;
    //                 PurchaseHeader.Invoice := true;
    //                 if Selection = 0 then
    //                     exit(false) else
    //                     exit(true);
    //             end;
    //     end;
    // end;
    //AJ_ALLE_23012023




    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post (Yes/No)", 'OnBeforeConfirmSalesPost', '', false, false)]
    // local procedure OnBeforeConfirmSalesPost(var DefaultOption: Integer; var HideDialog: Boolean; var IsHandled: Boolean; var PostAndSend: Boolean; var SalesHeader: Record "Sales Header")
    // begin
    //     if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then begin
    //         DefaultOption := 1;
    //         HideDialog := true;
    //         NewConfirm(SalesHeader);
    //     end;
    // end;

    // procedure NewConfirm(var SalesHeader: Record "Sales Header"): Boolean
    // var
    //     ShipInvoiceQst: Label '&Ship';
    //     Selection: Integer;
    // //SalesHeader.Ship := Selection in [1, 1];
    // begin
    //     case SalesHeader."Document Type" of
    //         SalesHeader."Document Type"::Order:
    //             begin
    //                 Selection := StrMenu(ShipInvoiceQst, 1);
    //                 SalesHeader.Ship := Selection in [1, 1];
    //                 if Selection = 0 then
    //                     exit(false);
    //             end;
    //     end;
    // end;



    // Need To Check-To be discuss as on cancel its prociding with post
    //AJ_ALLE_09272023
    //AJ_Alle_09252023
    /*
        [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post (Yes/No)", 'OnBeforeSelectPostOrderOption', '', true, true)]
        local procedure OnBeforeSelectPostOrderOption(var PurchaseHeader: Record "Purchase Header"; DefaultOption: Integer; var IsHandled: Boolean; var Result: Boolean)
        var
            Selection: Integer;
            ReceiveInvoiceQst: Label '&Receive';
            BothReceiveInvoiceQst: Label 'Receive &and Invoice,&Invoice';
            BothReceiveInvoiceQst1: Label 'Receive &and Invoice';

        begin
            if ((PurchaseHeader.ReceviedAgainstDC) or (PurchaseHeader.GRNInvoiceAmount > 0)) then begin
                IsHandled := true;
                PurchaseHeader.Receive := true;
                PurchaseHeader.Invoice := true;
                if (PurchaseHeader.ReceviedAgainstDC) then begin
                    Selection := StrMenu(ReceiveInvoiceQst, DefaultOption);
                    if Selection > 0 then Begin

                        PurchaseHeader.Receive := Selection in [1, 1];
                        // PurchaseHeader.Invoice := Selection in [2, 2];

                        Result := true;
                    End;

                end
                else begin
                    Selection := StrMenu(BothReceiveInvoiceQst, DefaultOption);

                    if Selection > 0 then Begin
                        if Selection = 1 then begin
                            PurchaseHeader.Receive := Selection in [1, 2];
                            PurchaseHeader.Invoice := Selection in [1, 2];

                        end;
                        if Selection = 2 then begin
                            PurchaseHeader.Invoice := Selection in [2, 2];
                        end;

                        Result := true;
                    End;

                end;
            end;
        end;
    */
    //Comment
    //AJ_Alle_09252023
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Retail Purchase Order Ext.", 'OnBeforePurchaseHeaderLocationCodeOnBeforeValidateEvent', '', true, true)]
    local procedure OnBeforePurchaseHeaderLocationCodeOnBeforeValidateEvent(var Rec: Record "Purchase Header"; var xRec: Record "Purchase Header"; var IsHandled: Boolean; CurrFieldNo: Integer)
    var

    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Retail Purchase Order Ext.", 'OnBeforeOnPurchaseHeaderOnAfterInit', '', true, true)]
    local procedure OnBeforeOnPurchaseHeaderOnAfterInit(var PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean)
    var

    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Retail Purchase Order Ext.", 'OnBeforeValidateStoreNoAndLocationCode', '', true, true)]
    local procedure OnBeforeValidateStoreNoAndLocationCode(var PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean)
    var
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterInitRecord', '', true, true)]
    local procedure OnAfterInitRecord(var PurchHeader: Record "Purchase Header")
    var
        tempuserSetup: Record "User Setup";
    begin
        IF tempuserSetup.get(UserId) then;
        PurchHeader."Location Code" := tempuserSetup."Location Code";
    end;

    //to add Purchase invoice No to as purchase credit Memo
    //start
    //

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnBeforeCopyPurchaseLinesToDoc', '', true, true)]
    local procedure OnBeforeCopyPurchaseLinesToDoc(var FromPurchCrMemoLine: Record "Purch. Cr. Memo Line"; var ToPurchaseHeader: Record "Purchase Header"; FromDocType: Option; var FromPurchInvLine: Record "Purch. Inv. Line"; var FromPurchRcptLine: Record "Purch. Rcpt. Line"; var FromReturnShipmentLine: Record "Return Shipment Line"; var LinesNotCopied: Integer; var MissingExCostRevLink: Boolean)
    begin
        // Message(FromPurchInvLine."Document No.");
        IF ToPurchaseHeader."Vendor Cr. Memo No." = '' then begin
            ToPurchaseHeader."Vendor Cr. Memo No." := FromPurchInvLine."Document No.";
            ToPurchaseHeader.Modify();
        end;
    end;


    //end

    //autolot assignment
    procedure GRNReservationEntry(var TempPurchaseLine: Record "Purchase Line")

    var
        n_reservationentry: Record "Reservation Entry";
        ReservationEntry: Record "Reservation Entry";
        entryNumber: Integer;
        LotNo: Code[20];
        NoSeriesMgt: Codeunit NoSeriesManagement;
        tempItem: Record "Item";
        expDate: Date;
        TempPurchaseHeader: Record "Purchase Header";
    begin
        IF n_reservationentry.FINDLAST THEN
            entryNumber := n_reservationentry."Entry No." + 1;

        if tempItem.Get(TempPurchaseLine."No.") Then;

        ReservationEntry.RESET;
        ReservationEntry."Entry No." := entryNumber;
        LotNo := NoSeriesMgt.GetNextNo(tempItem."Lot Nos.", WorkDate(), true);
        ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot No.";
        ReservationEntry."Lot No." := LotNo;

        ReservationEntry."Location Code" := TempPurchaseLine."Location Code";
        ReservationEntry."Quantity (Base)" := TempPurchaseLine."Quantity (Base)";
        ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Surplus;
        ReservationEntry.Description := TempPurchaseLine.Description;
        ReservationEntry."Creation Date" := WORKDATE;
        ReservationEntry."Source Type" := 39;
        ReservationEntry."Source Subtype" := ReservationEntry."Source Subtype"::"1";
        ReservationEntry."Source ID" := TempPurchaseLine."Document No.";
        ReservationEntry."Source Ref. No." := TempPurchaseLine."Line No.";
        ReservationEntry."Created By" := USERID;
        ReservationEntry.Positive := true;
        ReservationEntry."Expected Receipt Date" := TempPurchaseLine."Expected Receipt Date";
        ReservationEntry."Item No." := TempPurchaseLine."No.";
        ReservationEntry."Qty. per Unit of Measure" := TempPurchaseLine."Qty. per Unit of Measure";
        ReservationEntry.Quantity := TempPurchaseLine.Quantity;
        //ReservationEntry."Quantity (Base)" := (ABS(TempTransferLine."Quantity (Base)")) * -1;
        ReservationEntry.Validate(ReservationEntry.Quantity);
        ReservationEntry."Qty. to Handle (Base)" := TempPurchaseLine."Qty. to Receive (Base)";
        ReservationEntry."Qty. to Invoice (Base)" := TempPurchaseLine."Qty. to Invoice (Base)";
        ReservationEntry.AutoLotDocumentNo := TempPurchaseLine."Document No.";
        TempPurchaseHeader.Reset();
        TempPurchaseHeader.SetRange("No.", TempPurchaseLine."Document No.");
        IF TempPurchaseHeader.FindFirst() then;

        IF Format(tempItem."Expiration Calculation") <> '' then begin
            expDate := CalcDate('<' + Format(tempItem."Expiration Calculation") + '>', TempPurchaseHeader."Posting Date");
            ReservationEntry."Expiration Date" := expDate;
        end;


        //  ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot No.";
        //  ReservationEntry."Lot No." := LotNo;


        //ReservationEntry."Qty. to Handle (Base)" := TempTransferLine."Qty. to Receive (Base)";
        //ReservationEntry."Qty. to Invoice (Base)" := TempTransferLine."Qty. to Receive (Base)";
        //TempTransferLine."Variant Code";
        //ReservationEntry."Variant Code" := TempTransferLine."Variant Code";

        ReservationEntry.INSERT;



    end;

    [EventSubscriber(ObjectType::Page, PAGE::"PurchaseOrderGRN", 'OnBeforeActionEvent', 'Post', false, false)]
    local procedure PO_Post_OnBeforeActionEvent(Rec: Record "Purchase Header")
    var
        PurchLine: Record "Purchase Line";
        FixedAsset: Record "Fixed Asset";
    begin
        PurchLine.Reset();
        PurchLine.SetRange("Document Type", Rec."Document Type");
        PurchLine.SetRange("Document No.", Rec."No.");
        PurchLine.SetRange(Type, PurchLine.Type::"Fixed Asset");
        IF PurchLine.FindSet() then
            repeat
                // IF FixedAsset.Get(PurchLine."No.") then begin //PT-FBTS-OLD CODE
                //     IF FixedAsset."PO Item" then

                //         Error('You can not post fixed asset which only for PO Creation');
                // end
                //PT-FBTS -09-08-24
                IF FixedAsset.Get(PurchLine."No.") then begin
                    IF (FixedAsset."PO Item") AND (PurchLine."Qty. to Receive" <> 0) then
                        Error('You can not post fixed asset which only for PO Creation');
                end
            //PT-FBTS -09-08-24
            until PurchLine.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Page, PAGE::"PurchaseOrderGRN", 'OnBeforeActionEvent', 'Post and &Print', false, false)]
    local procedure PO_PostPrint_OnBeforeActionEvent(Rec: Record "Purchase Header")
    var
        PurchLine: Record "Purchase Line";
        FixedAsset: Record "Fixed Asset";
    begin
        PurchLine.Reset();
        PurchLine.SetRange("Document Type", Rec."Document Type");
        PurchLine.SetRange("Document No.", Rec."No.");
        PurchLine.SetRange(Type, PurchLine.Type::"Fixed Asset");
        IF PurchLine.FindSet() then
            repeat
                // IF FixedAsset.Get(PurchLine."No.") then begin //PT-FBTS-Old Code
                //     IF FixedAsset."PO Item" then
                //         Error('You can not post fixed asset which only for PO Creation');
                // end
                //PT-FBTS-09-08-24 
                IF FixedAsset.Get(PurchLine."No.") then begin
                    IF (FixedAsset."PO Item") AND (PurchLine."Qty. to Receive" <> 0) then
                        Error('You can not post fixed asset which only for PO Creation');
                end
            //PT-FBTS-09-08-24 
            until PurchLine.Next() = 0;
    end;


    [EventSubscriber(ObjectType::Page, PAGE::"Purchase Order GRN Subform", 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure PO_No_OnAfterValidateEvent(Rec: Record "Purchase Line")
    var
        FixedAsset: Record "Fixed Asset";
    begin
        IF Rec.Type = Rec.Type::"Fixed Asset" then begin
            IF FixedAsset.Get(Rec."No.") then begin
                IF Not FixedAsset."PO Item" then
                    Error('You can not choose fixed asset which is not PO enabled');
            end
        end;
    end;

    [EventSubscriber(ObjectType::Page, PAGE::"Purchase Order Subform", 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure PurchaseOrderOnAfterValidateEvent(Rec: Record "Purchase Line")
    var
        FixedAsset: Record "Fixed Asset";
    begin
        IF Rec.Type = Rec.Type::"Fixed Asset" then begin
            IF FixedAsset.Get(Rec."No.") then begin
                IF Not FixedAsset."PO Item" then
                    Error('You can not choose fixed asset which is not PO enabled');
            end
        end;
    end;




    //GRN end
    ///Coomented
    /// 
    /*
     ///GST sales invoice bvalidation
     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post (Yes/No)", 'OnBeforeOnRun', '', true, true)]
     local procedure GSTValidationOnBeforeOnRun(var SalesHeader: Record "Sales Header")
     begin
         IF SalesHeader."Shipping Agent Code" = '' then
             Error('Shipping Agent Code Must have value in sales Invoice Header');
     end;

     ///End
     */

    //Transfer Order In Out 



    /*
    //to check GST Manadatory Validation
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post (Yes/No)", 'OnBeforePost', '', true, true)]
    local procedure GSTValidationOnBeforePost(var TransHeader: Record "Transfer Header"; var TransferOrderPostShipment: Codeunit "TransferOrder-Post Shipment"; var TransferOrderPostReceipt: Codeunit "TransferOrder-Post Receipt"; var IsHandled: Boolean)
    var
    begin
        IF TransHeader."Shipping Agent Code" = '' then
            Error('Shipping Agent code must have Value on Transfer Header');
    end;
    */

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post", 'OnBeforeCode', '', true, true)]
    local procedure RunOnBeforeCode(var ItemJournalLine: Record "Item Journal Line"; var HideDialog: Boolean; var IsHandled: Boolean; var SuppressCommit: Boolean)
    var
        InventSetup: Record "Inventory Setup";
    begin
        InventSetup.Get();
        IF ItemJournalLine."Journal Batch Name" = InventSetup.FATransferBatchName then
            HideDialog := true;
    end;

    /*
        [EventSubscriber(ObjectType::Page, Page::"Transfer Order", 'OnAfterValidateEvent', 'No.', true, true)]
        local procedure RunOnAfterValidateEvent(var Rec: Record "Transfer Header"; var xRec: Record "Transfer Header")
        var
            TempUserSetup: Record "User Setup";
        begin

            if TempUserSetup.Get(UserId) then;
            Rec."Transfer-from Code" := TempUserSetup."Location Code";

        end;
        */
    //End transfer in out 

    //Interstore Transfer Order Start

    [EventSubscriber(ObjectType::Table, Database::"Transfer Header", 'OnAfterInitRecord', '', true, true)]
    local procedure RunOnAfterInitRecord(var TransferHeader: Record "Transfer Header")
    var
        TempUserSetup: Record "User Setup";
    begin
        if TransferHeader.InStoreTransfer then begin
            if TempUserSetup.Get(UserId) then;
            TransferHeader."Transfer-from Code" := TempUserSetup."Location Code";
            TransferHeader.Validate(TransferHeader."Transfer-from Code");
            TransferHeader."Direct Transfer" := true;
            //TransferHeader.Validate(TransferHeader."Direct Transfer");

        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Header", 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInsertEvent(var Rec: Record "Transfer Header")
    var
        TempUserSetup: Record "User Setup";
    begin
        /*
        if Rec.InStoreTransfer then begin
            if TempUserSetup.Get(UserId) then;
            Rec."Transfer-from Code" := TempUserSetup."Location Code";
            Rec.Validate(Rec."Transfer-from Code");
            Rec."Direct Transfer" := true;
            //TransferHeader.Validate(TransferHeader."Direct Transfer");

        end;
        */
    end;
    /*
        [EventSubscriber(ObjectType::Table, Database::"Transfer Header", 'OnAfterValidateEvent', 'Transfer-from Code', true, true)]
        local procedure TransferFromOnAfterValidateEvent(var Rec: Record "Transfer Header"; CurrFieldNo: Integer; var xRec: Record "Transfer Header")
        var
            TempLocation: Record "Location";
        begin
            Rec.Validate(Rec."Transfer-from Code");
        end;
        */

    [EventSubscriber(ObjectType::Table, Database::"Transfer Header", 'OnAfterValidateEvent', 'Transfer-to Code', true, true)]
    local procedure TransfertoOnAfterValidateEvent(var Rec: Record "Transfer Header"; CurrFieldNo: Integer; var xRec: Record "Transfer Header")
    var
        TempLocation: Record "Location";
    begin
        IF TempLocation.Get(Rec."Transfer-to Code") then;
        /*
           if TempLocation.IsWarehouse then begin
               Rec."Direct Transfer" := true;
               Rec.Validate(Rec."Direct Transfer");
           end
           Else begin
               IF NOt Rec.InStoreTransfer Then
                   Rec."Direct Transfer" := false;

           end;
           */

        IF Rec.InStoreTransfer Then begin
            Rec."Direct Transfer" := true;
            Rec.Validate(Rec."Direct Transfer");
        end;



    End;
    /*
        [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnBeforeTransferOrderPostShipment', '', true, true)]
        local procedure RunOnBeforeTransferOrderPostShipment(var TransferHeader: Record "Transfer Header"; var CommitIsSuppressed: Boolean)
        var
            TempUserSetup: Record "User Setup";
        begin
            if TempUserSetup.Get(UserId) then;
            if TransferHeader.InStoreTransfer then begin
                if (TransferHeader."Transfer-from Code" <> TempUserSetup."Location Code") then
                    Error('Location Mentioned on User card and transfer from location must be same');
            end;
        end;

        [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnBeforeTransferOrderPostReceipt', '', true, true)]
        local procedure RunOnBeforeTransferOrderPostReceipt(var TransferHeader: Record "Transfer Header"; var CommitIsSuppressed: Boolean; var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line")
        var
            TempUserSetup: Record "User Setup";
        begin
            if TempUserSetup.Get(UserId) then;
            if TransferHeader.InStoreTransfer then begin
                if (TransferHeader."Transfer-to Code" <> TempUserSetup."Location Code") then
                    Error('Location Mentioned on User card and transfer from location must be same');
            end;
        end;
       */
    [EventSubscriber(ObjectType::Table, Database::"Transfer Line", 'OnValidateItemNoOnAfterInitLine', '', true, true)]
    local procedure RunOnValidateItemNoOnAfterInitLine(var TransferLine: Record "Transfer Line"; TempTransferLine: Record "Transfer Line" temporary)
    var
        TempItem: Record Item;
        TempTransferHeader: Record "Transfer Header";
    begin
        TempTransferHeader.Reset();
        TempTransferHeader.SetRange("No.", TransferLine."Document No.");
        if TempTransferHeader.FindFirst() then;

        IF TempTransferHeader.InStoreTransfer then Begin
            IF TempItem.Get(TransferLine."Item No.") then Begin
                if NOT TempItem.InstoreAllowed then
                    Error('Please select Items with Instore Tranfer allow ');
            End;
        End;
    end;

    procedure InterstoreReservationEntry(var TempTransferLine: Record "Transfer Line";
    var LotNo: Code[20]; var qty: Decimal; var qty_base: Decimal; var qtyshipbase: Decimal; var qtyreceviedbase: Decimal; var expdate1: Date; var manfactDate1: Date)

    var
        n_reservationentry: Record "Reservation Entry";
        ReservationEntry: Record "Reservation Entry";
        entryNumber: Integer;
    begin
        IF n_reservationentry.FINDLAST THEN
            entryNumber := n_reservationentry."Entry No." + 1;


        ReservationEntry.RESET;
        ReservationEntry."Entry No." := entryNumber;
        ReservationEntry."Location Code" := TempTransferLine."Transfer-from Code";
        ReservationEntry."Quantity (Base)" := (ABS(qty_base)) * -1;
        ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Surplus;
        ReservationEntry.Description := TempTransferLine.Description;
        ReservationEntry."Creation Date" := WORKDATE;
        ReservationEntry."Source Type" := 5741;
        ReservationEntry."Source Subtype" := ReservationEntry."Source Subtype"::"0";
        ReservationEntry."Source ID" := TempTransferLine."Document No.";
        ReservationEntry."Source Ref. No." := TempTransferLine."Line No.";
        ReservationEntry."Created By" := USERID;
        ReservationEntry.Positive := False;
        ReservationEntry."Shipment Date" := TempTransferLine."Shipment Date";
        ReservationEntry."Item No." := TempTransferLine."Item No.";
        ReservationEntry."Qty. per Unit of Measure" := TempTransferLine."Qty. per Unit of Measure";
        ReservationEntry.Quantity := (qty) * -1;
        //ReservationEntry."Quantity (Base)" := (ABS(TempTransferLine."Quantity (Base)")) * -1;
        ReservationEntry.Validate(ReservationEntry.Quantity);
        ReservationEntry."Qty. to Handle (Base)" := qtyshipbase * -1;
        ReservationEntry."Qty. to Invoice (Base)" := qtyreceviedbase * -1;

        ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot No.";
        ReservationEntry."Lot No." := LotNo;
        ReservationEntry.AutoLotDocumentNo := TempTransferLine."Document No.";

        IF expdate1 <> 0D then
            ReservationEntry."Expiration Date" := expdate1;

        IF manfactDate1 <> 0D Then
            ReservationEntry.ManufacturingDate := manfactDate1;



        //ReservationEntry."Qty. to Handle (Base)" := TempTransferLine."Qty. to Receive (Base)";
        //ReservationEntry."Qty. to Invoice (Base)" := TempTransferLine."Qty. to Receive (Base)";
        //TempTransferLine."Variant Code";
        //ReservationEntry."Variant Code" := TempTransferLine."Variant Code";

        ReservationEntry.INSERT;

        //for transfer location

        IF n_reservationentry.FINDLAST THEN
            entryNumber := n_reservationentry."Entry No." + 1;


        ReservationEntry.RESET;
        ReservationEntry."Entry No." := entryNumber;
        ReservationEntry."Location Code" := TempTransferLine."Transfer-to Code";
        ReservationEntry."Quantity (Base)" := (ABS(qty_base));
        ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Surplus;
        ReservationEntry.Description := TempTransferLine.Description;
        ReservationEntry."Creation Date" := WORKDATE;
        ReservationEntry."Source Type" := 5741;
        ReservationEntry."Source Subtype" := ReservationEntry."Source Subtype"::"1";
        ReservationEntry."Source ID" := TempTransferLine."Document No.";
        ReservationEntry."Source Ref. No." := TempTransferLine."Line No.";
        ReservationEntry."Created By" := USERID;
        ReservationEntry.Positive := true;
        ReservationEntry."Expected Receipt Date" := TempTransferLine."Receipt Date";
        ReservationEntry."Item No." := TempTransferLine."Item No.";
        ReservationEntry."Qty. per Unit of Measure" := TempTransferLine."Qty. per Unit of Measure";
        ReservationEntry.Quantity := ABS(qty);
        ReservationEntry."Qty. to Handle (Base)" := qtyshipbase;
        ReservationEntry."Qty. to Invoice (Base)" := qtyreceviedbase;



        //ReservationEntry."Quantity (Base)" := (ABS(TempTransferLine."Quantity (Base)")) * -1;
        ReservationEntry.Validate(ReservationEntry.Quantity);

        ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot No.";
        ReservationEntry."Lot No." := LotNo;
        ReservationEntry.AutoLotDocumentNo := TempTransferLine."Document No.";

        IF expdate1 <> 0D then
            ReservationEntry."Expiration Date" := expdate1;

        IF manfactDate1 <> 0D Then
            ReservationEntry.ManufacturingDate := manfactDate1;


        //ReservationEntry."Qty. to Handle (Base)" := TempTransferLine."Qty. to Receive (Base)";
        //ReservationEntry."Qty. to Invoice (Base)" := TempTransferLine."Qty. to Receive (Base)";
        //TempTransferLine."Variant Code";
        //ReservationEntry."Variant Code" := TempTransferLine."Variant Code";

        ReservationEntry.INSERT;

    end;


    ////PT-FBTS
    procedure InterstoreReservationEntryAssembly(var TempTransferLine: Record "Assembly Line";
        var LotNo: Code[20]; var qty: Decimal; var qty_base: Decimal; var qtyshipbase: Decimal; var qtyreceviedbase: Decimal; var expdate1: Date; var manfactDate1: Date)

    var
        n_reservationentry: Record "Reservation Entry";
        ReservationEntry: Record "Reservation Entry";
        entryNumber: Integer;
        Assemblyheader: Record "Assembly Header";//PT-FBTS 200225
    begin
        Assemblyheader.Reset();
        Assemblyheader.SetRange("No.", TempTransferLine."Document No.");
        if Assemblyheader.FindFirst() then;
        IF n_reservationentry.FINDLAST THEN
            entryNumber := n_reservationentry."Entry No." + 1;


        ReservationEntry.RESET;
        ReservationEntry."Entry No." := entryNumber;
        ReservationEntry."Location Code" := TempTransferLine."Location Code";
        ReservationEntry."Quantity (Base)" := (ABS(qty_base)) * -1;
        ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Surplus;
        ReservationEntry.Description := TempTransferLine.Description;
        ReservationEntry."Creation Date" := WORKDATE;
        ReservationEntry."Source Type" := 5741;
        ReservationEntry."Source Subtype" := ReservationEntry."Source Subtype"::"0";
        ReservationEntry."Source ID" := TempTransferLine."Document No.";
        ReservationEntry."Source Ref. No." := TempTransferLine."Line No.";
        ReservationEntry."Created By" := USERID;
        ReservationEntry.Positive := False;
        ReservationEntry."Shipment Date" := Assemblyheader."Posting Date";
        ReservationEntry."Item No." := TempTransferLine."No.";
        ReservationEntry."Qty. per Unit of Measure" := TempTransferLine."Qty. per Unit of Measure";
        ReservationEntry.Quantity := (qty) * -1;
        //ReservationEntry."Quantity (Base)" := (ABS(TempTransferLine."Quantity (Base)")) * -1;
        ReservationEntry.Validate(ReservationEntry.Quantity);
        ReservationEntry."Qty. to Handle (Base)" := qtyshipbase * -1;
        ReservationEntry."Qty. to Invoice (Base)" := qtyreceviedbase * -1;

        ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot No.";
        ReservationEntry."Lot No." := LotNo;
        ReservationEntry.AutoLotDocumentNo := TempTransferLine."Document No.";

        IF expdate1 <> 0D then
            ReservationEntry."Expiration Date" := expdate1;

        IF manfactDate1 <> 0D Then
            ReservationEntry.ManufacturingDate := manfactDate1;



        //ReservationEntry."Qty. to Handle (Base)" := TempTransferLine."Qty. to Receive (Base)";
        //ReservationEntry."Qty. to Invoice (Base)" := TempTransferLine."Qty. to Receive (Base)";
        //TempTransferLine."Variant Code";
        //ReservationEntry."Variant Code" := TempTransferLine."Variant Code";

        ReservationEntry.INSERT;

        //for transfer location

        IF n_reservationentry.FINDLAST THEN
            entryNumber := n_reservationentry."Entry No." + 1;


        ReservationEntry.RESET;
        ReservationEntry."Entry No." := entryNumber;
        ReservationEntry."Location Code" := TempTransferLine."Location Code";
        ReservationEntry."Quantity (Base)" := (ABS(qty_base));
        ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Surplus;
        ReservationEntry.Description := TempTransferLine.Description;
        ReservationEntry."Creation Date" := WORKDATE;
        ReservationEntry."Source Type" := 5741;
        ReservationEntry."Source Subtype" := ReservationEntry."Source Subtype"::"1";
        ReservationEntry."Source ID" := TempTransferLine."Document No.";
        ReservationEntry."Source Ref. No." := TempTransferLine."Line No.";
        ReservationEntry."Created By" := USERID;
        ReservationEntry.Positive := true;
        ReservationEntry."Expected Receipt Date" := Assemblyheader."Posting Date";
        ReservationEntry."Item No." := TempTransferLine."No.";
        ReservationEntry."Qty. per Unit of Measure" := TempTransferLine."Qty. per Unit of Measure";
        ReservationEntry.Quantity := ABS(qty);
        ReservationEntry."Qty. to Handle (Base)" := qtyshipbase;
        ReservationEntry."Qty. to Invoice (Base)" := qtyreceviedbase;



        //ReservationEntry."Quantity (Base)" := (ABS(TempTransferLine."Quantity (Base)")) * -1;
        ReservationEntry.Validate(ReservationEntry.Quantity);

        ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot No.";
        ReservationEntry."Lot No." := LotNo;
        ReservationEntry.AutoLotDocumentNo := TempTransferLine."Document No.";

        IF expdate1 <> 0D then
            ReservationEntry."Expiration Date" := expdate1;

        IF manfactDate1 <> 0D Then
            ReservationEntry.ManufacturingDate := manfactDate1;


        //ReservationEntry."Qty. to Handle (Base)" := TempTransferLine."Qty. to Receive (Base)";
        //ReservationEntry."Qty. to Invoice (Base)" := TempTransferLine."Qty. to Receive (Base)";
        //TempTransferLine."Variant Code";
        //ReservationEntry."Variant Code" := TempTransferLine."Variant Code";

        ReservationEntry.INSERT;

    end;
    /////PT-FBTS


    procedure TransferOrderReservationEntry(var TempTransferLine: Record "Transfer Line";
   var LotNo: Code[20]; var qty: Decimal; var qty_base: Decimal; var qtyshipbase: Decimal; var qtyreceviedbase: Decimal; var expdate1: Date; var manufactDate1: Date)

    var
        n_reservationentry: Record "Reservation Entry";
        ReservationEntry: Record "Reservation Entry";
        entryNumber: Integer;
    begin
        IF n_reservationentry.FINDLAST THEN
            entryNumber := n_reservationentry."Entry No." + 1;


        ReservationEntry.RESET;
        ReservationEntry."Entry No." := entryNumber;
        ReservationEntry."Location Code" := TempTransferLine."Transfer-from Code";
        ReservationEntry."Quantity (Base)" := (ABS(qty_base)) * -1;
        ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Surplus;
        ReservationEntry.Description := TempTransferLine.Description;
        ReservationEntry."Creation Date" := WORKDATE;
        ReservationEntry."Source Type" := 5741;
        ReservationEntry."Source Subtype" := ReservationEntry."Source Subtype"::"0";
        ReservationEntry."Source ID" := TempTransferLine."Document No.";
        ReservationEntry."Source Ref. No." := TempTransferLine."Line No.";
        ReservationEntry."Created By" := USERID;
        ReservationEntry.Positive := False;
        ReservationEntry."Shipment Date" := TempTransferLine."Shipment Date";
        ReservationEntry."Item No." := TempTransferLine."Item No.";
        ReservationEntry."Qty. per Unit of Measure" := TempTransferLine."Qty. per Unit of Measure";
        ReservationEntry.Quantity := (qty) * -1;
        //ReservationEntry."Quantity (Base)" := (ABS(TempTransferLine."Quantity (Base)")) * -1;
        ReservationEntry.Validate(ReservationEntry.Quantity);
        ReservationEntry."Qty. to Handle (Base)" := qtyshipbase * -1;
        ReservationEntry."Qty. to Invoice (Base)" := qtyreceviedbase * -1;

        ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot No.";
        ReservationEntry."Lot No." := LotNo;
        ReservationEntry.AutoLotDocumentNo := TempTransferLine."Document No.";

        IF expdate1 <> 0D Then
            ReservationEntry."Expiration Date" := expdate1;

        IF manufactDate1 <> 0D Then
            ReservationEntry.ManufacturingDate := manufactDate1;



        //ReservationEntry."Qty. to Handle (Base)" := TempTransferLine."Qty. to Receive (Base)";
        //ReservationEntry."Qty. to Invoice (Base)" := TempTransferLine."Qty. to Receive (Base)";
        //TempTransferLine."Variant Code";
        //ReservationEntry."Variant Code" := TempTransferLine."Variant Code";

        ReservationEntry.INSERT;

        //for transfer location

        IF n_reservationentry.FINDLAST THEN
            entryNumber := n_reservationentry."Entry No." + 1;


        ReservationEntry.RESET;
        ReservationEntry."Entry No." := entryNumber;
        ReservationEntry."Location Code" := TempTransferLine."Transfer-to Code";
        ReservationEntry."Quantity (Base)" := (ABS(qty_base));
        ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Surplus;
        ReservationEntry.Description := TempTransferLine.Description;
        ReservationEntry."Creation Date" := WORKDATE;
        ReservationEntry."Source Type" := 5741;
        ReservationEntry."Source Subtype" := ReservationEntry."Source Subtype"::"1";
        ReservationEntry."Source ID" := TempTransferLine."Document No.";
        ReservationEntry."Source Ref. No." := TempTransferLine."Line No.";
        ReservationEntry."Created By" := USERID;
        ReservationEntry.Positive := true;
        ReservationEntry."Expected Receipt Date" := TempTransferLine."Receipt Date";
        ReservationEntry."Item No." := TempTransferLine."Item No.";
        ReservationEntry."Qty. per Unit of Measure" := TempTransferLine."Qty. per Unit of Measure";
        ReservationEntry.Quantity := ABS(qty);
        ReservationEntry."Qty. to Handle (Base)" := qtyshipbase;
        ReservationEntry."Qty. to Invoice (Base)" := qtyreceviedbase;



        //ReservationEntry."Quantity (Base)" := (ABS(TempTransferLine."Quantity (Base)")) * -1;
        ReservationEntry.Validate(ReservationEntry.Quantity);

        ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot No.";
        ReservationEntry."Lot No." := LotNo;
        ReservationEntry.AutoLotDocumentNo := TempTransferLine."Document No.";

        IF expdate1 <> 0D Then
            ReservationEntry."Expiration Date" := expdate1;

        IF manufactDate1 <> 0D Then
            ReservationEntry.ManufacturingDate := manufactDate1;


        //ReservationEntry."Qty. to Handle (Base)" := TempTransferLine."Qty. to Receive (Base)";
        //ReservationEntry."Qty. to Invoice (Base)" := TempTransferLine."Qty. to Receive (Base)";
        //TempTransferLine."Variant Code";
        //ReservationEntry."Variant Code" := TempTransferLine."Variant Code";

        ReservationEntry.INSERT;

    end;

    //Inter store transfer order end

    ///ALL Local Purchase Customization Start
    [EventSubscriber(ObjectType::Page, Page::"Purchase Order", 'OnInsertRecordEvent', '', true, true)]
    local procedure OnInsertRecordEvent(var Rec: Record "Purchase Header"; var xRec: Record "Purchase Header"; var AllowInsert: Boolean; BelowxRec: Boolean)
    var
        tempusersetp: Record "User Setup";
    begin
        IF tempusersetp.Get(UserId) then;
        // Rec."Location Code" := tempusersetp."Location Code";
        //ShipToOptions := ShipToOptions::Location;
        // ValidateShippingOption();

        //Rec."Location Code" := tempusersetp."Location Code";
        // Rec.Modify();
        //  Rec.Validate(Rec."Location Code");
    end;
    /*
        [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterInitRecord', '', true, true)]
        local procedure OnAfterInitRecord(var PurchHeader: Record "Purchase Header")
        var
            TempUserSetup: Record "User Setup";
        begin
            IF TempUserSetup.get(UserId) then;
            PurchHeader."Location Code" := TempUserSetup."Location Code";
            PurchHeader.Validate(PurchHeader."Location Code");
        end;

        [EventSubscriber(ObjectType::Page, Page::"Purchase Order", 'OnNewRecordEvent', '', true, true)]
        local procedure PurchOnNewRecordEvent(var Rec: Record "Purchase Header"; var xRec: Record "Purchase Header"; BelowxRec: Boolean)
        var
            TempUserSetup: Record "User Setup";
        begin
            IF TempUserSetup.get(UserId) then;
            Rec."Location Code" := TempUserSetup."Location Code";
            Rec.Validate(Rec."Location Code");
        end;
        

    [EventSubscriber(ObjectType::Page, Page::"Local Purchase Order", 'OnNewRecordEvent', '', true, true)]
    local procedure LocalPurchOnNewRecordEvent(var Rec: Record "Purchase Header"; var xRec: Record "Purchase Header"; BelowxRec: Boolean)
    var
        TempUserSetup: Record "User Setup";
    begin
        IF TempUserSetup.get(UserId) then;
        Rec."Location Code" := TempUserSetup."Location Code";
        Rec.Validate(Rec."Location Code");
    end;
    */


    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Buy-from Vendor No.', true, true)]
    local procedure PurchHeaderOnAfterValidateEvent(var Rec: Record "Purchase Header"; var xRec: Record "Purchase Header"; CurrFieldNo: Integer)
    var
        TempUserSetup: Record "User Setup";
    begin
        IF TempUserSetup.get(UserId) then;
        Rec."Location Code" := TempUserSetup."Location Code";
        Rec.Validate(Rec."Location Code");
        Rec.ReceviedAgainstDC := True;
    end;

    /*
[EventSubscriber(ObjectType::Page, Page::"Purchase Order", 'OnAfterValidateEvent', 'Buy-from Vendor No.', true, true)]
local procedure PurchHeaderOnAfterValidateEvent(var Rec: Record "Purchase Header"; var xRec: Record "Purchase Header")
var
    TempUserSetup: Record "User Setup";
begin
    IF TempUserSetup.get(UserId) then;
    Rec."Location Code" := TempUserSetup."Location Code";
    Rec.Validate(Rec."Location Code");
end;
*/



    [EventSubscriber(ObjectType::Page, Page::"Local Purchase Order", 'OnAfterValidateEvent', 'Buy-from Vendor No.', true, true)]
    local procedure RunnAfterValidateEvent(var Rec: Record "Purchase Header"; var xRec: Record "Purchase Header")
    var
        TempUserSetup: Record "User Setup";
        tempLocation: Record "Location";
        tempvendor1: Record Vendor;
        cashVendor1: Boolean;
    begin
        if tempusersetup.Get(UserId) then;
        tempLocation.Get(tempusersetup."Location Code");
        tempvendor1.Reset();
        tempvendor1.SetFilter(tempvendor1."No.", tempLocation.CashVendor);
        if tempvendor1.FindSet() Then
            repeat
                if tempvendor1."No." = Rec."Buy-from Vendor No." then
                    cashVendor1 := true;

            until tempvendor1.next = 0;
        if not cashVendor1 then
            error('Please select vendor only which mention as cash vendor on location card');
    end;

    procedure LocalPurchaseReservationEntry(var TempPurchaseLine: Record "Purchase Line")

    var
        n_reservationentry: Record "Reservation Entry";
        ReservationEntry: Record "Reservation Entry";
        entryNumber: Integer;
        LotNo: Code[20];
        NoSeriesMgt: Codeunit NoSeriesManagement;
        tempItem: Record "Item";
        TempPurchaseHeader: Record "Purchase Header";

        expDate: Date;
    begin
        IF n_reservationentry.FINDLAST THEN
            entryNumber := n_reservationentry."Entry No." + 1;

        if tempItem.Get(TempPurchaseLine."No.") Then;

        ReservationEntry.RESET;
        ReservationEntry."Entry No." := entryNumber;
        LotNo := NoSeriesMgt.GetNextNo(tempItem."Lot Nos.", WorkDate(), true);
        ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot No.";
        ReservationEntry."Lot No." := LotNo;

        ReservationEntry."Location Code" := TempPurchaseLine."Location Code";
        ReservationEntry."Quantity (Base)" := TempPurchaseLine."Quantity (Base)";
        ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Surplus;
        ReservationEntry.Description := TempPurchaseLine.Description;
        ReservationEntry."Creation Date" := WORKDATE;
        ReservationEntry."Source Type" := 39;
        ReservationEntry."Source Subtype" := ReservationEntry."Source Subtype"::"1";
        ReservationEntry."Source ID" := TempPurchaseLine."Document No.";
        ReservationEntry."Source Ref. No." := TempPurchaseLine."Line No.";
        ReservationEntry."Created By" := USERID;
        ReservationEntry.Positive := true;
        ReservationEntry."Expected Receipt Date" := TempPurchaseLine."Expected Receipt Date";
        ReservationEntry."Item No." := TempPurchaseLine."No.";
        ReservationEntry."Qty. per Unit of Measure" := TempPurchaseLine."Qty. per Unit of Measure";
        ReservationEntry.Quantity := TempPurchaseLine.Quantity;
        //ReservationEntry."Quantity (Base)" := (ABS(TempTransferLine."Quantity (Base)")) * -1;
        ReservationEntry.Validate(ReservationEntry.Quantity);
        ReservationEntry."Qty. to Handle (Base)" := TempPurchaseLine."Qty. to Receive (Base)";
        ReservationEntry."Qty. to Invoice (Base)" := TempPurchaseLine."Qty. to Invoice (Base)";
        ReservationEntry.AutoLotDocumentNo := TempPurchaseLine."Document No.";

        TempPurchaseHeader.Reset();
        TempPurchaseHeader.SetRange("No.", TempPurchaseLine."Document No.");
        IF TempPurchaseHeader.FindFirst() then;

        IF Format(tempItem."Expiration Calculation") <> '' then begin
            expDate := CalcDate('<' + Format(tempItem."Expiration Calculation") + '>', TempPurchaseHeader."Posting Date");
            ReservationEntry."Expiration Date" := expDate;
        end;


        //  ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot No.";
        //  ReservationEntry."Lot No." := LotNo;


        //ReservationEntry."Qty. to Handle (Base)" := TempTransferLine."Qty. to Receive (Base)";
        //ReservationEntry."Qty. to Invoice (Base)" := TempTransferLine."Qty. to Receive (Base)";
        //TempTransferLine."Variant Code";
        //ReservationEntry."Variant Code" := TempTransferLine."Variant Code";

        ReservationEntry.INSERT;



    end;

    procedure PurchaseOrderReservationEntry(var TempPurchaseLine: Record "Purchase Line")

    var
        n_reservationentry: Record "Reservation Entry";
        ReservationEntry: Record "Reservation Entry";
        entryNumber: Integer;
        LotNo: Code[20];
        NoSeriesMgt: Codeunit NoSeriesManagement;
        tempItem: Record "Item";
    begin
        IF n_reservationentry.FINDLAST THEN
            entryNumber := n_reservationentry."Entry No." + 1;

        if tempItem.Get(TempPurchaseLine."No.") Then;

        ReservationEntry.RESET;
        ReservationEntry."Entry No." := entryNumber;
        LotNo := NoSeriesMgt.GetNextNo(tempItem."Lot Nos.", WorkDate(), true);
        ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot No.";
        ReservationEntry."Lot No." := LotNo;

        ReservationEntry."Location Code" := TempPurchaseLine."Location Code";
        ReservationEntry."Quantity (Base)" := TempPurchaseLine."Quantity (Base)";
        ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Surplus;
        ReservationEntry.Description := TempPurchaseLine.Description;
        ReservationEntry."Creation Date" := WORKDATE;
        ReservationEntry."Source Type" := 39;
        ReservationEntry."Source Subtype" := ReservationEntry."Source Subtype"::"1";
        ReservationEntry."Source ID" := TempPurchaseLine."Document No.";
        ReservationEntry."Source Ref. No." := TempPurchaseLine."Line No.";
        ReservationEntry."Created By" := USERID;
        ReservationEntry.Positive := true;
        ReservationEntry."Expected Receipt Date" := TempPurchaseLine."Expected Receipt Date";
        ReservationEntry."Item No." := TempPurchaseLine."No.";
        ReservationEntry."Qty. per Unit of Measure" := TempPurchaseLine."Qty. per Unit of Measure";
        ReservationEntry.Quantity := TempPurchaseLine.Quantity;
        //ReservationEntry."Quantity (Base)" := (ABS(TempTransferLine."Quantity (Base)")) * -1;
        ReservationEntry.Validate(ReservationEntry.Quantity);
        ReservationEntry."Qty. to Handle (Base)" := TempPurchaseLine."Qty. to Receive (Base)";
        ReservationEntry."Qty. to Invoice (Base)" := TempPurchaseLine."Qty. to Invoice (Base)";
        ReservationEntry.AutoLotDocumentNo := TempPurchaseLine."Document No.";

        //  ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot No.";
        //  ReservationEntry."Lot No." := LotNo;
        //ReservationEntry."Qty. to Handle (Base)" := TempTransferLine."Qty. to Receive (Base)";
        //ReservationEntry."Qty. to Invoice (Base)" := TempTransferLine."Qty. to Receive (Base)";
        //TempTransferLine."Variant Code";
        //ReservationEntry."Variant Code" := TempTransferLine."Variant Code";
        ReservationEntry.INSERT;



    end;


    ///LocalPurchsae End

    //Master Validation Start
    [EventSubscriber(ObjectType::Page, Page::"Item Card", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent(var Rec: Record Item; var AllowDelete: Boolean)
    begin
        Error('You cannot Delete Items');
    end;

    [EventSubscriber(ObjectType::Page, Page::"LSC Retail Item Card", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RetailOnDeleteRecordEvent(var Rec: Record Item; var AllowDelete: Boolean)
    begin
        Error('You cannot Delete Items');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Item Card", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent(var Rec: Record Item; var AllowInsert: Boolean)
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup.IsModifyItem then
            Error('You do not have permission to create new item');
    end;

    [EventSubscriber(ObjectType::Page, Page::"LSC Retail Item Card", 'OnInsertRecordEvent', '', true, true)]
    local procedure RetailItemInsertRecordEvent(var Rec: Record Item; var AllowInsert: Boolean)
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup.IsModifyItem then
            Error('You do not have permission to create new item');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Item Card", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent(var Rec: Record Item; var AllowModify: Boolean; var xRec: Record Item)
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup.IsModifyItem then
            Error('You do not have permission to modify exsting Item');
    end;



    [EventSubscriber(ObjectType::Page, Page::"LSC Retail Item Card", 'OnModifyRecordEvent', '', true, true)]
    local procedure retailOnModifyRecordEvent(var Rec: Record Item; var AllowModify: Boolean; var xRec: Record Item)
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup.IsModifyItem then
            Error('You do not have permission to modify exsting Item');
    end;

    //for unit of measure
    [EventSubscriber(ObjectType::Page, Page::"Units of Measure", 'OnDeleteRecordEvent', '', true, true)]
    local procedure UoMOnDeleteRecordEvent(var Rec: Record "Unit of Measure"; var AllowDelete: Boolean)
    begin
        Error('You cannot Delete Items');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Units of Measure", 'OnInsertRecordEvent', '', true, true)]
    local procedure UoMOnInsertRecordEvent(var Rec: Record "Unit of Measure"; var AllowInsert: Boolean)
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup.IsModifyItem then
            Error('You do not have permission to create new UoM');
    end;


    [EventSubscriber(ObjectType::Page, Page::"Units of Measure", 'OnModifyRecordEvent', '', true, true)]
    local procedure UoMOnModifyRecordEvent(var Rec: Record "Unit of Measure"; var AllowModify: Boolean)
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup.IsModifyItem then
            Error('You do not have permission to modify exsting UoM');
    end;

    //end



    [EventSubscriber(ObjectType::Page, Page::"Customer Card", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent1()
    begin
        Error('You cannot Delete customer');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Customer Card", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnInsertRecordEvent1()
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup.IsModifyCustomer then
            Error('You Do not have permission to create new Customer');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Customer Card", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent1()
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup.IsModifyCustomer then
            Error('You Do not have permission to modify exsiting customer');
    end;

    //customer retail


    [EventSubscriber(ObjectType::Page, Page::"LSC Retail Customer Card", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RetailOnDeleteRecordEvent1()
    begin
        Error('You cannot Delete customer');
    end;

    [EventSubscriber(ObjectType::Page, Page::"LSC Retail Customer Card", 'OnInsertRecordEvent', '', true, true)]
    local procedure RetailOnInsertRecordEvent1()
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup.IsModifyCustomer then
            Error('You Do not have permission to create new Customer');
    end;

    [EventSubscriber(ObjectType::Page, Page::"LSC Retail Customer Card", 'OnModifyRecordEvent', '', true, true)]
    local procedure retailOnModifyRecordEvent1()
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup.IsModifyCustomer then
            Error('You Do not have permission to modify exsiting customer');
    end;




    [EventSubscriber(ObjectType::Page, Page::"Vendor Card", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RunOnDeleteRecordEvent2()
    Begin

        Error('You Do not have permission to delete vendor');
    end;



    [EventSubscriber(ObjectType::Page, Page::"Vendor Card", 'OnInsertRecordEvent', '', true, true)]
    local procedure RunOnBeforeInsertEvent2()
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup.IsModifyVendor then
            Error('You do not have permission to create new vendor');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Vendor Card", 'OnModifyRecordEvent', '', true, true)]
    local procedure RunOnModifyRecordEvent2()
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup.IsModifyVendor then
            Error('You Do not have permission to modify new vendor');
    end;

    //retail Vendor


    [EventSubscriber(ObjectType::Page, Page::"LSC Retail Vendor Card", 'OnDeleteRecordEvent', '', true, true)]
    local procedure RetailOnDeleteRecordEvent2()
    Begin

        Error('You Do not have permission to delete vendor');
    end;



    [EventSubscriber(ObjectType::Page, Page::"LSC Retail Vendor Card", 'OnInsertRecordEvent', '', true, true)]
    local procedure RetailOnBeforeInsertEvent2()
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup.IsModifyVendor then
            Error('You do not have permission to create new vendor');
    end;

    [EventSubscriber(ObjectType::Page, Page::"LSC Retail Vendor Card", 'OnModifyRecordEvent', '', true, true)]
    local procedure RetailOnModifyRecordEvent2()
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup.IsModifyVendor then
            Error('You Do not have permission to modify new vendor');
    end;
    ///for production BOm
    [EventSubscriber(ObjectType::Page, Page::"Production BOM", 'OnModifyRecordEvent', '', true, true)]
    local procedure productionOnModifyRecordEvent2()
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup.IsModifyProductionBom then
            Error('You Do not have permission to modify Production BOM');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Production BOM", 'OnInsertRecordEvent', '', true, true)]
    local procedure productionOnInsertRecordEvent2()
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup.IsModifyProductionBom then
            Error('You Do not have permission to insert Production BOM');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Production BOM", 'OnDeleteRecordEvent', '', true, true)]
    local procedure productionOnDeleteRecordEvent2()
    var
        TempUserSetup: Record "User Setup";
    begin
        //If (TempUserSetup.get(UserId)) then;
        //if Not TempUserSetup.IsModifyProductionBom then
        Error('You Do not have permission to delete Production BOM');
    end;


    //Master Validation ENd

    ///
    // Production Order Start
    [EventSubscriber(ObjectType::Report, Report::"Calculate Subcontracts", 'OnBeforeReqWkshLineInsert', '', true, true)]
    local procedure OnBeforeReqWkshLineInsert(var RequisitionLine: Record "Requisition Line"; ProdOrderLine: Record "Prod. Order Line")
    var
        TempItem: Record Item;
    begin
        IF TempItem.Get(ProdOrderLine."Item No.") then;
        RequisitionLine."Gen. Prod. Posting Group" := TempItem."Gen. Prod. Posting Group";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Req. Wksh.-Make Order", 'OnAfterInitPurchOrderLine', '', true, true)]
    local procedure OnAfterInitPurchOrderLine(var PurchaseLine: Record "Purchase Line"; RequisitionLine: Record "Requisition Line")
    var
        TempItem: Record Item;
    begin
        IF TempItem.Get(PurchaseLine."No.") then;
        PurchaseLine."Gen. Prod. Posting Group" := TempItem."Gen. Prod. Posting Group";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Req. Wksh.-Make Order", 'OnInsertPurchOrderLineOnAfterTransferFromReqLineToPurchLine', '', true, true)]
    local procedure OnInsertPurchOrderLineOnAfterTransferFromReqLineToPurchLine(var PurchOrderLine: Record "Purchase Line"; RequisitionLine: Record "Requisition Line")
    var
        TempItem: Record Item;
    begin
        IF TempItem.Get(PurchOrderLine."No.") then;
        PurchOrderLine."Gen. Prod. Posting Group" := TempItem."Gen. Prod. Posting Group";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Production BOM Line", 'OnValidateNoOnAfterAssignItemFields', '', true, true)]
    local procedure RunOnValidateNoOnAfterAssignItemFields(var ProductionBOMLine: Record "Production BOM Line";
     Item: Record Item; var xProductionBOMLine: Record "Production BOM Line"; CallingFieldNo: Integer)
    begin
        ProductionBOMLine.ItemUnitCost := (Item."Unit Cost" * ProductionBOMLine."Quantity per");

    end;

    [EventSubscriber(ObjectType::Table, DataBase::"Production BOM Line", 'OnAfterValidateEvent', 'Quantity Per', true, true)]
    local procedure OnAfterValidateEvent(var Rec: Record "Production BOM Line"; var xRec: Record "Production BOM Line")
    var
        TempProductionOrder: Record "Production BOM Header";
        tempItem: Record Item;
        TempProductionBOM: Page "Production BOM";
        TempProdBOMLines: Page "Production BOM Lines";
    begin
        IF tempItem.Get(Rec."No.") then;
        Rec.ItemUnitCost := (tempItem."Unit Cost" * Rec."Quantity per");
        //  Message(Format(Rec.ItemUnitCost));
        TempProductionOrder.Reset();
        TempProductionOrder.SetRange("No.", Rec."Production BOM No.");
        if TempProductionOrder.FindFirst() then;
        TempProductionOrder.CalcFields(TotalBOMValue);
        TempProductionOrder.Validate(TotalBOMValue);

    end;

    [EventSubscriber(ObjectType::Page, Page::"Production BOM Lines", 'OnModifyRecordEvent', '', true, true)]
    local procedure PageOnAfterValidateEvent(var Rec: Record "Production BOM Line"; var xRec: Record "Production BOM Line"; var AllowModify: Boolean)
    var
    begin
    end;

    //update unit cost
    [EventSubscriber(ObjectType::Page, Page::"Change Status on Prod. Order", 'OnAfterSet', '', true, true)]
    local procedure OnAfterSet(ProdOrder: Record "Production Order"; sender: Page "Change Status on Prod. Order";

    var
        PostingDate: Date;

    var
        ReqUpdUnitCost: Boolean)
    var

    begin
        ReqUpdUnitCost := true;
    End;
    ///
    /// 
    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterValidateEvent', 'Quantity', true, true)]
    local procedure ProdJornalOnAfterValidateEvent(var Rec: Record "Item Journal Line"; CurrFieldNo: Integer; var xRec: Record "Item Journal Line")
    var
    begin
        if Rec."Entry Type" = Rec."Entry Type"::Consumption then begin
            IF xRec.Quantity <> 0 Then
                IF rec.Quantity <> xRec.Quantity then
                    Rec.ProdutionOrderQtyChanged := true;

        end;

    End;
    //Need to check later

    [EventSubscriber(ObjectType::Table, Database::"Production Order", 'OnAfterInitRecord', '', true, true)]
    local procedure ProductionOrderOnAfterInitRecord(var ProductionOrder: Record "Production Order")
    var
        tempusersetup: Record "User Setup";
    begin
        If tempusersetup.Get(UserId) then;
        if tempusersetup."Location Code" <> '' Then
            ProductionOrder."Location Code" := tempusersetup."Location Code";
    end;


    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnBeforePostingItemJnlFromProduction', '', true, true)]
    local procedure OnBeforePostingItemJnlFromProduction(var ItemJournalLine: Record "Item Journal Line";
    Print: Boolean; var IsHandled: Boolean)
    var
        tempusersetup: Record "User Setup";
        TempProdOrder: Record "Production Order";
    begin
        If tempusersetup.Get(UserId) then;

        if ItemJournalLine.FindSet() then
            repeat
                if ItemJournalLine."Location Code" <> tempusersetup."Location Code" then
                    Error('Prodction order location and user location must be match');

            until ItemJournalLine.Next() = 0;

    end;

    /// <summary>
    /// AutolotProductionJornalReservEntry.
    /// </summary>
    /// <param name="ProdJournalLine">VAR Record "Item Journal Line".</param>
    /// <param name="LotNo">VAR Code[20].</param>
    /// <param name="qty">VAR Decimal.</param>
    /// <param name="qty_base">VAR Decimal.</param>
    /// <param name="qtyshipbase">VAR Decimal.</param>
    /// <param name="qtyreceviedbase">VAR Decimal.</param>
    procedure AutolotProductionJornalReservEntry(var ProdJournalLine: Record "Item Journal Line";
var LotNo: Code[20]; var qty: Decimal; var qty_base: Decimal; var qtyshipbase: Decimal; var qtyreceviedbase: Decimal; var expdate1: Date)

    var
        n_reservationentry: Record "Reservation Entry";
        ReservationEntry: Record "Reservation Entry";
        entryNumber: Integer;
    begin
        IF n_reservationentry.FINDLAST THEN
            entryNumber := n_reservationentry."Entry No." + 1;

        ReservationEntry.RESET;
        ReservationEntry."Entry No." := entryNumber;
        ReservationEntry."Location Code" := ProdJournalLine."Location Code";
        ReservationEntry."Quantity (Base)" := (ABS(qty_base)) * -1;
        ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Prospect;
        ReservationEntry.Description := ProdJournalLine.Description;
        ReservationEntry."Creation Date" := WORKDATE;
        ReservationEntry."Source Type" := 83;
        ReservationEntry."Source Subtype" := ReservationEntry."Source Subtype"::"5";
        ReservationEntry."Source ID" := ProdJournalLine."Journal Template Name";
        ReservationEntry."Source Batch Name" := ProdJournalLine."Journal Batch Name";

        ReservationEntry."Source Ref. No." := ProdJournalLine."Line No.";
        ReservationEntry."Created By" := USERID;
        ReservationEntry.Positive := False;
        //ReservationEntry."Shipment Date" := ProdJournalLine.ate;
        ReservationEntry."Item No." := ProdJournalLine."Item No.";
        ReservationEntry."Qty. per Unit of Measure" := ProdJournalLine."Qty. per Unit of Measure";
        ReservationEntry.Quantity := (qty) * -1;
        //ReservationEntry."Quantity (Base)" := (ABS(TempTransferLine."Quantity (Base)")) * -1;
        ReservationEntry.Validate(ReservationEntry.Quantity);
        ReservationEntry."Qty. to Handle (Base)" := qtyshipbase * -1;
        ReservationEntry."Qty. to Invoice (Base)" := qtyreceviedbase * -1;

        ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot No.";
        ReservationEntry."Lot No." := LotNo;
        ReservationEntry.AutoLotDocumentNo := ProdJournalLine."Document No.";

        IF expdate1 <> 0D Then
            ReservationEntry."Expiration Date" := expdate1;


        //ReservationEntry."Qty. to Handle (Base)" := TempTransferLine."Qty. to Receive (Base)";
        //ReservationEntry."Qty. to Invoice (Base)" := TempTransferLine."Qty. to Receive (Base)";
        //TempTransferLine."Variant Code";
        //ReservationEntry."Variant Code" := TempTransferLine."Variant Code";

        ReservationEntry.INSERT;

    end;

    /// <summary>
    /// AutolotProductionJornalOutputReservEntry.
    /// </summary>
    /// <param name="ProdJournalLine">VAR Record "Item Journal Line".</param>
    /// <param name="LotNo">VAR Code[20].</param>
    /// <param name="qty">VAR Decimal.</param>
    /// <param name="qty_base">VAR Decimal.</param>
    /// <param name="qtyshipbase">VAR Decimal.</param>
    /// <param name="qtyreceviedbase">VAR Decimal.</param>
    procedure AutolotProductionJornalOutputReservEntry(var ProdJournalLine: Record "Item Journal Line")

    var
        n_reservationentry: Record "Reservation Entry";
        ReservationEntry: Record "Reservation Entry";
        entryNumber: Integer;
        LotNo: Code[20];
        NoSeriesMgt: Codeunit NoSeriesManagement;
        tempItem: Record "Item";
        expDate: Date;
    begin
        IF n_reservationentry.FINDLAST THEN
            entryNumber := n_reservationentry."Entry No." + 1;

        if tempItem.Get(ProdJournalLine."Item No.") Then;


        ReservationEntry.RESET;
        ReservationEntry."Entry No." := entryNumber;
        LotNo := NoSeriesMgt.GetNextNo(tempItem."Lot Nos.", WorkDate(), true);
        ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot No.";
        ReservationEntry."Lot No." := LotNo;

        ReservationEntry."Location Code" := ProdJournalLine."Location Code";
        ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Prospect;
        ReservationEntry.Description := ProdJournalLine.Description;
        ReservationEntry."Creation Date" := WORKDATE;
        ReservationEntry."Item No." := ProdJournalLine."No.";
        ReservationEntry."Qty. per Unit of Measure" := ProdJournalLine."Qty. per Unit of Measure";
        ReservationEntry."Quantity (Base)" := ProdJournalLine."Quantity (Base)";
        ReservationEntry.Quantity := ProdJournalLine.Quantity;
        //ReservationEntry."Quantity (Base)" := (ABS(TempTransferLine."Quantity (Base)")) * -1;
        ReservationEntry.Validate(ReservationEntry.Quantity);
        ReservationEntry."Qty. to Handle (Base)" := ProdJournalLine."Quantity (Base)";
        ReservationEntry."Qty. to Invoice (Base)" := ProdJournalLine."Quantity (Base)";

        ReservationEntry."Source Type" := 83;
        ReservationEntry."Source Subtype" := ReservationEntry."Source Subtype"::"6";
        ReservationEntry."Source ID" := ProdJournalLine."Journal Template Name";
        ReservationEntry."Source Batch Name" := ProdJournalLine."Journal Batch Name";
        ReservationEntry."Source Ref. No." := ProdJournalLine."Line No.";
        ReservationEntry."Created By" := USERID;
        ReservationEntry.Positive := true;
        ReservationEntry.AutoLotDocumentNo := ProdJournalLine."Document No.";


        IF Format(tempItem."Expiration Calculation") <> '' then begin
            expDate := CalcDate('<' + Format(tempItem."Expiration Calculation") + '>', ProdJournalLine."Posting Date");
            ReservationEntry."Expiration Date" := expDate;
        end;

        //ReservationEntry."Expected Receipt Date" := ProdJournalLine."Expected Receipt Date";


        ReservationEntry.INSERT;


    end;



    //Production Order end

    //Purchase Comment line Start
    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterInsertEvent', '', true, true)]
    local procedure PurchCommentOnAfterInsertEvent(var Rec: Record "Purchase Header")
    var
        TempPurchCommentLine: Record "Purch. Comment Line";
        TempPurchCommentHead: Record PurchCommentHeader;
        TempCommentLine: Record PurchCommentLine;
        lineNo: Integer;
    begin
        TempPurchCommentLine.Reset();
        TempPurchCommentLine.SetRange("Document Type", Rec."Document Type"::Order);
        TempPurchCommentLine.SetRange("No.", rec."No.");
        IF TempPurchCommentLine.FindSet() Then
            TempPurchCommentLine.DeleteAll();

        TempPurchCommentHead.Reset();
        TempPurchCommentHead.SetRange(TempPurchCommentHead.Mandatory, true);
        IF TempPurchCommentHead.FindFirst() then begin
            TempCommentLine.Reset();
            TempCommentLine.SetRange(TempCommentLine.CommentCode, TempPurchCommentHead.CommentCode);
            IF TempCommentLine.FindSet() then
                repeat
                    lineNo := lineNo + 100;
                    TempPurchCommentLine.Init();
                    TempPurchCommentLine."No." := Rec."No.";
                    TempPurchCommentLine."Document Type" := Rec."Document Type"::Order;
                    TempPurchCommentLine.PurchCommentLine := TempCommentLine.Comment;
                    TempPurchCommentLine."Line No." := TempCommentLine.LineNo + lineNo;
                    TempPurchCommentLine.Insert();
                until TempCommentLine.Next() = 0;
        end;



    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterInsertEvent', '', true, true)]
    local procedure RunOnAfterInsertEvent(var Rec: Record "Purchase Line")
    var
        TempItemCategory: Record "Item Category";
        TempPuchLine: Record "Purchase Line";
        TempCommentLine: Record "Purch. Comment Line";
        LineNo: Integer;
        TempCommentLine1: Record "Purch. Comment Line";
        TempPurchHeader: Record "Purchase Header";
    begin
        IF Rec."Item Category Code" <> '' then Begin
            IF Rec."Line No." > 0 then begin
                //Message(Rec."Item Category Code");


                TempCommentLine1.Reset();
                TempCommentLine1.SetRange(TempCommentLine1."Document Type", Rec."Document Type");
                TempCommentLine1.SetRange(TempCommentLine1."No.", Rec."Document No.");
                TempCommentLine1.SetRange(TempCommentLine1."Document Line No.", Rec."Line No.");
                IF Not TempCommentLine1.FindFirst() Then begin

                    TempPurchHeader.Reset();
                    TempPurchHeader.SetRange("No.", Rec."Document No.");
                    If TempPurchHeader.FindFirst() then;

                    //Message('%1|%2', TempPurchHeader."No.", Rec."Item Category Code");

                    TempCommentLine.Init();
                    TempCommentLine."No." := Rec."Document No.";
                    TempCommentLine."Document Type" := Rec."Document Type";
                    TempCommentLine."Document Line No." := Rec."Line No.";

                    TempCommentLine."Line No." := Rec."Line No." + 1;

                    TempItemCategory.Reset();
                    TempItemCategory.SetRange(TempItemCategory.Code, Rec."Item Category Code");
                    IF TempItemCategory.FindFirst() then;
                    TempCommentLine.Comment := TempItemCategory.Comment;

                    TempCommentLine.Date := TempPurchHeader."Posting Date";

                    TempCommentLine.Insert(true);



                end;
            end;
        end;
    END;

    //Purchase Comment Line end

    //Purchase Short Close Start
    procedure ShortClosePurchaseOrder(DocumentNo: Code[20])
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseHeader.reset;
        PurchaseHeader.Setfilter("Document Type", '%1', PurchaseHeader."Document Type"::Order);
        PurchaseHeader.SetRange("No.", DocumentNo);
        if PurchaseHeader.FindFirst() then begin
            PurchaseLine.reset;
            PurchaseLine.SetFilter("Document Type", '%1', PurchaseLine."Document Type"::Order);
            PurchaseLine.Setrange("Document No.", DocumentNo);
            if PurchaseLine.FindSet() then begin
                repeat
                    //if PurchaseLine."Quantity Received" <> PurchaseLine."Quantity Invoiced" then
                    //  error('Sales Invoice of Line No. %1 is pending', PurchaseLine."Line No."); //Aashish (Desable after Start New process GRN and invoice is seperate)
                    if PurchaseLine."Qty. to Receive" <> 0 then//PT-FBTS 240524
                        Error('Please Remove Qty.to Receive');//PT-FBTS 240524
                until PurchaseLine.Next = 0;
                PurchaseHeader.ShortClosed := True;
                PurchaseHeader.Modify;
            end;
        end;
    end;


    //Purrchase Short Close End

    //Stock Audit Start
    /// <summary>
    /// WastageEntryReservationEntry.
    /// </summary>
    /// <param name="stockAuditItemJnlLine">VAR Record "Item Journal Line".</param>
    /// <param name="stockAuditItemJnlLine">VAR Record "Item Journal Line".</param>
    /// <param name="LotNo">VAR Code[20].</param>
    /// <param name="qty">VAR Decimal.</param>
    /// <param name="qty_base">VAR Decimal.</param>
    /// <param name="qtyshipbase">VAR Decimal.</param>
    /// <param name="qtyreceviedbase">VAR Decimal.</param>
    procedure stockauditReservationEntry(var stockAuditItemJnlLine: Record "Item Journal Line";
            var LotNo: Code[20]; var qty: Decimal; var qty_base: Decimal; var qtyshipbase: Decimal; var qtyreceviedbase: Decimal; var expdate1: Date)

    var
        n_reservationentry: Record "Reservation Entry";
        ReservationEntry: Record "Reservation Entry";
        entryNumber: Integer;
    begin


        IF stockAuditItemJnlLine."Entry Type" = stockAuditItemJnlLine."Entry Type"::"Negative Adjmt." then begin
            IF n_reservationentry.FINDLAST THEN
                entryNumber := n_reservationentry."Entry No." + 1;


            ReservationEntry.RESET;
            ReservationEntry.Init();
            ReservationEntry."Entry No." := entryNumber;
            ReservationEntry."Item No." := stockAuditItemJnlLine."Item No.";
            ReservationEntry."Location Code" := stockAuditItemJnlLine."Location Code";
            ReservationEntry."Qty. per Unit of Measure" := stockAuditItemJnlLine."Qty. per Unit of Measure";
            ReservationEntry.Quantity := (qty) * -1;
            ReservationEntry.Validate(ReservationEntry.Quantity);
            ReservationEntry."Quantity (Base)" := (ABS(qty_base)) * -1;
            ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Prospect;
            ReservationEntry.Description := stockAuditItemJnlLine.Description;
            ReservationEntry."Creation Date" := WORKDATE;
            ReservationEntry."Source Type" := 83;
            ReservationEntry."Source Subtype" := ReservationEntry."Source Subtype"::"3";
            ReservationEntry."Source ID" := stockAuditItemJnlLine."Journal Template Name";
            ReservationEntry."Source Batch Name" := stockAuditItemJnlLine."Journal Batch Name";
            ReservationEntry."Source Ref. No." := stockAuditItemJnlLine."Line No.";
            ReservationEntry."Created By" := USERID;
            ReservationEntry.Positive := False;
            ReservationEntry."Shipment Date" := stockAuditItemJnlLine."Posting Date";

            ReservationEntry."Qty. to Handle (Base)" := qtyshipbase * -1;
            ReservationEntry."Qty. to Invoice (Base)" := qtyreceviedbase * -1;

            ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot No.";
            ReservationEntry."Lot No." := LotNo;

            IF expdate1 <> 0D Then
                ReservationEntry."Expiration Date" := expdate1;

            //ReservationEntry."Qty. to Handle (Base)" := TempTransferLine."Qty. to Receive (Base)";
            //ReservationEntry."Qty. to Invoice (Base)" := TempTransferLine."Qty. to Receive (Base)";
            //TempTransferLine."Variant Code";
            //ReservationEntry."Variant Code" := TempTransferLine."Variant Code";

            ReservationEntry.INSERT;

        end;



    end;

    procedure StockAuditPostiveAdjreservationEntry(var stockAuditItemJnlLine: Record "Item Journal Line")
    var
        n_reservationentry: Record "Reservation Entry";
        ReservationEntry: Record "Reservation Entry";
        entryNumber: Integer;
        LotNo: Code[20];
        NoSeriesMgt: Codeunit NoSeriesManagement;
        tempItem: Record "Item";
        TempStockAuditHead: Record StockAuditHeader;
        expDate: Date;
    begin
        IF n_reservationentry.FINDLAST THEN
            entryNumber := n_reservationentry."Entry No." + 1;

        if tempItem.Get(stockAuditItemJnlLine."Item No.") Then;

        ReservationEntry.RESET;
        ReservationEntry."Entry No." := entryNumber;
        LotNo := NoSeriesMgt.GetNextNo(tempItem."Lot Nos.", WorkDate(), true);
        ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot No.";
        ReservationEntry."Lot No." := LotNo;

        ReservationEntry."Location Code" := stockAuditItemJnlLine."Location Code";
        // ReservationEntry."Item No." := stockAuditItemJnlLine."No."; //AJ_ALLE_23012024 Commnented as per Wrn assigned
        ReservationEntry."Item No." := stockAuditItemJnlLine."Item No."; //AJ_ALLE_23012024
        ReservationEntry."Qty. per Unit of Measure" := stockAuditItemJnlLine."Qty. per Unit of Measure";
        ReservationEntry.Quantity := stockAuditItemJnlLine.Quantity;
        ReservationEntry."Quantity (Base)" := stockAuditItemJnlLine."Quantity (Base)";
        //ReservationEntry."Quantity (Base)" := (ABS(TempTransferLine."Quantity (Base)")) * -1;
        ReservationEntry.Validate(ReservationEntry.Quantity);

        ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Prospect;
        ReservationEntry.Description := stockAuditItemJnlLine.Description;
        ReservationEntry."Creation Date" := WORKDATE;
        ReservationEntry."Source Type" := 83;
        ReservationEntry."Source Subtype" := ReservationEntry."Source Subtype"::"2";

        ReservationEntry."Source ID" := stockAuditItemJnlLine."Journal Template Name";
        ReservationEntry."Source Batch Name" := stockAuditItemJnlLine."Journal Batch Name";
        ReservationEntry."Source Ref. No." := stockAuditItemJnlLine."Line No.";

        ReservationEntry."Created By" := USERID;
        ReservationEntry.Positive := true;
        ReservationEntry."Qty. to Handle (Base)" := stockAuditItemJnlLine."Quantity (Base)";
        ReservationEntry."Qty. to Invoice (Base)" := stockAuditItemJnlLine."Quantity (Base)";

        TempStockAuditHead.Reset();
        TempStockAuditHead.SetRange("No.", stockAuditItemJnlLine."Document No.");
        IF TempStockAuditHead.FindFirst() Then;
        IF Format(tempItem."Expiration Calculation") <> '' then begin
            expDate := CalcDate('<' + Format(tempItem."Expiration Calculation") + '>', TempStockAuditHead."Posting Date");
            ReservationEntry."Expiration Date" := expDate;
        end;

        ReservationEntry.INSERT;

    end;

    //stock Audit end


    //Wastage Entry Start
    /// <summary>
    /// WastageEntryReservationEntry.
    /// </summary>
    /// <param name="WastageItemJnlLine">VAR Record "Item Journal Line".</param>
    /// <param name="LotNo">VAR Code[20].</param>
    /// <param name="qty">VAR Decimal.</param>
    /// <param name="qty_base">VAR Decimal.</param>
    /// <param name="qtyshipbase">VAR Decimal.</param>
    /// <param name="qtyreceviedbase">VAR Decimal.</param>
    procedure WastageEntryReservationEntry(var WastageItemJnlLine: Record "Item Journal Line";
        var LotNo: Code[20]; var qty: Decimal; var qty_base: Decimal; var qtyshipbase: Decimal; var qtyreceviedbase: Decimal; var expdate1: Date)

    var
        n_reservationentry: Record "Reservation Entry";
        ReservationEntry: Record "Reservation Entry";
        entryNumber: Integer;
    begin
        IF n_reservationentry.FINDLAST THEN
            entryNumber := n_reservationentry."Entry No." + 1;


        ReservationEntry.RESET;
        ReservationEntry."Entry No." := entryNumber;
        ReservationEntry."Item No." := WastageItemJnlLine."Item No.";
        ReservationEntry."Location Code" := WastageItemJnlLine."Location Code";
        ReservationEntry."Qty. per Unit of Measure" := WastageItemJnlLine."Qty. per Unit of Measure";
        ReservationEntry.Quantity := (qty) * -1;
        ReservationEntry.Validate(ReservationEntry.Quantity);
        ReservationEntry."Quantity (Base)" := (ABS(qty_base)) * -1;
        ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Prospect;
        ReservationEntry.Description := WastageItemJnlLine.Description;
        ReservationEntry."Creation Date" := WORKDATE;
        ReservationEntry."Source Type" := 83;
        ReservationEntry."Source Subtype" := ReservationEntry."Source Subtype"::"3";
        ReservationEntry."Source ID" := WastageItemJnlLine."Journal Template Name";
        ReservationEntry."Source Batch Name" := WastageItemJnlLine."Journal Batch Name";
        ReservationEntry."Source Ref. No." := WastageItemJnlLine."Line No.";
        ReservationEntry."Created By" := USERID;
        ReservationEntry.Positive := False;
        ReservationEntry."Shipment Date" := WastageItemJnlLine."Posting Date";

        ReservationEntry."Qty. to Handle (Base)" := qtyshipbase * -1;
        ReservationEntry."Qty. to Invoice (Base)" := qtyreceviedbase * -1;

        ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot No.";
        ReservationEntry."Lot No." := LotNo;

        IF expdate1 <> 0D Then
            ReservationEntry."Expiration Date" := expdate1;

        //ReservationEntry."Qty. to Handle (Base)" := TempTransferLine."Qty. to Receive (Base)";
        //ReservationEntry."Qty. to Invoice (Base)" := TempTransferLine."Qty. to Receive (Base)";
        //TempTransferLine."Variant Code";
        //ReservationEntry."Variant Code" := TempTransferLine."Variant Code";

        ReservationEntry.INSERT;
        Commit();


    end;

    procedure WastageEntryManualCreationReservationEntry(var WastageItemJnlLine: Record "Item Journal Line";
        var LotNo: Code[20]; var qty: Decimal; var qty_base: Decimal; var qtyshipbase: Decimal; var qtyreceviedbase: Decimal)

    var
        n_reservationentry: Record "Reservation Entry";
        ReservationEntry: Record "Reservation Entry";
        entryNumber: Integer;
    begin
        IF n_reservationentry.FINDLAST THEN
            entryNumber := n_reservationentry."Entry No." + 1;


        ReservationEntry.RESET;
        ReservationEntry."Entry No." := entryNumber;
        ReservationEntry."Item No." := WastageItemJnlLine."Item No.";
        ReservationEntry."Location Code" := WastageItemJnlLine."Location Code";
        ReservationEntry."Qty. per Unit of Measure" := WastageItemJnlLine."Qty. per Unit of Measure";
        ReservationEntry.Quantity := (qty) * -1;
        ReservationEntry.Validate(ReservationEntry.Quantity);
        ReservationEntry."Quantity (Base)" := (ABS(qty_base)) * -1;
        ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Prospect;
        ReservationEntry.Description := WastageItemJnlLine.Description;
        ReservationEntry."Creation Date" := WORKDATE;
        ReservationEntry."Source Type" := 83;
        ReservationEntry."Source Subtype" := ReservationEntry."Source Subtype"::"3";
        ReservationEntry."Source ID" := WastageItemJnlLine."Journal Template Name";
        ReservationEntry."Source Batch Name" := WastageItemJnlLine."Journal Batch Name";
        ReservationEntry."Source Ref. No." := WastageItemJnlLine."Line No.";
        ReservationEntry."Created By" := USERID;
        ReservationEntry.Positive := False;
        ReservationEntry."Shipment Date" := WastageItemJnlLine."Posting Date";

        ReservationEntry."Qty. to Handle (Base)" := qtyshipbase * -1;
        ReservationEntry."Qty. to Invoice (Base)" := qtyreceviedbase * -1;

        ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot No.";
        ReservationEntry."Lot No." := LotNo;

        //ReservationEntry."Qty. to Handle (Base)" := TempTransferLine."Qty. to Receive (Base)";
        //ReservationEntry."Qty. to Invoice (Base)" := TempTransferLine."Qty. to Receive (Base)";
        //TempTransferLine."Variant Code";
        //ReservationEntry."Variant Code" := TempTransferLine."Variant Code";

        ReservationEntry.INSERT;
        Commit();


    end;


    //Wastage Entry End

    ///For Vender Invoice Number On posted purchase receipt
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePurchRcptHeaderInsert', '', true, true)]
    local procedure RunOnBeforePurchRcptHeaderInsert(var PurchaseHeader: Record "Purchase Header"; var PurchRcptHeader: Record "Purch. Rcpt. Header"; WarehouseReceiptHeader: Record "Warehouse Receipt Header"; WarehouseShipmentHeader: Record "Warehouse Shipment Header";
    CommitIsSupressed: Boolean; WhseReceive: Boolean; WhseShip: Boolean)
    begin
        PurchRcptHeader.VendorInvoiceNo := PurchaseHeader."Vendor Invoice No.";
    end;
    //end

    ///added to avoid duplicate line 

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'No.', true, true)]
    local procedure DuplicateOnAfterValidateEvent(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        TempPurchOrderLine: Record "Purchase Line";
        ItemRec: Record Item;
    begin
        IF Rec."Document Type" = Rec."Document Type"::Order then begin
            IF Rec.Type = Rec.Type::Item then begin
                IF Rec."No." <> '' then Begin
                    if ItemRec.Get(Rec."No.") then begin
                        if ItemRec.Type <> ItemRec.Type::Service then begin
                            TempPurchOrderLine.Reset();
                            TempPurchOrderLine.SetRange("No.", Rec."No.");
                            TempPurchOrderLine.SetRange("Document No.", Rec."Document No.");

                            IF TempPurchOrderLine.FindFirst() then
                                Error('You can not enter same article twice in purchase order');
                        end;
                    end;
                End;
            end;
        end;

        //  TempPurchOrderLine.SetRange(Rec.Type,"Document Type"::);
    end;
    //end

    /// to flow fields from transfer Header to transfer shipment
    /// 
    [EventSubscriber(ObjectType::Table, Database::"Transfer Shipment Header", 'OnAfterCopyFromTransferHeader', '', true, true)]
    local procedure RunOnAfterCopyFromTransferHeader(var TransferShipmentHeader: Record "Transfer Shipment Header"; TransferHeader: Record "Transfer Header")

    begin
        TransferShipmentHeader.TransferOrderReferenceNo := TransferHeader.TransferOrderReferenceNo;
        TransferShipmentHeader."Requistion No." := TransferHeader."Requistion No.";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Receipt Header", 'OnAfterCopyFromTransferHeader', '', true, true)]
    local procedure RunReceiptOnAfterCopyFromTransferHeader(TransferHeader: Record "Transfer Header"; var TransferReceiptHeader: Record "Transfer Receipt Header")

    begin
        TransferReceiptHeader.TransferOrderReferenceNo := TransferHeader.TransferOrderReferenceNo;
        TransferReceiptHeader."Requistion No." := TransferHeader."Requistion No.";
    end;

    //statement line remark validation
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Statement-Post", 'OnBeforeStatementPost', '', true, true)]
    local procedure RunOnBeforeStatementPost(var Statement: Record "LSC Statement"; var IsHandled: Boolean)
    var
        TempLSCPostedstatementLine: Record "LSC Statement Line";
    begin

        TempLSCPostedstatementLine.Reset();
        TempLSCPostedstatementLine.SetRange("Statement No.", Statement."No.");
        IF TempLSCPostedstatementLine.FindSet() Then
            repeat
                IF TempLSCPostedstatementLine."Difference Amount" <> 0 Then Begin
                    IF TempLSCPostedstatementLine.Remarks = '' then
                        error('You must enter a remarks if difference amount is not equal to 0 ');
                End;
            until TempLSCPostedstatementLine.Next() = 0;


    end;

    //aded to fixed Transfer receipt issue
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnBeforePostItemJournalLine', '', true, true)]
    local procedure RunOnBeforePostItemJournalLine(var ItemJournalLine: Record "Item Journal Line"; TransLine: Record "Transfer Line"; TransferReceiptLine: Record "Transfer Receipt Line"; TransferReceiptHeader: Record "Transfer Receipt Header"; TransferLine: Record "Transfer Line"; PostedWhseRcptHeader: Record "Posted Whse. Receipt Header"; CommitIsSuppressed: Boolean)
    var
        TempItemJournalIntrsist: Record "Item Journal Buffer";
        //Dimension
        DefaultDim: Record "Default Dimension";
        GLSetup: Record "General Ledger Setup";
    begin
        // IF (((ItemJournalLine."Location Code" = 'INTRANSIT') and (ItemJournalLine."Order Type" = ItemJournalLine."Order Type"::Transfer))//AsPerREQ12102023
        IF (((ItemJournalLine."Location Code" = 'INTRANSIT1') and (ItemJournalLine."Order Type" = ItemJournalLine."Order Type"::Transfer))
          or ((ItemJournalLine."Direct Transfer" = true) and (ItemJournalLine."Order Type" = ItemJournalLine."Order Type"::Transfer))) then begin
            IF ItemJournalLine."New Location Code" <> '' then begin
                //Dimension
                GLSetup.Get();
                DefaultDim.Reset();
                DefaultDim.SetRange("Table ID", 14);
                DefaultDim.SetRange("No.", ItemJournalLine."New Location Code");
                DefaultDim.SetRange("Dimension Code", GLSetup."Global Dimension 1 Code");
                if DefaultDim.FindFirst() then begin
                    ItemJournalLine."Shortcut Dimension 1 Code" := DefaultDim."Dimension Value Code";

                    ItemJournalLine.Validate(ItemJournalLine."Shortcut Dimension 1 Code");
                    ItemJournalLine."New Shortcut Dimension 1 Code" := DefaultDim."Dimension Value Code";
                    ItemJournalLine.Validate(ItemJournalLine."New Shortcut Dimension 1 Code");
                end;

                GLSetup.Get();
                DefaultDim.Reset();
                DefaultDim.SetRange("Table ID", 14);
                DefaultDim.SetRange("No.", ItemJournalLine."New Location Code");
                DefaultDim.SetRange("Dimension Code", GLSetup."Global Dimension 2 Code");
                if DefaultDim.FindFirst() then begin

                    ItemJournalLine."Shortcut Dimension 2 Code" := DefaultDim."Dimension Value Code";
                    ItemJournalLine.Validate(ItemJournalLine."Shortcut Dimension 2 Code");

                    ItemJournalLine."New Shortcut Dimension 2 Code" := DefaultDim."Dimension Value Code";
                    ItemJournalLine.Validate(ItemJournalLine."New Shortcut Dimension 2 Code");
                end;                //end
                //dimesion values
                GLSetup.Get();
                DefaultDim.Reset();
                DefaultDim.SetRange("Table ID", 14);
                DefaultDim.SetRange("No.", ItemJournalLine."New Location Code");
                DefaultDim.SetRange("Dimension Code", GLSetup."Shortcut Dimension 3 Code");
                if DefaultDim.FindFirst() then begin
                    ItemJournalLine.ValidateShortcutDimCode(3, DefaultDim."Dimension Value Code");
                    ItemJournalLine.ValidateNewShortcutDimCode(3, DefaultDim."Dimension Value Code");
                end;                //end




            end;
        end;

    end;


    //End
    //aded for dimesion code validatite
    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Location Code', true, true)]
    local procedure PurchLocationOnAfterValidateEvent(var Rec: Record "Purchase Header"; var xRec: Record "Purchase Header"; CurrFieldNo: Integer)
    var
        //Dimension
        DefaultDim: Record "Default Dimension";
        GLSetup: Record "General Ledger Setup";

    begin
        IF Rec."Location Code" <> '' Then Begin
            //Dimension
            GLSetup.Get();
            DefaultDim.Reset();
            DefaultDim.SetRange("Table ID", 14);
            DefaultDim.SetRange("No.", Rec."Location Code");
            DefaultDim.SetRange("Dimension Code", GLSetup."Global Dimension 1 Code");
            if DefaultDim.FindFirst() then begin
                Rec."Shortcut Dimension 1 Code" := DefaultDim."Dimension Value Code";
                Rec.Validate(Rec."Shortcut Dimension 1 Code");
            end;

            GLSetup.Get();
            DefaultDim.Reset();
            DefaultDim.SetRange("Table ID", 14);
            DefaultDim.SetRange("No.", Rec."Location Code");
            DefaultDim.SetRange("Dimension Code", GLSetup."Global Dimension 2 Code");
            if DefaultDim.FindFirst() then begin
                Rec."Shortcut Dimension 2 Code" := DefaultDim."Dimension Value Code";
                Rec.Validate(Rec."Shortcut Dimension 2 Code");
            end;

            GLSetup.Get();
            DefaultDim.Reset();
            DefaultDim.SetRange("Table ID", 14);
            DefaultDim.SetRange("No.", Rec."Location Code");
            DefaultDim.SetRange("Dimension Code", GLSetup."Shortcut Dimension 3 Code");
            if DefaultDim.FindFirst() then begin
                Rec.ValidateShortcutDimCode(3, DefaultDim."Dimension Value Code");
            end;
            //end



        End;
    end;
    //
    ///Transfer Dimesion valiadte
    [EventSubscriber(ObjectType::Table, Database::"Transfer Header", 'OnAfterInsertEvent', '', true, true)]
    local procedure TransLocationOnAfterValidateEvent(var Rec: Record "Transfer Header")
    var
        //Dimension
        DefaultDim: Record "Default Dimension";
        GLSetup: Record "General Ledger Setup";

    begin
        IF Rec."Transfer-from Code" <> '' Then Begin
            //Dimension
            GLSetup.Get();
            DefaultDim.Reset();
            DefaultDim.SetRange("Table ID", 14);
            DefaultDim.SetRange("No.", Rec."Transfer-from Code");
            DefaultDim.SetRange("Dimension Code", GLSetup."Global Dimension 1 Code");
            if DefaultDim.FindFirst() then begin
                Rec."Shortcut Dimension 1 Code" := DefaultDim."Dimension Value Code";
                Rec.Validate(Rec."Shortcut Dimension 1 Code");
            end;

            GLSetup.Get();
            DefaultDim.Reset();
            DefaultDim.SetRange("Table ID", 14);
            DefaultDim.SetRange("No.", Rec."Transfer-from Code");
            DefaultDim.SetRange("Dimension Code", GLSetup."Global Dimension 2 Code");
            if DefaultDim.FindFirst() then begin
                Rec."Shortcut Dimension 2 Code" := DefaultDim."Dimension Value Code";
                Rec.Validate(Rec."Shortcut Dimension 2 Code");
            end;

            GLSetup.Get();
            DefaultDim.Reset();
            DefaultDim.SetRange("Table ID", 14);
            DefaultDim.SetRange("No.", Rec."Transfer-from Code");
            DefaultDim.SetRange("Dimension Code", GLSetup."Shortcut Dimension 3 Code");
            if DefaultDim.FindFirst() then begin
                Rec.ValidateShortcutDimCode(3, DefaultDim."Dimension Value Code");
            end;
            //end



        End;
    end;
    //
    //item journal line dimesion valiadte.
    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterValidateEvent', 'Location Code', true, true)]
    local procedure ItemJnlLocationOnAfterValidateEvent(var Rec: Record "Item Journal Line"; var xRec: Record "Item Journal Line"; CurrFieldNo: Integer)
    var
        //Dimension
        DefaultDim: Record "Default Dimension";
        GLSetup: Record "General Ledger Setup";

    begin
        IF Rec."Location Code" <> '' Then Begin
            //Dimension
            GLSetup.Get();
            DefaultDim.Reset();
            DefaultDim.SetRange("Table ID", 14);
            DefaultDim.SetRange("No.", Rec."Location Code");
            DefaultDim.SetRange("Dimension Code", GLSetup."Global Dimension 1 Code");
            if DefaultDim.FindFirst() then begin
                Rec."Shortcut Dimension 1 Code" := DefaultDim."Dimension Value Code";
                Rec.Validate(Rec."Shortcut Dimension 1 Code");
            end;

            GLSetup.Get();
            DefaultDim.Reset();
            DefaultDim.SetRange("Table ID", 14);
            DefaultDim.SetRange("No.", Rec."Location Code");
            DefaultDim.SetRange("Dimension Code", GLSetup."Global Dimension 2 Code");
            if DefaultDim.FindFirst() then begin
                Rec."Shortcut Dimension 2 Code" := DefaultDim."Dimension Value Code";
                Rec.Validate(Rec."Shortcut Dimension 2 Code");
            end;

            GLSetup.Get();
            DefaultDim.Reset();
            DefaultDim.SetRange("Table ID", 14);
            DefaultDim.SetRange("No.", Rec."Location Code");
            DefaultDim.SetRange("Dimension Code", GLSetup."Shortcut Dimension 3 Code");
            if DefaultDim.FindFirst() then begin
                Rec.ValidateShortcutDimCode(3, DefaultDim."Dimension Value Code");
            end;
            //end



        End;
    end;
    //
    //Purchase Return Order Ref ivoice no skip
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reference Invoice No. Mgt.", 'onBeforeCheckRefInvNoPurchaseHeader', '', true, true)]
    local procedure RunonBeforeCheckRefInvNoPurchaseHeader(var PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean)
    var
    begin
        IF PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::"Return Order" Then
            IF PurchaseHeader.ship = True Then
                IsHandled := true;
    end;

    //end
    ///transfeer order gst posting issue
    [EventSubscriber(ObjectType::Table, DATABASE::"Transfer Line", 'OnAfterValidateEvent', 'Item No.', false, false)]
    local procedure OutTransvalidateItemNo(var Rec: Record "Transfer Line")
    var
        Item: Record Item;
        TempLocation: Record Location;
        tempState: record State;
        TempLocation1: Record Location;
        tempState1: record State;
    begin
        if not Item.Get(Rec."Item No.") then
            exit;

        if TempLocation.get(Rec."Transfer-from Code") then;
        if tempState.Get(TempLocation."State Code") then;

        if TempLocation1.get(Rec."Transfer-to Code") then;
        if tempState1.Get(TempLocation1."State Code") then;

        IF tempState.Code = tempState1.code Then Begin

            Rec."GST Credit" := Item."GST Credit"::Availment;
            Rec."GST Group Code" := Item."GST Group Code";
            Rec."HSN/SAC Code" := Item."HSN/SAC Code";
            Rec.Exempted := Item.Exempted;
            Rec.Validate("Transfer Price");
        end;
    end;

    //End

    ///offlinesales process auto lot assignment start 
    procedure OfflineSalesReservationEntry(var stockAuditItemJnlLine: Record "Item Journal Line";
               var LotNo: Code[20]; var qty: Decimal; var qty_base: Decimal; var qtyshipbase: Decimal; var qtyreceviedbase: Decimal; var expdate1: Date)

    var
        n_reservationentry: Record "Reservation Entry";
        ReservationEntry: Record "Reservation Entry";
        entryNumber: Integer;
    begin


        IF stockAuditItemJnlLine."Entry Type" = stockAuditItemJnlLine."Entry Type"::Sale then begin
            IF n_reservationentry.FINDLAST THEN
                entryNumber := n_reservationentry."Entry No." + 1;


            ReservationEntry.RESET;
            ReservationEntry.Init();
            ReservationEntry."Entry No." := entryNumber;
            ReservationEntry."Item No." := stockAuditItemJnlLine."Item No.";
            ReservationEntry."Location Code" := stockAuditItemJnlLine."Location Code";
            ReservationEntry."Qty. per Unit of Measure" := stockAuditItemJnlLine."Qty. per Unit of Measure";
            ReservationEntry.Quantity := (qty) * -1;
            ReservationEntry.Validate(ReservationEntry.Quantity);
            ReservationEntry."Quantity (Base)" := (ABS(qty_base)) * -1;
            ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Prospect;
            ReservationEntry.Description := stockAuditItemJnlLine.Description;
            ReservationEntry."Creation Date" := WORKDATE;
            ReservationEntry."Source Type" := 83;
            ReservationEntry."Source Subtype" := ReservationEntry."Source Subtype"::"1";
            ReservationEntry."Source ID" := stockAuditItemJnlLine."Journal Template Name";
            ReservationEntry."Source Batch Name" := stockAuditItemJnlLine."Journal Batch Name";
            ReservationEntry."Source Ref. No." := stockAuditItemJnlLine."Line No.";
            ReservationEntry."Created By" := USERID;
            ReservationEntry.Positive := False;
            ReservationEntry."Shipment Date" := stockAuditItemJnlLine."Posting Date";

            ReservationEntry."Qty. to Handle (Base)" := qtyshipbase * -1;
            ReservationEntry."Qty. to Invoice (Base)" := qtyreceviedbase * -1;

            ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot No.";
            ReservationEntry."Lot No." := LotNo;

            IF expdate1 <> 0D Then
                ReservationEntry."Expiration Date" := expdate1;

            ReservationEntry.INSERT;
        end;

    end;

    //aded code to restict user from deletetion of no. series
    [EventSubscriber(ObjectType::Table, Database::Location, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure locationOndelete()
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup.AllowLocationDelete then
            Error('You do not have permission to delete location card');
    end;

    [EventSubscriber(ObjectType::Table, Database::"No. Series", 'OnBeforeDeleteEvent', '', true, true)]
    local procedure NoSeriesOndelete()
    var
        TempUserSetup: Record "User Setup";
    begin
        If (TempUserSetup.get(UserId)) then;
        if Not TempUserSetup.AllowNoseriesDelete then
            Error('You do not have permission to delete No.series');
    end;

    //for deleteing reservation entry
    procedure DeleteReserverationLine(var ItemJnlLine: Record "Item Journal Line")
    var
        ReservMgt: Codeunit "Reservation Management";
    begin

        with ItemJnlLine do begin
            ReservMgt.SetReservSource(ItemJnlLine);
            //auto delete
            ReservMgt.SetItemTrackingHandling(1); // Allow Deletion
            ReservMgt.DeleteReservEntries(true, 0);
            CalcFields("Reserved Qty. (Base)");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Queue Error Handler", 'OnAfterLogError', '', false, false)]
    local procedure OnAfterLogError(var JobQueueEntry: Record "Job Queue Entry")
    var
        JsonO: JsonObject;
        payload: Text;
        ResponseText: Text;
        RetailSetup: Record "LSC Retail Setup";
        StartDateTxt: text;
        EndDateTxt: text;
        StartDate: DateTime;
        EndDate: DateTime;
        Recstatus: text;
        ObjectType: Text;
        lenstart: Integer;
        lenEnd: Integer;

        JobQueueLogEntry: Record "Job Queue Log Entry";
        Body: Text;
        EmailItem: Record "Email Item" temporary;
    begin
        // Clear(Recstatus);
        // Clear(ObjectType);

        if (JobQueueEntry."Object ID to Run" = 50135) then begin
            //     JobQueueLogEntry.SetRange(ID, JobQueueEntry.ID);
            //     JobQueueLogEntry.SetRange("User Session ID", JobQueueEntry."User Session ID");
            //     JobQueueLogEntry.setfilter(status, '%1', JobQueueLogEntry.Status::Error);
            //     if JobQueueLogEntry.FindFirst() then
            //         RetailSetup.Get();
            //     JobQueueLogEntry."Store Code" := RetailSetup."Local Store No.";
            //     JsonO.Add('EntryNo', JobQueueLogEntry."Entry No.");
            //     JsonO.Add('StoreCode', JobQueueLogEntry."Store Code");
            //     JsonO.Add('UserId', JobQueueEntry."User ID");
            //     StartDateTxt := FORMAT(JobQueueLogEntry."Start Date/Time", 30, '<Year4>-<Month,2>-<Day,2> <Hours24,2>:<Minutes,2>:<Seconds,2>');
            //     StartDateTxt := StartDateTxt.Replace('T', ' ');
            //     lenstart := StrLen(StartDateTxt);
            //     if lenstart = 19 then begin
            //         lenstart := lenstart - 3;
            //         StartDateTxt := CopyStr(StartDateTxt, 16, lenstart);
            //     end;
            //     // StartDateTxt := Format(JobQueueEntry."Start Date/Time").Replace('/', '-');
            //     JsonO.Add('StartDateTime', StartDateTxt);
            //     EndDateTxt := FORMAT(JobQueueLogEntry."End Date/Time", 30, '<Year4>-<Month,2>-<Day,2> <Hours24,2>:<Minutes,2>:<Seconds,2>');
            //     EndDateTxt := EndDateTxt.Replace('T', ' ');
            //     lenEnd := StrLen(EndDateTxt);

            //     if lenEnd = 19 then begin
            //         lenEnd := lenEnd - 3;
            //         EndDateTxt := CopyStr(EndDateTxt, 16, lenEnd);
            //     end;
            //     JsonO.Add('EndDateTime', EndDateTxt);
            //     if JobQueueEntry."Object Type to Run" = 3 then
            //         ObjectType := 'Report';
            //     if JobQueueEntry."Object Type to Run" = 5 then
            //         ObjectType := 'Codeunit';
            //     JsonO.Add('ObjectType', ObjectType);
            //     JsonO.Add('ObjectId', JobQueueEntry."Object ID to Run");
            //     if JobQueueEntry.Status = 0 then
            //         Recstatus := 'Success';
            //     if JobQueueEntry.Status = 1 then
            //         Recstatus := 'In Process';
            //     if JobQueueEntry.Status = 2 then
            //         Recstatus := 'Error';
            //     JsonO.Add('status', Recstatus);
            //     JsonO.Add('Description', JobQueueEntry.Description);
            //     JsonO.Add('ErrorMessage', JobQueueEntry."Error Message");
            //     JsonO.Add('Duration', JobQueueLogEntry.Duration());
            //     JsonO.Add('UserSessionId', JobQueueEntry."User Session ID");
            //     JsonO.WriteTo(payload);
            //Message(payload);

            Body := 'Allow Posting Date Job has been Failed.' + 'Dear User Please Run It Manually ,<br><br>Error : <b>'
            + JobQueueEntry."Error Message" + '<br><br>Thanks & Regards';
            EmailItem."Send to" := 'parminder@thirdwavecoffee.in';
            EmailItem."Send CC" := 'sanjay.prakash@fbts.in';
            EmailItem.Subject := 'Allow Posting Date Job Error';
            EmailItem.Validate("Plaintext Formatted", false);
            EmailItem.SetBodyText(Body);
            EmailItem.Send(true, Enum::"Email Scenario"::Default);
            // TwcApiSetupUrl.Get();
            // TwcApiSetupUrl.Modify();
            // ResponseText := MakeRequestForJobQueueStatus('https://bce-apimanagement.azure-api.net/api/v1/posjobdetails', payload);//ADD URL


        end;                                                                                                                      // JobQueueLogEntry.Modify();
    end;
    //Alle-AS-13112023-commented
    [EventSubscriber(ObjectType::Table, Database::"Job Queue Entry", 'OnBeforeModifyLogEntry', '', false, false)]

    local procedure OnBeforeModifyLogEntry(var JobQueueLogEntry: Record "Job Queue Log Entry"; var JobQueueEntry: Record "Job Queue Entry")
    var
        JsonO: JsonObject;
        payload: Text;
        ResponseText: Text;
        RetailSetup: Record "LSC Retail Setup";
        StartDateTxt: text;
        EndDateTxt: text;
        StartDate: DateTime;
        EndDate: DateTime;
        Recstatus: text;
        ObjectType: Text;
        lenstart: Integer;
        lenEnd: Integer;

        Body: Text;
        EmailItem: Record "Email Item" temporary;
    begin
        if (JobQueueEntry."Object ID to Run" = 50135) then begin//795
            Body := 'Allow Posting Date Job has been Successfully completed.' +
                                             '<br><br>Thanks & Regards';
            EmailItem."Send to" := 'parminder@thirdwavecoffee.in';
            EmailItem."Send CC" := 'sanjay.prakash@fbts.in';
            // EmailItem."Send CC" := 'akswar@alletec.com;akaul@alletec.com';
            EmailItem.Subject := 'Allow Posting Date Job Successfully completed';
            EmailItem.Validate("Plaintext Formatted", false);
            EmailItem.SetBodyText(Body);
            EmailItem.Send(true, Enum::"Email Scenario"::Default);
            // JobQueueLogEntry.Modify();
        end;
    end;

    //TempComment_05012023
    //ALLE_Nick_261223
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post (Yes/No)", 'OnCodeOnBeforePostTransferOrder', '', false, false)]
    local procedure OnCodeOnBeforePostTransferOrder(var DefaultNumber: Integer; var IsHandled: Boolean; var TransHeader: Record "Transfer Header"; var Selection: Option " ",Shipment,Receipt)
    var
        InvtSetup: Record "Inventory Setup";
        TransLine: Record "Transfer Line";
        TransferPostShipment: Codeunit "TransferOrder-Post Shipment";
        TransferPostReceipt: Codeunit "TransferOrder-Post Receipt1";
        TransferOrderPostTransfer: Codeunit "TransferOrder-Post Transfer";
        Text000: Label '&Ship,&Receive';
    begin
        IsHandled := true;
        if TransHeader."Direct Transfer" then
            case InvtSetup."Direct Transfer Posting" of
                InvtSetup."Direct Transfer Posting"::"Receipt and Shipment":
                    begin
                        TransferPostShipment.Run(TransHeader);
                        TransferPostReceipt.Run(TransHeader);
                    end;
                InvtSetup."Direct Transfer Posting"::"Direct Transfer":
                    TransferOrderPostTransfer.Run(TransHeader);
            end
        else begin
            if DefaultNumber = 0 then
                DefaultNumber := 1;
            Selection := StrMenu(Text000, DefaultNumber);
            case Selection of
                0:
                    exit;
                Selection::Shipment:
                    TransferPostShipment.Run(TransHeader);
                Selection::Receipt:
                    TransferPostReceipt.Run(TransHeader);
            end;
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnBeforeInsertTransShptLine', '', false, false)]
    local procedure OnBeforeInsertTransShptLine(TransLine: Record "Transfer Line"; var TransShptLine: Record "Transfer Shipment Line")
    begin
        TransShptLine.FixedAssetNo := TransLine.FixedAssetNo;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt1", 'OnBeforeInsertTransRcptLine', '', false, false)]
    local procedure OnBeforeInsertTransRcptLine(TransLine: Record "Transfer Line"; var TransRcptLine: Record "Transfer Receipt Line")
    begin
        TransRcptLine.FixedAssetNo := TransLine.FixedAssetNo;
    end;
    //ALLE_NICK_190124_START
    [EventSubscriber(ObjectType::Page, Page::"No. Series", 'OnModifyRecordEvent', '', false, false)]
    local procedure OnModifyRecordNoSeries()
    var
        Usersetup: Record "User Setup";
    begin
        if Usersetup.Get(UserId) then
            if Usersetup."Allow Master Modification" = false then begin
                // CurrPage.Editable(false);
                Error('You are not authorized');
                //CurrPage.Close();
            end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"No. Series", 'OnInsertRecordEvent', '', false, false)]
    local procedure OnNewRecordNoSeries()
    var
        Usersetup: Record "User Setup";
    begin
        if Usersetup.Get(UserId) then
            if Usersetup."Allow Master Modification" = false then begin
                // CurrPage.Editable(false);
                Error('You are not authorized');
                //CurrPage.Close();
            end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"No. Series Lines", 'OnModifyRecordEvent', '', false, false)]
    local procedure OnModifyRecordNoSeriesLine()
    var
        Usersetup: Record "User Setup";
    begin
        if Usersetup.Get(UserId) then
            if Usersetup."Allow Master Modification" = false then begin
                // CurrPage.Editable(false);
                Error('You are not authorized');
                //CurrPage.Close();
            end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"No. Series Lines", 'OnInsertRecordEvent', '', false, false)]
    local procedure OnNewRecordNoSeriesLine()
    var
        Usersetup: Record "User Setup";
    begin
        if Usersetup.Get(UserId) then
            if Usersetup."Allow Master Modification" = false then begin
                // CurrPage.Editable(false);
                Error('You are not authorized');
                //CurrPage.Close();
            end;
    end;
    //ALLE-AS-21012024
    [EventSubscriber(ObjectType::Page, Page::"No. Series", 'OnDeleteRecordEvent', '', false, false)]
    local procedure OnDeleteRecordNoSeries()
    var
        Usersetup: Record "User Setup";
    begin
        if Usersetup.Get(UserId) then
            if Usersetup."Allow Master Modification" = false then begin
                // CurrPage.Editable(false);
                Error('You are not authorized');
                //CurrPage.Close();
            end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"No. Series Lines", 'OnDeleteRecordEvent', '', false, false)]
    local procedure OnDeleteRecordNoSeriesLine()
    var
        Usersetup: Record "User Setup";
    begin
        if Usersetup.Get(UserId) then
            if Usersetup."Allow Master Modification" = false then begin
                // CurrPage.Editable(false);
                Error('You are not authorized');
                //CurrPage.Close();
            end;
    end;
    //ALLE-AS-21012024
    //ALLE_NICK_190124_END

    //ALLE_NICK_120124
    //TodayFixedasset

    [EventSubscriber(ObjectType::Page, Page::"Fixed Asset List", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEvent(var Rec: Record "Fixed Asset")
    var
        tempUserSetup: Record "User Setup";
    begin
        IF tempUserSetup.Get(UserId) Then;
        IF tempUserSetup."Location Code" <> '' then begin
            Rec.FilterGroup(2);
            Rec.SetRange("Location Code", TempUsersetup."Location Code");
            Rec.FilterGroup(0);
        end;

    end;

    //AJ_ALLE_30012024
    [EventSubscriber(ObjectType::Page, Page::"Purchase Order", 'OnAfterActionEvent', 'Release', false, false)]
    local procedure OnAfterActionEventRelease(var Rec: Record "Purchase Header")
    begin
        if Rec."Pay-to Vendor No." <> Rec."Buy-from Vendor No." then Error('Cant proceed as "Pay to vendor no" & "Buy from Vendor No" Are not same');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Order", 'OnAfterActionEvent', 'Post', false, false)]
    local procedure OnAfterActionEventPostPur(var Rec: Record "Purchase Header")
    begin
        if Rec."Pay-to Vendor No." <> Rec."Buy-from Vendor No." then Error('Cant proceed as "Pay to vendor no" & "Buy from Vendor No" Are not same');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Order", 'OnAfterActionEvent', 'Post and &Print', false, false)]
    local procedure OnAfterActionEventPostPRIn(var Rec: Record "Purchase Header")
    begin
        if Rec."Pay-to Vendor No." <> Rec."Buy-from Vendor No." then Error('Cant proceed as "Pay to vendor no" & "Buy from Vendor No" Are not same');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Order List", 'OnAfterActionEvent', 'Post', false, false)]
    local procedure OnAfterActionEventPost(var Rec: Record "Purchase Header")
    begin
        if Rec."Pay-to Vendor No." <> Rec."Buy-from Vendor No." then Error('Cant proceed as "Pay to vendor no" & "Buy from Vendor No" Are not same');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Order List", 'OnAfterActionEvent', 'PostAndPrint', false, false)]
    local procedure OnAfterActionEventPostPrint(var Rec: Record "Purchase Header")
    begin
        if Rec."Pay-to Vendor No." <> Rec."Buy-from Vendor No." then Error('Cant proceed as "Pay to vendor no" & "Buy from Vendor No" Are not same');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Order List", 'OnAfterActionEvent', 'Release', false, false)]
    local procedure OnAfterActionEventrel(var Rec: Record "Purchase Header")
    begin
        if Rec."Pay-to Vendor No." <> Rec."Buy-from Vendor No." then Error('Cant proceed as "Pay to vendor no" & "Buy from Vendor No" Are not same');
    end;

    //AJ_ALLE_30012024
    //ALLE_NICK_STATEMENTPOSTING_120124
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Batch Posting", 'OnBeforePrePostChecks', '', false, false)]
    local procedure OnBeforePrePostChecks(var SkipPrePostingChecks: Boolean)
    begin
        SkipPrePostingChecks := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Queue Error Handler", 'OnAfterLogError', '', false, false)]
    procedure OnAfterLogError_(var JobQueueEntry: Record "Job Queue Entry")
    var
        JobQueueLogEntry: Record "Job Queue Log Entry";
        Body: Text;
        EmailItem: Record "Email Item" temporary;
        BatchPostingQueue: record 99001577;
        Store: text;
        test: Page 674;
        statmentNo: Text;
        UniqueValues: List of [Text];
        UniqueValues2: List of [Text];
        value: Text;
        value2: Text;
        countno: Integer;
        i: Integer;
        Storetable: text;
        Statmenttable: text;
        StoreRec: Record "LSC Store";
        StoreRec2: Record "LSC Store";
        Storelistfornotcalu: text;
        StorelistfornotcaluTab: text;
        UniqueValues3: List of [Text];
        value3: Text;
        InventorySetup: Record "Inventory Setup";
    begin
        if (JobQueueEntry."Object ID to Run" = 50147) then begin

            BatchPostingQueue.SetFilter("Queue Date", '%1', Today);
            BatchPostingQueue.SetFilter(Status, '%1|%2', BatchPostingQueue.Status::Waiting, BatchPostingQueue.Status::Running);
            // BatchPostingQueue.SetAscending("Store No.", true);
            if BatchPostingQueue.FindSet() then
                repeat
                    if StoreRec.get(BatchPostingQueue."Store No.") then
                        StoreRec."Statment No" := BatchPostingQueue."Document No.";
                    StoreRec."Statment caluclated" := true;
                    StoreRec.Modify();
                    if Store = '' then begin
                        Store := BatchPostingQueue."Store No.";
                        statmentNo := BatchPostingQueue."Document No.";
                    end
                    else begin
                        Store := Store + ',' + BatchPostingQueue."Store No.";
                        statmentNo := statmentNo + ',' + BatchPostingQueue."Document No."
                    end;
                until BatchPostingQueue.Next() = 0;
            StoreRec2.SetFilter("Statment caluclated", '%1', false);
            StoreRec2.SetFilter("Only Accept Statement", '%1', true);
            if StoreRec2.FindSet() then begin
                repeat
                    if Storelistfornotcalu = '' then
                        Storelistfornotcalu := StoreRec2."No."
                    else
                        Storelistfornotcalu := Storelistfornotcalu + ',' + StoreRec2."No.";
                until StoreRec2.Next() = 0;
            end;
            EmailItem."Send to" := 'parminder@thirdwavecoffee.in';
            EmailItem."Send CC" := 'sanjay.prakash@fbts.in';

            EmailItem."Send CC" := '';//'akswar@alletec.com;rkyadav@alletec.com;rakumar@alletec.com'
            EmailItem.Subject := 'Sales posting error statments';
            EmailItem.Validate("Plaintext Formatted", false);
            UniqueValues2 := SplitUniqueValues(Store);
            foreach value2 in UniqueValues2 do begin
                Storetable += '<table border="1" cellpadding="3" style="border-style: solid; border-width: 1px">' + '<tr>' +
                                       '<td widht="20"><font face="arial" size ="2">' + value2 + '</font></td>' +
                                       '</tr>' + '</table>';
            end;
            UniqueValues := SplitUniqueValues(statmentNo);

            foreach value in UniqueValues do begin
                Statmenttable += '<table border="1" cellpadding="3" style="border-style: solid; border-width: 1px">' + '<tr>' +
                                       '<td widht="20"><font face="arial" size ="2">' + value + '</font></td>' +
                                       '</tr>' + '</table>';
            end;
            UniqueValues3 := SplitUniqueValues(Storelistfornotcalu);
            Message(UniqueValues3.Get(1));
            StoreRec.Reset();
            if StoreRec.Get(UniqueValues3.Get(1)) then begin
                StoreRec."Only Accept Statement" := false;
                StoreRec."Statment error" := JobQueueEntry."Error Message";
                StoreRec.Modify();
            end;
            foreach value3 in UniqueValues3 do begin
                StorelistfornotcaluTab += '<table border="1" cellpadding="3" style="border-style: solid; border-width: 1px">' + '<tr>' +
                                       '<td widht="20"><font face="arial" size ="2">' + value3 + '</font></td>' +
                                       '</tr>' + '</table>';
            end;

            Body := '<font face="arial" size ="2">' +
                                '<b><font face="arial" size="2" color="#1E90FF">  Kind Attention : ' + '</font></b>' + '<br>' +
                               '<br>' + 'Dear Team,' + '</br>' + '<br>' + '<b><font face="arial" size="2" color="#1E90FF">  Error :' + JobQueueEntry."Error Message" + '</font></b>' + '</br>' +
                                '<br>' + 'Please find list of the stores for which Statements are calculated sucessfully -' + '<br>' + '</br>' +
                               // '</br>' + '<br></font>' + '<b>' + Store + '</br>' + '</b>' + '<br>' +
                               '<table border="1" cellpadding="3" style="border-style: solid; border-width: 1px">' +
                                              '<tr>' +
                                               '<td><b><font face="arial" size ="2">Store No</font></b></td>' +
                                              '<td><b><font face="arial" size ="2">Statment No</font></b></td>' +
                    '<tr>' +
                           '<td widht="20"><font face="arial" size ="2">' + Storetable + '</font></td>' +
                           '<td widht="20"><font face="arial" size ="2">' + Statmenttable + '</font></td>' +
                           '</tr>' + '</table>' + '<br>' +
                             '<br>' + 'This is list of the stores for which Statements are not calculated -' + '<br>' + '</br>' +
                               // '</br>' + '<br></font>' + '<b>' + Store + '</br>' + '</b>' + '<br>' +
                               '<table border="1" cellpadding="3" style="border-style: solid; border-width: 1px">' +
                                              '<tr>' +
                                               '<td><b><font face="arial" size ="2">Store No</font></b></td>' +
                    '<tr>' +
                           '<td widht="20"><font face="arial" size ="2">' + StorelistfornotcaluTab + '</font></td>' +
                           '</tr>' + '</table>' + '<br>' +
                                '<b><font face="arial" size="2" color="#1E90FF">' + 'Please restart job queue or you can run manually for rest of the stores' + '</font></b>' +
                               '</br>' + '<br>' + '<b>' + 'Thanks,' + '</b>' +
                                '<b>' + 'Heisetasse Beverages Private Limited Bangalore, India' + '</b>' + '<br>' +
                                '<b>' + 'www.thirdwavecoffeeroasters.com' + '</b>' + '</br>' +
                               '<br>' +
                               '<b><b>' + '<br>' + '*This is a system generated mail from Microsoft Dynamics Business Central' + '</b></b>' + '</br>' + '</br>' + '<br>' + '</br>';

            EmailItem.SetBodyText(Format(Body));

            EmailItem.Send(true, Enum::"Email Scenario"::Default);
            //  Message('Email has been sent.');
            JobQueueEntry.Status := JobQueueEntry.Status::Ready;
            JobQueueEntry.Modify();
        end;
    end;

    local procedure SplitUniqueValues(DelimitedText: Text): List of [Text]
    var
        UniqueValues: List of [Text];
        Values: List of [Text];
        Delimiters: Text;
        value: Text;
    begin
        Delimiters := ',';
        Values := DelimitedText.Split(Delimiters.Split(' '));
        foreach value in Values do
            // if not UniqueValues.Contains(value) then
            UniqueValues.Add(value);
        exit(UniqueValues);
    end;
    //ALLE_NICK_220224 
    [EventSubscriber(ObjectType::Page, Page::"Transfer Orders", 'OnOpenPageEvent', '', false, false)]
    local procedure OnOpenPageEventTransferOrder(var Rec: Record "Transfer Header")
    var
        Usersetup: Record "User Setup";
    begin
        if Usersetup.Get(UserId) then
            if Usersetup."Allow Master Modification" = false then begin
                // CurrPage.Editable(false);
                Error('You are not authorized');

            end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Queue Entry", 'OnBeforeModifyLogEntry', '', false, false)]

    procedure OnBeforeModifyLogEntrycaluclatestatment(var JobQueueLogEntry: Record "Job Queue Log Entry"; var JobQueueEntry: Record "Job Queue Entry")
    var

        Body: Text;
        EmailItem: Record "Email Item" temporary;
        BatchPostingQueue: record 99001577;
        Store: text;
        test: Page 674;
        statmentNo: Text;
        UniqueValues: List of [Text];
        UniqueValues2: List of [Text];
        value: Text;
        value2: Text;
        countno: Integer;
        i: Integer;
        Storetable: text;
        Statmenttable: text;
        StoreRec: Record "LSC Store";
        StoreRec2: Record "LSC Store";
        Storelistfornotcalu: text;
        StorelistfornotcaluTab: text;
        UniqueValues3: List of [Text];
        value3: Text;
        UniqueValues4: List of [Text];
        value4: Text;
        statmenterrors: text;
        statmenterrorstab: text;
        NoofCount: Integer;
        StoreRec3: Record "LSC Store";

    begin
        if (JobQueueEntry."Object ID to Run" = 50147) then begin
            BatchPostingQueue.SetFilter("Queue Date", '%1', Today);
            BatchPostingQueue.SetFilter(Status, '%1|%2', BatchPostingQueue.Status::Waiting, BatchPostingQueue.Status::Running);
            // BatchPostingQueue.SetAscending("Store No.", true);
            if BatchPostingQueue.FindSet() then
                repeat
                    if StoreRec.get(BatchPostingQueue."Store No.") then
                        StoreRec."Statment No" := BatchPostingQueue."Document No.";
                    StoreRec."Statment caluclated" := true;
                    StoreRec.Modify();
                    if Store = '' then begin
                        Store := BatchPostingQueue."Store No.";
                        statmentNo := BatchPostingQueue."Document No.";
                    end
                    else begin
                        Store := Store + ',' + BatchPostingQueue."Store No.";
                        statmentNo := statmentNo + ',' + BatchPostingQueue."Document No."
                    end;
                until BatchPostingQueue.Next() = 0;
            //StoreRec2.SetFilter("Statment caluclated", '%1', false);
            // StoreRec2.SetFilter("Only Accept Statement", '%1', true);
            StoreRec2.SetFilter("Statment error", '<>%1', '');
            if StoreRec2.FindSet() then begin
                MakeExcelDataHeader();
                repeat
                    ExcelBuf.NewRow();
                    ExcelBuf.AddColumn(StoreRec2."No.", false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
                    ExcelBuf.AddColumn(StoreRec2."Statment error", false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
                // if Storelistfornotcalu = '' then begin
                //     Storelistfornotcalu := StoreRec2."No.";
                //     statmenterrors := StoreRec2."Statment error";
                // end

                // else begin
                //     Storelistfornotcalu := Storelistfornotcalu + ',' + StoreRec2."No.";
                //     statmenterrors := statmenterrors + ',' + StoreRec2."Statment error";
                // end;
                until StoreRec2.Next() = 0;
                FileName := 'Store Errors' + '.xlsx';
                ExcelBuf.CreateNewBook('Stores Errors');
                ExcelBuf.WriteSheet('Stores Errors', '', '');
                ExcelBuf.SetFriendlyFilename('Stores Errors');
                ExcelBuf.CloseBook();
                TempBlob.CreateOutStream(OutS);
                ExcelBuf.SaveToStream(OutS, true);
                TempBlob.CreateInStream(InS);
                // DownloadFromStream(InS, '', '', '', FileName);
            end;
            StoreRec3.SetFilter("Statment caluclated", '%1', true);
            if StoreRec3.FindSet() then begin
                NoofCount := StoreRec3.Count;
            end;
            EmailItem."Send to" := 'parminder@thirdwavecoffee.in';
            EmailItem."Send CC" := 'sanjay.prakash@fbts.in';
            // EmailItem."Send to" := 'nchauhan@alletec.com';
            // EmailItem."Send CC" := 'akswar@alletec.com;rkyadav@alletec.com;rakumar@alletec.com';//'akswar@alletec.com;rkyadav@alletec.com;rakumar@alletec.com'
            EmailItem.Subject := 'Sales posting error statments';
            EmailItem.Validate("Plaintext Formatted", false);
            UniqueValues2 := SplitUniqueValues(Store);
            foreach value2 in UniqueValues2 do begin
                Storetable += '<table border="1" cellpadding="3" style="border-style: solid; border-width: 1px">' + '<tr>' +
                                       '<td widht="20"><font face="arial" size ="2">' + value2 + '</font></td>' +
                                       '</tr>' + '</table>';
            end;
            UniqueValues := SplitUniqueValues(statmentNo);

            foreach value in UniqueValues do begin
                Statmenttable += '<table border="1" cellpadding="3" style="border-style: solid; border-width: 1px">' + '<tr>' +
                                       '<td widht="20"><font face="arial" size ="2">' + value + '</font></td>' +
                                       '</tr>' + '</table>';
            end;
            // UniqueValues3 := SplitUniqueValues(Storelistfornotcalu);
            // foreach value3 in UniqueValues3 do begin
            //     StorelistfornotcaluTab += '<table border="1" cellpadding="3" style="border-style: solid; border-width: 1px">' + '<tr>' +
            //                            '<td widht="20"><font face="arial" size ="2">' + value3 + '</font></td>' +
            //                            '</tr>' + '</table>';

            // end;
            // UniqueValues4 := SplitUniqueValues(statmenterrors);
            // foreach value4 in UniqueValues4 do begin
            //     statmenterrorstab += '<table border="1" cellpadding="3" style="border-style: solid; border-width: 1px">' + '<tr>' +
            //                            '<td widht="20"><font face="arial" size ="2">' + value4 + '</font></td>' +
            //                            '</tr>' + '</table>';
            // end;

            Body := '<font face="arial" size ="2">' +
                                '<b><font face="arial" size="2" color="#1E90FF">  Kind Attention : ' + '</font></b>' + '<br>' +
                               '<br>' + 'Dear Team,' + '</br>' +
                                 '<b><br>' + 'No of count for which statment is calculated -' + Format(NoofCount) + '</b></br>' +
                                '<br>' + 'Please find list of the stores for which Statements are calculated sucessfully -' + '<br>' + '</br>' +
                               // '</br>' + '<br></font>' + '<b>' + Store + '</br>' + '</b>' + '<br>' +
                               '<table border="1" cellpadding="3" style="border-style: solid; border-width: 1px">' +
                                              '<tr>' +
                                               '<td><b><font face="arial" size ="2">Store No</font></b></td>' +
                                              '<td><b><font face="arial" size ="2">Statment No</font></b></td>' +
                    '<tr>' +
                           '<td widht="20"><font face="arial" size ="2">' + Storetable + '</font></td>' +
                           '<td widht="20"><font face="arial" size ="2">' + Statmenttable + '</font></td>' +
                           '</tr>' + '</table>' + '<br>' +

                             '<br>' + 'Find the attached excel of the stores for which Statements are not calculated' + '<br>' + '</br>' +
                                // '</br>' + '<br></font>' + '<b>' + Store + '</br>' + '</b>' + '<br>' +

                                '<b><font face="arial" size="2" color="#1E90FF">' + 'Please restart job queue or you can run manually for rest of the stores' + '</font></b>' +
                               '</br>' + '<br>' + '<b>' + 'Thanks,' + '</b>' +
                                '<b>' + 'Heisetasse Beverages Private Limited Bangalore, India' + '</b>' + '<br>' +
                                '<b>' + 'www.thirdwavecoffeeroasters.com' + '</b>' + '</br>' +
                               '<br>' +
                               '<b><b>' + '<br>' + '*This is a system generated mail from Microsoft Dynamics Business Central' + '</b></b>' + '</br>' + '</br>' + '<br>' + '</br>';

            EmailItem.SetBodyText(Format(Body));
            EmailItem.AddAttachment(InS, FileName);
            EmailItem.Send(true, Enum::"Email Scenario"::Default);

        end;
    end;



    local procedure MakeExcelDataHeader()
    begin
        ExcelBuf.AddColumn('Store No', false, '', false, false, true, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Error', false, '', false, false, true, '', ExcelBuf."Cell Type"::Text);
    end;

    //ALLE_NICK_220224
    // [EventSubscriber(ObjectType::Table, Database::"LSC POS Cash Declaration", 'OnAfterValidateEvent', 'Amount', false, false)]
    // local procedure OnAfterValidateEventcashdec(var Rec: Record "LSC POS Cash Declaration")
    // var
    //     Paymententry: Record "LSC Trans. Payment Entry";
    //     SumofAmount: Decimal;
    // begin
    //     Paymententry.SetFilter("Safe type", '%1', Paymententry."Safe type"::"Fixed Float");
    //     Paymententry.SetFilter(Date, '%1', Today);
    //     Paymententry.SetFilter("Staff ID", rec."Staff ID");
    //     Paymententry.SetFilter("Store No.", rec."Store No.");
    //     Paymententry.SetFilter("Amount Tendered", '<%1', 0);
    //     if Paymententry.Findset() then
    //         repeat
    //             SumofAmount += Paymententry."Amount Tendered";
    //         until Paymententry.Next() = 0;
    //     if SumofAmount <> rec.Amount then
    //         Error('Please Enter Same amount as float. Float amount is %1', Format(SumofAmount));
    // end;

    //ALLE_NICK_FORLOTAFTERSHIPMENT 250224
    procedure "Assign Lot NO"(transferline: Record "Transfer Line"; SourceProdOrderLine: Integer; SourceRefNo: Integer)
    var
        myInt: Integer;
        Item: Record Item;
    begin
        if Item.get(transferline."Item No.") then
            if Item."Item Tracking Code" <> '' then begin
                Clear(Reservationqty);
                QtyToAllocate := transferline."Quantity (Base)";
                itemledentry.Reset();
                itemledentry.SetFilter("Remaining Quantity", '<>%1', 0);
                itemledentry.SetRange("Order No.", transferline."Document No.");
                ItemLedEntry.SetRange("Item No.", transferline."Item No.");
                itemledentry.SetRange("Location Code", transferline."Transfer-from Code");
                if itemledentry.FindSet() then begin
                    repeat
                        if QtyToAllocate = 0 then
                            exit;
                        Clear(QtyToAllocate2);
                        Clear(QtyToReservation);
                        Clear(lotno);
                        lotno := itemledentry."Lot No.";
                        ReservationEntry.Reset();
                        ReservationEntry.SetRange(ReservationEntry."Item No.", transferline."Item No.");
                        ReservationEntry.SetRange(ReservationEntry."Location Code", transferline."Transfer-from Code");
                        ReservationEntry.SetRange(ReservationEntry."Lot No.", Lotno);
                        ReservationEntry.SetRange("ILE No.", itemledentry."Entry No.");
                        ReservationEntry.SetFilter(Quantity, '<%1', 0);
                        ReservationEntry.CalcSums("Quantity (Base)");
                        Reservationqty := abs(ReservationEntry."Quantity (Base)");

                        if itemledentry."Remaining Quantity" > Reservationqty then begin

                            IF QtyToAllocate >= itemledentry."Remaining Quantity" - Reservationqty then
                                QtyToReservation := itemledentry."Remaining Quantity" - Reservationqty
                            else
                                QtyToReservation := QtyToAllocate;
                            QtyToAllocate := QtyToAllocate - QtyToReservation;

                            ReservationEntry2.RESET;
                            ReservationEntry2.SetFilter("Lot No.", '<>%1', '');
                            ReservationEntry2.SETRANGE("Source ID", TransferLine."Document No.");
                            ReservationEntry2.SETRANGE("Source Ref. No.", TransferLine."Line No.");
                            ReservationEntry2.SETRANGE("Item No.", TransferLine."Item No.");
                            ReservationEntry2.CalcSums("Quantity (Base)");
                            TotalremQtyILE2 := ReservationEntry2."Quantity (Base)";
                            if transferline."Quantity (Base)" = TotalremQtyILE2 then
                                exit;

                            Clear(Entry);
                            ReservationEntry.Reset();
                            if ReservationEntry.FindLast() then
                                Entry := ReservationEntry."Entry No." + 1
                            else
                                Entry := 1;
                            ReservationEntry.INIT;
                            ReservationEntry."Entry No." := Entry + 2;
                            ReservationEntry.Positive := TRUE;
                            ReservationEntry."Item No." := TransferLine."Item No.";
                            ReservationEntry."Location Code" := transferline."Transfer-to Code";
                            ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Surplus;
                            ReservationEntry."Creation Date" := transferline."Shipment Date";
                            ReservationEntry."Source Type" := 5741;
                            ReservationEntry."Source Subtype" := 1;
                            ReservationEntry."Source ID" := TransferLine."Document No.";
                            ReservationEntry."Source Ref. No." := SourceProdOrderLine;
                            ReservationEntry."Source Prod. Order Line" := SourceRefNo;
                            ReservationEntry."Expected Receipt Date" := transferline."Shipment Date";
                            ReservationEntry."Created By" := USERID;
                            ReservationEntry."Qty. per Unit of Measure" := TransferLine."Qty. per Unit of Measure";
                            ReservationEntry.Validate(Quantity, (ReservationEntry.Quantity + QtyToReservation));
                            ReservationEntry."Quantity (Base)" := (ReservationEntry."Quantity (Base)" + QtyToReservation);
                            ReservationEntry."Qty. to Handle (Base)" := (ReservationEntry."Qty. to Handle (Base)" + QtyToReservation);
                            ReservationEntry."Qty. to Invoice (Base)" := (ReservationEntry."Qty. to Invoice (Base)" + QtyToReservation);
                            ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot No.";
                            ReservationEntry.Validate("Lot No.", lotno);
                            //ReservationEntry."ILE No." := itemledentry."Entry No.";
                            ReservationEntry.INSERT(TRUE);
                        end;
                    until itemledentry.Next() = 0;
                end
            end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeValidateDocumentDateWithPostingDate', '', false, false)] //PT-FBTS 
    local procedure "Purchase Header_OnBeforeValidateDocumentDateWithPostingDate"
   (
       var PurchaseHeader: Record "Purchase Header";
       CallingFieldNo: Integer;
       var IsHandled: Boolean;
       xPurchaseHeader: Record "Purchase Header"
   )
    begin
        if (PurchaseHeader."Posting Date" <> xPurchaseHeader."Posting Date") and (PurchaseHeader."Posting Date" <> 0D) then
            IsHandled := true;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInitVendLedgEntry', '', true, true)]
    local procedure "Gen. Jnl.-Post Line_OnAfterInitVendLedgEntry"
    (
        var VendorLedgerEntry: Record "Vendor Ledger Entry";
        GenJournalLine: Record "Gen. Journal Line";
        var GLRegister: Record "G/L Register"
    )
    begin
        VendorLedgerEntry."PO No." := GenJournalLine."PO No.";
    end;
    //PT-FBTS- 23-10-24

    //Ashish-FBTS-11.25.2024-NS


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnBeforeTransferOrderPostReceipt', '', true, true)]
    local procedure RunOnBeforeTransferOrderPostReceipt(var TransferHeader: Record "Transfer Header"; var CommitIsSuppressed: Boolean; var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line")
    var
        TransferLine: Record "Transfer Line";
        UserSetup: Record "User Setup";
    begin
        Clear(UserSetup);
        IF UserSetup.Get(UserId) then begin
            IF UserSetup."Transfer Post" then begin
                TransferLine.Reset();
                TransferLine.SetRange("Document No.", TransferHeader."No.");
                TransferLine.SetRange("Derived From Line No.", 0);
                IF TransferLine.FindSet() then
                    repeat
                        IF TransferLine."Quantity Shipped" <> TransferLine."Qty. to Receive" then
                            Error('Qty to Shipped & Qty. to Receive Not Matching ');
                    Until TransferLine.Next() = 0;
            end;
        End;
    end;


    //Ashish-FBTS-11.25.2024-NE



    var
        myInt: Integer;
        ReservationEntry: Record "Reservation Entry"; // "Reservation Entry"
        ReservationEntry2: Record "Reservation Entry";
        // NoSeriesMgt: Codeunit NoSeriesManagement;
        Entry: Integer;

        Lotno: Code[50];
        itemledentry: Record "Item Ledger Entry";
        itemledentry2: Record "Item Ledger Entry";
        QtyToAllocate: Decimal;
        QtyToReservation: Decimal;
        Reservationqty: Decimal;

        TotalremQtyILE2: Decimal;
        QtyToAllocate2: Decimal;


    var
        item: Record item;
        ExcelBuf: Record "Excel Buffer" temporary;
        TempBlob: Codeunit "Temp Blob";
        InS: InStream;
        OutS: OutStream;
        FileName: text;

}