tableextension 50056 LSCPostedStatementExt extends "LSC Posted Statement Line"
{
    fields
    {
        // Add changes to table fields here
        field(50101; Remarks; Text[100])
        {
            Caption = 'Remarks';
        }
    }

    var
        myInt: Integer;
}