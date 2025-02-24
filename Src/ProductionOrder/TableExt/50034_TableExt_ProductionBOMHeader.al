tableextension 50034 ProductionBOMHeaderExt extends "Production BOM Header"
{
    fields
    {
        field(50000; TotalBOMValue; decimal)
        {
            caption = 'TotalBOMValue';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("Production BOM Line".ItemUnitCost
            WHERE("Production BOM No." = Field("No."))
            );

        }
    }

    var
        myInt: Integer;
}