page 51017 "GRN List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = GRN;
    SourceTableView = where("Create Invoice" = const(False));


    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("GRN No."; Rec."GRN No.")
                {
                    ToolTip = 'Specifies the value of the GRN No. field.', Comment = '%';
                    ApplicationArea = all;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = all;

                    ToolTip = 'Specifies the value of the Line No. field.', Comment = '%';
                }
                field("GRN Date"; Rec."GRN Date")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the GRN Date field.', Comment = '%';
                }
                field("Doc No."; Rec."Doc No.")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Doc No. field.', Comment = '%';
                }
                field("DC Date"; Rec."DC Date")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Doc No. field.', Comment = '%';
                }

                field("Purchase Order No."; Rec."Purchase Order No.")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Purchase Order No. field.', Comment = '%';
                }
                field("Create Invoice"; Rec."Create Invoice")
                {
                    ApplicationArea = all;
                    Editable = false;

                    ToolTip = 'Specifies the value of the Create Invoice field.', Comment = '%';
                }
                field("Invoice No."; Rec."Invoice No.")
                {
                    ApplicationArea = all;
                    Editable = false;

                    ToolTip = 'Specifies the value of the Invoice No. field.', Comment = '%';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Location Code field.', Comment = '%';
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Vendor No. field.', Comment = '%';
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Vendor Name field.', Comment = '%';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Item No. field.', Comment = '%';
                }
                field("Type"; Rec."Type")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Type field.', Comment = '%';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Quantity field.', Comment = '%';
                }
                field("Invoiced Qty"; Rec."Invoiced Qty")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Invoiced Qty field.', Comment = '%';
                }
                field("Qty. Rcd. Not Invoiced"; Rec."Qty. Rcd. Not Invoiced")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Qty. Rcd. Not Invoiced field.', Comment = '%';
                }
                field("GRN Rate"; Rec."GRN Rate")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the GRN Rate field.', Comment = '%';
                }
                field("GRN Amout Without GST"; Rec."GRN Amout Without GST")
                {
                    ApplicationArea = all;

                    ToolTip = 'Specifies the value of the GRN Amout Without GST field.', Comment = '%';
                }
                field("Vendor Invoice No."; Rec."Vendor Invoice No.")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Vendor Invoice No. field.', Comment = '%';
                }
                field("Vendor Invoice Date"; Rec."Vendor Invoice Date")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Vendor Invoice Date field.', Comment = '%';
                }
                field("PI Qty."; Rec."PI Qty.")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the PI Qty. field.', Comment = '%';
                }
                field("PI Rate"; Rec."PI Rate")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the PI Rate field.', Comment = '%';
                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(ImportCSV)
            {
                PromotedCategory = Process;
                ApplicationArea = All;
                Caption = 'Import CSV Data';
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    InS: InStream;
                    FileName: Text[100];
                    UploadMsg: Label 'Please choose the CSV file';
                    Item: Record Item;
                    LineNo: Integer;
                    GRN_gRec: Record GRN;
                    GRNLineCheck_gRec: Record GRN;

                    DATEvalue: text;
                    DATEvalue1: text;
                    EntryNo: Integer;
                begin
                    DATEvalue := '';
                    CSVBuffer.Reset();
                    CSVBuffer.DeleteAll();
                    if UploadIntoStream(UploadMsg, '', '', FileName, InS) then begin
                        CSVBuffer.LoadDataFromStream(InS, ',');
                        for LineNo := 2 to CSVBuffer.GetNumberOfLines() do begin
                            GRNLineCheck_gRec.Reset();
                            IF GRNLineCheck_gRec.FindLast() then
                                GRNLineCheck_gRec."Entry No." += 1;

                            GRN_gRec.Init();
                            GRN_gRec."Entry No." := GRNLineCheck_gRec."Entry No.";
                            if GetValueAtCell(LineNo, 1) <> '' then Evaluate(GRN_gRec."GRN No.", GetValueAtCell(LineNo, 1));
                            if GetValueAtCell(LineNo, 2) <> '' then Evaluate(GRN_gRec."Line No.", GetValueAtCell(LineNo, 2));
                            if GetValueAtCell(LineNo, 3) <> '' then Evaluate(GRN_gRec."GRN Date", GetValueAtCell(LineNo, 3));

                            if GetValueAtCell(LineNo, 4) <> '' then Evaluate(GRN_gRec."Doc No.", GetValueAtCell(LineNo, 4));
                            if GetValueAtCell(LineNo, 5) <> '' then Evaluate(GRN_gRec."DC Date", GetValueAtCell(LineNo, 5));
                            if GetValueAtCell(LineNo, 6) <> '' then Evaluate(GRN_gRec."Purchase Order No.", GetValueAtCell(LineNo, 6));
                            if GetValueAtCell(LineNo, 7) <> '' then Evaluate(GRN_gRec."Location Code", GetValueAtCell(LineNo, 7));
                            if GetValueAtCell(LineNo, 8) <> '' then Evaluate(GRN_gRec."Vendor No.", GetValueAtCell(LineNo, 8));
                            if GetValueAtCell(LineNo, 9) <> '' then Evaluate(GRN_gRec."Vendor Name", GetValueAtCell(LineNo, 9));
                            if GetValueAtCell(LineNo, 10) <> '' then Evaluate(GRN_gRec."Item No.", GetValueAtCell(LineNo, 10));
                            if GetValueAtCell(LineNo, 11) <> '' then Evaluate(GRN_gRec.Type, GetValueAtCell(LineNo, 11));

                            if GetValueAtCell(LineNo, 12) <> '' then Evaluate(GRN_gRec.Description, GetValueAtCell(LineNo, 12));
                            if GetValueAtCell(LineNo, 13) <> '' then Evaluate(GRN_gRec.Quantity, GetValueAtCell(LineNo, 13));

                            if GetValueAtCell(LineNo, 14) <> '' then
                                Evaluate(GRN_gRec."Invoiced Qty", GetValueAtCell(LineNo, 14));
                            if GetValueAtCell(LineNo, 15) <> '' then
                                Evaluate(GRN_gRec."Qty. Rcd. Not Invoiced", GetValueAtCell(LineNo, 15));
                            if GetValueAtCell(LineNo, 16) <> '' then
                                Evaluate(GRN_gRec."GRN Rate", GetValueAtCell(LineNo, 16));
                            if GetValueAtCell(LineNo, 17) <> '' then
                                Evaluate(GRN_gRec."GRN Amout Without GST", GetValueAtCell(LineNo, 17));


                            if GetValueAtCell(LineNo, 18) <> '' then
                                Evaluate(GRN_gRec."Vendor Invoice No.", GetValueAtCell(LineNo, 18));
                            if GetValueAtCell(LineNo, 19) <> '' then
                                Evaluate(GRN_gRec."Vendor Invoice Date", GetValueAtCell(LineNo, 19));
                            if GetValueAtCell(LineNo, 20) <> '' then
                                Evaluate(GRN_gRec."PI Qty.", GetValueAtCell(LineNo, 20));
                            if GetValueAtCell(LineNo, 21) <> '' then
                                Evaluate(GRN_gRec."PI Rate", GetValueAtCell(LineNo, 21));

                            //     Evaluate(GRN_gRec."DC Date", GetValueAtCell(LineNo, 21));
                            GRN_gRec.Insert();
                            //  end;
                        end;
                    end;
                end;
            }

            action("Create&Invoice")
            {
                Caption = 'Create Invoice';
                trigger OnAction()
                var
                    PurchRcpLine: Record "Purch. Rcpt. Line";
                    PurchaseHeader: Record "Purchase Header";
                    i: Integer;
                    PurchaseLine: Record "Purchase Line";
                    PurchaseLineDuplicate: Record "Purchase Line";

                    TempRec: Record "Cust. Ledger Entry" temporary;
                    PurchaseLineCheckInsert: Record "Purchase Line";

                    InsertPurchaseLine: Record "Purchase Line";

                    ExtraPurchaseLine: Record "Purchase Line";
                    PurchaseCheckLine: Record "Purchase Line";
                    LineNo: Integer;
                    HeaderNo: Code[20];
                    ItemTrackingManagement: Codeunit "Item Tracking Management";
                    TrackingSpecification: Record "Tracking Specification";
                    ReservEntry: Record "Reservation Entry";
                    entryNo: Integer;
                    LotNo: Code[20];
                    Itemtraking: Text[20];
                    LineNo1: Integer;
                    // TrackingSpecification:Record "Tracking Specification";
                    ItemLedger: Record "Item Ledger Entry";
                    ReservEntry1: Record "Reservation Entry";
                    SNO: Integer;
                    GRN_lRec: Record grn;
                    VendorNo: Code[20];
                    VendorInvNo: Code[20];
                    DOCNO: Code[20];
                    DocDate: Date;

                    PurchaseLineGSTValue: Record "Purchase Line";
                    DimensionSetEntry: Record "Dimension Set Entry";
                begin
                    Clear(LineNo);
                    GRN_lRec.Reset();
                    GRN_lRec.SetCurrentKey("Vendor Invoice No.", "Doc No.");
                    GRN_lRec.SetFilter("Qty. Rcd. Not Invoiced", '<>%1', 0);
                    // // GRN_lRec.SetRange("GRN No.", 'MRN/24-25/35487');
                    GRN_lRec.SetRange("Create Invoice", false);
                    IF GRN_lRec.FindSet() then
                        repeat
                            PurchRcpLine.Reset();
                            PurchRcpLine.SetFilter("Qty. Rcd. Not Invoiced", '<>%1', 0);
                            PurchRcpLine.SetRange("Document No.", GRN_lRec."GRN No.");
                            PurchRcpLine.SetRange("No.", GRN_lRec."Item No.");
                            PurchRcpLine.SetRange("Line No.", GRN_lRec."Line No.");
                            IF PurchRcpLine.FindSet() then // Begin
                                repeat
                                    // IF (VendorInvNo <> GRN_lRec."Vendor Invoice No.")  then begin
                                    //     // VendorNo := GRN_lRec."Vendor No.";
                                    //     VendorInvNo := GRN_lRec."Vendor Invoice No.";
                                    //     //  IF i = 0 then begin
                                    IF (DOCNO <> GRN_lRec."Doc No.") then begin
                                        // VendorNo := GRN_lRec."Vendor No.";
                                        DOCNO := GRN_lRec."Doc No.";
                                        //  IF i = 0 then begin

                                        PurchaseHeader.Init();
                                        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Invoice;
                                        PurchaseHeader."No." := '';
                                        PurchaseHeader.Insert(true);

                                        PurchaseHeader."Vendor Invoice No." := DOCNO;
                                        PurchaseHeader."Vendor Bill No." := GRN_lRec."Vendor Invoice No.";

                                        PurchaseHeader.Validate("Buy-from Vendor No.", GRN_lRec."Vendor No.");
                                        PurchaseHeader.Validate("Location Code", GRN_lRec."Location Code");
                                        PurchaseHeader.Validate("Posting Date", Today);
                                        IF GRN_lRec."Vendor Invoice Date" <> '' then begin
                                            Evaluate(DocDate, GRN_lRec."Vendor Invoice Date");
                                            PurchaseHeader.Validate("Document Date", DocDate);
                                        end;
                                        HeaderNo := PurchaseHeader."No.";
                                        PurchaseHeader."Auto Invoice" := true;
                                        PurchaseHeader.Modify();
                                    end;
                                    i += 1;

                                    // IF PurchRcpLine.Quantity <> GRN_lRec.Quantity then
                                    //     Error('Quantity not Matching');

                                    // PurchaseLineCheckInsert.Reset();
                                    // PurchaseLineCheckInsert.SetRange("Receipt No.", PurchRcpLine."Document No.");
                                    // PurchaseLineCheckInsert.SetRange("Receipt Line No.", PurchRcpLine."Line No.");
                                    // IF Not PurchaseLineCheckInsert.FindSet() then begin

                                    PurchaseCheckLine.Reset();
                                    PurchaseCheckLine.SetRange("Document No.", HeaderNo);
                                    IF PurchaseCheckLine.FindLast() then
                                        LineNo := PurchaseCheckLine."Line No." + 10000
                                    Else
                                        LineNo := 10000;


                                    PurchaseLineGSTValue.Reset();
                                    PurchaseLineGSTValue.SetRange("Document No.", PurchRcpLine."Order No.");
                                    PurchaseLineGSTValue.SetRange("Line No.", PurchRcpLine."Order Line No.");
                                    IF PurchaseLineGSTValue.FindFirst() then begin

                                        // DimensionSetEntry.Reset();
                                        // DimensionSetEntry.SetRange("Dimension Set ID", PurchaseLineGSTValue."Dimension Set ID");
                                        // DimensionSetEntry.SetRange("Dimension Code", 'DEPARTMENT');
                                        // IF DimensionSetEntry.findfirst then;
                                    end;
                                    PurchaseLine.Init();
                                    PurchaseLine."Document Type" := PurchaseLine."Document Type"::Invoice;
                                    PurchaseLine."Document No." := HeaderNo;
                                    PurchaseLine."Line No." := LineNo;
                                    PurchaseLine.Type := PurchRcpLine.Type;
                                    PurchaseLine.Validate("No.", PurchRcpLine."No.");
                                    PurchaseLine."Qty. per Unit of Measure" := PurchRcpLine."Qty. per Unit of Measure";

                                    PurchaseLine.Validate(Quantity, PurchRcpLine."Qty. Rcd. Not Invoiced");
                                    PurchaseLine.Validate("Unit of Measure Code", PurchRcpLine."Unit of Measure Code");
                                    PurchaseLine.Validate("Direct Unit Cost", GRN_lRec."PI Rate");
                                    // PurchaseLine."Quantity (Base)" := PurchRcpLine."Quantity (Base)";
                                    PurchaseLine.Validate("LSC Original Quantity", PurchRcpLine.Quantity);
                                    PurchaseLine.Validate("LSC Original Quantity (base)", PurchRcpLine."Quantity (Base)");
                                    PurchaseLine."Receipt No." := PurchRcpLine."Document No.";
                                    PurchaseLine."Receipt Line No." := PurchRcpLine."Line No.";
                                    PurchaseLine."GRN Rate" := GRN_lRec."GRN Rate";
                                    PurchaseLine."PI Qty." := GRN_lRec."PI Qty.";
                                    PurchaseLine."Entry No." := GRN_lRec."Entry No.";
                                    PurchaseLine."DC No." := GRN_lRec."Doc No.";
                                    PurchaseLine."Purchase Order No." := GRN_lRec."Purchase Order No.";
                                    PurchaseLine."Extra Quantity" := GRN_lRec."PI Qty." - GRN_lRec."Qty. Rcd. Not Invoiced";
                                    PurchaseLine.Validate("GST Group Code", PurchaseLineGSTValue."GST Group Code");
                                    PurchaseLine.Validate("HSN/SAC Code", PurchaseLineGSTValue."HSN/SAC Code");
                                    PurchaseLine.Validate("Dimension Set ID", PurchaseLineGSTValue."Dimension Set ID");
                                    PurchaseLine.Description := GRN_lRec.Description;


                                    PurchaseLine.Insert();
                                    Clear(entryNo);
                                    ReservEntry1.Reset();
                                    if ReservEntry1.FindLast() then
                                        entryNo := ReservEntry1."Entry No." + 1
                                    else
                                        entryNo := 1;

                                    ItemLedger.Reset();
                                    ItemLedger.SetRange("Document No.", PurchRcpLine."Document No.");
                                    ItemLedger.SetRange("Document Line No.", PurchRcpLine."Line No.");
                                    ItemLedger.SetRange("Item No.", PurchRcpLine."No.");
                                    if ItemLedger.FindFirst() then
                                        IF ItemLedger."Lot No." <> '' then begin
                                            ReservEntry.Init();
                                            ReservEntry."Item No." := PurchaseLine."No.";
                                            ReservEntry."Source Subtype" := ReservEntry."Source Subtype"::"2";
                                            ReservEntry."Source ID" := PurchaseLine."Document No.";
                                            ReservEntry."Source Ref. No." := PurchaseLine."Line No.";
                                            ReservEntry."Location Code" := PurchaseLine."Location Code";
                                            ReservEntry.Quantity := PurchaseLine."Quantity (Base)";
                                            ReservEntry."Created By" := UserId;
                                            ReservEntry."Source Type" := 39;
                                            ReservEntry."Item Tracking" := ReservEntry."Item Tracking"::"Lot No.";

                                            ReservEntry."Lot No." := ItemLedger."Lot No.";
                                            ReservEntry."Item Ledger Entry No." := ItemLedger."Entry No.";
                                            ReservEntry."Expected Receipt Date" := PurchaseLine."Expected Receipt Date";
                                            ReservEntry."Creation Date" := Today;
                                            ReservEntry."Reservation Status" := "Reservation Status"::Prospect;
                                            ReservEntry."Quantity Invoiced (Base)" := 0;
                                            ReservEntry.Validate("Quantity (Base)", PurchaseLine."Quantity (Base)");
                                            ReservEntry.Positive := (ReservEntry."Quantity (Base)" > 0);
                                            ReservEntry."Entry No." := entryNo;
                                            ReservEntry."Qty. per Unit of Measure" := PurchaseLine."Qty. per Unit of Measure";
                                            ReservEntry.Insert();
                                        end;


                                    //EXTRA Line Create-NS
                                    Clear(LineNo1);
                                    ExtraPurchaseLine.Reset();
                                    ExtraPurchaseLine.setfilter("Extra Quantity", '<>%1', 0);
                                    ExtraPurchaseLine.SetRange("Document No.", HeaderNo);
                                    ExtraPurchaseLine.SetRange("Line No.", PurchaseLine."Line No.");
                                    IF ExtraPurchaseLine.FindSet() then Begin
                                        PurchaseCheckLine.Reset();
                                        PurchaseCheckLine.SetRange("Document No.", HeaderNo);
                                        IF PurchaseCheckLine.FindLast() then
                                            LineNo1 := PurchaseCheckLine."Line No." + 10000
                                        Else
                                            LineNo1 := 10000;

                                        InsertPurchaseLine.Init();
                                        InsertPurchaseLine."Document Type" := InsertPurchaseLine."Document Type"::Invoice;
                                        InsertPurchaseLine."Document No." := HeaderNo;
                                        InsertPurchaseLine."Line No." := LineNo1;
                                        InsertPurchaseLine.Type := PurchaseLine.Type;
                                        InsertPurchaseLine.Validate("No.", PurchaseLine."No.");
                                        InsertPurchaseLine.Validate(Quantity, ExtraPurchaseLine."Extra Quantity");
                                        InsertPurchaseLine.Validate("Direct Unit Cost", GRN_lRec."PI Rate");
                                        InsertPurchaseLine."Extra Receipt No." := PurchRcpLine."Document No.";
                                        InsertPurchaseLine."Extra Receipt Line No." := PurchRcpLine."Line No.";
                                        InsertPurchaseLine.Insert();


                                        Clear(entryNo);
                                        ReservEntry1.Reset();
                                        if ReservEntry1.FindLast() then
                                            entryNo := ReservEntry1."Entry No." + 1
                                        else
                                            entryNo := 1;

                                        ItemLedger.Reset();
                                        ItemLedger.SetRange("Document No.", PurchRcpLine."Document No.");
                                        ItemLedger.SetRange("Document Line No.", PurchRcpLine."Line No.");
                                        ItemLedger.SetRange("Item No.", PurchRcpLine."No.");
                                        if ItemLedger.FindFirst() then
                                            IF ItemLedger."Lot No." <> '' then begin
                                                ReservEntry.Init();
                                                ReservEntry."Item No." := PurchaseLine."No.";
                                                ReservEntry."Source Subtype" := ReservEntry."Source Subtype"::"2";
                                                ReservEntry."Source ID" := PurchaseLine."Document No.";
                                                ReservEntry."Source Ref. No." := InsertPurchaseLine."Line No.";
                                                ReservEntry."Location Code" := PurchaseLine."Location Code";
                                                ReservEntry.Quantity := InsertPurchaseLine."Quantity (Base)";
                                                ReservEntry."Created By" := UserId;
                                                ReservEntry."Source Type" := 39;
                                                ReservEntry."Item Tracking" := ReservEntry."Item Tracking"::"Lot No.";

                                                ReservEntry."Lot No." := ItemLedger."Lot No.";
                                                ReservEntry."Item Ledger Entry No." := ItemLedger."Entry No.";
                                                ReservEntry."Expected Receipt Date" := PurchaseLine."Expected Receipt Date";
                                                ReservEntry."Creation Date" := Today;
                                                ReservEntry."Reservation Status" := "Reservation Status"::Prospect;
                                                ReservEntry."Quantity Invoiced (Base)" := 0;
                                                ReservEntry.Validate("Quantity (Base)", InsertPurchaseLine."Quantity (Base)");
                                                ReservEntry.Positive := (ReservEntry."Quantity (Base)" > 0);
                                                ReservEntry."Entry No." := entryNo;
                                                ReservEntry."Qty. per Unit of Measure" := PurchaseLine."Qty. per Unit of Measure";
                                                ReservEntry.Insert();
                                            end;
                                    END;


                                    //EXTRA Line Create-NE
                                    GRN_lRec."Create Invoice" := true;
                                    GRN_lRec."Invoice No." := HeaderNo;
                                    GRN_lRec.Modify();
                                //  END;
                                Until PurchRcpLine.Next() = 0;
                        Until GRN_lRec.Next() = 0;
                    Message('Invoice Created%1', HeaderNo);
                    // TempRec.Reset();
                    // TempRec.DeleteAll();

                    // GRN_lRec.Reset();
                    // GRN_lRec.SetCurrentKey("Entry No.");
                    // GRN_lRec.SetRange("GRN No.", 'MRN/24-25/35487');
                    // GRN_lRec.SetFilter("Qty. Rcd. Not Invoiced", '<>%1', 0);
                    // GRN_lRec.SetRange("Create Invoice", false);
                    // IF GRN_lRec.FindSet() then
                    //     repeat
                    //         PurchaseLine.Reset();
                    //         PurchaseLine.SetCurrentKey("Entry No.");
                    //         PurchaseLine.Setrange("Entry No.", GRN_lRec."Entry No.");
                    //         if PurchaseLine.FindSet() then begin
                    //             repeat
                    //                 if not TempRec.Get(PurchaseLine."Entry No.") then begin
                    //                     TempRec."Entry No." := PurchaseLine."Entry No.";
                    //                     TempRec.Insert();
                    //                     // PurchaseLineDuplicate.Modify();
                    //                 end else begin
                    //                     // Duplicate mila, delete kar do
                    //                     // PurchaseLine.Delete();
                    //                     Message('%1', TempRec."Entry No.");
                    //                     PurchaseLine."Duplicate Line" := true;
                    //                     PurchaseLine.Modify();
                    //                 end;
                    //             until PurchaseLine.Next() = 0;
                    //         end;
                    //     Until GRN_lRec.Next() = 0;



                    // // Clear(PurchaseLineDuplicate);
                    // // IF TempRec.FindSet() then
                    //     repeat
                    //         ReservEntry.Reset();
                    //         ReservEntry.SetRange("Source ID", TempRec."Document No.");
                    //         ReservEntry.SetRange("Source Ref. No.", TempRec."Line No.");
                    //         IF ReservEntry.FindSet() then
                    //             ReservEntry.Delete();
                    //         IF PurchaseLineDuplicate.GEt(TempRec."Document Type", TempRec."Document No.", TempRec."Line No.") Then begin
                    //             PurchaseLineDuplicate.Delete(true);
                    //             //  Message('%1', PurchaseLineDuplicate."Line No.");
                    //         end;
                    //     Until TempRec.Next() = 0;


                end;
            }
        }
    }


    local procedure GetValueAtCell(RowNo: Integer; ColNo: Integer): Text
    begin
        if CSVBuffer.Get(RowNo, ColNo) then
            exit(CSVBuffer.Value)
        else
            exit('');
    end;

    var
        CSVBuffer: Record "CSV Buffer" temporary;

}