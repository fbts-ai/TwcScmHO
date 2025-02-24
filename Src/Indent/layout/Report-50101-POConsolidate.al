report 50101 "PO Consolidate"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = LayoutName;

    dataset
    {
        dataitem("Purchase Header"; "Purchase Header")
        {
            RequestFilterFields = "No.";
            column(No_; "No.")
            {

            }
            column(Your_Reference; "Your Reference")
            {

            }
            column(Posting_Date; "Posting Date")
            {

            }
            column(Requested_Receipt_Date; "Requested Receipt Date")
            {

            }
            column(Buy_from_Vendor_Name; "Buy-from Vendor Name")
            {

            }
            column(Buy_from_Vendor_Name_2; "Buy-from Vendor Name 2")
            {

            }
            column(Buy_from_Address; "Buy-from Address")
            {

            }
            column(Buy_from_Address_2; "Buy-from Address 2")
            {

            }
            column(CompanyInformation; CompanyInformation.Picture)
            {

            }
            column(CompanyInformationName; CompanyInformation.Name)
            {

            }
            column(CompanyInformationAddress; CompanyInformation.Address)
            {

            }
            column(CompanyInformationGST; CompanyInformation."GST Registration No.")
            {

            }
            dataitem("Purchase Line"; "Purchase Line")
            {
                DataItemLinkReference = "Purchase Header";
                DataItemLink = "Document No." = field("No.");
                column(itemNo_; "No.")
                {

                }
                column(Unit_Price__LCY_; "Purchase Line"."Unit Cost")
                {

                }
                column(Unit_of_Measure_Code; "Unit of Measure Code") { }

                column(Quantity; Quantity)
                {

                }
                column(Item; Item.Description)
                {

                }
                column(Location_Code; "Location Code")
                {

                }
                column(Unit_Cost; "Unit Cost")
                {

                }
                column(Percentage; Percentage)
                {

                }

                trigger OnAfterGetRecord()
                begin
                    if item.get("Purchase Line"."No.") then;
                    CalculateGST("Purchase Line");
                    //   if TaxRate.Get("Purchase Line"."GST Group Code") then begin
                    // DetailedGSTLedgerEntry.Reset();
                    // DetailedGSTLedgerEntry.SetCurrentKey("GST Component Code");
                    // DetailedGSTLedgerEntry.SetRange("Document No.",);
                    // Clear(CGSTTotalAmount);
                    // Clear(SGSTTotalAmount);
                    // Clear(IGSTTotalAmount);
                    // Clear(TotalInvoiceValue);
                    // DetailedGSTLedgerEntry.RESET;
                    // DetailedGSTLedgerEntry.SETCURRENTKEY("GST Component Code");
                    // DetailedGSTLedgerEntry.SETRANGE("Document No.", "No.");
                    // //DetailedGSTLedgerEntry.SETRANGE("Document Line No.", "Line No.");
                    // DetailedGSTLedgerEntry.SETRANGE("Entry Type", DetailedGSTLedgerEntry."Entry Type"::"Initial Entry");
                    // IF DetailedGSTLedgerEntry.FINDSET THEN BEGIN
                    //     REPEAT
                    //         IF DetailedGSTLedgerEntry."GST Component Code" = 'CGST' THEN BEGIN
                    //             CGSTTotalAmount += -DetailedGSTLedgerEntry."GST Amount";
                    //             //TotalGSTLinePercemntage += DetailedGSTLedgerEntry."GST %";
                    //         END;
                    //         IF DetailedGSTLedgerEntry."GST Component Code" = 'IGST' THEN BEGIN
                    //             IGSTTotalAmount += -DetailedGSTLedgerEntry."GST Amount";
                    //             //TotalGSTLinePercemntage += DetailedGSTLedgerEntry."GST %";
                    //         END;
                    //         IF DetailedGSTLedgerEntry."GST Component Code" = 'SGST' THEN BEGIN
                    //             SGSTTotalAmount += -DetailedGSTLedgerEntry."GST Amount";
                    //             //TotalGSTLinePercemntage += DetailedGSTLedgerEntry."GST %";
                    //         END;
                    //     UNTIL DetailedGSTLedgerEntry.NEXT = 0;
                    // end;
                end;

            }
            trigger OnAfterGetRecord()

            begin
                CompanyInformation.get;
                CompanyInformation.CalcFields(Picture);
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

    rendering
    {
        layout(LayoutName)
        {
            Type = RDLC;
            LayoutFile = 'Poconsolidate.rdl';
        }
    }

    var
        Item: Record Item;


        CompanyInformation: Record "Company Information";
        TaxRate: Record "Tax Rate";
        CGSTTotalAmount: decimal;
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        Percentage: Decimal;

    procedure CalculateGST(PL: Record "Purchase Line")
    var
        PurchaseLine: Record "Purchase Line";
        TaxRecordID: RecordId;
        TaxTransactionValue: Record "Tax Transaction Value";
        TaxTypeObjHelper: Codeunit "Tax Type Object Helper";
        ComponentAmt: Decimal;

    begin
        Clear(Percentage);
        if PurchaseLine.Get(PL."Document Type", PL."Document No.", PL."Line No.") then
            TaxRecordID := PurchaseLine.RecordId();
        ComponentAmt := 0;
        TaxTransactionValue.Reset();
        TaxTransactionValue.SetFilter("Tax Record ID", '%1', TaxRecordID);
        TaxTransactionValue.SetFilter("Value Type", '%1', TaxTransactionValue."Value Type"::Component);
        TaxTransactionValue.SetRange("Visible on Interface", true);
        TaxTransactionValue.SetFilter("Value ID", '%1|%2|%3', 6, 2, 3);
        if TaxTransactionValue.FindSet() then
            repeat
                ComponentAmt += TaxTypeObjHelper.GetComponentAmountFrmTransValue(TaxTransactionValue);
                Percentage += TaxTransactionValue.Percent;
            until TaxTransactionValue.Next() = 0;
        //if ComponentAmt > 0 then
        // TotalGST := ComponentAmt;

    end;
}