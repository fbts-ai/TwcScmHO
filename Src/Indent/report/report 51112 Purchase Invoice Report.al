report 51112 "Purchase Invoice Report"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = 'Src/Report/PurchaseAutoInv.rdl';

    dataset
    {
        dataitem("Purchase Header"; "Purchase Header")
        {
            DataItemTableView = sorting("No.", "Document Type") where("Auto Invoice" = const(true));
            column(VendorInvoiceNo; "Purchase Header"."Vendor Invoice No.")
            {

            }
            column(PosDate; "Purchase Header"."Posting Date")
            {

            }


            dataitem("Purchase Line"; "Purchase Line")
            {
                DataItemTableView = sorting("Document No.", "Document Type", "Line No.");

                DataItemLink = "Document Type" = field("Document Type"), "Document No." = field("No.");
                column(Receipt_No_; "Receipt No.")
                {

                }
                column(PostingDate_PurchaseLine; "Posting Date")
                {
                }
                column(DCNo_PurchaseLine; "Document No.")
                {
                }
                column(PurchaseOrderNo_PurchaseLine; "Purchase Order No.")
                {
                }
                column(LocationCode_PurchaseLine; "Location Code")
                {
                }
                column(BuyfromVendorNo_PurchaseLine; "Buy-from Vendor No.")
                {
                }
                column(No_PurchaseLine; "No.")
                {
                }
                column(Type_PurchaseLine; "Type")
                {
                }
                column(Description_PurchaseLine; Description)
                {
                }
                column(Quantity_PurchaseLine; Quantity)
                {
                }
                column(QtyRcdNotInvoiced_PurchaseLine; "Qty. Rcd. Not Invoiced")
                {
                }
                column(DirectUnitCost_PurchaseLine; "Direct Unit Cost")
                {
                }
                column(Amount_PurchaseLine; Amount)
                {
                }
                column(PIQty_PurchaseLine; "PI Qty.")
                {
                }
                column(GRNRate_PurchaseLine; "GRN Rate")
                {
                }

                column(VendorName; Vendor.Name)
                {

                }
                column(Quantity_Invoiced; Quantity)
                {

                }

                column(ValueCheck; ValueCheck)
                {

                }
                column(GSTAmt; GSTAmt)
                {
                }
                trigger OnAfterGetRecord()
                var
                begin
                    Clear(Vendor);
                    //Vendor.GEt("Purchase Line"."Buy-from Vendor No.");
                    ValueCheck := '';
                    IF ("Purchase Line".Quantity <> "Purchase Line"."PI Qty.") OR ("Purchase Line"."Direct Unit Cost" <> "Purchase Line"."GRN Rate") then
                        ValueCheck := 'False'
                    else
                        ValueCheck := 'True';


                    Clear(IGSTAmt);
                    Clear(CGSTAmt);
                    Clear(SGSTAmt);
                    TaxTransactionValue.SetFilter("Tax Record ID", '%1', "Purchase Line".RecordId);
                    TaxTransactionValue.SetFilter("Value Type", '%1', TaxTransactionValue."Value Type"::Component);
                    TaxTransactionValue.SetRange("Visible on Interface", true);
                    if TaxTransactionValue.FindSet() then
                        repeat

                            if TaxTransactionValue.GetAttributeColumName = 'IGST' then begin
                                IGSTPer := TaxTransactionValue.Percent;
                                IGSTAmt := TaxTypeObjHelper.GetComponentAmountFrmTransValue(TaxTransactionValue);
                            end;
                            if TaxTransactionValue.GetAttributeColumName = 'CGST' then begin
                                CGSTPer := TaxTransactionValue.Percent;
                                CGSTAmt := TaxTypeObjHelper.GetComponentAmountFrmTransValue(TaxTransactionValue);
                            end;
                            if TaxTransactionValue.GetAttributeColumName = 'SGST' then begin
                                SGSTPer := TaxTransactionValue.Percent;
                                SGSTAmt := TaxTypeObjHelper.GetComponentAmountFrmTransValue(TaxTransactionValue);
                            end;
                        until TaxTransactionValue.Next() = 0;
                    Clear(GSTAmt);
                    GSTAmt := IGSTAmt + CGSTAmt + SGSTAmt;

                end;
            }

        }
    }

    var
        Vendor: Record Vendor;
        TaxTransactionValue: Record "Tax Transaction Value";
        TaxTypeObjHelper: Codeunit "Tax Type Object Helper";
        SGSTAmt: Decimal;
        CGSTAmt: Decimal;
        IGSTAmt: Decimal;
        CGSTper: Decimal;
        SGSTper: Decimal;
        IGSTper: Decimal;
        GstPer: Decimal;
        ValueCheck: Text[10];
        GSTAmt: Decimal;
}