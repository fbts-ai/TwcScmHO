tableextension 50002 Store_Extn extends "LSC Store"
{
    fields
    {
        field(50000; "FSSAI Number"; Code[20])
        { }
        field(50001; "Expiry Date"; Date)
        { }
        field(50002; "Renewal Date"; Date)
        { }

        // SCM field
        field(50106; StoreRegion; Enum Region_InventoryCount)
        {
            caption = 'Store Region';
        }
        field(50107; AgaveStoreID; Code[10])
        {
            caption = 'Agave Store ID';
            Editable = False;
        }
        field(50108; InventoryUploaded; Boolean)
        {
            caption = 'InventoryUploaded';

            trigger OnValidate()
            var
            begin
                IF xRec.InventoryUploaded = true Then
                    Error('You can not Uncheck this boolean as inventory is uploaded');

            end;
        }


        // Add changes to table fields here
        //this field is not in used
        field(50100; JobQueueNotification; Text[100])
        {
            Caption = 'Job Queue Notification';
            Enabled = false;
        }
        field(50101; "Statment No"; code[20])
        {

        }
        field(50102; "Statment caluclated"; Boolean)
        {

        }
        field(50103; "Statment error"; text[200])
        {

        }
        //chetna_24_09_2024
        field(50131; "Custom BOM Group Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        //chetan_24_09_2024

        field(50141; Authentication; text[200])
        {
            DataClassification = ToBeClassified;
        }
        field(50142; "TransSalesEntry URL"; text[200])
        {
            DataClassification = ToBeClassified;
        }
        field(50143; "Enable API Replication Check"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(501144; "Response Data"; Text[2048])
        {
            DataClassification = ToBeClassified;
        }

    }

    var
        myInt: Integer;
}