tableextension 50170 AssemblyHeader extends "Assembly Header"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Assembly Production"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50102; "Order Posted"; Boolean)
        { }//ICT

    }

    keys
    {
        // Add changes to keys here
    }

    fieldgroups
    {
        // Add changes to field groups here
    }
    trigger OnInsert() //PT-FBTS 190825
    var
        UserSetupRec: Record "User Setup";
    begin
        if UserSetupRec.Get(UserId) then
            Rec.Validate("Location Code", UserSetupRec."Location Code");
    end;

    var
        myInt: Integer;

}