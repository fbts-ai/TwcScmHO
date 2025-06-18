
codeunit 51106 "Cost Adjustment Bucket Runner"
{
    TableNo = "Cost Adj. Item Bucket";

    trigger OnRun()
    var
        Item: Record Item;
        InventoryAdjustmentHandler: Codeunit "Inventory Adjustment Handler";
        UpdateItemAnalysisView: Codeunit "Update Item Analysis View";
        UpdateAnalysisView: Codeunit "Update Analysis View";
    begin
        // if not LockTables() then //Ashish-NS
        //     exit;

        Item.SetFilter("No.", Rec."Item Filter");
        InventoryAdjustmentHandler.SetFilterItem(Item);
        InventoryAdjustmentHandler.MakeInventoryAdjustment(false, Rec."Post to G/L");

        if Rec."Post to G/L" then
            UpdateAnalysisView.UpdateAll(0, true);
        UpdateItemAnalysisView.UpdateAll(0, true);
    end;

    local procedure LockTables(): Boolean
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        ItemApplicationEntry: Record "Item Application Entry";
        AvgCostEntryPointHandler: Codeunit "Avg. Cost Entry Point Handler";
    begin
        // //Ashish-NS  ItemApplicationEntry.LockTable();
        if ItemApplicationEntry.GetLastEntryNo() = 0 then
            exit(false);

        // //Ashish-NS  ItemLedgerEntry.LockTable();
        if ItemLedgerEntry.GetLastEntryNo() = 0 then
            exit(false);

        // //Ashish-NS ValueEntry.LockTable();
        if ValueEntry.GetLastEntryNo() = 0 then
            exit(false);

        AvgCostEntryPointHandler.LockBuffer();

        exit(true);
    end;
}