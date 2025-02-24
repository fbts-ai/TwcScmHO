pageextension 50171 AssemblySubformExt extends "Assembly Order Subform"
{
    layout
    {
        // Add changes to page layout here
        modify("No.")
        {
            trigger OnAfterValidate()
            var
                ItemRec: Record Item;
            begin
                // ItemRec.Reset();
                // ItemRec.SetRange("No.", Rec."No.");
                // ItemRec.SetRange("AssemblyProd.", false);
                // if ItemRec.FindFirst() then
                //     Error('');
            end;
        }

    }

    actions
    {
        // Add changes to page actions here
        addafter("&Line")
        {
            group(AutoLotAssignment) //PT-FBTS
            {
                action(AutoLotAssignAssembly)
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'AutoLotAssignAssembly';
                    Image = Shipment;

                    ShortCutKey = 'Ctrl+Alt+I';
                    ToolTip = 'View or edit serial numbers and lot numbers that are assigned to the item on the document or journal line.';
                    trigger OnAction()
                    var
                        ReservEntry: Record "Reservation Entry";
                        // CreateReservEntry: Codeunit "Create Reserv. Entry";
                        TempTransferLine: Record "Assembly Line";
                        TempIetm: Record Item;
                        Intestorecodeunit: Codeunit AllSCMCustomization;
                        ILE: Record "Item Ledger Entry";
                        TotalQty: Decimal;
                        qty_qtyBase: Decimal;
                        TotalQtytoShipBase: Decimal;
                        TotalQtytoReceiveBase: Decimal;
                        ILE1: Record "Item Ledger Entry";
                        qtyCount: Decimal;
                        ValidateReservationEntry: Record "Reservation Entry";

                    begin

                        //validation to check 
                        ValidateReservationEntry.Reset;
                        ValidateReservationEntry.SetRange(AutoLotDocumentNo, Rec."Document No.");
                        if ValidateReservationEntry.FindFirst() then
                            Error('Lot is already assigned for this document , if you want to reassign lotno please delete a existing line first');
                        //
                        TempTransferLine.Reset();
                        TempTransferLine.SetRange("Document No.", Rec."Document No.");
                        if TempTransferLine.FindSet() then
                            repeat
                                ValidateReservationEntry.Reset();
                                ValidateReservationEntry.SetRange("Source ID", TempTransferLine."Document No.");
                                ValidateReservationEntry.SetRange("Source Ref. No.", TempTransferLine."Line No.");
                                IF not ValidateReservationEntry.FindFirst() then begin
                                    TotalQty := TempTransferLine.Quantity * TempTransferLine."Qty. per Unit of Measure";
                                    TotalQtytoShipBase := (TempTransferLine.Quantity * TempTransferLine."Qty. per Unit of Measure");// TempTransferLine."Qty. to Ship (Base)";
                                    TotalQtytoReceiveBase := (TempTransferLine.Quantity * TempTransferLine."Qty. per Unit of Measure");//TempTransferLine."Qty. to Receive (Base)";
                                    IF TempIetm.Get(TempTransferLine."No.") then;
                                    if TempIetm."Item Tracking Code" <> '' then Begin


                                        //Validation for insuffient qty 
                                        qtyCount := 0;
                                        ILE1.Reset();
                                        ILE1.SetRange("Item No.", TempIetm."No.");
                                        ILE1.SetRange("Location Code", TempTransferLine."Location Code");
                                        ILE1.SetRange(Open, true);
                                        ILE1.SetFilter("Remaining Quantity", '>%1', 0);
                                        ILE1.SetFilter("Lot No.", '<>%1', '');
                                        IF ILE1.FindFirst() then
                                            repeat
                                                qtyCount := qtyCount + ILE1."Remaining Quantity";
                                            Until ILE1.Next() = 0;
                                        If qtyCount < (TempTransferLine.Quantity * TempTransferLine."Qty. per Unit of Measure") then
                                            Error('Qty available in Lot and Qty enter online is less , please reduce a qty available for item %1', TempTransferLine."No.");
                                        //Validation end

                                        //reservation entry creation
                                        ILE.Reset();
                                        ILE.SetRange("Item No.", TempIetm."No.");
                                        ILE.SetRange("Location Code", TempTransferLine."Location Code");
                                        ILE.SetRange(Open, true);
                                        ILE.SetFilter("Remaining Quantity", '>%1', 0);
                                        ILE.SetFilter("Lot No.", '<>%1', '');
                                        IF ILE.FindFirst() then
                                            repeat
                                                IF TotalQty > 0 then Begin
                                                    If ILE."Remaining Quantity" >= TotalQty then begin
                                                        qty_qtyBase := TotalQty;// * TempTransferLine."Qty. per Unit of Measure";
                                                        TotalQtytoShipBase := TotalQtytoShipBase;//TotalQty * TempTransferLine."Qty. per Unit of Measure";
                                                        TotalQtytoReceiveBase := TotalQtytoReceiveBase;//TotalQty * TempTransferLine."Qty. per Unit of Measure";
                                                        Intestorecodeunit.InterstoreReservationEntryAssembly(TempTransferLine, ILE."Lot No.",
                                                        TotalQty, qty_qtyBase, TotalQtytoShipBase, TotalQtytoReceiveBase, ILE."Expiration Date", ILE.ManufacturingDate);
                                                        TotalQty := 0;
                                                        TotalQtytoReceiveBase := 0;
                                                        TotalQtytoReceiveBase := 0;
                                                    end else
                                                        if (ILE."Remaining Quantity" < TotalQty) then begin
                                                            qty_qtyBase := ILE."Remaining Quantity";// * TempTransferLine."Qty. per Unit of Measure";
                                                            Intestorecodeunit.InterstoreReservationEntryAssembly(TempTransferLine, ILE."Lot No.", ILE."Remaining Quantity",
                                                            qty_qtyBase, qty_qtyBase, qty_qtyBase, ILE."Expiration Date", ILE.ManufacturingDate);
                                                            TotalQty := TotalQty - ILE."Remaining Quantity";
                                                            TotalQtytoShipBase := TotalQtytoShipBase - qty_qtyBase;
                                                            TotalQtytoReceiveBase := TotalQtytoReceiveBase - qty_qtyBase
                                                        end;
                                                End;
                                            Until ILE.Next() = 0;

                                    end;
                                end;
                            Until TempTransferLine.next() = 0;

                        Message('Auto Lot no assigned successfully');


                    end;
                }

            }


        }


    }

    trigger OnAfterGetRecord()
    var
        UserSetup: Record "User Setup";

    begin
        if UserSetup.Get(UserId) then begin
            if UserSetup."Assembly Production" = false then begin
                CurrPage.Editable(false);
            end else
                if UserSetup."Assembly Production" = true then
                    CurrPage.Editable(true);
        end;
    end;

    trigger OnAfterGetCurrRecord()
    var
        UserSetup: Record "User Setup";

    begin
        if UserSetup.Get(UserId) then begin
            if UserSetup."Assembly Production" = false then begin
                CurrPage.Editable(false);
            end else
                if UserSetup."Assembly Production" = true then
                    CurrPage.Editable(true);
        end;
    end;

    trigger OnOpenPage()
    var
        UserSetup: Record "User Setup";
    begin
        if UserSetup.Get(UserId) then begin
            if UserSetup."Assembly Production" = false then begin
                CurrPage.Editable(false);
            end else
                if UserSetup."Assembly Production" = true then
                    CurrPage.Editable(true);
        end;

    end;


    var
        EditBool: Boolean;
}