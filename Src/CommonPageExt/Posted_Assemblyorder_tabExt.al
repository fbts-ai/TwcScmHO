tableextension 50171 AssemblyPosted extends "Posted Assembly Header"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Assembly Production"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        //PT-FBTS 10-11-2025 RepCounter
        field(50001; "Replication Counter"; Integer)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                // Transaction: Record "LSC Transaction Header";
                Transaction: Record "Posted Assembly Header";
                ClientSessionUtility: Codeunit "LSC Client Session Utility";
            begin
                // Transaction.SetCurrentKey("Replication Counter");
                // if Transaction.FindLast then
                //     "Replication Counter" := Transaction."Replication Counter" + 1
                // else
                //     "Replication Counter" := 1;
            end;
        }
        //PT-FBTS 10-11-2025 RepCounter
    }

    keys
    {
        // Add changes to keys here

        key(sec; "Replication Counter") //PT-FBTS 10-11-2025 RepCounter
        {

        }
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