table 50077 ConsumptionLine
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
        field(3; "Remarks"; Code[200])
        {

        }
        field(4; "Original Bill No"; Code[200])
        {

        }
        field(5; "Item Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            // TableRelation = Item where("BI Super Category" = filter('Food|BEVERAGE'));
            //ValidateTableRelation = true;
            //TableRelation = "Stockkeeping Unit"."Item No." where(WastageItem = filter(<> false));//pT-fbts

            trigger OnValidate()
            var
                TempUnitOfMeasure: Record "Unit of Measure";
                wastageHeader: Record WastageEntryHeader;
                StockkeepingUnitPrice: Record "Stockkeeping Unit";//PT-FBTS
                TempWastageEntryHead: Record WastageEntryHeader;
                pp: record "Purchase Line";
                TempLine: Record ConsumptionLine;
            begin



                TempLine.Reset();
                TempLine.SetRange("DocumentNo.", "DocumentNo.");
                TempLine.SetRange("Item Code", "Item Code");
                TempLine.SetFilter("LineNo.", '<>%1', "LineNo.");
                if TempLine.FindFirst() then
                    Error('Item %1 already exists in this document.', "Item Code");

                ////OldCode
                if "Reason Code" = "Reason Code"::Dialing then begin
                    if "Item Code" <> 'FG000353' then
                        Error('Item Code must be FG000353');
                end;


                IF TempItem.Get(Rec."Item Code") then;
                Description := TempItem.Description;
                "Unit of Measure Code" := TempItem."Base Unit of Measure";

            end;
            // trigger OnLookup()
            // var
            //     myInt: Integer;
            // begin

            // end;
        }
        field(6; "Description"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(7; "Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 3;
        }

        field(8; "LineNo."; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;

        }


        field(10; "Reason Code"; Option)
        {
            OptionMembers = Dialing,Replacement;
        }
        field(11; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';

            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item Code"));
            Editable = false;//PT-FBTS
            trigger OnValidate()
            var
                TempUnitOfMeasure: Record "Item Unit of Measure";
            begin
                TempUnitOfMeasure.Reset();
                TempUnitOfMeasure.SetRange(TempUnitOfMeasure."Item No.", Rec."Item Code");
                TempUnitOfMeasure.SetRange(TempUnitOfMeasure.Code, "Unit of Measure Code");
                IF TempUnitOfMeasure.FindFirst() then;
                IF TempItem.Get(Rec."Item Code") then;
            end;
        }

        field(15; ItemExploaded; Boolean)
        {
            DataClassification = ToBeClassified;
        }

        field(18; "Posting Date"; Date)
        {
        }
        field(21; "Header Location Code"; code[20])
        {
            FieldClass = FlowFilter;
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