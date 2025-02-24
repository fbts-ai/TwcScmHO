report 50147 "Calculate Statement"
{
    ProcessingOnly = true;
    ShowPrintStatus = false;
    UseRequestPage = true;
    ApplicationArea = all;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Store; 99001470)
        {
            DataItemTableView = SORTING("No.")
                                ORDER(Ascending)
                                WHERE("Statment error" = filter(''), "Only Accept Statement" = CONST(true));

            trigger OnAfterGetRecord()
            var
                TransactionHeader: Record "LSC Transaction Header";
                StoreRec: Record 99001470;
            begin
                //ALLENICK_
                if Store."No." = 'S032' then
                    Error('testing');
                if StoreRec.get(Store."No.") then begin
                    repeat
                        StoreRec."Statment No" := '';
                        StoreRec."Statment caluclated" := false;
                        StoreRec.Modify();
                    until StoreRec.Next() = 0;
                end;

                StoreRec.Modify();
                TransactionHeader.SetRange("Store No.", Store."No.");
                //TransactionHeader.SetFilter(Date, '%1', Today - 22);
                TransactionHeader.SetFilter(Date, '%1', Today - 24);
                TransactionHeader.SetFilter("Entry Status", '%1|%2', TransactionHeader."Entry Status"::" ", TransactionHeader."Entry Status"::Posted);
                // TransactionHeader.SetFilter("Net Amount", '<>%1', 0);
                TransactionHeader.SetFilter("Statement No.", '%1', '');
                If TransactionHeader.FindSet() then begin
                    Posted := FALSE;
                    store1.RESET;
                    Stno := Store."No.";
                    Store.VALIDATE("Safe Mgnt. in Use", TRUE);
                    Store.VALIDATE("Use Batch Posting for Statem.", TRUE);
                    Store.VALIDATE("One Statement per Day", TRUE);
                    Store.MODIFY;


                    IF store1."Statement Method" = store1."Statement Method"::Staff THEN BEGIN
                        CLEAR(Statement);

                        CLEAR(Statement);
                        Statement.RESET;
                        Statement.INIT();
                        RetailSetup.GET;
                        RecTransSales.RESET;
                        RecPostStatement.SETCURRENTKEY("Posting Date");
                        IF RecPostStatement.FINDLAST THEN
                            //RecTransSales.SETRANGE(RecTransSales.Date,CALCDATE('1D',RecPostStatement."Posting Date"));
                            IF RecTransSales.FINDSET THEN BEGIN
                                // store1.SETFILTER("No.",RetailSetup."Local Store No.");
                                store1.SETFILTER("No.", Stno);
                                IF store1.FINDSET THEN
                                    Statement."Store No." := Stno;
                                Statement.VALIDATE("Store No.");
                                RecPostStatement.RESET;
                                RecPostStatement.SETCURRENTKEY("Posting Date");
                                IF RecPostStatement.FINDLAST THEN

                                    //Statement."Trans. Starting Date" := Today - 22; //for request Page //140122                                             //Statement."Trans. Starting Date":=TODAY-1; //for job 140122
                                    Statement."Trans. Starting Date" := Today - 24;
                                Statement.VALIDATE("Trans. Starting Date");

                                Statement."Skip Confirmation" := TRUE;
                                Statement.INSERT(TRUE);
                                // StatementCalculate.fctWarningSkip(TRUE);
                                StatementCalculate.RUN(Statement);
                                fctMakeDiffAmountNil(Statement);


                                QueueStatement1(Statement, FALSE);
                                Posted := TRUE;
                            END;
                    END;
                    COMMIT;

                END;




            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                // field(BackDay; BackDay)
                // {
                // }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    local procedure fctMakeDiffAmountNil(Statment: Record "LSC Statement")
    var
        myInt: Integer;
        recStatementLine: Record "LSC Statement Line";
    begin
        recStatementLine.RESET;
        recStatementLine.SETRANGE("Statement No.", Statment."No.");
        IF recStatementLine.FINDSET THEN BEGIN
            REPEAT
                IF recStatementLine."Difference Amount" <> 0 THEN BEGIN
                    recStatementLine."Counted Amount" := recStatementLine."Trans. Amount";
                    recStatementLine.VALIDATE("Counted Amount");
                    recStatementLine.MODIFY();
                END;
            UNTIL recStatementLine.NEXT = 0;
        END;

    end;

    local procedure QueueStatement1(Stmt: Record "LSC Statement"; PostSalesEntriesOnly: Boolean)
    var
        NewBatchPostingQueue: Record "LSC Batch Posting Queue";
        TransactionStatus: Record "LSC Transaction Status";
    begin
        Clear(NewBatchPostingQueue);

        NewBatchPostingQueue."Store No." := Stmt."Store No.";
        NewBatchPostingQueue."Document No." := Stmt."No.";
        NewBatchPostingQueue.Type := NewBatchPostingQueue.Type::Statement;
        NewBatchPostingQueue."Post Sales Entries Only" := PostSalesEntriesOnly;
        NewBatchPostingQueue."Document Posting Date" := Stmt."Posting Date";

        TransactionStatus.Reset;
        TransactionStatus.SetCurrentKey("Statement No.");
        TransactionStatus.SetRange("Statement No.", Stmt."No.");
        NewBatchPostingQueue."No. of Lines" := TransactionStatus.Count;
        BatchPosting.InsertNewJobInBatchQueue(NewBatchPostingQueue);
        // Message(AddedToQueueTxt, 'Statement', Stmt."No.");
    end;


    var
        recStore: Record 99001470;
        WorkShiftRBO: Record 99001507;
        Statement: Record 99001487;
        RetailSetup: Record 10000700;
        //StatementPost: Codeunit 50103;
        StatementCalculate: Codeunit 99001456;
        recStatementline: Record 99001488;
        NoSeriesMgt: Codeunit 396;
        dtStartDate: Date;
        dtEndDate: Date;
        store1: Record 99001470;
        RecPostedStatLine: Record 99001489;
        RecRetailUser: Record 10000742;
        RecPostStatement: Record 99001485;
        RecTransSales: Record 99001472;
        RecPOSFunctionality: Record 99001515;
        Posted: Boolean;
        Stno: Code[10];
        BatchPosting: Codeunit 99001455;
        Statement1: Record 99001487;
        BackDay: Integer;
        TransSafeEntry: Record 99001630;
}

