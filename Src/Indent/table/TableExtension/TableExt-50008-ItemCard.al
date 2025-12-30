tableextension 50008 Itemcard extends Item
{
    fields
    {
        // Add changes to table fields here
        modify(Description)
        {
            trigger OnAfterValidate() // PT-FBTS 23/12/25  Ticket-591 
            var
                ItemRec: Record Item;
                ItemNoList: Text;
            begin
                ItemRec.Reset();
                ItemRec.SetRange(Description, Rec.Description);
                ItemRec.SetFilter("No.", '<>%1', Rec."No.");
                if ItemRec.FindSet() then begin
                    repeat
                        if ItemNoList = '' then
                            ItemNoList := ItemRec."No."
                        else
                            ItemNoList += ', ' + ItemRec."No.";
                    until ItemRec.Next() = 0;
                    Message('Same Description already exists for Item No.(s): %1', ItemNoList);
                end;
            end;
        }
        // PT-FBTS 23/12/25  Ticket-591 
        field(50100; "Max Qty"; Decimal)
        {

        }
        field(50101; "Min Qty"; Decimal)
        {

        }
        field(50102; "Indent Unit of Measure"; Code[20])
        {
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("No."));
        }

        //scm Field
        field(50103; InstoreAllowed; Boolean)
        {
            Caption = 'InStore Allowed';
        }
        field(50104; LocalPurchase; Boolean)
        {
            Caption = 'Local Purchase Allow';
        }
        field(50105; IsFixedAssetItem; Boolean)
        {
            Caption = 'Is Fixed Asset Item';
        }
        field(50106; IsStoreProductionItem; Boolean)
        {
            caption = 'Is Store Production Item';
        }
        field(50107; "Auto Assembly"; Boolean) //PT-FBTS
        {
            caption = 'Auto Assembly';
        }
        field(50112; "Special"; Boolean) //PT-FBTS
        {
            Caption = 'Next day delivery';
        }
        field(50108; "BI Super Category"; Code[100]) //PT-FBTS
        {
            caption = 'BI Super Category';
            DataClassification = ToBeClassified;
            TableRelation = SuperCategoryGroup;
            trigger OnValidate()
            var
            begin
                Rec."BI Category Code" := '';
            end;
        }
        field(50109; "BI Category Code"; Text[100]) //PT-FBTS
        {
            caption = 'BI Category Code';
            DataClassification = ToBeClassified;
            TableRelation = CategoryGroupCode where(GroupCode = field("BI Super Category"));
        }
        field(50110; "Send to AP"; Boolean) //PT-FBTS
        {
            Caption = 'Send to AP';
        }
        field(50111; "Open PO Qty."; Decimal) //PT-FBTS
        {
            caption = 'Open PO Qty.';
            FieldClass = FlowField;
            AccessByPermission = TableData "Purch. Rcpt. Header" = R;
            CalcFormula = Sum("Purchase Line"."Outstanding Qty. (Base)" WHERE("Document Type" = CONST(Order),
         Type = CONST(Item), "No." = FIELD("No."), "Short Close" = filter(false), "Shortcut Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
        "Shortcut Dimension 2 Code" = FIELD("Global Dimension 2 Filter"), "Location Code" = FIELD("Location Filter"),
        "Drop Shipment" = FIELD("Drop Shipment Filter"), "Variant Code" = FIELD("Variant Filter"), "Expected Receipt Date" = FIELD("Date Filter"),
                                                                               "Unit of Measure Code" = FIELD("Unit of Measure Filter")));

        }
        //field(50201; "Enable Manual Costing"; Boolean)
        //{ } //FBTS AA
    }

    var
        myInt: Integer;
        itemavia: Page 1872;
    //AJ_Alle_09282023
    //NTCNFRM
    // trigger OnInsert()
    // var
    //     UserSetuprec: Record "User Setup";
    // begin
    //     if UserSetuprec.get(UserId) then begin
    //         if UserSetuprec."Allow Master Modification" = false then Error('You do not have permission to modify');

    //     end;

    // end;

    // trigger OnModify()
    // var
    //     UserSetuprec1: Record "User Setup";
    // begin
    //     if UserSetuprec1.get(UserId) then begin
    //         if UserSetuprec1."Allow Master Modification" = false then Error('You do not have permission to modify');

    //     end;

    // end;

    // trigger OnDelete()
    // var
    //     UserSetuprec2: Record "User Setup";
    // begin
    //     if UserSetuprec2.get(UserId) then begin
    //         if UserSetuprec2."Allow Master Modification" = false then Error('You do not have permission to modify');

    //     end;

    // end;

    // trigger OnRename()
    // var
    //     UserSetuprec3: Record "User Setup";
    // begin
    //     if UserSetuprec3.get(UserId) then begin
    //         if UserSetuprec3."Allow Master Modification" = false then Error('You do not have permission to modify');

    //     end;

    // end;
    //NTCNFRM
    //AJ_Alle_09282023
}