codeunit 50041 "Create Purchase Invoice"
{
    TableNo = LogHeader;
    trigger OnRun()
    begin
        ClearLastError;
        if TryCreatePurchaseInvoice(Rec) then begin
            Rec.Created := true;
            Rec."Created Error" := '';

            PurchaseHeader.Reset();
            PurchaseHeader.SetRange("Response ID", Rec.ID);
            if PurchaseHeader.FindFirst() then
                Rec."Invoice No." := PurchaseHeader."No.";

            Rec.Modify;
        end;
    end;

    procedure GetFieldsValue(var NoSrcode: code[20])
    begin
        NoSrcode := NoSeriesCode;
    end;

    procedure TryCreatePurchaseInvoice(LogHeader: Record "LogHeader"): Boolean
    var
        PurchHeader: Record "Purchase Header";
        LogLine: Record "LogLine";
        PurchLine: Record "Purchase Line";
        VendorNo: Code[20];
        DocNo: Code[20];
        ID: Integer;
        BillReference: Code[20];
        PurSetup: Record "Purchases & Payables Setup";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        Vendor: Record Vendor;
        GLAccount: Record "G/L Account";
        RecLogLine: Record "LogLine";
        NoSeriesLine: Record "No. Series Line";
        LastNo: Code[20];
        AllowedSection: Record "Allowed Sections";
        location_l: record Location;
    begin
        // Setup
        PurSetup.Get();
        Clear(NoSeriesManagement);
        ID := LogHeader.ID;
        BillReference := LogHeader.bill_reference;
        VendorNo := LogHeader.REF;


        // Create Purchase Header
        PurchHeader.Init();
        PurchHeader."Document Type" := PurchHeader."Document Type"::Invoice;
        PurchHeader."No." := NoSeriesManagement.GetNextNo(PurSetup."Invoice Nos.", Today, true);
        PurchHeader.Insert(true);

        PurchHeader.Validate("Buy-from Vendor No.", VendorNo);
        PurchHeader.Validate("Location Code", LogHeader."Store Code");
        PurchHeader."Response ID" := LogHeader.ID;
        PurchHeader."Vendor Invoice No." := LogHeader.bill_reference;
        PurchHeader.Validate("Posting Date", LogHeader."Bill Date");
        PurchHeader.Validate("Due Date", LogHeader."Due Date");
        // PurchHeader.Validate("Currency Code", LogHeader."Currency");
        PurchHeader.Validate("Document Date", Today);
        PurchHeader."Assigned User ID" := UserId;

        PurchHeader."Response Details" := true;
        PurchHeader.Modify();

        DocNo := PurchHeader."No.";

        // Insert Purchase Lines
        LogLine.SetRange(ID, ID);
        if LogLine.FindSet() then begin
            repeat
                PurchLine.Init();
                PurchLine."Document Type" := PurchHeader."Document Type";
                PurchLine."Document No." := DocNo;
                PurchLine."Line No." := LogLine."Line No.";
                PurchLine.Type := PurchLine.Type::"G/L Account";
                PurchLine.Validate("No.", LogLine.internal_reference);
                PurchLine.Insert();

                PurchLine.Description := LogLine.product_description + ' | ' + Format(LogHeader."Period From") + ' -- ' + Format(LogHeader."Period to");
                PurchLine.Validate("Location Code", LogHeader."Store Code");
                PurchLine.Validate("Quantity", LogLine.Quantity);
                PurchLine."HSN/SAC Code" := LogLine.product_hsn;

                PurchLine."GST Credit" := PurchLine."GST Credit"::Availment;
                PurchLine.Validate("TDS Section Code", LogLine.TDS_Name);
                PurchLine."GST Group Code" := LogLine."Tax name";
                PurchLine.Validate("Direct Unit Cost", LogLine.price_unit);
                PurchLine.Validate("Line Amount", LogLine.Price_Subtotal);
                PurchLine.modify();
            until LogLine.Next() = 0;
        end;

        exit(true); // Success
    end;


    var
        NoSeriesCode: code[20];
        log_LIne: Record LogLine;
        PurchaseHeader: Record "Purchase Header";
}