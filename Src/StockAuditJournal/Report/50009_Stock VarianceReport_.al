report 50009 "Stock Variance"//PT_FBTS 10-05-24
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    DefaultLayout = RDLC;
    Caption = 'Stock Variance Report';
    RDLCLayout = 'SRC/StockAuditJournal/Report/60101_Stock varianceReport.rdl';
    dataset
    {
        dataitem(StockAuditHeader; StockAuditHeader)
        {
            RequestFilterFields = "No.", "Posting date", "Location Code";
            dataitem(StockAuditLine; StockAuditLine)
            {
                DataItemLink = "DocumentNo." = field("No.");
                //DataItemLinkReference = StockAuditHeader;
                //DataItemTableView = sorting("Item Code", "LineNo.");
                CalcFields = "Stock in hand";
                column(DocumentNo_; "DocumentNo.")
                {
                }
                column(Time_; Time_)
                { }
                column(Posting_Date; "Posting Date")
                {
                }
                column(Location_Code; "Location Code")
                { }
                column(Unit_of_Measure_Code; "Unit of Measure Code")
                {
                }
                column(Item_Code; "Item Code")
                { }
                column(Description; Description)
                { }
                column(Stock_in_hand; "Stock in hand")
                { }
                column(WastageQty; WastageQty)
                { }
                column(Phys__Inventory; "Qty. (Phys. Inventory)")
                { }
                // dataitem(Integer; Integer)
                // {
                //     DataItemTableView = SORTING(Number) WHERE(Number = filter(1));
                column(TotalInStock; TotalInStock)
                { }
                // column(saleQty; saleQty)
                // {
                // }
                column(TranDircetSalesQty; TranDircetSalesQty)
                { }



                column(srn; srn)
                { }
                column(Bomqty; Bomqty)
                { }

                dataitem(Integer; Integer)
                {
                    column(ItemNo; ILE."Item No.")
                    {
                    }
                    column(ILEQTy; ILE.Quantity)
                    {
                    }

                    column(ILEQTys; (ILE."Remaining Quantity"))
                    {
                    }
                    column(invQty; ILE."Invoiced Quantity")
                    { }
                    column(LocCode; ILE."Location Code")
                    { }
                    column(TotalValu; TotalValu)
                    {
                    }
                    column(sumQty2; sumQty2)
                    { }
                    column(OpeningQty; OpeningQty)
                    { }
                    column(TotalOpnqty; TotalOpnqty)
                    { }
                    column(TotalstockIN; TotalstockIN)
                    { }
                    column(TotalstockOUT; TotalstockOUT)
                    { }
                    column(ProdConQty; ProdConQty)
                    { }
                    column(totalProdConQty; totalProdConQty)
                    { }

                    column(PostiveQty; PostiveQty)
                    { }
                    column(NegativeQty; NegativeQty)
                    { }


                    trigger OnPreDataItem()
                    var
                        myInt: Integer;
                    begin
                        SetRange(Number, 1, ILE.Count);
                    end;

                    trigger OnAfterGetRecord()
                    var
                    begin
                        if Number = 1 then begin
                            if not ILE.Findset() then
                                CurrReport.Break();
                        end else
                            if ILE.Next() = 0 then
                                CurrReport.Break();
                        Clear(TotalValu);

                        IF ILE."Location Code" = StockAuditLine."Item Code" then
                            TotalValu := ILE."Remaining Quantity"

                        else
                            TotalValu := 0;
                        //sumQty2 := 0;
                    end;
                    //end;
                }
                trigger OnAfterGetRecord()
                var
                    myInt: Integer;

                    bomcomp: Text;
                begin


                    srn += 1;
                    Clear(totalProdConQty);
                    Clear(ProdConQty);
                    Clear(TotalOpnqty);
                    Clear(TotalstockOUT);
                    Clear(TotalstockIn);
                    Clear(TranDircetSalesQty);
                    Clear(Bomqty);
                    Clear(saleQty);
                    Clear(TotalInStock);
                    Clear(ItemNo_gvar);
                    Clear(QtyPer);
                    Clear(sumQty);

                    sumQty1 := 0;
                    Clear(sumQty2);
                    BomCom_gVar.Reset();
                    BomCom_gVar.SetCurrentKey("No.");
                    BomCom_gVar.SetRange("No.", StockAuditLine."Item Code");
                    if BomCom_gVar.Findset() then begin
                        repeat
                            I_Uom.Reset();
                            I_Uom.SetRange("Item No.", BomCom_gVar."No.");
                            I_Uom.SetRange(Code, BomCom_gVar."Unit of Measure Code");
                            if I_Uom.FindFirst() then
                                QtyPer := I_Uom."Qty. per Unit of Measure";
                            Bomqty := BomCom_gVar."Quantity per";
                            ItemNo_gvar := BomCom_gVar."Parent Item No.";

                            // sumQty1 := 0;
                            TransSaleEntry_gVar.Reset();
                            TransSaleEntry_gVar.SetRange(Date, StockAuditLine."Posting Date");
                            TransSaleEntry_gVar.SetRange("Store No.", StockAuditLine."Location Code");
                            TransSaleEntry_gVar.SetRange("Item No.", ItemNo_gvar);
                            TransSaleEntry_gVar.CalcSums(Quantity);
                            saleQty := TransSaleEntry_gVar.Quantity * BomCom_gVar."Quantity per" * QtyPer;
                            // sumQty1 := TransSaleEntry_gVar.Quantity;
                            sumQty += TransSaleEntry_gVar.Quantity * BomCom_gVar."Quantity per" * QtyPer;


                            //     sumQty1 += TransSaleEntry_gVar.Quantity;
                            // sumQty2 := sumQty1 * BomCom_gVar."Quantity per" * QtyPer;


                            //////////////////////////////////
                            //Message('%1..%2', StockAuditLine."Item Code", WastageQty);

                            ////////////////////////////



                            ILE.Init();
                            ILE."Entry No." += 1;
                            ILE.Quantity := saleQty;
                            ILE."Item No." := ItemNo_gvar;
                            ILE."Location Code" := "Item Code";
                            ILE."Order No." := BomCom_gVar."No.";
                            ILE."Remaining Quantity" := sumQty;
                            ILE."Invoiced Quantity" := sumQty2;
                            ILE.Insert();
                        until BomCom_gVar.Next() = 0;
                    end;
                    //else

                    //until TransSaleEntry_gVar.Next() = 0;
                    /////Wastage value
                    Clear(WastageQty);
                    Clear(Wastage1);
                    ILE_Rec.Reset();
                    ILE_Rec.SetFilter("Document No.", '%1', '*WADJ*');
                    ILE_Rec.SetRange("Item No.", StockAuditLine."Item Code");
                    ILE_Rec.SetRange("Location Code", StockAuditLine."Location Code");
                    ILE_Rec.SetRange("Posting Date", StockAuditLine."Posting Date");
                    ILE_Rec.SetRange("Entry Type", ILE_Rec."Entry Type"::"Negative Adjmt.");
                    //ILE_Rec.SetRange(Open, false);
                    if ILE_Rec.FindFirst() then
                        repeat
                            Wastage1 += ILE_Rec.Quantity;
                        until ILE_Rec.next = 0;
                    WastageQty += Wastage1;

                    //////////////////////////// direct Sales qty
                    TranDircetSalesQty := 0;
                    Clear(sumQty2);
                    TransSaleEntry_gVar1.Reset();
                    TransSaleEntry_gVar1.SetRange(Date, StockAuditLine."Posting Date");
                    TransSaleEntry_gVar1.SetRange("Store No.", StockAuditLine."Location Code");
                    TransSaleEntry_gVar1.SetRange("Item No.", StockAuditLine."Item Code");
                    //MR000019
                    if TransSaleEntry_gVar1.FindFirst() then
                        repeat
                            TranDircetSalesQty += TransSaleEntry_gVar1.Quantity;
                        until TransSaleEntry_gVar1.Next() = 0;
                    sumQty2 += TranDircetSalesQty;
                    //Message('%1 ITEM..%2 QTY', StockAuditLine."Item Code", TranDircetSalesQty);
                    ////////////////////////// Opening-Qty
                    Clear(OpeningQty);
                    Clear(TotalOpnqty);
                    ILE_Rec1.Reset();
                    ILE_Rec1.SetRange("Item No.", StockAuditLine."Item Code");
                    ILE_Rec1.SetRange("Location Code", StockAuditLine."Location Code");
                    ILE_Rec1.SetFilter("Posting Date", '<%1', StockAuditLine."Posting Date");
                    if ILE_Rec1.FindFirst() then
                        repeat
                            OpeningQty += ILE_Rec1.Quantity;
                        until ILE_Rec1.Next() = 0;
                    //Message('%1', OpeningQty);
                    TotalOpnqty += OpeningQty;
                    ////////////////////////// ILE Positive= true
                    Clear(PostiveQty);
                    Clear(TotalstockIN);
                    ILE_Rec1.Reset();
                    ILE_Rec1.SetRange("Item No.", StockAuditLine."Item Code");
                    ILE_Rec1.SetRange("Location Code", StockAuditLine."Location Code");
                    ILE_Rec1.SetRange("Posting Date", StockAuditLine."Posting Date");
                    ILE_Rec1.SetRange(Positive, true);
                    //ILE_Rec.SetRange(Open, false);
                    if ILE_Rec1.FindFirst() then
                        repeat
                            PostiveQty += ILE_Rec1.Quantity;
                        until ILE_Rec1.Next() = 0;
                    TotalstockIN += PostiveQty;
                    ////////////////////////// ILE Positive= False
                    Clear(NegativeQty);
                    Clear(TotalstockOUT);
                    ILE_Rec1.Reset();
                    ILE_Rec1.SetRange("Item No.", StockAuditLine."Item Code");
                    ILE_Rec1.SetRange("Location Code", StockAuditLine."Location Code");
                    ILE_Rec1.SetRange("Posting Date", StockAuditLine."Posting Date");
                    ILE_Rec1.SetRange(Positive, false);
                    //ILE_Rec.SetRange(Open, false);
                    if ILE_Rec1.FindFirst() then
                        repeat
                            NegativeQty += ILE_Rec1.Quantity;
                        until ILE_Rec1.Next() = 0;
                    TotalstockOUT += NegativeQty;
                    ///////////////////////////////////// totalProd.Consp.Qty
                    Clear(totalProdConQty);
                    Clear(ProdConQty);
                    ILE_Rec1.Reset();
                    ILE_Rec1.SetRange("Item No.", StockAuditLine."Item Code");
                    ILE_Rec1.SetRange("Location Code", StockAuditLine."Location Code");
                    ILE_Rec1.SetRange("Posting Date", StockAuditLine."Posting Date");
                    ILE_Rec1.SetRange("Entry Type", ILE_Rec."Entry Type"::Consumption);
                    //ILE_Rec.SetRange(Open, false);
                    if ILE_Rec1.FindFirst() then
                        repeat
                            ProdConQty += ILE_Rec1.Quantity;
                        until ILE_Rec1.Next() = 0;
                    totalProdConQty += ProdConQty;

                end;

                trigger OnPreDataItem()
                var
                    myInt: Integer;
                begin
                    //SetFilter("Item Code", '%1|%2', 'CFG00021', 'CFG00022');
                    Time_ := CurrentDateTime;
                end;

                trigger OnPostDataItem()
                var
                    myInt: Integer;
                begin
                    srn := 0;
                    ILE.Reset();
                    ILE.DeleteAll();
                end;

            }

        }

    }

    // }

    requestpage
    {
        AboutTitle = 'Teaching tip title';
        AboutText = 'Teaching tip content';
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    // field(Name; SourceExpression)
                    // {
                    //     ApplicationArea = All;

                    // }
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(LayoutName)
                {
                    ApplicationArea = All;

                }
            }
        }
    }
    trigger OnInitReport()
    var
        rew: Integer;
    begin

    end;

    var
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

        sdsd: report 1305;
        TotalValu: Decimal;
        Time_: DateTime;

}