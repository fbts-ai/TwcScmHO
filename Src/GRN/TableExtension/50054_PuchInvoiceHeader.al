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
            field(50015; "Vendor Bill No."; Code[20]) //PT-FBTS
        {
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}