tableextension 50008 Itemcard extends Item
{
    fields
    {
        // Add changes to table fields here
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