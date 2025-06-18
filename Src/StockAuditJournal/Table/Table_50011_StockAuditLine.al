table 50011 StockAuditLine
{
    DataClassification = ToBeClassified;
    fields
    {
        field(1; "DocumentNo."; Code[25])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Location Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Location;
        }
        field(3; "Variant"; Code[20])
        {
        }
        field(4; Status; Enum Status_StockAudit)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Item Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Item;

            trigger OnValidate()
            var
                TempItem: Record "Item";
                tempStockAuditLine: Record StockAuditLine;
                ItemUoM: Record "Item Unit of Measure";
                TempStoreRegion: Record InventoryCountingStaging;
                TempstockAuditHead: Record StockAuditHeader;
                tempStore: Record "LSC Store";
                StockkeepingUnitPrice: Record "Stockkeeping Unit";
            begin

                tempStockAuditLine.Reset();
                tempStockAuditLine.SetRange("DocumentNo.", Rec."DocumentNo.");
                // tempStockAuditLine.SetRange("Location Code", Rec."Location Code");
                tempStockAuditLine.SetRange(Status, Status::Open);
                tempStockAuditLine.SetRange("Item Code", Rec."Item Code");
                IF tempStockAuditLine.FindFirst() then
                    Error('Stock Audit Line with Item No Already exsits');

                IF TempItem.Get(Rec."Item Code") then;
                //ALLENICK_Start101623
                //  If TempItem."Unit Cost" <> 0 then
                //ALLENICK_End101623
                Description := TempItem.Description;
                "Unit of Measure Code" := TempItem."Base Unit of Measure";
                NewUOM := TempItem."Base Unit of Measure";

                ItemUoM.Reset();
                ItemUoM.SetRange(ItemUoM."Item No.", Rec."Item Code");
                ItemUoM.SetRange(ItemUoM.Code, Rec.NewUOM);
                IF ItemUoM.FindFirst() then;
                QtyperUOM := ItemUoM."Qty. per Unit of Measure";

                TempstockAuditHead.Reset();
                TempstockAuditHead.SetRange(TempstockAuditHead."No.", Rec."DocumentNo.");
                IF TempstockAuditHead.FindFirst() then;
                // tempStore.Reset();/Old Code -PT-FBTS
                // tempStore.SetRange(tempStore."No.", TempstockAuditHead."Location Code");
                // IF tempStore.FindFirst() Then Begin

                // IF Not tempStore.InventoryUploaded then Begin
                //     IF tempStore.StoreRegion <> tempStore.StoreRegion::Blank then begin
                //         TempStoreRegion.Reset();
                //         TempStoreRegion.SetRange(ItemNo, Rec."Item Code");
                //         TempStoreRegion.SetRange(Region, tempStore.StoreRegion);
                //         IF TempStoreRegion.FindFirst() then
                //             UnitPrice := TempStoreRegion.UnitCost
                //     end //Old Code -PT-FBTS
                StockkeepingUnitPrice.Reset(); //PT-FBTS 09-08-24
                StockkeepingUnitPrice.SetRange("Location Code", TempstockAuditHead."Location Code");
                StockkeepingUnitPrice.SetRange("Item No.", Rec."Item Code");
                StockkeepingUnitPrice.SetFilter("Unit Cost", '<>%1', 0);//PT-FBTS-12-12-24
                if StockkeepingUnitPrice.FindFirst() then begin
                    UnitPrice := StockkeepingUnitPrice."Unit Cost"; //PT-FBTS 09-08-24
                end
                else
                    UnitPrice := TempItem."Unit Cost";
                // End/Old Code -PT-FBTS
                //     else
                //         UnitPrice := TempItem."Unit Cost";
                Amount := (Quantity * UnitPrice);
            end;
            //end;
        }
        field(6; "Description"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
            trigger OnValidate()
            begin
                Amount := (rec.UnitPrice * Rec.Quantity);
            end;
        }
        field(8; "LineNo."; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(9; "Reason Code"; text[100])
        {
            TableRelation = "Reason Code";
        }
        field(10; "Remarks"; text[100])
        {
        }
        field(11; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(12; "Entry Type"; Enum "Item Ledger Entry Type")
        {
            Caption = 'Entry Type';
        }
        field(13; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            Editable = false;
            /*
            TableRelation = IF ("Source Type" = CONST(Customer)) Customer
            ELSE
            IF ("Source Type" = CONST(Vendor)) Vendor
            ELSE
            IF ("Source Type" = CONST(Item)) Item;
            */
        }
        field(14; "Qty. (Calculated)"; Decimal)
        {
            Caption = 'Qty. (Calculated)';
            DecimalPlaces = 0 : 5;
            trigger OnValidate()
            begin
                Rec.Validate(Rec."Qty. (Phys. Inventory)");
            end;
        }
        field(15; "Qty. (Phys. Inventory)"; Decimal)
        {
            Caption = 'Qty. (Phys. Inventory)';
            DecimalPlaces = 0 : 5;
            Editable = true;
            trigger OnValidate()
            begin
                Rec.Quantity := 0;
                if Rec."Qty. (Phys. Inventory)" >= Rec."Qty. (Calculated)" then begin
                    Rec.Validate("Entry Type", "Entry Type"::"Positive Adjmt.");
                    Rec.Validate(Quantity, Rec."Qty. (Phys. Inventory)" - Rec."Qty. (Calculated)");
                end else begin
                    Rec.Validate("Entry Type", Rec."Entry Type"::"Negative Adjmt.");
                    Rec.Validate(Quantity, Rec."Qty. (Calculated)" - Rec."Qty. (Phys. Inventory)");
                end;
                // if Rec.Quantity <> 0 then//ALLE_NICK_180124
                //     Rec."Phys. Inventory" := false;
            end;
        }
        field(16; "Phys. Inventory"; Boolean)
        {
            Caption = 'Phys. Inventory';
            Editable = false;
        }
        field(17; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            Editable = false;
            TableRelation = "Source Code";
        }
        field(18; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item Code"));
            Editable = false;
        }
        field(19; "Amount"; Decimal)
        {
            Editable = false;
        }
        field(20; "UnitPrice"; Decimal)
        {
            Editable = false;
        }
        field(21; "NewUOM"; Code[10])
        {
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item Code"));
            Caption = 'New UOM';
            Editable = false;//pt-fbts

            trigger OnValidate()
            var
                ItemUoM: Record "Item Unit of Measure";
            begin
                ItemUoM.Reset();
                ItemUoM.SetRange(ItemUoM."Item No.", Rec."Item Code");
                ItemUoM.SetRange(ItemUoM.Code, Rec.NewUOM);
                IF ItemUoM.FindFirst() then;
                QtyperUOM := ItemUoM."Qty. per Unit of Measure";
                StockQty := 0;
                Rec.Quantity := 0;
                Rec.Validate(StockQty);
            end;



        }
        field(22; StockQty; Decimal)
        {
            Caption = 'StockQty';
            DecimalPlaces = 0 : 5;
            trigger OnValidate()
            var
            begin
                TestField(QtyperUOM);
                "Qty. (Phys. Inventory)" := StockQty * QtyperUOM;

                if StockQty >= 0 Then
                    Validate("Qty. (Phys. Inventory)");
            end;
        }
        field(23; QtyperUOM; Decimal)
        {
            Caption = 'Qty Per UOM';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        //ALLE_NICK_120124
        field(26; "Stock in hand"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("Item Ledger Entry"."Remaining Quantity" where("Item No." = field("Item Code"), "Location Code" = field("Location Code"), Open = const(true)));
            Editable = false;
        }
        field(27; "Reserved Qty. on Inventory"; Decimal)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header" = R;
            CalcFormula = Sum("Reservation Entry"."Quantity (Base)" WHERE("Item No." = FIELD("Item Code"),
                                                                           "Source Type" = CONST(32),
                                                                           "Source Subtype" = CONST("0"),
                                                                           "Reservation Status" = CONST(Reservation),
                                                                           // "Serial No." = FIELD("Serial No. Filter"),
                                                                           // "Lot No." = FIELD("Lot No. Filter"),
                                                                           "Location Code" = FIELD("Location Code")));
            // "Variant Code" = FIELD("Variant Filter")
            // "Package No." = FIELD("Package No. Filter")));
            Caption = 'Reserved Qty. on Inventory';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }

    }

    keys
    {
        key(pk; "DocumentNo.", "LineNo.")
        {
            Clustered = true;
        }
        key(sk; "Item Code")
        {

        }
    }
    trigger OnModify()
    var

    begin

    end;

    var
        myInt: Integer;

}