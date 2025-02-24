report 50102 "Delivery Challan Report"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = LayoutName;

    dataset
    {
        dataitem("Transfer Shipment Header"; "Transfer Shipment Header")
        {

            column(No_; "No.")
            {

            }

            column(Transfer_Order_Date; "Transfer Order Date")
            {

            }

            column(Transfer_from_Address; "Transfer-from Address")
            {

            }
            column(Transfer_to_Address; "Transfer-to Address")
            {

            }
            column(Transfer_from_Name; "Transfer-from Name")
            {

            }
            column(Transfer_to_Name; "Transfer-to Name")
            {

            }
            column(Transfer_from_Code; "Transfer-from Code")
            {

            }
            column(Transfer_to_Code; "Transfer-to Code")
            {

            }





            dataitem("Transfer Shipment Line"; "Transfer Shipment Line")
            {
                DataItemLinkReference = "Transfer Shipment Header";
                DataItemLink = "Document No." = field("No.");

                column(Item_No_; "Item No.")
                {

                }
                column(Description; Description)
                {

                }
                column(Unit_of_Measure; "Unit of Measure")
                {

                }
                column(Quantity; Quantity)
                {

                }
                column(Sno; Sno)
                {

                }
                column(Unit_Price; "Unit Price")
                {

                }
                column(CGSTAmount; CGSTAmount)
                {

                }
                column(IGSTAmount; IGSTAmount)
                {

                }
                column(SGSTAmount; SGSTAmount)
                {

                }
                column(Amount; Amount)
                {

                }
                column(TotalGST; TotalGST)
                {

                }
                column(IGSTPercent; IGSTPercent)
                {

                }
                column(SGSTPercent; SGSTPercent)
                {

                }
                column(CGSTPercent; CGSTPercent)
                {

                }
                column(HSN_SAC_Code; "HSN/SAC Code")
                {

                }



                trigger OnAfterGetRecord()
                begin
                    Sno := Sno + 1;
                    CalculateGST("Transfer Shipment Line");

                end;


            }
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
            LayoutFile = 'Delivery Challan.rdl';
        }
    }



    var
        Sno: Integer;
        IGSTAmount: Decimal;
        CGSTAmount: Decimal;
        SGSTAmount: Decimal;
        TotalGST: Decimal;
        IGSTPercent: Decimal;
        CGSTPercent: Decimal;
        SGSTPercent: Decimal;

    procedure CalculateGST(TSL: Record "Transfer Shipment Line")
    var
        TransferShipmentLine: Record "Transfer Shipment Line";
        TaxRecordID: RecordId;
        TaxTransactionValue: Record "Tax Transaction Value";
        TaxTypeObjHelper: Codeunit "Tax Type Object Helper";
        ComponentAmt: Decimal;

    begin
        if TransferShipmentLine.Get(TSL."Document No.", TSL."Line No.") then
            TaxRecordID := TransferShipmentLine.RecordId();
        ComponentAmt := 0;
        TaxTransactionValue.Reset();
        TaxTransactionValue.SetFilter("Tax Record ID", '%1', TaxRecordID);
        TaxTransactionValue.SetFilter("Value Type", '%1', TaxTransactionValue."Value Type"::Component);
        TaxTransactionValue.SetRange("Visible on Interface", true);
        TaxTransactionValue.SetFilter("Value ID", '%1|%2|%3', 6, 2, 3);
        if TaxTransactionValue.FindSet() then
            repeat
                ComponentAmt += TaxTypeObjHelper.GetComponentAmountFrmTransValue(TaxTransactionValue);
                IF (TaxTransactionValue.GetAttributeColumName() = 'CGST') then begin
                    CGSTAmount := TaxTransactionValue.Amount;
                    CGSTPercent := TaxTransactionValue.Percent;
                end;
                if (TaxTransactionValue.GetAttributeColumName() = 'SGST') then begin
                    SGSTAmount := TaxTransactionValue.Amount;
                    SGSTPercent := TaxTransactionValue.Percent;
                end;
                if (TaxTransactionValue.GetAttributeColumName() = 'IGST') THEN BEGIN
                    IGSTAmount := TaxTransactionValue.Amount;
                    IGSTPercent := TaxTransactionValue.Percent;
                end;



            until TaxTransactionValue.Next() = 0;
        if ComponentAmt > 0 then
            TotalGST := ComponentAmt;

    end;




}