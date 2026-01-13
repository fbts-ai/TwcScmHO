report 50015 ProdFinish_SubConSkip_ICT
{
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;
    UseRequestPage = false;

    dataset
    {
        dataitem("Production Order"; "Production Order")
        {
            DataItemTableView = where(Status = const(released));
            trigger OnPreDataItem()
            begin
                SetFilter("Due Date", '%1..', 20251201D);
            end;

            trigger OnAfterGetRecord()
            var
                ProductionLine: Record "Prod. Order Line";
                Qty: Decimal;
                FinishQty: Decimal;
                // Pro : Page 99000831
                ProCU: Codeunit "Prod. Order Status Management";
                NewStatus: Enum "Production Order Status";
                Skip: Boolean;
                l_ProductionLine: Record "Prod. Order Line";
            begin
                Qty := 0;
                FinishQty := 0;
                ProductionLine.Reset();
                ProductionLine.SetRange("Prod. Order No.", "No.");
                if ProductionLine.FindFirst() then
                    repeat
                        Qty += ProductionLine.Quantity;
                        FinishQty += ProductionLine."Finished Quantity";
                    until ProductionLine.next = 0;

                Skip := false;
                l_ProductionLine.Reset();
                l_ProductionLine.SetRange("Prod. Order No.", "No.");
                l_ProductionLine.SetFilter("Subcontracting Order No.", '<>%1', '');
                IF l_ProductionLine.FindFirst() then
                    Skip := true;

                If Not Skip then BEGIN
                    if (Qty <> 0) AND (FinishQty <> 0) THEN begin
                        if Qty = FinishQty then begin
                            // "Production Order".Status := "Production Order".Status::Finished;
                            // "Production Order".Modify();
                            ProCU.ChangeProdOrderStatus("Production Order", NewStatus::Finished, Today, false);
                            Commit();
                        end;
                    end;
                end;
            end;
        }
    }

}