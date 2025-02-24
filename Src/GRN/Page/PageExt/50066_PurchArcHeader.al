tableextension 50066 PurchaseArcExt extends "Purchase Header Archive"
{
    fields
    {
        // Add changes to table fields here
        //ALLENick
        field(50108; "Created userId"; code[50])
        {

        }
        field(50109; "Creation Location"; code[20])
        {
            Caption = 'Creation Location';
            TableRelation = Location WHERE("Creation Location" = CONST(true));
        }
    }

    var
        myInt: Integer;
}