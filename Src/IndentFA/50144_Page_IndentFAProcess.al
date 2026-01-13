page 50144 "Indent FA Processing Page"
{
    PageType = List;
    Editable = false;
    ApplicationArea = All;
    UsageCategory = History;
    SourceTable = IndentHeader;
    SourceTableView = where(Type = const("Fixed Asset"), Status = const(Released), "Created Transfer FA" = const(false));
    InsertAllowed = false;
    DeleteAllowed = true;
    // DelayedInsert = false;
    CardPageId = 50141;
    Caption = 'Fixed Asset Indent Processing';

    layout
    {
        area(Content)
        {
            repeater(control1)
            {
                field(Select; rec.Select)
                {
                    ApplicationArea = all;
                    Editable = true;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("To Location code"; Rec."To Location code")
                {
                    ApplicationArea = ALL;
                    Editable = false;
                    StyleExpr = true;
                    Style = Favorable;
                }
                field("To Location Name"; Rec."To Location Name")
                {
                    ApplicationArea = all;
                    Editable = false;
                    StyleExpr = true;
                    Style = Standard;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = true;
                    Style = StrongAccent;
                }
                field(Category; Rec.Category)
                {
                    ApplicationArea = all;
                    Caption = 'FA Subclass';
                    Editable = false;
                    StyleExpr = true;
                    Style = StandardAccent;
                }
                field(DepartmentCode; Rec."DepartmentCode")
                {
                    ApplicationArea = All;
                    Caption = 'Department Code';
                    Editable = false;
                    Visible = false;
                }
                field("Posting date"; Rec."Posting date")
                {
                    ApplicationArea = All;
                    Caption = 'Requested Delivery Date';
                    Editable = false;

                }
                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = All;
                    Caption = 'Created Date';
                    Editable = false;
                }
                field("CreatedBy"; Rec."CreatedBy")
                {
                    ApplicationArea = All;
                    Caption = 'Created By';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Select)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = Process;

                trigger OnAction()
                var
                    indentHdr: Record IndentHeader;
                    indentline: Record Indentline;
                    usersetup: Record "User Setup";

                    indentLinerec1: Record Indentline;
                    Farec_4: Record "Fixed Asset";
                    TotalQtyForIdent1: Decimal;
                    CheckQty_2: Decimal;
                    IndentHeaderRec: Record IndentHeader;
                begin
                    // IndentHeaderRec.SetRange("No.", Rec."No.");
                    CurrPage.SetSelectionFilter(IndentHeaderRec);
                    usersetup.Get(UserId);
                    IndentHeaderRec.SetRange("From Location Code", usersetup."Location Code");
                    IndentHeaderRec.SetRange(Type, IndentHeaderRec.Type::"Fixed Asset");
                    IndentHeaderRec.SetRange(Status, IndentHeaderRec.Status::Released);
                    IndentHeaderRec.SetRange("Created Transfer FA", false); //Control 
                    if IndentHeaderRec.FindSet() then begin
                        repeat
                            CheckQty_2 := 0;
                            indentLinerec1.SetRange("DocumentNo.", IndentHeaderRec."No.");
                            if indentLinerec1.FindSet() then begin
                                repeat
                                    Farec_4.SetRange("Parent Fixed Asset", indentLinerec1."Item Code");
                                    Farec_4.SetRange("Location Code", IndentHeaderRec."From Location Code");
                                    Farec_4.SetRange("Used To", false);
                                    if Farec_4.FindSet() then begin
                                        repeat
                                            CheckQty_2 += 1;
                                        until Farec_4.Next() = 0;
                                    end;
                                until indentLinerec1.Next() = 0;


                                if CheckQty_2 <> 0 then begin
                                    // usersetup.Get(UserId);
                                    // indentHdr.Reset();
                                    // //indentHdr.SetRange("To Location code", usersetup."Location Code");
                                    // IndentHeaderRec.SetRange("From Location Code", usersetup."Location Code");
                                    // IndentHeaderRec.SetRange(Type, IndentHeaderRec.Type::"Fixed Asset");
                                    // IndentHeaderRec.SetRange(Status, IndentHeaderRec.Status::Released);
                                    // IndentHeaderRec.SetRange("Created Transfer FA", false); //Control 
                                    // if IndentHeaderRec.FindSet() then
                                    //     repeat
                                    IndentHeaderRec.Select := true;
                                    IndentHeaderRec.Modify(true);
                                    indentline.Reset();
                                    indentline.SetRange("DocumentNo.", IndentHeaderRec."No.");
                                    IF indentline.FindSet() then
                                        indentline.ModifyAll(Select, true);
                                    //  until IndentHeaderRec.Next() = 0;
                                    Message('Selected');
                                end;
                            end;
                        until IndentHeaderRec.Next() = 0;
                        //Message('Success');
                    end;
                end;
            }
            action(UnSelect)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = Process;

                trigger OnAction()
                var
                    indentHdr: Record IndentHeader;
                    indentline: Record Indentline;
                    usersetup: Record "User Setup";
                begin
                    CurrPage.SetSelectionFilter(indentHdr);
                    usersetup.Get(UserId);
                    indentHdr.Reset();
                    //indentHdr.SetRange("To Location code", usersetup."Location Code");
                    indentHdr.SetRange("From Location Code", usersetup."Location Code");
                    indentHdr.SetRange(Type, indentHdr.Type::"Fixed Asset");
                    indentHdr.SetRange("Created Transfer FA", false);
                    indentHdr.SetRange(Status, indentHdr.Status::Released);
                    if indentHdr.FindSet() then
                        repeat
                            indentHdr.Select := false;
                            indentHdr.Modify(true);
                            indentline.Reset();
                            indentline.SetRange("DocumentNo.", indentHdr."No.");
                            IF indentline.FindSet() then
                                indentline.ModifyAll(Select, false);
                        until indentHdr.Next() = 0;
                    //  Message('Unselected');
                end;
            }
            action("Create Transfer Order")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = Post;
                trigger OnAction()
                var
                    indentHdr: Record IndentHeader;
                    indentline: Record Indentline;
                    usersetup: Record "User Setup";
                    //For Less Inventory of FAR AGN FAM
                    /*
                    FixedAsset1: Record "Fixed Asset";
                    FixedAsset: Record "Fixed Asset";
                    IndentLine1: Record Indentline;
                    FarQtyAviable: Decimal;
                    */
                    //For Less Inventory of FAR AGN FAM

                    IndentLine2: Record Indentline;
                    TotalIndetQty: Decimal;
                    FaREc2: Record "Fixed Asset";
                    FarQtyAviable1: Decimal;
                    ShortQty: Decimal;

                    indentLinerec: Record Indentline;
                    Farec4: Record "Fixed Asset";
                    TotalQtyForIdent: Decimal;
                    CheckQty2: Decimal;

                begin
                    //For Less Inventory of FAR AGN FAM

                    // IndentLine1.SetRange("DocumentNo.", Rec."No.");
                    // if IndentLine1.FindSet() then begin
                    //     repeat
                    //         FarQtyAviable := 0;
                    //         FixedAsset.SetRange("Parent Fixed Asset", IndentLine1."Item Code");
                    //         if FixedAsset.FindSet() then begin
                    //             repeat
                    //                 FarQtyAviable += 1;
                    //             until FixedAsset.Next() = 0;
                    //         end;
                    //         if FarQtyAviable < IndentLine1.Quantity then Error('%1 FA have in-sufficient Qty Of FAR', IndentLine1."Item Code");
                    //     until IndentLine1.Next() = 0;
                    // end;

                    //For Less Inventory of FAR AGN FAM


                    //For Short Qty +
                    /*
                    FarQtyAviable1 := 0;
                    TotalIndetQty := 0;
                    ShortQty := 0;
                    IndentLine2.SetRange("DocumentNo.", Rec."No.");
                    if IndentLine2.FindSet() then begin
                        repeat
                            TotalIndetQty += IndentLine2.Quantity;
                            FaREc2.SetRange("Parent Fixed Asset", IndentLine2."Item Code");
                            FaREc2.SetRange("Location Code", Rec."From Location Code");
                            FaREc2.SetRange("Used To", false);
                            if FaREc2.FindSet() then begin
                                repeat
                                    FarQtyAviable1 += 1;
                                until FaREc2.Next() = 0;
                            end;
                            ShortQty := TotalIndetQty - FarQtyAviable1;
                            // if FarQtyAviable1 < TotalIndetQty then Message('Indent Quanity For FA is %1 & Total Avialable FAR is %2', TotalIndetQty);
                            if ShortQty <> 0 then
                                Message('Indent Quanity For %1 is %2 & Total Avialable FAR QTY is %3', TotalIndetQty, IndentLine2."Item Code", FarQtyAviable1);
                        until IndentLine2.Next() = 0;
                        // ShortQty := TotalIndetQty - FarQtyAviable1;
                    end;
                    */
                    //For Short Qty -


                    if usersetup.Get(UserId) then;
                    indentHdr.Reset();
                    //indentHdr.SetRange("To Location code", usersetup."Location Code");
                    indentHdr.SetRange("From Location Code", usersetup."Location Code");
                    indentHdr.SetRange(Type, indentHdr.Type::"Fixed Asset");
                    indentHdr.SetRange(Status, indentHdr.Status::Released);
                    indentHdr.SetRange("Created Transfer FA", false);
                    indentHdr.SetRange(Select, true);
                    IF indentHdr.FindSet() then begin
                        repeat
                            CheckQty2 := 0;
                            indentLinerec.SetRange("DocumentNo.", indentHdr."No.");
                            if indentLinerec.FindSet() then begin
                                repeat
                                    Farec4.SetRange("Parent Fixed Asset", indentLinerec."Item Code");
                                    Farec4.SetRange("Location Code", indentHdr."From Location Code");
                                    Farec4.SetRange("Used To", false);
                                    if Farec4.FindSet() then begin
                                        repeat
                                            CheckQty2 += 1;
                                        until Farec4.Next() = 0;
                                    end;
                                until indentLinerec.Next() = 0;
                                // if CheckQty2 = 0 then Error('No Far Avialable,for all indent line');
                            end;
                            if CheckQty2 <> 0 then
                                CreateTransferOrder(indentHdr);
                        until indentHdr.Next() = 0;
                        Message('Created Transfer Orders Successfully for all selected FA Indents.');
                    end;
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        usersetup: Record "User Setup";
    begin
        IF usersetup.Get(UserId) then
            Rec.SetRange("From Location Code", usersetup."Location Code");
        // Rec.FilterGroup(2);
        // Rec.Setfilter("From Location code", '=%1|=%2', usersetup."Location Code", '');
        // Rec.FilterGroup(1);

    end;

    local procedure CreateTransferOrder(recIndent: Record IndentHeader)
    var
        transHdr: Record "Transfer Header";
        transHdr1: Record "Transfer Header";
        transline: Record "Transfer Line";
        transline1: Record "Transfer Line";
        inventorySetup: Record "Inventory Setup";
        usersetup: Record "User Setup";
        noseriesmgt: Codeunit NoSeriesManagement;
        IndentLine: Record Indentline;
        TransHdr2: Record "Transfer Header";
        IndentLn: Record Indentline;
        FAIndentHdr: Record IndentHeader;
        Transno: code[20];
        ReqDateVar: Date;

        indentLinerec: Record Indentline;
        Farec4: Record "Fixed Asset";
        TotalQtyForIdent: Decimal;
        CheckQty2: Decimal;
        IndentLine2: Record Indentline;
        Leftqty: Decimal;

    begin
        //If No FAR Avialable Throughout
        // CheckQty2 := 0;
        // indentLinerec.SetRange("DocumentNo.", Rec."No.");
        // if indentLinerec.FindSet() then begin
        //     repeat
        //         Farec4.SetRange("Parent Fixed Asset", indentLinerec."Item Code");
        //         Farec4.SetRange("Location Code", Rec."From Location Code");
        //         Farec4.SetRange("Used To", false);
        //         if Farec4.FindSet() then begin
        //             repeat
        //                 CheckQty2 += 1;
        //             until Farec4.Next() = 0;
        //         end;
        //     until indentLinerec.Next() = 0;
        //     if CheckQty2 = 0 then Error('No Far Avialable,for all indent line');
        // end;
        //If No FAR Avialable Throughout
        inventorySetup.Get();
        usersetup.Get(UserId);
        Clear(ReqDateVar);
        IndentLine.Reset();
        IndentLine.SetRange("DocumentNo.", recIndent."No.");
        IndentLine.SetFilter("Request Delivery Date", '<>%1', 0D);
        if IndentLine.FindFirst() then
            ReqDateVar := IndentLine."Request Delivery Date";

        transHdr.Init();
        transHdr.Validate("No.", noseriesmgt.GetNextNo(inventorySetup."Transfer Order Nos.", WorkDate(), true));
        transHdr.Validate("Transfer-from Code", recIndent."From Location Code");
        transHdr.Validate("Transfer-to Code", recIndent."To Location code");
        if ReqDateVar <> 0D then
            transHdr.Validate("Posting Date", ReqDateVar)
        else
            transHdr.Validate("Posting Date", Today);

        transHdr.Validate("Shipment Date", ReqDateVar);
        transHdr.Validate("Requistion No.", recIndent."No.");
        // transHdr.Validate("In-Transit Code", 'INTRANSIT');
        transHdr.Validate("In-Transit Code", 'INTRANSIT1');
        transHdr.Validate("Shipment Date", recIndent."Posting date");
        transHdr.Insert(true);


        CreateTransferLines(transHdr, recIndent);

        IndentLine2.SetRange("DocumentNo.", Rec."No.");
        if IndentLine2.FindSet() then begin
            repeat
                //Leftqty += IndentLine2.Quantity;
                Leftqty += IndentLine2."FA Qty. Shipped"
            // Leftqty += IndentLine2."FA Qty. to Ship";
            until IndentLine2.Next() = 0;
        end;
        if Leftqty <> 0 then begin
            //if Leftqty = 0 then begin
            FAIndentHdr.Reset();
            FAIndentHdr.SetRange("No.", Rec."No.");
            if FAIndentHdr.FindFirst() then begin
                FAIndentHdr."Transfer Order No." := Rec."No.";
                FAIndentHdr."Processed Date & time" := CurrentDateTime;
                FAIndentHdr."Processed By" := UserId;
                FAIndentHdr.Status := FAIndentHdr.Status::Processed;
                FAIndentHdr.Select := false;
                FAIndentHdr."Created Transfer FA" := true;
                FAIndentHdr.Modify(true);
            end;
        end;


        //Transfer Order Release
        TransHdr2.Reset();
        TransHdr2.SetRange("No.", transHdr."No.");
        IF TransHdr2.FindFirst() then begin
            TransHdr2.Validate(Status, TransHdr2.Status::Released);
            TransHdr2.Modify(true);
        end;
    end;

    // CreateTransferLines -RKAlle28Nov2023 <Start>
    local procedure CreateTransferLines(var TransferHeader: Record "Transfer Header"; IndentHDR: Record IndentHeader)
    var
        GSTPer: Decimal;//PT-FBTS 18-08-2025
        BookvalueGST: Decimal;
        IndentLine: Record Indentline;
        transline: Record "Transfer Line";
        transline2: Record "Transfer Line";
        FixedAssetFAR: Record "Fixed Asset";
        CloseQty: Decimal;
        Start: Decimal;
        LineNo: Integer;
        FARNo: Code[20];
        Window: Dialog;
        Text000: Label 'Processing Transfer Order Creation For Indent Fixed Assets     #1##########';
        FARec: Record "Fixed Asset";
        // IndentLine3: Record Indentline;
        FaREc3: Record "Fixed Asset";
        CheckQty: Decimal;
        FARec2: Record "Fixed Asset";
        diffqty: Decimal;
        FAIndentHdr: Record IndentHeader;
        FADepreciationBook: Record "FA Depreciation Book";
    begin
        Clear(BookvalueGST);
        Clear(GSTPer);
        IndentLine.Reset();
        IndentLine.SetRange("DocumentNo.", IndentHDR."No.");
        if IndentLine.FindSet() then begin
            // //
            // CheckQty := 0;
            // FaREc3.SetRange("Parent Fixed Asset", IndentLine."Item Code");
            // FaREc3.SetRange("Location Code", IndentHDR."From Location Code");
            // FaREc3.SetRange("Used To", false);
            // if FaREc3.FindSet() then begin
            //     repeat
            //         // if IndentLine.Quantity = CheckQty then
            //         //     exit else
            //         CheckQty += 1;
            //     until FaREc3.Next() = 0;
            // end;
            //
            Clear(CloseQty);
            repeat
                //
                CheckQty := 0;
                FaREc3.SetRange("Parent Fixed Asset", IndentLine."Item Code");
                FaREc3.SetRange("Location Code", IndentHDR."From Location Code");
                FaREc3.SetRange("Used To", false);
                if FaREc3.FindSet() then begin
                    repeat
                        CheckQty += 1;
                    until FaREc3.Next() = 0;
                end;
                Clear(CloseQty);
                //if CheckQty = IndentLine.Quantity then CloseQty := IndentLine.Quantity;
                // if CheckQty < IndentLine.Quantity then begin
                //     CloseQty := CheckQty;
                // end else begin
                //     CloseQty := IndentLine.Quantity;
                // end;
                if CheckQty < IndentLine."FA Qty. to Ship" then begin
                    CloseQty := CheckQty;
                end else begin
                    CloseQty := IndentLine."FA Qty. to Ship";
                end;
                //if CheckQty > IndentLine.Quantity then CloseQty := IndentLine.Quantity;

                Window.Open(Text000);
                Clear(Start);
                for Start := 1 to CloseQty do begin
                    // Clear(FARNo);
                    FARNo := '';
                    FixedAssetFAR.Reset();
                    FixedAssetFAR.SetRange("Location Code", IndentHDR."From Location Code");
                    FixedAssetFAR.SetRange("Parent Fixed Asset", IndentLine."Item Code");
                    FixedAssetFAR.SetRange("Used To", false);
                    if FixedAssetFAR.FindFirst() then begin
                        FARNo := FixedAssetFAR."No.";
                        // FARec.Reset();
                        if FARec.Get(FARNo) then begin
                            FARec."Used To" := True;
                            FARec.Modify();
                        end;
                    end;
                    Window.Update(1, IndentLine."Item Code");
                    Clear(LineNo);

                    transline2.Reset();
                    transline2.SetRange("Document No.", TransferHeader."No.");
                    if transline2.FindLast() then begin
                        LineNo := transline2."Line No." + 10000
                    end
                    else begin
                        LineNo := 10000;
                    end;
                    transline.Reset();
                    transline.Init();
                    transline.Validate("Document No.", TransferHeader."No.");
                    transline.Validate("Line No.", LineNo);
                    transline.Validate("Item No.", '9999999'); //Control Item //No Need To Validate
                                                               //transline."Item No." := '9999999'; //Control Item 
                    transline."Parent Fixed Asset" := IndentLine."Item Code";
                    transline.Validate(Quantity, 1);
                    // transline.Validate("Indent Qty.", IndentLine.Quantity);
                    transline.Validate("Indent Qty.", IndentLine."FA Qty. to Ship");
                    transline.Validate("FA Subclass", IndentLine."FA Subclass");
                    // transline.Validate(FixedAssetNo, FARNo); //FAR No. replaced FAM No.
                    transline.FixedAssetNo := FARNo;
                    transline.Insert(true);
                    //if FARec2.get(transline.FixedAssetNo) then begin //NICK_261223
                    if FARec2.get(IndentLine."Item Code") then begin //NICK_261223
                        //  transline."GST Group Code" := FARec2."GST Group Code"; oldcode//PT-FBTS-19-06-2-24
                        transline.Validate("GST Group Code", FARec2."GST Group Code");//PT-FBTS19-06-2-24
                        // transline."HSN/SAC Code" := FARec2."HSN/SAC Code"; oldcode//PT-FBTS 19-06-2-24
                        transline.Validate("HSN/SAC Code", FARec2."HSN/SAC Code");//PT-FBTS 19-06-2-24
                                                                                  //transline."GST Credit" := FARec2."GST Credit";oldcode//PT-FBTS
                        transline.Validate("GST Credit", FARec2."GST Credit");//PT-FBTS 19-06-2-24
                        transline.Description := FARec2.Description;
                        Evaluate(GSTPer, FARec2."GST Group Code");
                        //if FADepreciationBook.Get(FARNo) then
                        FADepreciationBook.SetRange("FA No.", FARNo);
                        if FADepreciationBook.FindFirst() then
                            FADepreciationBook.CalcFields("Book Value");
                        BookvalueGST := Round(FADepreciationBook."Book Value" / (100 + GSTPer) * 100);
                        //transline.Amount := FADepreciationBook."Book Value";oldcode//PT-FBTS-19-06-2-24
                        //transline.Validate(Amount, FADepreciationBook."Book Value");//PT-FBTS-19-06-2-24////old code icommPT-FBTS-10-09-2025
                        // transline."Transfer Price" := FADepreciationBook."Book Value";oldcode//PT-FBTS-19-06-2-24
                        if GSTPer <> 0 then//PT-FBTS-10-09-2025
                            transline.Validate("Transfer Price", BookvalueGST)
                        else
                            transline.Validate("Transfer Price", FADepreciationBook."Book Value");//Aashish 27-09-2025
                        //  transline."Transfer Price" := FADepreciationBook."Book Value";  //Aashish 27-09-2025 //Comment Code 
                        transline.Modify();
                    end;
                end;

                diffqty := IndentLine."FA Qty. to Ship" - CloseQty;

                if diffqty = 0 then begin
                    // if Leftqty - CloseQty = 0 then begin
                    IndentLine.Status := IndentLine.Status::Processed;
                    IndentLine.Select := false;
                    IndentLine."FA Qty. to Ship" := diffqty;
                    IndentLine."FA Qty. Shipped" := IndentLine.Quantity;
                    IndentLine.Modify();
                end
                else begin
                    IndentLine."FA Qty. Shipped" := Abs(IndentLine.Quantity - diffqty);
                    IndentLine."FA Qty. to Ship" := diffqty;
                    IndentLine.Select := false;
                    IndentLine.Modify();
                    FAIndentHdr.Reset();
                    FAIndentHdr.SetRange("No.", IndentLine."DocumentNo.");
                    if FAIndentHdr.FindFirst() then begin
                        FAIndentHdr.Select := false;
                        FAIndentHdr.Modify(true);
                    end;
                end;
            //  end;
            until IndentLine.Next() = 0;
            Window.Close();
        end;
        // end;
    end;
    //-RKAlle28Nov2023 </End>

}