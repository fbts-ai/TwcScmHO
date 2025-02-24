table 50109 "User Location Link Table" ///PT- FBTS -19-06-2024
{
    fields
    {
        field(1; "S.No."; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(2; "User Id"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "User Setup";
        }
        field(3; "Location Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Location.Code;

            trigger OnValidate()
            var
                myInt: Integer;
                Location_REc: Record Location;
            begin
                Location_REc.Get("location Code");
                Rec."Location Name" := Location_REc.Name;
            end;
        }
        // field(4; "Transfer to Code "; Code[20])
        // {
        //     DataClassification = ToBeClassified;
        //     TableRelation = Location.Code;
        //     trigger OnValidate()
        //     var
        //         myInt: Integer;
        //         Locatin_Rc: Record Location;
        //     begin
        //         Locatin_Rc.Get("Transfer to Code ");
        //         Rec."Transfer To Name" := Locatin_Rc.Name;
        //     end;

        // }
        field(5; "Location Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        // field(6; "Transfer To Name"; Text[100])
        // {
        //     DataClassification = ToBeClassified;
        //     Editable = false;
        // }
        // field(7; "Ship Permission"; Boolean)    // AA_05.03.23
        // {
        //     DataClassification = ToBeClassified;
        //     trigger OnValidate()
        //     var
        //         myInt: Integer;
        //     begin
        //         // AA_03.04.23_+++
        //         // if Rec."Receive Permission" = true then begin
        //         //     Error('Receive Permission Should be False');
        //         // end else
        //         //     exit;
        //         // AA_03.04.23_+++

        //     end;

        // }
        // field(8; "Receive Permission"; Boolean)   // AA_05.03.23
        // {
        //     DataClassification = ToBeClassified;
        //     trigger OnValidate()
        //     var
        //         myInt: Integer;
        //     begin
        //         // AA_03.04.23_+++

        //         // if Rec."Ship Permission" = true then begin
        //         //     Error('Receive Permission Should be False');
        //         // end else
        //         //     exit;
        //         // AA_03.04.23_+++

        //     end;
        // }
        // // AA_17.04.23_+++
        // field(9; "Both Permission"; Boolean)
        // {
        //     DataClassification = ToBeClassified;
        // }
        // AA_17.04.23_+++


    }
    keys
    {
        key(PK; "User Id", "Location Code")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "Location Code", "Location Name")
        {


        }
    }
}