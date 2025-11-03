codeunit 50102 "Transaction Sales Summary"
{
    procedure InsertOrUpdateTransactionSummary(DateColumn: Date; StoreNo: Code[20]; ItemNo: Code[20]; SalesQuantity: Decimal; SalesQuantityHO: Decimal)
    var
        CustomTableRec: Record "Transaction Summary";
        EntryNo: Integer;
        ItemBOMRec: Record "BOM Component";
    begin

        ItemBOMRec.Reset();
        ItemBOMRec.SetRange("Parent Item No.", ItemNo);

        if ItemBOMRec.FindSet() then begin

            repeat
                InsertOrUpdateOne(DateColumn, StoreNo, ItemNo, ItemBOMRec."No.", ItemBOMRec."Parent Item No.", SalesQuantity, SalesQuantityHO, ItemBOMRec."Quantity per");
            until ItemBOMRec.Next() = 0;
        end else begin
            InsertOrUpdateOne(DateColumn, StoreNo, ItemNo, ItemNo, ItemNo, SalesQuantity, SalesQuantityHO, SalesQuantityHO);
        end;
    end;

    local procedure InsertOrUpdateOne(DateColumn: Date; StoreNo: Code[20]; ItemNo: Code[20]; BOMItemNo: Code[20]; ParentItemNo: Code[20]; SalesQuantity: Decimal; SalesQuantityHO: Decimal; BOMQtyPer: Decimal)
    var
        CustomTableRec: Record "Transaction Summary";
        EntryNo: Integer;
        I_Uom: Record "Item Unit of Measure";
        BOMRec: Record 90;
        QtyPer: Decimal;
    begin
        CustomTableRec.Reset();
        CustomTableRec.SetRange("Store No.", StoreNo);
        CustomTableRec.SetRange("Date", DateColumn);
        CustomTableRec.SetRange("Item No.", ItemNo);
        CustomTableRec.SetRange("BOM Item", BOMItemNo);

        if CustomTableRec.FindFirst() then begin
            if SalesQuantity <> 0 then
                CustomTableRec.Quantity := Abs(SalesQuantity);
            if SalesQuantityHO <> 0 then
                CustomTableRec.QuantityHO := SalesQuantityHO;
            CustomTableRec.Modify();
        end else begin
            if CustomTableRec.FindLast() then
                EntryNo := CustomTableRec."Entry No." + 1
            else
                EntryNo := 1;

            CustomTableRec.Init();
            CustomTableRec."Entry No." := EntryNo;
            CustomTableRec."Store No." := StoreNo;
            CustomTableRec."Date" := DateColumn;
            CustomTableRec."Item No." := ItemNo;
            CustomTableRec."BOM Item" := BOMItemNo;
            CustomTableRec."Parent Item No" := ParentItemNo;

            if SalesQuantity <> 0 then
                CustomTableRec.Quantity := Abs(SalesQuantity);
            if SalesQuantityHO <> 0 then
                CustomTableRec.QuantityHO := SalesQuantityHO;
            CustomTableRec."BOM Qty Per" := BOMQtyPer;
            BOMRec.SetRange("No.", BOMItemNo);
            if BOMRec.FindFirst() then begin
                CustomTableRec."BOM Unit Of Measure" := BOMRec."Unit of Measure Code";
            end;
            I_Uom.Reset();
            I_Uom.SetRange("Item No.", BOMItemNo);
            I_Uom.SetRange(Code, CustomTableRec."BOM Unit Of Measure");
            if I_Uom.FindFirst() then
                QtyPer := I_Uom."Qty. per Unit of Measure";

            CustomTableRec."Sale Quantity" := BOMQtyPer * CustomTableRec.Quantity * QtyPer;
            CustomTableRec.Insert();
        end;
    end;

    var
        myInt: Integer;
}
