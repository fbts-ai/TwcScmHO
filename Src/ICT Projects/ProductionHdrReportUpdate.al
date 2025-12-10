report 50014 ProductionMarkedFinish_ICT
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

                if (Qty <> 0) AND (FinishQty <> 0) THEN begin
                    if Qty = FinishQty then begin
                        Status := Status::Finished;
                        Modify();
                    end;
                end;
            end;
        }
    }

}