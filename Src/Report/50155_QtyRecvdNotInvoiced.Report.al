Report 50175 "Qty Recvd Not Invoiced"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    Caption = 'Qty Recvd Not Invoiced';
    DefaultLayout = RDLC;
    RDLCLayout = 'Report/Qty Recvd Not Invoiced.rdl';
    dataset
    {
        // dataitem(PurchRcptHeader; "Purch. Rcpt. Header")
        // {
        //   RequestFilterFields = "Buy-from Vendor No.", "Location Code", "Posting Date", "User ID";



        dataitem("Purch. Rcpt. Line"; "Purch. Rcpt. Line")
        {
            // DataItemLink = "Document No." = field("No.");
            RequestFilterFields = "Buy-from Vendor No.", "Quantity Invoiced", "Location Code", "Posting Date";
            DataItemTableView = sorting("Document No.", "Line No.") order(ascending) where("Qty. Rcd. Not Invoiced" = filter(<> 0));
            column(PostingDate_PurchRcptLine; "Purch. Rcpt. Line"."Posting Date")
            {
            }
            column(BuyfromVendorName; PurchRcptHeader."Buy-from Vendor Name")
            {
            }
            column(BuyfromVendorship; PurchRcptHeader.VendorInvoiceNo)
            {

            }
            column(BuyfromVendordate; PurchRcptHeader."Document Date")
            {

            }
            column(LineNo_PurchRcptLine; "Line No.")
            {
            }
            column(No_PurchRcptLine; "Purch. Rcpt. Line"."No.")
            {
            }
            column(Qty__Rcd__Not_Invoiced; "Qty. Rcd. Not Invoiced")
            { }
            column(Quantity; Quantity)
            { }
            column(Quantity_Invoiced; "Quantity Invoiced")
            { }
            column(Direct_Unit_Cost; "Direct Unit Cost")
            {

            }
            column(Unit_of_Measure_Code; "Unit of Measure Code")
            { }
            column(Order_No_; "Order No.") { }
            column(DocumentNo_PurchRcptLine; "Purch. Rcpt. Line"."Document No.")
            {
            }
            column(QtyRcdNotInvoiced_PurchRcptLine; "Purch. Rcpt. Line"."Qty. Rcd. Not Invoiced")
            {
            }
            column(Description_PurchRcptLine; "Purch. Rcpt. Line".Description)
            {
            }
            column(BuyfromVendorNo_PurchRcptLine; "Purch. Rcpt. Line"."Buy-from Vendor No.")
            {
            }

            column(LocationCode_PurchRcptLine; "Purch. Rcpt. Line"."Location Code")
            {
            }
            column(Posting_Date; "Posting Date")
            {
            }
            column(Type; Type)
            {

            }
            column(DimensionCodeValue; DepCode)
            {

            }

            trigger OnAfterGetRecord()
            begin
                Clear(PurchRcptHeader);
                PurchRcptHeader.GET("Document No.");
                DepCode := '';
                DimensionSetEntry.Reset();
                DimensionSetEntry.SetRange("Dimension Set ID", "Purch. Rcpt. Line"."Dimension Set ID");
                DimensionSetEntry.SetRange("Dimension Code", 'DEPARTMENT');
                IF DimensionSetEntry.FindFirst() then
                    DepCode := DimensionSetEntry."Dimension Value Code";
            end;

            trigger OnPreDataItem()
            begin
                "Purch. Rcpt. Line".SetRange("Quantity Invoiced", 0);
                //"Purch. Rcpt. Line".SetRange(Type, "Purch. Rcpt. Line".Type::Item);
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(Content)
            {
            }
        }

        actions
        {

        }
    }

    labels
    {
    }

    var
        DimensionSetEntry: Record "Dimension Set Entry";
        DepCode: Code[20];
        PurchRcptHeader: Record "Purch. Rcpt. Header";

}

