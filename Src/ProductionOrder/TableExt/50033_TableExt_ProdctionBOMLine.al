tableextension 50033 ProdctionBolLineExt extends "Production BOM Line"
{
    fields
    {
        field(50000; ItemUnitCost; decimal)
        {
            Caption = 'ItemUnitCost';

        }
    }

    var
        myInt: Integer;
}