table 50008 WastageEntryLine
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
        field(4; Status; Enum Status_Wastage)
        {
            DataClassification = ToBeClassified;
        }
        // field(5; "Item Code"; Code[20])
        // {
        //     DataClassification = ToBeClassified;
        //     TableRelation = Item;
        //     trigger OnValidate()
        //     var
        //         TempUnitOfMeasure: Record "Unit of Measure";
        //     begin
        //         IF TempItem.Get(Rec."Item Code") then;
        //         Description := TempItem.Description;
        //         "Unit of Measure Code" := TempItem."Base Unit of Measure";
        //         UnitPrice := TempItem."Unit Cost";
        //         Amount := (Quantity * UnitPrice);
        //     end;
        // }
        field(5; "Item Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                TempUnitOfMeasure: Record "Unit of Measure";
                wastageHeader: Record WastageEntryHeader;
                StockkeepingUnitPrice: Record "Stockkeeping Unit";//PT-FBTS
                TempWastageEntryHead: Record WastageEntryHeader;
            begin
                ////OldCode
                IF TempItem.Get(Rec."Item Code") then;
                Description := TempItem.Description;
                "Unit of Measure Code" := TempItem."Base Unit of Measure";
                // UnitPrice := TempItem."Unit Cost";
                // Amount := (Quantity * UnitPrice);
                ////OldCode
                TempWastageEntryHead.Reset();
                TempWastageEntryHead.SetRange(TempWastageEntryHead."No.", Rec."DocumentNo.");
                IF TempWastageEntryHead.FindFirst() then;
                StockkeepingUnitPrice.Reset(); //PT-FBTS
                StockkeepingUnitPrice.SetRange("Location Code", TempWastageEntryHead."Location Code");
                StockkeepingUnitPrice.SetFilter("Unit Cost", '<>%1', 0);
                StockkeepingUnitPrice.SetRange("Item No.", Rec."Item Code");
                if StockkeepingUnitPrice.FindFirst() then begin
                    UnitPrice := StockkeepingUnitPrice."Unit Cost";
                end
                else
                    UnitPrice := TempItem."Unit Cost";

            end;
        }

        field(6; "Description"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(7; "Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                TestField("Item Code");//Aashish 05-09-2025

                if Rec.Quantity < 0 then
                    Error('Quantity must be postive for Wastage entry');

                Amount := (Quantity * UnitPrice);

                //***  ALLE MY_09-10-2023  Begin

            end;
        }

        field(8; "LineNo."; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;

        }

        field(9; "Reason Code"; text[100])
        {

        }
        field(10; "Remarks"; text[100])
        {

        }
        field(11; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';

            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item Code"));
            // Editable = false;
            trigger OnValidate()
            var
                TempUnitOfMeasure: Record "Item Unit of Measure";
            begin
                TempUnitOfMeasure.Reset();
                TempUnitOfMeasure.SetRange(TempUnitOfMeasure."Item No.", Rec."Item Code");
                TempUnitOfMeasure.SetRange(TempUnitOfMeasure.Code, "Unit of Measure Code");
                IF TempUnitOfMeasure.FindFirst() then;
                IF TempItem.Get(Rec."Item Code") then;

                UnitPrice := (TempItem."Unit Cost" * TempUnitOfMeasure."Qty. per Unit of Measure");
                Rec.Validate(Quantity);



            end;
        }
        field(12; "Amount"; Decimal)
        {
            Editable = false;
        }
        field(13; "UnitPrice"; Decimal)
        {
            Editable = false;
        }
        //ALL_NICk
        field(14; "Stock in hand"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("Item Ledger Entry"."Remaining Quantity" where("Item No." = field("Item Code"), "Location Code" = field("Location Code"), Open = const(true)));
            Editable = false;

        }
        field(18; "Posting Date"; Date)
        {

        }
        field(19; "API Stock"; Decimal)
        {
            Editable = false;
            Caption = 'SOH';
        }
        field(20; "To Data"; Boolean)
        {
        }


        field(21; "Header Location Code"; code[20])
        {
            FieldClass = FlowFilter;
        }
        field(22; "Parent Item No."; code[20])
        {
            trigger OnValidate()
            var
                ItemRec: Record Item;
            begin
                if ItemRec.Get(Rec."Parent Item No.") then
                    Rec.Validate("Parent Item Descrption", ItemRec.Description);
            end;
        }
        field(23; "Parent Item Descrption"; code[100])
        {

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
        TempItem: Record "Item";

}