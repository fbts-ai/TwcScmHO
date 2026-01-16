codeunit 50100 "All Event Subs"
{
    trigger OnRun()
    begin

    end;

    //Insert into Item Ledger Entry
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforeInsertItemLedgEntry', '', false, false)]
    local procedure OnBeforeInsertItemLedgEntry(var ItemLedgerEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line"; TransferItem: Boolean; OldItemLedgEntry: Record "Item Ledger Entry"; ItemJournalLineOrigin: Record "Item Journal Line")
    begin
        ItemLedgerEntry."Reason Code" := ItemJournalLine."Reason Code";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnValidateItemNoOnBeforeValidateUnitOfmeasureCode', '', false, false)]
    local procedure OnValidateItemNoOnBeforeValidateUnitOfmeasureCode(var ItemJournalLine: Record "Item Journal Line"; var Item: Record Item; CurrFieldNo: Integer; xItemJournalLine: Record "Item Journal Line");
    begin
        Item.CalcFields(Inventory);
        ItemJournalLine."Stock in Hand" := Item.Inventory;
    end;

    // [EventSubscriber(ObjectType::Page, Page::"Item Journal", 'OnBeforeOpenJournal', '', false, false)]
    // local procedure OnBeforeOpenJournal(var ItemJournalLine: Record "Item Journal Line"; var ItemJnlMgt: Codeunit ItemJnlManagement; CurrentJnlBatchName: Code[10]; var IsHandled: Boolean)
    // var
    //     ItemJnlBatch: Record "Item Journal Batch";
    //     LSCUserSetup: Record "LSC Retail User";
    //     JnlSelected: Boolean;
    // begin
    //     ItemJnlMgt.OpenJnlBatch(ItemJnlBatch);
    //     // if ItemJournalLine."Journal Template Name" = 'ITEM' then begin
    //     //     LSCUserSetup.Get(UserId);
    //     //     ItemJnlBatch.SetRange("Journal Template Name", 'ITEM');
    //     //     ItemJnlBatch.SetRange("Location Code", LSCUserSetup."Location Code");
    //     //     if ItemJnlBatch.FindFirst() then begin
    //     //         CurrentJnlBatchName := ItemJnlBatch.Name;
    //     //         ItemJournalLine."Journal Batch Name" := ItemJnlBatch.Name;
    //     //     end;
    //     //     ItemJnlMgt.TemplateSelection(PAGE::"Item Journal", 0, false, ItemJournalLine, JnlSelected);
    //     //     ItemJnlMgt.OpenJnl(CurrentJnlBatchName, ItemJournalLine);
    //     // end;
    // end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ItemJnlManagement, 'OnBeforeOpenJnl', '', false, false)]
    local procedure OnBeforeOpenJnl(var CurrentJnlBatchName: Code[10]; var ItemJnlLine: Record "Item Journal Line")
    var
        ItemJnlBatch: Record "Item Journal Batch";
        LSCUserSetup: Record "LSC Retail User";
    begin

        LSCUserSetup.Get(UserId);
        ItemJnlBatch.SetRange("Journal Template Name", 'ITEM');
        ItemJnlBatch.SetRange("Location Code", LSCUserSetup."Location Code");
        if ItemJnlBatch.FindFirst() then begin
            CurrentJnlBatchName := ItemJnlBatch.Name;
            // ItemJnlLine."Journal Batch Name" := ItemJnlBatch.Name;
        end;
    end;

    var
        myInt: Codeunit 22;
}