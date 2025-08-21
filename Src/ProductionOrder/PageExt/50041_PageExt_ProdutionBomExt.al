pageextension 50041 ProdutionBomExt extends "Production BOM"
{

    layout
    {

        addlast(General)
        {

            field(TotalBOMValue; rec.TotalBOMValue)
            {

                trigger OnValidate()
                begin
                    CurrPage.Update();
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

    trigger OnQueryClosePage(dd: Action): Boolean //pT-fbts 220425
    var
        ProductinBomLine: Record "Production BOM Line";
    begin
        ProductinBomLine.Reset();
        ProductinBomLine.SetRange("Production BOM No.", Rec."No.");
        if ProductinBomLine.FindSet() then
            repeat
                if ProductinBomLine."Unit of Measure Code" = 'KGS' then
                    Message('You can not Change unit of Measure%1', ProductinBomLine."Unit of Measure Code");
            until ProductinBomLine.Next() = 0;
    end;
}