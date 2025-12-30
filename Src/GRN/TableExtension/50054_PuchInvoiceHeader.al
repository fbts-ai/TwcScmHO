tableextension 50054 PurchInvoiceHeader extends "Purch. Inv. Header"
{
    fields
    {
        // Add changes to table fields here
        field(50105; ProformaInvoice; Code[20])
        {
            Caption = 'Proforma Invoice Number';

        }
        field(50106; FreightCost; Boolean)
        {
            Caption = 'Freight Cost';
        }
        field(50107; VendorInvoiceDate; Date)
        {
            Caption = 'Vendor Invoice Date';
        }
        field(50109; "Creation Location"; code[20])
        {
            Caption = 'Creation Location';

        }
        field(50110; "GST Amount"; Decimal) //PT-FBTS 16-10-24
        {
            Caption = 'GST Amount';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Detailed GST Ledger Entry"."GST Amount" where("Document No." = field("No.")));
        }
        field(50000; "Auto Invoice"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50020; "Order No"; Code[20]) //PT-FBTS 02-15-12-2025
        {
            DataClassification = ToBeClassified;
        }
        field(50015; "Vendor Bill No."; Code[20]) //PT-FBTS
        {
            DataClassification = ToBeClassified;
        }
        //PT-FBTS 10-11-2025 RepCounter

        field(50130; "Replication Counter"; Integer)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                // Transaction: Record "LSC Transaction Header";
                Transaction: Record "Purch. Inv. Header";
                ClientSessionUtility: Codeunit "LSC Client Session Utility";
            begin
                Transaction.SetCurrentKey("Replication Counter");
                if Transaction.FindLast then
                    "Replication Counter" := Transaction."Replication Counter" + 1
                else
                    "Replication Counter" := 1;
            end;
        }
        // PT-FBTS 10-11-2025 RepCounter
    }
    keys
    {
        // Add changes to keys here
        key(sec; "Replication Counter") //PT-FBTS 10-11-2025 RepCounter
        {

        }
    }
    trigger OnInsert()
    var
        myInt: Integer;
    begin
        Validate("Replication Counter"); //PT-FBTS 10-11-2025 RepCounter
    end;

    trigger OnModify()
    var
        myInt: Integer;
    begin
        Validate("Replication Counter"); //PT-FBTS 10-11-2025 RepCounter
    end;

    var
        myInt: Integer;
}