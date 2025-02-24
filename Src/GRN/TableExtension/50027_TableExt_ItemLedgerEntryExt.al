tableextension 50027 ItemLedegrEntryExt extends "Item Ledger Entry"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(50100; BrandName; Text[20])
        {
            Caption = 'Brand Name';
        }
        field(50105; ManufacturingDate; Date)
        {
            Caption = 'Manufacturing Date';
        }
        //AJ_ALLE_17012023
        //TodayQuarantine //AJ_ALLE_22012024
        field(50106; "Quarantine Location"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50107; "Remarks"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(50109; "Select"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50110; Completed; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50111; Approver; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        //TodayQuarantine //AJ_ALLE_22012024
        //AJ_ALLE_17012023
    }
    keys
    {
        // key(key22; "Item No.", "Location Code")
        // {

        // }
        // Key(key23; "Item No.", "Entry Type", "Variant Code", "Drop Shipment", "Location Code", "Posting Date")
        // {

        // }
    }

    var
        myInt: Integer;
}