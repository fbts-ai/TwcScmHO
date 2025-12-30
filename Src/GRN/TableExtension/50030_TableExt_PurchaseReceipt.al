tableextension 50030 PurchReceiptExtension extends "Purch. Rcpt. Line"
{
    fields
    {
        // Add changes to table fields here
        // Add changes to table fields here
        field(50110; Remarks; Text[100])
        {
            Caption = 'Remarks';
        }
        field(50000; "PI Qty."; Decimal)
        {

        }
        field(50001; "GRN Rate"; Decimal)
        {

        }
        field(50002; "DC No."; Code[20])
        {

        }
        field(50003; "DC Date"; Date)
        {

        }
        field(50004; "Purchase Order No."; Code[20])
        {

        }
        field(50005; "Extra Quantity"; Decimal)
        {

        }


        field(50006; "Extra Receipt No."; Code[20])
        {
            Editable = false;
        }
        field(50007; "Extra Receipt Line No."; Integer)
        {
            Editable = false;
        }
        field(50008; "Entry No."; Integer)
        {

        }
        field(50010; "Order No"; Code[20]) //PT-FBTS 02-09-2-2025
        {
            DataClassification = ToBeClassified;
        }
        field(50011; "Order Line No"; Integer) //PT-FBTS 02-09-2-2025
        {
            DataClassification = ToBeClassified;
        }


    }
    keys
    {
        key(Sec; "Buy-from Vendor No.", "No.", "Location Code", "Posting Date")
        {
            // Clustered = false;
            SumIndexFields = "Direct Unit Cost";
            MaintainSqlIndex = true;
        }
    }

    var
        myInt: Integer;

}