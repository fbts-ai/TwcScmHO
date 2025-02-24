report 50150 "Calculate Statement Datewise"
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
                                WHERE("Only Accept Statement" = CONST(true));
            //RequestFilterFields = "No.";

            trigger OnAfterGetRecord()
            var
                TransactionHeader: Record "LSC Transaction Header";
            begin
                if BackDay = 0D then
                    Error('Please enter date');
                TransactionHeader.SetRange("Store No.", Store."No.");
                TransactionHeader.SetFilter(Date, '%1', BackDay);
                TransactionHeader.SetFilter("Entry Status", '%1|%2', TransactionHeader."Entry Status"::" ", TransactionHeader."Entry Status"::Posted);
                // TransactionHeader.SetFilter("Net Amount", '<>%1', 0);
                TransactionHeader.SetFilter("Statement No.", '%1', '');
                If TransactionHeader.FindSet() then begin
                    // TransSafeEntry.RESET;
                    // TransSafeEntry.SETRANGE(Date, BackDay);
                    // TransSafeEntry.SETRANGE("Bal. Account No.", '');
                    // IF TransSafeEntry.FINDFIRST THEN
                    //     REPEAT
                    //         TransSafeEntry."Bal. Account No." := '106455';
                    //         TransSafeEntry.MODIFY;
                    //     UNTIL TransSafeEntry.NEXT = 0;

                    Posted := FALSE;
                    store1.RESET;
                    Stno := Store."No.";
                    Store.VALIDATE("Safe Mgnt. in Use", TRUE);
                    Store.VALIDATE("Use Batch Posting for Statem.", TRUE);
                    Store.VALIDATE("One Statement per Day", TRUE);
                    Store.MODIFY;
                    /*
                    IF RecPOSFunctionality.FINDFIRST THEN BEGIN
                      REPEAT
                       RecPOSFunctionality."POS Cash Management":=FALSE;
                       RecPOSFunctionality.MODIFY;
                      UNTIL RecPOSFunctionality.NEXT=0;
                    END;
                    */

                    IF store1."Statement Method" = store1."Statement Method"::Staff THEN BEGIN
                        CLEAR(Statement);
                        // IF Statement.GET(recStatementline."Statement No.") THEN BEGIN
                        //     Statement."Skip Confirmation" := TRUE;
                        //     //StatementCalculate.fctWarningSkip(TRUE);
                        //     StatementCalculate.SetTransactionsFree(Statement);
                        //     StatementCalculate.RUN(Statement);
                        //     //Statement.fctMakeDiffAmountNil(); //RK-04-02-19 Diff posting in GL
                        // END
                        // ELSE BEGIN
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
                                    //     Statement."No." := NoSeriesMgt.GetNextNo(store1."Statement Nos.", TODAY, TRUE);
                                    // Statement.Validate("No.");
                                    Statement."Store No." := Stno;
                                Statement.VALIDATE("Store No.");
                                RecPostStatement.RESET;
                                RecPostStatement.SETCURRENTKEY("Posting Date");
                                IF RecPostStatement.FINDLAST THEN
                                    //Statement."Trans. Starting Date":=CALCDATE('1D',RecPostStatement."Posting Date");
                                    Statement."Trans. Starting Date" := BackDay; //for request Page //140122                                             //Statement."Trans. Starting Date":=TODAY-1; //for job 140122
                                Statement.VALIDATE("Trans. Starting Date");

                                Statement."Skip Confirmation" := TRUE;
                                Statement.INSERT(TRUE);
                                // StatementCalculate.fctWarningSkip(TRUE);
                                StatementCalculate.RUN(Statement);
                                fctMakeDiffAmountNil(Statement); //RK-04-02-19 Diff. Post in GL
                                                                 //StatementPost.RUN;
                                                                 // BatchPosting.ValidateAndPostStatement(Statement, FALSE); //RK-06-11-19
                                QueueStatement1(Statement, FALSE); //RK-OM 150122 NEW REPORT 50126
                                Posted := TRUE;
                            END;
                    END;
                    COMMIT;
                END;



                //IF Posted=FALSE THEN
                //   MESSAGE('Statement Not Found');
                /*
                IF Statement1.FINDFIRST THEN BEGIN
                  REPEAT
                   BatchPosting.ValidateAndPostStatement(Statement1,FALSE);
                  UNTIL Statement1.NEXT=0;
                END;
                          */

                /*
                IF RecPOSFunctionality.FINDFIRST THEN BEGIN
                  REPEAT
                   RecPOSFunctionality."POS Cash Management":=TRUE;
                   RecPOSFunctionality.MODIFY;
                  UNTIL RecPOSFunctionality.NEXT=0;
                END;
                */


            end;

            trigger OnPreDataItem()
            var
                myInt: Integer;
            begin
                If StoreNo <> '' then
                    Store.SetFilter("No.", StoreNo);

            end;

        }
    }


    requestpage
    {

        layout
        {
            area(content)
            {
                field(BackDay; BackDay)
                {
                    ApplicationArea = all;
                    Caption = 'Date';
                    ShowMandatory = true;
                }
                field(StoreNo; StoreNo)
                {
                    ApplicationArea = all;
                    Caption = 'Store No.';
                }
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
        StatementNo: Code[20];
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
        BackDay: Date;
        TransSafeEntry: Record 99001630;
        StoreNo: code[250];
}

