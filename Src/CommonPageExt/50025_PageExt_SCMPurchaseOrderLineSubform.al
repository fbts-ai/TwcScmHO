pageextension 50025 SCMPurchaseOrderLineSubform extends "Purchase Order Subform"
{
    layout
    {
        /*
        modify("Direct Unit Cost")
        {
            Editable = False;

        }
        */
        modify("Location Code")
        {
            Editable = false; //PT-FBTS 070325
        }

        modify("Direct Unit Cost")  //////PT-FBTS 04/10/24
        {
            trigger OnAfterValidate()
            var
                myInt: Integer;
                InventorySetup: Record "Inventory Setup";
                ItemRec: Record Item;
                UserSetupRec: Record "User Setup";
            begin
                UserSetupRec.Get(UserId);
                if rec."Direct Unit Cost" <> 0 then begin
                    if xRec."Direct Unit Cost" <> Rec."Direct Unit Cost" then begin
                        if (rec."No." <> '') and (rec.Quantity <> 0) then begin
                            //  InventorySetup.Get();
                            if Rec.Type = Rec.Type::"Fixed Asset" then begin
                                //if InventorySetup."FA Non Editable" = true then //OldCode
                                if UserSetupRec."Fa Non Editable" = false then//PT-FBTS 04/10/24
                                    Error('FA- Direct Unit Cost is Uneditable');
                            end;
                            if Rec.Type = Rec.Type::Item then begin
                                if ItemRec.Get(Rec."No.") then   //AJ_ALLE_30012024
                                    if ItemRec.Type = ItemRec.Type::Inventory then //AJ_ALLE_30012024
                                        //if InventorySetup."Item Non Editable" = true then  //OldCode
                                        if UserSetupRec."Item Non Editable" = false then //PT-FBTS 04/10/24
                                            Error('Item Direct Unit Cost is Uneditable'); //AJ_ALLE_10112023
                            end;
                        end;
                    end;
                end;
            end;
        }
        modify("Line Amount")
        {
            Editable = false;
        }
        modify("Qty. to Invoice")//PT-FBTS
        {
            Editable = false;
        }
        // Add changes to page layout here

        addafter("Line Amount")
        {
            field(Remarks; rec.Remarks)
            {
                Caption = 'Remarks';
            }
        }
        addbefore(Type)
        {
            field("Select for Fixed Asset"; Rec.SelectforFixedAsset)
            {
                ApplicationArea = All;
            }

        }
        addafter("Location Code")
        {
            field(LocationName; LocationName)
            {
                Caption = 'Location Name';
                Editable = False;
            }
        }
        modify("No.")
        {
            trigger OnLookup(var Text: Text): Boolean
            var
                TempItem: Record "Item";
                tempPurchPrice: Record TWCPurchasePrice;
                TempPurchHead: Record "Purchase Header";
                TempFixedAsset: Record "Fixed Asset";
                TempGLAccount: Record "G/L Account";

            begin
                IF Type = Rec.Type::Item then begin
                    TempPurchHead.Reset();
                    TempPurchHead.SetRange("No.", Rec."Document No.");
                    IF TempPurchHead.FindFirst() then;

                    if Rec.Type = Rec.Type::Item then Begin

                        TempItem.Reset();
                        TempItem.SetFilter(TempItem."No.", '<>%1', '');
                        IF TempItem.FindSet() then
                            repeat

                                tempPurchPrice.Reset();
                                tempPurchPrice.SetRange(tempPurchPrice.PurchPricetype, tempPurchPrice.PurchPricetype::Item);
                                tempPurchPrice.SetRange(tempPurchPrice."Item No.", TempItem."No.");
                                tempPurchPrice.SetRange(tempPurchPrice."Vendor No.", TempPurchHead."Buy-from Vendor No.");
                                tempPurchPrice.SetRange(tempPurchPrice."Location Code", TempPurchHead."Location Code");
                                tempPurchPrice.SetFilter(tempPurchPrice."Starting Date", '<=%1', TempPurchHead."Document Date");
                                tempPurchPrice.SetFilter(tempPurchPrice."Ending Date", '=%1', 0D);
                                IF tempPurchPrice.FindFirst() then
                                    TempItem.Mark(true);


                            until TempItem.Next() = 0;

                        //  TempItem.Reset();
                        TempItem.MarkedOnly(true);
                        //IF TempItem.FindSet() then;
                        IF PAGE.RUNMODAL(0, TempItem) = ACTION::LookupOK THEN begin
                            Rec."No." := TempItem."No.";
                            Rec.Validate(Rec."No.");



                        end;
                    End;
                end;

                IF Type = Rec.Type::"Fixed Asset" then begin
                    TempFixedAsset.Reset();
                    TempFixedAsset.SetFilter("No.", '<>%1', '');
                    IF TempFixedAsset.FindSet() then;

                    // IF PAGE.RUNMODAL(0, TempFixedAsset) = ACTION::LookupOK THEN begin
                    IF PAGE.RUNMODAL(50112, TempFixedAsset) = ACTION::LookupOK THEN begin//ALLE_NICK_140224
                        Rec."No." := TempFixedAsset."No.";
                        Rec.Validate(Rec."No.");
                    end;

                end;

                IF Type = Rec.Type::"G/L Account" then begin
                    TempGLAccount.Reset();
                    TempGLAccount.SetFilter("No.", '<>%1', '');
                    IF TempGLAccount.FindSet() then;

                    IF PAGE.RUNMODAL(0, TempGLAccount) = ACTION::LookupOK THEN begin
                        Rec."No." := TempGLAccount."No.";
                        Rec.Validate(Rec."No.");
                    end;

                end;


            end;
        }



    }

    actions
    {
        // Add changes to page actions here
        addafter("&Line")
        {
            action(CreateFixedAsset)
            {
                ApplicationArea = All;
                Caption = 'Create New Fixed Assets', comment = 'NLB="YourLanguageCaption"';
                Image = FixedAssets;
                trigger OnAction()
                var
                    PurchHeader: Record "Purchase Header";
                    PurchLine: Record "Purchase Line";
                    i: Integer;
                    ArchiveManagement: Codeunit ArchiveManagement;
                    FixedAsset: Record "Fixed Asset";
                begin
                    PurchLine.Reset();
                    PurchLine.SetRange("Document Type", Rec."Document Type");
                    PurchLine.SetRange("Document No.", Rec."Document No.");
                    PurchLine.SetRange(Type, PurchLine.Type::"Fixed Asset");
                    PurchLine.SetRange(SelectforFixedAsset, true);
                    IF PurchLine.FindSet() then begin
                        PurchHeader.get(Rec."Document Type", Rec."Document No.");
                        PurchHeader.CalcFields("No. of Archived Versions");
                        IF PurchHeader."No. of Archived Versions" = 0 then
                            ArchiveManagement.ArchivePurchDocument(PurchHeader);
                        repeat
                            i := 1;
                            while i <= PurchLine.Quantity do begin
                                IF CreateFixedAssetCard(PurchLine, FixedAsset) then
                                    CreatePurchline(PurchLine, FixedAsset);
                                i += 1;
                            end;
                            PurchLine.Delete();
                        until PurchLine.Next() = 0;
                    end;
                end;
            }
        }

        /*
        // Add changes to page actions here
        addafter("&Line")
        {
            group(AutoLotAssignment)
            {
                action(AutoLotAssignShipment)
                {
                    ApplicationArea = All;
                    Caption = 'AutoLotAssignShipment';
                    Image = Purchase;

                    // ShortCutKey = 'Ctrl+Alt+I';
                    ToolTip = 'Auto Lot Assignement';

                    trigger OnAction()
                    var

                        TempPurchLine: Record "Purchase Line";
                        TempIetm: Record Item;
                        LocalPurchcodeunit: Codeunit LocalPurch;


                    begin
                        TempPurchLine.Reset();
                        TempPurchLine.SetRange("Document No.", Rec."Document No.");
                        TempPurchLine.SetRange(TempPurchLine.Type, TempPurchLine.Type::Item);
                        if TempPurchLine.FindSet() then
                            repeat
                                IF TempIetm.Get(TempPurchLine."No.") then;
                                if TempIetm."Item Tracking Code" <> '' then Begin
                                    TempPurchLine.TestField(TempPurchLine."Location Code");
                                    TempPurchLine.TestField(TempPurchLine."Qty. to Invoice (Base)");
                                    TempPurchLine.TestField(TempPurchLine."Qty. to Receive (Base)");

                                    LocalPurchcodeunit.PurchaseOrderReservationEntry(TempPurchLine);
                                end;
                            Until TempPurchLine.next() = 0;

                        Message('Auto Lot no assigned sussessfully');


                    end;
                }


            }
        }
        */
    }
    local procedure CreateFixedAssetCard(PurchLine: Record "Purchase Line"; var FixedAsset: Record "Fixed Asset"): Boolean
    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
        FASetup: Record "FA Setup";
        FAPurchLine: Record "Fixed Asset";
        CopyFA: Report "Copy Fixed Asset";
        DefaultDim: Record "Default Dimension";
        DefaultDim2: Record "Default Dimension";
        FADeprBook: Record "FA Depreciation Book";
        FADeprBook2: Record "FA Depreciation Book";
    begin
        FAPurchLine.Get(PurchLine."No.");
        //CopyFA.SetFANo(PurchLine."No.");
        //CopyFA.InitializeRequest(PurchLine."No.",PurchLine.Quantity,);
        //CopyFA.RunModal();
        DefaultDim.LockTable();
        FADeprBook.LockTable();
        FixedAsset.LockTable();
        FASetup.GET();
        FixedAsset.Init();
        FixedAsset.TransferFields(FAPurchLine);
        FixedAsset.Validate("No.", NoSeriesMgt.GetNextNo(FASetup."Fixed Asset Nos.", WorkDate(), true));
        FixedAsset."PO Item" := false;
        FixedAsset."Parent Fixed Asset" := FAPurchLine."No.";
        FADeprBook."FA No." := PurchLine."No.";
        FADeprBook.SetRange("FA No.", PurchLine."No.");
        DefaultDim."Table ID" := DATABASE::"Fixed Asset";
        DefaultDim."No." := PurchLine."No.";
        DefaultDim.SetRange("Table ID", DATABASE::"Fixed Asset");
        DefaultDim.SetRange("No.", PurchLine."No.");
        DefaultDim2 := DefaultDim;
        //for location code
        FixedAsset."Location Code" := PurchLine."Location Code";
        //
        FixedAsset.Insert();

        if DefaultDim.Find('-') then
            repeat
                DefaultDim2 := DefaultDim;
                DefaultDim2."No." := FixedAsset."No.";
                DefaultDim2.Insert(true);
            until DefaultDim.Next() = 0;
        if FADeprBook.Find('-') then
            repeat
                FADeprBook2 := FADeprBook;
                FADeprBook2."FA No." := FixedAsset."No.";
                FADeprBook2.Insert(true);
            until FADeprBook.Next() = 0;

        IF FixedAsset.Modify() then
            exit(true)
        else
            exit(false);
    end;

    local procedure CreatePurchline(var PurchLine: Record "Purchase Line"; F_Assest: Record "Fixed Asset")
    var
        PurchaseLine: Record "Purchase Line";
        RecPurchLine: Record "Purchase Line";
        LineNum: Integer;
    begin
        PurchaseLine.Reset();
        PurchaseLine.SetRange("Document Type", PurchLine."Document Type");
        PurchaseLine.SetRange("Document No.", PurchLine."Document No.");
        If PurchaseLine.FindLast() then
            LineNum := PurchaseLine."Line No." + 10000
        else
            LineNum := 10000;

        RecPurchLine.Init();
        RecPurchLine.TransferFields(PurchLine);
        RecPurchLine.Validate("No.", F_Assest."No.");
        RecPurchLine.Validate("Line No.", LineNum);
        RecPurchLine.Validate("Location Code", PurchLine."Location Code");
        RecPurchLine.Validate(Quantity, 1);
        RecPurchLine.Validate("Direct Unit Cost", PurchLine."Direct Unit Cost");
        RecPurchLine.SelectforFixedAsset := false;
        RecPurchLine."TDS Section Code" := PurchLine."TDS Section Code";
        //added for gst 
        RecPurchLine."GST Group Code" := PurchLine."GST Group Code";
        RecPurchLine."HSN/SAC Code" := PurchLine."HSN/SAC Code";
        RecPurchLine."GST Credit" := PurchLine."GST Credit";
        //
        RecPurchLine.Insert();
    end;

    trigger OnAfterGetRecord()
    var
        TempLocation: Record Location;
    begin
        if Rec."Location Code" <> '' Then begin
            IF TempLocation.Get(Rec."Location Code") then;
            LocationName := TempLocation.Name;
        end;
    end;

    trigger OnAfterGetCurrRecord()
    var
        TempLocation: Record Location;
    begin
        if Rec."Location Code" <> '' Then begin
            IF TempLocation.Get(Rec."Location Code") then;
            LocationName := TempLocation.Name;
        end;
    end;






    var
        myInt: Integer;
        [InDataSet]
        IsDirectUnitCostEditable: Boolean;

        LocationName: Text[50];
}