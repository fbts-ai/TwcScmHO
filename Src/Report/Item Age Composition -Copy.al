report 50198 "Item Age Composition -Copy"
{
    DefaultLayout = RDLC;
    RDLCLayout = './InventoryMgt/ItemAgeCompositionValue.rdl';
    ApplicationArea = Basic, Suite;
    //Caption = 'Item Age Composition - Value';
    Caption = 'Location wise item Age composition-Value';
    UsageCategory = ReportsAndAnalysis;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(Location; Location)
        {
            RequestFilterFields = Code;
            column(Location_Code; Location.Code) { }
            column(Location_Name; Location.Name) { }

            dataitem(Item; Item)
            {
                DataItemTableView = SORTING("No.") WHERE(Type = CONST(Inventory));
                RequestFilterFields = "No.", "Inventory Posting Group", "Statistics Group";


                column(TodayFormatted; Format(Today, 0, 4)) { }
                column(CompanyName; COMPANYPROPERTY.DisplayName()) { }
                column(ItemTableCaptItemFilter; TableCaption + ': ' + ItemFilter) { }
                column(ItemFilter; ItemFilter) { }
                column(PeriodStartDate21; Format(PeriodStartDate[2] + 1)) { }
                column(PeriodStartDate3; Format(PeriodStartDate[3])) { }
                column(PeriodStartDate31; Format(PeriodStartDate[3] + 1)) { }
                column(PeriodStartDate4; Format(PeriodStartDate[4])) { }
                column(PeriodStartDate41; Format(PeriodStartDate[4] + 1)) { }
                column(PeriodStartDate5; Format(PeriodStartDate[5])) { }
                column(PrintLine; PrintLine) { }

                column(InvtValueRTC1; InvtValueRTC[1]) { }
                column(InvtValueRTC2; InvtValueRTC[2]) { }
                column(InvtValueRTC3; InvtValueRTC[3]) { }
                column(InvtValueRTC4; InvtValueRTC[4]) { }
                column(InvtValueRTC5; InvtValueRTC[5]) { }
                column(TotalInvtValueRTC; TotalInvtValueRTC) { }

                column(InvtValue1_Item; InvtValue[1]) { AutoFormatType = 1; }
                column(InvtValue2_Item; InvtValue[2]) { AutoFormatType = 1; }
                column(InvtValue3_Item; InvtValue[3]) { AutoFormatType = 1; }
                column(InvtValue4_Item; InvtValue[4]) { AutoFormatType = 1; }
                column(InvtValue5_Item; InvtValue[5]) { AutoFormatType = 1; }
                column(TotalInvtValue_Item; TotalInvtValue_Item) { AutoFormatType = 1; }

                column(ItemAgeCompositionValueCaption; ItemAgeCompositionValueCaptionLbl) { }
                column(CurrReportPageNoCaption; CurrReportPageNoCaptionLbl) { }
                column(AfterCaption; AfterCaptionLbl) { }
                column(BeforeCaption; BeforeCaptionLbl) { }
                column(InventoryValueCaption; InventoryValueCaptionLbl) { }
                column(ItemDescriptionCaption; ItemDescriptionCaptionLbl) { }
                column(ItemNoCaption; ItemNoCaptionLbl) { }
                column(TotalCaption; TotalCaptionLbl) { }


                dataitem("Item Ledger Entry"; "Item Ledger Entry")
                {
                    DataItemLink =
                        "Item No." = FIELD("No."),
                        "Location Code" = FIELD("Location Filter"),
                        "Variant Code" = FIELD("Variant Filter"),
                        "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                        "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter");

                    DataItemTableView = SORTING("Item No.", Open) WHERE(Open = CONST(true));

                    trigger OnAfterGetRecord()
                    begin
                        if "Remaining Quantity" = 0 then
                            CurrReport.Skip();

                        PrintLine := true;
                        CalcRemainingQty();
                        RemainingQty += TotalInvtQty;

                        if Item."Costing Method" = Item."Costing Method"::Average then begin
                            InvtValue[i] += AverageCost[i] * InvtQty[i];
                            InvtValueRTC[i] += AverageCost[i] * InvtQty[i];
                        end else begin
                            CalcUnitCost();
                            TotalInvtValue_Item += UnitCost * Abs(TotalInvtQty);
                            InvtValue[i] += UnitCost * Abs(InvtQty[i]);

                            TotalInvtValueRTC += UnitCost * Abs(TotalInvtQty);
                            InvtValueRTC[i] += UnitCost * Abs(InvtQty[i]);
                        end;
                    end;

                    trigger OnPostDataItem()
                    var
                        AvgCostCurr: Decimal;
                        AvgCostCurrLCY: Decimal;
                    begin
                        if Item."Costing Method" = Item."Costing Method"::Average then begin
                            Item.SetRange("Date Filter");
                            ItemCostMgt.CalculateAverageCost(Item, AvgCostCurr, AvgCostCurrLCY);
                            TotalInvtValue_Item := AvgCostCurr * RemainingQty;
                            TotalInvtValueRTC += TotalInvtValue_Item;
                        end;
                    end;

                    trigger OnPreDataItem()
                    begin
                        TotalInvtValue_Item := 0;
                        for i := 1 to 5 do
                            InvtValue[i] := 0;
                        RemainingQty := 0;
                    end;
                }

                dataitem("Integer"; "Integer")
                {
                    DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));

                    column(TotalInvtValue_ItemLedgEntry; TotalInvtValue_Item) { AutoFormatType = 1; }
                    column(InvtValue5_ItemLedgEntry; InvtValue[5]) { AutoFormatType = 1; }
                    column(InvtValue4_ItemLedgEntry; InvtValue[4]) { AutoFormatType = 1; }
                    column(InvtValue3_ItemLedgEntry; InvtValue[3]) { AutoFormatType = 1; }
                    column(InvtValue2_ItemLedgEntry; InvtValue[2]) { AutoFormatType = 1; }
                    column(InvtValue1_ItemLedgEntry; InvtValue[1]) { AutoFormatType = 1; }
                    column(Description_Item; Item.Description) { }
                    column(No_Item; Item."No.") { }
                    column(LocCode; Location.code)
                    {

                    }
                }

                trigger OnAfterGetRecord()
                begin
                    if "Costing Method" = "Costing Method"::Average then begin
                        for i := 2 to 5 do begin
                            SetRange("Date Filter", PeriodStartDate[i] + 1, PeriodStartDate[i + 1]);
                            ItemCostMgt.CalculateAverageCost(Item, AverageCost[i], AverageCostACY[i]);
                        end;

                        SetRange("Date Filter", 0D, PeriodStartDate[2]);
                        ItemCostMgt.CalculateAverageCost(Item, AverageCost[1], AverageCostACY[1]);
                    end;

                    PrintLine := false;
                end;

                trigger OnPreDataItem()
                begin
                    Clear(InvtValue);
                    Clear(TotalInvtValue_Item);
                    SetRange("Location Filter", Location.Code);
                end;
            }
        }
    }

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(EndingDate; PeriodStartDate[5])
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Ending Date';

                        trigger OnValidate()
                        begin
                            if PeriodStartDate[5] = 0D then
                                Error(Text002);
                        end;
                    }
                    field(PeriodLength; PeriodLength)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Period Length';

                        trigger OnValidate()
                        begin
                            if Format(PeriodLength) = '' then
                                Evaluate(PeriodLength, '<0D>');
                        end;
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            if PeriodStartDate[5] = 0D then
                PeriodStartDate[5] := CalcDate('<CM>', WorkDate());
            if Format(PeriodLength) = '' then
                Evaluate(PeriodLength, '<1M>');
        end;
    }

    trigger OnPreReport()
    var
        NegPeriodLength: DateFormula;
    begin
        ItemFilter := Item.GetFilters();
        PeriodStartDate[6] := DMY2Date(31, 12, 9999);
        Evaluate(NegPeriodLength, StrSubstNo('-%1', Format(PeriodLength)));

        for i := 1 to 3 do
            PeriodStartDate[5 - i] := CalcDate(NegPeriodLength, PeriodStartDate[6 - i]);
    end;

    var
        ItemCostMgt: Codeunit ItemCostManagement;
        PeriodLength: DateFormula;
        ItemFilter: Text;
        InvtValue: array[6] of Decimal;
        InvtValueRTC: array[6] of Decimal;
        InvtQty: array[6] of Decimal;
        UnitCost: Decimal;
        PeriodStartDate: array[6] of Date;
        i: Integer;
        TotalInvtValue_Item: Decimal;
        TotalInvtValueRTC: Decimal;
        TotalInvtQty: Decimal;
        PrintLine: Boolean;
        AverageCost: array[5] of Decimal;
        AverageCostACY: array[5] of Decimal;
        RemainingQty: Decimal;

        Text002: Label 'Enter the ending date';
        ItemAgeCompositionValueCaptionLbl: Label 'Item Age Composition - Value';
        CurrReportPageNoCaptionLbl: Label 'Page';
        AfterCaptionLbl: Label 'After...';
        BeforeCaptionLbl: Label '...Before';
        InventoryValueCaptionLbl: Label 'Inventory Value';
        ItemDescriptionCaptionLbl: Label 'Description';
        ItemNoCaptionLbl: Label 'Item No.';
        TotalCaptionLbl: Label 'Total';

    local procedure CalcRemainingQty()
    begin
        for i := 1 to 5 do
            InvtQty[i] := 0;

        TotalInvtQty := "Item Ledger Entry"."Remaining Quantity";

        for i := 1 to 5 do
            if ("Item Ledger Entry"."Posting Date" > PeriodStartDate[i]) and
               ("Item Ledger Entry"."Posting Date" <= PeriodStartDate[i + 1])
            then
                if "Item Ledger Entry"."Remaining Quantity" <> 0 then begin
                    InvtQty[i] := "Item Ledger Entry"."Remaining Quantity";
                    exit;
                end;
    end;

    local procedure CalcUnitCost()
    var
        ValueEntry: Record "Value Entry";
    begin
        ValueEntry.SetRange("Item Ledger Entry No.", "Item Ledger Entry"."Entry No.");
        UnitCost := 0;

        if ValueEntry.Find('-') then
            repeat
                if ValueEntry."Partial Revaluation" then
                    SumUnitCost(UnitCost, ValueEntry."Cost Amount (Actual)" + ValueEntry."Cost Amount (Expected)", ValueEntry."Valued Quantity")
                else
                    SumUnitCost(UnitCost, ValueEntry."Cost Amount (Actual)" + ValueEntry."Cost Amount (Expected)", "Item Ledger Entry".Quantity);
            until ValueEntry.Next() = 0;
    end;

    local procedure SumUnitCost(var UnitCost: Decimal; CostAmount: Decimal; Quantity: Decimal)
    var
    begin
        UnitCost := UnitCost + CostAmount / Abs(Quantity);
    end;

    procedure InitializeRequest(NewEndingDate: Date; NewPeriodLength: DateFormula)
    begin
        PeriodStartDate[5] := NewEndingDate;
        PeriodLength := NewPeriodLength;
    end;
}
