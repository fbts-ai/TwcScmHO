report 50116 "Purchase Order Details"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = RDLC;

    RDLCLayout = 'Src/Report/Purchase Order Details.rdl';

    dataset
    {
        dataitem("Purchase Header"; "Purchase Header")
        {
            DataItemTableView = where("Document Type" = filter(Order));
            RequestFilterFields = "No.", "Order Date", "Posting Date";
            // MaxIteration = 50000000;
            column(PO_No; "No.")
            {
            }
            column(Posting_Date; "Posting Date")
            {

            }
            column(Purchase_Request_No; '')
            {

            }
            column(VendorProdPosting; VendorProdPosting)
            {

            }

            column(Expiry_Date; '') { }
            column(OrderDate_PurchaseHeader; FORMAT("Purchase Header"."Order Date", 0, '<Day,2>/<Month,2>/<Year4>'))
            {
            }
            column(Buy_from_Vendor_Name; "Buy-from Vendor Name")
            {

            }
            column(ComInfoName; ComInfo.Name)
            { }
            column(Expired; Expired) { }
            column(ComInfoAddr; ComInfo.Address)
            { }
            column(ComInfoAddr2; ComInfo."Address 2")
            { }
            column(ComInfocity; ComInfo.City)
            { }
            column(ComInfoPostcode; ComInfo."Post Code")
            { }
            column(ComInfophoneNo; ComInfo."Phone No.")
            { }
            column(ComInfostate; ComInfo."State Code")
            { }

            column(ComInfoEmail; ComInfo."E-Mail")
            { }
            dataitem("Purchase Line"; "Purchase Line")
            {
                DataItemLink = "Document No." = field("No."), "Document Type" = field("Document Type");
                DataItemLinkReference = "Purchase Header";
                DataItemTableView = where("Outstanding Quantity" = filter(> 0));
                MaxIteration = 90000000;


                column(HSN_SAC_Code; "HSN/SAC Code")
                {

                }
                column(Item_No; "No.")
                {

                }
                column(Location_Code; "Location Code")
                {

                }
                column(Document_No_; "Document No.")
                { }
                column(Description; Description)
                {

                }
                column(Unit_of_Measure; UomCode)
                {

                }
                column(Quantity; Quantity)
                {

                }
                column(Quantity_Received; "Quantity Received")
                {

                }
                column(Outstanding_Quantity; "Outstanding Quantity")
                {

                }
                column(Direct_Unit_Cost; "Direct Unit Cost")
                {

                }
                column(GST_Group_Code; "GST Group Code")
                {

                }
                column(UomCode; UomCode)
                { }
                column(Line_Discount_Amount; "Line Discount Amount")
                {

                }
                column(SGST; SGST)
                {

                }
                column(CGST; CGST)
                {

                }
                column(IGST; IGST)
                {

                }
                column(SGSTAmount; SGSTAmount)
                {

                }
                column(CGSTAmount; CGSTAmount)
                {

                }
                column(IGSTAmount; IGSTAmount)
                {

                }
                column(CESSAMT; CESSAMT)
                {

                }

                column(CESS; CESS)
                {

                }
                column(Line_Discount__; "Line Discount %")
                {

                }
                column(Line_Line_Discount_Amount; "Line Discount Amount")
                {

                }
                column(GstRate; GstRate)
                {

                }
                column(TotalAMT; TotalAMT)
                { }
                column(Line_Amount; "Line Amount")
                { }
                column(OverRecQty; OverRecQty)
                {

                }
                column(ItemCat; ItemCat)
                {

                }
                column(ItemDivisonCode; ItemDivisonCode)
                {

                }
                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                    PurchRcptLine: Record 121;
                    ItemRec: Record Item;

                begin
                    UOM.Reset();
                    UOM.SetRange(Code, "Purchase Line"."Unit of Measure Code");
                    if UOM.FindFirst() then
                        UomCode := UOM.Code;

                    if ItemRec.Get("No.") then begin
                        ItemCat := ItemRec."Item Category Code";
                        ItemDivisonCode := ItemRec."LSC Division Code";


                    end;

                    PurchRcptLine.Reset();

                    clear(OverRecQty);
                    PurchRcptLine.SetRange("Order No.", "Document No.");
                    PurchRcptLine.SetRange("Order Line No.", "Line No.");
                    //PurchRcptLine.SetRange("Order No.", "No.");
                    if PurchRcptLine.FindFirst() then begin
                        OverRecQty := PurchRcptLine."Over-Receipt Quantity";

                    end;

                    // TotalAMT := ("Line Amount" + CGSTAmount + IGSTAmount + SGSTAmount + CESSAMT);


                    ///////////////////////////////////Pratham
                    Clear(IGST);
                    Clear(SGST);
                    Clear(CGST);
                    //Clear(SubTotal);
                    Clear(GstRate);
                    //Clear(Amount_);
                    Clear(IGSTamount);
                    Clear(SGSTAmount);
                    Clear(CGSTamount);
                    Clear(CESSAMT);
                    Clear(CESS);
                    GSTSetup.Get();
                    TaxTransValue.SetRange("Tax Type", GSTSetup."GST Tax Type");
                    TaxTransValue.SetRange("Tax Record ID", "Purchase Line".RecordId());
                    TaxTransValue.SetRange("Value Type", TaxTransValue."Value Type"::COMPONENT);
                    TaxTransValue.SetFilter(Percent, '<>%1', 0);
                    if TaxTransValue.FindSet() then
                        repeat
                            TaxComponentName := TaxTransValue.GetAttributeColumName();
                            case TaxComponentName of
                                'IGST':
                                    begin
                                        IGST := TaxTransValue.Percent;
                                        evaluate(IGSTAmount, TaxTransValue."Column Value");
                                    end;
                                'CGST':
                                    begin
                                        evaluate(CGSTAmount, TaxTransValue."Column Value");
                                        CGST := TaxTransValue.Percent;
                                    end;
                                'SGST':
                                    begin
                                        evaluate(SGSTAmount, TaxTransValue."Column Value");
                                        SGST := TaxTransValue.Percent;
                                    end;
                            end;
                        //  Message('%1AMT..%2Css', CESSAMT, CESS);
                        until TaxTransValue.Next() = 0;
                    GstRate := CGST + SGST + IGST;
                    GSTSetup.Get();
                    TaxTransValue.SetRange("Tax Type", GSTSetup."Cess Tax Type");
                    TaxTransValue.SetRange("Tax Record ID", "Purchase Line".RecordId());
                    TaxTransValue.SetRange("Value Type", TaxTransValue."Value Type"::COMPONENT);
                    TaxTransValue.SetFilter(Percent, '<>%1', 0);
                    if TaxTransValue.FindSet() then
                        repeat
                            TaxComponentName := TaxTransValue.GetAttributeColumName();
                            case TaxComponentName of
                                'CESS':
                                    begin
                                        evaluate(CESSAMT, TaxTransValue."Column Value");
                                        CESS := TaxTransValue.Percent;
                                    end;
                            end;
                        until TaxTransValue.Next() = 0;

                end;


            }
            trigger OnPreDataItem()
            var
                myInt: Integer;
            begin
                ComInfo.get();
                ComInfo.CalcFields(Picture);
            end;

            trigger OnAfterGetRecord()
            var
                purchaeHeader: Record "Purchase Header";
                Vendor: Record Vendor;

            begin
                Clear(Expired);

                purchaeHeader.Reset();
                purchaeHeader.SetRange("No.", "Purchase Header"."No.");
                if purchaeHeader.FindFirst() then begin
                    repeat
                        // purchaeHeader.CalcFields("Completely Received");
                        // if purchaeHeader."Expiry Date" < WorkDate() then begin
                        //     Expired := 'Expired'
                        // end else
                        if purchaeHeader."Completely Received" = true then begin
                            Expired := 'Completed'
                        end else
                            if purchaeHeader."Completely Received" = false then
                                Expired := 'Pending';
                    until purchaeHeader.Next() = 0;
                end;
                Vendor.Reset();
                if Vendor.get("Buy-from Vendor No.") then begin
                    VendorProdPosting := Vendor."Gen. Bus. Posting Group";
                end;

                //   Message('%1', Expired);

            end;
        }
    }

    requestpage
    {
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
                action(ActionName)
                {
                    ApplicationArea = All;

                }
            }
        }
    }

    // rendering
    // {
    //     layout(LayoutName)
    //     {
    //         Type = RDLC;
    //         LayoutFile = 'mylayout.rdl';
    //     }
    // }

    var
        myInt: Integer;
        saleLine: Record "Sales Line";
        salesHeader: Record "Sales Header";
        TaxTransValue: Record "Tax Transaction Value";
        GSTSetup: Record "GST Setup";
        TaxComponentName: Text;
        Expired: Text[100];
        SGSTAmount: Decimal;
        CGSTAmount: Decimal;
        TotalAMT: Decimal;
        IGSTAmount: Decimal;
        CGST: Decimal;
        SGST: Decimal;
        IGST: Decimal;
        GstRate: Decimal;
        CESS: Decimal;
        CESSAMT: Decimal;
        ComInfo: Record "Company Information";
        UOM: Record "Unit of Measure";
        UomCode: Code[10];
        OverRecQty: Decimal;

        ItemCat: Code[20];
        VendorProdPosting: code[20];
        ItemDivisonCode: Code[20];



}