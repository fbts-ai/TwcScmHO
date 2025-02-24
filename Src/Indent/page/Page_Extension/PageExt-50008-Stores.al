pageextension 50008 StoresExtn extends "LSC Store Card"
{
    layout
    {
        addafter("Advanced Shift Nos.")
        {
            field("FSSAI Number"; rec."FSSAI Number")
            {
                ApplicationArea = all;
            }
            field("Expiry Date"; rec."Expiry Date")
            {
                ApplicationArea = all;
            }
            field("Renewal Date"; rec."Renewal Date")
            {
                ApplicationArea = all;
            }
        }
        addlast(General)
        {
            field(InventoryUploaded; Rec.InventoryUploaded)
            {
                Caption = 'InventoryUploaded';
            }
            field(StoreRegion; Rec.StoreRegion)
            {
                caption = 'Store Region';
            }
            field("Custom BOM Group Code"; "Custom BOM Group Code") //PT-FBTS //BOMS
            {
                ApplicationArea = all;
                TableRelation = "Custom BOM Group";
            }

        }

    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}