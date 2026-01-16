pageextension 51115 ItemJournal extends "Item Journal"
{
    layout
    {
        // Add changes to page layout here
        addbefore(Quantity)
        {
            field("Stock in Hand"; Rec."Stock in Hand")
            {
                ApplicationArea = all;
                Editable = false;
            }
            field("Line No."; Rec."Line No.")
            { }


        }//PT-FBTS-22-12-2025
    }

    actions
    {
        // Add changes to page actions here
        modify(Post)
        {
            trigger OnBeforeAction()
            var
                ItemJnlLine: Record "Item Journal Line";
            begin
                ItemJnlLine.SetRange("Journal Template Name", Rec."Journal Template Name");
                ItemJnlLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
                ItemJnlLine.SetRange("LSC InStore-Created Entry", false);//181225
                if ItemJnlLine.FindSet() then
                    repeat
                        ItemJnlLine.TestField("Reason Code");
                    until ItemJnlLine.Next() = 0;
            end;
        }
        addafter(Post)
        {
            action("Assign Lot No.")
            {
                ApplicationArea = all;
                Image = Lot;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    ItemJnl: Record "Item Journal Line";
                begin
                    PostWastageEntry();
                end;
            }
            action("Send for Wastage Approval")
            {
                ApplicationArea = all;
                Image = ApplyEntries;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    SendForApproval();
                end;
            }
        }
    }

    // trigger OnOpenPage()
    // var
    //     ItemJnlBatch: Record "Item Journal Batch";
    //     LSCUserSetup: Record "LSC Retail User";
    // begin
    //     if Rec."Journal Template Name" = 'ITEM' then begin
    //         LSCUserSetup.Get(UserId);
    //         ItemJnlBatch.SetRange("Journal Template Name", 'ITEM');
    //         ItemJnlBatch.SetRange("Location Code", LSCUserSetup."Location Code");
    //         if ItemJnlBatch.FindFirst() then
    //             Rec."Journal Batch Name" := ItemJnlBatch.Name;
    //         CurrPage.Update(true);
    //     end;
    // end;

    // local procedure StockInHand()
    // var
    //     ItemInv: Record Item;
    // begin
    //     ItemInv.Get(Rec."Item No.");
    //     ItemInv.CalcFields(Inventory);

    //     Rec."Stock in Hand" := ItemInv.Inventory;
    // end;

    procedure PostWastageEntry()
    var
        ItemJnlBatch: Record "Item Journal Batch";
        LSCUserSetup: Record "LSC Retail User";
        ILE: Record "Item Ledger Entry";
    begin
        LSCUserSetup.Get(UserId);
        ItemJnlBatch.SetRange("Journal Template Name", 'ITEM');
        ItemJnlBatch.SetRange("Location Code", LSCUserSetup."Location Code");
        if ItemJnlBatch.FindFirst() then;

        ItemJnlLine.Reset();
        ItemJnlLine.SetRange("Journal Template Name", 'ITEM');
        ItemJnlLine.SetRange("Journal Batch Name", ItemJnlBatch.Name);
        // ItemJnlLine.SetRange(IsQRBundleGenerated, false);        //***
        ItemJnlLine.SetFilter(Quantity, '<>%1', 0);
        if ItemJnlLine.FindSet() then
            repeat
                ItemJnlLine.TestField("Item No.");

                if Item.Get(ItemJnlLine."Item No.") then begin
                    if Item."Item Tracking Code" <> '' then begin

                        ReservationEntry.Init();
                        if ReservationEntry.FindLast() then
                            Entry := ReservationEntry."Entry No." + 1
                        else
                            Entry := 1;
                        ReservationEntry."Entry No." := Entry;
                        ReservationEntry.Positive := false;
                        ReservationEntry.validate("Item No.", ItemJnlLine."Item No.");
                        ReservationEntry.Validate("Location Code", ItemJnlLine."Location Code");
                        ReservationEntry.Validate("Quantity (Base)", ItemJnlLine."Quantity (Base)");
                        ReservationEntry.Validate("Reservation Status", ReservationEntry."Reservation Status"::Prospect);
                        ReservationEntry.Validate("Creation Date", WorkDate());
                        ReservationEntry.Validate("Expected Receipt Date", WorkDate());
                        ReservationEntry.Validate("Source Type", 83);
                        ReservationEntry.Validate("Source Subtype", 3);     //*** 3 by EY
                        ReservationEntry.Validate("Source ID", ItemJnlLine."Journal Template Name");
                        ReservationEntry.Validate("Source Batch Name", ItemJnlLine."Journal Batch Name");
                        ReservationEntry."Source Ref. No." := ItemJnlLine."Line No.";
                        ReservationEntry.Validate("Item Tracking", ReservationEntry."Item Tracking"::"Lot No.");
                        // if ItemJnlLine."Opening Lot No." <> '' then
                        //     ReservationEntry.Validate("Lot No.", ItemJnlLine."Opening Lot No.")
                        // else //begin
                        // if NoSeries.Get(Item."Lot No. Profile Code 08 FDW") then

                        // ILE.SetRange("Item No.", ItemJnlLine."No.");
                        // ILE.SetRange("Location Code", ItemJnlLine."Location Code");
                        // ILE.SetRange(Open, true);
                        // ILE.SetFilter("Remaining Quantity", '>%1', 0);
                        // ILE.SetFilter("Lot No.", '<>%1', '');
                        // if ILE.find
                        ReservationEntry.Validate("Lot No.", ItemJnlLine."Lot No.");
                        //end;
                        ReservationEntry.Validate("Warranty Date", ItemJnlLine."Warranty Date");

                        ReservationEntry.Insert();
                        Commit();
                    end;
                end;
            // ItemJnlLine.IsQRBundleGenerated := true;  //***
            until ItemJnlLine.Next() = 0;
    end;

    local procedure SendForApproval()
    var
        UserSetup: Record "User Setup";
        ItemJournalLine: Record "Item Journal Line";
        ItemJnlBatch: Record "Item Journal Batch";
        LSCUserSetup: Record "LSC Retail User";
        TempTransactionHeader: Record "LSC Transaction Header";
        TransHead: Record "LSC Transaction Header";
        TotalAmount, TodaysSales, totalPercentageValue : Decimal;
        EmailCodeunit: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        MessageBody, Subject : Text;

    begin
        LSCUserSetup.Get(UserId);
        ItemJnlBatch.SetRange("Journal Template Name", 'ITEM');
        ItemJnlBatch.SetRange("Location Code", LSCUserSetup."Location Code");
        if ItemJnlBatch.FindFirst() then;

        ItemJournalLine.SetRange("Journal Template Name", 'ITEM');
        ItemJournalLine.SetRange("Journal Batch Name", ItemJnlBatch.Name);
        if ItemJournalLine.FindSet() then
            repeat
                ItemJournalLine.Testfield("Reason Code");
            until ItemJournalLine.Next() = 0;

        //**********
        UserSetup.get(UserId);
        if not UserSetup.SkipEODValidation then begin
            TempTransactionHeader.Reset();
            TempTransactionHeader.SetRange(TempTransactionHeader.Date, Rec."Posting date");
            TempTransactionHeader.SetRange(TempTransactionHeader."Store No.", Rec."Location Code");
            TempTransactionHeader.SetFilter(TempTransactionHeader."Transaction Type", '=%1', TempTransactionHeader."Transaction Type"::Sales);
            TempTransactionHeader.SetFilter(TempTransactionHeader."Posted Statement No.", '=%1', '');
            TempTransactionHeader.SetFilter(TempTransactionHeader."Entry Status", '<>%1&<>%2', TempTransactionHeader."Entry Status"::Voided, TempTransactionHeader."Entry Status"::Training);
            IF TempTransactionHeader.FindFirst() then
                Error('Statement posting has not finsihed for this date %1. Please post statement first', Format(Rec."Posting date"));
        end;

        //*****************
        IF Confirm('Do you want to submit this order for approval?', false) then begin
            IF Rec.Status = Rec.Status::Open then begin
                ItemJournalLine.Reset();
                ItemJournalLine.SetRange("Journal Template Name", 'ITEM');
                ItemJournalLine.SetRange("Journal Batch Name", ItemJnlBatch.Name);
                if ItemJournalLine.FindSet() then
                    repeat
                        TotalAmount += ItemJournalLine.Quantity;
                    until ItemJournalLine.Next() = 0;

                //************
                TransHead.Reset();
                TransHead.SetRange(TransHead.Date, Rec."Posting date");
                TransHead.SetRange("Store No.", Rec."Location Code");
                TransHead.SetRange("Transaction Type", TransHead."Transaction Type"::Sales);
                TransHead.SetRange("Sale Is Return Sale", false);
                IF TransHead.FindSet() then Begin
                    repeat
                        TodaysSales := TodaysSales + ABS(TransHead."Gross Amount");
                    until TransHead.next() = 0;
                End;

                //****************
                totalPercentageValue := Round(((UserSetup.WastageEntryLimit * TodaysSales) / 100), 1, '=');
                if ((TotalAmount > totalPercentageValue) and (UserSetup.WastageEntryApprover <> UserId)) then begin
                    Rec.Status := Rec.Status::PendingApproval;
                    Rec.Modify();

                    //to send a mail for wastageEntry approval
                    Subject := 'Wastage Entry ' + Rec."No." + 'Pending approval';
                    MessageBody := 'Dear Approver, ' + '<br><br> This Document No. ' + Rec."No." + ' is pending for approval. The reason for approval is amount ' + Format(TotalAmount) + ' exceeded allowed Limit of ' + Format(totalPercentageValue) + '<br><br>' + 'https://erptwc.thirdwavecoffee.in/BC220/?company=HBPL&page=50076&dc=0' +
                    '<br><br>' + 'Regards' + '<br><br>' + 'IT - Team.';
                    EmailMessage.Create(UserSetup.WastageEntryNotification, Subject, MessageBody, true);
                    EmailCodeunit.Send(EmailMessage);
                    //end
                end
                else begin
                    Rec.Status := Rec.Status::Approved;
                    Rec.Modify();

                    IF Confirm('Order is auto approved Are you sure to submit the Wastage Entry? You will not be able to modify after submitting.', true) then begin
                        ItemJournalLine.Reset();
                        ItemJournalLine.SetRange("Journal Template Name", 'ITEM');
                        ItemJournalLine.SetRange("Journal Batch Name", ItemJnlBatch.Name);

                        Codeunit.Run(Codeunit::"Item Jnl.-Post Batch", ItemJournalLine);
                    end;
                end;
            end;
        end;
    end;

    var
        ItemJnlLine: Record "Item Journal Line";
        Item: Record Item;
        NoSeries: Record "No. Series";
        ReservationEntry: Record "Reservation Entry";
        Entry: Integer;
        NoSeriesManagement: Codeunit NoSeriesManagement;
}