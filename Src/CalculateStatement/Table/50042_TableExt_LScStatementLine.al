tableextension 50042 LSCSatementLineSCMExt extends "LSC Statement Line"
{
    fields
    {
        // Add changes to table fields here
        field(50100; CountedTransaction; Integer)
        {
            Caption = 'Counted Transaction';
            Editable = false;
        }
        field(50101; Remarks; Text[100])
        {
            Caption = 'Remarks';
        }
    }

    var
        myInt: Integer;
}