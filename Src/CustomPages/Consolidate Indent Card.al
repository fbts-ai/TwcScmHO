page 50161 "Consolidate Indent Card"
{
    PageType = Card;
    SourceTable = "Consolidate indent Header";
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group("General")
            {
                Editable = not Rec.Post;
                ;
                field("No."; rec."No.")
                {
                }
                field("Delivery Date"; Rec."Delivery Date")
                {
                }
                field(Post; Rec.Post)
                {
                    Editable = false;
                }
            }
            part(Lines; "Consolidate Indent Lines")
            {
                SubPageLink = " Document No." = field("No.");
                Editable = not Rec.Post;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Auto Indent")
            {
                ApplicationArea = all;
                Enabled = EditBool;
                trigger OnAction()
                var
                    ConsolidatedLine: Record "Consolidate indent Line";
                begin
                    if Rec."Delivery Date" = 0D then
                        Error('Delivery Date must be defined to proceed ');
                    ConsolidatedLine.Reset();
                    ConsolidatedLine.SetRange(" Document No.", Rec."No.");
                    if not ConsolidatedLine.FindFirst() then
                        Error('No consolidated lines found for document %1.', Rec."No.");
                    ConsolidatedLine.Reset();
                    ConsolidatedLine.SetRange(" Document No.", Rec."No.");
                    ConsolidatedLine.SetRange(Quantity, 0);
                    if ConsolidatedLine.FindFirst() then
                        Error('Quantity must be defined for%1..%2..%3', ConsolidatedLine."Item No", ConsolidatedLine."Item Name", ConsolidatedLine.Store);
                    ConsolidatedLine.Reset();
                    ConsolidatedLine.SetRange(" Document No.", Rec."No.");
                    ConsolidatedLine.SetRange(UOM, '');
                    if ConsolidatedLine.FindFirst() then
                        Error('UOM must be defined for%1..%2..%3', ConsolidatedLine."Item No", ConsolidatedLine."Item Name", ConsolidatedLine.Store);

                    ConsolidatedLine.Reset();
                    ConsolidatedLine.SetRange(" Document No.", Rec."No.");
                    ConsolidatedLine.SetRange(Store, '');
                    if ConsolidatedLine.FindFirst() then
                        Error('Store must be defined for%1..%2..%3..%4', ConsolidatedLine."Item No", ConsolidatedLine."Item Name", ConsolidatedLine.Quantity, ConsolidatedLine.UOM);

                    ConsolidatedLine.Reset();
                    ConsolidatedLine.SetRange(" Document No.", Rec."No.");
                    ConsolidatedLine.SetRange("Sourcing Method", ConsolidatedLine."Sourcing Method"::" ");
                    if ConsolidatedLine.FindFirst() then
                        Error('  Sourcing Method must be defined for %1..%2..%3..%4', ConsolidatedLine."Item No", ConsolidatedLine."Item Name", ConsolidatedLine.Quantity, ConsolidatedLine.UOM);

                    ConsolidatedLine.Reset();
                    ConsolidatedLine.SetRange(" Document No.", Rec."No.");
                    ConsolidatedLine.SetRange("Source Location No.", '');
                    if ConsolidatedLine.FindFirst() then
                        Error('Sourcing Location No. must be defined for  %1..%2..%3..%4', ConsolidatedLine."Item No", ConsolidatedLine."Item Name", ConsolidatedLine.Quantity, ConsolidatedLine.UOM);



                    CreateOrdersFromIndent(Rec."No.");
                end;
            }
        }
    }
    var
        EditBool: Boolean;

    // procedure CreatePOsFromIndent(DocumentNo: Code[20])
    // var
    //     IndentLine: Record "Consolidate indent Line";
    //     PurchHeader: Record "Purchase Header";
    //     PurchLine: Record "Purchase Line";
    //     CurrentStore: Code[20];
    //     CurrentVendor: Code[20];
    //     LastDocNo: Code[20];
    //     NoSeriesMgt: Codeunit NoSeriesManagement;
    //     PurchSetup: Record "Purchases & Payables Setup";
    //     NewNo: Code[20];
    // begin
    //     IndentLine.SetRange(" Document No.", DocumentNo);
    //     IndentLine.SetCurrentKey(Store, "vendor Code");

    //     CurrentStore := '';
    //     CurrentVendor := '';
    //     LastDocNo := '';
    //     if IndentLine.FindSet() then begin
    //         repeat
    //             if (IndentLine.Store <> CurrentStore) or (IndentLine."Source Location No." <> CurrentVendor) OR
    //              (IndentLine."Sourcing Method" = IndentLine."Sourcing Method"::Purchase) then begin
    //                 CurrentStore := IndentLine.Store;
    //                 CurrentVendor := IndentLine."Source Location No.";
    //                 PurchSetup.Get();
    //                 PurchSetup.TestField("Order Nos."); // Ensure No. Series set
    //                 NewNo := NoSeriesMgt.GetNextNo(PurchSetup."Order Nos.", WORKDATE, true);

    //                 PurchHeader.Init();
    //                 PurchHeader."Document Type" := PurchHeader."Document Type"::Order;
    //                 PurchHeader."No." := NewNo;
    //                 PurchHeader.Insert(true);
    //                 PurchHeader.Validate("Buy-from Vendor No.", CurrentVendor);
    //                 PurchHeader.Validate("Indent No.", Rec."No.");
    //                 PurchHeader.Validate("Location Code", CurrentStore);
    //                 PurchHeader.Modify(true);
    //                 LastDocNo := NewNo;
    //                 Message('PO %1 created for Vendor %2 at Store %3', NewNo, CurrentVendor, CurrentStore);
    //             end;
    //             PurchLine.Init();
    //             PurchLine.SetRange("Document Type", PurchHeader."Document Type");
    //             PurchLine.SetRange("Document No.", LastDocNo);
    //             if PurchLine.FindLast() then
    //                 PurchLine."Line No." := PurchLine."Line No." + 10000
    //             else
    //                 PurchLine."Line No." := 10000;
    //             PurchLine."Document Type" := PurchHeader."Document Type";
    //             PurchLine."Document No." := LastDocNo;
    //             PurchLine.Type := PurchLine.Type::Item;
    //             PurchLine.Validate("No.", IndentLine."Item No");
    //             PurchLine.Validate(Quantity, IndentLine.Quantity);
    //             PurchLine.Insert(true);
    //         until IndentLine.Next() = 0;
    //         // Rec.Post := true;
    //     end;
    // end;


    procedure CreateOrdersFromIndent(DocumentNo: Code[20])
    var
        IndentLine: Record "Consolidate indent Line";
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        CurrentStore: Code[20];
        CurrentSource: Code[20];
        LastPONo: Code[20];
        LastTransNo: Code[20];
        NoSeriesMgt: Codeunit NoSeriesManagement;
        PurchSetup: Record "Purchases & Payables Setup";
        InventorySetup: Record "Inventory Setup";
        NewNo: Code[20];
        LineNo: Integer;
    begin
        IndentLine.SetRange(" Document No.", DocumentNo);
        IndentLine.SetCurrentKey("Sourcing Method", Store, "Source Location No.");
        CurrentStore := '';
        CurrentSource := '';
        LastPONo := '';
        LastTransNo := '';
        if IndentLine.FindSet() then begin
            repeat
                case IndentLine."Sourcing Method" of
                    IndentLine."Sourcing Method"::Purchase:
                        begin
                            if (IndentLine.Store <> CurrentStore) or (IndentLine."Source Location No." <> CurrentSource) then begin
                                CurrentStore := IndentLine.Store;
                                CurrentSource := IndentLine."Source Location No.";

                                PurchSetup.Get();
                                PurchSetup.TestField("Order Nos.");
                                NewNo := NoSeriesMgt.GetNextNo(PurchSetup."Order Nos.", WORKDATE, true);

                                PurchHeader.Init();
                                PurchHeader."Document Type" := PurchHeader."Document Type"::Order;
                                PurchHeader."No." := NewNo;
                                PurchHeader.Validate("Posting Date", Rec."Delivery Date");
                                PurchHeader.Validate("Order Date", Rec."Delivery Date");
                                PurchHeader.Insert(true);
                                PurchHeader.Validate("Buy-from Vendor No.", CurrentSource);
                                PurchHeader.Validate("Location Code", CurrentStore);
                                PurchHeader.Validate("Indent No.", DocumentNo);
                                PurchHeader.Modify(true);

                                LastPONo := NewNo;
                                LineNo := 10000;

                                Message('PO %1 created for Vendor %2 at Store %3', NewNo, CurrentSource, CurrentStore);
                            end;
                            PurchLine.Init();
                            PurchLine."Document Type" := PurchHeader."Document Type";
                            PurchLine."Document No." := LastPONo;
                            PurchLine."Line No." := LineNo;
                            LineNo += 10000;
                            PurchLine.Type := PurchLine.Type::Item;
                            PurchLine.Validate("No.", IndentLine."Item No");
                            PurchLine.Validate(Quantity, IndentLine.Quantity);
                            PurchLine.Validate("Unit of Measure Code", IndentLine.UOM);
                            PurchLine.Insert(true);
                            IndentLine."Referance No." := LastPONo;
                            IndentLine.Modify();
                        end;

                    IndentLine."Sourcing Method"::Transfer:
                        begin
                            if (IndentLine.Store <> CurrentStore) or (IndentLine."Source Location No." <> CurrentSource) then begin
                                CurrentStore := IndentLine.Store;
                                CurrentSource := IndentLine."Source Location No.";
                                InventorySetup.Get();
                                InventorySetup.TestField("Transfer Order Nos.");
                                NewNo := NoSeriesMgt.GetNextNo(InventorySetup."Transfer Order Nos.", WORKDATE, true);

                                TransferHeader.Init();
                                TransferHeader."No." := NewNo;
                                TransferHeader.Validate("Posting Date", Rec."Delivery Date");
                                TransferHeader.Validate("Transfer-from Code", CurrentSource);
                                TransferHeader.Validate("Transfer-to Code", CurrentStore);
                                TransferHeader.Validate("Requistion No.", Rec."No.");
                                TransferHeader."In-Transit Code" := 'INTRANSIT1';
                                // TransferHeader.NO := 'INTRANSIT1';
                                TransferHeader.Insert(true);
                                LastTransNo := NewNo;
                                LineNo := 10000;


                            end;
                            TransferLine.Init();
                            TransferLine."Document No." := LastTransNo;
                            TransferLine."Line No." := LineNo;
                            LineNo += 10000;
                            TransferLine.Validate("Item No.", IndentLine."Item No");
                            TransferLine.Validate("Unit of Measure Code", IndentLine.UOM);
                            TransferLine.Validate(Quantity, IndentLine.Quantity);
                            TransferLine.Insert(true);
                            TransferLine.Validate("Transfer Price");//Aashish 10-09-2025
                            //IndentLine."Referance No." := NewNo;
                            IndentLine."Referance No." := LastTransNo;
                            IndentLine.Modify();
                        end;

                end;
            until IndentLine.Next() = 0;
            Rec.Post := true;
        end;
    end;


    trigger OnAfterGetRecord()
    var
        myInt: Integer;
    begin
        if Rec.Post = true then begin
            EditBool := false
        end
        else
            EditBool := true;
    end;

    trigger OnAfterGetCurrRecord()
    var
        myInt: Integer;
    begin
        if Rec.Post = true then begin
            EditBool := false
        end
        else
            EditBool := true;
    end;
}
