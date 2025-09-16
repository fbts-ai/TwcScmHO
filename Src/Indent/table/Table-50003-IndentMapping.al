table 50003 "Indent Mapping"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Location Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Location.Code;

        }
        field(2; "Item Category"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(3; "Item No."; Code[20])
        {
            TableRelation = Item."No.";

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                IF Item.Get("Item No.") then begin
                    "Item Category" := Item."Item Category Code";
                    "Item Description" := Item.Description;
                end;
            end;
        }
        field(4; "Approval Required"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Consolidation Applicable"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Sourcing Method"; Option)
        {
            // OptionCaption = '', "Transfer", "Purchase", "Production";
            OptionMembers = " ","Transfer","Purchase","Production";
            trigger OnValidate()
            var
                ItemRec: Record Item;
            begin
                if (Rec."Sourcing Method" = Rec."Sourcing Method"::Transfer) then begin //PT-FBTS-16-09-2025
                    if ItemRec.Get(Rec."Item No.") then
                        if ItemRec."Indent Unit of Measure" = '' then
                            Error('Indent unit of Measure is not defined%1..%2', rec."Item No.", 'Please contect Administrator');
                end;
                if (Rec."Sourcing Method" = Rec."Sourcing Method"::Purchase) then begin //PT-FBTS-16-09-2025
                    if ItemRec.Get(Rec."Item No.") then
                        if ItemRec."Indent Unit of Measure" = '' then
                            Error('Purch. unit of Measure is not defined%1..%2', rec."Item No.", 'Please contect Administrator');
                end;
            end;

        }
        field(7; "Source Location No."; Code[20])
        {
            TableRelation = if ("Sourcing Method" = filter(Purchase)) Vendor else
            Location;
        }
        field(8; "Max Qty."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Item Description"; Text[100])
        {

        }
        field(10; "Min Qty."; Integer)
        { }
        field(11; "Minimum Inventory in days"; Integer)
        { }
        field(12; "Maximun Inventory in days"; Integer)
        { }
        field(13; "Lead Time"; Integer)
        { }
        //PT-FBTS 03-07-2024
        field(14; "Block Indent"; Boolean) //PT-FBTS
        { }
        //PT-FBTS 03-07-2024
    }

    keys
    {
        key(PKey; "Location Code", "Item Category", "Item No.")
        {
            Clustered = true;
        }
        key(Skey; "Source Location No.")
        {

        }
    }

    var
        myInt: Integer;

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
    // // NTCNFRM
    //AJ_Alle_09282023
    var
        tst: Page 5805;

}