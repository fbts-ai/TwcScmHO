table 50028 "TWCPurchasePrice"
{
    Caption = 'TWC Purchase Price';

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            NotBlank = true;
            //TableRelation = Item;

            trigger OnValidate()
            begin
                if "Item No." <> xRec."Item No." then begin
                    //"Unit of Measure Code" := '';
                    //"Variant Code" := '';
                end;
            end;
        }
        field(2; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            NotBlank = true;
            TableRelation = Vendor;

            trigger OnValidate()
            begin
                if Vend.Get("Vendor No.") then
                    "Currency Code" := Vend."Currency Code";
            end;
        }
        field(3; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(4; "Starting Date"; Date)
        {
            Caption = 'Starting Date';

            trigger OnValidate()
            begin
                if ("Starting Date" > "Ending Date") and ("Ending Date" <> 0D) then
                    Error(Text000, FieldCaption("Starting Date"), FieldCaption("Ending Date"));
            end;
        }
        field(5; "Direct Unit Cost"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Direct Unit Cost';
            MinValue = 0;
        }
        field(6; "Location Code"; Code[20])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(7; PurchPricetype; Enum PurchasePriceType)
        {
            Caption = 'PurchPricetype';
            //TableRelation = Location;
        }

        field(14; "Minimum Quantity"; Decimal)
        {
            Caption = 'Minimum Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(15; "Ending Date"; Date)
        {
            Caption = 'Ending Date';

            trigger OnValidate()
            begin
                Validate("Starting Date");
            end;
        }
        field(5400; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));
            trigger OnValidate()//PT-FBTS-140524 vaidation 
            var
                ItemRec: Record Item;
            begin
                ItemRec.Get("Item No.");
                if Rec."Unit of Measure Code" <> ItemRec."Purch. Unit of Measure" then
                    Error('Please Check the item  Purch. Unit of Measure');
            end;
        }
        field(5700; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
    }

    keys
    {
        key(Key1; "Item No.", "Vendor No.", "Location Code", PurchPricetype, "Starting Date", "Currency Code", "Variant Code", "Unit of Measure Code", "Minimum Quantity")
        {
            Clustered = true;
        }
        key(Key2; "Vendor No.", "Item No.", "Starting Date", "Currency Code", "Variant Code", "Unit of Measure Code", "Minimum Quantity")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Item No.", "Vendor No.", "Starting Date", "Currency Code", "Variant Code", "Unit of Measure Code", "Minimum Quantity")
        {
        }
    }

    trigger OnInsert()
    begin
        TestField("Vendor No.");
        TestField("Item No.");
    end;

    trigger OnRename()
    begin
        TestField("Vendor No.");
        TestField("Item No.");
    end;

    var
        Vend: Record Vendor;
        Text000: Label '%1 cannot be after %2';
    /*
    #if not CLEAN21
        procedure CopyPurchPriceToVendorsPurchPrice(var PurchPrice: Record "Purchase Price"; VendNo: Code[20])
        var
            NewPurchasePrice: Record "Purchase Price";
        begin
            if PurchPrice.FindSet() then
                repeat
                    NewPurchasePrice := PurchPrice;
                    NewPurchasePrice."Vendor No." := VendNo;
                    OnBeforeNewPurchasePriceInsert(NewPurchasePrice, PurchPrice);
                    if NewPurchasePrice.Insert() then;
                until PurchPrice.Next() = 0;
        end;

        [IntegrationEvent(false, false)]
        local procedure OnBeforeNewPurchasePriceInsert(var NewPurchasePrice: Record "Purchase Price"; PurchasePrice: Record "Purchase Price")
        begin
        end;
    #endif
    */

}

