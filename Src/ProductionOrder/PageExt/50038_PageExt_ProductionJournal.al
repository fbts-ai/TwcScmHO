pageextension 50038 ProductionJournalExt extends "Production Journal"
{
    layout
    {
        // Add changes to page layout here






        addafter("Scrap Quantity")
        {
            field(ProdutionOrderRemark; Rec.ProdutionOrderRemark)
            {
                caption = 'Production Order Remark';
            }
        }
        modify(Quantity) //PT-FBTS -16-10-24
        {
            Editable = EditBool;


            trigger OnAfterValidate()
            var
                ProdOrderCmponent: Record "Prod. Order Component";
                InvSetup: Record "Inventory Setup";
            begin
                //Gaurav_FBTS++
                InvSetup.Get();
                ProdOrderCmponent.Reset();
                ProdOrderCmponent.SetRange("Prod. Order No.", Rec."Document No.");
                ProdOrderCmponent.SetRange("Item No.", Rec."Item No.");
                if ProdOrderCmponent.FindFirst() then begin

                    // Ensure quantities are compared as expected
                    if (Rec.Quantity > ProdOrderCmponent."Expected Quantity" * (100 + InvSetup."Max. Quantity Percent") / 100) then
                        Error('You cannot enter more than the maximum quantity.')

                    else
                        if (Rec.Quantity < ProdOrderCmponent."Expected Quantity" * (100 - InvSetup."Min. Quantity Percent") / 100) then
                            Error('You cannot enter less than the minimum quantity.');
                end;
                //Gaurav_FBTS--

            End;
        }
        modify("Output Quantity")
        {
            Editable = false;
        }
        //PT-FBTS -16-10-24
    }

    actions
    {
        // Add changes to page actions here

        modify(Post)
        {
            trigger OnBeforeAction()
            var
                tempprodjournal: Record "Item Journal Line";
            begin
                tempprodjournal.Reset();
                tempprodjournal.SetRange("Document No.", Rec."Document No.");
                tempprodjournal.SetRange(ProdutionOrderQtyChanged, true);
                tempprodjournal.SetFilter("Entry Type", '=%1', Rec."Entry Type"::Consumption);
                tempprodjournal.SetFilter(ProdutionOrderRemark, '=%1', '');
                IF tempprodjournal.FindFirst() then
                    Error('You have changed the qty on line , you must enter production remark for change aty line');


            end;


        }

        addfirst("&Line")
        {
            group(AutoLotAssignmentGroup)
            {
                action(AutoLotAssignment)
                {

                    caption = '&AutoLotAssignment';
                    ApplicationArea = All;
                    Promoted = true;
                    Image = AutoReserve;

                    trigger OnAction();
                    var
                        ReservEntry: Record "Reservation Entry";
                        CreateReservEntry: Codeunit "Create Reserv. Entry";
                        TempProductionJournalLine: Record "Item Journal Line";
                        TempIetm: Record Item;
                        ProductionJournalCodeunit: Codeunit AllSCMCustomization;
                        ILE: Record "Item Ledger Entry";
                        TotalQty: Decimal;
                        qty_qtyBase: Decimal;
                        TotalQtytoShipBase: Decimal;
                        TotalQtytoReceiveBase: Decimal;
                        ILE1: Record "Item Ledger Entry";
                        qtyCount: Decimal;
                        TempReservationEntry: Record "Reservation Entry";
                        ValidateReservationEntry: Record "Reservation Entry";

                    begin
                        //validation to check 
                        ValidateReservationEntry.Reset;
                        ValidateReservationEntry.SetRange(AutoLotDocumentNo, Rec."Document No.");

                        if ValidateReservationEntry.FindFirst() then
                            Error('Lot is already assigned for this document , if you want to reassign lotno please delete a existing line first');
                        //
                        TempProductionJournalLine.Reset();
                        TempProductionJournalLine.SetRange("Journal Template Name", rec."Journal Template Name");
                        TempProductionJournalLine.SetRange("Journal Batch Name", rec."Journal Batch Name");
                        TempProductionJournalLine.SetFilter("Order Type", '=%1', Rec."Order Type"::Production);
                        TempProductionJournalLine.SetRange("Order No.", rec."Order No.");
                        //TempProductionJournalLine.SetFilter("Entry Type", '=%1', rec."Entry Type"::Consumption);
                        if TempProductionJournalLine.FindSet() then
                            repeat
                                ValidateReservationEntry.Reset();
                                ValidateReservationEntry.SetRange("Source ID", Rec."Journal Template Name");
                                ValidateReservationEntry.SetRange("Source Batch Name", Rec."Journal Batch Name");
                                ValidateReservationEntry.SetRange("Source Ref. No.", TempProductionJournalLine."Line No.");
                                IF not ValidateReservationEntry.FindFirst() then Begin


                                    TotalQty := TempProductionJournalLine.Quantity * TempProductionJournalLine."Qty. per Unit of Measure";
                                    TotalQtytoShipBase := (TempProductionJournalLine.Quantity * TempProductionJournalLine."Qty. per Unit of Measure");// TempTransferLine."Qty. to Ship (Base)";
                                    TotalQtytoReceiveBase := (TempProductionJournalLine.Quantity * TempProductionJournalLine."Qty. per Unit of Measure");//TempTransferLine."Qty. to Receive (Base)";
                                    IF TempIetm.Get(TempProductionJournalLine."Item No.") then;
                                    if TempIetm."Item Tracking Code" <> '' then Begin
                                        IF TempProductionJournalLine."Entry Type" = TempProductionJournalLine."Entry Type"::Consumption then begin

                                            //Validation for insuffient qty 
                                            qtyCount := 0;
                                            ILE1.Reset();
                                            ILE1.SetRange("Item No.", TempIetm."No.");
                                            ILE1.SetRange("Location Code", TempProductionJournalLine."Location Code");
                                            ILE1.SetRange(Open, true);
                                            ILE1.SetFilter("Remaining Quantity", '>%1', 0);
                                            ILE1.SetFilter("Lot No.", '<>%1', '');
                                            IF ILE1.FindFirst() then
                                                repeat
                                                    qtyCount := qtyCount + ILE1."Remaining Quantity";
                                                Until ILE1.Next() = 0;

                                            If qtyCount < (TempProductionJournalLine.Quantity * TempProductionJournalLine."Qty. per Unit of Measure") then
                                                Error('Qty available in Lot and Qty enter is less , please reduce a qty available for Item %1', TempProductionJournalLine."Item No.");
                                            //Validation end

                                            //reservation entry creation
                                            ILE.Reset();
                                            ILE.SetCurrentKey("Entry No.");
                                            ILE.SetAscending("Entry No.", true);
                                            ILE.SetRange("Item No.", TempIetm."No.");
                                            ILE.SetRange("Location Code", TempProductionJournalLine."Location Code");
                                            ILE.SetRange(Open, true);
                                            ILE.SetFilter("Remaining Quantity", '>%1', 0);
                                            ILE.SetFilter("Lot No.", '<>%1', '');
                                            IF ILE.FindFirst() then
                                                repeat
                                                    IF TotalQty > 0 then Begin
                                                        If ILE."Remaining Quantity" >= TotalQty then begin
                                                            qty_qtyBase := TotalQty;//TotalQty * TempProductionJournalLine."Qty. per Unit of Measure";
                                                            TotalQtytoShipBase := TotalQtytoShipBase;//TotalQty * TempProductionJournalLine."Qty. per Unit of Measure";
                                                            TotalQtytoReceiveBase := TotalQtytoReceiveBase;// TotalQty * TempProductionJournalLine."Qty. per Unit of Measure";
                                                            ProductionJournalCodeunit.AutolotProductionJornalReservEntry(TempProductionJournalLine, ILE."Lot No.",
                                                            TotalQty, qty_qtyBase, TotalQtytoShipBase, TotalQtytoReceiveBase, ILE."Expiration Date");
                                                            TotalQty := 0;
                                                            TotalQtytoReceiveBase := 0;
                                                            TotalQtytoReceiveBase := 0;
                                                        end else
                                                            if (ILE."Remaining Quantity" < TotalQty) then begin
                                                                qty_qtyBase := ILE."Remaining Quantity";// * TempProductionJournalLine."Qty. per Unit of Measure";
                                                                ProductionJournalCodeunit.AutolotProductionJornalReservEntry(TempProductionJournalLine, ILE."Lot No.", ILE."Remaining Quantity",
                                                                qty_qtyBase, qty_qtyBase, qty_qtyBase, ILE."Expiration Date");
                                                                TotalQty := TotalQty - ILE."Remaining Quantity";
                                                                TotalQtytoShipBase := TotalQtytoShipBase - qty_qtyBase;
                                                                TotalQtytoReceiveBase := TotalQtytoReceiveBase - qty_qtyBase
                                                            end;
                                                    End;
                                                Until ILE.Next() = 0;

                                        end;
                                        IF TempProductionJournalLine."Entry Type" = TempProductionJournalLine."Entry Type"::Output then begin
                                            ProductionJournalCodeunit.AutolotProductionJornalOutputReservEntry(TempProductionJournalLine);
                                        end;
                                    End;
                                End;
                            Until TempProductionJournalLine.next() = 0;

                        Message('Auto Lot no assigned successfully');

                    end;
                }
            }

        }
    }

    var
        myInt: Integer;
        EditBool: Boolean;

    trigger OnDeleteRecord(): Boolean //PTFBTS // 11-09-24
    var
        myInt: Integer;
    begin
        Error('You can not delete this documnet');
    end;

    trigger OnAfterGetRecord()
    var
        LocationRec: Record Location;
    begin
        If LocationRec.Get(Rec."Location Code") then begin
            if LocationRec."Consumption Qty change Allow" = true then begin
                EditBool := true;
            end
            else
                EditBool := false;
        end;

    end;

    trigger OnOpenPage()
    var
        LocationRec: Record Location;
    begin
        If LocationRec.Get(Rec."Location Code") then begin
            if LocationRec."Consumption Qty change Allow" = true then begin
                EditBool := true;
            end
            else
                EditBool := false;
        end;

    end;

}