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
}