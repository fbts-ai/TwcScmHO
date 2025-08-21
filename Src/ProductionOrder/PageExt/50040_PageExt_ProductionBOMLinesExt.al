pageextension 50040 ProductionBOMLinesExt extends "Production BOM Lines"
{
    layout
    {

        modify("No.") //PT-FBTS-170425  
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
        modify("Unit of Measure Code") //PT-FBTS-170425  
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
        addafter("Ending Date")
        {
            // Add changes to page layout here
            field(ItemUnitCost; Rec.ItemUnitCost)
            {
                Visible = False;
                trigger OnValidate()
                var
                    TempProductionBOM: Page "Production BOM";
                begin

                    CurrPage.Update();
                    TempProductionBOM.Update();
                    //Message('Updated');
                end;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }


    var
        myInt: Integer;

    trigger OnModifyRecord(): Boolean
    begin
        /*

        CurrPage.Update();
        Message('Updated modify');
        */
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        /*        CurrPage.Update();
            Rec.Validate(ItemUnitCost);
            Message('Delelte');
            */
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        /*
        CurrPage.Update();
        Rec.Validate(ItemUnitCost);
        Message('insert');
        */
    end;

}