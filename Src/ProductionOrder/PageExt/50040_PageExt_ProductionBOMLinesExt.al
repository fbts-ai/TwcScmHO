pageextension 50040 ProductionBOMLinesExt extends "Production BOM Lines"
{
    layout
    {
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