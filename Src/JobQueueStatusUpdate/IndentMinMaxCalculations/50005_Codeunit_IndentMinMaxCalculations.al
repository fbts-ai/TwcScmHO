codeunit 50005 IndentMinMaxCalculations
{
    trigger OnRun()
    var
        TempIndentMappingSheet: Record "Indent Mapping";
        TempTransSalesEntry: Record "LSC Trans. Sales Entry";
        startDate: Date;
        enddate: Date;
        TransCurrentdate: Date;
        SalesDaysCount: Integer;
        SalesQty: Decimal;
        ILE: Record "Item Ledger Entry";
        InveSetup: Record "Inventory Setup";
    begin
        startDate := Today - 30;
        Message(Format(startDate));
        endDate := Today;

        TempIndentMappingSheet.Reset();
        TempIndentMappingSheet.SetFilter("Item No.", '<>%1', '');
        IF TempIndentMappingSheet.FindSet() then
            repeat
                SalesDaysCount := 0;
                SalesQty := 0;
                /*
                TempTransSalesEntry.Reset();
                //TempTransSalesEntry.SetCurrentKey(TempTransSalesEntry.Date);
                TempTransSalesEntry.SetRange("Item No.", TempIndentMappingSheet."Item No.");
                TempTransSalesEntry.SetRange("Trans. Date", startDate, enddate);
                IF TempTransSalesEntry.FindSet() then
                    repeat
                        IF TempTransSalesEntry."Trans. Date" <> TransCurrentdate then begin

                            SalesDaysCount := SalesDaysCount + 1;
                            SalesQty := SalesQty + TempTransSalesEntry.Quantity;
                            TransCurrentdate := TempTransSalesEntry."Trans. Date";
                        end
                        Else
                            SalesQty := SalesQty + TempTransSalesEntry.Quantity;
                    until TempTransSalesEntry.Next() = 0;
                    */

                ILE.Reset();
                ILE.SetRange(ILE."Item No.", TempIndentMappingSheet."Item No.");
                ILE.SetRange(ILE."Location Code", TempIndentMappingSheet."Location Code");
                ILE.SetRange("Posting Date", startDate, enddate);
                ILE.SetFilter("Entry Type", '=%1|=%2|=%3|=%4', ILE."Entry Type"::Sale, ILE."Entry Type"::Consumption,
                ILE."Entry Type"::"Negative Adjmt.", ILE."Entry Type"::"Assembly Consumption");
                IF ILE.FindSet() then
                    repeat

                        SalesQty := SalesQty + Abs(ILE.Quantity);

                    until ILE.Next() = 0;
                InveSetup.Get();
                SalesDaysCount := InveSetup.IndentMinMaxCalDays;
                IF SalesDaysCount > 0 then
                    TempIndentMappingSheet."Min Qty." := ROUND((ABS(SalesQty) / SalesDaysCount), 1, '=');
                TempIndentMappingSheet."Max Qty." := TempIndentMappingSheet."Min Qty." * InveSetup.IndentMaxCalculation;
                TempIndentMappingSheet.Modify();

            until TempIndentMappingSheet.Next() = 0;
    end;

    var
        myInt: Integer;
}