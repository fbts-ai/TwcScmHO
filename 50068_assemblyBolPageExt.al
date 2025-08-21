pageextension 50068 AssenblyBomExt extends "Assembly BOM"
{
    layout
    {
        // Add changes to page layout here
        addbefore("Quantity per")
        {
            field("Actual Qty."; Rec."Actual Qty.")
            {
                ApplicationArea = ALL;
                DecimalPlaces = 3;
            }
        }
        addafter("Actual Qty.")
        {
            field("LSC Wastage %"; Rec."LSC Wastage %")
            {
                ApplicationArea = all;
            }
        }
        modify("No.")
        {
            trigger OnAfterValidate()//PT-FBTS-08-07-25    
            var
                ItemUOM: Record "Item Unit of Measure";
            begin
                ItemUOM.Reset();
                ItemUOM.SetRange("Item No.", Rec."No.");
                if ItemUOM.FindFirst() then
                    if Rec."Unit of Measure Code" = 'KGS' then
                        Message('You can not Change unit of Measure%1', Rec."Unit of Measure Code");

            end;
        }
        modify("Unit of Measure Code")//PT-FBTS-08-07-25   
        {
            trigger OnAfterValidate()
            var
                ItemUOM: Record "Item Unit of Measure";
            begin
                ItemUOM.Reset();
                ItemUOM.SetRange("Item No.", Rec."No.");
                if ItemUOM.FindFirst() then
                    if Rec."Unit of Measure Code" = 'KGS' then
                        Message('You can not Change unit of Measure%1', Rec."Unit of Measure Code");

            end;
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
        dfd: report 795;

        fd: codeunit 5895;

    trigger OnQueryClosePage(dd: Action): Boolean //PT-FBTS-08-07-25  
    var
        myInt: Integer;
    begin
        if Rec."Unit of Measure Code" = 'KGS' then
            Message('You can not Change unit of Measure%1', Rec."Unit of Measure Code");


    end;
}