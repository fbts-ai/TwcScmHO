report 50012 "Stock Audit Report"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    Caption = 'Stock Audit Report';
    RDLCLayout = 'SRC/StockAuditJournal/Report/SalesStockDetailReport.rdl';

    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.", "Location Filter";
            CalcFields = "Assembly BOM", Inventory;
            DataItemTableView = where("Phys Invt Counting Period Code" = filter(<> ''), Type = filter('Inventory'));
            column(No_; "No.") { }
            column(Description; Description) { }
            column(Datetime; CurrentDateTime)
            { }
            column(Inventory; Inventory) { }
            column(Base_Unit_of_Measure; "Base Unit of Measure") { }
            column(ProdConQty; ProdConQty) { }

            trigger OnAfterGetRecord()
            var
                myInt: Integer;
                TransactionSummaryRec: Record "Transaction Summary";
            begin
                TransactionSummaryRec.Reset();
                ProdConQty := 0;
                TransactionSummaryRec.SetRange("BOM Item", "No.");
                TransactionSummaryRec.SetRange("Store No.", Item.GetFilter("Location Filter"));
                if TransactionSummaryRec.FindSet() then begin
                    repeat
                        ProdConQty += TransactionSummaryRec."Sale Quantity";
                    until TransactionSummaryRec.Next() = 0;
                end;
            end;

            trigger OnPreDataItem()
            var
                SalesEntryImporter: Codeunit SalesEntryImporter;
                myInt: Integer;
                locationCode: Code[20];
                StockAuditHeader: Record StockAuditHeader;
            begin
                locationCode := Item.GetFilter("Location Filter");
                //  Message(locationCode);

                if locationCode = '' then begin
                    Error('Please select location code ');
                    exit;
                end;
                StockAuditHeader.Reset();
                StockAuditHeader.SetRange("Location Code", locationCode);
                StockAuditHeader.SetRange("Posting Date", CalcDate('-1D', Today));
                StockAuditHeader.SetFilter(Status, '<>%1', StockAuditHeader.Status::Posted);
                if StockAuditHeader.FindFirst() then
                    Error('Inventory Posting is pending for location %1.', locationCode);

                SalesEntryImporter.GetAndStoreSalesEntryData(Today, locationCode)
            end;

        }
    }


    trigger OnPreReport()
    var
        myInt: Integer;

    begin


    end;


    var
        myInt: Integer;
        TransSaleEntry_gVar: Record "LSC Trans. Sales Entry";
        TransSaleEntry_gVar1: Record "LSC Trans. Sales Entry";
        ILE_Rec: Record "Item Ledger Entry";
        ILE_Rec1: Record "Item Ledger Entry";
        PostiveQty: Decimal;
        NegativeQty: Decimal;
        ProdConQty: Decimal;
        totalProdConQty: Decimal;
        WastageQty: Decimal;
        OpeningQty: Decimal;
        wsadoc: Text[50];
        BomCom_gVar: Record "BOM Component";
        ItemNo_gvar: Code[100];
        saleQty: Decimal;
        Bomqty: Decimal;
        TotalOpnqty: Decimal;
        TotalstockIN: Decimal;
        TotalstockOUT: Decimal;
        srn: Integer;
        sumQty: Decimal;
        Wastage1: Decimal;
        sumQty1: Decimal;
        sumQty2: Decimal;
        TranDircetSalesQty: Decimal;

        TotalInStock: Decimal;
        I_Uom: Record "Item Unit of Measure";
        QtyPer: Decimal;
        i: Integer;
        ILE: Record "Item Ledger Entry" temporary;

}