codeunit 50039 Flow_TOILE
{
    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforeInsertItemLedgEntry', '', false, false)]
    local procedure OnBeforeInsertItemLedgEntry(var ItemLedgerEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line"; TransferItem: Boolean; OldItemLedgEntry: Record "Item Ledger Entry"; ItemJournalLineOrigin: Record "Item Journal Line")
    var
    //GetCode: Codeunit 50038;
    begin
        ItemLedgerEntry.Remarks := ItemJournalLine.Remarks;
        ItemLedgerEntry."Quarantine Location" := ItemJournalLine."Quarantine Location Boolean";
        ItemLedgerEntry.Approver := ItemJournalLine.Approver;//AJ_ALLE_24012024
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnBeforePostItemJournalLine', '', false, false)]
    local procedure OnBeforePostItemJournalLineShip(var ItemJournalLine: Record "Item Journal Line"; TransferLine: Record "Transfer Line"; CommitIsSuppressed: Boolean)
    var
        TransferHeader: Record "Transfer Header";
    begin
        if TransferHeader.Get(TransferLine."Document No.") then begin
            if TransferHeader."Quaratine Location" = true then begin
                ItemJournalLine.Remarks := TransferLine.Remarks;
                ItemJournalLine."Quarantine Location Boolean" := true;
                ItemJournalLine.Approver := TransferHeader."Assigned User ID";//AJ_ALLE_24012024
            end;
        end;
    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt1", 'OnBeforePostItemJournalLine', '', false, false)]
    local procedure OnBeforePostItemJournalLine(TransferLine: Record "Transfer Line"; var ItemJournalLine: Record "Item Journal Line")
    var
        TransferHeader: Record "Transfer Header";
    begin
        if TransferHeader.Get(TransferLine."Document No.") then begin
            if TransferHeader."Quaratine Location" = true then begin
                ItemJournalLine.Remarks := TransferLine.Remarks;
                ItemJournalLine."Quarantine Location Boolean" := true;
                ItemJournalLine.Approver := TransferHeader."Assigned User ID";//AJ_ALLE_24012024
            end;
        end;
    end;



    var
        myInt: page "Order Address List";

    var


}