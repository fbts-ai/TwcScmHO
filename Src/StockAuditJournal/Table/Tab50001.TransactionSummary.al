table 50055 "Transaction Summary"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Store No."; Code[20]) { Caption = 'Store No.'; }
        field(2; "Date"; Date) { Caption = 'Date'; }
        field(3; "Item No."; Code[20]) { Caption = 'Item No.'; }
        field(4; Quantity; Decimal) { Caption = 'Quantity (Store)'; }
        field(5; "QuantityHO"; Decimal) { Caption = 'Quantity (HO)'; }
        field(6; "Entry No."; Integer) { Caption = 'Entry No.'; }

        //CHETAN
        field(7; "BOM Item"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Parent Item No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "BOM Qty Per"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Sale Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 4;
        }
        field(11; "BOM Unit Of Measure"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        //CHETAN
    }

    keys
    {
        key(PK; "Store No.", "Date", "Item No.", "BOM Item")
        {
            Clustered = true;
        }
    }
}
