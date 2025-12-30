report 50016 "Purchase Price master report"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = 'Src/Report/PurchPricematerReport.rdl';
    dataset
    {
        dataitem(TWCPurchasePrice; TWCPurchasePrice)
        {
            RequestFilterFields = "Item No.", "Location Code", "Vendor No.", "Ending Date";
            DataItemTableView = where(PurchPricetype = filter(ITEM));

            column(userID; UserId)
            { }
            column(currentDate; CurrentDateTime)
            { }
            column(Unit_of_Measure_Code; "Unit of Measure Code")
            { }
            column(QtyPar; QtyPar)
            { }
            column(location; location)
            { }
            column(Item; Item)
            { }
            column(Vendor; Vendor)
            { }
            column(StartDate; StartDateValue)
            { }
            column(EndingDate; EndDateValue)
            { }
            column(Location_Code; "Location Code")
            {
            }
            column(description; ItemRec.Description)
            { }
            column(ItemCategoryCode; ItemCategory.Description)
            { }
            column(ItemSuperCategory; Invposting.Description)
            { }
            column(LocationName; LocationRec.Name)
            {
            }
            column(Region; '')//LocationRec.StoreRegion
            {
            }
            column(CityName; LocationRec.City)
            {
            }
            column(Item_Code; "Item No.")
            {
            }
            column(ItemRec; ItemRec.Description)
            {
            }
            column(BaseUOM; ItemRec."Base Unit of Measure")
            {
            }
            column(Vendor_Code; "Vendor No.")
            {
            }
            column(VendorName; VendorRec.Name)
            {
            }
            column(Vendor_Location; VendorRec.City)
            {
            }
            column(PriceGST; Round("Direct Unit Cost"))
            {
            }
            column(TAX; gstgroup)
            {
            }
            column(PriceInclGST; Round(Directunit))
            { }
            column(MAP; Round(StockeepingUnit."Unit Cost"))
            { }

            column(PriceStartDate; "Starting Date")
            { }
            /// Direct Unit Cost x (1 + (GST Group/100)) 
            column(PriceEndDate; "Ending Date")
            { }
            column(PriceStatus; Active)
            { }
            column(CurrentActiveIndentUOM; ItemRec."Indent Unit of Measure")
            { }
            column(CurrentConversionFactorwrtActiveIndentUOM; ItemqtyPer)
            { }
            column(CurrentActivePurchaseUOM; ItemRec."Purch. Unit of Measure")
            { }
            column(Current_Conversion_Factor_wrt_to_active_Purchase_UOM; PurchqtyPer)
            { }
            column(Businesssharebasislastmonthpurchasevalue; Round(TotalValueDirectCost))
            { }
            column(ActiveNonActive; ActiveNonActive)
            {
            }
            trigger OnPostDataItem()
            var
                myInt: Integer;
            begin
                //  PurchaseRcptDirectCost.Close();

            end;

            trigger OnAfterGetRecord()
            var
                myInt: Integer;
            begin
                Clear(GSTRate);
                Clear(Directunit);
                if LocationRec.Get("Location Code") then;
                if ItemRec.Get("Item No.") then;
                if ItemRec.Get("Item No.") then;
                if ItemCategory.Get(ItemRec."Item Category Code") then;
                if Invposting.Get(ItemRec."Inventory Posting Group") then
                    if VendorRec.Get("Vendor No.") then;
                Clear(HSNHAC);
                Clear(gstgroup);
                MultitaxApplication.Reset();
                MultitaxApplication.SetRange(Item, TWCPurchasePrice."Item No.");
                MultitaxApplication.SetRange(Vendor, VendorRec."No.");
                // MultitaxApplication.SetRange(StoreRegion, LocationRec.StoreRegion);
                if MultitaxApplication.FindFirst() then begin
                    gstgroup := MultitaxApplication."GST Group Code";
                    HSNHAC := MultitaxApplication."HSN/SAC CODE";
                end else begin

                    //if ItemRec.Get("Item No.") then begin
                    gstgroup := ItemRec."GST Group Code";
                    HSNHAC := ItemRec."HSN/SAC CODE";
                end;

                if gstgroup <> '' then
                    if not Evaluate(GSTRate, gstgroup) then;
                //     GSTRate := 0
                // else
                //     GSTRate := 0;


                Directunit := "Direct Unit Cost" * (1 + GSTRate / 100);

                StockeepingUnit.Reset();
                StockeepingUnit.SetRange("Item No.", "Item No.");
                StockeepingUnit.SetRange("Location Code", "Location Code");
                if StockeepingUnit.FindFirst() then;

                Clear(Active);
                if (Today <= "Ending Date") then
                    Active := 'Active'
                Else
                    Active := 'Inactive';


                Clear(ItemqtyPer);
                //  if ItemRec.Get("Item No.") then begin
                ItemUnitofMeasure.Reset();
                ItemUnitofMeasure.SetRange("Item No.", ItemRec."No.");
                ItemUnitofMeasure.SetRange(code, ItemRec."Indent Unit of Measure");
                if ItemUnitofMeasure.FindFirst() then
                    ItemqtyPer := ItemUnitofMeasure."Qty. per Unit of Measure";
                //end;
                Clear(PurchqtyPer);
                //if ItemRec.Get("Item No.") then begin
                ItemUnitofMeasure.Reset();
                ItemUnitofMeasure.SetRange("Item No.", ItemRec."No.");
                ItemUnitofMeasure.SetRange(code, ItemRec."Purch. Unit of Measure");
                if ItemUnitofMeasure.FindFirst() then
                    PurchqtyPer := ItemUnitofMeasure."Qty. per Unit of Measure";


                Clear(QtyPar);
                ItemUnitofMeasure.Reset();
                ItemUnitofMeasure.SetRange("Item No.", TWCPurchasePrice."Item No.");
                ItemUnitofMeasure.SetRange(Code, TWCPurchasePrice."Unit of Measure Code");
                if ItemUnitofMeasure.FindFirst() then
                    QtyPar := ItemUnitofMeasure."Qty. per Unit of Measure";

                //end;

                // Clear(DirctUnitwithVendor);
                // PurchaseReceiptHeader.Reset();
                // PurchaseReceiptHeader.SetCurrentKey("No.", "Buy-from Vendor No.");
                // PurchaseReceiptHeader.SetRange("Buy-from Vendor No.", TWCPurchasePrice."Vendor No.");
                // PurchaseReceiptHeader.SetFilter("Posting Date", '%1..%2', StartDateValue, EndDateValue);
                // PurchaseReceiptHeader.SetRange("Location Code", "Location Code");
                // if PurchaseReceiptHeader.FindSet() then
                //     repeat
                //         PurchaseReceiptLine.Reset();
                //         PurchaseReceiptLine.SetRange("Document No.", PurchaseReceiptHeader."No.");
                //         PurchaseReceiptLine.SetRange("No.", TWCPurchasePrice."Item No.");
                //         PurchaseReceiptLine.SetRange("Buy-from Vendor No.", PurchaseReceiptHeader."Buy-from Vendor No.");
                //         PurchaseReceiptLine.SetRange("Location Code", TWCPurchasePrice."Location Code");
                //         if PurchaseReceiptLine.FindSet() then begin
                //             PurchaseReceiptLine.CalcSums("Direct Unit Cost");
                //             DirctUnitwithVendor += PurchaseReceiptLine."Direct Unit Cost";
                //         end;
                //     until PurchaseReceiptHeader.Next() = 0;


                // Clear(DirctUnitwithItem);
                // PurchaseReceiptHeader.Reset();
                // PurchaseReceiptHeader.SetCurrentKey("No.", "Location Code");
                // PurchaseReceiptHeader.SetRange("Location Code", TWCPurchasePrice."Location Code");
                // PurchaseReceiptHeader.SetFilter("Posting Date", '%1..%2', StartDateValue, EndDateValue);
                // if PurchaseReceiptHeader.FindSet() then
                //     repeat
                //         PurchaseReceiptLine.Reset();
                //         PurchaseReceiptLine.SetRange("Document No.", PurchaseReceiptHeader."No.");
                //         PurchaseReceiptLine.SetRange("No.", TWCPurchasePrice."Item No.");
                //         PurchaseReceiptLine.SetRange("Location Code", TWCPurchasePrice."Location Code");
                //         if PurchaseReceiptLine.FindSet() then begin
                //             PurchaseReceiptLine.CalcSums("Direct Unit Cost");
                //             DirctUnitwithItem += PurchaseReceiptLine."Direct Unit Cost";
                //         end;
                //     until PurchaseReceiptHeader.Next() = 0;

                // if DirctUnitwithItem <> 0 then
                //     TotalValueDirectCost := Round(DirctUnitwithVendor / DirctUnitwithItem * 100)
                // else
                //     TotalValueDirectCost := 0;
                Clear(DirctUnitwithVendor);
                Clear(TotalValueDirectCost);
                PurchaseReceiptLine.Reset();
                PurchaseReceiptLine.SetLoadFields("Buy-from Vendor No.", "No.", "Location Code", "Posting Date");
                PurchaseReceiptLine.SetRange("Buy-from Vendor No.", TWCPurchasePrice."Vendor No.");
                PurchaseReceiptLine.SetRange("No.", TWCPurchasePrice."Item No.");
                PurchaseReceiptLine.SetRange("Location Code", TWCPurchasePrice."Location Code");
                PurchaseReceiptLine.SetFilter("Posting Date", '%1..%2', StartDateValue, EndDateValue);
                if PurchaseReceiptLine.Findset() then begin
                    repeat
                        // PurchaseReceiptLine.CalcSums("Direct Unit Cost");
                        //  PurchaseReceiptLine.CalcSums(Quantity);
                        DirctUnitwithVendor += (PurchaseReceiptLine."Direct Unit Cost" * PurchaseReceiptLine.Quantity);
                    until PurchaseReceiptLine.Next() = 0;
                    // end;
                    Clear(DirctUnitwithItem);
                    PurchaseReceiptLine.Reset();
                    PurchaseReceiptLine.SetLoadFields("No.", "Location Code", "Posting Date");
                    PurchaseReceiptLine.SetRange("No.", TWCPurchasePrice."Item No.");
                    PurchaseReceiptLine.SetRange("Location Code", TWCPurchasePrice."Location Code");
                    PurchaseReceiptLine.SetFilter("Posting Date", '%1..%2', StartDateValue, EndDateValue);
                    if PurchaseReceiptLine.Findset() then begin
                        repeat
                            // PurchaseReceiptLine.CalcSums("Direct Unit Cost");
                            DirctUnitwithItem += (PurchaseReceiptLine."Direct Unit Cost" * PurchaseReceiptLine.Quantity);
                        until PurchaseReceiptLine.Next() = 0;
                    end;
                end;
                // DirctUnitwithVendor := GetVendorCost(TWCPurchasePrice, StartDateValue, EndDateValue);
                // DirctUnitwithItem := GetItemCost(TWCPurchasePrice, StartDateValue, EndDateValue);

                if DirctUnitwithItem <> 0 then
                    TotalValueDirectCost := Round(DirctUnitwithVendor / DirctUnitwithItem * 100)
                else
                    TotalValueDirectCost := 0;


                // Clear(DirctUnitwithVendor);
                // PurchaseRcptDirectCost.SetRange(Buy_from_Vendor_No_, TWCPurchasePrice."Vendor No.");
                // PurchaseRcptDirectCost.SetRange(No_, TWCPurchasePrice."Item No.");
                // PurchaseRcptDirectCost.SetRange(Location_Code, TWCPurchasePrice."Location Code");
                // PurchaseRcptDirectCost.SetFilter(PostingDate, '%1..%2', StartDateValue, EndDateValue);
                // if PurchaseRcptDirectCost.Open() then begin
                //     while PurchaseRcptDirectCost.Read() do
                //         DirctUnitwithVendor += PurchaseRcptDirectCost.DirectUnitCost;
                // end;

                // exit(DirctUnitwithVendor);

                Clear(ActiveNonActive);
                IndentMappingStaup.Reset();
                IndentMappingStaup.SetRange("Item No.", TWCPurchasePrice."Item No.");
                IndentMappingStaup.SetRange("Location Code", TWCPurchasePrice."Location Code");
                IndentMappingStaup.SetRange("Sourcing Method", IndentMappingStaup."Sourcing Method"::Purchase);
                IndentMappingStaup.SetRange("Source Location No.", TWCPurchasePrice."Vendor No.");
                if IndentMappingStaup.FindFirst() then begin
                    if IndentMappingStaup."Block Indent" = true then begin
                        ActiveNonActive := 'Inactive'
                    end;
                    if IndentMappingStaup."Block Indent" = false then
                        ActiveNonActive := 'Active ';
                end
                else
                    ActiveNonActive := 'Not Defined';

                //  Message('%1', ActiveNonActive);
            end;

            trigger OnPreDataItem()
            var
                myInt: Integer;
                StartDateFilter: Text;
                EndDateFilter: Text;

            begin
                // if ("Starting Date" = 0D) then
                //     Error('Please enter Starting Date');
                // if ("Ending Date" = 0D) then
                //     Error('Please enter Ending Date');
                Item := GetFilter("Item No.");
                Vendor := GetFilter("Vendor No.");
                // StartDate := GetFilter("Starting Date");
                // EndingDate := GetFilter("Ending Date");
                location := GetFilter("Location Code");

                StartDateFilter := GetFilter("Starting Date");
                EndDateFilter := GetFilter("Ending Date");



                // if StartDateValue = 0D then
                //     Error('Please enter a Starting Date before running the report.');

                // if EndDateValue = 0D then
                //     Error('Please enter an Ending Date before running the report.');

                //if Evaluate(StartDateValue, StartDateFilter) and Evaluate(EndDateValue, EndDateFilter) then
                // if StartDateValue > EndDateValue then
                //     Error('Starting Date cannot be greater than Ending Date.');




                //  TWCPurchasePrice.SetFilter("Ending Date", '>%1', Today);


            end;
        }
    }

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
                    field(StartDateValue; StartDateValue)
                    {
                        ApplicationArea = all;
                        Caption = 'Start Date';
                    }
                    field(EndDateValue; EndDateValue)
                    {
                        ApplicationArea = all;
                        Caption = 'Ending Date';
                    }
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(LayoutName)
                {

                }
            }
        }
    }



    var
        myInt: Integer;
        StartDate: Text;
        EndingDate: Text;
        location: Code[100];
        //PurchaseRcptDirectCost: Query PurchaseRcptDirectCost;
        Vendor: Code[50];
        StartDateValue: Date;
        EndDateValue: Date;
        QtyPar: Decimal;
        Item: Code[50];


        LocationRec: Record Location;
        ItemRec: Record Item;
        ItemCategory: Record "Item Category";
        Invposting: Record "Inventory Posting Group";
        VendorRec: Record Vendor;
        MultitaxApplication: Record "Multiple Tax Applicable";
        GSTRate: Decimal;
        gstgroup: Code[20];
        HSNHAC: Code[20];
        Directunit: Decimal;
        PurchqtyPer: Decimal;
        ItemqtyPer: Decimal;

        StockeepingUnit: Record "Stockkeeping Unit";
        Active: Text;
        ItemUnitofMeasure: Record "Item Unit of Measure";
        PurchaseReceiptHeader: Record "Purch. Rcpt. Header";
        PurchaseReceiptLine: Record "Purch. Rcpt. Line";
        DirctUnitwithVendor: Decimal;
        DirctUnitwithItem: Decimal;
        TotalValueDirectCost: Decimal;
        IndentMappingStaup: Record "Indent Mapping";
        ActiveNonActive: Text[100];

    // procedure GetVendorCost(TWCPurchasePrice: Record TWCPurchasePrice; StartDateValue: Date; EndDateValue: Date): Decimal
    // var
    //     PurchaseRcptDirectCost: Query "PurchaseRcptDirectCost";
    //     DirctUnitwithVendor: Decimal;
    // begin
    //     Clear(DirctUnitwithVendor);
    //     PurchaseRcptDirectCost.SetRange(Buy_from_Vendor_No_, TWCPurchasePrice."Vendor No.");
    //     PurchaseRcptDirectCost.SetRange(No_, TWCPurchasePrice."Item No.");
    //     PurchaseRcptDirectCost.SetRange(Location_Code, TWCPurchasePrice."Location Code");
    //     PurchaseRcptDirectCost.SetFilter(PostingDate, '%1..%2', StartDateValue, EndDateValue);
    //     if PurchaseRcptDirectCost.Open() then begin
    //         while PurchaseRcptDirectCost.Read() do
    //             DirctUnitwithVendor += PurchaseRcptDirectCost.DirectUnitCost;
    //         PurchaseRcptDirectCost.Close();
    //     end;

    //     exit(DirctUnitwithVendor);
    // end;


    // procedure GetItemCost(TWCPurchasePrice: Record TWCPurchasePrice; StartDateValue: Date; EndDateValue: Date): Decimal
    // var
    //     PurchaseRcptDirectCost: Query "PurchaseRcptDirectCostItem";
    //     DirctUnitwithItem: Decimal;
    // begin
    //     Clear(DirctUnitwithItem);

    //     PurchaseRcptDirectCost.SetRange(No_, TWCPurchasePrice."Item No.");
    //     PurchaseRcptDirectCost.SetRange(Location_Code, TWCPurchasePrice."Location Code");
    //     PurchaseRcptDirectCost.SetFilter(PostingDate, '%1..%2', StartDateValue, EndDateValue);
    //     if PurchaseRcptDirectCost.Open() then begin
    //         while PurchaseRcptDirectCost.Read() do
    //             DirctUnitwithItem += PurchaseRcptDirectCost.DirectUnitCost;
    //         PurchaseRcptDirectCost.Close();
    //     end;

    //     exit(DirctUnitwithItem);
    // end;





}