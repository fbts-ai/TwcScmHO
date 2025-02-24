table 50001 Indentline
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "DocumentNo."; Code[25])
        {
            DataClassification = ToBeClassified;

        }
        field(2; "Location/StoreNo.To"; Code[20])
        {
            DataClassification = ToBeClassified;

            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
        }
        field(3; "Location/StoreNo.From"; Code[20])
        {

            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
        }
        field(4; "Type Of Item"; Option)
        {
            Caption = 'Type';
            OptionMembers = " ",Item,"Fixed Asset";
        }
        field(5; Status; Enum Status_indent)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Item Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = IF ("Type Of Item" = CONST(" ")) "Standard Text" ELSE
            //TodayFixedasset
            IF ("Type Of Item" = CONST(Item)) Item;
            // ELSE
            // IF ("Type Of Item" = CONST("Fixed Asset")) "Fixed Asset"; //RkAlle24Nov2023

            trigger OnValidate()
            var
                Item: Record Item;
                FA: Record "Fixed Asset";
                GL_Account: Record "G/L Account";
            begin
                if "Type Of Item" = Rec."Type Of Item"::Item then begin
                    if Item.Get("Item Code") then begin
                        UOM := Item."Indent Unit of Measure";
                        "Description" := item.Description;
                    end;
                end;
                if "Type Of Item" = Rec."Type Of Item"::"Fixed Asset" then begin
                    if FA.Get("Item Code") then begin

                        "Description" := FA.Description;
                    end;
                end;
            end;

        }
        field(21; "Description"; Text[100])
        {
            DataClassification = ToBeClassified;

        }

        field(7; "Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 0;

            trigger OnValidate()
            var
                indentmapp: Record "Indent Mapping";
                IndentHeader: Record IndentHeader;

                Item: Record Item;
                qty: Integer;
            begin
                // IF not Evaluate(qty, Quantity) then
                //     Error('Quantity should be in integer');

                IF Item.Get(rec."Item Code") then begin
                    IF Item.IsFixedAssetItem then
                        Rec.TestField(Quantity, 1);
                end;

                IF xrec.quantity <> 0 then begin
                    IF rec.Quantity <> xRec.Quantity then begin
                        IF IndentHeader.Get(Rec."DocumentNo.") then;

                        //indentmapp.Reset();
                        indentmapp.SetRange("Location Code", IndentHeader."To Location code");
                        indentmapp.SetRange("Item No.", rec."Item Code");
                        IF indentmapp.FindFirst() then;

                        IF indentmapp."Approval Required" then begin
                            Rec.Validate("Approval Required", indentmapp."Approval Required");
                            rec.Validate("Approval Remarks", rec."Approval Remarks"::"Specific Category need approval");
                        end;
                        IF indentmapp."Max Qty." <> 0 then begin
                            IF indentmapp."Max Qty." < rec.Quantity * rec."Item UOM Qty.of measure" then begin
                                rec.Validate("Approval Required", true);
                                rec.Validate("Approval Remarks", rec."Approval Remarks"::"Submitted beyond min & max quantity");
                            end;
                        end;
                        IF indentmapp."Min Qty." <> 0 then begin
                            IF indentmapp."Min Qty." > rec.Quantity * rec."Item UOM Qty.of measure" then begin
                                rec.Validate("Approval Required", true);
                                rec.Validate("Approval Remarks", rec."Approval Remarks"::"Submitted beyond min & max quantity");
                            end;
                        end;
                        Rec.Modify();

                        IF rec."Approval Required" then begin
                            IndentHeader."Approval Required" := Rec."Approval Required";
                            IndentHeader.Modify();
                        end;
                    end;
                end;

            end;

        }
        field(8; "LineNo."; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;

        }
        field(9; "Request Delivery Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(10; Department; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Item UOM"; Code[20])
        {
            Caption = 'Item Base UOM';
            FieldClass = FlowField;
            CalcFormula = lookup(Item."Base Unit of Measure" where("No." = field("Item Code")));

        }
        field(12; "Item UOM Qty.of measure"; Decimal)
        {
            FieldClass = FlowField;
            DecimalPlaces = 0 : 5;
            CalcFormula = lookup("Item Unit of Measure"."Qty. per Unit of Measure" where("Item No." = field("Item Code"), Code = field(UOM)));
        }
        field(16; "UOM"; Code[20])
        {
            // DataClassification = ToBeClassified;
            Caption = 'Indent UOM';
            //TableRelation = "Unit of Measure".Code;
            FieldClass = FlowField;
            CalcFormula = lookup(Item."Indent Unit of Measure" where("No." = field("Item Code")));

        }
        field(50000; "Category"; code[20])
        {

        }
        field(50001; "Remarks"; text[100])
        {

        }

        field(50004; "Indent Date"; Date)
        {
            FieldClass = FlowField;
            CalcFormula = lookup(IndentHeader."Posting date" where("no." = field("DocumentNo.")));
        }
        field(50023; Select; Boolean)
        {

        }
        field(50031; "Sub-Indent"; Boolean)
        {

        }
        field(50032; "Error"; Text[50])
        {

        }
        field(50035; "Approval Required"; Boolean)
        {
            trigger OnValidate()
            begin
                // IF indenthdr.Get("DocumentNo.") then begin
                //   indenthdr.Validate("Approval Required", Rec."Approval Required");
                //  indenthdr.Modify(true);
                //end;
            end;
        }
        field(50036; "Approval Remarks"; Option)
        {
            OptionMembers = "","Submitted Beyond timeline","Specific Category need approval","Submitted beyond min & max quantity";
        }
        field(50037; "FA Subclass"; Code[20])
        {
            TableRelation = "FA Subclass".Code;
        }
        field(50038; "Source Loc"; Code[20])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Indent Mapping"."Source Location No." where("Location Code" = field("Location/StoreNo.From"), "Item No." = field("Item Code")));
        }
        field(50039; "FA Qty. to Ship"; Decimal)
        {
            DecimalPlaces = 0 : 0;

        }
        field(50040; "FA Qty. Shipped"; Decimal)
        {
            DecimalPlaces = 0 : 0;

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
        indenthdr: Record IndentHeader;
    begin
        indenthdr.Reset();
        indenthdr.SetRange("No.", "DocumentNo.");
        IF indenthdr.FindFirst() then begin
            indenthdr.Select := false;
            indenthdr.Modify();
        end;
    end;

    var
        indenthdr: Record IndentHeader;

}